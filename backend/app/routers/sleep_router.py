from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SleepSession, User
from app.schemas.sleep_schema import (
    SleepSessionFinish,
    SleepSessionResponse,
)


router = APIRouter(
    prefix="/sleep",
    tags=["Sleep"],
)


def _sleep_session_to_response(session: SleepSession) -> SleepSessionResponse:
    return SleepSessionResponse(
        id=session.id,
        user_id=session.user_id,
        start_time=session.start_time,
        end_time=session.end_time,
        duration_minutes=session.duration_minutes,
        quality=session.quality,
        notes=session.notes,
        is_active=session.is_active,
        created_at=session.created_at,
    )


def _get_active_sleep_session(
    db: Session,
    user_id: int,
) -> Optional[SleepSession]:
    return (
        db.query(SleepSession)
        .filter(
            SleepSession.user_id == user_id,
            SleepSession.is_active == True,
        )
        .order_by(SleepSession.start_time.desc())
        .first()
    )


@router.post("/start", response_model=SleepSessionResponse)
def start_sleep_session(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    active_session = _get_active_sleep_session(
        db=db,
        user_id=current_user.id,
    )

    if active_session is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya tienes una sesión de sueño activa",
        )

    sleep_session = SleepSession(
        user_id=current_user.id,
        start_time=datetime.utcnow(),
        is_active=True,
    )

    db.add(sleep_session)
    db.commit()
    db.refresh(sleep_session)

    return _sleep_session_to_response(sleep_session)


@router.get("/active", response_model=Optional[SleepSessionResponse])
def get_active_sleep_session(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    active_session = _get_active_sleep_session(
        db=db,
        user_id=current_user.id,
    )

    if active_session is None:
        return None

    return _sleep_session_to_response(active_session)


@router.patch("/{sleep_session_id}/finish", response_model=SleepSessionResponse)
def finish_sleep_session(
    sleep_session_id: int,
    payload: SleepSessionFinish,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sleep_session = (
        db.query(SleepSession)
        .filter(
            SleepSession.id == sleep_session_id,
            SleepSession.user_id == current_user.id,
        )
        .first()
    )

    if sleep_session is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sesión de sueño no encontrada",
        )

    if sleep_session.is_active is False:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Esta sesión de sueño ya está finalizada",
        )

    end_time = datetime.utcnow()
    duration = end_time - sleep_session.start_time
    duration_minutes = max(0, int(duration.total_seconds() // 60))

    sleep_session.end_time = end_time
    sleep_session.duration_minutes = duration_minutes
    sleep_session.quality = payload.quality
    sleep_session.notes = payload.notes
    sleep_session.is_active = False

    db.commit()
    db.refresh(sleep_session)

    return _sleep_session_to_response(sleep_session)


@router.get("/me", response_model=List[SleepSessionResponse])
def get_my_sleep_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    sessions = (
        db.query(SleepSession)
        .filter(SleepSession.user_id == current_user.id)
        .order_by(SleepSession.start_time.desc())
        .all()
    )

    return [
        _sleep_session_to_response(session)
        for session in sessions
    ]


@router.get("/latest", response_model=Optional[SleepSessionResponse])
def get_latest_sleep_session(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    latest_session = (
        db.query(SleepSession)
        .filter(
            SleepSession.user_id == current_user.id,
            SleepSession.is_active == False,
        )
        .order_by(SleepSession.end_time.desc())
        .first()
    )

    if latest_session is None:
        return None

    return _sleep_session_to_response(latest_session)