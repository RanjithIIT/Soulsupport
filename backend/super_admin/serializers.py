"""
Serializers for super_admin app
"""
from rest_framework import serializers
from .models import School, SchoolStats, Activity
from main_login.serializers import UserSerializer


class SchoolStatsSerializer(serializers.ModelSerializer):
    """Serializer for School Statistics"""
    class Meta:
        model = SchoolStats
        fields = ['total_students', 'total_teachers', 'total_revenue', 'updated_at']


class SchoolSerializer(serializers.ModelSerializer):
    """Serializer for School model"""
    stats = SchoolStatsSerializer(read_only=True)
    generated_password = serializers.SerializerMethodField()
    user_id = serializers.UUIDField(source='user.user_id', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = School
        fields = [
            'school_id', 'name', 'location', 'statecode', 'districtcode', 'registration_number',
            'email', 'phone', 'address', 'principal_name', 'established_year', 'status',
            'license_expiry', 'user', 'user_id', 'username', 'stats', 'generated_password',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['school_id', 'user', 'user_id', 'username', 'created_at', 'updated_at']
    
    def get_generated_password(self, obj):
        """Get generated password from context (only available during creation)"""
        return self.context.get('generated_password', None)


class ActivitySerializer(serializers.ModelSerializer):
    """Serializer for Activity model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    class Meta:
        model = Activity
        fields = [
            'id', 'user', 'school', 'school_name', 'activity_type',
            'description', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

