import json
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session

from app.database.models import (
    SavedWorkout,
    ScheduledWorkout,
    User,
    WorkoutSession,
)


def _safe_value(value, fallback: str = "No especificado") -> str:
    if value is None:
        return fallback

    text = str(value).strip()

    if not text:
        return fallback

    return text


def _parse_content_json(raw_content: str) -> Dict[str, Any]:
    try:
        data = json.loads(raw_content)

        if isinstance(data, dict):
            return data

        return {}
    except Exception:
        return {}


def _parse_int(value, fallback: int = 0) -> int:
    if value is None:
        return fallback

    if isinstance(value, int):
        return value

    try:
        return int(value)
    except Exception:
        return fallback


def _get_current_week_range():
    today = datetime.utcnow().date()

    week_start_date = today - timedelta(days=today.weekday())
    week_end_date = week_start_date + timedelta(days=6)

    week_start = datetime.combine(week_start_date, datetime.min.time())
    week_end = datetime.combine(week_end_date, datetime.max.time())

    return week_start, week_end


def _build_summary_from_sessions(sessions: List[WorkoutSession]) -> Dict[str, int]:
    total_sessions = len(sessions)

    total_minutes = sum(
        session.duration_minutes or 0
        for session in sessions
    )

    total_completed_exercises = sum(
        session.completed_exercises or 0
        for session in sessions
    )

    estimated_kcal = total_minutes * 6

    return {
        "total_sessions": total_sessions,
        "total_minutes": total_minutes,
        "total_completed_exercises": total_completed_exercises,
        "estimated_kcal": estimated_kcal,
    }


def _build_streak_from_sessions(sessions: List[WorkoutSession]) -> Dict[str, Any]:
    if not sessions:
        return {
            "current_streak": 0,
            "last_training_date": None,
            "trained_today": False,
            "trained_yesterday": False,
        }

    training_dates = sorted(
        {
            session.completed_at.date()
            for session in sessions
            if session.completed_at is not None
        },
        reverse=True,
    )

    if not training_dates:
        return {
            "current_streak": 0,
            "last_training_date": None,
            "trained_today": False,
            "trained_yesterday": False,
        }

    today = datetime.utcnow().date()
    yesterday = today - timedelta(days=1)

    trained_today = today in training_dates
    trained_yesterday = yesterday in training_dates
    last_training_date = training_dates[0]

    if not trained_today and not trained_yesterday:
        return {
            "current_streak": 0,
            "last_training_date": last_training_date.isoformat(),
            "trained_today": False,
            "trained_yesterday": False,
        }

    expected_date = today if trained_today else yesterday
    training_dates_set = set(training_dates)

    current_streak = 0

    while expected_date in training_dates_set:
        current_streak += 1
        expected_date = expected_date - timedelta(days=1)

    return {
        "current_streak": current_streak,
        "last_training_date": last_training_date.isoformat(),
        "trained_today": trained_today,
        "trained_yesterday": trained_yesterday,
    }


def _format_active_workout(active_workout: Optional[SavedWorkout]) -> str:
    if active_workout is None:
        return """
Rutina activa:
- No hay rutina activa actualmente.
""".strip()

    content = _parse_content_json(active_workout.content_json)
    days = content.get("days")

    lines = [
        "Rutina activa:",
        f"- ID: {active_workout.id}",
        f"- Título: {_safe_value(active_workout.title)}",
        f"- Objetivo: {_safe_value(active_workout.goal)}",
        f"- Nivel: {_safe_value(active_workout.level)}",
        f"- Días por semana: {_safe_value(active_workout.days_per_week)}",
        f"- Duración estimada: {_safe_value(active_workout.duration_minutes)} min",
    ]

    if isinstance(days, list) and days:
        lines.append("- Días de entrenamiento:")

        for index, raw_day in enumerate(days[:6]):
            if not isinstance(raw_day, dict):
                continue

            day_number = raw_day.get("day_number") or index + 1
            day_name = raw_day.get("name") or f"Día {day_number}"
            focus = raw_day.get("focus") or "Sin enfoque especificado"
            exercises = raw_day.get("exercises")

            lines.append(f"  - Día {day_number}: {day_name} ({focus})")

            if isinstance(exercises, list) and exercises:
                exercise_names = []

                for raw_exercise in exercises[:6]:
                    if not isinstance(raw_exercise, dict):
                        continue

                    exercise_name = (
                        raw_exercise.get("exercise_name")
                        or raw_exercise.get("name")
                        or "Ejercicio"
                    )

                    sets = raw_exercise.get("sets")
                    reps = raw_exercise.get("reps")

                    if sets and reps:
                        exercise_names.append(f"{exercise_name} ({sets}x{reps})")
                    else:
                        exercise_names.append(str(exercise_name))

                if exercise_names:
                    lines.append(f"    Ejercicios: {', '.join(exercise_names)}")

    return "\n".join(lines)


def _format_recent_sessions(sessions: List[WorkoutSession]) -> str:
    if not sessions:
        return """
Últimas sesiones:
- No hay sesiones completadas registradas.
""".strip()

    lines = [
        "Últimas sesiones completadas:",
    ]

    for session in sessions[:5]:
        completed_at = (
            session.completed_at.strftime("%Y-%m-%d %H:%M")
            if session.completed_at
            else "Sin fecha"
        )

        lines.append(
            f"- {completed_at}: {session.workout_title} / "
            f"{_safe_value(session.day_name, 'Sesión')} / "
            f"{session.completed_exercises}/{session.total_exercises} ejercicios / "
            f"{_safe_value(session.duration_minutes, '0')} min"
        )

    return "\n".join(lines)


def _format_upcoming_scheduled_workouts(
    scheduled_workouts: List[ScheduledWorkout],
) -> str:
    if not scheduled_workouts:
        return """
Próximos entrenamientos programados:
- No hay próximos entrenamientos programados.
""".strip()

    lines = [
        "Próximos entrenamientos programados:",
    ]

    for workout in scheduled_workouts[:5]:
        scheduled_date = (
            workout.scheduled_date.strftime("%Y-%m-%d %H:%M")
            if workout.scheduled_date
            else "Sin fecha"
        )

        lines.append(
            f"- {scheduled_date}: {workout.workout_title} / "
            f"{_safe_value(workout.day_name, 'Entrenamiento')} / "
            f"{_safe_value(workout.duration_minutes, '0')} min"
        )

    return "\n".join(lines)


def build_ai_user_context(
    db: Session,
    user: User,
) -> str:
    now = datetime.utcnow()
    week_start, week_end = _get_current_week_range()

    active_workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.user_id == user.id,
            SavedWorkout.is_active == True,
        )
        .first()
    )

    all_sessions = (
        db.query(WorkoutSession)
        .filter(WorkoutSession.user_id == user.id)
        .order_by(WorkoutSession.completed_at.desc())
        .all()
    )

    recent_sessions = all_sessions[:5]

    weekly_sessions = [
        session
        for session in all_sessions
        if session.completed_at is not None
        and week_start <= session.completed_at <= week_end
    ]

    total_summary = _build_summary_from_sessions(all_sessions)
    weekly_summary = _build_summary_from_sessions(weekly_sessions)
    streak = _build_streak_from_sessions(all_sessions)

    upcoming_scheduled_workouts = (
        db.query(ScheduledWorkout)
        .filter(
            ScheduledWorkout.user_id == user.id,
            ScheduledWorkout.completed == False,
            ScheduledWorkout.scheduled_date >= now,
        )
        .order_by(ScheduledWorkout.scheduled_date.asc())
        .limit(5)
        .all()
    )

    active_workout_text = _format_active_workout(active_workout)
    recent_sessions_text = _format_recent_sessions(recent_sessions)
    scheduled_text = _format_upcoming_scheduled_workouts(upcoming_scheduled_workouts)

    return f"""
Contexto real de PulseAI:
Este contexto procede de la base de datos de la app. Úsalo para personalizar tus respuestas.

{active_workout_text}

Resumen de esta semana:
- Sesiones completadas: {weekly_summary["total_sessions"]}
- Minutos entrenados: {weekly_summary["total_minutes"]}
- Ejercicios completados: {weekly_summary["total_completed_exercises"]}
- Kcal estimadas: {weekly_summary["estimated_kcal"]}

Resumen histórico:
- Sesiones totales: {total_summary["total_sessions"]}
- Minutos totales: {total_summary["total_minutes"]}
- Ejercicios completados totales: {total_summary["total_completed_exercises"]}
- Kcal estimadas totales: {total_summary["estimated_kcal"]}

Racha:
- Racha actual: {streak["current_streak"]} días
- Ha entrenado hoy: {streak["trained_today"]}
- Ha entrenado ayer: {streak["trained_yesterday"]}
- Último entrenamiento: {_safe_value(streak["last_training_date"])}

{recent_sessions_text}

{scheduled_text}

Reglas sobre el contexto:
- Si el usuario pregunta por su progreso, usa estos datos reales.
- Si el usuario pregunta qué entrenar hoy, ten en cuenta la rutina activa, la semana actual y las últimas sesiones.
- Si el usuario pide modificar rutinas, ejercicios o agenda, de momento NO digas que ya lo has cambiado.
- Para cambios en la app, propone el cambio de forma clara y pide confirmación.
- No inventes sesiones, rutinas activas ni entrenamientos programados si no aparecen en este contexto.
""".strip()