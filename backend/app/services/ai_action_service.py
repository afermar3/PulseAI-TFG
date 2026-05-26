import json
import re
import unicodedata
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

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


def _get_active_workout(
    db: Session,
    user: User,
) -> Optional[SavedWorkout]:
    return (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.user_id == user.id,
            SavedWorkout.is_active == True,
        )
        .first()
    )


def _get_next_day_number(active_workout: SavedWorkout) -> int:
    content = _parse_content_json(active_workout.content_json)
    days = content.get("days")

    if isinstance(days, list):
        return len(days) + 1

    return 1


def _detect_duration_minutes(message: str) -> int:
    text = _normalize(message)

    short_keywords = [
        "corto",
        "corta",
        "poco tiempo",
        "rapido",
        "express",
        "30 min",
        "media hora",
    ]

    long_keywords = [
        "largo",
        "larga",
        "mucho tiempo",
        "completo",
        "completa",
        "intenso",
        "intensa",
        "una hora",
        "60 min",
    ]

    if any(keyword in text for keyword in short_keywords):
        return 30

    if any(keyword in text for keyword in long_keywords):
        return 60

    return 45


def _detect_muscle_focus(message: str) -> Dict[str, Any]:
    text = _normalize(message)

    muscle_map = [
        {
            "key": "pecho",
            "label": "Pecho",
            "keywords": [
                "pecho",
                "pectoral",
                "pectorales",
            ],
            "exercise_keywords": [
                "pecho",
                "pectoral",
                "pectorales",
                "flexion",
                "flexiones",
                "press banca",
                "press de banca",
                "press pecho",
                "press de pecho",
                "apertura",
                "aperturas",
            ],
        },
        {
            "key": "espalda",
            "label": "Espalda",
            "keywords": [
                "espalda",
                "dorsal",
                "dorsales",
            ],
            "exercise_keywords": [
                "espalda",
                "dorsal",
                "dorsales",
                "remo",
                "jalon",
                "dominada",
                "dominadas",
            ],
        },
        {
            "key": "pierna",
            "label": "Pierna",
            "keywords": [
                "pierna",
                "piernas",
                "cuadriceps",
                "gluteo",
                "gluteos",
                "femoral",
                "isquio",
                "isquios",
            ],
            "exercise_keywords": [
                "pierna",
                "piernas",
                "cuadriceps",
                "gluteo",
                "gluteos",
                "femoral",
                "isquio",
                "isquios",
                "sentadilla",
                "sentadillas",
                "zancada",
                "zancadas",
                "prensa",
                "gemelo",
                "gemelos",
            ],
        },
        {
            "key": "hombro",
            "label": "Hombro",
            "keywords": [
                "hombro",
                "hombros",
                "deltoides",
            ],
            "exercise_keywords": [
                "hombro",
                "hombros",
                "deltoides",
                "press militar",
                "elevaciones laterales",
                "elevacion lateral",
                "pajaros",
                "arnold",
            ],
        },
        {
            "key": "brazo",
            "label": "Brazos",
            "keywords": [
                "brazo",
                "brazos",
                "biceps",
                "triceps",
            ],
            "exercise_keywords": [
                "brazo",
                "brazos",
                "biceps",
                "triceps",
                "curl",
                "martillo",
                "extension",
            ],
        },
        {
            "key": "core",
            "label": "Core",
            "keywords": [
                "core",
                "abdomen",
                "abdominales",
                "abs",
            ],
            "exercise_keywords": [
                "core",
                "abdomen",
                "abdominal",
                "abdominales",
                "abs",
                "plancha",
                "crunch",
                "dead bug",
                "mountain climbers",
            ],
        },
    ]

    for muscle in muscle_map:
        if any(keyword in text for keyword in muscle["keywords"]):
            return muscle

    return {
        "key": "general",
        "label": "Entrenamiento general",
        "keywords": ["general"],
        "exercise_keywords": [
            "general",
            "sentadilla",
            "flexiones",
            "remo",
            "plancha",
            "zancadas",
        ],
    }


