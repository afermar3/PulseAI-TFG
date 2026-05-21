import os
import time
from pathlib import Path
from typing import Any

from dotenv import load_dotenv
from google import genai
from google.genai import types


BACKEND_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(BACKEND_ROOT / ".env")


def _get_client() -> genai.Client:
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise ValueError("Falta GEMINI_API_KEY en backend/.env")

    return genai.Client(api_key=api_key)


def generate_text_response(prompt: str) -> str:
    client = _get_client()

    last_error = None

    for attempt in range(2):
        try:
            response = client.models.generate_content(
                #model="gemini-2.5-flash",
                model="gemini-2.5-flash-lite",
                #model="gemini-2.0-flash-lite",
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.35,
                    max_output_tokens=2200,
                ),
            )

            if not response.text:
                raise RuntimeError("Gemini no ha devuelto respuesta.")

            return response.text.strip()

        except Exception as e:
            last_error = e
            error_text = str(e)

            if (
                "503" in error_text
                or "UNAVAILABLE" in error_text
                or "high demand" in error_text
            ):
                time.sleep(2)
                continue

            raise e

    raise last_error


def generate_json_response(
    prompt: str,
    response_schema: Any,
) -> str:
    client = _get_client()

    last_error = None

    for attempt in range(2):
        try:
            response = client.models.generate_content(
                #model="gemini-2.5-flash",
                model="gemini-2.5-flash-lite",
                #model="gemini-2.0-flash-lite",
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.25,
                    max_output_tokens=6000,
                    response_mime_type="application/json",
                    response_schema=response_schema,
                ),
            )

            if not response.text:
                raise RuntimeError("Gemini no ha devuelto JSON.")

            return response.text.strip()

        except Exception as e:
            last_error = e
            error_text = str(e)

            if (
                "503" in error_text
                or "UNAVAILABLE" in error_text
                or "high demand" in error_text
            ):
                time.sleep(2)
                continue

            raise e

    raise last_error