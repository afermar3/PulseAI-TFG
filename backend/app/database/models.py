from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
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

    sleep_sessions = relationship(
        "SleepSession",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    sleep_goal = relationship(
        "SleepGoal",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )

    sleep_goal_profiles = relationship(
        "SleepGoalProfile",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    ai_chat_messages = relationship(
        "AiChatMessage",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    progress_photos = relationship(
        "ProgressPhoto",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    password_reset_tokens = relationship(
    "PasswordResetToken",
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


class SleepSession(Base):
    __tablename__ = "sleep_sessions"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    start_time = Column(DateTime, nullable=False, default=datetime.utcnow)
    end_time = Column(DateTime, nullable=True)

    duration_minutes = Column(Integer, nullable=True)

    quality = Column(String, nullable=True)
    notes = Column(Text, nullable=True)

    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="sleep_sessions")


class SleepGoal(Base):
    __tablename__ = "sleep_goals"

    __table_args__ = (
        UniqueConstraint("user_id", name="uq_sleep_goals_user_id"),
    )

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    bed_time = Column(String, nullable=False)
    wake_time = Column(String, nullable=False)

    target_minutes = Column(Integer, nullable=False)

    repeat = Column(String, nullable=True, default="Todos los días")
    enabled = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    user = relationship("User", back_populates="sleep_goal")


class SleepGoalProfile(Base):
    __tablename__ = "sleep_goal_profiles"

    __table_args__ = (
        UniqueConstraint(
            "user_id",
            "goal_type",
            name="uq_sleep_goal_profiles_user_goal_type",
        ),
    )

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    goal_type = Column(String, nullable=False)
    # ALL_DAYS / WEEKDAYS / WEEKENDS

    bed_time = Column(String, nullable=False)
    wake_time = Column(String, nullable=False)

    target_minutes = Column(Integer, nullable=False)

    enabled = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    user = relationship("User", back_populates="sleep_goal_profiles")


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


class AiChatMessage(Base):
    __tablename__ = "ai_chat_messages"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    role = Column(String, nullable=False)
    content = Column(Text, nullable=False)

    pending_action_json = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="ai_chat_messages")


class ProgressPhoto(Base):
    __tablename__ = "progress_photos"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    image_path = Column(String, nullable=False)

    photo_type = Column(String, nullable=False)
    # FRONT / SIDE / BACK / OTHER

    weight_kg = Column(Float, nullable=True)
    note = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="progress_photos")

class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    token_hash = Column(String, nullable=False, index=True)
    expires_at = Column(DateTime, nullable=False)

    used = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="password_reset_tokens")