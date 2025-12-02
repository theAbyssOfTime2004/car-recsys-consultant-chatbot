# Car Recommendation System

A comprehensive car recommendation system with authentication, user behavior tracking, and hybrid recommendation engine.

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  Next.js    │─────▶│   FastAPI    │─────▶│ PostgreSQL  │
│  Frontend   │      │   Backend    │      │ (Raw/Silver │
│   (3000)    │      │   (8000)     │      │    /Gold)   │
└─────────────┘      │              │      └─────────────┘
                     │              │
                     │              │──────▶┌─────────────┐
                     │              │       │Elasticsearch│
                     │              │       │   (Search)  │
                     │              │       │   (9200)    │
                     │              │       └─────────────┘
                     │              │
                     │              │──────▶┌─────────────┐
                     │              │       │   Qdrant    │
                     │              │       │  (Vectors)  │
                     │              │       │   (6333)    │
                     │              │       └─────────────┘
                     │              │
                     └──────────────┘──────▶┌─────────────┐
                                            │    Redis    │
                                            │ (Cache/RL)  │
                                            │   (6379)    │
                                            └─────────────┘
```

## Features

### ✅ Frontend (Next.js)
- **E-commerce UI**: Homepage, search, detail, compare, favorites
- **Authentication**: Login/register with JWT
- **Responsive design**: Mobile, tablet, desktop
- **User tracking**: Views, clicks, favorites, comparisons
- **Recommendation UI**: Personalized suggestions with explanations

### ✅ Data Platform
- **3-layer architecture**: Raw → Silver → Gold
- **Schema design**: Normalized tables with proper relationships
- **Data lineage tracking**: Full audit trail
- **Data quality checks**: Automated validation and monitoring

### ✅ Search & Discovery
- **Full-text search**: Elasticsearch with facets and filters
- **Vector search**: Semantic search using embeddings (Qdrant)
- **Hybrid search**: Combines text + vector + user context

### ✅ Authentication & Tracking
- **JWT authentication**: Secure user sessions
- **User profiles**: Preferences and favorites
- **Interaction tracking**: Views, clicks, searches, favorites
- **Session management**: Anonymous + authenticated users

### ✅ Recommendation Engine
- **Content-based**: Feature similarity (price, brand, specs)
- **Collaborative**: User behavior patterns
- **Dense retrieval**: Embedding-based candidate generation
- **Cross-encoder reranking**: Top-K refinement with explanations
- **Hybrid scoring**: Weighted combination of multiple signals

## Quick Start

### Prerequisites
- Docker & Docker Compose
- 8GB+ RAM recommended
- CSV datasets in `datasets/` folder

### Installation

1. **Clone and setup**:
```bash
cd "Car Recsys Consultant Chatbot/car-recsys-system"
```

2. **Prepare datasets**:
```bash
# Copy your CSV files to datasets/ folder
cp ../datasets/*.csv ./datasets/
```

3. **Start services**:
```bash
docker-compose up -d
```

4. **Wait for services to be healthy**:
```bash
docker-compose ps
```

5. **Run ETL pipeline** (loads data into database):
```bash
docker-compose run etl-worker python -m app.pipeline.load_csv
docker-compose run etl-worker python -m app.pipeline.raw_to_silver
docker-compose run etl-worker python -m app.pipeline.silver_to_gold
```

6. **Sync to search & vector stores**:
```bash
docker-compose run etl-worker python -m app.pipeline.sync_elasticsearch
docker-compose run etl-worker python -m app.pipeline.sync_qdrant
```

7. **Access services**:
- **Frontend**: http://localhost:3000
- **API Documentation**: http://localhost:8000/docs
- **Elasticsearch**: http://localhost:9200
- **Qdrant Dashboard**: http://localhost:6333/dashboard

## Frontend Pages

### Public Pages
- **Homepage** (`/`): Hero, featured vehicles, categories, recommendations
- **Search** (`/search`): Advanced filters, grid view, pagination, sorting
- **Vehicle Detail** (`/vehicle/[id]`): Full specs, seller info, similar vehicles
- **Login** (`/login`): Email/password authentication
- **Register** (`/register`): New user registration

### Protected Pages (Require Login)
- **Favorites** (`/favorites`): Saved vehicles
- **Recommendations** (`/recommendations`): Personalized suggestions (hybrid & popular)
- **Compare** (`/compare`): Side-by-side comparison (up to 4 vehicles)

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `GET /auth/me` - Get current user profile

### Search & Discovery
- `GET /search` - Search vehicles with filters
- `GET /listing/{vehicle_id}` - Get vehicle details
- `POST /compare` - Compare multiple vehicles

### Recommendations
- `GET /reco/candidate` - Get recommendation candidates
- `GET /reco/hybrid` - Hybrid recommendations with explanations
- `GET /reco/similar/{vehicle_id}` - Similar vehicles

### User Interactions
- `POST /feedback` - Submit user interaction
- `GET /favorites` - Get user favorites
- `POST /favorites/{vehicle_id}` - Add to favorites
- `DELETE /favorites/{vehicle_id}` - Remove from favorites

## Project Structure

```
car-recsys-system/
├── docker-compose.yml           # Infrastructure setup
├── database/
│   └── init/
│       └── 01_create_schemas.sql # Database schema
├── backend/                     # FastAPI application
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py             # Application entry
│       ├── api/                # API endpoints
│       ├── core/               # Config, security
│       ├── models/             # Pydantic models
│       ├── services/           # Business logic
│       └── recommender/        # Recommendation engine
├── etl/                        # Data pipeline
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       └── pipeline/           # ETL jobs
└── datasets/                   # CSV data files
```

## Configuration

### Environment Variables

Create `.env` file:
```bash
# Database
DATABASE_URL=postgresql://admin:admin123@postgres:5432/car_recsys

# Search & Vector
ELASTICSEARCH_URL=http://elasticsearch:9200
QDRANT_URL=http://qdrant:6333

# Cache
REDIS_URL=redis://redis:6379

# Security
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Recommendation
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
RERANKER_MODEL=cross-encoder/ms-marco-MiniLM-L-6-v2
```

## Development

### Run tests
```bash
docker-compose run backend pytest
```

### Access logs
```bash
docker-compose logs -f backend
docker-compose logs -f etl-worker
```

### Database migrations
```bash
docker-compose exec postgres psql -U admin -d car_recsys
```

## Data Pipeline

### ETL Flow
1. **CSV → Raw**: Direct load from CSV files
2. **Raw → Silver**: Clean, deduplicate, type conversion
3. **Silver → Gold**: Business logic, computed fields
4. **Gold → Elasticsearch**: Search index sync
5. **Gold → Qdrant**: Vector embeddings sync

### Data Quality
- Completeness checks (missing values)
- Uniqueness checks (duplicates)
- Validity checks (data types, ranges)
- Consistency checks (referential integrity)

## Recommendation System

### Baseline (Rule-based + Content)
- Filter by budget range
- Match body type, fuel type
- Sort by ratings, price

### Dense Retrieval
- Encode vehicle descriptions to embeddings
- Find similar vehicles via cosine similarity
- Personalize with user preference embeddings

### Hybrid Approach
1. **Candidate Generation** (100-500 items):
   - Popular items (trending)
   - Content-based (features match)
   - Collaborative (similar users liked)
   - Dense retrieval (semantic search)

2. **Reranking** (Top 20):
   - Cross-encoder scoring
   - User behavior signals
   - Diversity optimization
   - Generate explanations

### Evaluation Metrics
- **Offline**: MRR@10, NDCG@10, Recall@50
- **Online**: CTR, Conversion rate, Session depth

## Monitoring & Observability

### Metrics
- Request latency (p50, p95, p99)
- QPS (queries per second)
- Cache hit rate
- Recommendation diversity

### Logs
- Structured JSON logs
- Request/response tracking
- Error tracking with stack traces

### Tracing
- Distributed tracing with correlation IDs
- Database query performance
- External API calls

## Production Checklist

- [ ] Change default passwords
- [ ] Use strong SECRET_KEY
- [ ] Enable HTTPS/SSL
- [ ] Setup backup strategy
- [ ] Configure log retention
- [ ] Setup monitoring alerts
- [ ] Rate limiting per user
- [ ] CORS configuration
- [ ] Database connection pooling
- [ ] Load testing

## License

MIT

## Support

For issues and questions, create an issue in the repository.
