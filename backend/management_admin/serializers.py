"""
Serializers for management_admin app
"""
from rest_framework import serializers
from .models import File, Department, Teacher, Student, DashboardStats, NewAdmission, Examination_management, Fee, PaymentHistory, Bus, BusStop, BusStopStudent, Event, Award, CampusFeature
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
    school_name = serializers.CharField(source='school.school_name', read_only=True)
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
    
    # Make employee_no required but allow auto-generation if not provided
    employee_no = serializers.CharField(max_length=50, required=False, help_text='Employee number (auto-generated if not provided)')
    
    # First and last name fields - read-write so they appear in responses
    first_name = serializers.CharField(required=True)
    last_name = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    
    class Meta:
        model = Teacher
        fields = [
            'employee_no', 'school_id', 'school_name', 'user', 'department', 'department_name',
            'first_name', 'last_name', 'qualification',
            'joining_date', 'dob', 'gender',
            'blood_group', 'nationality', 'mobile_no', 'email', 'address',
            'class_teacher_class', 'class_teacher_grade', 'subject_specialization',
            'emergency_contact', 'profile_photo', 'profile_photo_url', 
            'is_class_teacher', 'is_active',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at', 'user', 'profile_photo_url']
    
    def get_profile_photo_url(self, obj):
        if obj.profile_photo:
            request = self.context.get('request')
            if request:
                # If it's already a full URL, return it
                if obj.profile_photo.startswith('http://') or obj.profile_photo.startswith('https://'):
                    return obj.profile_photo
                # If it starts with /media/, it's a media file URL - build absolute URI
                if obj.profile_photo.startswith('/media/'):
                    return request.build_absolute_uri(obj.profile_photo)
                # If it doesn't start with /, add /media/ prefix (for relative paths like 'profile_photos/...')
                if not obj.profile_photo.startswith('/'):
                    media_path = f'/media/{obj.profile_photo}'
                    return request.build_absolute_uri(media_path)
                # For other absolute paths, build absolute URI
                return request.build_absolute_uri(obj.profile_photo)
            # If no request context, return as-is (may be used in management commands)
            return obj.profile_photo
        return None
    
    def create(self, validated_data):
        import random
        import string
        from django.utils import timezone
        
        first_name = validated_data.get('first_name', '')
        last_name = validated_data.get('last_name', '')
        email = validated_data.get('email', '')
        
        # Auto-generate employee_no if not provided
        employee_no = validated_data.get('employee_no')
        if not employee_no or employee_no.strip() == '':
            # Generate unique employee number: EMP + timestamp + random suffix
            timestamp = timezone.now().strftime('%Y%m%d%H%M%S')
            random_suffix = ''.join(random.choices(string.digits, k=4))
            employee_no = f'EMP{timestamp}{random_suffix}'
            
            # Ensure uniqueness
            while Teacher.objects.filter(employee_no=employee_no).exists():
                random_suffix = ''.join(random.choices(string.digits, k=4))
                employee_no = f'EMP{timestamp}{random_suffix}'
            
            validated_data['employee_no'] = employee_no
        else:
            # Ensure uniqueness of provided employee_no
            employee_no = employee_no.strip().upper()
            if Teacher.objects.filter(employee_no=employee_no).exists():
                raise serializers.ValidationError({'employee_no': f'Employee number {employee_no} already exists.'})
            validated_data['employee_no'] = employee_no
        
        # User will be created separately when teacher account is activated/approved
        # For now, teacher is created without user account
        user = None
        
        if 'is_class_teacher' not in validated_data:
            validated_data['is_class_teacher'] = False
        
        teacher = Teacher.objects.create(user=user, **validated_data)
        return teacher


class StudentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.school_name', read_only=True)
    school_id = serializers.CharField(source='school.school_id', read_only=True)
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
            'profile_photo', 'profile_photo_url',
            'total_fee_amount', 'paid_fee_amount', 'due_fee_amount', 'fees_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['email', 'school_id', 'created_at', 'updated_at', 'user', 'profile_photo_url']
    
    def get_profile_photo_url(self, obj):
        if obj.profile_photo:
            request = self.context.get('request')
            if request:
                # If it's already a full URL, return it; otherwise build absolute URI
                if obj.profile_photo.startswith('http://') or obj.profile_photo.startswith('https://'):
                    return obj.profile_photo
                return request.build_absolute_uri(obj.profile_photo)
            return obj.profile_photo
        return None
    
    def get_total_fee_amount(self, obj):
        from django.db.models import Sum
        try:
            total = obj.management_fees.aggregate(Sum('total_amount'))['total_amount__sum'] or 0
            return float(total)
        except:
            return 0.0
    
    def get_paid_fee_amount(self, obj):
        from django.db.models import Sum
        try:
            paid = obj.management_fees.aggregate(Sum('paid_amount'))['paid_amount__sum'] or 0
            return float(paid)
        except:
            return 0.0
    
    def get_due_fee_amount(self, obj):
        from django.db.models import Sum
        try:
            due = obj.management_fees.aggregate(Sum('due_amount'))['due_amount__sum'] or 0
            return float(due)
        except:
            return 0.0
    
    def get_fees_count(self, obj):
        try:
            return obj.management_fees.count()
        except:
            return 0


# -------------- FIXED SERIALIZER BELOW -----------------
class NewAdmissionSerializer(SchoolIdMixin, serializers.ModelSerializer):
    generated_password = serializers.CharField(read_only=True)
    created_student = StudentSerializer(read_only=True)
    
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

    def create(self, validated_data):
        import random, string, datetime, logging
        from django.db import transaction, IntegrityError
        from main_login.models import User, Role

        logger = logging.getLogger(__name__)

        with transaction.atomic():
            # auto school
            request = self.context.get("request")
            if request and request.user.is_authenticated:
                sid = get_user_school_id(request.user)
                if sid:
                    validated_data["school_id"] = sid

            # student id
            if not validated_data.get("student_id"):
                validated_data["student_id"] = f"STUD-{random.randint(100000,999999)}"

            # Generate password for when admission is approved (user will be created then)
            generated_password = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(8))
            self.generated_password = generated_password

            admission = NewAdmission.objects.create(**validated_data)
            admission.generated_password = generated_password
            return admission


