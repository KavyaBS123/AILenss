# Production Deployment & Environment Management

## Quick Start

### For Development

```bash
cd backend_fastapi
cp .env.example .env
# Edit .env with development values
python main.py
```

### For Staging

```bash
# Create staging environment file
cp .env.example .env.staging

# Edit with staging values
nano .env.staging

# Set environment variable to load this file
export ENV_FILE=.env.staging
python main.py
```

### For Production

```bash
# Create production environment file
cp .env.example .env.production

# Edit with secure production values
nano .env.production

# Deploy with production environment
export ENV_FILE=.env.production
gunicorn app:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

## Environment-Specific Configuration

### Development Environment

Create `.env` with development settings:

```env
# Development Configuration
ENVIRONMENT=development
PROJECT_NAME=AILens
DEBUG=true

# Database - Local SQLite
DATABASE_URL=sqlite:///./ailens.db

# Security - Temporary key (not used in production)
SECRET_KEY=dev-key-1234567890abcdefghijk-not-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# File Storage - Local directory
UPLOAD_DIR=./uploads
MAX_UPLOAD_SIZE_MB=50

# Biometric Settings
FACE_MIN_QUALITY_SCORE=0.8
VOICE_MIN_QUALITY_SCORE=0.75

# CORS - Allow all (development only!)
# Configured in app/core/config.py

# Logging - Debug level
LOG_LEVEL=debug
ENABLE_NETWORK_LOGS=true

# Feature Flags
ENABLE_GOOGLE_SIGNIN=false
```

### Staging Environment

Create `.env.staging`:

```env
# Staging Configuration
ENVIRONMENT=staging
PROJECT_NAME=AILens
DEBUG=false

# Database - PostgreSQL staging server
DATABASE_URL=postgresql://ailens_staging:safe_staging_password@staging-db.internal:5432/ailens_staging

# Security - Generated staging secret
SECRET_KEY=staging-key-use-secure-random-string-here-48-chars-min
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# File Storage - S3 staging bucket (or local with backup)
UPLOAD_DIR=/var/ailens/uploads-staging
MAX_UPLOAD_SIZE_MB=100

# Biometric Settings
FACE_MIN_QUALITY_SCORE=0.85
VOICE_MIN_QUALITY_SCORE=0.8

# AWS/S3 Configuration (optional)
AWS_ACCESS_KEY_ID=AKIA_STAGING_KEY_HERE
AWS_SECRET_ACCESS_KEY=staging_secret_key_here
AWS_REGION=us-east-1
S3_BUCKET=ailens-staging-biometrics

# Email Configuration (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=staging@ailens.com
SMTP_PASSWORD=staging_app_password
FROM_EMAIL=noreply-staging@ailens.com

# Google OAuth (staging/development app)
GOOGLE_CLIENT_ID=staging-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=staging_google_secret_here

# Logging - Info level
LOG_LEVEL=info
ENABLE_NETWORK_LOGS=true

# Feature Flags
ENABLE_GOOGLE_SIGNIN=true
```

### Production Environment

Create `.env.production`:

```env
# Production Configuration
ENVIRONMENT=production
PROJECT_NAME=AILens
DEBUG=false

# Database - PostgreSQL production server
DATABASE_URL=postgresql://ailens_prod:very_secure_production_password@prod-db.internal:5432/ailens_prod

# Security - MUST use strong random key generated securely
# Generate with: python -c "import secrets; print(secrets.token_urlsafe(48))"
SECRET_KEY=production-use-very-long-random-secure-key-generated-properly-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

# OTP Settings
OTP_EXPIRY_MINUTES=5
OTP_LENGTH=6

# File Storage - S3 production bucket
UPLOAD_DIR=/mnt/efs/ailens-uploads
MAX_UPLOAD_SIZE_MB=200

# Biometric Settings - Stricter requirements
FACE_MIN_QUALITY_SCORE=0.9
VOICE_MIN_QUALITY_SCORE=0.85

# AWS/S3 Configuration
AWS_ACCESS_KEY_ID=AKIA_PRODUCTION_KEY_HERE
AWS_SECRET_ACCESS_KEY=production_secret_key_with_minimum_permissions
AWS_REGION=us-east-1
S3_BUCKET=ailens-production-biometrics

# Email Configuration
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=production_sendgrid_api_key
FROM_EMAIL=noreply@ailens.com

# Google OAuth (production app)
GOOGLE_CLIENT_ID=production-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=production_google_secret_here

# Logging - Warning/Error only
LOG_LEVEL=warning
ENABLE_NETWORK_LOGS=false

# Feature Flags
ENABLE_GOOGLE_SIGNIN=true
ENABLE_FACE_RECOGNITION=true
ENABLE_VOICE_RECOGNITION=true
```

## Database Configuration by Environment

### Development - SQLite
```python
# .env
DATABASE_URL=sqlite:///./ailens.db
```

### Staging - PostgreSQL
```python
# .env.staging
DATABASE_URL=postgresql://ailens_staging:pwd@staging-db.example.com:5432/ailens_staging

# Connection Pool Configuration
# SQLALCHEMY_POOL_SIZE=10
# SQLALCHEMY_MAX_OVERFLOW=20
```

### Production - PostgreSQL with Replication
```python
# .env.production
# Primary database
DATABASE_URL=postgresql://ailens_prod:pwd@prod-db-primary.internal:5432/ailens_prod

