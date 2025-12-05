from django.urls import re_path
from .consumers import TeacherParentChatConsumer

websocket_urlpatterns = [
    re_path(r'ws/teacher-parent/(?P<room_id>[^/]+)/$', TeacherParentChatConsumer.as_asgi()),
]