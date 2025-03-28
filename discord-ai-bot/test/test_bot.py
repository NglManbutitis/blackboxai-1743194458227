import unittest
from unittest.mock import AsyncMock, patch
from bot.main import AIResponseHandler
import aiohttp
import json

class TestAIResponseHandler(unittest.IsolatedAsyncioTestCase):
    async def test_successful_response(self):
        handler = AIResponseHandler()
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json.return_value = {"response": "Test response"}
        
        with patch('aiohttp.ClientSession.post', return_value=mock_response):
            response = await handler.get_ai_response("test message")
            self.assertEqual(response, "Test response")

    async def test_failed_response(self):
        handler = AIResponseHandler()
        mock_response = AsyncMock()
        mock_response.status = 500
        
        with patch('aiohttp.ClientSession.post', return_value=mock_response):
            response = await handler.get_ai_response("test message")
            self.assertIsNone(response)

    async def test_timeout_error(self):
        handler = AIResponseHandler()
        
        with patch('aiohttp.ClientSession.post', side_effect=asyncio.TimeoutError):
            response = await handler.get_ai_response("test message")
            self.assertIsNone(response)

class TestBotIntegration(unittest.IsolatedAsyncioTestCase):
    @patch('bot.main.AIResponseHandler.get_ai_response')
    async def test_bot_mention(self, mock_get_response):
        mock_get_response.return_value = "Mocked response"
        
        # Setup test bot and message
        bot = commands.Bot(command_prefix='!')
        message = AsyncMock()
        message.author = bot.user
        message.content = "@bot hello"
        message.channel.type = discord.ChannelType.text
        bot.user.mentioned_in = lambda msg: True
        
        await bot.on_message(message)
        message.channel.send.assert_called_with("Mocked response")

if __name__ == '__main__':
    unittest.main()