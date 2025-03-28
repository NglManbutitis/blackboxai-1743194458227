import discord
from discord.ext import commands
import aiohttp
import logging
import json
from config import settings
from typing import Optional

# Initialize bot
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class AIResponseHandler:
    def __init__(self):
        self.session = aiohttp.ClientSession()
        self.api_url = settings.MODEL_API_URL
        self.timeout = settings.API_TIMEOUT
        
    async def get_ai_response(self, text: str) -> Optional[str]:
        try:
            payload = {
                "text": text,
                "user_id": "discord_user"
            }
            async with self.session.post(
                self.api_url,
                json=payload,
                timeout=self.timeout
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    return data.get('response')
                logger.error(f"API error: {response.status}")
        except Exception as e:
            logger.error(f"Request failed: {str(e)}")
        return None

@bot.event
async def on_ready():
    logger.info(f'Logged in as {bot.user.name}')
    bot.ai_handler = AIResponseHandler()

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return
    
    # Process commands first
    await bot.process_commands(message)
    
    # Get AI response for non-command messages
    if bot.user.mentioned_in(message) or message.channel.type == discord.ChannelType.private:
        response = await bot.ai_handler.get_ai_response(message.content)
        if response:
            await message.channel.send(response)
        else:
            await message.channel.send("I'm having trouble understanding. Could you rephrase that?")

@bot.command(name='train')
@commands.is_owner()
async def train_model(ctx):
    """Trigger model retraining (owner only)"""
    await ctx.send("Starting model training...")
    # Implementation would call your training API
    await ctx.send("Training complete!")

if __name__ == '__main__':
    bot.run(settings.DISCORD_TOKEN)
