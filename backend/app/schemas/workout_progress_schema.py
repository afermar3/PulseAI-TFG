from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class WorkoutExerciseProgressToggle(BaseModel):
    saved_workout_id: Optional[int] = None
    scheduled_workout_id: Optional[int] = None

    day_number: Optional[int] = None

    exercise_index: int
    exercise_id: Optional[int] = None
    exercise_name: str

    completed: bool


class WorkoutExerciseProgressResponse(BaseModel):
    id: int
    user_id: int

    saved_workout_id: Optional[int] = None
    scheduled_workout_id: Optional[int] = None

    day_number: Optional[int] = None

    exercise_index: int
    exercise_id: Optional[int] = None
    exercise_name: str

    completed: bool
    completed_at: Optional[datetime] = None

    created_at: datetime
    updated_at: datetime


class WorkoutDayProgressResponse(BaseModel):
    saved_workout_id: Optional[int] = None
    scheduled_workout_id: Optional[int] = None
    day_number: Optional[int] = None

    total_completed: int
    completed_exercise_indexes: List[int]

    exercises: List[WorkoutExerciseProgressResponse]