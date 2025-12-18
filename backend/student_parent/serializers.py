"""
Serializers for student_parent app
"""
from rest_framework import serializers
from .models import Parent, Notification, Fee, Communication
from main_login.serializer_mixins import SchoolIdMixin
from management_admin.serializers import StudentSerializer
from main_login.serializers import UserSerializer


class ParentSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Parent model"""
    user = UserSerializer(read_only=True)
    students = StudentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Parent
        fields = [
            'id', 'school_id', 'user', 'students', 'phone', 'address',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class NotificationSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Notification model"""
    recipient = UserSerializer(read_only=True)
    
    class Meta:
        model = Notification
        fields = [
            'id', 'school_id', 'recipient', 'title', 'message', 'notification_type',
            'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class FeeSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Fee model"""
    student = StudentSerializer(read_only=True)
    
    class Meta:
        model = Fee
        fields = [
            'id', 'school_id', 'student', 'amount', 'due_date', 'status',
            'payment_date', 'description', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class CommunicationSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Communication model"""
    sender = UserSerializer(read_only=True)
    recipient = UserSerializer(read_only=True)
    
    class Meta:
        model = Communication
        fields = [
            'id', 'school_id', 'sender', 'recipient', 'subject', 'message',
            'is_read', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

