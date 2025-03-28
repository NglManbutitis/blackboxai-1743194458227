# Discord AI Bot with Custom NLP Model

A Discord bot with custom-trained NLP capabilities for English conversations.

## Features
- Custom-trained DistilBERT model for text understanding
- FastAPI server for model inference
- Discord bot interface with natural language responses
- Configurable settings for model and bot behavior

## Setup Instructions

### 1. Prerequisites
- Python 3.9+
- Discord Developer Account (for bot token)
- NVIDIA GPU (recommended for training)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/discord-ai-bot.git
cd discord-ai-bot

# Install dependencies
pip install -r requirements.txt
```

### 3. Configuration
1. Get your Discord bot token from [Discord Developer Portal](https://discord.com/developers/applications)
2. Create `.env` file in project root:
```env
DISCORD_TOKEN=your_bot_token_here
```

### 4. Training the Model
```bash
python model/train.py
```
Note: Replace the sample dataset in `train.py` with your custom data

### 5. Running the System
```bash
# Start the API server (in one terminal)
python api/app.py

# Start the Discord bot (in another terminal)
python bot/main.py
```

## Project Structure
```
discord-ai-bot/
├── bot/                # Discord bot components
│   ├── main.py         # Bot entry point
├── model/              # NLP model components
│   ├── train.py        # Model training script
│   └── checkpoints/    # Saved model weights
├── api/                # Model serving API
│   └── app.py          # FastAPI server
├── config/             # Configuration files
│   └── settings.py     # Main settings
└── requirements.txt    # Python dependencies
```

## Customization
- Edit `model/train.py` to use your own dataset
- Modify `bot/main.py` to change bot behavior
- Update `api/app.py` to change API endpoints

## Deployment
For production deployment:
1. Host the API server on AWS/GCP/Azure
2. Run the bot on a cloud VM or container
3. Set up monitoring with Prometheus/Grafana