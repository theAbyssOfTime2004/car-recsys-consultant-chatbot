#!/usr/bin/env python3
"""
Reset database and load data from CSV
"""
import pandas as pd
from sqlalchemy import create_engine, text
import sys

# Database connection
DATABASE_URL = "postgresql://admin:admin123@localhost:5432/car_recsys"

def reset_database():
    """Drop and recreate raw schema and table"""
    engine = create_engine(DATABASE_URL)
    
    with engine.connect() as conn:
        print("🗑️  Dropping raw schema...")
        conn.execute(text("DROP SCHEMA IF EXISTS raw CASCADE;"))
        conn.commit()
        
        print("📦 Creating raw schema...")
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))
        conn.commit()
        
        print("📦 Creating silver schema...")
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS silver;"))
        conn.commit()
        
        print("📦 Creating gold schema...")
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS gold;"))
        conn.commit()
        
    print("✅ Schemas ready!")
    return engine

def load_csv_data(engine):
    """Load data from CSV file"""
    csv_path = "/home/duc-nguyen16/Car Recsys Consultant Chatbot/datasets/used_vehicles.csv"
    
    print(f"📁 Reading CSV from {csv_path}...")
    df = pd.read_csv(csv_path)
    
    print(f"📊 Loaded {len(df)} rows")
    print(f"📋 Columns: {list(df.columns)}")
    
    # Clean column names
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')
    
    # Rename columns to match expected schema
    column_mapping = {
        'vehicle_id': 'id',
        'car_name': 'title',
        'car_model': 'model',
        'exterior_color': 'color',
        'vehicle_url': 'url'
    }
    
    for old_name, new_name in column_mapping.items():
        if old_name in df.columns:
            df.rename(columns={old_name: new_name}, inplace=True)
    
    # Ensure required columns exist
    required_cols = ['id', 'url', 'title', 'price', 'brand', 'model', 'year', 
                     'mileage', 'fuel_type', 'transmission']
    
    missing_cols = [col for col in required_cols if col not in df.columns]
    if missing_cols:
        print(f"⚠️  Missing columns: {missing_cols}")
        for col in missing_cols:
            df[col] = None
    
    # Add optional columns if not present
    optional_cols = ['body_type', 'color', 'seats', 'origin', 'location', 
                     'description', 'image_url', 'seller_name', 'seller_phone', 'posted_date']
    for col in optional_cols:
        if col not in df.columns:
            df[col] = None
    
    print("💾 Writing to database...")
    df.to_sql('used_vehicles', engine, schema='raw', if_exists='replace', 
              index=False, method='multi', chunksize=1000)
    
    print(f"✅ Inserted {len(df)} rows into raw.used_vehicles")
    
    # Verify
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM raw.used_vehicles"))
        count = result.scalar()
        print(f"✅ Verified: {count} rows in database")
        
        # Show sample data
        result = conn.execute(text("SELECT id, title, brand, model, price FROM raw.used_vehicles LIMIT 3"))
        print("\n📝 Sample data:")
        for row in result:
            print(f"  ID: {row[0]}, Title: {row[1]}, Brand: {row[2]}, Model: {row[3]}, Price: {row[4]}")

def create_user_tables(engine):
    """Create user and interaction tables"""
    with engine.connect() as conn:
        print("👤 Creating gold.users table...")
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS gold.users (
                id VARCHAR PRIMARY KEY,
                email VARCHAR UNIQUE NOT NULL,
                hashed_password VARCHAR NOT NULL,
                full_name VARCHAR,
                phone VARCHAR,
                is_active BOOLEAN DEFAULT TRUE,
                is_verified BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        """))
        conn.commit()
        
        print("📊 Creating gold.user_interactions table...")
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS gold.user_interactions (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR NOT NULL,
                vehicle_id VARCHAR NOT NULL,
                interaction_type VARCHAR NOT NULL,
                session_id VARCHAR,
                interaction_score FLOAT DEFAULT 1.0,
                extra_data JSONB,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        """))
        conn.commit()
        
        print("✅ User tables created!")

if __name__ == "__main__":
    try:
        print("🚀 Starting database reset and data load...\n")
        
        # Reset database
        engine = reset_database()
        
        # Load CSV data
        load_csv_data(engine)
        
        # Create user tables
        create_user_tables(engine)
        
        print("\n✅ Database reset and data load complete!")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
