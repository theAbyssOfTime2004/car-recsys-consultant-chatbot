"""
Database models
"""
from app.models.user import User
from app.models.vehicle import Vehicle
from app.models.interaction import UserInteraction

__all__ = ['User', 'Vehicle', 'UserInteraction']
