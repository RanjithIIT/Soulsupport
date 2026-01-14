import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from student_parent.models import Communication, ChatMessage
from django.utils import timezone

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
            recipient_username = data.get('recipient', '').strip()
            
            if not message_text:
                return
            
            # If recipient is provided, save to database
            recipient = None
            chat_message = None
            if recipient_username:
                recipient = await self.get_user_by_username(recipient_username)
                if recipient:
                    # Save message to database (returns ChatMessage instance)
                    chat_message = await self.save_message(self.user, recipient, message_text)
                else:
                    # Log warning if recipient not found
                    import logging
                    logger = logging.getLogger(__name__)
                    logger.warning(f'Recipient not found: {recipient_username}')
            
            # Get sender's display name (first_name + last_name or username)
            # Always use the authenticated user's info, ignore sender from frontend
            sender_name = self.user.username
            if self.user.first_name or self.user.last_name:
                sender_name = f"{self.user.first_name or ''} {self.user.last_name or ''}".strip()
                if not sender_name:  # If stripped result is empty, use username
                    sender_name = self.user.username
            
            # Broadcast to group - This ensures BOTH sender and recipient receive the message
            # Both users should be connected to the same room_id (group_name)
            # This works like WhatsApp/Telegram - both ends receive messages in real-time
            await self.channel_layer.group_send(
                self.group_name,
                {
                    'type': 'chat.message',
                    'sender': sender_name,  # Send full name instead of just username
                    'sender_username': self.user.username,  # Also include username for comparison
                    'sender_id': str(self.user.user_id),
                    'recipient': recipient_username or '',  # Can be empty if not provided
                    'recipient_id': str(recipient.user_id) if recipient else '',
                    'message': message_text,
                    'timestamp': data.get('timestamp', timezone.now().isoformat()),
                    'message_id': str(chat_message.message_id) if chat_message else '',
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
        """Send message to WebSocket - Send to both sender and recipient in the same room"""
        # IMPORTANT: Both sender and recipient should receive the message
        # The frontend will filter based on the current conversation
        # This ensures real-time bidirectional messaging like WhatsApp/Telegram
        await self.send(text_data=json.dumps({
            'type': 'message',
            'sender': event['sender'],
            'sender_username': event.get('sender_username', event['sender']),
            'sender_id': event.get('sender_id'),
            'recipient': event.get('recipient', ''),
            'recipient_id': event.get('recipient_id', ''),
            'message': event['message'],
            'timestamp': event.get('timestamp', ''),
            'message_id': event.get('message_id', ''),
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
        """Save message to ChatMessage model for real-time chat (WhatsApp/Telegram-like)"""
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
        
        # Save message to ChatMessage model (designed for real-time chat)
        chat_message = ChatMessage.objects.create(
            sender=sender,
            recipient=recipient,
            message_type='text',
            message_text=message,
            is_read=False
        )
        
        # Also save to Communication model for backward compatibility
        try:
            Communication.objects.create(
                sender=sender,
                recipient=recipient,
                subject=f'Chat: {sender.username} to {recipient.username}',
                message=message,
                is_read=False
            )
        except Exception as e:
            # If Communication save fails, log but don't fail the chat message
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f'Failed to save to Communication model: {str(e)}')
        
        return chat_message