from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import SleepGoal, User
from app.schemas.sleep_goal_schema import (
    SleepGoalResponse,
    SleepGoalUpsert,
)


router = APIRouter(
    prefix="/sleep-goal",
    tags=["Sleep Goal"],
)


def _sleep_goal_to_response(goal: SleepGoal) -> SleepGoalResponse:
    return SleepGoalResponse(
        id=goal.id,
        user_id=goal.user_id,
        bed_time=goal.bed_time,
        wake_time=goal.wake_time,
        target_minutes=goal.target_minutes,
        repeat=goal.repeat,
        enabled=goal.enabled,
        created_at=goal.created_at,
        updated_at=goal.updated_at,
    )


def _get_user_sleep_goal(
    db: Session,
    user_id: int,
) -> Optional[SleepGoal]:
    return (
        db.query(SleepGoal)
        .filter(SleepGoal.user_id == user_id)
        .first()
    )


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


@router.get("/me", response_model=Optional[SleepGoalResponse])
def get_my_sleep_goal(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = _get_user_sleep_goal(
        db=db,
        user_id=current_user.id,
    )

    if goal is None:
        return None

    return _sleep_goal_to_response(goal)


@router.put("/me", response_model=SleepGoalResponse)
def upsert_my_sleep_goal(
    data: SleepGoalUpsert,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
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

    goal = _get_user_sleep_goal(
        db=db,
        user_id=current_user.id,
    )

    if goal is None:
        goal = SleepGoal(
            user_id=current_user.id,
            bed_time=data.bed_time,
            wake_time=data.wake_time,
            target_minutes=data.target_minutes,
            repeat=data.repeat,
            enabled=data.enabled,
        )

        db.add(goal)
    else:
        goal.bed_time = data.bed_time
        goal.wake_time = data.wake_time
        goal.target_minutes = data.target_minutes
        goal.repeat = data.repeat
        goal.enabled = data.enabled

    db.commit()
    db.refresh(goal)

    return _sleep_goal_to_response(goal)


@router.patch("/me/toggle", response_model=SleepGoalResponse)
def toggle_my_sleep_goal(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = _get_user_sleep_goal(
        db=db,
        user_id=current_user.id,
    )

    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No tienes un objetivo de sueño configurado",
        )

    goal.enabled = not goal.enabled

    db.commit()
    db.refresh(goal)

    return _sleep_goal_to_response(goal)


@router.delete("/me")
def delete_my_sleep_goal(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    goal = _get_user_sleep_goal(
        db=db,
        user_id=current_user.id,
    )

    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No tienes un objetivo de sueño configurado",
        )

    db.delete(goal)
    db.commit()

    return {
        "message": "Objetivo de sueño eliminado correctamente"
    }