def _exercise_matches_keywords(
    exercise: Exercise,
    keywords: List[str],
) -> bool:
    searchable_text = _normalize(
        " ".join(
            [
                str(exercise.name or ""),
                str(exercise.category or ""),
                str(exercise.muscle_group or ""),
            ]
        )
    )

    return any(keyword in searchable_text for keyword in keywords)


def _find_matching_exercises(
    db: Session,
    muscle_focus: Dict[str, Any],
    limit: int = 5,
) -> List[Exercise]:
    keywords = muscle_focus.get("exercise_keywords") or []

    if not keywords:
        return []

    all_exercises = db.query(Exercise).order_by(Exercise.id.asc()).all()

    selected: List[Exercise] = []
    selected_ids = set()

    for exercise in all_exercises:
        if exercise.id in selected_ids:
            continue

        if _exercise_matches_keywords(exercise, keywords):
            selected.append(exercise)
            selected_ids.add(exercise.id)

        if len(selected) >= limit:
            break

    return selected[:limit]


def _build_exercises_payload(
    db: Session,
    muscle_focus: Dict[str, Any],
    duration_minutes: int,
) -> List[Dict[str, Any]]:
    target_count = 4 if duration_minutes <= 35 else 5

    matching_exercises = _find_matching_exercises(
        db=db,
        muscle_focus=muscle_focus,
        limit=target_count,
    )

    return [
        {
            "exercise_id": exercise.id,
            "exercise_name": exercise.name,
            "sets": 3,
            "reps": "10-12",
            "rest_seconds": 60 if duration_minutes <= 35 else 75,
            "notes": "",
        }
        for exercise in matching_exercises[:target_count]
    ]


def _extract_day_number(message: str) -> Optional[int]:
    text = _normalize(message)

    numeric_match = re.search(r"\bdia\s*(\d+)\b", text)

    if numeric_match:
        try:
            day_number = int(numeric_match.group(1))

            if 1 <= day_number <= 7:
                return day_number
        except Exception:
            pass

    day_patterns = [
        ("dia uno", 1),
        ("dia dos", 2),
        ("dia tres", 3),
        ("dia cuatro", 4),
        ("dia cinco", 5),
        ("dia seis", 6),
        ("dia siete", 7),
    ]

    for pattern, day_number in day_patterns:
        if pattern in text:
            return day_number

    return None


def _is_add_workout_day_request(message: str) -> bool:
    text = _normalize(message)

    if _extract_day_number(message) is not None:
        return False

    action_keywords = [
        "anade",
        "anademe",
        "agrega",
        "meteme",
        "ponme",
        "incluye",
        "crea",
    ]

    workout_keywords = [
        "entrenamiento",
        "entreno",
        "sesion",
        "rutina",
    ]

    day_creation_keywords = [
        "nuevo dia",
        "dia nuevo",
        "otro dia",
        "dia de",
    ]

    has_action = any(keyword in text for keyword in action_keywords)
    has_workout = any(keyword in text for keyword in workout_keywords)
    has_day_creation = any(keyword in text for keyword in day_creation_keywords)

    return has_action and (has_workout or has_day_creation)


