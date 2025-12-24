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
    school_id = serializers.SerializerMethodField()
    school_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Parent
        fields = [
            'id', 'school_id', 'school_name', 'user', 'students', 'phone', 'address',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_school_id(self, obj):
        """Get school_id from model or compute from students"""
        # First try to get from model field
        if obj.school_id:
            return obj.school_id
        
        # If not available, try to get from first student's school
        # Use select_related to optimize database queries
        students = obj.students.all().select_related('school')
        for student in students:
            if student and student.school:
                # Log for debugging
                import logging
                logger = logging.getLogger(__name__)
                logger.debug(f"Parent {obj.id}: Found school_id {student.school.school_id} from student {student.email}")
                return student.school.school_id
        
        # Log warning if no school found
        import logging
        logger = logging.getLogger(__name__)
        logger.warning(f"Parent {obj.id}: No school_id found. Students count: {obj.students.count()}")
        return None
    
    def get_school_name(self, obj):
        """Get school_name from model or compute from students"""
        # First try to get from model field
        if obj.school_name:
            return obj.school_name
        
        # If not available, try to get from first student's school
        # Use select_related to optimize database queries
        students = obj.students.all().select_related('school')
        for student in students:
            if student and student.school:
                import logging
                logger = logging.getLogger(__name__)
                logger.debug(f"Parent {obj.id}: Found school_name {student.school.school_name} from student {student.email}")
                return student.school.school_name
        
        import logging
        logger = logging.getLogger(__name__)
        logger.warning(f"Parent {obj.id}: No school_name found. Students count: {obj.students.count()}")
        return None


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

