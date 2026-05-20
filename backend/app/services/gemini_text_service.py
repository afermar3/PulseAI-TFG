import os
import re
from pathlib import Path

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


def _clean_response(text: str) -> str:
    cleaned = text.strip()

    cleaned = cleaned.replace("###", "")
    cleaned = cleaned.replace("##", "")
    cleaned = cleaned.replace("#", "")

    cleaned = cleaned.replace("**", "")
    cleaned = cleaned.replace("__", "")
    cleaned = cleaned.replace("*   *", "- ")
    cleaned = cleaned.replace("*  *", "- ")
    cleaned = cleaned.replace("* *", "- ")
    cleaned = cleaned.replace("*   ", "- ")
    cleaned = cleaned.replace("* ", "- ")
    cleaned = cleaned.replace("*", "")

    cleaned = cleaned.replace("---", "")

    cleaned = re.sub(r"^\s*[-•]\s+", "- ", cleaned, flags=re.MULTILINE)
    cleaned = re.sub(r"[ \t]+", " ", cleaned)
    cleaned = re.sub(r"\n{3,}", "\n\n", cleaned)

    return cleaned.strip()


def generate_text_response(prompt: str) -> str:
    client = _get_client()

    response = client.models.generate_content(
        #model="gemini-2.5-flash",
        model="gemini-2.5-flash-lite",
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.4,
            max_output_tokens=2200,
            thinking_config=types.ThinkingConfig(
                thinking_budget=0,
            ),
        ),
    )

    if not response.text:
        raise RuntimeError("Gemini no ha devuelto respuesta.")

    return _clean_response(response.text)