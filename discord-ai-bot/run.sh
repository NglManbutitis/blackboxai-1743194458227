#!/bin/bash

# Discord AI Bot Deployment Script
# Usage: ./run.sh [--train] [--api] [--bot]

# Configuration
API_PORT=8000
BOT_NAME="Discord AI Bot"
VENV_NAME="discord_bot_env"
REQUIREMENTS="requirements.txt"

# Functions
start_api() {
    echo "Starting API server on port $API_PORT..."
    cd api && uvicorn app:app --host 0.0.0.0 --port $API_PORT &
    API_PID=$!
    echo "API server started (PID: $API_PID)"
}

start_bot() {
    echo "Starting $BOT_NAME..."
    cd bot && python main.py &
    BOT_PID=$!
    echo "Bot started (PID: $BOT_PID)"
}

train_model() {
    echo "Training model..."
    cd model && python train.py
    echo "Model training complete"
}

cleanup() {
    echo "Stopping processes..."
    kill $API_PID $BOT_PID 2>/dev/null
    exit 0
}

# Main execution
trap cleanup SIGINT

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_NAME" ]; then
    echo "Creating virtual environment..."
    python -m venv $VENV_NAME
    source $VENV_NAME/bin/activate
    pip install --upgrade pip
    pip install -r $REQUIREMENTS
else
    source $VENV_NAME/bin/activate
fi

# Process arguments
if [ "$1" == "--train" ]; then
    train_model
    exit 0
fi

if [ "$1" == "--api" ]; then
    start_api
    wait $API_PID
    exit 0
fi

if [ "$1" == "--bot" ]; then
    start_bot
    wait $BOT_PID
    exit 0
fi

# Default: run both API and bot
start_api
start_bot

# Wait for both processes
wait $API_PID $BOT_PID