from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ScheduledWorkoutCreate(BaseModel):
    saved_workout_id: Optional[int] = None

    workout_title: str
    day_number: Optional[int] = None
    day_name: Optional[str] = None

    scheduled_date: datetime
    duration_minutes: Optional[int] = None


class ScheduledWorkoutComplete(BaseModel):
    total_exercises: Optional[int] = None
    completed_exercises: Optional[int] = None
    duration_minutes: Optional[int] = None


class ScheduledWorkoutResponse(BaseModel):
    id: int
    user_id: int

    saved_workout_id: Optional[int] = None
    completed_session_id: Optional[int] = None

    workout_title: str
    day_number: Optional[int] = None
    day_name: Optional[str] = None

    scheduled_date: datetime
    duration_minutes: Optional[int] = None

    completed: bool
    created_at: datetime