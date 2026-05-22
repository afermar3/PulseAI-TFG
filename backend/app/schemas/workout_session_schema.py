from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class WorkoutSessionCreate(BaseModel):
    saved_workout_id: Optional[int] = None

    workout_title: str
    day_number: Optional[int] = None
    day_name: Optional[str] = None

    total_exercises: int
    completed_exercises: int
    duration_minutes: Optional[int] = None


class WorkoutSessionResponse(BaseModel):
    id: int
    user_id: int
    saved_workout_id: Optional[int] = None

    workout_title: str
    day_number: Optional[int] = None
    day_name: Optional[str] = None

    total_exercises: int
    completed_exercises: int
    duration_minutes: Optional[int] = None

    completed_at: datetime