#!/bin/bash

# Install Python requirements
echo "=== INSTALLING PYTHON REQUIREMENTS ==="
pip install -r requirements.txt

# Download NLTK data
echo "=== DOWNLOADING NLTK DATA ==="
python -c "import nltk; nltk.download('punkt'); nltk.download('wordnet')"

# Create default config file
echo "=== CREATING DEFAULT CONFIG ==="
if [ ! -f "config.py" ]; then
    cat > config.py <<EOL
import os

# Discord Configuration
DISCORD_TOKEN = os.getenv('DISCORD_TOKEN', 'your-bot-token-here')

# Model Configuration
MODEL_PATH = "model/ai_model.pth"
KNOWLEDGE_FILE = "model/knowledge.json"
LEARNING_RATE = 0.1
MIN_CONFIDENCE = 0.6

# Bot Behavior
COMMAND_PREFIX = "!"
RATE_LIMIT = 3  # messages per second
EOL
    echo "Created config.py - remember to add your Discord token!"
else
    echo "config.py already exists - skipping creation"
fi

# Create empty knowledge base if it doesn't exist
if [ ! -f "model/knowledge.json" ]; then
    echo "=== INITIALIZING KNOWLEDGE BASE ==="
    mkdir -p model
    echo '{"greetings": {"hi": "Hello! How can I help you today?", "hello": "Hi there!"}}' > model/knowledge.json
fi

echo "=== SETUP COMPLETE ==="
echo "1. Edit config.py with your Discord token"
echo "2. Run the bot with: python bot/main.py"
echo "3. Train the model with: python model/train.py"