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
    Exam, Grade, Timetable, StudyMaterial, Project, StudentProject, Task
)
from .serializers import (
    ClassSerializer, ClassStudentSerializer, AttendanceSerializer,
    AssignmentSerializer, ExamSerializer, GradeSerializer,
    TimetableSerializer, StudyMaterialSerializer,
    ProjectSerializer, StudentProjectSerializer, TaskSerializer
)
from main_login.permissions import IsTeacher
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
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['teacher', 'department', 'academic_year']
    search_fields = ['name', 'section']
    ordering_fields = ['name', 'created_at']
    ordering = ['-created_at']
    pagination_class = None # Show all classes for dropdowns

    
    def get_queryset(self):
        """Filter classes by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Class.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Class.objects.none()


class ClassStudentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for ClassStudent management"""
    queryset = ClassStudent.objects.all()
    serializer_class = ClassStudentSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['class_obj', 'student']
    
    def get_queryset(self):
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


class ProjectViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Project management"""
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    permission_classes = [IsAuthenticated, IsTeacher]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher', 'subject']
    search_fields = ['title', 'description']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter projects by current teacher"""
        user = self.request.user
        try:
            teacher = Teacher.objects.get(user=user)
            return Project.objects.filter(teacher=teacher)
        except Teacher.DoesNotExist:
            return Project.objects.none()

    def perform_create(self, serializer):
        """Auto-assign teacher on create"""
        try:
            # Use filter().first() to be safe against multiple objects (though unlikely)
            teacher = Teacher.objects.filter(user=self.request.user).first()
            if teacher:
                serializer.save(teacher=teacher)
            else:
                from rest_framework.exceptions import ValidationError
                raise ValidationError({"detail": "No Teacher profile found for this user."})
        except Exception as e:
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": f"Failed to assign teacher: {str(e)}"})


class StudentProjectViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Student Project Status management"""
    queryset = StudentProject.objects.all()
    serializer_class = StudentProjectSerializer
    permission_classes = [IsAuthenticated] # Allow both teachers and students
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['project', 'student', 'status']
    
    def get_queryset(self):
        """Filter projects based on user role"""
        user = self.request.user
        
        # If student, return their own projects
        if hasattr(user, 'student_profile'):
            return StudentProject.objects.filter(student=user.student_profile)
            
        # If teacher, return projects for their classes
        if hasattr(user, 'teacher_profile'):
            return StudentProject.objects.filter(project__teacher=user.teacher_profile)
            
        return StudentProject.objects.none()


class TaskViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Task management"""
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated] # Allow both teachers and students
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['class_obj', 'teacher', 'category', 'priority']
    search_fields = ['title', 'description', 'subject']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter tasks based on user role"""
        user = self.request.user
        
        # If student, return tasks for their class
        if hasattr(user, 'student_profile') and user.student_profile.current_class:
            return Task.objects.filter(class_obj=user.student_profile.current_class)
            
        # If teacher, return tasks created by them
        # Safe lookup for teacher
        teacher = Teacher.objects.filter(user=user).first()
        if teacher:
            return Task.objects.filter(teacher=teacher)
            
        return Task.objects.none()

    def perform_create(self, serializer):
        """Auto-assign teacher on create"""
        try:
            teacher = Teacher.objects.filter(user=self.request.user).first()
            if teacher:
                serializer.save(teacher=teacher)
            else:
                from rest_framework.exceptions import ValidationError
                raise ValidationError({"detail": "No Teacher profile found for this user."})
        except Exception as e:
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": f"Failed to assign teacher: {str(e)}"})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def teacher_profile(request):
    """Get current logged-in teacher's profile"""
    # First try to find by user relationship (use first() since ForeignKey allows multiple)
    teacher = Teacher.objects.filter(user=request.user).first()
    
    if teacher:
        serializer = TeacherSerializer(teacher, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    # If not found by user, try to find by email
    if request.user.email:
        teacher = Teacher.objects.filter(email=request.user.email).first()
        if teacher:
            # Auto-link the user if not already linked
            if not teacher.user:
                teacher.user = request.user
                teacher.save()
            serializer = TeacherSerializer(teacher, context={'request': request})
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

@api_view(['GET'])
@permission_classes([IsAuthenticated, IsTeacher])
def school_details(request):
    """Get school details including logo for the current teacher"""
    try:
        from super_admin.serializers import SchoolSerializer
        
        from main_login.utils import get_user_school
        school = get_user_school(request.user)
            
        if not school:
            return Response(
                {'error': 'School not found for this teacher'},
                status=status.HTTP_404_NOT_FOUND
            )
            
        # Serialize school data with request context for absolute URLs
        serializer = SchoolSerializer(school, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'Error fetching school details: {str(e)}')
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsTeacher])
def dashboard_stats(request):
    """Get aggregated dashboard statistics for the teacher"""
    try:
        # Use filter().first() to match the pattern in ViewSets
        teacher = Teacher.objects.filter(user=request.user).first()
        if not teacher:
            return Response(
                {'error': 'Teacher profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # 1. Classes and Students
        classes = Class.objects.filter(teacher=teacher)
        total_classes = classes.count()
        
        # Get unique student count across all classes
        # ClassStudent -> student
        student_ids = ClassStudent.objects.filter(
            class_obj__in=classes
        ).values_list('student_id', flat=True).distinct()
        total_students = student_ids.count()
        
        # 2. Upcoming Exams (future dates)
        now = timezone.now()
        upcoming_exams = Exam.objects.filter(
            teacher=teacher,
            exam_date__gte=now
        ).count()
        
        # 3. Pending Assignments (due date in future)
        pending_assignments = Assignment.objects.filter(
            teacher=teacher,
            due_date__gte=now
        ).count()
        
        # 4. Total Results (Grades given)
        # Assuming simple count of grades created by this teacher? 
        # Or distinct exams graded? The mock said "Total Results". 
        # Let's count total grades marked.
        total_results = Grade.objects.filter(
            exam__teacher=teacher
        ).count()
        
        # 5. Attendance Rate (Last 30 days)
        thirty_days_ago = now.date() - timezone.timedelta(days=30)
        attendances = Attendance.objects.filter(
            class_obj__in=classes,
            date__gte=thirty_days_ago
        )
        total_recs = attendances.count()
        present_recs = attendances.filter(status='present').count()
        
        attendance_rate_str = "0%"
        if total_recs > 0:
            rate = (present_recs / total_recs) * 100
            attendance_rate_str = f"{round(rate, 1)}%"
            
        # 6. Class Breakdown for UI
        classes_data = []
        for cls in classes:
            # Count students in this class
            cnt = ClassStudent.objects.filter(class_obj=cls).count()
            # Get subject if possible - Class model behaves like subject-based class in some systems,
            # but here Class model has 'name' (e.g. 10A).
            # The mock had 'subjects' list. Here we assume the class itself covers generalized subjects?
            # Or maybe we fetch subjects from Timetable?
            # For MVP, let's just return the class name and student count.
            subjects = Timetable.objects.filter(class_obj=cls).values_list('subject', flat=True).distinct()
            
            classes_data.append({
                'name': f"{cls.name} - {cls.section}",
                'students': cnt,
                'subjects': list(subjects) if subjects else ['General']
            })
            
        # 7. Other metrics for mock parity
        total_attendance_records = Attendance.objects.filter(class_obj__in=classes).count()
        total_study_materials = StudyMaterial.objects.filter(teacher=teacher).count()
        total_communications = Communication.objects.filter(
            Q(sender=request.user) | Q(recipient=request.user)
        ).count()
        total_timetable = Timetable.objects.filter(teacher=teacher).count()
        
        # New metrics for Projects and Tasks
        total_projects = Project.objects.filter(teacher=teacher).count()
        total_tasks = Task.objects.filter(teacher=teacher).count()
        
        data = {
            'totalStudents': total_students,
            'totalClasses': total_classes,
            'upcomingExams': upcoming_exams,
            'pendingAssignments': pending_assignments,
            'totalResults': total_results,
            'attendanceRate': attendance_rate_str,
            'avgGrade': 'B+', # Placeholder as grade calculation is complex
            'classes': classes_data,
            'totalAttendanceRecords': total_attendance_records,
            'totalStudyMaterials': total_study_materials,
            'totalGradesPending': 0, # Placeholder
            'totalCommunication': total_communications,
            'totalTimetableSlots': total_timetable,
            'projectsCount': total_projects,
            'tasksCount': total_tasks
        }
        
        return Response(data, status=status.HTTP_200_OK)
        
    except Teacher.DoesNotExist:
        return Response(
            {'error': 'Teacher profile not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'Error aggregating dashboard stats: {str(e)}')
        return Response(
            {'error': 'Failed to load dashboard stats'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
