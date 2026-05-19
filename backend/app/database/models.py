from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.database.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    profile = relationship(
        "UserProfile",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )

    workouts = relationship(
        "WorkoutSchedule",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    sleep_alarms = relationship(
        "SleepAlarm",
        back_populates="user",
        cascade="all, delete-orphan",
    )


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    name = Column(String, nullable=True)
    surname = Column(String, nullable=True)
    gender = Column(String, nullable=True)

    age = Column(Integer, nullable=True)
    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)

    goal = Column(String, nullable=True)

    user = relationship("User", back_populates="profile")


class WorkoutSchedule(Base):
    __tablename__ = "workout_schedules"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    name = Column(String, nullable=False)
    category = Column(String, nullable=True)
    duration = Column(String, nullable=True)
    kcal = Column(String, nullable=True)

    start_time = Column(DateTime, nullable=False)
    completed = Column(Boolean, default=False)

    difficulty = Column(String, nullable=True)
    repetitions = Column(Integer, nullable=True)
    weight = Column(Float, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="workouts")


class SleepAlarm(Base):
    __tablename__ = "sleep_alarms"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    name = Column(String, nullable=False, default="Alarma")
    date_time = Column(DateTime, nullable=False)

    bed_time = Column(DateTime, nullable=True)
    duration = Column(String, nullable=True)
    repeat = Column(String, nullable=True)

    vibrate = Column(Boolean, default=True)
    enabled = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="sleep_alarms")