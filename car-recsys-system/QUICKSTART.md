# 🚀 QUICKSTART - Chạy Hệ Thống Từ Đầu Đến Cuối

> **Mục tiêu**: Chạy được Frontend + Backend + Database trong 5 phút

---

## 📋 YÊU CẦU

- ✅ Docker & Docker Compose đã cài
- ✅ 8GB RAM trở lên
- ✅ Port 3000, 5432, 6333, 6379, 8000, 9200 chưa bị dùng

---

## ⚡ 5 BƯỚC CHẠY NGAY

### BƯỚC 1: Vào thư mục project
```bash
cd "/home/duc-nguyen16/Car Recsys Consultant Chatbot/car-recsys-system"
```

### BƯỚC 2: Copy dữ liệu CSV (nếu có)
```bash
cp ../datasets/*.csv ./datasets/
# Hoặc tạo thư mục nếu chưa có
mkdir -p datasets
```

### BƯỚC 3: Khởi động TẤT CẢ services
```bash
docker-compose up -d
```
⏳ **Đợi 30-60 giây** để các services khởi động

### BƯỚC 4: Kiểm tra status
```bash
docker-compose ps
```
**✅ Kết quả mong đợi**: Tất cả hiển thị "Up" hoặc "Up (healthy)"

### BƯỚC 5: Load dữ liệu vào database (nếu có CSV)
```bash
docker-compose exec etl-worker python -m app.pipeline.load_csv
```

---

## 🎯 TRUY CẬP HỆ THỐNG

### 🌐 Frontend (Giao diện chính)
```
http://localhost:3000
```
**Làm gì được:**
- ✅ Xem trang chủ, xe nổi bật
- ✅ Tìm kiếm xe với bộ lọc
- ✅ Xem chi tiết xe
- ✅ Đăng ký / Đăng nhập
- ✅ Yêu thích xe
- ✅ So sánh xe (tối đa 4 chiếc)
- ✅ Xem gợi ý cá nhân

### 📚 Backend API (Swagger UI)
```
http://localhost:8000/docs
```
**Test API:**
- Thử search: `GET /search?q=toyota`
- Đăng ký: `POST /auth/register`
- Login: `POST /auth/login`

### 🗄️ Database (PostgreSQL)
```bash
# Connect vào database
docker-compose exec postgres psql -U admin -d car_recsys

# Xem tables
\dt raw.*

# Đếm số xe
SELECT COUNT(*) FROM raw.used_vehicles;

# Thoát
\q
```

### 🔍 Services khác
- **Elasticsearch**: http://localhost:9200
- **Qdrant**: http://localhost:6333/dashboard
- **Redis**: localhost:6379

---

## 🔧 TROUBLESHOOTING

### ❌ Lỗi: Port đã được sử dụng
```bash
# Tìm process đang dùng port
sudo lsof -i :3000
sudo lsof -i :8000

# Kill process
kill -9 <PID>

# Hoặc thay đổi port trong docker-compose.yml
```

### ❌ Lỗi: Container không healthy
```bash
# Xem logs chi tiết
docker-compose logs backend
docker-compose logs frontend
docker-compose logs postgres

# Restart service
docker-compose restart backend
```

### ❌ Lỗi: Frontend không kết nối Backend
```bash
# 1. Kiểm tra backend chạy
curl http://localhost:8000/health

# 2. Kiểm tra network
docker network inspect car-recsys-network

# 3. Rebuild frontend
docker-compose up -d --build frontend
```

### ❌ Lỗi: Database trống
```bash
# Kiểm tra data
docker-compose exec postgres psql -U admin -d car_recsys \
  -c "SELECT COUNT(*) FROM raw.used_vehicles;"

# Nếu = 0, load lại data
docker-compose exec etl-worker python -m app.pipeline.load_csv
```

### ❌ Lỗi: Out of memory
```bash
# Tăng Docker memory limit
# Docker Desktop > Settings > Resources > Memory: 8GB+

# Hoặc restart Docker
sudo systemctl restart docker
```

---

## 🛠️ COMMANDS HỮU ÍCH

### Quản lý containers
```bash
# Xem status
docker-compose ps

# Xem logs (real-time)
docker-compose logs -f backend frontend

# Restart service
docker-compose restart backend

# Dừng tất cả
docker-compose down

# Dừng + xóa data (RESET hoàn toàn)
docker-compose down -v

# Rebuild image
docker-compose up -d --build backend
```

