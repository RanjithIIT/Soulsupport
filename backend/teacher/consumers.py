import json
from channels.generic.websocket import AsyncWebsocketConsumer

class TeacherParentChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # expect /ws/teacher-parent/<room_id>/
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.group_name = f'teacher_parent_{self.room_id}'

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        # Expect JSON: { "sender": "teacher" | "parent", "message": "..." }
        data = json.loads(text_data or '{}')
        await self.channel_layer.group_send(
            self.group_name,
            {
                'type': 'chat.message',
                'sender': data.get('sender'),
                'message': data.get('message'),
            },
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'sender': event['sender'],
            'message': event['message'],
        }))