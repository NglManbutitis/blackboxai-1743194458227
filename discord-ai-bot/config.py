import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Discord Configuration
DISCORD_TOKEN = os.getenv('DISCORD_TOKEN', 'your-bot-token-here')
COMMAND_PREFIX = os.getenv('COMMAND_PREFIX', '!')
ADMIN_IDS = [int(id) for id in os.getenv('ADMIN_IDS', '').split(',') if id]

# Model Configuration
MODEL_PATH = "model/ai_model.pth"
KNOWLEDGE_FILE = "model/knowledge.json"
LEARNING_RATE = float(os.getenv('LEARNING_RATE', '0.1'))
MIN_CONFIDENCE = float(os.getenv('MIN_CONFIDENCE', '0.6'))

# Learning Parameters
MAX_VOCAB_SIZE = 10000
MAX_SEQUENCE_LENGTH = 50
EMBEDDING_DIM = 256

# Bot Behavior
RATE_LIMIT = int(os.getenv('RATE_LIMIT', '3'))  # messages per second
TYPING_INDICATOR = bool(os.getenv('TYPING_INDICATOR', 'True'))

# File Paths
LOG_FILE = "logs/bot.log"
ERROR_LOG = "logs/errors.log"

# Create required directories if they don't exist
os.makedirs("model", exist_ok=True)
os.makedirs("logs", exist_ok=True)