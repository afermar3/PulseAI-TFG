from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class SleepGoalProfileUpsert(BaseModel):
    goal_type: str = Field(..., min_length=1, max_length=30)

    bed_time: str = Field(..., min_length=5, max_length=5)
    wake_time: str = Field(..., min_length=5, max_length=5)

    target_minutes: int = Field(..., ge=1)

    enabled: bool = True


class SleepGoalProfileResponse(BaseModel):
    id: int
    user_id: int

    goal_type: str

    bed_time: str
    wake_time: str

    target_minutes: int

    enabled: bool

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class EffectiveSleepGoalResponse(BaseModel):
    source: str
    goal: Optional[SleepGoalProfileResponse] = None
    recommended_minutes: int = 480