def _build_add_workout_day_action(
    db: Session,
    user: User,
    message: str,
) -> Optional[Dict[str, Any]]:
    active_workout = _get_active_workout(db=db, user=user)

    if active_workout is None:
        return {
            "type": "create_workout_plan",
            "title": "Crear una rutina antes de añadir entrenamientos",
            "description": "No tienes una rutina activa. Antes de añadir un nuevo día, habría que crear o activar una rutina.",
            "requires_confirmation": True,
            "payload": {
                "reason": "NO_ACTIVE_WORKOUT",
                "original_message": message,
            },
        }

    duration_minutes = _detect_duration_minutes(message)
    muscle_focus = _detect_muscle_focus(message)
    next_day_number = _get_next_day_number(active_workout)

    exercises = _build_exercises_payload(
        db=db,
        muscle_focus=muscle_focus,
        duration_minutes=duration_minutes,
    )

    if not exercises:
        return {
            "type": "missing_exercises",
            "title": f"No hay ejercicios de {muscle_focus['label'].lower()}",
            "description": (
                f"No se han encontrado ejercicios de {muscle_focus['label'].lower()} "
                "en tu biblioteca de ejercicios. Añade ejercicios a la base de datos "
                "o prueba con otro grupo muscular."
            ),
            "requires_confirmation": False,
            "payload": {
                "muscle_group": muscle_focus["key"],
                "available_exercises": [],
                "original_message": message,
            },
        }

    duration_label = "corto" if duration_minutes <= 35 else "completo"
    day_name = f"{muscle_focus['label']} {duration_label}"
    focus = f"Entrenamiento de {muscle_focus['label'].lower()}"

    return {
        "type": "add_workout_day",
        "title": f"Añadir entrenamiento de {muscle_focus['label'].lower()}",
        "description": (
            f"Se añadirá un nuevo día a tu rutina activa "
            f"con {len(exercises)} ejercicio(s) reales de tu biblioteca "
            f"y duración estimada de {duration_minutes} minutos."
        ),
        "requires_confirmation": True,
        "payload": {
            "target": "active_workout",
            "saved_workout_id": active_workout.id,
            "workout_title": active_workout.title,
            "day": {
                "day_number": next_day_number,
                "name": day_name,
                "focus": focus,
                "duration_minutes": duration_minutes,
                "exercises": exercises,
            },
            "original_message": message,
        },
    }


def _is_add_exercise_to_day_request(message: str) -> bool:
    text = _normalize(message)

    action_keywords = [
        "anade",
        "anademe",
        "agrega",
        "meteme",
        "mete",
        "ponme",
        "pon",
        "incluye",
    ]

    has_action = any(keyword in text for keyword in action_keywords)
    has_day = _extract_day_number(message) is not None

    return has_action and has_day


def _clean_message_for_exercise_search(message: str) -> str:
    text = _normalize(message)

    removable_words = [
        "anade",
        "anademe",
        "agrega",
        "meteme",
        "mete",
        "ponme",
        "pon",
        "incluye",
        "ejercicio",
        "el ejercicio",
        "la rutina",
        "mi rutina",
        "al",
        "a",
        "en",
        "el",
        "la",
        "los",
        "las",
        "un",
        "una",
        "del",
        "de",
        "por favor",
    ]

    text = re.sub(r"\bdia\s*\d+\b", " ", text)

    for word in removable_words:
        text = re.sub(rf"\b{re.escape(word)}\b", " ", text)

    text = re.sub(r"\s+", " ", text).strip()

    return text


def _find_exercise_by_message(
    db: Session,
    message: str,
) -> Optional[Exercise]:
    clean_text = _clean_message_for_exercise_search(message)

    if not clean_text:
        return None

    exercises = db.query(Exercise).order_by(Exercise.id.asc()).all()

    best_match = None
    best_score = 0

    for exercise in exercises:
        exercise_name = _normalize(exercise.name or "")

        if not exercise_name:
            continue

        score = 0

        if exercise_name == clean_text:
            score = 200
        elif exercise_name in clean_text:
            score = 160
        elif clean_text in exercise_name:
            score = 120
        else:
            exercise_words = [
                word
                for word in exercise_name.split()
                if len(word) >= 4
            ]

            clean_words = [
                word
                for word in clean_text.split()
                if len(word) >= 4
            ]

            for word in exercise_words:
                if word in clean_words or word in clean_text:
                    score += 35

            for word in clean_words:
                if word in exercise_name:
                    score += 25

        if score > best_score:
            best_score = score
            best_match = exercise

    if best_score <= 0:
        return None

    return best_match