### Kiểm tra dữ liệu
```bash
# Connect PostgreSQL
docker-compose exec postgres psql -U admin -d car_recsys

# Queries hữu ích:
# Xem schemas
\dn

# Xem tables
\dt raw.*
\dt silver.*
\dt gold.*

# Đếm xe
SELECT COUNT(*) FROM raw.used_vehicles;

# Top brands
SELECT brand, COUNT(*) as count 
FROM raw.used_vehicles 
GROUP BY brand 
ORDER BY count DESC 
LIMIT 10;

# Xe mới nhất
SELECT title, brand, year, price 
FROM raw.used_vehicles 
ORDER BY year DESC 
LIMIT 10;

# Thoát
\q
```

### Backend Development
```bash
# Exec vào container
docker-compose exec backend bash

# Install package
docker-compose exec backend pip install package-name

# Restart để apply changes
docker-compose restart backend
```

### Frontend Development
```bash
# Exec vào container
docker-compose exec frontend sh

# Install package
docker-compose exec frontend npm install package-name

# Clear cache
docker-compose exec frontend rm -rf .next

# Rebuild
docker-compose up -d --build frontend
```

---

## 📋 CHECKLIST SAU KHI SETUP

- [ ] `docker-compose ps` hiển thị 7 containers "Up"
- [ ] Database có dữ liệu: `SELECT COUNT(*) FROM raw.used_vehicles;` > 0
- [ ] Backend response: `curl http://localhost:8000/health` → 200 OK
- [ ] Frontend hiển thị: http://localhost:3000 → Trang chủ load
- [ ] Đăng ký được user mới
- [ ] Search được xe
- [ ] Xem chi tiết xe được

---

## 🎓 WORKFLOW PHÁT TRIỂN

### Luồng dữ liệu
```
CSV Files
  ↓ load_csv.py
RAW Layer
  ↓ raw_to_silver.py
SILVER Layer
  ↓ silver_to_gold.py
GOLD Layer
  ↓
  ├→ sync_elasticsearch.py → Search API
  └→ sync_qdrant.py → Vector Search API
      ↓
  Backend API (FastAPI)
      ↓
  Frontend (Next.js)
      ↓
  User Browser
```

### Thêm feature Backend
```bash
# 1. Sửa code trong backend/app/
# 2. Tự động reload (uvicorn --reload)
# 3. Test: http://localhost:8000/docs
```

### Thêm feature Frontend  
```bash
# 1. Sửa code trong frontend/src/
# 2. Tự động reload (npm run dev)
# 3. Xem: http://localhost:3000
```

### Update database schema
```bash
# 1. Sửa: database/init/01_create_schemas.sql
# 2. Reset database:
docker-compose down -v
docker-compose up -d
# 3. Load lại data
```

---

## 💡 TIPS

### Performance
- Docker cần ít nhất 8GB RAM
- Elasticsearch cần ~2GB RAM
- Frontend build lần đầu mất 1-2 phút

### Development
- Backend & Frontend đều hot reload
- Không cần rebuild khi sửa code
- Chỉ rebuild khi thay đổi dependencies

### Next Steps
1. Implement ETL transformations (raw_to_silver, silver_to_gold)
2. Implement API business logic
3. Sync Elasticsearch & Qdrant
4. Build recommendation engine
5. Add more features

---

## 🆘 CẦN TRỢ GIÚP?

### Xem logs
```bash
# Tất cả
docker-compose logs

# Real-time
docker-compose logs -f backend frontend

# Service cụ thể
docker-compose logs backend
```

### Reset hoàn toàn
```bash
# Dừng và xóa tất cả
docker-compose down -v

# Xóa images
docker rmi $(docker images -q car-recsys*)

# Start lại từ đầu
docker-compose up -d
```

---

## ✅ HOÀN THÀNH!

**Bây giờ bạn có thể:**
1. 🌐 Mở http://localhost:3000 - Dùng giao diện
2. 📚 Mở http://localhost:8000/docs - Test API
3. 🔧 Bắt đầu phát triển features
4. 🎨 Customize UI theo ý thích

**Happy Coding! 🚀**
CSV Files
    ↓
RAW Layer (PostgreSQL)
    ↓ [Data Quality Checks]
SILVER Layer (Cleaned & Typed)
    ↓ [Business Logic]
GOLD Layer (Serving Ready)
    ↓
    ├──→ Elasticsearch (Search Index)
    └──→ Qdrant (Vector Store)
```

## 🔍 Test API với curl

### 1. Health Check
```bash
curl http://localhost:8000/health
```

### 2. Register User
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "full_name": "John Doe"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=password123"
```

Save the `access_token` from response.

