import json
import unicodedata
from typing import Any, Dict, List

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.database.models import Exercise, SavedWorkout, User


def _normalize(text: str) -> str:
    normalized = unicodedata.normalize("NFD", text.lower().strip())
    normalized = "".join(
        char
        for char in normalized
        if unicodedata.category(char) != "Mn"
    )

    return normalized


def _parse_content_json(raw_content: str) -> Dict[str, Any]:
    try:
        data = json.loads(raw_content)

        if isinstance(data, dict):
            return data

        return {}
    except Exception:
        return {}


def _save_content_json(data: Dict[str, Any]) -> str:
    return json.dumps(
        data,
        ensure_ascii=False,
    )


def _get_user_workout(
    db: Session,
    user: User,
    saved_workout_id: int,
) -> SavedWorkout:
    workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.id == saved_workout_id,
            SavedWorkout.user_id == user.id,
        )
        .first()
    )

    if workout is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rutina guardada no encontrada",
        )

    return workout


def _validate_exercises_exist(
    db: Session,
    exercises: List[Dict[str, Any]],
) -> None:
    if not exercises:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene ejercicios para añadir",
        )

    for exercise in exercises:
        exercise_id = exercise.get("exercise_id")

        if exercise_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La acción contiene ejercicios sin ID real de la base de datos",
            )

        existing_exercise = (
            db.query(Exercise)
            .filter(Exercise.id == exercise_id)
            .first()
        )

        if existing_exercise is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"El ejercicio con ID {exercise_id} no existe",
            )


def _exercise_exists_in_day(
    exercises: List[Dict[str, Any]],
    exercise_id: int,
    exercise_name: str,
) -> bool:
    normalized_new_name = _normalize(exercise_name)

    for exercise in exercises:
        if not isinstance(exercise, dict):
            continue

        existing_id = exercise.get("exercise_id")
        existing_name = (
            exercise.get("exercise_name")
            or exercise.get("name")
            or ""
        )

        if existing_id is not None:
            try:
                if int(existing_id) == int(exercise_id):
                    return True
            except Exception:
                pass

        if existing_name and _normalize(str(existing_name)) == normalized_new_name:
            return True

    return False


def _normalize_day_payload(
    day_payload: Dict[str, Any],
    next_day_number: int,
) -> Dict[str, Any]:
    exercises = day_payload.get("exercises")

    if not isinstance(exercises, list) or not exercises:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El día propuesto no contiene ejercicios válidos",
        )

    normalized_exercises = []

    for raw_exercise in exercises:
        if not isinstance(raw_exercise, dict):
            continue

        exercise_id = raw_exercise.get("exercise_id")
        exercise_name = raw_exercise.get("exercise_name") or raw_exercise.get("name")

        if exercise_id is None or not exercise_name:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Hay ejercicios incompletos en la acción pendiente",
            )

        if _exercise_exists_in_day(
            exercises=normalized_exercises,
            exercise_id=int(exercise_id),
            exercise_name=str(exercise_name),
        ):
            continue

        normalized_exercises.append(
            {
                "exercise_id": exercise_id,
                "exercise_name": str(exercise_name),
                "sets": raw_exercise.get("sets") or 3,
                "reps": raw_exercise.get("reps") or "10-12",
                "rest_seconds": raw_exercise.get("rest_seconds") or 60,
                "notes": raw_exercise.get("notes") or "",
            }
        )

    if not normalized_exercises:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se han podido normalizar los ejercicios de la acción",
        )

    return {
        "day_number": next_day_number,
        "name": day_payload.get("name") or f"Día {next_day_number}",
        "focus": day_payload.get("focus") or "Entrenamiento añadido por PulseAI",
        "duration_minutes": day_payload.get("duration_minutes"),
        "exercises": normalized_exercises,
    }


