"""
ETL Pipeline - Load CSV files to RAW layer
"""
import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import os
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database connection
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://admin:admin123@postgres:5432/car_recsys")

# Datasets directory
DATASETS_DIR = Path("/app/datasets")


def load_csv_to_raw():
    """Load all CSV files to RAW layer"""
    logger.info("Starting CSV to RAW layer ETL")
    
    engine = create_engine(DATABASE_URL)
    
    # Mapping CSV files to RAW tables
    csv_mappings = {
        "used_vehicles.csv": "raw.used_vehicles",
        "new_vehicles.csv": "raw.new_vehicles",
        "sellers.csv": "raw.sellers",
        "vehicle_features.csv": "raw.vehicle_features",
        "reviews_ratings.csv": "raw.reviews_ratings",
        "vehicle_images.csv": "raw.vehicle_images",
        "seller_vehicle_relationships.csv": "raw.seller_vehicle_relationships",
    }
    
    for csv_file, table_name in csv_mappings.items():
        csv_path = DATASETS_DIR / csv_file
        
        if not csv_path.exists():
            logger.warning(f"File not found: {csv_path}")
            continue
        
        logger.info(f"Loading {csv_file} to {table_name}")
        
        try:
            # Read CSV
            df = pd.read_csv(csv_path, low_memory=False)
            
            logger.info(f"  Rows: {len(df):,}")
            logger.info(f"  Columns: {len(df.columns)}")
            
            # Load to database
            df.to_sql(
                name=table_name.split('.')[1],  # table name without schema
                schema=table_name.split('.')[0],  # schema name
                con=engine,
                if_exists='append',
                index=False,
                chunksize=1000,
                method='multi'
            )
            
            logger.info(f"✓ Successfully loaded {csv_file}")
            
        except Exception as e:
            logger.error(f"✗ Error loading {csv_file}: {e}")
            continue
    
    engine.dispose()
    logger.info("CSV to RAW layer ETL completed")


if __name__ == "__main__":
    load_csv_to_raw()
