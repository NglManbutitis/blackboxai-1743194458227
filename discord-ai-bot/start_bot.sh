#!/bin/bash

# Install Python requirements
echo "=== INSTALLING PYTHON REQUIREMENTS ==="
pip install -r requirements.txt

# Download NLTK data
echo "=== DOWNLOADING NLTK DATA ==="
python -c "import nltk; nltk.download('punkt'); nltk.download('wordnet')"

# Start the Discord bot
echo "=== STARTING DISCORD BOT ==="
python bot/main.py