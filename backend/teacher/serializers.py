"""
Serializers for teacher app
"""
from rest_framework import serializers
from .models import (
    Class, ClassStudent, Attendance, Assignment,
    Exam, Grade, Timetable, StudyMaterial
)
from main_login.serializer_mixins import SchoolIdMixin
from management_admin.serializers import TeacherSerializer, StudentSerializer, DepartmentSerializer


class ClassSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Class model"""
    teacher = TeacherSerializer(read_only=True)
    department = DepartmentSerializer(read_only=True)
    
    class Meta:
        model = Class
        fields = [
            'id', 'school_id', 'name', 'section', 'teacher', 'department',
            'academic_year', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ClassListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for Class list/dropdown - only essential fields"""
    
    class Meta:
        model = Class
        fields = ['id', 'name', 'section']
        read_only_fields = ['id']


class ClassStudentSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for ClassStudent model"""
    class_obj = ClassSerializer(read_only=True)
    student = StudentSerializer(read_only=True)
    
    class Meta:
        model = ClassStudent
        fields = ['id', 'school_id', 'class_obj', 'student', 'enrolled_date']


class AttendanceSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Attendance model"""
    class_obj = ClassSerializer(read_only=True)
    student = StudentSerializer(read_only=True)
    marked_by = TeacherSerializer(read_only=True)
    
    class Meta:
        model = Attendance
        fields = [
            'id', 'school_id', 'class_obj', 'student', 'date', 'status',
            'marked_by', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class AssignmentSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Assignment model"""
    class_obj = ClassSerializer(read_only=True)
    teacher = TeacherSerializer(read_only=True)
    
    class Meta:
        model = Assignment
        fields = [
            'id', 'school_id', 'class_obj', 'teacher', 'title', 'description',
            'due_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ExamSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Exam model"""
    class_obj = ClassSerializer(read_only=True)
    teacher = TeacherSerializer(read_only=True)
    
    class Meta:
        model = Exam
        fields = [
            'id', 'school_id', 'class_obj', 'teacher', 'title', 'description',
            'exam_date', 'total_marks', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class GradeSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Grade model"""
    exam = ExamSerializer(read_only=True)
    student = StudentSerializer(read_only=True)
    
    class Meta:
        model = Grade
        fields = [
            'id', 'school_id', 'exam', 'student', 'marks_obtained',
            'remarks', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class TimetableSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Timetable model"""
    class_obj = ClassSerializer(read_only=True)
    class_id = serializers.PrimaryKeyRelatedField(
        queryset=Class.objects.all(), source='class_obj', write_only=True
    )
    teacher = TeacherSerializer(read_only=True)
    teacher_id = serializers.PrimaryKeyRelatedField(
        queryset=Teacher.objects.all(), source='teacher', write_only=True
    )
    
    class Meta:
        model = Timetable
        fields = [
            'id', 'school_id', 'class_obj', 'class_id', 'teacher', 'teacher_id',
            'day_of_week', 'start_time', 'end_time', 'subject', 'room', 'color',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def to_representation(self, instance):
        """Show full details for reading"""
        representation = super().to_representation(instance)
        # Ensure nested serializers are used for output
        representation['class_obj'] = ClassSerializer(instance.class_obj).data
        representation['teacher'] = TeacherSerializer(instance.teacher).data
        return representation


class StudyMaterialSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for StudyMaterial model"""
    class_obj = ClassSerializer(read_only=True)
    teacher = TeacherSerializer(read_only=True)
    
    class Meta:
        model = StudyMaterial
        fields = [
            'id', 'school_id', 'class_obj', 'teacher', 'title', 'description',
            'file_url', 'file_path', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

