import json
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import AiChatMessage, User, UserProfile
from app.schemas.ai_chat_schema import (
    AiApplyActionRequest,
    AiApplyActionResponse,
    AiChatHistoryItem,
    AiChatHistoryResponse,
    AiChatRequest,
    AiChatResponse,
)
from app.services.ai_action_apply_service import apply_pending_action
from app.services.ai_action_service import (
    build_pending_action_answer,
    detect_pending_action,
)
from app.services.ai_context_service import build_ai_user_context
from app.services.ai_prompt_service import build_coach_prompt
from app.services.gemini_text_service import generate_text_response


router = APIRouter(
    prefix="/ai-chat",
    tags=["AI Chat"],
)


def _pending_action_to_json(
    pending_action: Optional[Dict[str, Any]],
) -> Optional[str]:
    if pending_action is None:
        return None

    return json.dumps(
        pending_action,
        ensure_ascii=False,
    )


def _pending_action_from_json(
    raw_pending_action: Optional[str],
) -> Optional[Dict[str, Any]]:
    if not raw_pending_action:
        return None

    try:
        data = json.loads(raw_pending_action)

        if isinstance(data, dict):
            return data

        return None
    except Exception:
        return None


def _save_chat_message(
    db: Session,
    user: User,
    role: str,
    content: str,
    pending_action: Optional[Dict[str, Any]] = None,
) -> AiChatMessage:
    chat_message = AiChatMessage(
        user_id=user.id,
        role=role,
        content=content,
        pending_action_json=_pending_action_to_json(pending_action),
    )

    db.add(chat_message)
    db.commit()
    db.refresh(chat_message)

    return chat_message


def _chat_message_to_history_item(
    chat_message: AiChatMessage,
) -> AiChatHistoryItem:
    return AiChatHistoryItem(
        id=chat_message.id,
        role=chat_message.role,
        content=chat_message.content,
        pending_action=_pending_action_from_json(chat_message.pending_action_json),
        created_at=chat_message.created_at,
    )


def _get_recent_chat_messages_for_prompt(
    db: Session,
    user: User,
    limit: int = 10,
    exclude_message_id: Optional[int] = None,
) -> list[dict[str, Any]]:
    query = db.query(AiChatMessage).filter(
        AiChatMessage.user_id == user.id,
    )

    if exclude_message_id is not None:
        query = query.filter(
            AiChatMessage.id != exclude_message_id,
        )

    messages = (
        query
        .order_by(AiChatMessage.created_at.desc())
        .limit(limit)
        .all()
    )

    messages = list(reversed(messages))

    return [
        {
            "role": message.role,
            "content": message.content,
        }
        for message in messages
    ]


@router.post("/message", response_model=AiChatResponse)
def send_ai_message(
    payload: AiChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        user_message = payload.message.strip()

        saved_user_message = _save_chat_message(
            db=db,
            user=current_user,
            role="user",
            content=user_message,
        )

        profile = (
            db.query(UserProfile)
            .filter(UserProfile.user_id == current_user.id)
            .first()
        )

        app_context = build_ai_user_context(
            db=db,
            user=current_user,
        )

        pending_action = detect_pending_action(
            db=db,
            user=current_user,
            message=user_message,
        )

        recent_messages = _get_recent_chat_messages_for_prompt(
            db=db,
            user=current_user,
            limit=10,
            exclude_message_id=saved_user_message.id,
        )

        if pending_action is not None:
            answer = build_pending_action_answer(pending_action)
        else:
            prompt = build_coach_prompt(
                user=current_user,
                profile=profile,
                message=user_message,
                app_context=app_context,
                recent_messages=recent_messages,
            )

            answer = generate_text_response(prompt)

        _save_chat_message(
            db=db,
            user=current_user,
            role="assistant",
            content=answer,
            pending_action=pending_action,
        )

        print("======== CONTEXTO IA PULSEAI ========")
        print(app_context)
        print("======== HISTORIAL RECIENTE IA ========")
        print(recent_messages)
        print("======== ACCIÓN PENDIENTE IA ========")
        print(pending_action)
        print("======== RESPUESTA IA COMPLETA ========")
        print(answer)
        print("======== LONGITUD RESPUESTA ========")
        print(len(answer))
        print("======================================")

        return AiChatResponse(
            answer=answer,
            pending_action=pending_action,
        )

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )

    except Exception as e:
        error_text = str(e)

        print("======== ERROR REAL GEMINI / IA ========")
        print(error_text)
        print("========================================")

        if (
            "429" in error_text
            or "RESOURCE_EXHAUSTED" in error_text
            or "Quota exceeded" in error_text
            or "quota" in error_text.lower()
        ):
            raise HTTPException(
                status_code=429,
                detail="Has alcanzado temporalmente el límite gratuito del Coach IA. Espera unos segundos o vuelve a intentarlo más tarde.",
            )

        if (
            "503" in error_text
            or "UNAVAILABLE" in error_text
            or "high demand" in error_text
            or "overloaded" in error_text.lower()
        ):
            raise HTTPException(
                status_code=503,
                detail="El Coach IA está saturado temporalmente. Inténtalo de nuevo en unos segundos.",
            )

        raise HTTPException(
            status_code=500,
            detail=f"Error generando respuesta IA: {error_text}",
        )


@router.post("/apply-action", response_model=AiApplyActionResponse)
def apply_ai_action(
    payload: AiApplyActionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        result = apply_pending_action(
            db=db,
            user=current_user,
            pending_action=payload.pending_action.model_dump(),
        )

        response = AiApplyActionResponse(**result)

        _save_chat_message(
            db=db,
            user=current_user,
            role="assistant",
            content=response.message,
        )

        return response

    except HTTPException:
        raise

    except Exception as e:
        error_text = str(e)

        print("======== ERROR APLICANDO ACCIÓN IA ========")
        print(error_text)
        print("===========================================")

        raise HTTPException(
            status_code=500,
            detail=f"Error aplicando acción IA: {error_text}",
        )


@router.get("/history", response_model=AiChatHistoryResponse)
def get_ai_chat_history(
    limit: int = Query(default=30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    messages = (
        db.query(AiChatMessage)
        .filter(AiChatMessage.user_id == current_user.id)
        .order_by(AiChatMessage.created_at.desc())
        .limit(limit)
        .all()
    )

    messages = list(reversed(messages))

    return AiChatHistoryResponse(
        messages=[
            _chat_message_to_history_item(message)
            for message in messages
        ]
    )