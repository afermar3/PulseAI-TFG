import json
import re

from fastapi import APIRouter, Depends, HTTPException
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import Exercise, User, UserProfile
from app.schemas.ai_workout_schema import (
    AiWorkoutGenerateRequest,
    AiWorkoutGenerateResponse,
)
from app.services.ai_workout_prompt_service import build_ai_workout_prompt
from app.services.gemini_text_service import generate_json_response


router = APIRouter(
    prefix="/ai-workouts",
    tags=["AI Workouts"],
)


def _extract_json_from_text(text: str) -> dict:
    cleaned_text = text.strip()

    cleaned_text = cleaned_text.replace("```json", "")
    cleaned_text = cleaned_text.replace("```", "")
    cleaned_text = cleaned_text.strip()

    try:
        return json.loads(cleaned_text)
    except json.JSONDecodeError:
        match = re.search(r"\{.*\}", cleaned_text, re.DOTALL)

        if not match:
            raise ValueError("La IA no ha devuelto un JSON válido.")

        return json.loads(match.group(0))


@router.post("/generate", response_model=AiWorkoutGenerateResponse)
def generate_ai_workout(
    payload: AiWorkoutGenerateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        profile = (
            db.query(UserProfile)
            .filter(UserProfile.user_id == current_user.id)
            .first()
        )

        exercises = db.query(Exercise).order_by(Exercise.id.asc()).all()

        if not exercises:
            raise HTTPException(
                status_code=400,
                detail="No hay ejercicios disponibles. Ejecuta primero /exercises/seed.",
            )

        prompt = build_ai_workout_prompt(
            user=current_user,
            profile=profile,
            exercises=exercises,
            days_per_week=payload.days_per_week,
            duration_minutes=payload.duration_minutes,
            focus=payload.focus,
            level=payload.level,
        )

        raw_response = generate_json_response(
            prompt=prompt,
            response_schema=AiWorkoutGenerateResponse,
        )

        workout_data = _extract_json_from_text(raw_response)

        return AiWorkoutGenerateResponse(**workout_data)

    except HTTPException:
        raise

    except ValidationError as e:
        raise HTTPException(
            status_code=500,
            detail=f"La IA devolvió una rutina con formato incorrecto: {str(e)}",
        )

    except ValueError as e:
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    except Exception as e:
        error_text = str(e)

        if "503" in error_text or "UNAVAILABLE" in error_text or "high demand" in error_text:
            raise HTTPException(
                status_code=503,
                detail="El generador de rutinas está saturado temporalmente. Inténtalo de nuevo en unos segundos.",
            )
        if "429" in error_text or "RESOURCE_EXHAUSTED" in error_text or "quota" in error_text.lower():
            raise HTTPException(
                status_code=429,
                detail="Has alcanzado el límite gratuito de Gemini por ahora. Inténtalo más tarde o prueba con una rutina ya guardada.",
    )

        raise HTTPException(
            status_code=500,
            detail=f"Error generando rutina IA: {error_text}",
        )