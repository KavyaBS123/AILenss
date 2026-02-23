# AILens Backend (FastAPI + Postgres)

Production-ready FastAPI backend following a clean, scalable structure with JWT auth, Google Sign-In verification, mocked phone OTP, Alembic migrations, and secure local storage (S3-ready design).

## Features

- FastAPI + SQLModel
- PostgreSQL (local or Docker)
- Alembic migrations
- Google ID token verification
- Mocked phone OTP (configurable code)
- JWT auth with OAuth2PasswordBearer
- Secure file storage (face_data, voice_data, temp)

## Project Structure

```
backend_fastapi/
├── app/
│   ├── api/              # Routes
│   ├── core/             # Settings, DB, security, storage
│   ├── crud/             # CRUD helpers
│   ├── models/           # SQLModel models
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Google auth, OTP service
├── migrations/           # Alembic migrations
├── Dockerfile
├── docker-compose.yml
├── alembic.ini
├── main.py
└── requirements.txt
```

## Setup (Local)

1) Create and activate virtualenv

```bash
python -m venv venv
venv\Scripts\activate
```

2) Install dependencies

```bash
pip install -r requirements.txt
```

3) Configure environment

```bash
copy .env.example .env
```

Fill in `DATABASE_URL`, `JWT_SECRET_KEY`, `GOOGLE_CLIENT_ID`.

4) Run migrations

```bash
alembic upgrade head
```

5) Start the server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 5000
```

## Setup (Docker)

```bash
docker compose up --build
```

## API Endpoints

- `POST /api/auth/google` - Google login (verify ID token)
- `POST /api/auth/phone/send-otp` - Send mocked OTP
- `POST /api/auth/phone/verify-otp` - Verify OTP and issue JWT
- `GET /api/users/me` - Current user (Bearer token)

## Notes

- OTP code is mocked using `OTP_CODE` in `.env`.
- Local storage is under `storage/` with `face_data/`, `voice_data/`, `temp/`.
- S3 migration is supported by swapping the storage service implementation.
