# AILens FastAPI Backend

A modern, secure FastAPI backend for the AILens biometric protection app.

## Features

✅ **FastAPI** - Modern Python web framework  
✅ **SQLModel** - Python SQL database ORM with type hints  
✅ **SQLite** - Lightweight database (SQLAlchemy for production)  
✅ **JWT Authentication** - Secure token-based auth  
✅ **OTP Verification** - Two-factor authentication  
✅ **CORS** - Cross-Origin Resource Sharing configured  
✅ **Password Hashing** - Bcrypt for secure passwords  
✅ **Automatic API Docs** - Swagger UI at /docs  

## Installation

### 1. Create a Virtual Environment

```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Generate Secret Key

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Update the `SECRET_KEY` in `.env` file with the generated key.

### 4. Run the Backend

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 5000
```

The backend will be available at: **http://localhost:5000**

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user (generates OTP)
- `POST /api/auth/verify-otp` - Verify OTP (returns JWT token)
- `GET /api/auth/me` - Get current user (requires token)
- `POST /api/auth/logout` - Logout user

### Health Check

- `GET /health` - Backend health check
- `GET /` - API information

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:5000/docs
- **ReDoc**: http://localhost:5000/redoc

## Database

The backend uses SQLite by default for development:
- Database file: `ailens.db`
- Automatically created on first run

To use PostgreSQL in production, update `.env`:
```
DATABASE_URL=postgresql://user:password@localhost/ailens
```

## Demo User

For testing, create an account with demo credentials:

```
Email: test@ailens.app
Password: TestPassword123!
```

## Environment Variables

See `.env` file for configuration:

```
ENVIRONMENT=development
PROJECT_NAME=AILens
DATABASE_URL=sqlite:///./ailens.db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
CORS_ORIGINS=["http://localhost:3000","*"]
```

## Project Structure

```
backend_fastapi/
├── app/
│   ├── api/
│   │   ├── auth.py          # Authentication routes
│   │   └── routes.py        # API router
│   ├── core/
│   │   ├── config.py        # Settings
│   │   ├── security.py      # JWT, password hashing
│   │   └── database.py      # Database setup
│   ├── models/
│   │   └── user.py          # User model
│   ├── schemas/
│   │   └── user.py          # Pydantic schemas
│   └── __init__.py
├── main.py                  # FastAPI app entry point
├── requirements.txt         # Dependencies
├── .env                     # Environment variables
└── README.md               # This file
```

## Connecting Flutter App

Update your Flutter app's API endpoint in `.env`:

```
API_BASE_URL=http://10.0.2.2:5000/api
```

*(Use `10.0.2.2` for Android emulator, `localhost` for iOS)*

## Troubleshooting

### Port 5000 already in use

```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :5000
kill -9 <PID>
```

### Database errors

```bash
# Remove the database file and restart
rm ailens.db
```

### Import errors

Make sure you're in the project root directory when running:
```bash
cd backend_fastapi
uvicorn main:app --reload
```

## License

MIT License
