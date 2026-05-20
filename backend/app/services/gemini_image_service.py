""" import os
from pathlib import Path

from dotenv import load_dotenv
from google import genai
from google.genai import types

from app.services.image_prompt_service import build_image_prompt


BACKEND_ROOT = Path(__file__).resolve().parents[2]
GENERATED_IMAGES_DIR = BACKEND_ROOT / "generated_images"
GENERATED_IMAGES_DIR.mkdir(parents=True, exist_ok=True)

load_dotenv(BACKEND_ROOT / ".env")


def _get_client() -> genai.Client:
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise ValueError("Falta GEMINI_API_KEY en backend/.env")

    return genai.Client(api_key=api_key)


def generate_or_get_screen_image(
    screen: str,
    force_regenerate: bool = False,
) -> dict:
    screen_key = screen.lower().strip()
    prompt = build_image_prompt(screen_key)

    file_name = f"{screen_key}.png"
    file_path = GENERATED_IMAGES_DIR / file_name

    if file_path.exists() and not force_regenerate:
        return {
            "screen": screen_key,
            "prompt": prompt,
            "image_path": f"/generated-images/{file_name}",
            "image_url": f"/generated-images/{file_name}",
            "cached": True,
        }

    client = _get_client()

    response = client.models.generate_images(
        model="imagen-4.0-generate-001",
        prompt=prompt,
        config=types.GenerateImagesConfig(
            number_of_images=1,
            aspect_ratio="1:1",
        ),
    )

    if not response.generated_images:
        raise RuntimeError("Gemini/Imagen no ha devuelto ninguna imagen.")

    generated_image = response.generated_images[0]

    # La SDK permite guardar directamente la imagen generada.
    generated_image.image.save(str(file_path))

    return {
        "screen": screen_key,
        "prompt": prompt,
        "image_path": f"/generated-images/{file_name}",
        "image_url": f"/generated-images/{file_name}",
        "cached": False,
    } """