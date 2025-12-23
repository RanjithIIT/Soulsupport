"""
Serializers for super_admin app
"""
from rest_framework import serializers
from .models import School, SchoolStats, Activity
from main_login.serializers import UserSerializer


class SchoolStatsSerializer(serializers.ModelSerializer):
    """Serializer for School Statistics"""
    # Real-time counts calculated from database
    total_students = serializers.SerializerMethodField()
    total_teachers = serializers.SerializerMethodField()
    total_buses = serializers.SerializerMethodField()
    
    class Meta:
        model = SchoolStats
        fields = ['total_students', 'total_teachers', 'total_buses', 'total_revenue', 'updated_at']
    
    def get_total_students(self, obj):
        """Get real-time student count from database"""
        try:
            if obj and hasattr(obj, 'school') and obj.school:
                return obj.school.students.count()
        except Exception:
            pass
        return 0
    
    def get_total_teachers(self, obj):
        """Get real-time teacher count from database"""
        try:
            if obj and hasattr(obj, 'school') and obj.school:
                from management_admin.models import Teacher
                return Teacher.objects.filter(school_id=obj.school.school_id).count()
        except Exception:
            pass
        return 0
    
    def get_total_buses(self, obj):
        """Get real-time bus count from database"""
        try:
            if obj and hasattr(obj, 'school') and obj.school:
                return obj.school.buses.count()
        except Exception:
            pass
        return 0


class SchoolSerializer(serializers.ModelSerializer):
    """Serializer for School model"""
    stats = serializers.SerializerMethodField()
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
    
    def get_stats(self, obj):
        """Get or create SchoolStats and serialize it"""
        try:
            stats, created = SchoolStats.objects.get_or_create(school=obj)
            return SchoolStatsSerializer(stats).data
        except Exception:
            # Return default stats if there's an error
            return {
                'total_students': 0,
                'total_teachers': 0,
                'total_buses': 0,
                'total_revenue': '0.00',
                'updated_at': None
            }
    
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

