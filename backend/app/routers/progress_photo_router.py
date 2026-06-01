import uuid
from pathlib import Path
from typing import List, Optional

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    UploadFile,
    status,
)
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database.database import get_db
from app.database.models import ProgressPhoto, User
from app.schemas.progress_photo_schema import (
    ProgressPhotoResponse,
    ProgressPhotoUpdate,
)


router = APIRouter(
    prefix="/progress-photos",
    tags=["Progress Photos"],
)


VALID_PHOTO_TYPES = {
    "FRONT",
    "SIDE",
    "BACK",
    "OTHER",
}

VALID_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
}


def _uploads_root() -> Path:
    return Path(__file__).resolve().parents[2] / "uploads"


def _photo_to_response(photo: ProgressPhoto) -> ProgressPhotoResponse:
    return ProgressPhotoResponse(
        id=photo.id,
        user_id=photo.user_id,
        image_path=photo.image_path,
        image_url=f"/uploads/{photo.image_path}",
        photo_type=photo.photo_type,
        weight_kg=photo.weight_kg,
        note=photo.note,
        created_at=photo.created_at,
    )


def _normalize_photo_type(photo_type: str) -> str:
    normalized = photo_type.upper().strip()

    if normalized not in VALID_PHOTO_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tipo de foto no válido. Usa FRONT, SIDE, BACK u OTHER.",
        )

    return normalized


def _validate_image_file(file: UploadFile) -> str:
    original_name = file.filename or ""
    extension = Path(original_name).suffix.lower()

    if extension not in VALID_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Formato de imagen no válido. Usa JPG, PNG o WEBP.",
        )

    if file.content_type is not None and not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El archivo subido no parece ser una imagen.",
        )

    return extension


def _get_user_photo(
    db: Session,
    user_id: int,
    photo_id: int,
) -> ProgressPhoto:
    photo = (
        db.query(ProgressPhoto)
        .filter(
            ProgressPhoto.id == photo_id,
            ProgressPhoto.user_id == user_id,
        )
        .first()
    )

    if photo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Foto de progreso no encontrada",
        )

    return photo


@router.post("", response_model=ProgressPhotoResponse)
async def upload_progress_photo(
    photo_type: str = Form(...),
    weight_kg: Optional[float] = Form(None),
    note: Optional[str] = Form(None),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    normalized_photo_type = _normalize_photo_type(photo_type)
    extension = _validate_image_file(file)

    user_folder = _uploads_root() / "progress_photos" / f"user_{current_user.id}"
    user_folder.mkdir(parents=True, exist_ok=True)

    filename = f"{uuid.uuid4().hex}{extension}"
    file_path = user_folder / filename

    content = await file.read()

    if not content:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La imagen está vacía",
        )

    file_path.write_bytes(content)

    relative_path = f"progress_photos/user_{current_user.id}/{filename}"

    photo = ProgressPhoto(
        user_id=current_user.id,
        image_path=relative_path,
        photo_type=normalized_photo_type,
        weight_kg=weight_kg,
        note=note,
    )

    db.add(photo)
    db.commit()
    db.refresh(photo)

    return _photo_to_response(photo)


@router.get("/me", response_model=List[ProgressPhotoResponse])
def get_my_progress_photos(
    photo_type: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = (
        db.query(ProgressPhoto)
        .filter(ProgressPhoto.user_id == current_user.id)
    )

    if photo_type is not None and photo_type.strip():
        normalized_photo_type = _normalize_photo_type(photo_type)
        query = query.filter(ProgressPhoto.photo_type == normalized_photo_type)

    photos = (
        query
        .order_by(ProgressPhoto.created_at.desc())
        .all()
    )

    return [
        _photo_to_response(photo)
        for photo in photos
    ]


@router.get("/{photo_id}", response_model=ProgressPhotoResponse)
def get_progress_photo_detail(
    photo_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    photo = _get_user_photo(
        db=db,
        user_id=current_user.id,
        photo_id=photo_id,
    )

    return _photo_to_response(photo)


@router.patch("/{photo_id}", response_model=ProgressPhotoResponse)
def update_progress_photo(
    photo_id: int,
    data: ProgressPhotoUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    photo = _get_user_photo(
        db=db,
        user_id=current_user.id,
        photo_id=photo_id,
    )

    if data.photo_type is not None:
        photo.photo_type = _normalize_photo_type(data.photo_type)

    if data.weight_kg is not None:
        photo.weight_kg = data.weight_kg

    if data.note is not None:
        photo.note = data.note

    db.commit()
    db.refresh(photo)

    return _photo_to_response(photo)


@router.delete("/{photo_id}")
def delete_progress_photo(
    photo_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    photo = _get_user_photo(
        db=db,
        user_id=current_user.id,
        photo_id=photo_id,
    )

    image_path = _uploads_root() / photo.image_path

    db.delete(photo)
    db.commit()

    if image_path.exists():
        try:
            image_path.unlink()
        except Exception:
            pass

    return {
        "message": "Foto de progreso eliminada correctamente"
    }