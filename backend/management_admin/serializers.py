"""
Serializers for management_admin app
"""
from rest_framework import serializers
from .models import Department, Teacher, Student, DashboardStats, NewAdmission
from main_login.serializers import UserSerializer
from super_admin.serializers import SchoolSerializer


class DepartmentSerializer(serializers.ModelSerializer):
    """Serializer for Department model"""
    head = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    class Meta:
        model = Department
        fields = [
            'id', 'school', 'school_name', 'name', 'description',
            'head', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class TeacherSerializer(serializers.ModelSerializer):
    """Serializer for Teacher model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    department_name = serializers.CharField(source='department.name', read_only=True)
    
    # Writable fields for creating user
    first_name = serializers.CharField(write_only=True, required=False)
    last_name = serializers.CharField(write_only=True, required=False)
    username = serializers.CharField(write_only=True, required=False)
    email_user = serializers.EmailField(write_only=True, required=False, source='email_for_user')
    
    class Meta:
        model = Teacher
        fields = [
            'id', 'user', 'school', 'school_name', 'department',
            'department_name', 'employee_id', 'designation',
            'hire_date', 'phone', 'email', 'address', 'experience',
            'qualifications', 'specializations', 'class_teacher', 'photo',
            'created_at', 'updated_at',
            'first_name', 'last_name', 'username', 'email_user'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'user']
    
    def create(self, validated_data):
        """Override create to handle user creation"""
        from main_login.models import User
        
        # Extract user data
        first_name = validated_data.pop('first_name', '')
        last_name = validated_data.pop('last_name', '')
        username = validated_data.pop('username', '')
        email_for_user = validated_data.pop('email_for_user', '')
        
        # Create or get user
        if username and email_for_user:
            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'email': email_for_user,
                    'first_name': first_name,
                    'last_name': last_name,
                }
            )
        else:
            raise serializers.ValidationError("Username and email_user are required for creating a teacher")
        
        # Create teacher with the user
        teacher = Teacher.objects.create(user=user, **validated_data)
        return teacher


class StudentSerializer(serializers.ModelSerializer):
    """Serializer for Student model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    # Writable fields for creating user
    first_name = serializers.CharField(write_only=True, required=False)
    last_name = serializers.CharField(write_only=True, required=False)
    username = serializers.CharField(write_only=True, required=False)
    email_user = serializers.EmailField(write_only=True, required=False, source='email_for_user')
    
    class Meta:
        model = Student
        fields = [
            'id', 'user', 'school', 'school_name', 'student_id',
            'class_name', 'section', 'admission_date',
            'date_of_birth', 'gender', 'blood_group', 'address',
            'emergency_contact', 'medical_info', 'parent_name', 'parent_phone',
            'photo', 'created_at', 'updated_at',
            'first_name', 'last_name', 'username', 'email_user'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'user']
    
    def create(self, validated_data):
        """Override create to handle user creation"""
        from main_login.models import User
        
        # Extract user data
        first_name = validated_data.pop('first_name', '')
        last_name = validated_data.pop('last_name', '')
        username = validated_data.pop('username', '')
        email_for_user = validated_data.pop('email_for_user', '')
        
        # Create or get user
        if username and email_for_user:
            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'email': email_for_user,
                    'first_name': first_name,
                    'last_name': last_name,
                }
            )
        else:
            raise serializers.ValidationError("Username and email_user are required for creating a student")
        
        # Create student with the user
        student = Student.objects.create(user=user, **validated_data)
        return student


class NewAdmissionSerializer(serializers.ModelSerializer):
    """Serializer for New Admission model"""
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    class Meta:
        model = NewAdmission
        fields = [
            'id', 'school', 'school_name', 'student_name', 'parent_name',
            'date_of_birth', 'gender', 'applying_class', 'contact_number',
            'address', 'application_date', 'category', 'status',
            'admission_number', 'email', 'previous_school', 'remarks',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class DashboardStatsSerializer(serializers.ModelSerializer):
    """Serializer for Dashboard Statistics"""
    school = SchoolSerializer(read_only=True)
    
    class Meta:
        model = DashboardStats
        fields = [
            'school', 'total_teachers', 'total_students',
            'total_departments', 'updated_at'
        ]

