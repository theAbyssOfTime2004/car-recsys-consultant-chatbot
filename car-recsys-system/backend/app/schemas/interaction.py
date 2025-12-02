"""
User interaction schemas
"""
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime


class InteractionCreate(BaseModel):
    vehicle_id: str
    interaction_type: str  # view, click, favorite, compare, contact
    session_id: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class InteractionResponse(BaseModel):
    id: int
    user_id: str
    vehicle_id: str
    interaction_type: str
    created_at: datetime

    class Config:
        from_attributes = True
