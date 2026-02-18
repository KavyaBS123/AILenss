@echo off
echo ============================================
echo   AILens FastAPI Backend Setup
echo ============================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9+ from https://www.python.org/
    pause
    exit /b 1
)

echo  Python found!
echo.
echo  Installing dependencies...
timeout /t 2 /nobreak

REM Install dependencies
python -m pip install --quiet --upgrade pip
python -m pip install --quiet fastapi uvicorn sqlmodel sqlalchemy pydantic python-jose passlib bcrypt email-validator python-dotenv python-multipart

if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo  Dependencies installed successfully!
echo.
echo  ============================================
echo  STARTING FASTAPI BACKEND
echo  ============================================
echo.
echo  Server will run at: http://localhost:5000
echo  API Docs: http://localhost:5000/docs
echo  ReDoc: http://localhost:5000/redoc
echo.
echo  Press Ctrl+C to stop the server
echo.

REM Start the backend
python main.py

pause