# ---------------- remaining serializers unchanged -------------------

class DashboardStatsSerializer(serializers.ModelSerializer):
    school_name = serializers.CharField(source='school.school_name', read_only=True)
    
    class Meta:
        model = DashboardStats
        fields = [
            'school', 'total_teachers', 'total_students',
            'total_departments', 'updated_at'
        ]


class ExaminationManagementSerializer(SchoolIdMixin, serializers.ModelSerializer):
    class Meta:
        model = Examination_management
        fields = '__all__'


class PaymentHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentHistory
        fields = '__all__'


class FeeSerializer(SchoolIdMixin, serializers.ModelSerializer):
    student_id = serializers.SerializerMethodField()
    student_email = serializers.SerializerMethodField()
    payment_history = PaymentHistorySerializer(many=True, read_only=True)

    class Meta:
        model = Fee
        fields = '__all__'

    def get_student_id(self, obj):
        return str(obj.student.student_id) if obj.student else ''

    def get_student_email(self, obj):
        return obj.student.email if obj.student else ''


class BusStopStudentSerializer(SchoolIdMixin, serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.student_name', read_only=True)
    bus_stop_name = serializers.CharField(source='bus_stop.stop_name', read_only=True)

    class Meta:
        model = BusStopStudent
        fields = '__all__'


class BusStopSerializer(SchoolIdMixin, serializers.ModelSerializer):
    bus_name = serializers.CharField(source='bus.bus_number', read_only=True)

    class Meta:
        model = BusStop
        fields = '__all__'


class BusSerializer(SchoolIdMixin, serializers.ModelSerializer):
    school_name = serializers.CharField(source='school.school_name', read_only=True)
    morning_stops = serializers.SerializerMethodField()
    afternoon_stops = serializers.SerializerMethodField()

    class Meta:
        model = Bus
        fields = '__all__'

    def get_morning_stops(self, obj):
        return []

    def get_afternoon_stops(self, obj):
        return []


class EventSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Event model"""
    
    class Meta:
        model = Event
        fields = [
            'id', 'school_id', 'school_name', 'name', 'category', 'date',
            'time', 'location', 'organizer', 'participants', 'status',
            'description', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school_id', 'school_name', 'created_at', 'updated_at']
    
    def update(self, instance, validated_data):
        """Update event instance"""
        # Update all fields except read-only ones
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class DepartmentSerializer(serializers.ModelSerializer):
    """Serializer for Department model"""
    school_id = serializers.ReadOnlyField(source='school.school_id')
    
    class Meta:
        model = Department
        fields = [
            'id', 'school', 'school_id', 'school_name', 'name', 'code', 'description',
            'head_name', 'email', 'phone', 'faculty_count', 'student_count',
            'course_count', 'established_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school', 'school_id', 'school_name', 'created_at', 'updated_at']

    def update(self, instance, validated_data):
        """Update department instance"""
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class CampusFeatureSerializer(serializers.ModelSerializer):
    """Serializer for CampusFeature model"""
    school_id = serializers.ReadOnlyField(source='school.school_id')
    
    class Meta:
        model = CampusFeature
        fields = [
            'id', 'school', 'school_id', 'school_name', 'name', 'category', 'description',
            'location', 'capacity', 'status', 'date_added', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school', 'school_id', 'school_name', 'date_added', 'created_at', 'updated_at']

    def update(self, instance, validated_data):
        """Update campus feature instance"""
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance


class AwardSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Award model"""
    
    class Meta:
        model = Award
        fields = [
            'id', 'school_id', 'school_name', 'title', 'category', 'recipient',
            'student_ids', 'date', 'description', 'level', 'presented_by',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'school_id', 'school_name', 'created_at', 'updated_at']
    
    def update(self, instance, validated_data):
        """Update award instance"""
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance
