from typing import Optional
from pydantic import BaseModel


class ProfileResponse(BaseModel):
    id: int
    user_id: int

    name: Optional[str] = None
    surname: Optional[str] = None
    gender: Optional[str] = None

    age: Optional[int] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

    goal: Optional[str] = None

    profile_image_path: Optional[str] = None

    class Config:
        from_attributes = True


class ProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    surname: Optional[str] = None
    gender: Optional[str] = None

    age: Optional[int] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

    goal: Optional[str] = None