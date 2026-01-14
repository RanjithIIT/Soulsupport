"""
Views for student_parent app - API layer for App 4
"""
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone

import os
from .models import Parent, Notification, Fee, Communication, ChatMessage
from .serializers import (
    ParentSerializer, NotificationSerializer,
    FeeSerializer, CommunicationSerializer, ChatMessageSerializer,
    StudentProjectViewSerializer
)
from main_login.permissions import IsStudentParent, IsTeacher
from rest_framework import permissions
from main_login.mixins import SchoolFilterMixin
from management_admin.models import Student, Teacher, Department, CampusFeature, NewAdmission
from management_admin.serializers import StudentSerializer
from teacher.models import Exam, Timetable, Assignment, Grade, Attendance, StudyMaterial, Project, Task
from teacher.serializers import ProjectSerializer, TaskSerializer, ClassStudentSerializer as TeacherClassStudentSerializer


class ParentViewSet(SchoolFilterMixin, viewsets.ReadOnlyModelViewSet):
    """ViewSet for Parent profile"""
    queryset = Parent.objects.all()
    serializer_class = ParentSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    
    def get_queryset(self):
        """Filter by current user and prefetch related students with their schools and users"""
        return Parent.objects.filter(user=self.request.user).prefetch_related(
            'students__school', 'students__user'
        ).select_related('user')
    
    def list(self, request, *args, **kwargs):
        """Override list to return current user's parent profile as single object"""
        import logging
        logger = logging.getLogger(__name__)
        
        try:
            logger.info(f'Fetching parent profile for user: {request.user.username} (ID: {request.user.user_id}, Email: {request.user.email})')
            parent = self.get_queryset().first()
            
            if parent:
                logger.info(f'Found parent profile: ID={parent.id}, Students count={parent.students.count()}')
                serializer = self.get_serializer(parent)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                logger.warning(f'Parent profile not found for user: {request.user.username} (ID: {request.user.user_id}, Email: {request.user.email})')
                
                # Try to auto-create parent profile from Student record (student and parent are same user)
                student = Student.objects.filter(user=request.user).first()
                if not student and request.user.email:
                    # Try to find student by email
                    try:
                        student = Student.objects.get(email=request.user.email)
                        # Auto-link user if not already linked
                        if not student.user:
                            student.user = request.user
                            student.save()
                    except Student.DoesNotExist:
                        pass
                
                if student:
                    # Create parent profile from student data
                    logger.info(f'Auto-creating parent profile for user: {request.user.username} from student record')
                    try:
                        # Create parent first without accessing students
                        parent = Parent(
                            user=request.user,
                            phone=student.parent_phone or student.email or '',
                            address=student.address or 'Address not provided'
                        )
                        parent.save()  # Save first to get pk
                        # Now add the student to parent's students (ManyToMany)
                        parent.students.add(student)
                        # Save again to update school_id/school_name from student
                        parent.save()
                        
                        logger.info(f'Successfully created parent profile: ID={parent.id}')
                        serializer = self.get_serializer(parent)
                        return Response(serializer.data, status=status.HTTP_200_OK)
                    except Exception as e:
                        logger.error(f'Error auto-creating parent profile: {str(e)}', exc_info=True)
                
                # If we still don't have a parent, return error
                logger.warning(f'No parent record exists in database for user: {request.user.username}')
                return Response(
                    {
                        'error': 'Parent profile not found for this user',
                        'message': 'Please ensure your account is linked to a parent profile',
                        'user_id': str(request.user.user_id),
                        'username': request.user.username,
                        'email': request.user.email
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
        except Exception as e:
            logger.error(f'Error fetching parent profile: {str(e)}', exc_info=True)
            return Response(
                {
                    'error': f'Error fetching parent profile: {str(e)}',
                    'message': 'An error occurred while fetching your profile'
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class NotificationViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Notification management"""
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['notification_type', 'is_read']
    search_fields = ['title', 'message']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter notifications by current user"""
        return Notification.objects.filter(recipient=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'message': 'Notification marked as read'})
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = Notification.objects.filter(
            recipient=request.user,
            is_read=False
        ).count()
        return Response({'unread_count': count})


class FeeViewSet(SchoolFilterMixin, viewsets.ReadOnlyModelViewSet):
    """ViewSet for Fee viewing"""
    queryset = Fee.objects.all()
    serializer_class = FeeSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'student']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-due_date']
    
    def get_queryset(self):
        """Filter fees by student's parent or student themselves"""
        user = self.request.user
        try:
            # Check if user is a parent
            parent = Parent.objects.get(user=user)
            student_ids = parent.students.values_list('id', flat=True)
            return Fee.objects.filter(student_id__in=student_ids)
        except Parent.DoesNotExist:
            try:
                # Check if user is a student
                student = Student.objects.get(user=user)
                return Fee.objects.filter(student=student)
            except Student.DoesNotExist:
                return Fee.objects.none()
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """Get fee summary"""
        fees = self.get_queryset()
        total_pending = sum(
            float(fee.amount) for fee in fees.filter(status='pending')
        )
        total_paid = sum(
            float(fee.amount) for fee in fees.filter(status='paid')
        )
        total_overdue = sum(
            float(fee.amount) for fee in fees.filter(status='overdue')
        )
        
        return Response({
            'total_pending': total_pending,
            'total_paid': total_paid,
            'total_overdue': total_overdue,
            'total_fees': fees.count(),
        })


class CommunicationViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Communication management"""
    queryset = Communication.objects.all()
    serializer_class = CommunicationSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_read']  # Removed 'sender' and 'recipient' - handled manually in get_queryset
    search_fields = ['subject', 'message']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter communications by current user, with support for username/email-based filtering"""
        from main_login.models import User
        from django.db.models import Q
        
        # Base queryset: only messages where current user is sender or recipient
        queryset = Communication.objects.filter(
            Q(recipient=self.request.user) | Q(sender=self.request.user)
        )
        
        # Handle sender and recipient filters (expects username or email)
        # IMPORTANT: Both sender AND recipient must be specified and matched together
        # to ensure we only get messages between the specific pair
        sender_param = self.request.query_params.get('sender')
        recipient_param = self.request.query_params.get('recipient')
        
        # If both sender and recipient are provided, filter for messages between them
        if sender_param and recipient_param:
            # Find both users
            sender_user = User.objects.filter(
                Q(username=sender_param) | Q(email=sender_param)
            ).first()
            recipient_user = User.objects.filter(
                Q(username=recipient_param) | Q(email=recipient_param)
            ).first()
            
            if sender_user and recipient_user:
                # Filter for messages between these two specific users (in either direction)
                queryset = queryset.filter(
                    (Q(sender=sender_user) & Q(recipient=recipient_user)) |
                    (Q(sender=recipient_user) & Q(recipient=sender_user))
                )
            else:
                # If either user not found, return empty queryset
                queryset = queryset.none()
        elif sender_param:
            # Only sender specified - filter by sender (but still restricted to current user's conversations)
            sender_user = User.objects.filter(
                Q(username=sender_param) | Q(email=sender_param)
            ).first()
            if sender_user:
                queryset = queryset.filter(sender=sender_user)
            else:
                queryset = queryset.none()
        elif recipient_param:
            # Only recipient specified - filter by recipient (but still restricted to current user's conversations)
            recipient_user = User.objects.filter(
                Q(username=recipient_param) | Q(email=recipient_param)
            ).first()
            if recipient_user:
                queryset = queryset.filter(recipient=recipient_user)
            else:
                queryset = queryset.none()
        # If neither sender nor recipient specified, return all messages for current user
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark communication as read"""
        communication = self.get_object()
        if communication.recipient == request.user:
            communication.is_read = True
            communication.save()
            return Response({'message': 'Communication marked as read'})
        return Response(
            {'error': 'You can only mark your received messages as read'},
            status=status.HTTP_403_FORBIDDEN
        )


class IsTeacherOrStudentParent(permissions.BasePermission):
    """Allow both teachers and student/parent to access"""
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            request.user.role and
            (request.user.role.name == 'teacher' or request.user.role.name == 'student_parent')
        )


class ChatMessageViewSet(SchoolFilterMixin, viewsets.ReadOnlyModelViewSet):
    """ViewSet for ChatMessage model - Real-time chat messages (WhatsApp/Telegram-like)"""
    queryset = ChatMessage.objects.all()
    serializer_class = ChatMessageSerializer
    permission_classes = [IsAuthenticated, IsTeacherOrStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['message_type', 'is_read']
    search_fields = ['message_text']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter chat messages by current user, with support for username/email-based filtering"""
        from main_login.models import User
        from django.db.models import Q
        
        # Base queryset: only messages where current user is sender or recipient
        queryset = ChatMessage.objects.filter(
            Q(recipient=self.request.user) | Q(sender=self.request.user)
        ).filter(is_deleted=False)  # Exclude deleted messages
        
        # Handle sender and recipient filters (expects username or email)
        # IMPORTANT: Both sender AND recipient must be specified and matched together
        # to ensure we only get messages between the specific pair
        sender_param = self.request.query_params.get('sender')
        recipient_param = self.request.query_params.get('recipient')
        
        # If both sender and recipient are provided, filter for messages between them
        if sender_param and recipient_param:
            # Find both users
            sender_user = User.objects.filter(
                Q(username=sender_param) | Q(email=sender_param)
            ).first()
            recipient_user = User.objects.filter(
                Q(username=recipient_param) | Q(email=recipient_param)
            ).first()
            
            if sender_user and recipient_user:
                # Filter for messages between these two specific users (in either direction)
                queryset = queryset.filter(
                    (Q(sender=sender_user) & Q(recipient=recipient_user)) |
                    (Q(sender=recipient_user) & Q(recipient=sender_user))
                )
            else:
                # If either user not found, return empty queryset
                queryset = queryset.none()
        elif sender_param:
            # Only sender specified
            sender_user = User.objects.filter(
                Q(username=sender_param) | Q(email=sender_param)
            ).first()
            if sender_user:
                queryset = queryset.filter(sender=sender_user)
            else:
                queryset = queryset.none()
        elif recipient_param:
            # Only recipient specified
            recipient_user = User.objects.filter(
                Q(username=recipient_param) | Q(email=recipient_param)
            ).first()
            if recipient_user:
                queryset = queryset.filter(recipient=recipient_user)
            else:
                queryset = queryset.none()
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark chat message as read"""
        chat_message = self.get_object()
        if chat_message.recipient == request.user:
            chat_message.mark_as_read()
            return Response({'message': 'Message marked as read'})
        return Response(
            {'error': 'You can only mark your received messages as read'},
            status=status.HTTP_403_FORBIDDEN
        )


class StudentDashboardViewSet(viewsets.ViewSet):
    """ViewSet for Student Dashboard"""
    permission_classes = [IsAuthenticated, IsStudentParent]
    
    @action(detail=False, methods=['get'])
    def overview(self, request):
        """Get student dashboard overview"""
        user = request.user
        try:
            student = Student.objects.get(user=user)
            
            # Get recent data
            recent_attendances = Attendance.objects.filter(
                student=student
            ).order_by('-date')[:5]
            
            recent_assignments = Assignment.objects.filter(
                class_obj__class_students__student=student
            ).order_by('-created_at')[:5]
            
            recent_grades = Grade.objects.filter(
                student=student
            ).order_by('-created_at')[:5]
            
            unread_notifications = Notification.objects.filter(
                recipient=user,
                is_read=False
            ).count()
            
            return Response({
                'student_id': student.student_id,
                'class_name': student.class_name,
                'section': student.section,
                'recent_attendances_count': recent_attendances.count(),
                'recent_assignments_count': recent_assignments.count(),
                'recent_grades_count': recent_grades.count(),
                'unread_notifications': unread_notifications,
            })
        except Student.DoesNotExist:
            return Response(
                {'error': 'Student profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['get'])
    def attendance_history(self, request):
        """Get full attendance history and stats for the student"""
        user = request.user
        student = None
        
        # Determine student
        if request.query_params.get('student_id'):
            # Parent viewing specific child
            try:
                parent = Parent.objects.get(user=user)
                student = parent.students.get(id=request.query_params.get('student_id'))
            except (Parent.DoesNotExist, Student.DoesNotExist):
                 # Fallback: maybe user IS the student
                 pass
        
        if not student:
            try:
                student = Student.objects.get(user=user)
            except Student.DoesNotExist:
                 return Response(
                    {'error': 'Student profile not found'},
                    status=status.HTTP_404_NOT_FOUND
                )

        # Fetch all attendance
        attendances = Attendance.objects.filter(student=student).order_by('date')
        
        total_days = attendances.count()
        present_days = attendances.filter(status='present').count()
        absent_days = attendances.filter(status='absent').count()
        late_days = attendances.filter(status='late').count()
        
        percentage = 0.0
        if total_days > 0:
            percentage = (present_days / total_days) * 100
            
        # Group by month for chart? 
        # For now, return list + stats
        
        today = timezone.now().date()
        month_start = today.replace(day=1)
        
        return Response({
            'stats': {
                'total_days': total_days,
                'present_days': present_days,
                'absent_days': absent_days,
                'late_days': late_days,
                'percentage': round(percentage, 1),
            },
            'history': list(attendances.values('date', 'status')),
            'student_name': student.student_name,
            'class_name': student.applying_class, # or fetch class object name
        })


class StudentProjectViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Student to view Projects assigned to their class"""
    queryset = Project.objects.all()
    serializer_class = StudentProjectViewSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['subject']
    search_fields = ['title', 'description', 'subject']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-due_date']

    def get_queryset(self):
        """Filter projects by student's class or teacher"""
        user = self.request.user
        try:
            # Case 1: User is a Student
            student = Student.objects.filter(user=user).first()
            if student:
                return self._get_student_projects(student)

            # Case 2: User is a Parent
            parent = Parent.objects.filter(user=user).first()
            if parent:
                # Aggregate projects for all students linked to this parent
                all_projects = Project.objects.none()
                for student in parent.students.all():
                    student_projects = self._get_student_projects(student)
                    all_projects = all_projects | student_projects
                return all_projects.distinct()

            return Project.objects.none()

        except Exception as e:
            import logging
            print(f"DEBUG_PROJECTS ERROR: {e}")
            logger = logging.getLogger(__name__)
            logger.error(f"Error fetching student projects: {e}")
            return Project.objects.none()

    def _get_student_projects(self, student):
        """Helper to get projects for a single student"""
        # Find the classes the student is enrolled in
        from teacher.models import ClassStudent, Class
        
        # Get class IDs where this student is enrolled
        class_ids = list(ClassStudent.objects.filter(student=student).values_list('class_obj_id', flat=True))
        
        # Fallback: if no direct enrollment, try to match by class name string
        if not class_ids and student.applying_class:
            class_name = student.applying_class.lower().replace('class', '').strip()
            # Try exact match on name first
            classes = Class.objects.filter(name__iexact=class_name)
            # If no exact match, try fuzzy match
            if not classes.exists() and class_name:
                    classes = Class.objects.filter(name__icontains=class_name)
            
            if classes.exists():
                class_ids = list(classes.values_list('id', flat=True))

        from django.db.models import Q
        
        # Core Logic:
        # 1. Matches School ID (Either directly on Project OR via Teacher)
        # 2. MATCHES (Class is My Class OR Class is General/Null)
        
        # Ensure we have a school ID to filter by
        if not student.school:
             return Project.objects.none()
             
        school_id = student.school.school_id

        queryset = Project.objects.filter(
            (Q(school_id=school_id) | Q(teacher__school_id=school_id)) & 
            (Q(class_obj_id__in=class_ids) | Q(class_obj__isnull=True))
        ).distinct()
        
        return queryset


class StudentTaskViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Student to view Tasks assigned to their class"""
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated, IsStudentParent]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['subject', 'category', 'priority']
    search_fields = ['title', 'description', 'subject']
    ordering_fields = ['due_date', 'created_at']
    ordering = ['-due_date']

    def get_queryset(self):
        """Filter tasks by student's class or teacher"""
        user = self.request.user
        try:
            # Case 1: User is a Student
            student = Student.objects.filter(user=user).first()
            if student:
                return self._get_student_tasks(student)

            # Case 2: User is a Parent
            parent = Parent.objects.filter(user=user).first()
            if parent:
                # Aggregate tasks for all students linked to this parent
                all_tasks = Task.objects.none()
                for student in parent.students.all():
                    student_tasks = self._get_student_tasks(student)
                    all_tasks = all_tasks | student_tasks
                return all_tasks.distinct()

            return Task.objects.none()
                
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error fetching student tasks: {e}")
            return Task.objects.none()

    def _get_student_tasks(self, student):
        """Helper to get tasks for a single student"""
        # Find the classes the student is enrolled in
        from teacher.models import ClassStudent, Class
        
        # Get class IDs where this student is enrolled
        class_ids = list(ClassStudent.objects.filter(student=student).values_list('class_obj_id', flat=True))
        
        # Fallback: if no direct enrollment, try to match by class name string
        if not class_ids and student.applying_class:
            class_name = student.applying_class.lower().replace('class', '').strip()
            # Try exact match on name first
            classes = Class.objects.filter(name__iexact=class_name)
            # If no exact match, try fuzzy match
            if not classes.exists() and class_name:
                    classes = Class.objects.filter(name__icontains=class_name)
            
            if classes.exists():
                class_ids = list(classes.values_list('id', flat=True))

        from django.db.models import Q
        
        if not student.school:
             return Task.objects.none()
             
        school_id = student.school.school_id
        
        # Filter by School (Direct or Teacher) AND (Class match or General)
        queryset = Task.objects.filter(
            (Q(school_id=school_id) | Q(teacher__school_id=school_id)) & 
            (Q(class_obj_id__in=class_ids) | Q(class_obj__isnull=True))
        ).distinct()
        return queryset


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def student_profile(request):
    """Get current logged-in student's profile"""
    # First try to find by user relationship (use first() since ForeignKey allows multiple)
    student = Student.objects.filter(user=request.user).first()
    
    if student:
        serializer = StudentSerializer(student, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    # If not found by user, try to find by email
    if request.user.email:
        try:
            # Email is primary key, so get() is safe here
            student = Student.objects.get(email=request.user.email)
            # Auto-link the user if not already linked
            if not student.user:
                student.user = request.user
                student.save()
            serializer = StudentSerializer(student, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Student.DoesNotExist:
            pass
    
    return Response(
        {'error': 'Student profile not found for this user'},
        status=status.HTTP_404_NOT_FOUND
    )

from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from django.db.models import Q
import re
import random
import os

# Import modules to access data
from management_admin.models import Student
from teacher.models import Grade, Attendance
from student_parent.models import Parent, Fee


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsStudentParent])
def school_details(request):
    """Get school details including logo for the current student/parent"""
    try:
        from super_admin.serializers import SchoolSerializer
        
        from main_login.utils import get_user_school
        school = get_user_school(request.user)
        
        if not school:
            return Response(
                {'error': 'School not found for this user'},
                status=status.HTTP_404_NOT_FOUND
            )
            
        # Serialize school data with request context for absolute URLs
        serializer = SchoolSerializer(school, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'Error fetching school details: {str(e)}')
        return Response(
            {'error': 'Failed to fetch school details'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
