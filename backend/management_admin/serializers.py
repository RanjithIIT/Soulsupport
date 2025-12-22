"""
Serializers for management_admin app
"""
from rest_framework import serializers
from .models import File, Department, Teacher, Student, DashboardStats, NewAdmission, Examination_management, Fee, PaymentHistory, Bus, BusStop, BusStopStudent
from main_login.serializers import UserSerializer
from main_login.serializer_mixins import SchoolIdMixin
from main_login.utils import get_user_school_id
from super_admin.serializers import SchoolSerializer


class FileSerializer(serializers.ModelSerializer):
    """Serializer for File model"""
    file_url = serializers.SerializerMethodField()
    
    class Meta:
        model = File
        fields = [
            'file_id', 'file', 'file_url', 'file_name', 'file_type', 'file_size',
            'school_id', 'uploaded_by', 'created_at', 'updated_at'
        ]
        read_only_fields = ['file_id', 'school_id', 'created_at', 'updated_at']
    
    def get_file_url(self, obj):
        """Get the URL to access the file"""
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None


class DepartmentSerializer(serializers.ModelSerializer):
    """Serializer for Department model"""
    head = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    school_id = serializers.CharField(source='school.school_id', read_only=True, help_text='School ID (read-only)')
    
    class Meta:
        model = Department
        fields = [
            'id', 'school', 'school_id', 'school_name', 'name', 'description',
            'head', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school_id', 'created_at', 'updated_at']



class TeacherSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Teacher model"""
    user = UserSerializer(read_only=True)
    department_name = serializers.CharField(source='department.name', read_only=True)
    department = serializers.PrimaryKeyRelatedField(
        queryset=Department.objects.all(),
        required=False,
        allow_null=True,
        help_text='Department ID (optional)'
    )
    profile_photo_url = serializers.SerializerMethodField()
    
    # Writable fields for creating user
    first_name = serializers.CharField(write_only=True, required=False)
    last_name = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = Teacher
        fields = [
            'teacher_id', 'school_id', 'user', 'department', 'department_name',
            'employee_no', 'first_name', 'last_name', 'qualification',
            'joining_date', 'dob', 'gender',
            'blood_group', 'nationality', 'mobile_no', 'email', 'address',
            'primary_room_id', 'class_teacher_section_id', 'subject_specialization',
            'emergency_contact', 'profile_photo', 'profile_photo_id', 'profile_photo_url', 
            'is_class_teacher', 'is_active',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['teacher_id', 'created_at', 'updated_at', 'user', 'profile_photo_id', 'profile_photo_url']
    
    def get_profile_photo_url(self, obj):
        """Get the URL to access the profile photo"""
        if obj.profile_photo and obj.profile_photo.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_photo.file.url)
            return obj.profile_photo.file.url
        return None
    
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
        
        # Ensure is_class_teacher has a default value if not provided
        if 'is_class_teacher' not in validated_data:
            validated_data['is_class_teacher'] = False
        
        # Create teacher with the user (if created)
        teacher = Teacher.objects.create(user=user, **validated_data)
        return teacher


class StudentSerializer(serializers.ModelSerializer):
    """Serializer for Student model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    school_id = serializers.CharField(source='school.school_id', read_only=True, help_text='School ID (read-only)')
    total_fee_amount = serializers.SerializerMethodField()
    paid_fee_amount = serializers.SerializerMethodField()
    due_fee_amount = serializers.SerializerMethodField()
    fees_count = serializers.SerializerMethodField()
    profile_photo_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Student
        fields = [
            'email', 'user', 'school', 'school_id', 'school_name', 'student_id',
            'student_name', 'parent_name', 'date_of_birth', 'gender',
            'applying_class', 'grade', 'address', 'category', 'admission_number',
            'parent_phone', 'emergency_contact', 'medical_information',
            'blood_group', 'previous_school', 'remarks',
            'profile_photo', 'profile_photo_id', 'profile_photo_url',
            'total_fee_amount', 'paid_fee_amount', 'due_fee_amount', 'fees_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['email', 'school_id', 'created_at', 'updated_at', 'user', 'profile_photo_id', 'profile_photo_url']
    
    def get_profile_photo_url(self, obj):
        """Get the URL to access the profile photo"""
        if obj.profile_photo and obj.profile_photo.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_photo.file.url)
            return obj.profile_photo.file.url
        return None
    
    def get_total_fee_amount(self, obj):
        """Calculate total fee amount for this student"""
        from django.db.models import Sum
        from django.db import DataError
        try:
            total = obj.management_fees.aggregate(Sum('total_amount'))['total_amount__sum'] or 0
            return float(total)
        except (DataError, ValueError, TypeError):
            # Handle case where database column type doesn't match (e.g., UUID vs email)
            return 0.0
    
    def get_paid_fee_amount(self, obj):
        """Calculate total paid fee amount for this student"""
        from django.db.models import Sum
        from django.db import DataError
        try:
            paid = obj.management_fees.aggregate(Sum('paid_amount'))['paid_amount__sum'] or 0
            return float(paid)
        except (DataError, ValueError, TypeError):
            return 0.0
    
    def get_due_fee_amount(self, obj):
        """Calculate total due fee amount for this student"""
        from django.db.models import Sum
        from django.db import DataError
        try:
            due = obj.management_fees.aggregate(Sum('due_amount'))['due_amount__sum'] or 0
            return float(due)
        except (DataError, ValueError, TypeError):
            return 0.0
    
    def get_fees_count(self, obj):
        """Get count of fees for this student"""
        from django.db import DataError
        try:
            return obj.management_fees.count()
        except (DataError, ValueError, TypeError):
            return 0


class NewAdmissionSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for New Admission model"""
    generated_password = serializers.CharField(read_only=True, help_text='8-character password generated for user login')
    created_student = StudentSerializer(read_only=True, help_text='Student record created when admission is approved')
    
    class Meta:
        model = NewAdmission
        fields = [
            'student_id', 'school_id', 'student_name', 'parent_name',
            'date_of_birth', 'gender', 'applying_class', 'grade',
            'address', 'category', 'status',
            'admission_number', 'email', 'parent_phone', 'emergency_contact',
            'medical_information', 'blood_group', 'previous_school', 'remarks',
            'created_at', 'updated_at', 'generated_password', 'created_student'
        ]
        read_only_fields = ['created_at', 'updated_at', 'generated_password', 'created_student']
    
    def __init__(self, *args, **kwargs):
        """Override to make email required only for creation, not updates"""
        super().__init__(*args, **kwargs)
        # For partial updates (PATCH), make email optional
        if self.instance is not None:
            # This is an update, make email optional
            self.fields['email'].required = False
            # Make student_id read-only for updates (can't change primary key)
            self.fields['student_id'].read_only = True
        else:
            # For creation, student_id is optional (will be auto-generated if not provided)
            self.fields['student_id'].required = False
            self.fields['student_id'].allow_blank = True
            self.fields['student_id'].allow_null = True
    
    def validate_email(self, value):
        """Validate email - required for creation, optional for updates"""
        if not self.instance and not value:
            raise serializers.ValidationError("Email is required for new admissions.")
        
        # Check if email already exists in NewAdmission (for new records only)
        if not self.instance and value:
            if NewAdmission.objects.filter(email=value).exists():
                raise serializers.ValidationError(
                    f"An admission with email '{value}' already exists. Please use a different email or update the existing admission."
                )
        
        return value
    
    def create(self, validated_data):
        """Override create to generate student_id and password if not provided"""
        import random
        import string
        import datetime
        from django.db import IntegrityError
        from main_login.models import User, Role
        from main_login.utils import get_user_school_id
        
        # Auto-populate school_id from logged-in user (from SchoolIdMixin logic)
        request = None
        if hasattr(self, 'context') and self.context:
            request = self.context.get('request')
        
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            school_id = get_user_school_id(request.user)
            if school_id:
                # Only auto-populate if user is not super admin
                if hasattr(request.user, 'role') and request.user.role:
                    if request.user.role.name != 'super_admin':
                        validated_data['school_id'] = school_id
                else:
                    # No role means auto-populate
                    validated_data['school_id'] = school_id
        
        # Generate student_id if not provided
        student_id = validated_data.get('student_id')
        if not student_id:
            # Generate unique student ID
            timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
            student_id = f'STUD-{datetime.datetime.now().year}-{timestamp[-6:]}'
            # Ensure uniqueness
            while NewAdmission.objects.filter(student_id=student_id).exists():
                timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')
                student_id = f'STUD-{datetime.datetime.now().year}-{timestamp[-6:]}'
            validated_data['student_id'] = student_id
        
        # Generate 8-character password for user login
        characters = string.ascii_letters + string.digits
        generated_password = ''.join(random.choice(characters) for _ in range(8))
        
        # Store generated password in the instance (will be returned in response)
        self.generated_password = generated_password
        
        # Create user account if email is provided
        email = validated_data.get('email')
        if email:
            # Generate username from email
            username = email.split('@')[0]
            # Ensure username is unique
            base_username = username
            counter = 1
            while User.objects.filter(username=username).exists():
                username = f'{base_username}{counter}'
                counter += 1
            
            # Get or create student/parent role
            role, _ = Role.objects.get_or_create(
                name='student_parent',
                defaults={'description': 'Student/Parent role'}
            )
            
            # Get or create user - handle case where user already exists
            user, user_created = User.objects.get_or_create(
                email=email,
                defaults={
                    'username': username,
                    'first_name': validated_data.get('student_name', ''),
                    'role': role,
                    'is_active': True,
                    'has_custom_password': False,
                }
            )
            
            # If user already existed, update it if needed
            if not user_created:
                # Update user details if they changed
                if user.first_name != validated_data.get('student_name', ''):
                    user.first_name = validated_data.get('student_name', '')
                if user.role != role:
                    user.role = role
                user.save()
            
            # Set password_hash to the generated 8-character password (only if user was just created or doesn't have a password)
            if user_created or not user.password_hash:
                user.password_hash = generated_password
                user.set_unusable_password()  # This sets password field to unusable
                user.has_custom_password = False
                user.save()
        
        # Create admission record - handle IntegrityError for better error messages
        try:
            admission = NewAdmission.objects.create(**validated_data)
        except IntegrityError as e:
            # Check if it's a unique constraint violation
            error_str = str(e).lower()
            if 'unique' in error_str or 'duplicate' in error_str:
                if 'email' in error_str:
                    raise serializers.ValidationError({
                        'email': ["An admission with this email already exists. Please use a different email or update the existing admission."]
                    })
                elif 'admission_number' in error_str:
                    raise serializers.ValidationError({
                        'admission_number': ["An admission with this admission number already exists. Please use a different admission number."]
                    })
                elif 'student_id' in error_str:
                    raise serializers.ValidationError({
                        'student_id': ["An admission with this student ID already exists. Please use a different student ID."]
                    })
            # Re-raise the original error if we can't handle it
            raise
        
        # Store generated password in admission for response
        admission.generated_password = generated_password
        
        return admission


class DashboardStatsSerializer(serializers.ModelSerializer):
    """Serializer for Dashboard Stats"""
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    class Meta:
        model = DashboardStats
        fields = [
            'school', 'total_teachers', 'total_students',
            'total_departments', 'updated_at'
        ]


class ExaminationManagementSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Examination Management model"""
    
    class Meta:
        model = Examination_management
        fields = [
            'id', 'school_id', 'Exam_Title', 'Exam_Type', 'Exam_Date', 'Exam_Time',
            'Exam_Subject', 'Exam_Class', 'Exam_Duration', 'Exam_Marks',
            'Exam_Description', 'Exam_Location', 'Exam_Status',
            'Exam_Created_At', 'Exam_Updated_At'
        ]
        read_only_fields = ['id', 'school_id', 'Exam_Created_At', 'Exam_Updated_At']


class PaymentHistorySerializer(serializers.ModelSerializer):
    """Serializer for Payment History model"""
    
    class Meta:
        model = PaymentHistory
        fields = [
            'id', 'fee', 'payment_amount', 'payment_date', 'receipt_number',
            'notes', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class FeeSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Fee model"""
    student_id = serializers.SerializerMethodField()
    student_email = serializers.SerializerMethodField()
    payment_history = PaymentHistorySerializer(many=True, read_only=True)
    
    class Meta:
        model = Fee
        fields = [
            'id', 'school_id', 'student', 'student_id', 'student_id_string', 'student_email', 'student_name', 'applying_class', 'fee_type', 'grade',
            'total_amount', 'frequency', 'due_date', 'late_fee', 'description',
            'status', 'paid_amount', 'due_amount', 
            'last_paid_date', 'payment_history', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at', 'student_name', 'applying_class', 'payment_history']
    
    def get_student_id(self, obj):
        """Safely get student ID"""
        try:
            return str(obj.student.student_id) if obj.student else ''
        except Exception:
            return ''
    
    def get_student_email(self, obj):
        """Safely get student email"""
        try:
            return obj.student.email if obj.student else ''
        except Exception:
            return ''
    
    def create(self, validated_data):
        """Override create to auto-populate grade from student if not provided"""
        grade = validated_data.get('grade', '').strip()
        student = validated_data.get('student')
        
        # If grade is not provided or empty, try to get it from student or admission
        if not grade and student:
            # First try to get grade from Student model
            if hasattr(student, 'grade') and student.grade:
                validated_data['grade'] = student.grade
            else:
                # If not in Student, try to get from NewAdmission
                from .models import NewAdmission
                try:
                    # Try to find admission by student_id or email
                    admission = NewAdmission.objects.filter(
                        student_id=student.student_id
                    ).first()
                    
                    if not admission:
                        admission = NewAdmission.objects.filter(
                            email=student.email
                        ).first()
                    
                    if admission and admission.grade:
                        validated_data['grade'] = admission.grade
                except Exception:
                    pass
        
        return super().create(validated_data)


class BusStopStudentSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for BusStopStudent model"""
    student_name = serializers.CharField(source='student.student_name', read_only=True)
    bus_stop_name = serializers.CharField(source='bus_stop.stop_name', read_only=True)
    
    class Meta:
        model = BusStopStudent
        fields = [
            'id', 'school_id', 'bus_stop', 'bus_stop_name', 'student', 'student_name',
            'student_id_string', 'student_class', 'student_grade',
            'pickup_time', 'dropoff_time', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school_id', 'created_at', 'updated_at']


class BusStopSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for BusStop model"""
    bus_name = serializers.CharField(source='bus.bus_number', read_only=True)
    
    class Meta:
        model = BusStop
        fields = [
            'stop_id', 'school_id', 'bus', 'bus_name', 'stop_name', 'stop_address',
            'stop_time', 'route_type', 'stop_order', 'latitude', 'longitude',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['stop_id', 'school_id', 'created_at', 'updated_at']


class BusSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Bus model"""
    school_name = serializers.CharField(source='school.name', read_only=True)
    school_id = serializers.CharField(source='school.school_id', read_only=True, help_text='School ID (read-only)')
    morning_stops = serializers.SerializerMethodField()
    afternoon_stops = serializers.SerializerMethodField()
    
    class Meta:
        model = Bus
        fields = [
            'bus_number', 'school', 'school_id', 'school_name', 'bus_type',
            'capacity', 'registration_number', 'driver_name', 'driver_phone',
            'driver_license', 'driver_experience', 'route_name', 'route_distance',
            'start_location', 'end_location', 'morning_start_time', 'morning_end_time',
            'afternoon_start_time', 'afternoon_end_time', 'notes', 'is_active',
            'morning_stops', 'afternoon_stops',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['school_id', 'created_at', 'updated_at']
    
    def get_morning_stops(self, obj):
        """Get all morning route stops with their students"""
        morning_stops = obj.stops.filter(route_type='morning').order_by('stop_order')
        stops_data = []
        for stop in morning_stops:
            stop_data = BusStopSerializer(stop, context=self.context).data
            # Get students for this stop
            students = stop.stop_students.all()
            stop_data['students'] = BusStopStudentSerializer(students, many=True, context=self.context).data
            stop_data['student_count'] = students.count()
            stops_data.append(stop_data)
        return stops_data
    
    def get_afternoon_stops(self, obj):
        """Get all afternoon route stops with their students.
        Students are always taken from the corresponding morning stop (matched by stop_name),
        so only the stop order changes, not the student assignments.
        """
        afternoon_stops = obj.stops.filter(route_type='afternoon').order_by('stop_order')
        morning_stops = obj.stops.filter(route_type='morning').order_by('stop_order')
        
        # Create a map of morning stops by stop_name for quick lookup
        morning_stops_map = {stop.stop_name: stop for stop in morning_stops}
        
        stops_data = []
        for stop in afternoon_stops:
            stop_data = BusStopSerializer(stop, context=self.context).data
            
            # Always get students from the corresponding morning stop (matched by stop_name)
            # This ensures students remain the same, only stop_order changes
            corresponding_morning_stop = morning_stops_map.get(stop.stop_name)
            
            if corresponding_morning_stop:
                # Get students from corresponding morning stop (same location name)
                morning_students = corresponding_morning_stop.stop_students.all()
                stop_data['students'] = BusStopStudentSerializer(morning_students, many=True, context=self.context).data
                stop_data['student_count'] = morning_students.count()
            else:
                # If no corresponding morning stop found, use students directly assigned to afternoon stop
                students = stop.stop_students.all()
                stop_data['students'] = BusStopStudentSerializer(students, many=True, context=self.context).data
                stop_data['student_count'] = students.count()
            
            stops_data.append(stop_data)
        return stops_data
