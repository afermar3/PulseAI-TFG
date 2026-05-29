import json
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session

from app.database.models import (
    SavedWorkout,
    ScheduledWorkout,
    SleepGoalProfile,
    SleepSession,
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


def _format_minutes(minutes: Optional[int]) -> str:
    if minutes is None or minutes <= 0:
        return "No especificado"

    hours = minutes // 60
    remaining_minutes = minutes % 60

    if hours <= 0:
        return f"{remaining_minutes}min"

    if remaining_minutes == 0:
        return f"{hours}h"

    return f"{hours}h {remaining_minutes}min"


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


def _sleep_goal_type_label(goal_type: str) -> str:
    if goal_type == "ALL_DAYS":
        return "Todos los días"

    if goal_type == "WEEKDAYS":
        return "Entre semana"

    if goal_type == "WEEKENDS":
        return "Fin de semana"

    return goal_type


def _get_effective_sleep_goal(
    sleep_goals: List[SleepGoalProfile],
) -> tuple[str, Optional[SleepGoalProfile]]:
    today = datetime.utcnow().date()
    weekday = today.weekday()

    preferred_type = "WEEKENDS" if weekday >= 5 else "WEEKDAYS"

    preferred_goal = next(
        (
            goal
            for goal in sleep_goals
            if goal.goal_type == preferred_type and goal.enabled is True
        ),
        None,
    )

    if preferred_goal is not None:
        return preferred_type, preferred_goal

    all_days_goal = next(
        (
            goal
            for goal in sleep_goals
            if goal.goal_type == "ALL_DAYS" and goal.enabled is True
        ),
        None,
    )

    if all_days_goal is not None:
        return "ALL_DAYS", all_days_goal

    return "RECOMMENDED", None


def _format_sleep_goal(goal: SleepGoalProfile) -> str:
    status = "activo" if goal.enabled else "desactivado"

    return (
        f"- {_sleep_goal_type_label(goal.goal_type)}: "
        f"{goal.bed_time} - {goal.wake_time} / "
        f"{_format_minutes(goal.target_minutes)} / {status}"
    )


def _format_sleep_session(session: SleepSession) -> str:
    start_time = (
        session.start_time.strftime("%Y-%m-%d %H:%M")
        if session.start_time
        else "Sin inicio"
    )

    end_time = (
        session.end_time.strftime("%Y-%m-%d %H:%M")
        if session.end_time
        else "Sin fin"
    )

    duration = _format_minutes(session.duration_minutes)
    quality = _safe_value(session.quality, "No indicada")

    return (
        f"- {start_time} → {end_time} / "
        f"Duración: {duration} / Calidad: {quality}"
    )


def _format_sleep_context(
    active_sleep_session: Optional[SleepSession],
    latest_sleep_session: Optional[SleepSession],
    recent_sleep_sessions: List[SleepSession],
    sleep_goals: List[SleepGoalProfile],
) -> str:
    source, effective_goal = _get_effective_sleep_goal(sleep_goals)

    lines = [
        "Sueño y descanso:",
    ]

    if active_sleep_session is None:
        lines.append("- Sueño activo: No hay una sesión de sueño activa.")
    else:
        start_time = (
            active_sleep_session.start_time.strftime("%Y-%m-%d %H:%M")
            if active_sleep_session.start_time
            else "Sin inicio"
        )

        lines.append(f"- Sueño activo: Sí, iniciado en {start_time}.")

    if latest_sleep_session is None:
        lines.append("- Último sueño registrado: No hay registros completados.")
    else:
        lines.append("- Último sueño registrado:")
        lines.append(f"  {_format_sleep_session(latest_sleep_session)}")

    if effective_goal is None:
        lines.append("- Objetivo efectivo de hoy: Recomendado / 8h.")
    else:
        lines.append(
            "- Objetivo efectivo de hoy: "
            f"{_sleep_goal_type_label(source)} / "
            f"{effective_goal.bed_time} - {effective_goal.wake_time} / "
            f"{_format_minutes(effective_goal.target_minutes)}."
        )

    if not sleep_goals:
        lines.append("- Objetivos configurados: No hay objetivos personalizados.")
    else:
        lines.append("- Objetivos configurados:")

        ordered_types = ["WEEKDAYS", "WEEKENDS", "ALL_DAYS"]

        for goal_type in ordered_types:
            goal = next(
                (
                    item
                    for item in sleep_goals
                    if item.goal_type == goal_type
                ),
                None,
            )

            if goal is not None:
                lines.append(f"  {_format_sleep_goal(goal)}")

    completed_recent = [
        session
        for session in recent_sleep_sessions
        if session.is_active is False
    ]

    if not completed_recent:
        lines.append("- Historial reciente de sueño: No hay registros recientes.")
    else:
        lines.append("- Historial reciente de sueño:")

        for session in completed_recent[:5]:
            lines.append(f"  {_format_sleep_session(session)}")

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

    active_sleep_session = (
        db.query(SleepSession)
        .filter(
            SleepSession.user_id == user.id,
            SleepSession.is_active == True,
        )
        .order_by(SleepSession.start_time.desc())
        .first()
    )

    latest_sleep_session = (
        db.query(SleepSession)
        .filter(
            SleepSession.user_id == user.id,
            SleepSession.is_active == False,
        )
        .order_by(SleepSession.end_time.desc())
        .first()
    )

    recent_sleep_sessions = (
        db.query(SleepSession)
        .filter(SleepSession.user_id == user.id)
        .order_by(SleepSession.start_time.desc())
        .limit(5)
        .all()
    )

    sleep_goals = (
        db.query(SleepGoalProfile)
        .filter(SleepGoalProfile.user_id == user.id)
        .order_by(SleepGoalProfile.goal_type.asc())
        .all()
    )

    active_workout_text = _format_active_workout(active_workout)
    recent_sessions_text = _format_recent_sessions(recent_sessions)
    scheduled_text = _format_upcoming_scheduled_workouts(upcoming_scheduled_workouts)
    sleep_context_text = _format_sleep_context(
        active_sleep_session=active_sleep_session,
        latest_sleep_session=latest_sleep_session,
        recent_sleep_sessions=recent_sleep_sessions,
        sleep_goals=sleep_goals,
    )

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

{sleep_context_text}

Reglas sobre el contexto:
- Si el usuario pregunta por su progreso, usa estos datos reales.
- Si el usuario pregunta qué entrenar hoy, ten en cuenta la rutina activa, la semana actual y las últimas sesiones.
- Si el usuario pregunta por sueño, descanso, horas dormidas u objetivos de sueño, usa los datos reales del bloque "Sueño y descanso".
- Si el usuario pide modificar rutinas, ejercicios, agenda u objetivos de sueño, de momento NO digas que ya lo has cambiado.
- Para cambios en la app, propone el cambio de forma clara y pide confirmación.
- No inventes sesiones, rutinas activas, entrenamientos programados, registros de sueño ni objetivos de sueño si no aparecen en este contexto.
""".strip()