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
    FeeSerializer, CommunicationSerializer, ChatMessageSerializer
)
from main_login.permissions import IsStudentParent, IsTeacher
from rest_framework import permissions
from main_login.mixins import SchoolFilterMixin
from management_admin.models import Student, Teacher, Department, CampusFeature, NewAdmission
from management_admin.serializers import StudentSerializer
from teacher.models import Exam, Timetable, Assignment, Grade, Attendance, StudyMaterial


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
        # Determine student
        if request.query_params.get('student_id'):
            # Parent viewing specific child
            sid_param = request.query_params.get('student_id')
            try:
                parent = Parent.objects.get(user=user)
                # Filter by student_id field (string) instead of id (pk)
                student = parent.students.get(student_id=sid_param)
            except (Parent.DoesNotExist, Student.DoesNotExist):
                 # Fallback: maybe user IS the student (if param passed accidentally or explicitly)
                 # Or maybe tried to query by PK? Let's try PK just in case
                 try:
                     if parent:
                         student = parent.students.get(id=sid_param)
                 except:
                     pass
        
        if not student:
            try:
                student = Student.objects.get(user=user)
                print(f"DEBUG: Found student for user {user.username}: {student.student_name} (ID: {student.student_id})")
            except Student.DoesNotExist:
                 print(f"DEBUG: Student profile not found for user {user.username}")
                 return Response(
                    {'error': 'Student profile not found'},
                    status=status.HTTP_404_NOT_FOUND
                )

        # Fetch all attendance
        attendances = Attendance.objects.filter(student=student).order_by('date')
        print(f"DEBUG: Found {attendances.count()} attendance records for {student.student_name}")
        
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

    @action(detail=False, methods=['get'])
    def day_details(self, request):
        """Get details for a specific day (Events, Exams, Homework, Attendance)"""
        user = request.user
        
        # 1. Get Date
        date_str = request.query_params.get('date')
        student_id_param = request.query_params.get('student_id')
        print(f"DEBUG: day_details called by {user.username} for date={date_str}, student_id_param={student_id_param}")

        if not date_str:
            return Response({'error': 'Date parameter is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            target_date = timezone.datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
             return Response({'error': 'Invalid date format. Use YYYY-MM-DD'}, status=status.HTTP_400_BAD_REQUEST)


        # 2. Get Student
        student = None
        student_id_param = request.query_params.get('student_id')
        print(f"DEBUG: day_details called for date={date_str}, student_id_param={student_id_param}")
        
        if student_id_param:
            try:
                parent = Parent.objects.get(user=user)
                if student_id_param.isdigit():
                    student = parent.students.get(id=student_id_param)
                else:
                    student = parent.students.get(student_id=student_id_param)
            except (Parent.DoesNotExist, Student.DoesNotExist):
                 pass
        
        if not student:
            try:
                student = Student.objects.get(user=user)
            except Student.DoesNotExist:
                 # Fallback
                 if student_id_param:
                    if student_id_param.isdigit():
                         student = Student.objects.filter(pk=student_id_param).first()
                    else:
                         student = Student.objects.filter(student_id=student_id_param).first()

                 if not student:
                     return Response({'error': 'Student profile not found'}, status=status.HTTP_404_NOT_FOUND)

        print(f"DEBUG: Found student {student.student_name} (PK: {student.pk})")

        # 3. Fetch Data
        response_data = {
            'date': date_str,
            'events': [],
            'exams': [],
            'homework': [],
            'attendance': None
        }

        # A. Attendance
        try:
            att = Attendance.objects.filter(student=student, date=target_date).first()
            if att:
                response_data['attendance'] = {
                    'status': att.status,
                    'remarks': att.remarks
                }
        except Exception as e:
            print(f"Error fetching attendance: {e}")

        # B. Events (School-wide for now)
        try:
            from management_admin.models import Event
            # Filter events that encompass this date
            events = Event.objects.filter(
                school_id=student.school_id
            ).filter(
                Q(start_datetime__date=target_date) | 
                Q(end_datetime__date=target_date) |
                (Q(start_datetime__date__lte=target_date) & Q(end_datetime__date__gte=target_date))
            )
            
            for event in events:
                response_data['events'].append({
                    'title': event.name,
                    'time': event.start_datetime.strftime('%I:%M %p') if event.start_datetime else 'All Day',
                    'category': event.category
                })
        except Exception as e:
             print(f"Error fetching events: {e}")

        # C. Exams & D. Homework (Shared Class IDs)
        target_classes = []
        try:
            from teacher.models import Class
            class_id_param = request.query_params.get('class_id')
            section_id_param = request.query_params.get('section_id')

            # 1. Try resolving class_id_param
            if class_id_param:
                if class_id_param.isdigit():
                    cls = Class.objects.filter(id=class_id_param).first()
                    if cls:
                        target_classes.append(cls)
                
                # If still no classes, try it as a name
                if not target_classes:
                    name_filter = Class.objects.filter(name__iexact=class_id_param)
                    if section_id_param:
                        name_filter = name_filter.filter(section__iexact=section_id_param)
                    target_classes = list(name_filter)
            
            # 2. Try direct links via ClassStudent
            if not target_classes:
                student_classes = student.student_classes.select_related('class_obj').all()
                if student_classes.exists():
                     target_classes = [sc.class_obj for sc in student_classes]
            
            # 3. Fallback to applying_class (Fuzzy matching)
            if not target_classes and student.applying_class:
                # 1. Try exact match on name
                fallback_classes = Class.objects.filter(name__iexact=student.applying_class)
                
                # 2. Try match with section if grade is provided
                if not fallback_classes.exists() and student.grade:
                     fallback_classes = Class.objects.filter(name__iexact=student.applying_class, section__iexact=student.grade)
                
                # 3. Try parsing "Name - Section"
                if not fallback_classes.exists() and ' - ' in student.applying_class:
                    parts = student.applying_class.split(' - ')
                    fallback_classes = Class.objects.filter(name__iexact=parts[0].strip(), section__iexact=parts[1].strip())

                # 4. Final fallback: icontains and stripping "Class "
                if not fallback_classes.exists():
                    query_name = student.applying_class
                    if query_name.lower().startswith('class '):
                        query_name = query_name[6:].strip()
                        fallback_classes = Class.objects.filter(name__iexact=query_name)
                    
                    if not fallback_classes.exists():
                        fallback_classes = Class.objects.filter(name__icontains=student.applying_class)
                
                if fallback_classes.exists():
                    target_classes = list(fallback_classes)

            print(f"DEBUG: target_classes found: {[f'{c.name}-{c.section}' for c in target_classes]}")
            
            if target_classes:
                class_ids = [c.id for c in target_classes]
                # Fetch Exams for these classes (Filter by date in Python to be safe)
                all_exams = Exam.objects.filter(
                    class_obj__id__in=class_ids
                ).select_related('class_obj')
                
                print(f"DEBUG: Checking {all_exams.count()} total exams for date match: {target_date}")
                
                for exam in all_exams:
                    exam_server_date = exam.exam_date.date()
                    print(f"DEBUG: Exam '{exam.title}' date: {exam_server_date} vs Target: {target_date}")
                    
                    if exam_server_date == target_date:
                        response_data['exams'].append({
                            'id': exam.id,
                            'title': exam.title,
                            'subject': exam.subject or exam.title,
                            'description': exam.description,
                            'time': exam.exam_date.strftime('%I:%M %p'),
                            'duration': f"{exam.duration_minutes} min" if exam.duration_minutes else 'N/A',
                            'type': exam.exam_type or 'Exam',
                            'className': f"{exam.class_obj.name} - {exam.class_obj.section}"
                        })

                # Fetch Homework (Assignments)
                assignments = Assignment.objects.filter(
                     class_obj__id__in=class_ids, 
                     due_date__date=target_date
                 ).select_related('class_obj')
                 
                print(f"DEBUG: Found {assignments.count()} assignments")

                for asm in assignments:
                     response_data['homework'].append({
                         'subject': asm.subject or asm.title, 
                         'title': asm.title,
                         'description': asm.description[:50],
                         'status': 'pending',
                         'type': asm.assignment_type or 'Homework'
                     })

        except Exception as e:
            print(f"Error fetching exams/homework: {e}")
            import traceback
            traceback.print_exc()

        return Response(response_data)

    @action(detail=False, methods=['get'])
    def student_exams(self, request):
        """Get all exams for the student (past and upcoming)"""
        user = request.user
        
        # 1. Get Student
        student = None
        student_id_param = request.query_params.get('student_id')
        class_id_param = request.query_params.get('class_id')
        section_id_param = request.query_params.get('section_id')
        

        
        response_data = []

        # COLLECT TARGET CLASSES BASED ON PARAMS
        target_classes = []
        from teacher.models import Class
        
        # 1. Try resolving class_id_param
        if class_id_param:
            if class_id_param.isdigit():
                cls = Class.objects.filter(id=class_id_param).first()
                if cls:
                    target_classes.append(cls)
            
            # If still no classes, try it as a name
            if not target_classes:
                name_filter = Class.objects.filter(name__iexact=class_id_param)
                if section_id_param:
                    name_filter = name_filter.filter(section__iexact=section_id_param)
                target_classes = list(name_filter)
        
        # 2. If only section is provided
        elif section_id_param:
             # This is unusual but we can try to find classes for this section 
             # (might need school filter but Strategy 2 handles student context better)
             pass

        if target_classes:

            # Map students if needed for grades
            student = None
            if student_id_param:
                if student_id_param.isdigit():
                    student = Student.objects.filter(pk=student_id_param).first()
                else:
                    student = Student.objects.filter(student_id=student_id_param).first()

            for cls in target_classes:
                exams = Exam.objects.filter(class_obj=cls).order_by('-exam_date')
                for exam in exams:
                    exam_data = {
                        'id': exam.id,
                        'title': exam.title,
                        'subject': exam.subject or exam.title,
                        'description': exam.description,
                        'examType': exam.exam_type or 'Exam',
                        'exam_date': exam.exam_date.isoformat() if exam.exam_date else None,
                        'date': exam.exam_date.strftime('%Y-%m-%d') if exam.exam_date else None,
                        'start_time': exam.exam_date.strftime('%I:%M %p') if exam.exam_date else 'TBA',
                        'total_marks': exam.total_marks,
                        'duration': f"{exam.duration_minutes} mins" if exam.duration_minutes else "N/A",
                        'room': exam.room_no or "TBA",
                    }
                    
                    # More robust teacher name resolution
                    try:
                        if exam.class_obj and exam.class_obj.teacher and exam.class_obj.teacher.user:
                             exam_data['teacher'] = exam.class_obj.teacher.user.username
                        elif exam.teacher and exam.teacher.user:
                             exam_data['teacher'] = exam.teacher.user.username
                        else:
                             exam_data['teacher'] = "TBA"
                    except:
                        exam_data['teacher'] = "TBA"
                    
                    # Try to fetch grade
                    grade_entry = None
                    if student:
                        grade_entry = Grade.objects.filter(exam=exam, student=student).first()
                    
                    if grade_entry:
                        exam_data['score'] = grade_entry.marks_obtained
                        exam_data['status'] = 'completed'
                        try:
                            percentage = (float(grade_entry.marks_obtained) / float(exam.total_marks)) * 100
                            if percentage >= 90: exam_data['grade'] = 'A'
                            elif percentage >= 80: exam_data['grade'] = 'B'
                            elif percentage >= 70: exam_data['grade'] = 'C'
                            elif percentage >= 60: exam_data['grade'] = 'D'
                            else: exam_data['grade'] = 'F'
                        except:
                            exam_data['grade'] = 'N/A'
                    else:
                        exam_data['score'] = 0
                        exam_data['grade'] = '-'
                        exam_data['status'] = 'upcoming' if exam.exam_date > timezone.now() else 'pending'

                    response_data.append(exam_data)
            
            return Response(response_data)
        
        # STRATEGY 2: FALLBACK TO STUDENT LOOKUP
        print(f"DEBUG: Strategy 2 - Fallback to student lookup. ID: {student_id_param}")
        if student_id_param:
            try:
                parent = Parent.objects.get(user=user)
                if student_id_param.isdigit():
                    student = parent.students.get(id=student_id_param)
                else:
                    student = parent.students.get(student_id=student_id_param)
            except (Parent.DoesNotExist, Student.DoesNotExist):
                 pass
        
        if not student:
            try:
                student = Student.objects.get(user=user)
            except Student.DoesNotExist:
                 # Fallback direct lookup
                 if student_id_param:
                    if student_id_param.isdigit():
                         student = Student.objects.filter(pk=student_id_param).first()
                    else:
                         student = Student.objects.filter(student_id=student_id_param).first()

                 if not student:
                     print("DEBUG: Student not found for exam lookup")
                     return Response({'error': 'Student profile not found'}, status=status.HTTP_404_NOT_FOUND)
        
        print(f"DEBUG: Found student {student.student_name} (PK: {student.pk}). Checking linked classes...")

        # 2. Fetch Exams for Student's Classes
        # 2. Fetch Exams for Student's Classes
        try:

            
            # STRATEGY 3: FALLBACK TO applying_class IF NO LINKED CLASSES
            # If the M2M table is empty, try to match by string name (e.g. "Class 5")
            student_classes = student.student_classes.all()
            print(f"DEBUG: Student {student.student_name} has {student_classes.count()} direct class links.")
            
            # STRATEGY 2 & 3
            target_classes = []
            if student_classes.exists():
                target_classes = [sc.class_obj for sc in student_classes]
            else:

                if student.applying_class:
                    from teacher.models import Class
                    # 1. Try exact match on name
                    fallback_classes = Class.objects.filter(name__iexact=student.applying_class)
                    
                    # 2. Try match with section if grade is provided
                    if not fallback_classes.exists() and student.grade:
                         print(f"DEBUG: Trying name='{student.applying_class}', section='{student.grade}'")
                         fallback_classes = Class.objects.filter(name__iexact=student.applying_class, section__iexact=student.grade)
                    
                    # 3. Try parsing "Name - Section" if it's in applying_class
                    if not fallback_classes.exists() and ' - ' in student.applying_class:
                        parts = student.applying_class.split(' - ')
                        print(f"DEBUG: Parsing '{student.applying_class}' into {parts}")
                        fallback_classes = Class.objects.filter(name__iexact=parts[0].strip(), section__iexact=parts[1].strip())

                    # 4. Final fallback: icontains and stripping "Class "
                    if not fallback_classes.exists():
                        query_name = student.applying_class
                        if query_name.lower().startswith('class '):
                            query_name = query_name[6:].strip()
                            print(f"DEBUG: Stripped 'Class ' from query, checking for '{query_name}'")
                            fallback_classes = Class.objects.filter(name__iexact=query_name)
                        
                        if not fallback_classes.exists():
                            print(f"DEBUG: Exact matches failed. Trying icontains on '{student.applying_class}'")
                            fallback_classes = Class.objects.filter(name__icontains=student.applying_class)
                    
                    if fallback_classes.exists():
                        target_classes = list(fallback_classes)
                        print(f"DEBUG: Fallback found {len(target_classes)} classes: {[f'{c.name}-{c.section}' for c in target_classes]}")
                    else:
                        print(f"DEBUG: No classes found matching '{student.applying_class}'")

            if not target_classes:
                return Response([])
                
            for cls in target_classes:
                # Fetch exams for this class
                exams = Exam.objects.filter(class_obj=cls).order_by('-exam_date')
                
                for exam in exams:
                    # Check for Grade
                    grade_entry = Grade.objects.filter(exam=exam, student=student).first()
                    
                    exam_data = {
                        'id': exam.id,
                        'title': exam.title,
                        'subject': exam.subject or exam.title,
                        'description': exam.description,
                        'examType': exam.exam_type or 'Exam',
                        'exam_date': exam.exam_date.isoformat() if exam.exam_date else None,
                        'date': exam.exam_date.strftime('%Y-%m-%d') if exam.exam_date else None,
                        'start_time': exam.exam_date.strftime('%I:%M %p') if exam.exam_date else 'TBA',
                        'total_marks': exam.total_marks,
                        'duration': f"{exam.duration_minutes} mins" if exam.duration_minutes else "N/A",
                        'room': exam.room_no or "TBA",
                    }
                    
                    # More robust teacher name resolution
                    try:
                        if cls and cls.teacher and cls.teacher.user:
                             exam_data['teacher'] = cls.teacher.user.username
                        elif exam.teacher and exam.teacher.user:
                             exam_data['teacher'] = exam.teacher.user.username
                        else:
                             exam_data['teacher'] = "TBA"
                    except:
                        exam_data['teacher'] = "TBA"
                    
                    if grade_entry:
                        exam_data['score'] = grade_entry.marks_obtained
                        exam_data['status'] = 'completed'
                        # Calculate letter grade
                        try:
                            percentage = (float(grade_entry.marks_obtained) / float(exam.total_marks)) * 100
                            if percentage >= 90: exam_data['grade'] = 'A'
                            elif percentage >= 80: exam_data['grade'] = 'B'
                            elif percentage >= 70: exam_data['grade'] = 'C'
                            elif percentage >= 60: exam_data['grade'] = 'D'
                            else: exam_data['grade'] = 'F'
                        except:
                             exam_data['grade'] = 'N/A'
                    else:
                        exam_data['score'] = 0
                        exam_data['grade'] = '-'
                        exam_data['status'] = 'upcoming' if exam.exam_date > timezone.now() else 'pending'

                    response_data.append(exam_data)
                    
        except Exception as e:
            print(f"Error fetching student exams: {e}")
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response(response_data)


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
