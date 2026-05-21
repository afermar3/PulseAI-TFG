from typing import List, Optional

from pydantic import BaseModel, Field


class AiWorkoutGenerateRequest(BaseModel):
    days_per_week: int = Field(default=4, ge=1, le=7)
    duration_minutes: int = Field(default=60, ge=15, le=180)
    focus: Optional[str] = None
    level: Optional[str] = None


class AiWorkoutExercise(BaseModel):
    exercise_id: int
    exercise_name: str
    sets: int
    reps: str
    rest_seconds: int
    notes: Optional[str] = None


class AiWorkoutDay(BaseModel):
    day_number: int
    name: str
    focus: str
    exercises: List[AiWorkoutExercise]


class AiWorkoutGenerateResponse(BaseModel):
    title: str
    summary: str
    days_per_week: int
    duration_minutes: int
    level: str
    goal: str
    days: List[AiWorkoutDay]
    warmup: List[str]
    progression: List[str]
    final_tips: List[str]