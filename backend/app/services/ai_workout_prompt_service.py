from app.database.models import Exercise, User, UserProfile


def _safe_value(value, fallback: str = "No especificado") -> str:
    if value is None:
        return fallback

    text = str(value).strip()

    if not text:
        return fallback

    return text


def _format_exercises_for_prompt(exercises: list[Exercise]) -> str:
    if not exercises:
        return "No hay ejercicios disponibles."

    lines = []

    for exercise in exercises:
        lines.append(
            f"- ID {exercise.id}: {exercise.name} | "
            f"Categoría: {exercise.category} | "
            f"Grupo muscular: {exercise.muscle_group} | "
            f"Dificultad: {exercise.difficulty} | "
            f"Equipo: {_safe_value(exercise.equipment)} | "
            f"Descripción: {_safe_value(exercise.description)}"
        )

    return "\n".join(lines)


def build_ai_workout_prompt(
    user: User,
    profile: UserProfile | None,
    exercises: list[Exercise],
    days_per_week: int,
    duration_minutes: int,
    focus: str | None,
    level: str | None,
) -> str:
    if profile is None:
        profile_text = """
Perfil del usuario:
- Perfil no completado todavía.
""".strip()
    else:
        profile_text = f"""
Perfil del usuario:
- Nombre: {_safe_value(profile.name)}
- Género: {_safe_value(profile.gender)}
- Edad: {_safe_value(profile.age)}
- Altura: {_safe_value(profile.height_cm)} cm
- Peso: {_safe_value(profile.weight_kg)} kg
- Objetivo principal: {_safe_value(profile.goal)}
""".strip()

    exercises_text = _format_exercises_for_prompt(exercises)

    selected_focus = focus or (profile.goal if profile else None) or "Mejora física general"
    selected_level = level or "Principiante/intermedio"

    return f"""
Eres PulseAI Coach, un entrenador personal inteligente integrado en una app móvil.

Tu tarea:
Crear una rutina de entrenamiento personalizada usando EXCLUSIVAMENTE los ejercicios disponibles en la lista.

Reglas obligatorias:
- Responde siempre en español.
- Devuelve SOLO JSON válido.
- No uses Markdown.
- No uses ```json.
- No escribas texto antes ni después del JSON.
- NO inventes ejercicios.
- Usa únicamente ejercicios cuyo ID aparezca en la lista.
- En cada ejercicio debes usar el ID real de la lista.
- No uses ejercicios externos ni siquiera en el calentamiento.
- Si necesitas calentamiento, usa recomendaciones generales de movilidad sin inventar ejercicios concretos externos.
- La rutina debe ser realista para el perfil del usuario.
- No prometas resultados garantizados.
- Si falta nivel, asume nivel principiante/intermedio.
- El número de días generados debe coincidir con days_per_week.
- Cada día debe tener entre 4 y 6 ejercicios.
- El descanso debe estar en segundos.
- sets debe ser un número entero.
- reps debe ser texto, por ejemplo "10-12", "12-15" o "30-45 segundos".
- Si days_per_week es 4, genera exactamente 4 días de entrenamiento real, no días de descanso.
- No incluyas días de descanso dentro del array "days".
- Los descansos o recuperación activa deben ir en "final_tips", no como un día de entrenamiento.
- Para objetivos de ganar músculo, prioriza ejercicios de fuerza sobre cardio.
- Cada día debe tener entre 4 y 6 ejercicios. No generes días con menos de 4 ejercicios.
- El campo summary debe tener máximo 2 frases cortas.
- El campo title debe tener máximo 45 caracteres

Datos solicitados:
- Días por semana: {days_per_week}
- Duración aproximada por sesión: {duration_minutes} minutos
- Enfoque: {selected_focus}
- Nivel: {selected_level}

{profile_text}

Ejercicios disponibles:
{exercises_text}

Formato JSON obligatorio:
{{
  "title": "Rutina de 4 días para ganar músculo",
  "summary": "Resumen breve personalizado de la rutina.",
  "days_per_week": {days_per_week},
  "duration_minutes": {duration_minutes},
  "level": "{selected_level}",
  "goal": "{selected_focus}",
  "days": [
    {{
      "day_number": 1,
      "name": "Tren superior A",
      "focus": "Pecho, espalda, hombro y brazos",
      "exercises": [
        {{
          "exercise_id": 1,
          "exercise_name": "Flexiones",
          "sets": 3,
          "reps": "10-12",
          "rest_seconds": 60,
          "notes": "Mantén el cuerpo alineado durante todo el movimiento."
        }}
      ]
    }}
  ],
  "warmup": [
    "Movilidad articular general durante 5 minutos.",
    "Activación suave del grupo muscular que se va a trabajar."
  ],
  "progression": [
    "Semana 1: prioriza técnica y control.",
    "Semana 2: aumenta ligeramente repeticiones si completas todas las series.",
    "Semana 3: aumenta carga o dificultad si mantienes buena técnica."
  ],
  "final_tips": [
    "Descansa correctamente entre sesiones.",
    "Mantén una buena hidratación.",
    "Acompaña la rutina con una alimentación suficiente en proteína."
  ]
}}

Genera ahora SOLO el JSON válido.
""".strip()