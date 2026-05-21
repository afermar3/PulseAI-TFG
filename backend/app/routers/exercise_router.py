from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.database.models import Exercise
from app.schemas.exercise_schema import ExerciseCreate, ExerciseResponse
from app.services.exercise_seed_service import seed_exercises

router = APIRouter(
    prefix="/exercises",
    tags=["Exercises"],
)


@router.get("", response_model=List[ExerciseResponse])
def get_exercises(
    muscle_group: Optional[str] = None,
    difficulty: Optional[str] = None,
    category: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Exercise)

    if muscle_group:
        query = query.filter(Exercise.muscle_group.ilike(f"%{muscle_group}%"))

    if difficulty:
        query = query.filter(Exercise.difficulty.ilike(f"%{difficulty}%"))

    if category:
        query = query.filter(Exercise.category.ilike(f"%{category}%"))

    return query.order_by(Exercise.id.asc()).all()


@router.get("/{exercise_id}", response_model=ExerciseResponse)
def get_exercise_by_id(
    exercise_id: int,
    db: Session = Depends(get_db),
):
    exercise = db.query(Exercise).filter(Exercise.id == exercise_id).first()

    if not exercise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ejercicio no encontrado",
        )

    return exercise


@router.post("", response_model=ExerciseResponse)
def create_exercise(
    data: ExerciseCreate,
    db: Session = Depends(get_db),
):
    existing_exercise = db.query(Exercise).filter(Exercise.name == data.name).first()

    if existing_exercise:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un ejercicio con ese nombre",
        )

    exercise = Exercise(**data.model_dump())

    db.add(exercise)
    db.commit()
    db.refresh(exercise)

    return exercise


@router.post("/seed")
def seed_default_exercises(
    db: Session = Depends(get_db),
):
    return seed_exercises(db)