import unittest
from unittest.mock import AsyncMock, MagicMock, patch
from bot.main import bot
from model.model_handler import model_handler

class TestBot(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        # Mock the bot's user
        bot.user = MagicMock()
        bot.user.id = 12345
        bot.user.mentioned_in = MagicMock(return_value=True)
        
        # Initialize test knowledge
        model_handler.knowledge = {
            "greetings": {
                "hello": "Hi there!",
                "hi": "Hello!"
            }
        }

    async def test_known_response(self):
        # Test handling a known message
        message = AsyncMock()
        message.content = "hello"
        message.author = MagicMock()
        message.author.id = 54321  # Different from bot ID
        message.channel = AsyncMock()
        
        await bot.on_message(message)
        message.channel.send.assert_called_with("Hi there!")

    async def test_unknown_response(self):
        # Test handling an unknown message
        message = AsyncMock()
        message.content = "unknown phrase"
        message.author = MagicMock()
        message.author.id = 54321
        message.channel = AsyncMock()
        
        await bot.on_message(message)
        message.channel.send.assert_called_with("I'm not sure about that. What should I have said? (Reply with '!learn [response]')")

    async def test_learning(self):
        # Test the learn command
        ctx = AsyncMock()
        ctx.message = AsyncMock()
        ctx.message.reference = MagicMock()
        ctx.message.reference.message_id = 1
        ctx.channel = AsyncMock()
        
        # Mock the referenced message
        referenced_msg = AsyncMock()
        referenced_msg.content = "new phrase"
        ctx.channel.fetch_message.return_value = referenced_msg
        
        await bot.get_command('learn').callback(ctx, response="new response")
        self.assertEqual(model_handler.knowledge["responses"]["new phrase"], "new response")
        ctx.send.assert_called_with("✅ Learned new response for: 'new phrase'")

if __name__ == '__main__':
    unittest.main()