from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ProgressPhotoResponse(BaseModel):
    id: int
    user_id: int

    image_path: str
    image_url: str

    photo_type: str

    weight_kg: Optional[float] = None
    note: Optional[str] = None

    created_at: datetime

    class Config:
        from_attributes = True


class ProgressPhotoUpdate(BaseModel):
    photo_type: Optional[str] = None
    weight_kg: Optional[float] = None
    note: Optional[str] = None