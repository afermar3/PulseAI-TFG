import json
import unicodedata
from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.database.models import Exercise, SavedWorkout, ScheduledWorkout, User


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
    ignored_index: Optional[int] = None,
) -> bool:
    normalized_new_name = _normalize(exercise_name)

    for index, exercise in enumerate(exercises):
        if ignored_index is not None and index == ignored_index:
            continue

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


def _is_same_exercise(
    old_exercise: Dict[str, Any],
    new_exercise_id: int,
    new_exercise_name: str,
) -> bool:
    old_exercise_id = old_exercise.get("exercise_id")
    old_exercise_name = (
        old_exercise.get("exercise_name")
        or old_exercise.get("name")
        or ""
    )

    if old_exercise_id is not None:
        try:
            if int(old_exercise_id) == int(new_exercise_id):
                return True
        except Exception:
            pass

    if old_exercise_name:
        return _normalize(str(old_exercise_name)) == _normalize(new_exercise_name)

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


def _find_exercise_in_days(
    days: List[Dict[str, Any]],
    old_exercise_text: str,
    day_number: Optional[int] = None,
):
    normalized_old = _normalize(old_exercise_text)

    start_index = 0
    end_index = len(days)

    if day_number is not None:
        day_index = int(day_number) - 1

        if day_index < 0 or day_index >= len(days):
            return None

        start_index = day_index
        end_index = day_index + 1

    for day_index in range(start_index, end_index):
        day = days[day_index]

        if not isinstance(day, dict):
            continue

        exercises = day.get("exercises")

        if not isinstance(exercises, list):
            continue

        for exercise_index, exercise in enumerate(exercises):
            if not isinstance(exercise, dict):
                continue

            exercise_name = (
                exercise.get("exercise_name")
                or exercise.get("name")
                or ""
            )

            normalized_name = _normalize(str(exercise_name))

            if normalized_old == normalized_name:
                return day_index, exercise_index, exercise

            if normalized_old in normalized_name:
                return day_index, exercise_index, exercise

            if normalized_name in normalized_old:
                return day_index, exercise_index, exercise

    return None


def _find_exercise_for_update(
    exercises: List[Dict[str, Any]],
    exercise_id: Any,
    exercise_name: str,
):
    normalized_target_name = _normalize(exercise_name)

    for index, exercise in enumerate(exercises):
        if not isinstance(exercise, dict):
            continue

        current_id = exercise.get("exercise_id")
        current_name = (
            exercise.get("exercise_name")
            or exercise.get("name")
            or ""
        )

        if exercise_id is not None and current_id is not None:
            try:
                if int(current_id) == int(exercise_id):
                    return index, exercise
            except Exception:
                pass

        if current_name and _normalize(str(current_name)) == normalized_target_name:
            return index, exercise

    return None