def _build_add_exercise_to_day_action(
    db: Session,
    user: User,
    message: str,
) -> Dict[str, Any]:
    active_workout = _get_active_workout(db=db, user=user)

    if active_workout is None:
        return {
            "type": "create_workout_plan",
            "title": "Crear una rutina antes de añadir ejercicios",
            "description": "No tienes una rutina activa. Antes de añadir ejercicios, habría que crear o activar una rutina.",
            "requires_confirmation": False,
            "payload": {
                "reason": "NO_ACTIVE_WORKOUT",
                "original_message": message,
            },
        }

    day_number = _extract_day_number(message)

    if day_number is None:
        return {
            "type": "missing_day",
            "title": "Falta indicar el día",
            "description": "He entendido que quieres añadir un ejercicio, pero necesito saber a qué día de tu rutina quieres añadirlo.",
            "requires_confirmation": False,
            "payload": {
                "saved_workout_id": active_workout.id,
                "workout_title": active_workout.title,
                "original_message": message,
            },
        }

    content = _parse_content_json(active_workout.content_json)
    days = content.get("days")

    if not isinstance(days, list) or day_number < 1 or day_number > len(days):
        return {
            "type": "invalid_day",
            "title": "Día no encontrado",
            "description": f"No he encontrado el día {day_number} en tu rutina activa.",
            "requires_confirmation": False,
            "payload": {
                "saved_workout_id": active_workout.id,
                "workout_title": active_workout.title,
                "day_number": day_number,
                "available_days": len(days) if isinstance(days, list) else 0,
                "original_message": message,
            },
        }

    exercise = _find_exercise_by_message(
        db=db,
        message=message,
    )

    if exercise is None:
        return {
            "type": "missing_exercise",
            "title": "Ejercicio no encontrado",
            "description": "No he encontrado ese ejercicio en tu biblioteca. Prueba escribiendo el nombre exacto del ejercicio.",
            "requires_confirmation": False,
            "payload": {
                "saved_workout_id": active_workout.id,
                "workout_title": active_workout.title,
                "day_number": day_number,
                "original_message": message,
            },
        }

    day = days[day_number - 1]
    day_name = day.get("name") or f"Día {day_number}"

    return {
        "type": "add_exercise_to_day",
        "title": f"Añadir {exercise.name} al día {day_number}",
        "description": (
            f"Se añadirá el ejercicio {exercise.name} al día {day_number} "
            f"de tu rutina activa."
        ),
        "requires_confirmation": True,
        "payload": {
            "target": "active_workout",
            "saved_workout_id": active_workout.id,
            "workout_title": active_workout.title,
            "day_number": day_number,
            "day_name": day_name,
            "exercise": {
                "exercise_id": exercise.id,
                "exercise_name": exercise.name,
                "sets": 3,
                "reps": "10-12",
                "rest_seconds": 60,
                "notes": "",
            },
            "original_message": message,
        },
    }


def _is_schedule_workout_request(message: str) -> bool:
    text = _normalize(message)

    schedule_keywords = [
        "programa",
        "agendar",
        "agenda",
        "planifica",
        "ponme",
    ]

    date_keywords = [
        "manana",
        "hoy",
        "lunes",
        "martes",
        "miercoles",
        "jueves",
        "viernes",
        "sabado",
        "domingo",
    ]

    workout_keywords = [
        "entrenamiento",
        "entreno",
        "sesion",
        "rutina",
    ]

    return (
        any(keyword in text for keyword in schedule_keywords)
        and any(keyword in text for keyword in workout_keywords)
        and any(keyword in text for keyword in date_keywords)
    )


