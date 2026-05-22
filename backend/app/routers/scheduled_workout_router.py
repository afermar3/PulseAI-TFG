from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import (
    SavedWorkout,
    ScheduledWorkout,
    User,
    WorkoutSession,
)
from app.schemas.scheduled_workout_schema import (
    ScheduledWorkoutCreate,
    ScheduledWorkoutResponse,
)

router = APIRouter(
    prefix="/scheduled-workouts",
    tags=["Scheduled Workouts"],
)


def _scheduled_workout_to_response(
    scheduled_workout: ScheduledWorkout,
) -> ScheduledWorkoutResponse:
    return ScheduledWorkoutResponse(
        id=scheduled_workout.id,
        user_id=scheduled_workout.user_id,
        saved_workout_id=scheduled_workout.saved_workout_id,
        completed_session_id=scheduled_workout.completed_session_id,
        workout_title=scheduled_workout.workout_title,
        day_number=scheduled_workout.day_number,
        day_name=scheduled_workout.day_name,
        scheduled_date=scheduled_workout.scheduled_date,
        duration_minutes=scheduled_workout.duration_minutes,
        completed=bool(scheduled_workout.completed),
        created_at=scheduled_workout.created_at,
    )


@router.post("", response_model=ScheduledWorkoutResponse)
def create_scheduled_workout(
    data: ScheduledWorkoutCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if data.saved_workout_id is not None:
        saved_workout = (
            db.query(SavedWorkout)
            .filter(
                SavedWorkout.id == data.saved_workout_id,
                SavedWorkout.user_id == current_user.id,
            )
            .first()
        )

        if not saved_workout:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Rutina guardada no encontrada",
            )

    scheduled_workout = ScheduledWorkout(
        user_id=current_user.id,
        saved_workout_id=data.saved_workout_id,
        workout_title=data.workout_title,
        day_number=data.day_number,
        day_name=data.day_name,
        scheduled_date=data.scheduled_date,
        duration_minutes=data.duration_minutes,
        completed=False,
    )

    db.add(scheduled_workout)
    db.commit()
    db.refresh(scheduled_workout)

    return _scheduled_workout_to_response(scheduled_workout)


@router.get("/me", response_model=List[ScheduledWorkoutResponse])
def get_my_scheduled_workouts(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    scheduled_workouts = (
        db.query(ScheduledWorkout)
        .filter(ScheduledWorkout.user_id == current_user.id)
        .order_by(ScheduledWorkout.scheduled_date.asc())
        .all()
    )

    return [
        _scheduled_workout_to_response(scheduled_workout)
        for scheduled_workout in scheduled_workouts
    ]


@router.patch("/{scheduled_workout_id}/complete", response_model=ScheduledWorkoutResponse)
def complete_scheduled_workout(
    scheduled_workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    scheduled_workout = (
        db.query(ScheduledWorkout)
        .filter(
            ScheduledWorkout.id == scheduled_workout_id,
            ScheduledWorkout.user_id == current_user.id,
        )
        .first()
    )

    if not scheduled_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entrenamiento programado no encontrado",
        )

    if scheduled_workout.completed:
        return _scheduled_workout_to_response(scheduled_workout)

    session = WorkoutSession(
        user_id=current_user.id,
        saved_workout_id=scheduled_workout.saved_workout_id,
        workout_title=scheduled_workout.workout_title,
        day_number=scheduled_workout.day_number,
        day_name=scheduled_workout.day_name,
        total_exercises=0,
        completed_exercises=0,
        duration_minutes=scheduled_workout.duration_minutes,
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    scheduled_workout.completed = True
    scheduled_workout.completed_session_id = session.id

    db.commit()
    db.refresh(scheduled_workout)

    return _scheduled_workout_to_response(scheduled_workout)


@router.delete("/{scheduled_workout_id}")
def delete_scheduled_workout(
    scheduled_workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    scheduled_workout = (
        db.query(ScheduledWorkout)
        .filter(
            ScheduledWorkout.id == scheduled_workout_id,
            ScheduledWorkout.user_id == current_user.id,
        )
        .first()
    )

    if not scheduled_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entrenamiento programado no encontrado",
        )

    db.delete(scheduled_workout)
    db.commit()

    return {
        "message": "Entrenamiento programado eliminado correctamente",
    }