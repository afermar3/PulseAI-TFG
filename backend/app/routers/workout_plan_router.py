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
    WorkoutPlanUpdate,
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
        is_active=bool(saved_workout.is_active),
        created_at=saved_workout.created_at,
    )


def _get_user_saved_workout_or_404(
    workout_id: int,
    current_user: User,
    db: Session,
) -> SavedWorkout:
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

    return saved_workout


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
        is_active=False,
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


@router.get("/active", response_model=WorkoutPlanResponse)
def get_active_workout_plan(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    active_workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.user_id == current_user.id,
            SavedWorkout.is_active == True,
        )
        .first()
    )

    if not active_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No tienes ninguna rutina activa",
        )

    return _saved_workout_to_response(active_workout)


@router.get("/{workout_id}", response_model=WorkoutPlanResponse)
def get_workout_plan_by_id(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = _get_user_saved_workout_or_404(
        workout_id=workout_id,
        current_user=current_user,
        db=db,
    )

    return _saved_workout_to_response(saved_workout)


@router.patch("/{workout_id}", response_model=WorkoutPlanResponse)
def update_workout_plan(
    workout_id: int,
    data: WorkoutPlanUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = _get_user_saved_workout_or_404(
        workout_id=workout_id,
        current_user=current_user,
        db=db,
    )

    update_data = data.model_dump(exclude_unset=True)

    if "title" in update_data and update_data["title"] is not None:
        saved_workout.title = update_data["title"]

    if "summary" in update_data:
        saved_workout.summary = update_data["summary"]

    if "goal" in update_data:
        saved_workout.goal = update_data["goal"]

    if "level" in update_data:
        saved_workout.level = update_data["level"]

    if "days_per_week" in update_data:
        saved_workout.days_per_week = update_data["days_per_week"]

    if "duration_minutes" in update_data:
        saved_workout.duration_minutes = update_data["duration_minutes"]

    if "content" in update_data and update_data["content"] is not None:
        saved_workout.content_json = json.dumps(
            update_data["content"],
            ensure_ascii=False,
        )

    db.commit()
    db.refresh(saved_workout)

    return _saved_workout_to_response(saved_workout)


@router.patch("/{workout_id}/activate", response_model=WorkoutPlanResponse)
def activate_workout_plan(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    workout_to_activate = _get_user_saved_workout_or_404(
        workout_id=workout_id,
        current_user=current_user,
        db=db,
    )

    db.query(SavedWorkout).filter(
        SavedWorkout.user_id == current_user.id,
    ).update(
        {
            SavedWorkout.is_active: False,
        }
    )

    workout_to_activate.is_active = True

    db.commit()
    db.refresh(workout_to_activate)

    return _saved_workout_to_response(workout_to_activate)


@router.delete("/{workout_id}")
def delete_workout_plan(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    saved_workout = _get_user_saved_workout_or_404(
        workout_id=workout_id,
        current_user=current_user,
        db=db,
    )

    db.delete(saved_workout)
    db.commit()

    return {
        "message": "Rutina eliminada correctamente",
    }