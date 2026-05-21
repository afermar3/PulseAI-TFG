import json
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SavedWorkout, User
from app.schemas.workout_plan_schema import (
    WorkoutPlanCreate,
    WorkoutPlanResponse,
)

router = APIRouter(
    prefix="/workout-plans",
    tags=["Workout Plans"],
)


def _saved_workout_to_response(saved_workout: SavedWorkout) -> WorkoutPlanResponse:
    return WorkoutPlanResponse(
        id=saved_workout.id,
        user_id=saved_workout.user_id,
        title=saved_workout.title,
        summary=saved_workout.summary,
        goal=saved_workout.goal,
        level=saved_workout.level,
        days_per_week=saved_workout.days_per_week,
        duration_minutes=saved_workout.duration_minutes,
        content=json.loads(saved_workout.content_json),
        created_at=saved_workout.created_at,
    )


@router.post("", response_model=WorkoutPlanResponse)
def save_workout_plan(
    data: WorkoutPlanCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = SavedWorkout(
        user_id=current_user.id,
        title=data.title,
        summary=data.summary,
        goal=data.goal,
        level=data.level,
        days_per_week=data.days_per_week,
        duration_minutes=data.duration_minutes,
        content_json=json.dumps(data.content, ensure_ascii=False),
    )

    db.add(saved_workout)
    db.commit()
    db.refresh(saved_workout)

    return _saved_workout_to_response(saved_workout)


@router.get("/me", response_model=List[WorkoutPlanResponse])
def get_my_workout_plans(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workouts = (
        db.query(SavedWorkout)
        .filter(SavedWorkout.user_id == current_user.id)
        .order_by(SavedWorkout.created_at.desc())
        .all()
    )

    return [
        _saved_workout_to_response(saved_workout)
        for saved_workout in saved_workouts
    ]


@router.get("/{workout_id}", response_model=WorkoutPlanResponse)
def get_workout_plan_by_id(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.id == workout_id,
            SavedWorkout.user_id == current_user.id,
        )
        .first()
    )

    if not saved_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rutina no encontrada",
        )

    return _saved_workout_to_response(saved_workout)


@router.delete("/{workout_id}")
def delete_workout_plan(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.id == workout_id,
            SavedWorkout.user_id == current_user.id,
        )
        .first()
    )

    if not saved_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rutina no encontrada",
        )

    db.delete(saved_workout)
    db.commit()

    return {
        "message": "Rutina eliminada correctamente",
    }