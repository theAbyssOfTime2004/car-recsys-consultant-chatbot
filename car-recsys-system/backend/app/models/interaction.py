"""
User interaction tracking model
"""
from sqlalchemy import Column, String, Integer, DateTime, Float, JSON
from sqlalchemy.sql import func
from app.core.database import Base


class UserInteraction(Base):
    __tablename__ = "user_interactions"
    __table_args__ = {'schema': 'gold'}

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    vehicle_id = Column(String, nullable=False, index=True)
    interaction_type = Column(String, nullable=False)  # view, click, favorite, compare, contact
    session_id = Column(String)
    interaction_score = Column(Float, default=1.0)
    extra_data = Column(JSON)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