# With read replica (for read operations)
DATABASE_READ_URL=postgresql://ailens_prod:pwd@prod-db-read.internal:5432/ailens_prod

# Connection Pool Configuration
# SQLALCHEMY_POOL_SIZE=20
# SQLALCHEMY_MAX_OVERFLOW=50
```

## Important Differences by Environment

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| Debug Mode | ✅ On | ❌ Off | ❌ Off |
| CORS Origins | `*` | Limited | Specific domains only |
| Database | SQLite | PostgreSQL | PostgreSQL HA |
| File Storage | Local | Local/S3 | S3 only |
| SSL/TLS | Optional | Recommended | Required |
| Log Level | DEBUG | INFO | WARNING |
| Rate Limiting | None | Soft | Strict |
| Monitoring | Basic | Comprehensive | Real-time |
| Backup Frequency | Manual | Daily | Hourly |
| Secret Rotation | Rare | Monthly | Quarterly |

## Setting Environment at Runtime

### Using Environment Variable

```bash
# Set which .env file to load
export ENV_FILE=.env.production

# Python code automatically loads correct file
python -c "
import os
from dotenv import load_dotenv
env_file = os.getenv('ENV_FILE', '.env')
load_dotenv(env_file)
"
```

### Using Python `.env` Loader

```python
# app/core/config.py
from pathlib import Path
from dotenv import load_dotenv
import os

# Determine environment
env = os.getenv('ENV', 'development')
env_file = Path(__file__).parent.parent.parent / f".env.{env}"

# Load appropriate .env file
if env_file.exists():
    load_dotenv(env_file)
else:
    load_dotenv('.env')
```

### Using Docker/Kubernetes

```dockerfile
# Dockerfile
FROM python:3.11

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Set environment
ARG ENV=development
ENV ENV=${ENV}
ENV ENV_FILE=.env.${ENV}

CMD ["python", "main.py"]
```

```bash
# Build for production
docker build --build-arg ENV=production -t ailens:latest .

# Run with environment
docker run -e ENV=production ailens:latest
```

## Security Checklist for Each Environment

### Development Checklist
- [ ] Using SQLite locally
- [ ] DEBUG=true for development
- [ ] Using test/demo credentials
- [ ] Basic security features enabled
- [ ] Logging detailed for debugging

### Staging Checklist
- [ ] Using PostgreSQL database
- [ ] DEBUG=false
- [ ] Using staging credentials
- [ ] All security features enabled
- [ ] Testing scenarios running
- [ ] Monitoring configured
- [ ] Backup configured

### Production Checklist
- [ ] Using PostgreSQL with HA/replication
- [ ] DEBUG=false
- [ ] Strong SECRET_KEY generated
- [ ] SSL/TLS enabled
- [ ] Database encryption enabled
- [ ] File backup strategy in place
- [ ] Monitoring and alerting active
- [ ] Log aggregation configured
- [ ] Rate limiting enabled
- [ ] CORS restricted to allowed domains
- [ ] Regular security audits scheduled
- [ ] Disaster recovery plan documented
- [ ] Incident response plan documented

## Deployment Procedure

### 1. Pre-Deployment

```bash
# Run tests
pytest tests/

# Check configuration
python -c "from app.core.config import settings; settings.logConfiguration()"

# Verify database connection
python -c "from app.core.database import engine; print('Database OK')"
```

### 2. Deployment

```bash
# Stop old server
sudo systemctl stop ailens

# Deploy new code
git pull origin main

# Install dependencies
pip install -r requirements.txt

# Run migrations (if any)
alembic upgrade head

# Start server
sudo systemctl start ailens

# Verify health check
curl http://localhost:5000/health

# Check logs
tail -f /var/log/ailens/app.log
```

### 3. Post-Deployment

```bash
# Verify endpoints
curl -X GET http://localhost:5000/api/health
curl -X POST http://localhost:5000/api/auth/register

# Monitor logs
grep "ERROR" /var/log/ailens/app.log

# Monitor metrics
# Check CPU, memory, database connections
```

## Monitoring & Maintenance

### Health Check Endpoint

```python
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "database": "connected"
    }
```

### Log Monitoring

```bash
# Development
tail -f backend_fastapi.log

# Production
tail -f /var/log/ailens/app.log | grep ERROR
```

### Database Maintenance

```sql
-- Check database size
SELECT pg_size_pretty(pg_database.datsize) 
FROM pg_database 
WHERE datname = 'ailens_prod';

-- Vacuum and analyze
VACUUM ANALYZE;

-- Check active connections
SELECT count(*) FROM pg_stat_activity;
```

## Rollback Procedure

If deployment fails:

```bash
# 1. Stop current server
sudo systemctl stop ailens

# 2. Checkout previous version
git checkout HEAD~1

# 3. Restore previous .env if needed
cp /backup/.env.previous .env

# 4. Start server
sudo systemctl start ailens

# 5. Verify
curl http://localhost:5000/health
```

## Useful Commands

```bash
# Load specific environment
source backend_fastapi/.env.production

# Test configuration
python -c "from app.core.config import settings; print(settings)"

# Generate secret key
python -c "import secrets; print(secrets.token_urlsafe(48))"

# Check Python version
python --version

# Verify requirements
pip list | grep -E "fastapi|uvicorn|sqlmodel"

# Run development server
python -m uvicorn main:app --reload --host 0.0.0.0 --port 5000

# Run production server
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:5000
```