def _build_schedule_workout_action(
    user: User,
    message: str,
) -> Dict[str, Any]:
    text = _normalize(message)

    scheduled_date_hint = None

    if "manana" in text:
        scheduled_date_hint = (
            datetime.utcnow() + timedelta(days=1)
        ).date().isoformat()
    elif "hoy" in text:
        scheduled_date_hint = datetime.utcnow().date().isoformat()

    muscle_focus = _detect_muscle_focus(message)
    duration_minutes = _detect_duration_minutes(message)

    return {
        "type": "schedule_workout",
        "title": "Programar entrenamiento",
        "description": "Se preparará un entrenamiento para añadirlo a tu agenda.",
        "requires_confirmation": True,
        "payload": {
            "workout_title": f"Entrenamiento de {muscle_focus['label'].lower()}",
            "day_name": muscle_focus["label"],
            "duration_minutes": duration_minutes,
            "scheduled_date_hint": scheduled_date_hint,
            "original_message": message,
        },
    }


def _is_replace_exercise_request(message: str) -> bool:
    text = _normalize(message)

    replace_keywords = [
        "cambia",
        "cambiame",
        "sustituye",
        "reemplaza",
    ]

    return any(keyword in text for keyword in replace_keywords) and " por " in text


def _build_replace_exercise_action(message: str) -> Dict[str, Any]:
    normalized_text = _normalize(message)

    old_exercise = None
    new_exercise = None

    if " por " in normalized_text:
        parts = normalized_text.split(" por ", 1)

        old_part = parts[0]
        new_part = parts[1]

        for keyword in ["cambia", "cambiame", "sustituye", "reemplaza"]:
            old_part = old_part.replace(keyword, "")

        old_part = old_part.replace("el ejercicio", "")
        old_part = old_part.replace("ejercicio", "")
        old_part = old_part.strip(" :,-.")
        new_part = new_part.strip(" :,-.")

        old_exercise = old_part if old_part else None
        new_exercise = new_part if new_part else None

    return {
        "type": "replace_exercise",
        "title": "Sustituir ejercicio",
        "description": "Se preparará una sustitución de ejercicio en tu rutina activa.",
        "requires_confirmation": True,
        "payload": {
            "target": "active_workout",
            "old_exercise": old_exercise,
            "new_exercise": new_exercise,
            "original_message": message,
        },
    }


