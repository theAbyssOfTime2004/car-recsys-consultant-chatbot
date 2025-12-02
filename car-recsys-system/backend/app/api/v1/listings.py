"""
Listing endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.vehicle import Vehicle
from app.schemas.vehicle import VehicleResponse

router = APIRouter()


@router.get("/listing/{vehicle_id}", response_model=VehicleResponse)
async def get_listing(vehicle_id: int, db: Session = Depends(get_db)):
    """Get vehicle listing details"""
    vehicle = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehicle not found"
        )
    
    return VehicleResponse.from_orm(vehicle)


@router.get("/listings", response_model=List[VehicleResponse])
async def get_listings(
    limit: int = 10,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get featured/latest vehicle listings"""
    vehicles = db.query(Vehicle).order_by(Vehicle.id.desc()).offset(offset).limit(limit).all()
    return [VehicleResponse.from_orm(v) for v in vehicles]


@router.get("/listings/similar/{vehicle_id}", response_model=List[VehicleResponse])
async def get_similar_vehicles(
    vehicle_id: int,
    limit: int = 6,
    db: Session = Depends(get_db)
):
    """Get similar vehicles based on brand, model, price range"""
    # Get the reference vehicle
    vehicle = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehicle not found"
        )
    
    # Find similar vehicles
    query = db.query(Vehicle).filter(Vehicle.id != vehicle_id)
    
    # Same brand
    if vehicle.brand:
        query = query.filter(Vehicle.brand == vehicle.brand)
    
    # Similar price range (±30%)
    if vehicle.price:
        price_min = vehicle.price * 0.7
        price_max = vehicle.price * 1.3
        query = query.filter(Vehicle.price.between(price_min, price_max))
    
    similar_vehicles = query.limit(limit).all()
    
    return [VehicleResponse.from_orm(v) for v in similar_vehicles]
