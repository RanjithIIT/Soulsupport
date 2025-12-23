import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from student_parent.models import Communication

User = get_user_model()

class TeacherStudentChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract room_id from URL
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        
        # Determine chat_type from URL path
        url_path = self.scope.get('path', '')
        if 'teacher-student' in url_path:
            chat_type = 'teacher-student'
        elif 'teacher-parent' in url_path:
            chat_type = 'teacher-parent'
        else:
            chat_type = 'teacher-student'  # default
        
        self.group_name = f'{chat_type}_{self.room_id}'
        
        # Get authenticated user
        self.user = self.scope.get('user')
        
        if not self.user or not self.user.is_authenticated:
            await self.close()
            return
        
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()
        
        # Send connection confirmation
        await self.send(text_data=json.dumps({
            'type': 'connection',
            'message': 'Connected to chat',
            'user': self.user.username
        }))

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if not self.user or not self.user.is_authenticated:
            return
            
        try:
            data = json.loads(text_data or '{}')
            message_text = data.get('message', '').strip()
            recipient_username = data.get('recipient')
            
            if not message_text:
                return
            
            # If recipient is provided, save to database
            if recipient_username:
                recipient = await self.get_user_by_username(recipient_username)
                if recipient:
                    # Save message to database
                    await self.save_message(self.user, recipient, message_text)
            
            # Broadcast to group
            await self.channel_layer.group_send(
                self.group_name,
                {
                    'type': 'chat.message',
                    'sender': self.user.username,
                    'sender_id': str(self.user.user_id),
                    'recipient': recipient_username or '',
                    'message': message_text,
                    'timestamp': data.get('timestamp', ''),
                },
            )
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Invalid message format'
            }))
        except Exception as e:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': str(e)
            }))

    async def chat_message(self, event):
        """Send message to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'message',
            'sender': event['sender'],
            'sender_id': event.get('sender_id'),
            'recipient': event.get('recipient'),
            'message': event['message'],
            'timestamp': event.get('timestamp'),
        }))

    @database_sync_to_async
    def get_user_by_username(self, username):
        """Get user by username"""
        try:
            return User.objects.get(username=username)
        except User.DoesNotExist:
            return None

    @database_sync_to_async
    def save_message(self, sender, recipient, message):
        """Save message to Communication model"""
        Communication.objects.create(
            sender=sender,
            recipient=recipient,
            subject=f'Chat: {sender.username} to {recipient.username}',
            message=message,
            is_read=False
        )