def _apply_update_exercise_config(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}

    saved_workout_id = payload.get("saved_workout_id")
    day_number = payload.get("day_number")
    exercise_id = payload.get("exercise_id")
    exercise_name = payload.get("exercise_name")
    updates = payload.get("updates")

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

    if not exercise_name:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene el nombre del ejercicio",
        )

    if not isinstance(updates, dict) or not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene cambios válidos",
        )

    allowed_updates = {"sets", "reps", "rest_seconds"}
    clean_updates: Dict[str, Any] = {}

    for key, value in updates.items():
        if key not in allowed_updates:
            continue

        if key == "sets":
            try:
                parsed_value = int(value)
            except Exception:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="El valor de series no es válido",
                )

            if parsed_value < 1 or parsed_value > 20:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="El valor de series debe estar entre 1 y 20",
                )

            clean_updates[key] = parsed_value

        elif key == "reps":
            text_value = str(value).strip()

            if not text_value:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="El valor de repeticiones no es válido",
                )

            clean_updates[key] = text_value

        elif key == "rest_seconds":
            try:
                parsed_value = int(value)
            except Exception:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="El valor de descanso no es válido",
                )

            if parsed_value < 0 or parsed_value > 600:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="El descanso debe estar entre 0 y 600 segundos",
                )

            clean_updates[key] = parsed_value

    if not clean_updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No hay cambios válidos para aplicar",
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

    try:
        parsed_day_number = int(day_number)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El número de día no es válido",
        )

    day_index = parsed_day_number - 1

    if day_index < 0 or day_index >= len(days):
        return {
            "success": False,
            "invalid_day": True,
            "not_found": False,
            "no_changes": False,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": parsed_day_number,
            "available_days": len(days),
            "exercise_name": exercise_name,
            "updates": clean_updates,
        }

    selected_day = days[day_index]

    if not isinstance(selected_day, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El día seleccionado no tiene formato válido",
        )

    exercises = selected_day.get("exercises")

    if not isinstance(exercises, list):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El día seleccionado no contiene ejercicios válidos",
        )

    found = _find_exercise_for_update(
        exercises=exercises,
        exercise_id=exercise_id,
        exercise_name=str(exercise_name),
    )

    if found is None:
        return {
            "success": False,
            "invalid_day": False,
            "not_found": True,
            "no_changes": False,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": parsed_day_number,
            "day_name": selected_day.get("name") or f"Día {parsed_day_number}",
            "exercise_name": exercise_name,
            "updates": clean_updates,
        }

    exercise_index, exercise = found

    before = {
        "sets": exercise.get("sets"),
        "reps": exercise.get("reps"),
        "rest_seconds": exercise.get("rest_seconds"),
    }

    applied_updates: Dict[str, Any] = {}

    for key, value in clean_updates.items():
        current_value = exercise.get(key)

        if str(current_value) != str(value):
            exercise[key] = value
            applied_updates[key] = value

    if not applied_updates:
        return {
            "success": False,
            "invalid_day": False,
            "not_found": False,
            "no_changes": True,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": parsed_day_number,
            "day_name": selected_day.get("name") or f"Día {parsed_day_number}",
            "exercise_name": (
                exercise.get("exercise_name")
                or exercise.get("name")
                or exercise_name
            ),
            "before": before,
            "updates": clean_updates,
        }

    exercises[exercise_index] = exercise
    selected_day["exercises"] = exercises
    days[day_index] = selected_day
    content["days"] = days

    workout.content_json = _save_content_json(content)

    db.commit()
    db.refresh(workout)

    return {
        "success": True,
        "invalid_day": False,
        "not_found": False,
        "no_changes": False,
        "saved_workout_id": workout.id,
        "workout_title": workout.title,
        "day_number": parsed_day_number,
        "day_name": selected_day.get("name") or f"Día {parsed_day_number}",
        "exercise_name": (
            exercise.get("exercise_name")
            or exercise.get("name")
            or exercise_name
        ),
        "before": before,
        "updates": applied_updates,
    }


