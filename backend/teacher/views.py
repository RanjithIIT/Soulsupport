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
    ClassSerializer, ClassStudentSerializer, AttendanceSerializer,
    AssignmentSerializer, ExamSerializer, GradeSerializer,
    TimetableSerializer, StudyMaterialSerializer
)
from main_login.permissions import IsTeacher
from main_login.mixins import SchoolFilterMixin
from management_admin.models import Teacher, Student
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
             # Return all classes for the school, not just assigned classes
            if teacher.school_id:
                return Class.objects.filter(school_id=teacher.school_id)
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

    @action(detail=False, methods=['get'])
    def get_students_for_attendance(self, request):
        """
        Get students for a specific class and section for attendance marking.
        Query params: class_name, section, date (optional)
        """
        class_name = request.query_params.get('class_name')
        section = request.query_params.get('section')
        date_str = request.query_params.get('date')
        
        if not class_name or not section:
            return Response(
                {'error': 'class_name and section are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            # 1. Ensure Class object exists
            # We map Student.applying_class -> Class.name, Student.grade -> Class.section
            # Also need to associate with teacher/school if creating new
            user = request.user
            teacher = Teacher.objects.filter(user=user).first()
            if not teacher:
                return Response({'error': 'Teacher profile not found'}, status=status.HTTP_404_NOT_FOUND)
            
            # Find or create the class
            # Note: This auto-creates a Class record effectively syncing the string fields to the relational model
            class_obj, created = Class.objects.get_or_create(
                name=class_name,
                section=section,
                defaults={
                    'teacher': teacher,
                    'academic_year': '2025-2026', # Default current year
                    'school_id': teacher.school_id,
                    'school_name': teacher.school_name
                }
            )
            
            # 2. Fetch Students from Student model directly
            # This ensures we get the "real" students from Admission
            students = Student.objects.filter(
                applying_class=class_name,
                grade=section
            ).order_by('student_name')

            # Filter by school if possible to avoid cross-school data leak
            if teacher.school_id:
                students = students.filter(school__school_id=teacher.school_id)
            
            # 3. Fetch existing attendance for the date
            attendance_map = {}
            if date_str:
                attendances = Attendance.objects.filter(
                    class_obj=class_obj,
                    date=date_str
                )
                for att in attendances:
                    attendance_map[att.student_id] = {
                        'status': att.status,
                        'id': att.id,
                        'remarks': att.remarks
                    }
            
            # 4. Construct Response
            student_data = []
            for student in students:
                # Generate a roll number if not existing (UI needs it)
                roll_no = student.admission_number or f"ROLL-{student.pk}"
                
                att_info = attendance_map.get(str(student.pk), {}) # pk is email/string usually
                if not att_info:
                    # check integer id if pk is not matching
                    att_info = attendance_map.get(student.user_id, {})
                
                student_data.append({
                    'id': student.pk, # This is the email or primary key
                    'name': student.student_name,
                    'rollNo': roll_no,
                    'avatarInitials': "".join([n[0] for n in student.student_name.split()[:2]]).upper(),
                    'status': att_info.get('status', 'present'), # Default to present
                    'attendance_id': att_info.get('id'),
                    'remarks': att_info.get('remarks', '')
                })
                
            return Response({
                'class_id': class_obj.id,
                'students': student_data
            })
            
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error fetching students for attendance: {str(e)}")
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['post'])
    def bulk_save_attendance(self, request):
        """
        Bulk save attendance records.
        Body: {
            "class_id": 1,
            "date": "2025-01-08",
            "records": [
                {"student_id": "email@example.com", "status": "present"},
                ...
            ]
        }
        """
        class_id = request.data.get('class_id')
        date_str = request.data.get('date')
        records = request.data.get('records', [])
        
        if not class_id or not date_str:
            return Response({'error': 'class_id and date are required'}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            teacher = Teacher.objects.get(user=request.user)
            class_obj = Class.objects.get(id=class_id)
            
            created_count = 0
            updated_count = 0
            
            for record in records:
                student_id = record.get('student_id')
                status_val = record.get('status')
                
                # Verify student exists
                try:
                    student = Student.objects.get(pk=student_id)
                except Student.DoesNotExist:
                    continue
                
                # Update or Create
                obj, created = Attendance.objects.update_or_create(
                    class_obj=class_obj,
                    student=student,
                    date=date_str,
                    defaults={
                        'status': status_val,
                        'remarks': record.get('remarks', ''),
                        'student_name': student.student_name,
                        'teacher_name': f"{teacher.first_name} {teacher.last_name or ''}".strip() or teacher.employee_no,
                        'marked_by': teacher,
                        'school_id': teacher.school_id,
                        'school_name': teacher.school_name
                    }
                )
                
                if created:
                    created_count += 1
                else:
                    updated_count += 1
                    
            return Response({
                'message': 'Attendance saved successfully',
                'created': created_count,
                'updated': updated_count
            })
            
        except Class.DoesNotExist:
            return Response({'error': 'Class not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


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
            
    def perform_create(self, serializer):
        """Create exam and corresponding assignment"""
        exam = serializer.save()
        
        # Auto-create assignment for this exam
        try:
            # Ensure school info is present
            school_id = exam.school_id
            school_name = exam.school_name
            if not school_id and exam.class_obj and exam.class_obj.school_id:
                 school_id = exam.class_obj.school_id
                 school_name = exam.class_obj.school_name

            # Pack all data into description (single line as requested)
            desc_parts = []
            if exam.description:
                desc_parts.append(f"{exam.description}")
            if exam.instructions:
                desc_parts.append(f"Instructions: {exam.instructions}")
            if exam.exam_type:
                desc_parts.append(f"Type: {exam.exam_type}")
            if exam.duration_minutes:
                desc_parts.append(f"Duration: {exam.duration_minutes} min")
            if exam.total_marks:
                desc_parts.append(f"Marks: {exam.total_marks}")
            if exam.room_no:
                desc_parts.append(f"Room: {exam.room_no}")

            full_description = " | ".join(desc_parts)

            Assignment.objects.create(
                class_obj=exam.class_obj,
                teacher=exam.teacher,
                school_id=school_id,
                school_name=school_name,
                title=f"Exam: {exam.title}",
                description=full_description,
                due_date=exam.exam_date
            )
        except Exception as e:
            # Log error but don't fail the request if assignment creation fails
            print(f"Failed to auto-create assignment for exam {exam.id}: {e}")


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
        teacher = Teacher.objects.get(user=request.user)
        
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
            'totalTimetableSlots': total_timetable
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
