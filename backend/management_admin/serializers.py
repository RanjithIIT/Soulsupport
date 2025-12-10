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
    department_name = serializers.CharField(source='department.name', read_only=True)
    
    # Writable fields for creating user
    first_name = serializers.CharField(write_only=True, required=False)
    last_name = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = Teacher
        fields = [
            'teacher_id', 'user', 'department', 'department_name',
            'employee_no', 'first_name', 'last_name', 'qualification',
            'joining_date', 'dob', 'gender', 'designation', 'department',
            'blood_group', 'nationality', 'mobile_no', 'email', 'address',
            'primary_room_id', 'class_teacher_section_id', 'subject_specialization',
            'emergency_contact', 'profile_photo_id', 'is_active',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['teacher_id', 'created_at', 'updated_at', 'user']
    
    def create(self, validated_data):
        """Override create to handle user creation from email"""
        import random
        import string
        from main_login.models import User, Role
        
        # Get user data (don't pop, as they're also Teacher model fields)
        first_name = validated_data.get('first_name', '')
        last_name = validated_data.get('last_name', '')
        email = validated_data.get('email', '')
        
        # Create user from email if email is provided
        user = None
        if email:
            # Generate username from email (part before @)
            username = email.split('@')[0] if email else None
            
            # Ensure username is unique
            if username:
                base_username = username
                counter = 1
                while User.objects.filter(username=username).exists():
                    username = f'{base_username}{counter}'
                    counter += 1
            else:
                # Fallback if no email
                username = f'teacher_{validated_data.get("employee_no", "unknown")}'
                counter = 1
                while User.objects.filter(username=username).exists():
                    username = f'teacher_{validated_data.get("employee_no", "unknown")}_{counter}'
                    counter += 1
            
            # Get or create teacher role
            role, _ = Role.objects.get_or_create(
                name='teacher',
                defaults={'description': 'Teacher role'}
            )
            
            # Generate 8-character random password (alphanumeric)
            characters = string.ascii_letters + string.digits
            generated_password = ''.join(random.choice(characters) for _ in range(8))
            
            # Create or get user
            user, created = User.objects.get_or_create(
                email=email,
                defaults={
                    'username': username,
                    'first_name': first_name or '',
                    'last_name': last_name or '',
                    'role': role,
                    'is_active': True,
                    'has_custom_password': False,  # Teacher needs to create their own password
                }
            )
            
            # Set password_hash to the generated 8-character password
            if created:
                user.password_hash = generated_password
                user.set_unusable_password()  # This sets password field to unusable (effectively null)
                user.has_custom_password = False
                user.save()
            else:
                # Update user if it already existed
                if first_name:
                    user.first_name = first_name
                if last_name:
                    user.last_name = last_name
                user.save()
        
        # Create teacher with the user (if created)
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
    generated_password = serializers.CharField(read_only=True, help_text='8-character password generated for user login')
    created_student = StudentSerializer(read_only=True, help_text='Student record created when admission is approved')
    
    class Meta:
        model = NewAdmission
        fields = [
            'id', 'student_name', 'parent_name',
            'date_of_birth', 'gender', 'applying_class', 'grade', 'fees',
            'address', 'category', 'status',
            'admission_number', 'student_id', 'email', 'parent_phone', 'emergency_contact',
            'medical_information', 'blood_group', 'previous_school', 'remarks',
            'created_at', 'updated_at', 'generated_password', 'created_student'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'generated_password', 'created_student']
    
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