def _apply_replace_exercise(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}

    saved_workout_id = payload.get("saved_workout_id")
    old_exercise_text = payload.get("old_exercise")
    new_exercise_payload = payload.get("new_exercise")
    day_number = payload.get("day_number")

    if saved_workout_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene saved_workout_id",
        )

    if not old_exercise_text:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene el ejercicio a sustituir",
        )

    if not isinstance(new_exercise_payload, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene un ejercicio nuevo válido",
        )

    new_exercise_id = new_exercise_payload.get("exercise_id")

    if new_exercise_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nuevo ejercicio no tiene ID real de la base de datos",
        )

    new_exercise = (
        db.query(Exercise)
        .filter(Exercise.id == int(new_exercise_id))
        .first()
    )

    if new_exercise is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"El ejercicio con ID {new_exercise_id} no existe",
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

    parsed_day_number = None

    if day_number is not None:
        try:
            parsed_day_number = int(day_number)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El número de día no es válido",
            )

        if parsed_day_number < 1 or parsed_day_number > len(days):
            return {
                "success": False,
                "not_found": True,
                "invalid_day": True,
                "already_exists": False,
                "same_exercise": False,
                "saved_workout_id": workout.id,
                "workout_title": workout.title,
                "day_number": parsed_day_number,
                "available_days": len(days),
                "old_exercise": old_exercise_text,
                "new_exercise": {
                    "exercise_id": new_exercise.id,
                    "exercise_name": new_exercise.name,
                },
            }

    found = _find_exercise_in_days(
        days=days,
        old_exercise_text=str(old_exercise_text),
        day_number=parsed_day_number,
    )

    if found is None:
        return {
            "success": False,
            "not_found": True,
            "invalid_day": False,
            "already_exists": False,
            "same_exercise": False,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": parsed_day_number,
            "old_exercise": old_exercise_text,
            "new_exercise": {
                "exercise_id": new_exercise.id,
                "exercise_name": new_exercise.name,
            },
        }

    day_index, exercise_index, old_exercise = found
    selected_day = days[day_index]
    exercises = selected_day.get("exercises")

    if not isinstance(exercises, list):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El día seleccionado no contiene ejercicios válidos",
        )

    old_exercise_name = (
        old_exercise.get("exercise_name")
        or old_exercise.get("name")
        or str(old_exercise_text)
    )

    if _is_same_exercise(
        old_exercise=old_exercise,
        new_exercise_id=new_exercise.id,
        new_exercise_name=new_exercise.name,
    ):
        return {
            "success": False,
            "same_exercise": True,
            "already_exists": False,
            "not_found": False,
            "invalid_day": False,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": day_index + 1,
            "day_name": selected_day.get("name") or f"Día {day_index + 1}",
            "old_exercise": old_exercise_name,
            "new_exercise": {
                "exercise_id": new_exercise.id,
                "exercise_name": new_exercise.name,
            },
        }

    if _exercise_exists_in_day(
        exercises=exercises,
        exercise_id=new_exercise.id,
        exercise_name=new_exercise.name,
        ignored_index=exercise_index,
    ):
        return {
            "success": False,
            "already_exists": True,
            "same_exercise": False,
            "not_found": False,
            "invalid_day": False,
            "saved_workout_id": workout.id,
            "workout_title": workout.title,
            "day_number": day_index + 1,
            "day_name": selected_day.get("name") or f"Día {day_index + 1}",
            "old_exercise": old_exercise_name,
            "new_exercise": {
                "exercise_id": new_exercise.id,
                "exercise_name": new_exercise.name,
            },
        }

    replacement_exercise = {
        "exercise_id": new_exercise.id,
        "exercise_name": new_exercise.name,
        "sets": old_exercise.get("sets") or 3,
        "reps": old_exercise.get("reps") or "10-12",
        "rest_seconds": old_exercise.get("rest_seconds") or 60,
        "notes": old_exercise.get("notes") or "",
    }

    exercises[exercise_index] = replacement_exercise
    selected_day["exercises"] = exercises
    days[day_index] = selected_day
    content["days"] = days

    workout.content_json = _save_content_json(content)

    db.commit()
    db.refresh(workout)

    return {
        "success": True,
        "not_found": False,
        "invalid_day": False,
        "already_exists": False,
        "same_exercise": False,
        "saved_workout_id": workout.id,
        "workout_title": workout.title,
        "day_number": day_index + 1,
        "day_name": selected_day.get("name") or f"Día {day_index + 1}",
        "old_exercise": old_exercise_name,
        "new_exercise": replacement_exercise,
    }


