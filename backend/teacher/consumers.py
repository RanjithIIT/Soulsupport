import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from student_parent.models import Communication

User = get_user_model()

class TeacherStudentChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Extract room_id from URL and URL-decode it
        from urllib.parse import unquote
        raw_room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_id = unquote(raw_room_id)  # Decode URL-encoded characters like %40 (@)
        
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
    def get_user_by_username(self, username_or_name):
        """Get user by username, email, or name (first_name + last_name)"""
        try:
            # First try username
            try:
                return User.objects.get(username=username_or_name)
            except User.DoesNotExist:
                pass
            
            # Then try email
            try:
                return User.objects.get(email=username_or_name)
            except User.DoesNotExist:
                pass
            
            # Finally try by name (first_name + last_name)
            # Split name into parts
            name_parts = username_or_name.split('_')  # Handle normalized names
            if len(name_parts) >= 2:
                # Try to find by first_name and last_name
                first_name = name_parts[0].capitalize()
                last_name = name_parts[1].capitalize()
                user = User.objects.filter(
                    first_name__iexact=first_name,
                    last_name__iexact=last_name
                ).first()
                if user:
                    return user
            
            # If name has space, try splitting by space
            if ' ' in username_or_name:
                name_parts = username_or_name.split(' ', 2)
                if len(name_parts) >= 2:
                    first_name = name_parts[0].strip().capitalize()
                    last_name = name_parts[1].strip().capitalize()
                    user = User.objects.filter(
                        first_name__iexact=first_name,
                        last_name__iexact=last_name
                    ).first()
                    if user:
                        return user
            
            return None
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'Error looking up user by {username_or_name}: {str(e)}')
            return None

    @database_sync_to_async
    def save_message(self, sender, recipient, message):
        """Save message to Communication model with school_id validation"""
        from main_login.utils import get_user_school_id
        
        # Get school_id for both sender and recipient
        sender_school_id = get_user_school_id(sender)
        recipient_school_id = get_user_school_id(recipient)
        
        # Validate that sender and recipient have matching school_id
        if sender_school_id and recipient_school_id:
            if sender_school_id != recipient_school_id:
                raise ValueError(
                    f'Cannot send message: Sender and recipient must belong to the same school. '
                    f'Sender school: {sender_school_id}, Recipient school: {recipient_school_id}'
                )
        
        # Save message (Communication model's save() will also validate)
        Communication.objects.create(
            sender=sender,
            recipient=recipient,
            subject=f'Chat: {sender.username} to {recipient.username}',
            message=message,
            is_read=False
        )