AILens Project
==============

A cross-platform AI-powered application with a FastAPI backend and a Flutter mobile frontend.

---

## Project Structure

```
AILens/
├── backend_fastapi/      # FastAPI backend (Python 3.11+)
│   ├── app/              # Main application code
│   │   ├── api/          # API route definitions
│   │   ├── core/         # Core settings, config, security
│   │   ├── crud/         # CRUD operations
│   │   ├── models/       # SQLModel ORM models
│   │   ├── schemas/      # Pydantic schemas
│   │   ├── services/     # Business logic/services
│   │   └── ...           # Other app modules
│   ├── migrations/       # Alembic migrations
│   ├── storage/          # Persistent storage (if any)
│   ├── uploads/          # File uploads
│   ├── tests/            # Backend tests
│   ├── main.py           # FastAPI entrypoint
│   ├── Dockerfile        # Backend Dockerfile
│   ├── .env              # Backend environment variables
│   └── ...
├── mobile_flutter/       # Flutter mobile app
│   ├── android/          # Android native code
│   ├── ios/              # iOS native code
│   ├── lib/              # Dart source code
│   ├── test/             # Flutter tests
│   ├── pubspec.yaml      # Flutter dependencies
│   ├── .env              # Mobile environment variables
│   └── ...
├── docker-compose.yml    # Multi-service orchestration
├── README.md             # Project documentation
└── ...
```

---

## Backend (FastAPI)
- **Language:** Python 3.11+
- **Framework:** FastAPI
- **Database:** PostgreSQL
- **ORM:** SQLModel
- **Migrations:** Alembic
- **Auth:** PyJWT
- **Config:** .env file
- **Containerization:** Docker

### Key Folders
- `app/api/`      — API endpoints
- `app/core/`     — Settings, config, security
- `app/crud/`     — CRUD logic
- `app/models/`   — Database models
- `app/schemas/`  — Pydantic schemas
- `app/services/` — Business logic
- `migrations/`   — Alembic migrations
- `uploads/`      — Uploaded files
- `tests/`        — Backend tests

### Running Backend
1. **Install dependencies:**
   ```sh
   cd backend_fastapi
   pip install -r requirements.txt
   ```
2. **Configure environment:**
   - Copy `.env.example` to `.env` and set values.
3. **Run server:**
   ```sh
   uvicorn main:app --reload
   ```
4. **API Docs:**
   - Swagger UI: [http://localhost:5000/api/docs](http://localhost:5000/api/docs)

---

## Mobile (Flutter)
- **Framework:** Flutter SDK 3.x
- **Languages:** Dart, Java/Kotlin (Android), Swift/ObjC (iOS)
- **Config:** .env file

### Key Folders
- `android/`   — Android native code
- `ios/`       — iOS native code
- `lib/`       — Dart source code
- `test/`      — Flutter tests

### Running Mobile App
1. **Install Flutter SDK:** [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Install dependencies:**
   ```sh
   cd mobile_flutter
   flutter pub get
   ```
3. **Configure environment:**
   - Copy `.env.example` to `.env` and set values.
4. **Run app:**
   ```sh
   flutter run
   ```

---

## Environment Variables
- **Backend:** `backend_fastapi/.env` (see `.env.example`)
- **Mobile:** `mobile_flutter/.env` (see `.env.example`)

---

## Docker & Orchestration
- Use `docker-compose.yml` to run backend and database together.
- Example:
  ```sh
  docker-compose up --build
  ```

---

## Contributing
1. Fork the repo
2. Create a feature branch
3. Commit and push changes
4. Open a pull request

---

## License
[MIT](LICENSE)

---

## Contact
- Maintainer: [Your Name/Email]
- Issues: [GitHub Issues](https://github.com/your-repo/issues)

--
Last updated: February 23, 2026
