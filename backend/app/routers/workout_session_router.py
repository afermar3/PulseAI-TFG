from datetime import datetime, time, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SavedWorkout, User, WorkoutSession
from app.schemas.workout_session_schema import (
    WorkoutSessionCreate,
    WorkoutSessionResponse,
    WorkoutSessionTodayStatusResponse,
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


def _get_today_range():
    today = datetime.utcnow().date()
    today_start = datetime.combine(today, time.min)
    today_end = datetime.combine(today, time.max)

    return today_start, today_end


def _get_current_week_range():
    today = datetime.utcnow().date()

    week_start_date = today - timedelta(days=today.weekday())
    week_end_date = week_start_date + timedelta(days=6)

    week_start = datetime.combine(week_start_date, time.min)
    week_end = datetime.combine(week_end_date, time.max)

    return week_start, week_end


def _get_current_month_range():
    today = datetime.utcnow().date()

    month_start_date = today.replace(day=1)

    if today.month == 12:
        next_month_start_date = today.replace(
            year=today.year + 1,
            month=1,
            day=1,
        )
    else:
        next_month_start_date = today.replace(
            month=today.month + 1,
            day=1,
        )

    month_end_date = next_month_start_date - timedelta(days=1)

    month_start = datetime.combine(month_start_date, time.min)
    month_end = datetime.combine(month_end_date, time.max)

    return month_start, month_end


def _build_sessions_summary(sessions: List[WorkoutSession]):
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


def _find_existing_session_today(
    db: Session,
    user_id: int,
    saved_workout_id: Optional[int],
    day_number: Optional[int],
) -> Optional[WorkoutSession]:
    today_start, today_end = _get_today_range()

    return (
        db.query(WorkoutSession)
        .filter(
            WorkoutSession.user_id == user_id,
            WorkoutSession.saved_workout_id == saved_workout_id,
            WorkoutSession.day_number == day_number,
            WorkoutSession.completed_at >= today_start,
            WorkoutSession.completed_at <= today_end,
        )
        .first()
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

    if not data.allow_duplicate:
        existing_session = _find_existing_session_today(
            db=db,
            user_id=current_user.id,
            saved_workout_id=data.saved_workout_id,
            day_number=data.day_number,
        )

        if existing_session:
            return _session_to_response(existing_session)

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


@router.get("/today-status", response_model=WorkoutSessionTodayStatusResponse)
def get_today_workout_session_status(
    saved_workout_id: Optional[int] = Query(default=None),
    day_number: Optional[int] = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    existing_session = _find_existing_session_today(
        db=db,
        user_id=current_user.id,
        saved_workout_id=saved_workout_id,
        day_number=day_number,
    )

    return WorkoutSessionTodayStatusResponse(
        already_completed_today=existing_session is not None,
        session=_session_to_response(existing_session)
        if existing_session is not None
        else None,
    )


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

    return _build_sessions_summary(sessions)


@router.get("/weekly-summary")
def get_workout_sessions_weekly_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    week_start, week_end = _get_current_week_range()

    sessions = (
        db.query(WorkoutSession)
        .filter(
            WorkoutSession.user_id == current_user.id,
            WorkoutSession.completed_at >= week_start,
            WorkoutSession.completed_at <= week_end,
        )
        .all()
    )

    weekly_summary = _build_sessions_summary(sessions)

    daily_summary = []

    for index in range(7):
        day_start = week_start + timedelta(days=index)
        day_end = datetime.combine(day_start.date(), time.max)

        day_sessions = [
            session
            for session in sessions
            if day_start <= session.completed_at <= day_end
        ]

        day_summary = _build_sessions_summary(day_sessions)

        daily_summary.append({
            "date": day_start.date().isoformat(),
            "day_index": index + 1,
            "total_sessions": day_summary["total_sessions"],
            "total_minutes": day_summary["total_minutes"],
            "total_completed_exercises": day_summary["total_completed_exercises"],
            "estimated_kcal": day_summary["estimated_kcal"],
        })

    return {
        "week_start": week_start.date().isoformat(),
        "week_end": week_end.date().isoformat(),
        "total_sessions": weekly_summary["total_sessions"],
        "total_minutes": weekly_summary["total_minutes"],
        "total_completed_exercises": weekly_summary["total_completed_exercises"],
        "estimated_kcal": weekly_summary["estimated_kcal"],
        "daily_summary": daily_summary,
    }


@router.get("/streak")
def get_workout_sessions_streak(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sessions = (
        db.query(WorkoutSession)
        .filter(WorkoutSession.user_id == current_user.id)
        .order_by(WorkoutSession.completed_at.desc())
        .all()
    )

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

    current_streak = 0

    if trained_today:
        expected_date = today
    else:
        expected_date = yesterday

    training_dates_set = set(training_dates)

    while expected_date in training_dates_set:
        current_streak += 1
        expected_date = expected_date - timedelta(days=1)

    return {
        "current_streak": current_streak,
        "last_training_date": last_training_date.isoformat(),
        "trained_today": trained_today,
        "trained_yesterday": trained_yesterday,
    }


@router.get("/monthly-summary")
def get_workout_sessions_monthly_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    month_start, month_end = _get_current_month_range()

    sessions = (
        db.query(WorkoutSession)
        .filter(
            WorkoutSession.user_id == current_user.id,
            WorkoutSession.completed_at >= month_start,
            WorkoutSession.completed_at <= month_end,
        )
        .all()
    )

    monthly_summary = _build_sessions_summary(sessions)

    weekly_summary = []
    current_week_start = month_start
    week_index = 1

    while current_week_start <= month_end:
        current_week_end = current_week_start + timedelta(days=6)

        if current_week_end > month_end:
            current_week_end = month_end

        week_sessions = [
            session
            for session in sessions
            if current_week_start <= session.completed_at <= current_week_end
        ]

        week_summary = _build_sessions_summary(week_sessions)

        weekly_summary.append({
            "week_index": week_index,
            "week_start": current_week_start.date().isoformat(),
            "week_end": current_week_end.date().isoformat(),
            "total_sessions": week_summary["total_sessions"],
            "total_minutes": week_summary["total_minutes"],
            "total_completed_exercises": week_summary["total_completed_exercises"],
            "estimated_kcal": week_summary["estimated_kcal"],
        })

        current_week_start = current_week_end + timedelta(days=1)
        week_index += 1

    return {
        "month_start": month_start.date().isoformat(),
        "month_end": month_end.date().isoformat(),
        "total_sessions": monthly_summary["total_sessions"],
        "total_minutes": monthly_summary["total_minutes"],
        "total_completed_exercises": monthly_summary["total_completed_exercises"],
        "estimated_kcal": monthly_summary["estimated_kcal"],
        "weekly_summary": weekly_summary,
    }