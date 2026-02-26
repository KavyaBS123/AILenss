
print("MAIN IMPORTED")
from fastapi import FastAPI
from .api.routes import api_router
from fastapi.responses import JSONResponse
from fastapi.requests import Request
from fastapi.exception_handlers import RequestValidationError
from fastapi.exceptions import RequestValidationError as FastAPIRequestValidationError
import traceback




# Ensure all models are imported so SQLModel metadata is populated
from .core.database import engine
from sqlmodel import SQLModel
from app import models  # This imports __init__.py, which imports all models

app = FastAPI(debug=True)
app.include_router(api_router)


# On startup: create all tables and print routes
@app.on_event("startup")
async def on_startup():
    print("\n--- RUNNING STARTUP HOOK ---")
    # Create all tables (including face_data)
    try:
        SQLModel.metadata.create_all(engine)
        print("[DB] Tables created or already exist.")
    except Exception as e:
        print(f"[DB ERROR] Table creation failed: {e}")
    print("--- REGISTERED ROUTES ---")
    for route in app.routes:
        print(f"{route.path} -> {route.name}")
    print("--- END ROUTES ---\n")

@app.get("/test-alive")
def test_alive():
    print("ALIVE ENDPOINT HIT")
    return {"status": "alive"}

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    print("\n--- GLOBAL EXCEPTION HANDLER ---\n")
    print(f"Exception: {exc}")
    print(traceback.format_exc())
    print("--- END GLOBAL EXCEPTION HANDLER ---\n")
    return JSONResponse(status_code=500, content={"detail": f"Internal Server Error: {exc}"})

@app.exception_handler(FastAPIRequestValidationError)
async def validation_exception_handler(request: Request, exc: FastAPIRequestValidationError):
    print("\n--- VALIDATION ERROR ---\n")
    print(f"Validation error: {exc}")
    print(traceback.format_exc())
    print("--- END VALIDATION ERROR ---\n")
    return JSONResponse(status_code=422, content={"detail": exc.errors(), "body": exc.body})

@app.get("/")
def read_root():
    return {"message": "Backend FastAPI is running!"}
