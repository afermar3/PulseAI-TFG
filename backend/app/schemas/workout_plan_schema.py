from datetime import datetime
from typing import Any, Dict, Optional

from pydantic import BaseModel


class WorkoutPlanCreate(BaseModel):
    title: str
    summary: Optional[str] = None
    goal: Optional[str] = None
    level: Optional[str] = None
    days_per_week: Optional[int] = None
    duration_minutes: Optional[int] = None
    content: Dict[str, Any]


class WorkoutPlanResponse(BaseModel):
    id: int
    user_id: int

    title: str
    summary: Optional[str] = None
    goal: Optional[str] = None
    level: Optional[str] = None

    days_per_week: Optional[int] = None
    duration_minutes: Optional[int] = None

    content: Dict[str, Any]
    is_active: bool
    created_at: datetime