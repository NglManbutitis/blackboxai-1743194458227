# AI Discord Bot

A customizable AI chatbot for Discord that learns from conversations.

## Features

- 🧠 Learns from user interactions
- 💬 Natural language understanding
- 🤖 Discord integration
- 📊 Learning statistics
- 🔄 Continuous improvement

## Setup

1. Install requirements:
```bash
chmod +x install.sh
./install.sh
```

2. Edit `config.py`:
```python
DISCORD_TOKEN = 'your-bot-token-here'  # Get from Discord Developer Portal
```

3. Run the bot:
```bash
python bot/main.py
```

## Usage

### Basic Interaction
- Mention the bot or DM it to chat
- The bot will respond based on its knowledge

### Teaching the Bot
Reply to a message with:
```
!learn [response]
```
Example:
```
User1: What's your favorite color?
User2: !learn I like blue and green
```

### Commands
- `!stats` - Show learning statistics
- `!train` - Retrain the AI model (admin only)

## Customization

### Knowledge Base
Edit `model/knowledge.json` to add predefined responses:
```json
{
  "greetings": {
    "hi": "Hello!",
    "hello": "Hi there!"
  },
  "questions": {
    "how are you": "I'm doing well, thanks for asking!"
  }
}
```

### Training
To manually retrain the model:
```bash
python model/train.py
```

## Requirements
- Python 3.8+
- Discord Bot Token
- 4GB+ RAM (for BERT model)

## Troubleshooting

**Bot not responding:**
- Check the bot has proper permissions
- Verify the token in config.py is correct
- Check logs for errors

**Learning issues:**
- Ensure you're replying with `!learn [response]`
- Check knowledge.json has proper formatting

## License
MIT