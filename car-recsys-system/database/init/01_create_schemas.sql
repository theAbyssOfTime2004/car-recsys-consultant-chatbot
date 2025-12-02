-- ==============================================================================
-- CAR RECOMMENDATION SYSTEM - DATABASE SCHEMA
-- ==============================================================================
-- Data Platform: RAW → SILVER → GOLD
-- ==============================================================================

-- Create schemas for data layers
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- ==============================================================================
-- RAW LAYER - Direct CSV ingestion (minimal transformation)
-- ==============================================================================

-- Raw: Used Vehicles
CREATE TABLE IF NOT EXISTS raw.used_vehicles (
    vehicle_id VARCHAR(100),
    stock_number VARCHAR(100),
    condition VARCHAR(50),
    title TEXT,
    brand VARCHAR(100),
    car_model VARCHAR(100),
    car_name VARCHAR(200),
    price NUMERIC,
    monthly_payment NUMERIC,
    mileage INTEGER,
    mileage_str VARCHAR(100),
    exterior_color VARCHAR(100),
    interior_color VARCHAR(100),
    drivetrain VARCHAR(100),
    mpg VARCHAR(100),
    fuel_type VARCHAR(100),
    transmission VARCHAR(100),
    engine VARCHAR(200),
    vin VARCHAR(100),
    accidents_damage TEXT,
    one_owner VARCHAR(50),
    personal_use_only VARCHAR(50),
    warranty TEXT,
    car_rating NUMERIC,
    percentage_recommend NUMERIC,
    comfort_rating NUMERIC,
    interior_rating NUMERIC,
    performance_rating NUMERIC,
    value_rating NUMERIC,
    exterior_rating NUMERIC,
    reliability_rating NUMERIC,
    vehicle_url TEXT,
    car_review_link TEXT,
    car_link TEXT,
    source_file TEXT,
    total_images INTEGER,
    has_ratings BOOLEAN,
    data_complete BOOLEAN,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: New Vehicles
CREATE TABLE IF NOT EXISTS raw.new_vehicles (
    vehicle_id VARCHAR(100),
    stock_number VARCHAR(100),
    condition VARCHAR(50),
    title TEXT,
    brand VARCHAR(100),
    car_model VARCHAR(100),
    car_name VARCHAR(200),
    price NUMERIC,
    monthly_payment NUMERIC,
    mileage INTEGER,
    mileage_str VARCHAR(100),
    exterior_color VARCHAR(100),
    interior_color VARCHAR(100),
    drivetrain VARCHAR(100),
    mpg VARCHAR(100),
    fuel_type VARCHAR(100),
    transmission VARCHAR(100),
    engine VARCHAR(200),
    vin VARCHAR(100),
    accidents_damage TEXT,
    one_owner VARCHAR(50),
    personal_use_only VARCHAR(50),
    warranty TEXT,
    car_rating NUMERIC,
    percentage_recommend NUMERIC,
    comfort_rating NUMERIC,
    interior_rating NUMERIC,
    performance_rating NUMERIC,
    value_rating NUMERIC,
    exterior_rating NUMERIC,
    reliability_rating NUMERIC,
    vehicle_url TEXT,
    car_review_link TEXT,
    car_link TEXT,
    source_file TEXT,
    total_images INTEGER,
    has_ratings BOOLEAN,
    data_complete BOOLEAN,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: Sellers
CREATE TABLE IF NOT EXISTS raw.sellers (
    seller_key VARCHAR(200),
    seller_name VARCHAR(300),
    seller_link TEXT,
    phone_new VARCHAR(50),
    phone_used VARCHAR(50),
    phone_service VARCHAR(50),
    destination TEXT,
    sales_hours TEXT,
    service_hours TEXT,
    hours_monday VARCHAR(100),
    hours_tuesday VARCHAR(100),
    hours_wednesday VARCHAR(100),
    hours_thursday VARCHAR(100),
    hours_friday VARCHAR(100),
    hours_saturday VARCHAR(100),
    hours_sunday VARCHAR(100),
    seller_rating NUMERIC,
    seller_rating_count INTEGER,
    description TEXT,
    total_images INTEGER,
    images_json JSONB,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: Vehicle Features
CREATE TABLE IF NOT EXISTS raw.vehicle_features (
    vehicle_id VARCHAR(100),
    condition VARCHAR(50),
    title TEXT,
    feature_category VARCHAR(200),
    feature_name TEXT,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: Reviews & Ratings
CREATE TABLE IF NOT EXISTS raw.reviews_ratings (
    vehicle_id VARCHAR(100),
    condition VARCHAR(50),
    car_model VARCHAR(100),
    car_name VARCHAR(200),
    title TEXT,
    overall_rating NUMERIC,
    review_time VARCHAR(100),
    user_name VARCHAR(200),
    user_location VARCHAR(200),
    review_text TEXT,
    comfort_rating NUMERIC,
    interior_rating NUMERIC,
    performance_rating NUMERIC,
    value_rating NUMERIC,
    exterior_rating NUMERIC,
    reliability_rating NUMERIC,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: Vehicle Images
CREATE TABLE IF NOT EXISTS raw.vehicle_images (
    vehicle_id VARCHAR(100),
    condition VARCHAR(50),
    title TEXT,
    image_order INTEGER,
    image_url TEXT,
    total_images INTEGER,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raw: Seller-Vehicle Relationships
CREATE TABLE IF NOT EXISTS raw.seller_vehicle_relationships (
    vehicle_id VARCHAR(100),
    seller_key VARCHAR(200),
    condition VARCHAR(50),
    title TEXT,
    seller_name VARCHAR(300),
    price NUMERIC,
    stock_number VARCHAR(100),
    vehicle_url TEXT,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- SILVER LAYER - Cleaned, typed, deduplicated data
-- ==============================================================================

-- Silver: Vehicles (Unified table for both used and new)
CREATE TABLE IF NOT EXISTS silver.vehicles (
    vehicle_id VARCHAR(100) PRIMARY KEY,
    condition VARCHAR(10) NOT NULL CHECK (condition IN ('used', 'new')),
    stock_number VARCHAR(100),
    title TEXT NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    full_name VARCHAR(200),
    
    -- Pricing
    price NUMERIC CHECK (price >= 0),
    monthly_payment NUMERIC CHECK (monthly_payment >= 0),
    
    -- Mileage (NULL for new vehicles)
    mileage INTEGER CHECK (mileage >= 0),
    
    -- Specifications
    exterior_color VARCHAR(100),
    interior_color VARCHAR(100),
    drivetrain VARCHAR(100),
    mpg VARCHAR(100),
    fuel_type VARCHAR(100),
    transmission VARCHAR(100),
    engine VARCHAR(200),
    vin VARCHAR(17),
    
    -- History (mostly for used vehicles)
    accidents_damage TEXT,
    one_owner BOOLEAN,
    personal_use_only BOOLEAN,
    warranty TEXT,
    
    -- Ratings
    car_rating NUMERIC CHECK (car_rating BETWEEN 0 AND 5),
    percentage_recommend NUMERIC CHECK (percentage_recommend BETWEEN 0 AND 100),
    comfort_rating NUMERIC CHECK (comfort_rating BETWEEN 0 AND 5),
    interior_rating NUMERIC CHECK (interior_rating BETWEEN 0 AND 5),
    performance_rating NUMERIC CHECK (performance_rating BETWEEN 0 AND 5),
    value_rating NUMERIC CHECK (value_rating BETWEEN 0 AND 5),
    exterior_rating NUMERIC CHECK (exterior_rating BETWEEN 0 AND 5),
    reliability_rating NUMERIC CHECK (reliability_rating BETWEEN 0 AND 5),
    
    -- Links
    vehicle_url TEXT,
    car_review_link TEXT,
    car_link TEXT,
    
    -- Metadata
    total_images INTEGER DEFAULT 0,
    has_ratings BOOLEAN DEFAULT FALSE,
    data_quality_score NUMERIC,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Silver: Sellers
CREATE TABLE IF NOT EXISTS silver.sellers (
    seller_key VARCHAR(200) PRIMARY KEY,
    seller_name VARCHAR(300) NOT NULL,
    seller_link TEXT,
    
    -- Contact
    phone_new VARCHAR(50),
    phone_used VARCHAR(50),
    phone_service VARCHAR(50),
    location TEXT,
    
    -- Hours (stored as JSONB for flexibility)
    business_hours JSONB,
    
    -- Ratings
    seller_rating NUMERIC CHECK (seller_rating BETWEEN 0 AND 5),
    seller_rating_count INTEGER DEFAULT 0,
    
    -- Description
    description TEXT,
    
    -- Images
    images JSONB,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Silver: Features
CREATE TABLE IF NOT EXISTS silver.features (
    id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(100) NOT NULL REFERENCES silver.vehicles(vehicle_id) ON DELETE CASCADE,
    category VARCHAR(200) NOT NULL,
    feature_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_silver_features_vehicle ON silver.features(vehicle_id);
CREATE INDEX idx_silver_features_category ON silver.features(category);

-- Silver: Images
CREATE TABLE IF NOT EXISTS silver.images (
    id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(100) NOT NULL REFERENCES silver.vehicles(vehicle_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vehicle_id, image_order)
);

CREATE INDEX idx_silver_images_vehicle ON silver.images(vehicle_id);

-- Silver: Reviews
CREATE TABLE IF NOT EXISTS silver.reviews (
    id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(100) REFERENCES silver.vehicles(vehicle_id) ON DELETE CASCADE,
    car_model VARCHAR(100),
    car_name VARCHAR(200),
    overall_rating NUMERIC CHECK (overall_rating BETWEEN 0 AND 5),
    review_time VARCHAR(100),
    user_name VARCHAR(200),
    user_location VARCHAR(200),
    review_text TEXT,
    comfort_rating NUMERIC,
    interior_rating NUMERIC,
    performance_rating NUMERIC,
    value_rating NUMERIC,
    exterior_rating NUMERIC,
    reliability_rating NUMERIC,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_silver_reviews_vehicle ON silver.reviews(vehicle_id);
CREATE INDEX idx_silver_reviews_car_model ON silver.reviews(car_model);

-- Silver: Inventory (Vehicle-Seller relationship)
CREATE TABLE IF NOT EXISTS silver.inventory (
    id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(100) NOT NULL REFERENCES silver.vehicles(vehicle_id) ON DELETE CASCADE,
    seller_key VARCHAR(200) NOT NULL REFERENCES silver.sellers(seller_key) ON DELETE CASCADE,
    price NUMERIC,
    stock_number VARCHAR(100),
    listed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vehicle_id, seller_key)
);

CREATE INDEX idx_silver_inventory_vehicle ON silver.inventory(vehicle_id);
CREATE INDEX idx_silver_inventory_seller ON silver.inventory(seller_key);

-- ==============================================================================
-- GOLD LAYER - Business-ready, optimized for serving
-- ==============================================================================

-- Gold: Listing Latest (Materialized view for fast queries)
CREATE TABLE IF NOT EXISTS gold.listing_latest (
    vehicle_id VARCHAR(100) PRIMARY KEY,
    condition VARCHAR(10) NOT NULL,
    title TEXT NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    full_name VARCHAR(200),
    
    -- Pricing
    price NUMERIC,
    monthly_payment NUMERIC,
    price_range VARCHAR(50), -- Computed: budget, mid-range, premium, luxury
    
    -- Specs
    mileage INTEGER,
    mileage_range VARCHAR(50), -- Computed: <30k, 30k-60k, 60k-100k, 100k+
    year INTEGER, -- Extracted from title/model
    exterior_color VARCHAR(100),
    interior_color VARCHAR(100),
    body_type VARCHAR(100), -- Computed from features/title: SUV, Sedan, Truck, etc
    drivetrain VARCHAR(100),
    fuel_type VARCHAR(100),
    transmission VARCHAR(100),
    engine VARCHAR(200),
    mpg_combined NUMERIC, -- Parsed from mpg string
    
    -- Quality indicators
    accidents_damage_clean BOOLEAN,
    one_owner BOOLEAN,
    warranty_available BOOLEAN,
    
    -- Aggregated ratings
    overall_rating NUMERIC,
    total_reviews INTEGER,
    percentage_recommend NUMERIC,
    
    -- Seller info
    seller_key VARCHAR(200),
    seller_name VARCHAR(300),
    seller_rating NUMERIC,
    seller_location TEXT,
    
    -- Media
    primary_image_url TEXT,
    total_images INTEGER,
    
    -- Features (top features as array for quick filter)
    key_features TEXT[],
    
    -- Search optimization
    search_text TSVECTOR, -- Full-text search vector
    popularity_score NUMERIC DEFAULT 0, -- For ranking
    
    -- URLs
    vehicle_url TEXT,
    
    -- Timestamps
    listed_at TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for gold.listing_latest (optimized for common queries)
CREATE INDEX idx_gold_listing_condition ON gold.listing_latest(condition);
CREATE INDEX idx_gold_listing_brand ON gold.listing_latest(brand);
CREATE INDEX idx_gold_listing_model ON gold.listing_latest(model);
CREATE INDEX idx_gold_listing_price ON gold.listing_latest(price);
CREATE INDEX idx_gold_listing_mileage ON gold.listing_latest(mileage);
CREATE INDEX idx_gold_listing_body_type ON gold.listing_latest(body_type);
CREATE INDEX idx_gold_listing_fuel_type ON gold.listing_latest(fuel_type);
CREATE INDEX idx_gold_listing_seller ON gold.listing_latest(seller_key);
CREATE INDEX idx_gold_listing_rating ON gold.listing_latest(overall_rating DESC);
CREATE INDEX idx_gold_listing_search ON gold.listing_latest USING GIN(search_text);

-- ==============================================================================
-- USER & INTERACTION TRACKING TABLES
-- ==============================================================================

-- Users table for authentication
CREATE TABLE IF NOT EXISTS gold.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE INDEX idx_users_email ON gold.users(email);

-- User preferences (for personalization)
CREATE TABLE IF NOT EXISTS gold.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES gold.users(user_id) ON DELETE CASCADE,
    preferred_brands TEXT[],
    budget_min NUMERIC,
    budget_max NUMERIC,
    preferred_body_types TEXT[],
    preferred_fuel_types TEXT[],
    max_mileage INTEGER,
    preferences_json JSONB, -- Additional flexible preferences
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User interactions (for recommendation engine)
CREATE TABLE IF NOT EXISTS gold.user_interactions (
    interaction_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES gold.users(user_id) ON DELETE CASCADE,
    session_id UUID NOT NULL,
    vehicle_id VARCHAR(100),
    interaction_type VARCHAR(50) NOT NULL, -- view, click, favorite, compare, inquiry, search
    interaction_data JSONB, -- Additional context (search query, filters, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interactions_user ON gold.user_interactions(user_id);
CREATE INDEX idx_interactions_vehicle ON gold.user_interactions(vehicle_id);
CREATE INDEX idx_interactions_type ON gold.user_interactions(interaction_type);
CREATE INDEX idx_interactions_created ON gold.user_interactions(created_at DESC);

-- User favorites/shortlist
CREATE TABLE IF NOT EXISTS gold.user_favorites (
    user_id UUID REFERENCES gold.users(user_id) ON DELETE CASCADE,
    vehicle_id VARCHAR(100) NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (user_id, vehicle_id)
);

CREATE INDEX idx_favorites_user ON gold.user_favorites(user_id);

-- Search history (for analytics & personalization)
CREATE TABLE IF NOT EXISTS gold.search_history (
    search_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES gold.users(user_id) ON DELETE CASCADE,
    session_id UUID NOT NULL,
    query TEXT,
    filters JSONB,
    results_count INTEGER,
    clicked_results VARCHAR(100)[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_history_user ON gold.search_history(user_id);
CREATE INDEX idx_search_history_created ON gold.search_history(created_at DESC);

-- ==============================================================================
-- DATA QUALITY TABLES
-- ==============================================================================

-- Data lineage tracking
CREATE TABLE IF NOT EXISTS gold.data_lineage (
    lineage_id SERIAL PRIMARY KEY,
    source_layer VARCHAR(50) NOT NULL,
    source_table VARCHAR(100) NOT NULL,
    target_layer VARCHAR(50) NOT NULL,
    target_table VARCHAR(100) NOT NULL,
    records_processed INTEGER,
    records_passed INTEGER,
    records_failed INTEGER,
    transformation_name VARCHAR(200),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time_ms INTEGER,
    status VARCHAR(50)
);

-- Data quality checks
CREATE TABLE IF NOT EXISTS gold.data_quality_checks (
    check_id SERIAL PRIMARY KEY,
    layer VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    check_name VARCHAR(200) NOT NULL,
    check_type VARCHAR(100), -- completeness, uniqueness, validity, consistency
    passed BOOLEAN,
    total_records INTEGER,
    failed_records INTEGER,
    failure_rate NUMERIC,
    details JSONB,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quality_checks_table ON gold.data_quality_checks(layer, table_name);
CREATE INDEX idx_quality_checks_checked ON gold.data_quality_checks(checked_at DESC);
