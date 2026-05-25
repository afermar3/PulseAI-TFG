from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import (
    SavedWorkout,
    ScheduledWorkout,
    User,
    WorkoutExerciseProgress,
)
from app.schemas.workout_progress_schema import (
    WorkoutDayProgressResponse,
    WorkoutExerciseProgressResponse,
    WorkoutExerciseProgressToggle,
)

router = APIRouter(
    prefix="/workout-progress",
    tags=["Workout Progress"],
)


def _progress_to_response(
    progress: WorkoutExerciseProgress,
) -> WorkoutExerciseProgressResponse:
    return WorkoutExerciseProgressResponse(
        id=progress.id,
        user_id=progress.user_id,
        saved_workout_id=progress.saved_workout_id,
        scheduled_workout_id=progress.scheduled_workout_id,
        day_number=progress.day_number,
        exercise_index=progress.exercise_index,
        exercise_id=progress.exercise_id,
        exercise_name=progress.exercise_name,
        completed=progress.completed,
        completed_at=progress.completed_at,
        created_at=progress.created_at,
        updated_at=progress.updated_at,
    )


def _validate_saved_workout(
    db: Session,
    saved_workout_id: Optional[int],
    current_user: User,
):
    if saved_workout_id is None:
        return

    saved_workout = (
        db.query(SavedWorkout)
        .filter(
            SavedWorkout.id == saved_workout_id,
            SavedWorkout.user_id == current_user.id,
        )
        .first()
    )

    if not saved_workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rutina guardada no encontrada",
        )


def _validate_scheduled_workout(
    db: Session,
    scheduled_workout_id: Optional[int],
    current_user: User,
):
    if scheduled_workout_id is None:
        return

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


@router.get("/day", response_model=WorkoutDayProgressResponse)
def get_day_progress(
    saved_workout_id: Optional[int] = Query(default=None),
    scheduled_workout_id: Optional[int] = Query(default=None),
    day_number: Optional[int] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(WorkoutExerciseProgress).filter(
        WorkoutExerciseProgress.user_id == current_user.id,
    )

    if scheduled_workout_id is not None:
        query = query.filter(
            WorkoutExerciseProgress.scheduled_workout_id == scheduled_workout_id,
        )
    else:
        query = query.filter(
            WorkoutExerciseProgress.saved_workout_id == saved_workout_id,
            WorkoutExerciseProgress.day_number == day_number,
            WorkoutExerciseProgress.scheduled_workout_id.is_(None),
        )

    progress_items = query.order_by(
        WorkoutExerciseProgress.exercise_index.asc(),
    ).all()

    completed_indexes = [
        item.exercise_index
        for item in progress_items
        if item.completed
    ]

    return WorkoutDayProgressResponse(
        saved_workout_id=saved_workout_id,
        scheduled_workout_id=scheduled_workout_id,
        day_number=day_number,
        total_completed=len(completed_indexes),
        completed_exercise_indexes=completed_indexes,
        exercises=[_progress_to_response(item) for item in progress_items],
    )


@router.post("/toggle", response_model=WorkoutExerciseProgressResponse)
def toggle_exercise_progress(
    data: WorkoutExerciseProgressToggle,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    _validate_saved_workout(db, data.saved_workout_id, current_user)
    _validate_scheduled_workout(db, data.scheduled_workout_id, current_user)

    query = db.query(WorkoutExerciseProgress).filter(
        WorkoutExerciseProgress.user_id == current_user.id,
        WorkoutExerciseProgress.exercise_index == data.exercise_index,
    )

    if data.scheduled_workout_id is not None:
        query = query.filter(
            WorkoutExerciseProgress.scheduled_workout_id == data.scheduled_workout_id,
        )
    else:
        query = query.filter(
            WorkoutExerciseProgress.saved_workout_id == data.saved_workout_id,
            WorkoutExerciseProgress.day_number == data.day_number,
            WorkoutExerciseProgress.scheduled_workout_id.is_(None),
        )

    progress = query.first()

    completed_at = datetime.utcnow() if data.completed else None

    if progress is None:
        progress = WorkoutExerciseProgress(
            user_id=current_user.id,
            saved_workout_id=data.saved_workout_id,
            scheduled_workout_id=data.scheduled_workout_id,
            day_number=data.day_number,
            exercise_index=data.exercise_index,
            exercise_id=data.exercise_id,
            exercise_name=data.exercise_name,
            completed=data.completed,
            completed_at=completed_at,
        )

        db.add(progress)
    else:
        progress.exercise_id = data.exercise_id
        progress.exercise_name = data.exercise_name
        progress.completed = data.completed
        progress.completed_at = completed_at
        progress.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(progress)

    return _progress_to_response(progress)


@router.delete("/day")
def clear_day_progress(
    saved_workout_id: Optional[int] = Query(default=None),
    scheduled_workout_id: Optional[int] = Query(default=None),
    day_number: Optional[int] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(WorkoutExerciseProgress).filter(
        WorkoutExerciseProgress.user_id == current_user.id,
    )

    if scheduled_workout_id is not None:
        query = query.filter(
            WorkoutExerciseProgress.scheduled_workout_id == scheduled_workout_id,
        )
    else:
        query = query.filter(
            WorkoutExerciseProgress.saved_workout_id == saved_workout_id,
            WorkoutExerciseProgress.day_number == day_number,
            WorkoutExerciseProgress.scheduled_workout_id.is_(None),
        )

    deleted_count = query.delete(synchronize_session=False)

    db.commit()

    return {
        "message": "Progreso eliminado correctamente",
        "deleted_count": deleted_count,
    }