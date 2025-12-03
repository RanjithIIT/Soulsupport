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
    
    class Meta:
        model = Teacher
        fields = [
            'id', 'user', 'school', 'school_name', 'department',
            'department_name', 'employee_id', 'designation',
            'hire_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class StudentSerializer(serializers.ModelSerializer):
    """Serializer for Student model"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    
    class Meta:
        model = Student
        fields = [
            'id', 'user', 'school', 'school_name', 'student_id',
            'class_name', 'section', 'admission_date',
            'parent_name', 'parent_phone', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


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

