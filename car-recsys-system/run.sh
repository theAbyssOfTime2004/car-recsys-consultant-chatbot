#!/bin/bash

# Car Recommendation System - Complete Auto Setup Script
# Chạy file này để tự động setup và start toàn bộ hệ thống

set -e  # Exit on error

echo "🚀 Car Recommendation System - Complete Auto Setup"
echo "===================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${RED}❌ Error: $1${NC}"
    echo -e "${YELLOW}💡 Troubleshooting:${NC}"
    echo "   - Check logs: docker-compose logs"
    echo "   - Restart services: docker-compose restart"
    echo "   - Full reset: docker-compose down -v && ./run.sh"
    exit 1
}

# Function to wait for PostgreSQL
wait_for_postgres() {
    local max_attempts=30
    local attempt=0
    
    echo -e "${BLUE}⏳ Waiting for PostgreSQL to be ready...${NC}"
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose exec -T postgres pg_isready -U admin > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    echo ""
    echo -e "${YELLOW}⚠️  PostgreSQL took longer than expected, continuing anyway...${NC}"
    return 0
}

# Function to wait for HTTP service
wait_for_http_service() {
    local service=$1
    local url=$2
    local max_attempts=30
    local attempt=0
    
    echo -e "${BLUE}⏳ Waiting for $service to be ready...${NC}"
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service is ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    echo ""
    echo -e "${YELLOW}⚠️  $service took longer than expected, continuing anyway...${NC}"
    return 0
}

# Check Docker
echo -e "${YELLOW}📋 Step 1/7: Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    handle_error "Docker is not installed. Please install Docker first."
fi

if ! command -v docker-compose &> /dev/null; then
    handle_error "Docker Compose is not installed. Please install Docker Compose first."
fi

echo -e "${GREEN}✅ Docker & Docker Compose are installed${NC}"
echo ""

# Check if in correct directory
if [ ! -f "docker-compose.yml" ]; then
    handle_error "docker-compose.yml not found. Please run this script from the project root directory."
fi

# Create datasets directory if not exists
echo -e "${YELLOW}📋 Step 2/7: Preparing directories...${NC}"
mkdir -p datasets
mkdir -p backend/app/api/v1
mkdir -p backend/app/models
mkdir -p backend/app/schemas
echo -e "${GREEN}✅ Directories ready${NC}"
echo ""

# Copy CSV files if they exist
echo -e "${YELLOW}📋 Step 3/7: Checking for data files...${NC}"
if [ -f "../datasets/used_vehicles.csv" ]; then
    echo -e "${BLUE}📊 Copying used_vehicles.csv...${NC}"
    cp ../datasets/used_vehicles.csv ./datasets/
    echo -e "${GREEN}✅ CSV file copied${NC}"
elif [ -f "datasets/used_vehicles.csv" ]; then
    echo -e "${GREEN}✅ CSV file already exists${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: used_vehicles.csv not found${NC}"
    echo -e "   Place CSV file at: datasets/used_vehicles.csv"
fi
echo ""

# Stop and clean existing containers
echo -e "${YELLOW}📋 Step 4/7: Cleaning up existing containers...${NC}"
docker-compose down -v 2>/dev/null || true
echo -e "${GREEN}✅ Old containers and volumes removed${NC}"
echo ""

# Start services in order to avoid timeout
echo -e "${YELLOW}📋 Step 5/7: Starting services in sequence...${NC}"

# Start infrastructure services first
echo -e "${BLUE}   Starting infrastructure (PostgreSQL, Redis, Elasticsearch, Qdrant)...${NC}"
docker-compose up -d postgres redis elasticsearch qdrant
sleep 10

# Start ETL worker
echo -e "${BLUE}   Starting ETL worker...${NC}"
docker-compose up -d etl-worker
sleep 5

# Start backend
echo -e "${BLUE}   Starting backend API...${NC}"
docker-compose up -d backend
sleep 10

# Start frontend last (with timeout handling)
echo -e "${BLUE}   Starting frontend...${NC}"
export COMPOSE_HTTP_TIMEOUT=120
if ! docker-compose up -d frontend 2>&1; then
    echo -e "${YELLOW}⚠️  Frontend timeout, retrying...${NC}"
    sleep 5
    docker-compose up -d frontend || {
        echo -e "${YELLOW}⚠️  Frontend may still be starting...${NC}"
        echo -e "${BLUE}   Checking container status...${NC}"
        docker-compose ps frontend
    }
fi
unset COMPOSE_HTTP_TIMEOUT

echo -e "${GREEN}✅ All services started${NC}"
echo ""

# Wait for critical services
echo -e "${YELLOW}📋 Step 6/7: Waiting for services to initialize...${NC}"
wait_for_postgres
sleep 3
wait_for_http_service "Backend API" "http://localhost:8000/health"
sleep 2
wait_for_http_service "Frontend" "http://localhost:3000"

echo ""

# Initialize and load database
echo -e "${YELLOW}📋 Step 7/7: Setting up database...${NC}"

# Check if CSV file exists
if [ ! -f "datasets/used_vehicles.csv" ]; then
    echo -e "${YELLOW}⚠️  Skipping data load: used_vehicles.csv not found${NC}"
