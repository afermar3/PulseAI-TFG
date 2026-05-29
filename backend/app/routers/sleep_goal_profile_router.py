from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SleepGoalProfile, User
from app.schemas.sleep_goal_profile_schema import (
    EffectiveSleepGoalResponse,
    SleepGoalProfileResponse,
    SleepGoalProfileUpsert,
)


router = APIRouter(
    prefix="/sleep-goal-profiles",
    tags=["Sleep Goal Profiles"],
)

VALID_GOAL_TYPES = {
    "ALL_DAYS",
    "WEEKDAYS",
    "WEEKENDS",
}


def _is_valid_time(value: str) -> bool:
    parts = value.split(":")

    if len(parts) != 2:
        return False

    try:
        hour = int(parts[0])
        minute = int(parts[1])
    except ValueError:
        return False

    return 0 <= hour <= 23 and 0 <= minute <= 59


def _goal_to_response(goal: SleepGoalProfile) -> SleepGoalProfileResponse:
    return SleepGoalProfileResponse(
        id=goal.id,
        user_id=goal.user_id,
        goal_type=goal.goal_type,
        bed_time=goal.bed_time,
        wake_time=goal.wake_time,
        target_minutes=goal.target_minutes,
        enabled=goal.enabled,
        created_at=goal.created_at,
        updated_at=goal.updated_at,
    )


def _get_goal_by_type(
    db: Session,
    user_id: int,
    goal_type: str,
) -> Optional[SleepGoalProfile]:
    return (
        db.query(SleepGoalProfile)
        .filter(
            SleepGoalProfile.user_id == user_id,
            SleepGoalProfile.goal_type == goal_type,
        )
        .first()
    )


def _get_effective_goal(
    db: Session,
    user_id: int,
) -> tuple[str, Optional[SleepGoalProfile]]:
    today = datetime.utcnow().date()
    weekday = today.weekday()

    preferred_type = "WEEKENDS" if weekday >= 5 else "WEEKDAYS"

    preferred_goal = _get_goal_by_type(
        db=db,
        user_id=user_id,
        goal_type=preferred_type,
    )

    if preferred_goal is not None and preferred_goal.enabled:
        return preferred_type, preferred_goal

    all_days_goal = _get_goal_by_type(
        db=db,
        user_id=user_id,
        goal_type="ALL_DAYS",
    )

    if all_days_goal is not None and all_days_goal.enabled:
        return "ALL_DAYS", all_days_goal

    return "RECOMMENDED", None


@router.get("/me", response_model=List[SleepGoalProfileResponse])
def get_my_sleep_goal_profiles(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goals = (
        db.query(SleepGoalProfile)
        .filter(SleepGoalProfile.user_id == current_user.id)
        .order_by(SleepGoalProfile.goal_type.asc())
        .all()
    )

    return [_goal_to_response(goal) for goal in goals]


@router.get("/effective-today", response_model=EffectiveSleepGoalResponse)
def get_effective_sleep_goal_today(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    source, goal = _get_effective_goal(
        db=db,
        user_id=current_user.id,
    )

    return EffectiveSleepGoalResponse(
        source=source,
        goal=_goal_to_response(goal) if goal is not None else None,
        recommended_minutes=480,
    )


@router.put("", response_model=SleepGoalProfileResponse)
def upsert_sleep_goal_profile(
    data: SleepGoalProfileUpsert,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal_type = data.goal_type.upper().strip()

    if goal_type not in VALID_GOAL_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tipo de objetivo no válido. Usa ALL_DAYS, WEEKDAYS o WEEKENDS.",
        )

    if not _is_valid_time(data.bed_time):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La hora de dormir debe tener formato HH:MM válido",
        )

    if not _is_valid_time(data.wake_time):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La hora de despertar debe tener formato HH:MM válido",
        )

    goal = _get_goal_by_type(
        db=db,
        user_id=current_user.id,
        goal_type=goal_type,
    )

    if goal is None:
        goal = SleepGoalProfile(
            user_id=current_user.id,
            goal_type=goal_type,
            bed_time=data.bed_time,
            wake_time=data.wake_time,
            target_minutes=data.target_minutes,
            enabled=data.enabled,
        )

        db.add(goal)
    else:
        goal.bed_time = data.bed_time
        goal.wake_time = data.wake_time
        goal.target_minutes = data.target_minutes
        goal.enabled = data.enabled

    db.commit()
    db.refresh(goal)

    return _goal_to_response(goal)


@router.patch("/{goal_id}/toggle", response_model=SleepGoalProfileResponse)
def toggle_sleep_goal_profile(
    goal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = (
        db.query(SleepGoalProfile)
        .filter(
            SleepGoalProfile.id == goal_id,
            SleepGoalProfile.user_id == current_user.id,
        )
        .first()
    )

    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Objetivo de sueño no encontrado",
        )

    goal.enabled = not goal.enabled

    db.commit()
    db.refresh(goal)

    return _goal_to_response(goal)


@router.delete("/{goal_id}")
def delete_sleep_goal_profile(
    goal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = (
        db.query(SleepGoalProfile)
        .filter(
            SleepGoalProfile.id == goal_id,
            SleepGoalProfile.user_id == current_user.id,
        )
        .first()
    )

    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Objetivo de sueño no encontrado",
        )

    db.delete(goal)
    db.commit()

    return {
        "message": "Objetivo de sueño eliminado correctamente"
    }