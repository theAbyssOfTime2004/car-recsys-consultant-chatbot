"""
Vehicle model (read-only from raw data)
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, Text
from app.core.database import Base


class Vehicle(Base):
    __tablename__ = "used_vehicles"
    __table_args__ = {'schema': 'raw'}

    id = Column(Integer, primary_key=True)
    url = Column(String, nullable=True)
    title = Column(String, nullable=True)
    price = Column(Float, nullable=True)
    brand = Column(String, nullable=True)
    model = Column(String, nullable=True)
    year = Column(Integer, nullable=True)
    mileage = Column(Float, nullable=True)
    fuel_type = Column(String, nullable=True)
    transmission = Column(String, nullable=True)
    body_type = Column(String, nullable=True)
    color = Column(String, nullable=True)
    seats = Column(Integer, nullable=True)
    origin = Column(String, nullable=True)
    location = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    seller_name = Column(String, nullable=True)
    seller_phone = Column(String, nullable=True)
    posted_date = Column(DateTime, nullable=True)
