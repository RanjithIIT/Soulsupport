"""
Views for teacher app - API layer for App 3
"""
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from .models import (
    Class, ClassStudent, Attendance, Assignment,
    Exam, Grade, Timetable, StudyMaterial
)
from .serializers import (
    ClassSerializer, ClassListSerializer, ClassStudentSerializer, AttendanceSerializer,
    AssignmentSerializer, ExamSerializer, GradeSerializer,
    TimetableSerializer, StudyMaterialSerializer
)
from main_login.permissions import IsTeacher, IsAdminOrTeacher
from main_login.mixins import SchoolFilterMixin
from management_admin.models import Teacher
from management_admin.serializers import TeacherSerializer
from student_parent.models import Communication
from student_parent.serializers import CommunicationSerializer
from django.db.models import Q


class ClassViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Class management"""
    queryset = Class.objects.all()
    serializer_class = ClassSerializer
    permission_classes = [IsAuthenticated, IsAdminOrTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['teacher', 'department', 'academic_year']
    search_fields = ['name', 'section']
    ordering_fields = ['name', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
<<<<<<< Updated upstream
        """Filter classes by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Class.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Class.objects.none()
=======
        """Filter classes by school_id (handled by mixin)"""
        return Class.objects.all()
    
    def get_serializer_class(self):
        """Use lightweight serializer for list action"""
        if self.action == 'list':
            return ClassListSerializer
        return ClassSerializer
>>>>>>> Stashed changes


class ClassStudentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for ClassStudent management"""
    queryset = ClassStudent.objects.all()
    serializer_class = ClassStudentSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['class_obj', 'student']
    
    def get_queryset(self):
        # Force reload
        """Filter class students by teacher's school"""
        queryset = super().get_queryset()
        
        # Get school_id for current teacher
        school_id = self.get_school_id()
        
        if school_id:
            # Filter by school_id (ClassStudent has school_id field)
            queryset = queryset.filter(school_id=school_id)
        else:
            # If no school_id, try to filter by teacher's classes
            try:
                teacher = Teacher.objects.get(user=self.request.user)
                if teacher:
                    # Get classes for this teacher and filter students in those classes
                    class_ids = Class.objects.filter(teacher=teacher).values_list('id', flat=True)
                    queryset = queryset.filter(class_obj_id__in=class_ids)
            except Teacher.DoesNotExist:
                queryset = queryset.none()
        
        return queryset


class AttendanceViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Attendance management"""
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'student', 'date', 'status']
    ordering_fields = ['date', 'created_at']
    ordering = ['-date']


class AssignmentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Assignment management"""
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher']
    search_fields = ['title', 'description']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter assignments by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Assignment.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Assignment.objects.none()


class ExamViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Exam management"""
    queryset = Exam.objects.all()
    serializer_class = ExamSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher']
    search_fields = ['title', 'description']
    ordering_fields = ['exam_date', 'created_at']
    ordering = ['-exam_date']
    
    def get_queryset(self):
        """Filter exams by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Exam.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Exam.objects.none()


class GradeViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Grade management"""
    queryset = Grade.objects.all()
    serializer_class = GradeSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['exam', 'student']
    ordering_fields = ['created_at']
    ordering = ['-created_at']


class TimetableViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Timetable management"""
    queryset = Timetable.objects.all()
    serializer_class = TimetableSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher', 'day_of_week']
    search_fields = ['subject']
    ordering_fields = ['day_of_week', 'start_time']
    ordering = ['day_of_week', 'start_time']
    
    def get_queryset(self):
        """Filter timetables by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Timetable.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Timetable.objects.none()


class StudyMaterialViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for StudyMaterial management"""
    queryset = StudyMaterial.objects.all()
    serializer_class = StudyMaterialSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher']
    search_fields = ['title', 'description']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter study materials by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return StudyMaterial.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return StudyMaterial.objects.none()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def teacher_profile(request):
    """Get current logged-in teacher's profile"""
    # First try to find by user relationship (use first() since ForeignKey allows multiple)
    teacher = Teacher.objects.filter(user=request.user).first()
    
    if teacher:
        serializer = TeacherSerializer(teacher)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    # If not found by user, try to find by email
    if request.user.email:
        teacher = Teacher.objects.filter(email=request.user.email).first()
        if teacher:
            # Auto-link the user if not already linked
            if not teacher.user:
                teacher.user = request.user
                teacher.save()
            serializer = TeacherSerializer(teacher)
            return Response(serializer.data, status=status.HTTP_200_OK)
    
    return Response(
        {'error': 'Teacher profile not found for this user'},
        status=status.HTTP_404_NOT_FOUND
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsTeacher])
def teacher_communications(request):
    """Get all communications for the current teacher"""
    # Get communications where teacher is sender or recipient
    communications = Communication.objects.filter(
        Q(sender=request.user) | Q(recipient=request.user)
    ).order_by('-created_at')
    
    serializer = CommunicationSerializer(communications, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsTeacher])
def teacher_chat_history(request):
    """Get chat history with a specific user"""
    user_id = request.query_params.get('user_id')
    if not user_id:
        return Response(
            {'error': 'user_id parameter is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        from main_login.models import User
        import uuid
        
        # Try to parse as UUID first
        try:
            uuid_obj = uuid.UUID(user_id)
            other_user = User.objects.get(user_id=uuid_obj)
        except (ValueError, User.DoesNotExist):
            # If not a valid UUID, try to find by email or username
            other_user = User.objects.filter(
                Q(email=user_id) | Q(username=user_id)
            ).first()
            
            if not other_user:
                return Response(
                    {'error': 'User not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'Error finding user for chat history: {str(e)}')
        return Response(
            {'error': f'Error finding user: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    # Get messages where current user is sender or recipient
    messages = Communication.objects.filter(
        (Q(sender=request.user) & Q(recipient=other_user)) |
        (Q(sender=other_user) & Q(recipient=request.user))
    ).order_by('created_at')
    
    serializer = CommunicationSerializer(messages, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

