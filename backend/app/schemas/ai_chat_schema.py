from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class AiPendingAction(BaseModel):
    type: str
    title: str
    description: str
    requires_confirmation: bool = True
    payload: Dict[str, Any] = Field(default_factory=dict)


class AiChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=1000)


class AiChatResponse(BaseModel):
    answer: str
    pending_action: Optional[AiPendingAction] = None


class AiApplyActionRequest(BaseModel):
    pending_action: AiPendingAction


class AiApplyActionResponse(BaseModel):
    success: bool
    message: str
    action_type: str
    data: Optional[Dict[str, Any]] = None


class AiChatHistoryItem(BaseModel):
    id: int
    role: str
    content: str
    pending_action: Optional[Dict[str, Any]] = None
    created_at: datetime


class AiChatHistoryResponse(BaseModel):
    messages: List[AiChatHistoryItem]