from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class SleepSessionFinish(BaseModel):
    quality: Optional[str] = None
    notes: Optional[str] = None


class SleepSessionResponse(BaseModel):
    id: int
    user_id: int

    start_time: datetime
    end_time: Optional[datetime] = None

    duration_minutes: Optional[int] = None

    quality: Optional[str] = None
    notes: Optional[str] = None

    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True