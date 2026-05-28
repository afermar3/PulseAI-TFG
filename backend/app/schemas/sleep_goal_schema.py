from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class SleepGoalUpsert(BaseModel):
    bed_time: str = Field(..., min_length=5, max_length=5)
    wake_time: str = Field(..., min_length=5, max_length=5)

    target_minutes: int = Field(..., ge=1)

    repeat: Optional[str] = "Todos los días"
    enabled: bool = True


class SleepGoalResponse(BaseModel):
    id: int
    user_id: int

    bed_time: str
    wake_time: str

    target_minutes: int

    repeat: Optional[str] = None
    enabled: bool

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True