def _apply_add_workout_day(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}

    saved_workout_id = payload.get("saved_workout_id")
    day_payload = payload.get("day")

    if saved_workout_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene saved_workout_id",
        )

    if not isinstance(day_payload, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene un día válido para añadir",
        )

    workout = _get_user_workout(
        db=db,
        user=user,
        saved_workout_id=int(saved_workout_id),
    )

    content = _parse_content_json(workout.content_json)

    days = content.get("days")

    if not isinstance(days, list):
        days = []

    exercises = day_payload.get("exercises")

    if not isinstance(exercises, list):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene ejercicios válidos",
        )

    _validate_exercises_exist(
        db=db,
        exercises=exercises,
    )

    next_day_number = len(days) + 1

    normalized_day = _normalize_day_payload(
        day_payload=day_payload,
        next_day_number=next_day_number,
    )

    days.append(normalized_day)

    content["days"] = days
    content["days_per_week"] = len(days)

    if "title" not in content or not content.get("title"):
        content["title"] = workout.title

    if "source" not in content:
        content["source"] = content.get("source") or "AI_ACTION"

    workout.content_json = _save_content_json(content)
    workout.days_per_week = len(days)

    if normalized_day.get("duration_minutes"):
        workout.duration_minutes = normalized_day.get("duration_minutes")

    db.commit()
    db.refresh(workout)

    return {
        "saved_workout_id": workout.id,
        "workout_title": workout.title,
        "added_day": normalized_day,
        "days_per_week": workout.days_per_week,
    }


def _apply_add_exercise_to_day(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}

    saved_workout_id = payload.get("saved_workout_id")
    day_number = payload.get("day_number")
    exercise_payload = payload.get("exercise")

    if saved_workout_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene saved_workout_id",
        )

    if day_number is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene day_number",
        )

    if not isinstance(exercise_payload, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene un ejercicio válido",
        )

    exercise_id = exercise_payload.get("exercise_id")

    if exercise_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El ejercicio no tiene ID real de la base de datos",
        )

    existing_exercise = (
        db.query(Exercise)
        .filter(Exercise.id == exercise_id)
        .first()
    )

    if existing_exercise is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"El ejercicio con ID {exercise_id} no existe",
        )

    workout = _get_user_workout(
        db=db,
        user=user,
        saved_workout_id=int(saved_workout_id),
    )

    content = _parse_content_json(workout.content_json)
    days = content.get("days")

    if not isinstance(days, list):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La rutina no contiene días válidos",
        )

    day_index = int(day_number) - 1

    if day_index < 0 or day_index >= len(days):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"El día {day_number} no existe en la rutina",
        )

    selected_day = days[day_index]

    if not isinstance(selected_day, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El día seleccionado no tiene formato válido",
        )

    exercises = selected_day.get("exercises")

    if not isinstance(exercises, list):
        exercises = []

    if _exercise_exists_in_day(
        exercises=exercises,
        exercise_id=existing_exercise.id,
        exercise_name=existing_exercise.name,
    ):
        return {
            "success": False,
            "already_exists": True,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": int(day_number),
            "day_name": selected_day.get("name") or f"Día {day_number}",
            "exercise": {
                "exercise_id": existing_exercise.id,
                "exercise_name": existing_exercise.name,
            },
        }

    normalized_exercise = {
        "exercise_id": existing_exercise.id,
        "exercise_name": existing_exercise.name,
        "sets": exercise_payload.get("sets") or 3,
        "reps": exercise_payload.get("reps") or "10-12",
        "rest_seconds": exercise_payload.get("rest_seconds") or 60,
        "notes": exercise_payload.get("notes") or "",
    }

    exercises.append(normalized_exercise)

    selected_day["exercises"] = exercises
    days[day_index] = selected_day
    content["days"] = days

    workout.content_json = _save_content_json(content)

    db.commit()
    db.refresh(workout)

    return {
        "success": True,
        "already_exists": False,
        "saved_workout_id": workout.id,
        "workout_title": workout.title,
        "day_number": int(day_number),
        "day_name": selected_day.get("name") or f"Día {day_number}",
        "added_exercise": normalized_exercise,
    }


def apply_pending_action(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    action_type = pending_action.get("type")

    if action_type == "add_workout_day":
        data = _apply_add_workout_day(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        return {
            "success": True,
            "message": "El entrenamiento se ha añadido correctamente a tu rutina activa.",
            "action_type": action_type,
            "data": data,
        }

    if action_type == "add_exercise_to_day":
        data = _apply_add_exercise_to_day(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        if data.get("already_exists") is True:
            return {
                "success": False,
                "message": "Ese ejercicio ya estaba añadido en el día seleccionado. No se ha duplicado.",
                "action_type": action_type,
                "data": data,
            }

        return {
            "success": True,
            "message": "El ejercicio se ha añadido correctamente al día seleccionado.",
            "action_type": action_type,
            "data": data,
        }

    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail=f"La acción '{action_type}' todavía no está soportada para aplicarse",
    )