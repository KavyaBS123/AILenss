#!/bin/bash
# AILens FastAPI Backend Setup Script for macOS/Linux

echo "============================================"
echo "  AILens FastAPI Backend Setup"
echo "============================================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3.9+ from https://www.python.org/"
    exit 1
fi

echo "✓ Python found!"
echo
echo "📦 Installing dependencies..."
sleep 2

# Install dependencies
python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet fastapi uvicorn sqlmodel sqlalchemy pydantic python-jose passlib bcrypt email-validator python-dotenv python-multipart

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi

echo
echo "✓ Dependencies installed successfully!"
echo
echo "============================================"
echo "  STARTING FASTAPI BACKEND"
echo "============================================"
echo
echo "Server will run at: http://localhost:5000"
echo "API Docs: http://localhost:5000/docs"
echo "ReDoc: http://localhost:5000/redoc"
echo
echo "Press Ctrl+C to stop the server"
echo

# Start the backend
python3 main.py
