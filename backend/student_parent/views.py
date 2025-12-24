"""
Views for student_parent app - API layer for App 4
"""
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from .models import Parent, Notification, Fee, Communication
from .serializers import (
    ParentSerializer, NotificationSerializer,
    FeeSerializer, CommunicationSerializer
)
from main_login.permissions import IsStudentParent
from main_login.mixins import SchoolFilterMixin
from management_admin.models import Student
from management_admin.serializers import StudentSerializer


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
                # Check if parent exists at all for this user
                parent_exists = Parent.objects.filter(user=request.user).exists()
                if not parent_exists:
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
    filterset_fields = ['sender', 'recipient', 'is_read']
    search_fields = ['subject', 'message']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter communications by current user, with support for username/email-based filtering"""
        from main_login.models import User
        from django.db.models import Q
        
        queryset = Communication.objects.filter(
            Q(recipient=self.request.user) | Q(sender=self.request.user)
        )
        
        # Handle sender and recipient filters (expects username or email)
        sender_param = self.request.query_params.get('sender')
        recipient_param = self.request.query_params.get('recipient')
        
        if sender_param:
            # Try to find user by username or email
            sender_user = User.objects.filter(
                Q(username=sender_param) | Q(email=sender_param)
            ).first()
            if sender_user:
                queryset = queryset.filter(sender=sender_user)
            else:
                # If not found, return empty queryset
                queryset = queryset.none()
        
        if recipient_param:
            # Try to find user by username or email
            recipient_user = User.objects.filter(
                Q(username=recipient_param) | Q(email=recipient_param)
            ).first()
            if recipient_user:
                queryset = queryset.filter(recipient=recipient_user)
            else:
                # If not found, return empty queryset
                queryset = queryset.none()
        
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


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def student_profile(request):
    """Get current logged-in student's profile"""
    # First try to find by user relationship (use first() since ForeignKey allows multiple)
    student = Student.objects.filter(user=request.user).first()
    
    if student:
        serializer = StudentSerializer(student)
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
            serializer = StudentSerializer(student)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Student.DoesNotExist:
            pass
    
    return Response(
        {'error': 'Student profile not found for this user'},
        status=status.HTTP_404_NOT_FOUND
    )

