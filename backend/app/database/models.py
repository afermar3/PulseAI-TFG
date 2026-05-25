from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
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


class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)
    category = Column(String, nullable=False)
    muscle_group = Column(String, nullable=False)
    difficulty = Column(String, nullable=False)
    equipment = Column(String, nullable=True)

    description = Column(String, nullable=True)
    instructions = Column(String, nullable=True)
    image = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

class SavedWorkout(Base):
    __tablename__ = "saved_workouts"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    title = Column(String, nullable=False)
    summary = Column(String, nullable=True)
    goal = Column(String, nullable=True)
    level = Column(String, nullable=True)

    days_per_week = Column(Integer, nullable=True)
    duration_minutes = Column(Integer, nullable=True)

    content_json = Column(Text, nullable=False)

    is_active = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")

class WorkoutSession(Base):
    __tablename__ = "workout_sessions"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    saved_workout_id = Column(Integer, ForeignKey("saved_workouts.id"), nullable=True)

    workout_title = Column(String, nullable=False)
    day_number = Column(Integer, nullable=True)
    day_name = Column(String, nullable=True)

    total_exercises = Column(Integer, default=0)
    completed_exercises = Column(Integer, default=0)
    duration_minutes = Column(Integer, nullable=True)

    completed_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")
    saved_workout = relationship("SavedWorkout")

class ScheduledWorkout(Base):
    __tablename__ = "scheduled_workouts"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    saved_workout_id = Column(Integer, ForeignKey("saved_workouts.id"), nullable=True)
    completed_session_id = Column(Integer, ForeignKey("workout_sessions.id"), nullable=True)

    workout_title = Column(String, nullable=False)
    day_number = Column(Integer, nullable=True)
    day_name = Column(String, nullable=True)

    scheduled_date = Column(DateTime, nullable=False)

    duration_minutes = Column(Integer, nullable=True)
    completed = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User")
    saved_workout = relationship("SavedWorkout")
    completed_session = relationship("WorkoutSession")

class WorkoutExerciseProgress(Base):
    __tablename__ = "workout_exercise_progress"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    saved_workout_id = Column(
        Integer,
        ForeignKey("saved_workouts.id"),
        nullable=True,
    )

    scheduled_workout_id = Column(
        Integer,
        ForeignKey("scheduled_workouts.id"),
        nullable=True,
    )

    day_number = Column(Integer, nullable=True)

    exercise_index = Column(Integer, nullable=False)
    exercise_id = Column(Integer, ForeignKey("exercises.id"), nullable=True)
    exercise_name = Column(String, nullable=False)

    completed = Column(Boolean, default=False)
    completed_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    user = relationship("User")
    saved_workout = relationship("SavedWorkout")
    scheduled_workout = relationship("ScheduledWorkout")
    exercise = relationship("Exercise")