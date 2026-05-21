from sqlalchemy.orm import Session

from app.database.models import Exercise


DEFAULT_EXERCISES = [
    {
        "name": "Flexiones",
        "category": "Fuerza",
        "muscle_group": "Pecho",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio básico para trabajar pecho, hombros y tríceps.",
        "instructions": "Coloca las manos a la altura del pecho, baja el cuerpo de forma controlada y empuja hasta extender los brazos.",
        "image": "assets/img/workout/Pushups.png",
    },
    {
        "name": "Sentadillas",
        "category": "Fuerza",
        "muscle_group": "Pierna",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio principal para trabajar piernas y glúteos.",
        "instructions": "Coloca los pies a la anchura de los hombros, baja manteniendo la espalda recta y sube empujando con las piernas.",
        "image": "assets/img/workout/Squats.png",
    },
    {
        "name": "Plancha",
        "category": "Core",
        "muscle_group": "Abdomen",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio isométrico para fortalecer el core.",
        "instructions": "Apoya antebrazos y puntas de los pies, mantén el cuerpo recto y contrae el abdomen.",
        "image": "assets/img/workout/Plank.png",
    },
    {
        "name": "Zancadas",
        "category": "Fuerza",
        "muscle_group": "Pierna",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio unilateral para piernas y glúteos.",
        "instructions": "Da un paso hacia delante, baja la rodilla trasera cerca del suelo y vuelve a la posición inicial.",
        "image": "assets/img/workout/Lunges.png",
    },
    {
        "name": "Burpees",
        "category": "Cardio",
        "muscle_group": "Cuerpo completo",
        "difficulty": "Intermedio",
        "equipment": "Peso corporal",
        "description": "Ejercicio intenso que combina fuerza y resistencia cardiovascular.",
        "instructions": "Baja al suelo, realiza una flexión, vuelve a posición de sentadilla y salta de forma explosiva.",
        "image": "assets/img/workout/Burpees.png",
    },
    {
        "name": "Mountain Climbers",
        "category": "Cardio",
        "muscle_group": "Core",
        "difficulty": "Intermedio",
        "equipment": "Peso corporal",
        "description": "Ejercicio dinámico para abdomen y resistencia.",
        "instructions": "En posición de plancha, lleva las rodillas hacia el pecho alternando rápidamente.",
        "image": "assets/img/workout/MountainClimbers.png",
    },
    {
        "name": "Jumping Jacks",
        "category": "Cardio",
        "muscle_group": "Cuerpo completo",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio cardiovascular sencillo para activar todo el cuerpo.",
        "instructions": "Salta abriendo piernas y brazos al mismo tiempo, vuelve al centro y repite.",
        "image": "assets/img/workout/JumpingJacks.png",
    },
    {
        "name": "Crunch abdominal",
        "category": "Core",
        "muscle_group": "Abdomen",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio básico para trabajar el abdomen.",
        "instructions": "Túmbate boca arriba, flexiona rodillas y eleva ligeramente el tronco contrayendo el abdomen.",
        "image": "assets/img/workout/Crunches.png",
    },
    {
        "name": "Elevación de piernas",
        "category": "Core",
        "muscle_group": "Abdomen",
        "difficulty": "Intermedio",
        "equipment": "Peso corporal",
        "description": "Ejercicio para trabajar la zona inferior del abdomen.",
        "instructions": "Túmbate boca arriba, eleva las piernas rectas y bájalas lentamente sin tocar el suelo.",
        "image": "assets/img/workout/LegRaises.png",
    },
    {
        "name": "Fondos de tríceps",
        "category": "Fuerza",
        "muscle_group": "Tríceps",
        "difficulty": "Principiante",
        "equipment": "Banco o silla",
        "description": "Ejercicio para trabajar tríceps usando un apoyo elevado.",
        "instructions": "Apoya las manos en una silla, baja flexionando los codos y vuelve a subir extendiendo los brazos.",
        "image": "assets/img/workout/TricepDips.png",
    },
    {
        "name": "Remo con mancuerna",
        "category": "Fuerza",
        "muscle_group": "Espalda",
        "difficulty": "Intermedio",
        "equipment": "Mancuerna",
        "description": "Ejercicio para fortalecer la espalda y mejorar la postura.",
        "instructions": "Inclina el torso, mantén la espalda recta y lleva la mancuerna hacia la cadera.",
        "image": "assets/img/workout/DumbbellRow.png",
    },
    {
        "name": "Press de hombro",
        "category": "Fuerza",
        "muscle_group": "Hombro",
        "difficulty": "Intermedio",
        "equipment": "Mancuernas",
        "description": "Ejercicio para trabajar hombros y tríceps.",
        "instructions": "Sujeta las mancuernas a la altura de los hombros y empuja hacia arriba hasta extender los brazos.",
        "image": "assets/img/workout/ShoulderPress.png",
    },
    {
        "name": "Curl de bíceps",
        "category": "Fuerza",
        "muscle_group": "Bíceps",
        "difficulty": "Principiante",
        "equipment": "Mancuernas",
        "description": "Ejercicio básico para trabajar los bíceps.",
        "instructions": "Sujeta las mancuernas, mantén los codos pegados al cuerpo y flexiona los brazos de forma controlada.",
        "image": "assets/img/workout/BicepCurl.png",
    },
    {
        "name": "Peso muerto con mancuernas",
        "category": "Fuerza",
        "muscle_group": "Pierna",
        "difficulty": "Intermedio",
        "equipment": "Mancuernas",
        "description": "Ejercicio para trabajar glúteos, isquiosurales y espalda baja.",
        "instructions": "Baja las mancuernas manteniendo la espalda recta y sube extendiendo la cadera.",
        "image": "assets/img/workout/DumbbellDeadlift.png",
    },
    {
        "name": "Puente de glúteos",
        "category": "Fuerza",
        "muscle_group": "Glúteos",
        "difficulty": "Principiante",
        "equipment": "Peso corporal",
        "description": "Ejercicio para activar y fortalecer los glúteos.",
        "instructions": "Túmbate boca arriba, flexiona rodillas y eleva la cadera apretando los glúteos.",
        "image": "assets/img/workout/GluteBridge.png",
    },
]


def seed_exercises(db: Session) -> dict:
    created = 0
    skipped = 0

    for exercise_data in DEFAULT_EXERCISES:
        existing_exercise = (
            db.query(Exercise)
            .filter(Exercise.name == exercise_data["name"])
            .first()
        )

        if existing_exercise:
            skipped += 1
            continue

        exercise = Exercise(**exercise_data)
        db.add(exercise)
        created += 1

    db.commit()

    return {
        "created": created,
        "skipped": skipped,
        "total_seed": len(DEFAULT_EXERCISES),
    }