def _apply_schedule_workout(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}

    saved_workout_id = payload.get("saved_workout_id")
    workout_title = payload.get("workout_title")
    day_number = payload.get("day_number")
    day_name = payload.get("day_name")
    scheduled_date_raw = payload.get("scheduled_date")
    duration_minutes = payload.get("duration_minutes")

    if saved_workout_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene saved_workout_id",
        )

    if not workout_title:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene workout_title",
        )

    if scheduled_date_raw is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene scheduled_date",
        )

    try:
        scheduled_date = datetime.fromisoformat(str(scheduled_date_raw))
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La fecha programada no es válida",
        )

    workout = _get_user_workout(
        db=db,
        user=user,
        saved_workout_id=int(saved_workout_id),
    )

    parsed_day_number = None

    if day_number is not None:
        try:
            parsed_day_number = int(day_number)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El número de día no es válido",
            )

    parsed_duration = None

    if duration_minutes is not None:
        try:
            parsed_duration = int(duration_minutes)
        except Exception:
            parsed_duration = None

    existing = (
        db.query(ScheduledWorkout)
        .filter(
            ScheduledWorkout.user_id == user.id,
            ScheduledWorkout.saved_workout_id == workout.id,
            ScheduledWorkout.day_number == parsed_day_number,
            ScheduledWorkout.completed == False,
        )
        .all()
    )

    for item in existing:
        if (
            item.scheduled_date.year == scheduled_date.year
            and item.scheduled_date.month == scheduled_date.month
            and item.scheduled_date.day == scheduled_date.day
        ):
            return {
                "success": False,
                "already_exists": True,
                "scheduled_workout_id": item.id,
                "saved_workout_id": workout.id,
                "workout_title": item.workout_title,
                "day_number": item.day_number,
                "day_name": item.day_name,
                "scheduled_date": item.scheduled_date.isoformat(),
                "duration_minutes": item.duration_minutes,
            }

    scheduled_workout = ScheduledWorkout(
        user_id=user.id,
        saved_workout_id=workout.id,
        workout_title=workout_title,
        day_number=parsed_day_number,
        day_name=day_name,
        scheduled_date=scheduled_date,
        duration_minutes=parsed_duration,
        completed=False,
    )

    db.add(scheduled_workout)
    db.commit()
    db.refresh(scheduled_workout)

    return {
        "success": True,
        "already_exists": False,
        "scheduled_workout_id": scheduled_workout.id,
        "saved_workout_id": workout.id,
        "workout_title": scheduled_workout.workout_title,
        "day_number": scheduled_workout.day_number,
        "day_name": scheduled_workout.day_name,
        "scheduled_date": scheduled_workout.scheduled_date.isoformat(),
        "duration_minutes": scheduled_workout.duration_minutes,
    }

def _apply_create_workout_plan(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    payload = pending_action.get("payload") or {}
    workout_payload = payload.get("workout")
    activate = payload.get("activate") is True

    if not isinstance(workout_payload, dict):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La acción no contiene una rutina válida",
        )

    title = workout_payload.get("title") or "Rutina IA"
    summary = workout_payload.get("summary")
    goal = workout_payload.get("goal")
    level = workout_payload.get("level")
    days_per_week = workout_payload.get("days_per_week")
    duration_minutes = workout_payload.get("duration_minutes")
    days = workout_payload.get("days")

    if not isinstance(days, list) or not days:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La rutina propuesta no contiene días válidos",
        )

    for day in days:
        if not isinstance(day, dict):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La rutina contiene días con formato inválido",
            )

        exercises = day.get("exercises")

        if not isinstance(exercises, list) or not exercises:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La rutina contiene días sin ejercicios",
            )

        _validate_exercises_exist(
            db=db,
            exercises=exercises,
        )

    try:
        parsed_days_per_week = int(days_per_week)
    except Exception:
        parsed_days_per_week = len(days)

    parsed_duration = None

    if duration_minutes is not None:
        try:
            parsed_duration = int(duration_minutes)
        except Exception:
            parsed_duration = None

    clean_workout = {
        "title": title,
        "summary": summary,
        "goal": goal,
        "level": level,
        "days_per_week": parsed_days_per_week,
        "duration_minutes": parsed_duration,
        "source": workout_payload.get("source") or "AI_ACTION",
        "days": days,
    }

    if activate:
        (
            db.query(SavedWorkout)
            .filter(
                SavedWorkout.user_id == user.id,
                SavedWorkout.is_active == True,
            )
            .update(
                {
                    SavedWorkout.is_active: False,
                }
            )
        )

    saved_workout = SavedWorkout(
        user_id=user.id,
        title=title,
        summary=summary,
        goal=goal,
        level=level,
        days_per_week=parsed_days_per_week,
        duration_minutes=parsed_duration,
        content_json=_save_content_json(clean_workout),
        is_active=activate,
    )

    db.add(saved_workout)
    db.commit()
    db.refresh(saved_workout)

    return {
        "success": True,
        "saved_workout_id": saved_workout.id,
        "workout_title": saved_workout.title,
        "days_per_week": saved_workout.days_per_week,
        "duration_minutes": saved_workout.duration_minutes,
        "is_active": saved_workout.is_active,
    }

