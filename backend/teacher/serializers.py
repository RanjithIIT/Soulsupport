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
from management_admin.models import Teacher


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
            'marked_by', 'remarks', 'student_name', 'teacher_name', 'created_at'
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
            'instructions', 'subject', 'assignment_type', 'total_marks',
            'due_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ExamSerializer(SchoolIdMixin, serializers.ModelSerializer):
    """Serializer for Exam model"""
    class_obj = ClassSerializer(read_only=True)
    teacher = TeacherSerializer(read_only=True)
    class_id = serializers.PrimaryKeyRelatedField(
        queryset=Class.objects.all(), source='class_obj', write_only=True
    )
    
    class Meta:
        model = Exam
        fields = [
            'id', 'school_id', 'class_obj', 'class_id', 'teacher', 'title', 
            'description', 'instructions', 'subject', 'exam_type', 
            'duration_minutes', 'room_no',
            'exam_date', 'total_marks', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
        
    def create(self, validated_data):
        # Auto-assign teacher
        user = self.context['request'].user
        try:
            teacher = Teacher.objects.get(user=user)
            validated_data['teacher'] = teacher
        except Teacher.DoesNotExist:
            raise serializers.ValidationError("Teacher profile not found for current user")
            
        return super().create(validated_data)


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
    teacher = TeacherSerializer(read_only=True)
    
    class Meta:
        model = Timetable
        fields = [
            'id', 'school_id', 'class_obj', 'teacher', 'day_of_week',
            'start_time', 'end_time', 'subject', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


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

