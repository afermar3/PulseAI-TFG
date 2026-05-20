""" from fastapi import APIRouter, HTTPException

from app.schemas.ai_image_schema import (
    GenerateScreenImageRequest,
    GenerateScreenImageResponse,
)
from app.services.gemini_image_service import generate_or_get_screen_image


router = APIRouter(
    prefix="/ai-images",
    tags=["AI Images"],
)


@router.post("/generate", response_model=GenerateScreenImageResponse)
def generate_screen_image(payload: GenerateScreenImageRequest):
    try:
        return generate_or_get_screen_image(
            screen=payload.screen,
            force_regenerate=payload.force_regenerate,
        )

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error generando imagen: {str(e)}",
        ) """