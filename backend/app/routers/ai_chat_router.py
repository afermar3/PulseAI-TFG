from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import User, UserProfile
from app.schemas.ai_chat_schema import AiChatRequest, AiChatResponse
from app.services.ai_prompt_service import build_coach_prompt
from app.services.gemini_text_service import generate_text_response


router = APIRouter(
    prefix="/ai-chat",
    tags=["AI Chat"],
)


@router.post("/message", response_model=AiChatResponse)
def send_ai_message(
    payload: AiChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        profile = (
            db.query(UserProfile)
            .filter(UserProfile.user_id == current_user.id)
            .first()
        )

        prompt = build_coach_prompt(
            user=current_user,
            profile=profile,
            message=payload.message,
        )

        answer = generate_text_response(prompt)

        print("======== RESPUESTA IA COMPLETA ========")
        print(answer)
        print("======== LONGITUD RESPUESTA ========")
        print(len(answer))
        print("======================================")

        return AiChatResponse(answer=answer)

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