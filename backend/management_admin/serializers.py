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
    
    class Meta:
        model = Student
        fields = [
            'user', 'school', 'school_name', 'student_id',
            'student_name', 'parent_name', 'date_of_birth', 'gender',
            'applying_class', 'address', 'category', 'admission_number',
            'email', 'parent_phone', 'emergency_contact', 'medical_information',
            'blood_group', 'previous_school', 'remarks',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['student_id', 'created_at', 'updated_at', 'user']


class NewAdmissionSerializer(serializers.ModelSerializer):
    """Serializer for New Admission model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    generated_password = serializers.CharField(read_only=True, help_text='6-digit password generated for user login')
    created_student = StudentSerializer(read_only=True, help_text='Student record created when admission is approved')
    
    class Meta:
        model = NewAdmission
        fields = [
            'id', 'user', 'school', 'school_name', 'student_name', 'parent_name',
            'date_of_birth', 'gender', 'applying_class',
            'address', 'category', 'status',
            'admission_number', 'email', 'parent_phone', 'emergency_contact',
            'medical_information', 'blood_group', 'previous_school', 'remarks',
            'created_at', 'updated_at', 'generated_password', 'created_student'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'generated_password', 'user', 'created_student']
    
    def __init__(self, *args, **kwargs):
        """Override to make email required only for creation, not updates"""
        super().__init__(*args, **kwargs)
        # For partial updates (PATCH), make email optional
        if self.instance is not None:
            # This is an update, make email optional
            self.fields['email'].required = False
    
    def validate_email(self, value):
        """Validate email - required for creation, optional for updates"""
        # If this is a create (no instance) and email is not provided
        if self.instance is None and (value is None or value == ''):
            raise serializers.ValidationError("Email is required for new admissions.")
        # For updates, if email is not provided, keep existing email
        if self.instance is not None and (value is None or value == ''):
            return self.instance.email
        return value
    
    def validate_admission_number(self, value):
        """Validate admission_number uniqueness, excluding current instance"""
        # Handle empty strings - convert to None
        if value is not None:
            value = value.strip() if isinstance(value, str) else value
            if not value:
                value = None
        
        if value:
            # Check if admission_number already exists (excluding current instance)
            queryset = NewAdmission.objects.filter(admission_number=value)
            if self.instance:
                queryset = queryset.exclude(pk=self.instance.pk)
            if queryset.exists():
                raise serializers.ValidationError(
                    f"Admission number '{value}' already exists."
                )
        return value


class DashboardStatsSerializer(serializers.ModelSerializer):
    """Serializer for Dashboard Statistics"""
    school = SchoolSerializer(read_only=True)
    
    class Meta:
        model = DashboardStats
        fields = [
            'school', 'total_teachers', 'total_students',
            'total_departments', 'updated_at'
        ]