def apply_pending_action(
    db: Session,
    user: User,
    pending_action: Dict[str, Any],
) -> Dict[str, Any]:
    action_type = pending_action.get("type")

    if action_type == "create_workout_plan":
        data = _apply_create_workout_plan(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        if data.get("is_active") is True:
            message = "La rutina se ha guardado correctamente y se ha establecido como rutina activa."
        else:
            message = "La rutina se ha guardado correctamente en tus rutinas guardadas."

        return {
            "success": True,
            "message": message,
            "action_type": action_type,
            "data": data,
        }

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

    if action_type == "replace_exercise":
        data = _apply_replace_exercise(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        if data.get("invalid_day") is True:
            return {
                "success": False,
                "message": "El día indicado no existe en tu rutina activa.",
                "action_type": action_type,
                "data": data,
            }

        if data.get("same_exercise") is True:
            return {
                "success": False,
                "message": "El ejercicio nuevo es el mismo que el ejercicio actual. No se ha realizado ningún cambio.",
                "action_type": action_type,
                "data": data,
            }

        if data.get("already_exists") is True:
            day_number = data.get("day_number")

            return {
                "success": False,
                "message": (
                    f"El ejercicio nuevo ya existe en el día {day_number}. "
                    "No se ha realizado la sustitución para evitar duplicados."
                ),
                "action_type": action_type,
                "data": data,
            }

        if data.get("not_found") is True:
            day_number = data.get("day_number")

            if day_number is not None:
                message = (
                    f"No he encontrado el ejercicio que querías sustituir "
                    f"dentro del día {day_number}."
                )
            else:
                message = (
                    "No he encontrado el ejercicio que querías sustituir "
                    "dentro de tu rutina activa."
                )

            return {
                "success": False,
                "message": message,
                "action_type": action_type,
                "data": data,
            }

        return {
            "success": True,
            "message": "El ejercicio se ha sustituido correctamente en tu rutina activa.",
            "action_type": action_type,
            "data": data,
        }

    if action_type == "update_exercise_config":
        data = _apply_update_exercise_config(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        if data.get("invalid_day") is True:
            return {
                "success": False,
                "message": "El día indicado no existe en tu rutina activa.",
                "action_type": action_type,
                "data": data,
            }

        if data.get("not_found") is True:
            return {
                "success": False,
                "message": "No he encontrado el ejercicio indicado dentro del día seleccionado.",
                "action_type": action_type,
                "data": data,
            }

        if data.get("no_changes") is True:
            return {
                "success": False,
                "message": "El ejercicio ya tenía esos valores. No se ha realizado ningún cambio.",
                "action_type": action_type,
                "data": data,
            }

        return {
            "success": True,
            "message": "La configuración del ejercicio se ha actualizado correctamente.",
            "action_type": action_type,
            "data": data,
        }
    
    if action_type == "schedule_workout":
        data = _apply_schedule_workout(
            db=db,
            user=user,
            pending_action=pending_action,
        )

        if data.get("already_exists") is True:
            return {
                "success": False,
                "message": "Ese entrenamiento ya estaba programado para ese día. No se ha duplicado.",
                "action_type": action_type,
                "data": data,
            }

        return {
            "success": True,
            "message": "El entrenamiento se ha programado correctamente en tu agenda.",
            "action_type": action_type,
            "data": data,
        }
    

    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail=f"La acción '{action_type}' todavía no está soportada para aplicarse",
    )