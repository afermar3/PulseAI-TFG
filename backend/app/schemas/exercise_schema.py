from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ExerciseBase(BaseModel):
    name: str
    category: str
    muscle_group: str
    difficulty: str
    equipment: Optional[str] = None
    description: Optional[str] = None
    instructions: Optional[str] = None
    image: Optional[str] = None


class ExerciseCreate(ExerciseBase):
    pass


class ExerciseResponse(ExerciseBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True