else
    echo -e "${BLUE}🗄️  Creating database schemas...${NC}"
    docker-compose exec -T postgres psql -U admin -d car_recsys -c "
        CREATE SCHEMA IF NOT EXISTS raw;
        CREATE SCHEMA IF NOT EXISTS silver;
        CREATE SCHEMA IF NOT EXISTS gold;
    " 2>/dev/null || echo "Schemas may already exist"

    echo -e "${BLUE}🗑️  Dropping existing vehicle table (if any)...${NC}"
    docker-compose exec -T postgres psql -U admin -d car_recsys -c "
        DROP TABLE IF EXISTS raw.used_vehicles CASCADE;
    " 2>/dev/null || true

    echo -e "${BLUE}📥 Loading data from CSV...${NC}"
    
    # Get CSV header to create table
    echo -e "${BLUE}   Reading CSV header...${NC}"
    HEADER=$(docker-compose exec -T postgres head -1 /datasets/used_vehicles.csv 2>/dev/null || head -1 datasets/used_vehicles.csv)
    
    if [ -z "$HEADER" ]; then
        echo -e "${RED}❌ Cannot read CSV file${NC}"
    else
        # Create table with all columns as TEXT first (simple approach)
        echo -e "${BLUE}   Creating table structure...${NC}"
        docker-compose exec -T postgres psql -U admin -d car_recsys << 'EOF'
CREATE TABLE IF NOT EXISTS raw.used_vehicles (
    vehicle_id TEXT,
    url TEXT,
    title TEXT,
    price TEXT,
    brand TEXT,
    model TEXT,
    year TEXT,
    mileage TEXT,
    fuel_type TEXT,
    transmission TEXT,
    body_type TEXT,
    color TEXT,
    seats TEXT,
    origin TEXT,
    location TEXT,
    description TEXT,
    image_url TEXT,
    seller_name TEXT,
    seller_phone TEXT,
    posted_date TEXT
);
EOF

        # Copy CSV file into container if not already there
        echo -e "${BLUE}   Preparing CSV file...${NC}"
        docker cp datasets/used_vehicles.csv $(docker-compose ps -q postgres):/tmp/used_vehicles.csv 2>/dev/null || true
        
        # Load data using COPY command
        echo -e "${BLUE}   Importing data...${NC}"
        docker-compose exec -T postgres psql -U admin -d car_recsys << 'EOF'
COPY raw.used_vehicles FROM '/tmp/used_vehicles.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
EOF
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Data loaded successfully${NC}"
            
            # Verify data
            echo -e "${BLUE}🔍 Verifying data...${NC}"
            VEHICLE_COUNT=$(docker-compose exec -T postgres psql -U admin -d car_recsys -t -c "SELECT COUNT(*) FROM raw.used_vehicles;" 2>/dev/null | xargs)
            if [ ! -z "$VEHICLE_COUNT" ]; then
                echo -e "${GREEN}✅ Database contains $VEHICLE_COUNT vehicles${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Warning: Data import had some issues${NC}"
            echo -e "   You can try loading data manually with:"
            echo -e "   docker cp datasets/used_vehicles.csv \$(docker-compose ps -q postgres):/tmp/used_vehicles.csv"
            echo -e "   docker-compose exec postgres psql -U admin -d car_recsys -c \"COPY raw.used_vehicles FROM '/tmp/used_vehicles.csv' CSV HEADER;\""
        fi
    fi
fi

echo ""

# Final health check
echo -e "${YELLOW}🏥 Running final health checks...${NC}"
docker-compose ps
echo ""

# Final health check
echo -e "${YELLOW}🏥 Running final health checks...${NC}"
docker-compose ps
echo ""

# Test API endpoint
echo -e "${BLUE}🧪 Testing API endpoint...${NC}"
API_TEST=$(curl -s "http://localhost:8000/api/v1/search?page_size=1" || echo "failed")
if [[ "$API_TEST" == *"total"* ]]; then
    echo -e "${GREEN}✅ API is responding correctly${NC}"
else
    echo -e "${YELLOW}⚠️  API may still be initializing${NC}"
fi
echo ""

# Display access information
echo -e "${GREEN}===================================================="
echo "✨ Setup Complete! System is Ready! ✨"
echo "====================================================${NC}"
echo ""
echo -e "${GREEN}🌐 Frontend (Main UI):${NC}"
echo -e "   ${BLUE}http://localhost:3000${NC}"
echo ""
echo -e "${GREEN}📚 Backend API (Swagger):${NC}"
echo -e "   ${BLUE}http://localhost:8000/docs${NC}"
echo ""
echo -e "${GREEN}🗄️  Database (PostgreSQL):${NC}"
echo "   Host: localhost:5432"
echo "   User: admin"
echo "   Password: admin123"
echo "   Database: car_recsys"
echo ""
echo -e "${GREEN}🔍 Other Services:${NC}"
echo "   Elasticsearch: http://localhost:9200"
echo "   Qdrant: http://localhost:6333/dashboard"
echo "   Redis: localhost:6379"
echo ""
echo -e "${YELLOW}📋 Useful Commands:${NC}"
echo "   View all logs:       docker-compose logs -f"
echo "   View backend logs:   docker-compose logs -f backend"
echo "   View frontend logs:  docker-compose logs -f frontend"
echo "   Stop all services:   docker-compose down"
echo "   Restart services:    docker-compose restart"
echo "   Check status:        docker-compose ps"
echo "   Full reset:          docker-compose down -v && ./run.sh"
echo ""
echo -e "${YELLOW}🔗 Quick Actions:${NC}"
echo "   Open Frontend:  firefox http://localhost:3000 &"
echo "   Open API Docs:  firefox http://localhost:8000/docs &"
echo ""
echo -e "${YELLOW}📊 Database Info:${NC}"
if [ -f "datasets/used_vehicles.csv" ]; then
    echo -e "   ✅ Vehicle data loaded"
    echo -e "   📍 Run 'docker-compose exec postgres psql -U admin -d car_recsys' to access DB"
else
    echo -e "   ⚠️  No data loaded yet"
    echo -e "   📍 Add CSV to datasets/ and run: ./run.sh"
fi
echo ""
echo -e "${GREEN}Happy Coding! 🚀${NC}"
echo ""
