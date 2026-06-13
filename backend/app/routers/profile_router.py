from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import User, UserProfile
from app.schemas.profile_schema import ProfileResponse, ProfileUpdateRequest
from pathlib import Path
from uuid import uuid4


router = APIRouter(
    prefix="/profile",
    tags=["Profile"],
)


@router.get("/me", response_model=ProfileResponse)
def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = (
        db.query(UserProfile)
        .filter(UserProfile.user_id == current_user.id)
        .first()
    )

    if profile is None:
        profile = UserProfile(user_id=current_user.id)
        db.add(profile)
        db.commit()
        db.refresh(profile)

    return profile


@router.put("/me", response_model=ProfileResponse)
def update_my_profile(
    data: ProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = (
        db.query(UserProfile)
        .filter(UserProfile.user_id == current_user.id)
        .first()
    )

    if profile is None:
        profile = UserProfile(user_id=current_user.id)
        db.add(profile)
        db.commit()
        db.refresh(profile)

    update_data = data.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(profile, key, value)

    db.commit()
    db.refresh(profile)

    return profile


@router.post("/me/image", response_model=ProfileResponse)
async def upload_profile_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    allowed_content_types = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }

    if file.content_type not in allowed_content_types:
        raise HTTPException(
            status_code=400,
            detail="Formato de imagen no válido. Usa JPG, PNG o WEBP.",
        )

    profile = (
        db.query(UserProfile)
        .filter(UserProfile.user_id == current_user.id)
        .first()
    )

    if profile is None:
        profile = UserProfile(user_id=current_user.id)
        db.add(profile)
        db.commit()
        db.refresh(profile)

    uploads_dir = Path(__file__).resolve().parents[2] / "uploads" / "profile_images"
    uploads_dir.mkdir(parents=True, exist_ok=True)

    extension = allowed_content_types[file.content_type]
    filename = f"user_{current_user.id}_{uuid4().hex}{extension}"
    file_path = uploads_dir / filename

    content = await file.read()

    with open(file_path, "wb") as buffer:
        buffer.write(content)

    profile.profile_image_path = f"/uploads/profile_images/{filename}"

    db.commit()
    db.refresh(profile)

    return profile