def build_pending_action_answer(
    pending_action: Dict[str, Any],
) -> str:
    action_type = pending_action.get("type")
    title = pending_action.get("title", "Propuesta de cambio")
    description = pending_action.get("description", "")
    payload = pending_action.get("payload", {})

    if action_type == "add_workout_day":
        day = payload.get("day", {})
        exercises = day.get("exercises", [])

        day_name = day.get("name", "Nuevo entrenamiento")
        focus = day.get("focus", "Entrenamiento")
        duration_minutes = day.get("duration_minutes", "No especificada")
        workout_title = payload.get("workout_title", "tu rutina activa")

        lines = [
            "He preparado una propuesta para modificar tu rutina activa.",
            "",
            "Propuesta:",
            f"- Rutina: {workout_title}",
            f"- Nuevo día: {day_name}",
            f"- Enfoque: {focus}",
            f"- Duración estimada: {duration_minutes} minutos",
            f"- Ejercicios encontrados en tu biblioteca: {len(exercises)}",
            "",
            "Ejercicios que se añadirían:",
        ]

        for index, exercise in enumerate(exercises, start=1):
            exercise_name = exercise.get("exercise_name", "Ejercicio")
            sets = exercise.get("sets", 3)
            reps = exercise.get("reps", "10-12")
            rest_seconds = exercise.get("rest_seconds", 60)

            lines.append(
                f"- {index}. {exercise_name}: {sets} series x {reps} reps, descanso {rest_seconds} segundos."
            )

        lines.extend([
            "",
            "Importante:",
            "- Solo he usado ejercicios que existen en tu biblioteca.",
            "- No he aplicado todavía el cambio.",
            "",
            "¿Quieres que lo aplique a tu rutina activa?",
        ])

        return "\n".join(lines)

    if action_type == "add_exercise_to_day":
        exercise = payload.get("exercise", {})
        exercise_name = exercise.get("exercise_name", "Ejercicio")
        sets = exercise.get("sets", 3)
        reps = exercise.get("reps", "10-12")
        rest_seconds = exercise.get("rest_seconds", 60)
        day_number = payload.get("day_number", "No especificado")
        day_name = payload.get("day_name", f"Día {day_number}")
        workout_title = payload.get("workout_title", "tu rutina activa")

        return "\n".join([
            "He preparado una propuesta para añadir un ejercicio a tu rutina.",
            "",
            "Propuesta:",
            f"- Rutina: {workout_title}",
            f"- Día: {day_number} - {day_name}",
            f"- Ejercicio: {exercise_name}",
            f"- Series: {sets}",
            f"- Repeticiones: {reps}",
            f"- Descanso: {rest_seconds} segundos",
            "",
            "Importante:",
            "- El ejercicio existe en tu biblioteca.",
            "- No he aplicado todavía el cambio.",
            "",
            "¿Quieres que lo añada a ese día?",
        ])

    if action_type == "missing_exercises":
        return (
            f"{title}\n\n"
            f"{description}\n\n"
            "No puedo preparar una acción aplicable porque no hay ejercicios reales disponibles para ese grupo muscular.\n\n"
            "Puedes añadir ejercicios a tu biblioteca o pedirme otro tipo de entrenamiento."
        )

    if action_type == "missing_day":
        return (
            f"{title}\n\n"
            f"{description}\n\n"
            "Ejemplo: “Añádeme flexiones al día 1”."
        )

    if action_type == "invalid_day":
        available_days = payload.get("available_days", 0)

        return (
            f"{title}\n\n"
            f"{description}\n\n"
            f"Tu rutina activa tiene {available_days} día(s). "
            "Indica un día existente para poder preparar el cambio."
        )

    if action_type == "missing_exercise":
        return (
            f"{title}\n\n"
            f"{description}\n\n"
            "Revisa el nombre del ejercicio en tu biblioteca y vuelve a intentarlo."
        )

    if action_type == "replace_exercise":
        old_exercise = payload.get("old_exercise") or "ejercicio actual"
        new_exercise = payload.get("new_exercise") or "nuevo ejercicio"

        return (
            "He preparado una propuesta de sustitución de ejercicio.\n\n"
            "Propuesta:\n"
            f"- Sustituir: {old_exercise}\n"
            f"- Por: {new_exercise}\n\n"
            "No he aplicado todavía el cambio.\n\n"
            "¿Quieres que lo aplique a tu rutina activa?"
        )

    if action_type == "schedule_workout":
        workout_title = payload.get("workout_title", "Entrenamiento")
        duration_minutes = payload.get("duration_minutes", "No especificada")
        scheduled_date_hint = payload.get("scheduled_date_hint") or "fecha pendiente de confirmar"

        return (
            "He preparado una propuesta para programar un entrenamiento.\n\n"
            "Propuesta:\n"
            f"- Entrenamiento: {workout_title}\n"
            f"- Duración estimada: {duration_minutes} minutos\n"
            f"- Fecha: {scheduled_date_hint}\n\n"
            "No lo he añadido todavía a tu agenda.\n\n"
            "¿Quieres que lo programe?"
        )

    return (
        f"{title}\n\n"
        f"{description}\n\n"
        "No he aplicado todavía ningún cambio. ¿Quieres confirmar esta acción?"
    )


def detect_pending_action(
    db: Session,
    user: User,
    message: str,
) -> Optional[Dict[str, Any]]:
    if _is_replace_exercise_request(message):
        return _build_replace_exercise_action(message)

    if _is_add_exercise_to_day_request(message):
        return _build_add_exercise_to_day_action(
            db=db,
            user=user,
            message=message,
        )

    if _is_schedule_workout_request(message):
        return _build_schedule_workout_action(
            user=user,
            message=message,
        )

    if _is_add_workout_day_request(message):
        return _build_add_workout_day_action(
            db=db,
            user=user,
            message=message,
        )

    return None