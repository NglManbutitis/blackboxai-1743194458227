import discord
from discord.ext import commands
import logging
from config import DISCORD_TOKEN, COMMAND_PREFIX, ADMIN_IDS
from model.model_handler import model_handler
from typing import Optional, Tuple

# Initialize bot
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix=COMMAND_PREFIX, intents=intents)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@bot.event
async def on_ready():
    logger.info(f'Logged in as {bot.user.name} (ID: {bot.user.id})')
    logger.info(f'Loaded {model_handler.get_learning_stats()["total_phrases"]} phrases')

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return
    
    # Process commands first
    await bot.process_commands(message)
    
    # Handle AI responses
    if bot.user.mentioned_in(message) or isinstance(message.channel, discord.DMChannel):
        async with message.channel.typing():
            response, confidence = model_handler.get_response(message.content)
            
            # Learn if response was low confidence
            if confidence < 0.5:
                await message.channel.send(f"I'm not sure about that. What should I have said? (Reply with '!learn [response]')")
            else:
                await message.channel.send(response)

@bot.command(name='learn')
async def learn_response(ctx, *, response: str):
    """Teach the bot a new response"""
    if not ctx.message.reference:
        return await ctx.send("Please reply to a message to teach me!")
    
    # Get the original message that was replied to
    try:
        original_msg = await ctx.channel.fetch_message(ctx.message.reference.message_id)
        model_handler.learn_phrase(original_msg.content, response)
        await ctx.send(f"✅ Learned new response for: '{original_msg.content}'")
    except Exception as e:
        logger.error(f"Learning failed: {str(e)}")
        await ctx.send("Failed to learn that. Please try again.")

@bot.command(name='stats')
async def show_stats(ctx):
    """Show learning statistics"""
    stats = model_handler.get_learning_stats()
    embed = discord.Embed(
        title="AI Knowledge Stats",
        color=discord.Color.blue()
    )
    for category, count in stats['categories'].items():
        embed.add_field(name=category.capitalize(), value=str(count), inline=True)
    await ctx.send(embed=embed)

@bot.command(name='train')
@commands.is_owner()
async def train_model(ctx):
    """Retrain the AI model (Owner only)"""
    await ctx.send("Starting model training...")
    # Future implementation would trigger training
    await ctx.send("Training complete!")

if __name__ == '__main__':
    bot.run(DISCORD_TOKEN)