### 4. Search Vehicles
```bash
# Anonymous search
curl "http://localhost:8000/api/v1/search?q=toyota&limit=10"

# Authenticated search (personalized)
curl "http://localhost:8000/api/v1/search?q=toyota&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 5. Get Recommendations
```bash
curl "http://localhost:8000/api/v1/reco/hybrid?limit=20" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🎯 Các Endpoint Chính

### Authentication (`/api/v1/auth`)
- `POST /register` - Đăng ký user mới
- `POST /login` - Đăng nhập
- `GET /me` - Thông tin user hiện tại

### Search & Discovery (`/api/v1`)
- `GET /search` - Tìm kiếm xe với filters
  - Query params: `q`, `brand`, `min_price`, `max_price`, `condition`, `body_type`, `fuel_type`
- `GET /listing/{vehicle_id}` - Chi tiết một xe
- `POST /compare` - So sánh nhiều xe

### Recommendations (`/api/v1/reco`)
- `GET /candidate` - Lấy candidates (baseline)
- `GET /hybrid` - Hybrid recommendations (advanced)
- `GET /similar/{vehicle_id}` - Xe tương tự

### User Interactions (`/api/v1`)
- `POST /feedback` - Ghi lại interaction (view, click, favorite)
- `GET /favorites` - Danh sách yêu thích
- `POST /favorites/{vehicle_id}` - Thêm vào favorites
- `DELETE /favorites/{vehicle_id}` - Xóa khỏi favorites

## 📈 Monitoring

### Xem logs real-time
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f elasticsearch
```

### Access database
```bash
docker-compose exec postgres psql -U admin -d car_recsys

# Example queries
SELECT count(*) FROM gold.listing_latest;
SELECT * FROM gold.users LIMIT 5;
SELECT * FROM gold.user_interactions ORDER BY created_at DESC LIMIT 10;
```

### Check Elasticsearch
```bash
# Cluster health
curl http://localhost:9200/_cluster/health?pretty

# List indices
curl http://localhost:9200/_cat/indices?v

# Search vehicles
curl -X POST http://localhost:9200/vehicles/_search?pretty \
  -H "Content-Type: application/json" \
  -d '{"query": {"match": {"title": "toyota"}}}'
```

### Check Qdrant
```bash
# Collections
curl http://localhost:6333/collections

# Collection info
curl http://localhost:6333/collections/vehicles
```

## 🛠️ Development

### Rebuild services sau khi thay đổi code
```bash
# Rebuild specific service
docker-compose up -d --build backend

# Rebuild all
docker-compose up -d --build
```

### Run tests
```bash
docker-compose run --rm backend pytest
```

### Interactive Python shell với database access
```bash
docker-compose exec backend python

# In Python shell:
from app.core.database import SessionLocal
db = SessionLocal()
# Run queries...
```

## 🐛 Troubleshooting

### Services không start
```bash
# Xem logs chi tiết
docker-compose logs backend
docker-compose logs postgres

# Restart services
docker-compose restart
```

### Database connection errors
```bash
# Check Postgres is running
docker-compose ps postgres

# Check database exists
docker-compose exec postgres psql -U admin -l
```

### Out of memory
```bash
# Increase Docker memory limit (Docker Desktop settings)
# Or reduce Elasticsearch heap size in docker-compose.yml
```

### Port conflicts
```bash
# Check ports
lsof -i :5432  # PostgreSQL
lsof -i :9200  # Elasticsearch
lsof -i :8000  # FastAPI

# Change ports in docker-compose.yml if needed
```

## 🔧 Configuration

Tạo file `.env` để override settings:

```bash
# Database
DATABASE_URL=postgresql://admin:admin123@postgres:5432/car_recsys

# Search & Vector
ELASTICSEARCH_URL=http://elasticsearch:9200
QDRANT_URL=http://qdrant:6333

# Cache
REDIS_URL=redis://redis:6379

# Security (CHANGE THESE IN PRODUCTION!)
SECRET_KEY=your-very-secret-key-change-me
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# ML Models
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
RERANKER_MODEL=cross-encoder/ms-marco-MiniLM-L-6-v2
```

## 📚 Next Steps

1. **Frontend Development**
   - Build React/Next.js UI
   - Connect to API endpoints
   - Implement user authentication flow

2. **ML Model Training**
   - Collect user interaction data
   - Train personalized models
   - A/B test different recommendation strategies

3. **Production Deployment**
   - Setup CI/CD pipeline
   - Configure monitoring & alerting
   - Implement backup strategy
   - Setup load balancing

4. **Feature Enhancements**
   - Real-time recommendations
   - Chatbot integration
   - Email notifications
   - Advanced filters

## 📞 Support

Có vấn đề? Tạo issue hoặc liên hệ support team.
