from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SavedWorkout, User, WorkoutSession
from app.schemas.workout_session_schema import (
    WorkoutSessionCreate,
    WorkoutSessionResponse,
)

router = APIRouter(
    prefix="/workout-sessions",
    tags=["Workout Sessions"],
)


def _session_to_response(session: WorkoutSession) -> WorkoutSessionResponse:
    return WorkoutSessionResponse(
        id=session.id,
        user_id=session.user_id,
        saved_workout_id=session.saved_workout_id,
        workout_title=session.workout_title,
        day_number=session.day_number,
        day_name=session.day_name,
        total_exercises=session.total_exercises,
        completed_exercises=session.completed_exercises,
        duration_minutes=session.duration_minutes,
        completed_at=session.completed_at,
    )


@router.post("", response_model=WorkoutSessionResponse)
def create_workout_session(
    data: WorkoutSessionCreate,
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

    session = WorkoutSession(
        user_id=current_user.id,
        saved_workout_id=data.saved_workout_id,
        workout_title=data.workout_title,
        day_number=data.day_number,
        day_name=data.day_name,
        total_exercises=data.total_exercises,
        completed_exercises=data.completed_exercises,
        duration_minutes=data.duration_minutes,
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return _session_to_response(session)


@router.get("/me", response_model=List[WorkoutSessionResponse])
def get_my_workout_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sessions = (
        db.query(WorkoutSession)
        .filter(WorkoutSession.user_id == current_user.id)
        .order_by(WorkoutSession.completed_at.desc())
        .all()
    )

    return [_session_to_response(session) for session in sessions]

@router.get("/summary")
def get_workout_sessions_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sessions = (
        db.query(WorkoutSession)
        .filter(WorkoutSession.user_id == current_user.id)
        .all()
    )

    total_sessions = len(sessions)

    total_minutes = sum(
        session.duration_minutes or 0
        for session in sessions
    )

    total_completed_exercises = sum(
        session.completed_exercises or 0
        for session in sessions
    )

    # Estimación sencilla: 6 kcal por minuto.
    estimated_kcal = total_minutes * 6

    return {
        "total_sessions": total_sessions,
        "total_minutes": total_minutes,
        "total_completed_exercises": total_completed_exercises,
        "estimated_kcal": estimated_kcal,
    }