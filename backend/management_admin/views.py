"""
Views for management_admin app - API layer for App 2
"""
import random
import string
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from .models import File, Department, Teacher, Student, DashboardStats, NewAdmission, Examination_management, Fee, PaymentHistory, Bus, BusStop, BusStopStudent, Event, Award, CampusFeature
from super_admin.models import School
from .serializers import (
    FileSerializer,
    DepartmentSerializer,
    TeacherSerializer,
    StudentSerializer,
    DashboardStatsSerializer,
    NewAdmissionSerializer,
    ExaminationManagementSerializer,
    FeeSerializer,
    BusSerializer,
    BusStopSerializer,
    BusStopStudentSerializer,
    EventSerializer,
    AwardSerializer,
    CampusFeatureSerializer
)
from main_login.permissions import IsManagementAdmin
from main_login.mixins import SchoolFilterMixin
from main_login.utils import get_user_school_id


class FileViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for File uploads (profile photos)"""
    queryset = File.objects.all()
    serializer_class = FileSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['file_type', 'school_id']
    search_fields = ['file_name']
    ordering_fields = ['created_at']
    ordering = ['-created_at']
    
    def perform_create(self, serializer):
        """Set uploaded_by and school_id when creating file"""
        school_id = get_user_school_id(self.request.user)
        serializer.save(
            uploaded_by=self.request.user,
            school_id=school_id
        )



# Teacher ViewSet


class TeacherViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Teacher management"""
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['department', 'is_active']
    search_fields = ['user__first_name', 'user__last_name', 'employee_no', 'email', 'first_name', 'last_name']
    ordering_fields = ['joining_date', 'created_at']
    ordering = ['-created_at']

    def get_permissions(self):
        """Require authentication for list/retrieve to ensure school filtering works"""
        # Changed: Require authentication for list/retrieve to enable school filtering
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]  # Changed from AllowAny() to ensure school filtering
        if self.action in ['create', 'destroy']:
            return [AllowAny()]  # Keep AllowAny for create/destroy if needed
        return [IsAuthenticated(), IsManagementAdmin()]
    
    def perform_create(self, serializer):
        """Override to ensure school_id is set correctly when creating teachers"""
        school_id = self.get_school_id()
        
        # Check if user is super admin
        if hasattr(self.request.user, 'role') and self.request.user.role:
            if self.request.user.role.name == 'super_admin':
                # Super admin can set school_id manually or leave it
                # If school_id is provided in data, use it; otherwise let it be set from department
                super().perform_create(serializer)
                # After save, ensure school_id is set from department if not already set
                teacher = serializer.instance
                if teacher and teacher.department and teacher.department.school:
                    department_school_id = teacher.department.school.school_id
                    if not teacher.school_id or teacher.school_id != department_school_id:
                        teacher.school_id = department_school_id
                        teacher.save(update_fields=['school_id'])
                return
        
        # For non-super-admin users, automatically set school_id
        serializer.save()
        
        # After save, ensure school_id is set
        teacher = serializer.instance
        if teacher:
            # First, try to get school_id from department's school
            if teacher.department and teacher.department.school:
                department_school_id = teacher.department.school.school_id
                if not teacher.school_id or teacher.school_id != department_school_id:
                    teacher.school_id = department_school_id
                    teacher.save(update_fields=['school_id'])
            # If no department or department has no school, use school_id from user context
            elif school_id and not teacher.school_id:
                teacher.school_id = school_id
                teacher.save(update_fields=['school_id'])
    
    def create(self, request, *args, **kwargs):
        """
        Override create to allow creation even if school_id is not found initially.
        school_id will be auto-populated from department when teacher is saved.
        This completely bypasses the SchoolFilterMixin.create() check.
        Also handles profile photo upload.
        """
        # Handle profile photo upload if present
        profile_photo_file = request.FILES.get('profile_photo')
        profile_photo_url = None
        
        if profile_photo_file:
            # Save file and get the URL/path
            from django.core.files.storage import default_storage
            from django.utils import timezone
            import os
            
            # Generate filename with timestamp to avoid conflicts
            file_ext = os.path.splitext(profile_photo_file.name)[1]
            timestamp = timezone.now().strftime('%Y%m%d_%H%M%S')
            filename = f'profile_photos/{timestamp}_{profile_photo_file.name}'
            
            # Save file using default storage
            saved_path = default_storage.save(filename, profile_photo_file)
            # Get the URL for the saved file
            profile_photo_url = default_storage.url(saved_path)
        
        # Prepare data for serializer
        data = request.data.copy()
        if 'profile_photo' in data:
            if profile_photo_file:
                # Remove the file from data, we'll add the URL instead
                del data['profile_photo']
            elif isinstance(data['profile_photo'], str):
                # If profile_photo is already a string (URL), use it
                profile_photo_url = data['profile_photo']
        
        if profile_photo_url:
            data['profile_photo'] = profile_photo_url
        
        # Get serializer
        serializer = self.get_serializer(data=data)
        
        # Validate and log errors if validation fails
        if not serializer.is_valid():
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Teacher creation validation failed: {serializer.errors}")
            logger.error(f"Request data: {data}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        # Call perform_create which will handle school_id assignment
        # This allows creation even if school_id is not found (will be set from department)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
    
    def get_queryset(self):
        """
        Override to filter by school_id using SchoolFilterMixin logic.
        Now all list/retrieve requests are authenticated, so filtering will always work.
        """
        # Call SchoolFilterMixin's get_queryset to get proper filtering
        queryset = super(SchoolFilterMixin, self).get_queryset()
        
        # All requests should be authenticated now (due to permission change above)
        # But keep the check for safety
        if not self.request.user.is_authenticated:
            return queryset.none()  # Changed: Return empty instead of all teachers
        
        # Check if user is super admin
        if hasattr(self.request.user, 'role') and self.request.user.role:
            if self.request.user.role.name == 'super_admin':
                # Super admin can see all teachers
                return queryset
        
        # Get school_id for filtering
        school_id = self.get_school_id()
        
        # Debug logging
        import logging
        logger = logging.getLogger(__name__)
        logger.debug(f"TeacherViewSet - User: {self.request.user.username}, School ID: {school_id}")
        
        # For non-super-admin users, filter by school_id
        if school_id:
            # Filter by school_id
            queryset = queryset.filter(school_id=school_id)
            logger.debug(f"Filtered teachers by school_id={school_id}, count: {queryset.count()}")
        else:
            logger.warning(f"No school_id found for user {self.request.user.username}")
            # If no school_id found for authenticated user, return empty queryset
            return queryset.none()
        
        return queryset


class StudentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Student management"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'applying_class', 'category', 'gender']
    search_fields = ['student_name', 'parent_name', 'admission_number', 'email']
    ordering_fields = ['created_at', 'student_name']
    ordering = ['-created_at']

    def get_permissions(self):
        """Require authentication for list/retrieve to ensure school filtering works"""
        # Changed: Require authentication for list/retrieve to enable school filtering
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]  # Changed from AllowAny() to ensure school filtering
        if self.action in ['create', 'destroy']:
            return [AllowAny()]  # Keep AllowAny for create/destroy if needed
        return [IsAuthenticated(), IsManagementAdmin()]
    
    def get_queryset(self):
        """
        Override to ensure school_id filtering is applied when user is authenticated.
        Now all list/retrieve requests are authenticated, so filtering will always work.
        """
        # Get base queryset
        queryset = super(SchoolFilterMixin, self).get_queryset()
        
        # All requests should be authenticated now (due to permission change above)
        # But keep the check for safety
        if not self.request.user.is_authenticated:
            return queryset.none()  # Changed: Return empty instead of all students
        
        # For authenticated users, apply school filtering via SchoolFilterMixin
        # Check if user is super admin (should see all data)
        if hasattr(self.request.user, 'role') and self.request.user.role:
            if self.request.user.role.name == 'super_admin':
                return queryset
        
        # Get school_id for current user
        school_id = self.get_school_id()
        
        # Debug logging
        import logging
        logger = logging.getLogger(__name__)
        logger.debug(f"StudentViewSet - User: {self.request.user.username}, School ID: {school_id}")
        
        if not school_id:
            logger.warning(f"No school_id found for user {self.request.user.username}")
            # If no school_id found for authenticated user, return empty queryset
            return queryset.none()
        
        # Filter by school_id (Student model has 'school' ForeignKey)
        queryset = queryset.filter(school__school_id=school_id)
        logger.debug(f"Filtered students by school__school_id={school_id}, count: {queryset.count()}")
        
        return queryset
    
    def perform_create(self, serializer):
        """Override to ensure school is set correctly when creating students"""
        school_id = self.get_school_id()
        
        # Check if user is super admin
        if hasattr(self.request.user, 'role') and self.request.user.role:
            if self.request.user.role.name == 'super_admin':
                # Super admin can set school manually or leave it
                # If school is provided in data, use it; otherwise let it be set manually
                if 'school' not in serializer.validated_data:
                    # Try to get school from request data
                    school_id_from_request = self.request.data.get('school')
                    if school_id_from_request:
                        from super_admin.models import School
                        try:
                            school = School.objects.get(school_id=school_id_from_request)
                            serializer.save(school=school)
                            return
                        except School.DoesNotExist:
                            pass
                super().perform_create(serializer)
                return
        
        # For non-super-admin users, automatically set school
        if school_id:
            from super_admin.models import School
            try:
                school = School.objects.get(school_id=school_id)
                # Always set school, even if provided in data (to prevent cross-school data)
                serializer.save(school=school)
                return
            except School.DoesNotExist:
                pass
        
        # If no school_id found and user is authenticated, this is an error
        if self.request.user.is_authenticated:
            from rest_framework.exceptions import ValidationError
            raise ValidationError({
                'school': 'No school associated with your account. Please contact administrator.'
            })
        
        # If user is not authenticated, try to use school from serializer if provided
        # Otherwise, let parent handle it (might fail validation)
        student = serializer.save()
        
        # Auto-link user if email matches and user exists
        if student.email:
            from main_login.models import User
            try:
                user = User.objects.get(email=student.email)
                if not student.user:
                    student.user = user
                    student.save()
            except User.DoesNotExist:
                pass
        
        return student


class NewAdmissionViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for New Admission management"""
    queryset = NewAdmission.objects.all()
    serializer_class = NewAdmissionSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'applying_class', 'category', 'gender', 'student_id']
    search_fields = ['student_name', 'parent_name', 'parent_phone', 'email', 'admission_number', 'student_id']
    ordering_fields = ['created_at', 'status', 'student_name']
    ordering = ['-created_at']
    
    def create(self, request, *args, **kwargs):
        """Override create to provide better error messages"""
        import logging
        import traceback
        logger = logging.getLogger(__name__)
        
        # Log incoming request data for debugging
        logger.info(f"Admission creation request from user: {request.user.username}")
        logger.debug(f"Request data: {request.data}")
        
        serializer = self.get_serializer(data=request.data)
        
        if not serializer.is_valid():
            # Log validation errors
            logger.error(f"Validation failed for admission creation")
            logger.error(f"Validation errors: {serializer.errors}")
            logger.error(f"Request data received: {request.data}")
            
            return Response(
                {
                    'success': False,
                    'message': 'Validation error',
                    'errors': serializer.errors,
                    'received_data': {k: v for k, v in request.data.items()},  # Include received data for debugging
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            self.perform_create(serializer)
            headers = self.get_success_headers(serializer.data)
            
            # Get generated password from context
            generated_password = serializer.context.get('generated_password', None)
            
            # Prepare response data
            response_data = serializer.data.copy()
            if generated_password:
                response_data['generated_password'] = generated_password
                response_data['login_credentials'] = {
                    'email': serializer.data.get('email'),
                    'password': generated_password,
                    'message': 'Please save these credentials. You can use them to login once admission is approved.'
                }
            
            logger.info(f"Admission created successfully: {serializer.data.get('student_id')}")
            return Response(
                {
                    'success': True,
                    'message': 'Admission created successfully. User account created with generated password.',
                    'data': response_data,
                },
                status=status.HTTP_201_CREATED,
                headers=headers
            )
        except Exception as e:
            # Log exception details
            logger.error(f"Exception during admission creation: {str(e)}")
            logger.error(traceback.format_exc())
            
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'error': 'Failed to create admission',
                    'error_type': type(e).__name__,
                },
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def perform_create(self, serializer):
        """Override to handle admission creation - user creation is done in serializer"""
        # The serializer's create method already handles user creation
        # Just save the admission (which will call serializer.create())
        admission = serializer.save()
        
        # Get generated password from serializer if set (the serializer's create method sets this)
        generated_password = getattr(serializer, 'generated_password', None)
        if generated_password:
            serializer.context['generated_password'] = generated_password
        
        return admission
    
    def update(self, request, *args, **kwargs):
        """Override update to provide better error messages and handle partial updates"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        old_status = instance.status
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if not serializer.is_valid():
            return Response(
                {
                    'success': False,
                    'message': 'Validation error',
                    'errors': serializer.errors,
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Get the new status from validated data
            new_status = serializer.validated_data.get('status', old_status)
            
            # Perform the update
            self.perform_update(serializer)
            
            # Refresh instance to get updated data
            instance.refresh_from_db()
            
            # If status changed to 'Approved', create Student record
            created_student = None
            if old_status != 'Approved' and new_status == 'Approved':
                try:
                    created_student = instance.create_student_from_admission()
                except Exception as e:
                    return Response(
                        {
                            'success': False,
                            'message': f'Admission approved but failed to create student record: {str(e)}',
                            'error': 'Failed to create student',
                        },
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            if getattr(instance, '_prefetched_objects_cache', None):
                instance._prefetched_objects_cache = {}
            
            # Prepare response data
            response_data = serializer.data.copy()
            if created_student:
                # Include student information in response
                student_serializer = StudentSerializer(created_student)
                response_data['created_student'] = student_serializer.data
                message = 'Admission approved and student record created successfully'
            else:
                message = 'Admission updated successfully'
            
            return Response(
                {
                    'success': True,
                    'message': message,
                    'data': response_data,
                },
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'error': 'Failed to update admission',
                },
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'], url_path='approve')
    def approve(self, request, pk=None):
        """
        Custom action to approve an admission and create Student record.
        POST /api/management-admin/admissions/{id}/approve/
        """
        admission = self.get_object()
        
        if admission.status == 'Approved':
            return Response(
                {
                    'success': False,
                    'message': 'Admission is already approved',
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update status to Approved
        old_status = admission.status
        admission.status = 'Approved'
        
        # Generate admission number if not provided
        if not admission.admission_number:
            import datetime
            counter = 0
            max_attempts = 1000  # Prevent infinite loops
            while counter < max_attempts:
                # Use current timestamp with microseconds and add random component for uniqueness
                now = datetime.datetime.now()
                timestamp = now.strftime('%Y%m%d%H%M%S%f')
                random_suffix = ''.join(random.choices(string.digits, k=3))  # Add 3 random digits
                admission_number = f'ADM-{now.year}-{timestamp[-9:]}{random_suffix}'  # Use last 9 chars + 3 random
                
                # Check uniqueness
                if not Student.objects.filter(admission_number=admission_number).exists() and \
                   not NewAdmission.objects.filter(admission_number=admission_number).exists():
                    break
                counter += 1
            
            if counter >= max_attempts:
                # Fallback: use timestamp with milliseconds and random string
                now = datetime.datetime.now()
                random_str = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
                admission_number = f'ADM-{now.year}-{now.strftime("%m%d%H%M%S")}{random_str}'
            
            admission.admission_number = admission_number
        
        admission.save()
        
        # Create Student record
        created_student = None
        try:
            created_student = admission.create_student_from_admission()
        except Exception as e:
            # Rollback status if student creation fails
            admission.status = old_status
            admission.save()
            return Response(
                {
                    'success': False,
                    'message': f'Failed to create student record: {str(e)}',
                    'error': 'Student creation failed',
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Serialize response
        serializer = self.get_serializer(admission)
        response_data = serializer.data.copy()
        
        if created_student:
            student_serializer = StudentSerializer(created_student)
            response_data['created_student'] = student_serializer.data
        
        return Response(
            {
                'success': True,
                'message': 'Admission approved and student record created successfully',
                'data': response_data,
            },
            status=status.HTTP_200_OK
        )
    


class DashboardViewSet(viewsets.ViewSet):
    """ViewSet for Dashboard data"""
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get dashboard statistics"""
        # Get school associated with the user (assuming user has a school)
        # This would need to be implemented based on your user-school relationship
        stats = DashboardStats.objects.first()  # Placeholder
        
        if stats:
            serializer = DashboardStatsSerializer(stats)
            return Response(serializer.data)
        
        return Response({
            'total_teachers': 0,
            'total_students': 0,
            'total_departments': 0,
        })


class ExaminationManagementViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Examination Management"""
    queryset = Examination_management.objects.all()
    serializer_class = ExaminationManagementSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['Exam_Type', 'Exam_Status']
    search_fields = ['Exam_Title', 'Exam_Description', 'Exam_Location']
    ordering_fields = ['Exam_Date', 'Exam_Created_At', 'Exam_Title']
    ordering = ['-Exam_Created_At']
    
    def get_permissions(self):
        """Allow read/create/update/delete without auth for development - can be adjusted"""
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]


class FeeViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Fee Management"""
    queryset = Fee.objects.select_related('student').prefetch_related('payment_history').all()
    serializer_class = FeeSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['fee_type', 'status', 'frequency', 'grade', 'student']
    search_fields = ['student__student_name', 'description', 'fee_type']
    ordering_fields = ['due_date', 'created_at', 'total_amount']
    ordering = ['-due_date']
    
    def get_permissions(self):
        """Allow read/create/update/delete without auth for development - can be adjusted"""
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]
    
    def get_queryset(self):
        """Override to ensure school_id filtering is applied"""
        queryset = super().get_queryset()
        
        # Check if user is super admin
        if hasattr(self.request.user, 'role') and self.request.user.role:
            if self.request.user.role.name == 'super_admin':
                return queryset
        
        # Get school_id for filtering
        school_id = self.get_school_id()
        if school_id:
            # Filter by school_id
            queryset = queryset.filter(school_id=school_id)
        else:
            # If no school_id and user is authenticated (not super admin), return empty
            if self.request.user.is_authenticated:
                return queryset.none()
        
        return queryset
    
    def list(self, request, *args, **kwargs):
        """Override list to ensure proper response format and handle errors gracefully"""
        try:
            # Get queryset (already filtered by school_id via get_queryset)
            queryset = self.get_queryset()
            
            # Apply additional filters if any
            queryset = self.filter_queryset(queryset)
            
            # Serialize the data
            serializer = self.get_serializer(queryset, many=True)
            data = serializer.data
            
            return Response(data)
        except Exception as e:
            import traceback
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f"Error in FeeViewSet.list: {e}")
            logger.error(traceback.format_exc())
            
            return Response(
                {'error': str(e), 'detail': 'An error occurred while fetching fees'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], url_path='record-payment')
    def record_payment(self, request, pk=None):
        """Record a payment for a fee and create payment history"""
        try:
            fee = self.get_object()
            payment_amount = request.data.get('payment_amount')
            payment_date = request.data.get('payment_date')
            receipt_number = request.data.get('receipt_number', '')
            notes = request.data.get('notes', '')
            
            if not payment_amount:
                return Response(
                    {'error': 'payment_amount is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            try:
                payment_amount = float(payment_amount)
            except (ValueError, TypeError):
                return Response(
                    {'error': 'payment_amount must be a valid number'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Parse payment date or use today
            from datetime import date
            if payment_date:
                try:
                    from datetime import datetime
                    payment_date_obj = datetime.strptime(payment_date, '%Y-%m-%d').date()
                except ValueError:
                    payment_date_obj = date.today()
            else:
                payment_date_obj = date.today()
            
            # Create payment history record
            from django.utils import timezone
            payment_history = PaymentHistory.objects.create(
                fee=fee,
                payment_amount=payment_amount,
                payment_date=payment_date_obj,
                receipt_number=receipt_number,
                notes=notes
            )
            print(f"Created payment history: ID={payment_history.id}, Amount={payment_history.payment_amount}, Date={payment_history.payment_date}, Created={payment_history.created_at}")
            
            # Update fee with new payment (cumulative)
            # Set last_paid_date (will be set even for first payment)
            fee.last_paid_date = payment_date_obj
            
            # Update paid_amount cumulatively
            from decimal import Decimal
            fee.paid_amount = Decimal(str(fee.paid_amount)) + Decimal(str(payment_amount))
            
            # Recalculate due amount (will be recalculated in save() method too)
            fee.due_amount = Decimal(str(fee.total_amount)) - Decimal(str(fee.paid_amount))
            
            # Update status (using Decimal comparison)
            if fee.paid_amount >= fee.total_amount:
                fee.status = 'paid'
            elif fee.paid_amount > Decimal('0'):
                fee.status = 'pending'
            
            # Save the fee (this will trigger the save() method which recalculates due_amount)
            fee.save()
            print(f"Fee saved: ID={fee.id}, paid_amount={fee.paid_amount}, due_amount={fee.due_amount}, last_paid_date={fee.last_paid_date}, status={fee.status}")
            
            # Reload from database to ensure we have the latest data including payment history
            fee = Fee.objects.prefetch_related('payment_history').select_related('student').get(pk=fee.pk)
            
            # Verify the calculations
            print(f"Fee after refresh from database:")
            print(f"  - total_amount: {fee.total_amount}")
            print(f"  - paid_amount: {fee.paid_amount}")
            print(f"  - due_amount: {fee.due_amount}")
            print(f"  - last_paid_date: {fee.last_paid_date}")
            print(f"  - calculated due: {float(fee.total_amount) - float(fee.paid_amount)}")
            print(f"  - payment_history count: {fee.payment_history.count()}")
            
            # Return updated fee with payment history
            serializer = self.get_serializer(fee)
            serialized_data = serializer.data
            print(f"Serialized data:")
            print(f"  - paid_amount: {serialized_data.get('paid_amount')}")
            print(f"  - due_amount: {serialized_data.get('due_amount')}")
            print(f"  - last_paid_date: {serialized_data.get('last_paid_date')}")
            print(f"  - payment_history items: {len(serialized_data.get('payment_history', []))}")
            return Response(serialized_data, status=status.HTTP_200_OK)
            
        except Fee.DoesNotExist:
            return Response(
                {'error': 'Fee not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            import traceback
            print(f"Error recording payment: {e}")
            print(traceback.format_exc())
            return Response(
                {'error': str(e), 'detail': 'An error occurred while recording payment'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['put', 'patch'], url_path='payment-history/(?P<payment_id>[^/.]+)')
    def update_payment_history(self, request, pk=None, payment_id=None):
        """Update a payment history record and recalculate fee totals"""
        try:
            fee = self.get_object()
            
            # Get the payment history record
            try:
                payment_history = PaymentHistory.objects.get(id=payment_id, fee=fee)
            except PaymentHistory.DoesNotExist:
                return Response(
                    {'error': 'Payment history record not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get old payment amount before update
            old_amount = float(payment_history.payment_amount)
            
            # Update payment history fields
            if 'payment_amount' in request.data:
                try:
                    new_amount = float(request.data.get('payment_amount'))
                    payment_history.payment_amount = new_amount
                except (ValueError, TypeError):
                    return Response(
                        {'error': 'payment_amount must be a valid number'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            if 'payment_date' in request.data:
                from datetime import date, datetime
                payment_date = request.data.get('payment_date')
                if payment_date:
                    try:
                        payment_date_obj = datetime.strptime(payment_date, '%Y-%m-%d').date()
                        payment_history.payment_date = payment_date_obj
                    except ValueError:
                        pass  # Keep existing date if invalid
            
            if 'receipt_number' in request.data:
                payment_history.receipt_number = request.data.get('receipt_number', '')
            
            if 'notes' in request.data:
                payment_history.notes = request.data.get('notes', '')
            
            payment_history.save()
            print(f"Updated payment history: ID={payment_history.id}, Amount={payment_history.payment_amount}, Date={payment_history.payment_date}")
            
            # Refresh fee from database to get updated payment_history
            fee.refresh_from_db()
            fee = Fee.objects.prefetch_related('payment_history').select_related('student').get(pk=fee.pk)
            
            # Recalculate fee's paid_amount by summing all payment history
            from decimal import Decimal
            total_paid = Decimal('0')
            payment_count = 0
            for payment in fee.payment_history.all():
                total_paid += Decimal(str(payment.payment_amount))
                payment_count += 1
                print(f"Payment {payment_count}: ID={payment.id}, Amount={payment.payment_amount}")
            
            print(f"Total paid calculated: {total_paid}, from {payment_count} payments")
            fee.paid_amount = total_paid
            
            # Recalculate due amount
            fee.due_amount = Decimal(str(fee.total_amount)) - fee.paid_amount
            print(f"Fee amounts - Total: {fee.total_amount}, Paid: {fee.paid_amount}, Due: {fee.due_amount}")
            
            # Update last_paid_date to the most recent payment date
            latest_payment = fee.payment_history.order_by('-payment_date').first()
            if latest_payment:
                fee.last_paid_date = latest_payment.payment_date
                print(f"Last paid date updated to: {fee.last_paid_date}")
            
            # Update status
            if fee.paid_amount >= fee.total_amount:
                fee.status = 'paid'
            elif fee.paid_amount > Decimal('0'):
                fee.status = 'pending'
            else:
                fee.status = 'pending'
            
            fee.save()
            print(f"Fee saved: ID={fee.id}, paid_amount={fee.paid_amount}, due_amount={fee.due_amount}, status={fee.status}")
            
            # Reload from database one more time to ensure we have the latest data
            fee = Fee.objects.prefetch_related('payment_history').select_related('student').get(pk=fee.pk)
            
            # Return updated fee with payment history
            serializer = self.get_serializer(fee)
            return Response(serializer.data, status=status.HTTP_200_OK)
            
        except Fee.DoesNotExist:
            return Response(
                {'error': 'Fee not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            import traceback
            print(f"Error updating payment history: {e}")
            print(traceback.format_exc())
            return Response(
                {'error': str(e), 'detail': 'An error occurred while updating payment history'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BusViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Bus management"""
    queryset = Bus.objects.all()
    serializer_class = BusSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    lookup_field = 'bus_number'  # Use bus_number as primary key for lookups
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'bus_type', 'is_active']
    search_fields = ['bus_number', 'driver_name', 'route_name', 'registration_number']
    ordering_fields = ['bus_number', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Optimize queryset with prefetch_related for stops and students"""
        queryset = super().get_queryset()
        # Prefetch stops and their students to avoid N+1 queries
        queryset = queryset.prefetch_related(
            'stops__stop_students__student',
            'stops__bus'
        ).select_related('school')
        return queryset
    
    def create(self, request, *args, **kwargs):
        """Override create to automatically get school from logged-in user if not provided"""
        # Get school from request data if provided
        school_id = request.data.get('school')
        
        # If school_id not provided, try to get it from the logged-in user
        if not school_id:
            try:
                school = School.objects.filter(user=request.user).first()
                if not school:
                    return Response(
                        {
                            'success': False,
                            'message': 'No school found. Please contact administrator to assign a school to your account.',
                            'error': 'School not found'
                        },
                        status=status.HTTP_404_NOT_FOUND
                    )
                # Create mutable copy of request data and add school_id
                mutable_data = request.data.copy()
                if hasattr(mutable_data, '_mutable'):
                    mutable_data._mutable = True
                mutable_data['school'] = school.school_id
                # Update request data
                request._full_data = mutable_data
            except Exception as e:
                return Response(
                    {
                        'success': False,
                        'message': f'Error getting school: {str(e)}',
                        'error': 'Failed to get school'
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        # Call parent create method
        return super().create(request, *args, **kwargs)


class BusStopViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for BusStop management"""
    queryset = BusStop.objects.all()
    serializer_class = BusStopSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    lookup_field = 'stop_id'  # Explicitly set lookup field to stop_id (CharField: busnumber_stopnumber)
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['route_type']  # Removed 'bus' from here, will handle manually
    search_fields = ['stop_name']
    ordering_fields = ['stop_order', 'stop_time']
    ordering = ['bus', 'route_type', 'stop_order']
    
    def get_queryset(self):
        """Override to handle bus filter by bus_number instead of bus_id"""
        queryset = super().get_queryset()
        
        # Handle bus filter - if bus parameter is provided, filter by bus__bus_number
        bus_param = self.request.query_params.get('bus')
        if bus_param:
            queryset = queryset.filter(bus__bus_number=bus_param)
        
        return queryset
    
    @action(detail=True, methods=['get'])
    def students(self, request, *args, **kwargs):
        """Get all students for a specific stop.
        For afternoon stops, returns students from the corresponding morning stop (matched by stop_name).
        """
        # get_object() automatically uses the lookup_field (stop_id) to find the object
        # Using *args, **kwargs to avoid parameter name conflicts with custom lookup_field
        stop = self.get_object()
        
        # If this is an afternoon stop, get students from corresponding morning stop
        if stop.route_type == 'afternoon':
            # Find corresponding morning stop with same stop_name
            try:
                corresponding_morning_stop = BusStop.objects.filter(
                    bus=stop.bus,
                    route_type='morning',
                    stop_name=stop.stop_name
                ).first()
                
                if corresponding_morning_stop:
                    # Return students from corresponding morning stop
                    students = corresponding_morning_stop.stop_students.all()
                else:
                    # Fallback to afternoon stop's own students if no corresponding morning stop
                    students = stop.stop_students.all()
            except Exception:
                # Fallback to afternoon stop's own students on error
                students = stop.stop_students.all()
        else:
            # For morning stops, return students directly assigned to this stop
            students = stop.stop_students.all()
        
        serializer = BusStopStudentSerializer(students, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'], url_path='drop-off-view')
    def drop_off_view(self, request, pk=None):
        """
        Get drop-off view for the first morning stop.
        Returns the last drop-off stop information if this is the first morning stop.
        """
        stop = self.get_object()
        
        # Check if this is the first morning stop
        if stop.route_type == 'morning' and stop.stop_order == 1:
            drop_off_stop = stop.corresponding_drop_off_stop
            if drop_off_stop:
                serializer = BusStopSerializer(drop_off_stop)
                return Response({
                    'success': True,
                    'message': 'Drop-off stop information for first morning stop',
                    'first_morning_stop': BusStopSerializer(stop).data,
                    'last_drop_off_stop': serializer.data
                })
            else:
                return Response({
                    'success': False,
                    'message': 'No drop-off stop found. The last drop-off stop will be created automatically when saved.',
                    'first_morning_stop': BusStopSerializer(stop).data
                })
        else:
            return Response({
                'success': False,
                'message': 'This endpoint is only available for the first morning stop (stop_order=1, route_type=morning)'
            }, status=status.HTTP_400_BAD_REQUEST)


class BusStopStudentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for BusStopStudent management"""
    queryset = BusStopStudent.objects.all()
    serializer_class = BusStopStudentSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['bus_stop', 'student']
    search_fields = ['student_name', 'student_id_string', 'student__student_id', 'student__student_name']
    ordering_fields = ['created_at']
    ordering = ['bus_stop', 'student_name']
    
    def create(self, request, *args, **kwargs):
        """Override create to fetch student by student_id and validate school match"""
        student_id = request.data.get('student_id')
        stop_id = request.data.get('stop')
        
        if not student_id:
            return Response(
                {'error': 'student_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not stop_id:
            return Response(
                {'error': 'stop is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            stop = BusStop.objects.select_related('bus', 'bus__school').get(pk=stop_id)
        except BusStop.DoesNotExist:
            return Response(
                {'error': 'Stop not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Get the bus and its school
        bus = stop.bus
        bus_school = bus.school
        
        if not bus_school:
            return Response(
                {'error': 'Bus does not have an associated school'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Find student by student_id and filter by school_id to ensure it belongs to the same school
            student = Student.objects.select_related('school').get(
                student_id=student_id,
                school=bus_school
            )
        except Student.DoesNotExist:
            return Response(
                {
                    'error': f'Student with ID {student_id} not found in school {bus_school.school_name}. Please ensure the student belongs to the same school as the bus.',
                    'school_id': str(bus_school.school_id)
                },
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Additional validation: ensure student's school matches bus's school
        if student.school != bus_school:
            return Response(
                {
                    'error': f'Student belongs to a different school. Bus belongs to {bus_school.school_name}, but student belongs to {student.school.school_name}',
                    'bus_school_id': str(bus_school.school_id),
                    'student_school_id': str(student.school.school_id)
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if student is already assigned to this stop
        if BusStopStudent.objects.filter(bus_stop=stop, student=student).exists():
            return Response(
                {'error': 'Student is already assigned to this stop'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if student is already assigned to any other stop of the same bus
        existing_assignment = BusStopStudent.objects.filter(
            bus_stop__bus=bus,
            student=student
        ).select_related('bus_stop').first()
        
        if existing_assignment:
            return Response(
                {
                    'error': f'Student is already assigned to another stop: {existing_assignment.bus_stop.stop_name} (Stop {existing_assignment.bus_stop.stop_order}, {existing_assignment.bus_stop.get_route_type_display()})',
                    'existing_stop_name': existing_assignment.bus_stop.stop_name,
                    'existing_stop_order': existing_assignment.bus_stop.stop_order,
                    'existing_route_type': existing_assignment.bus_stop.route_type,
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create the BusStopStudent
        bus_stop_student = BusStopStudent.objects.create(
            bus_stop=stop,
            student=student
        )
        
        serializer = self.get_serializer(bus_stop_student)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class SchoolViewSet(viewsets.ViewSet):
    """ViewSet for getting current user's school"""
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    
    @action(detail=False, methods=['get'], url_path='current')
    def current(self, request):
        """Get the school associated with the current logged-in user"""
        from super_admin.models import School
        from super_admin.serializers import SchoolSerializer
        
        try:
            # Get school from user's school_account relationship
            school = School.objects.filter(user=request.user).first()
            
            if not school:
                return Response(
                    {
                        'success': False,
                        'message': 'No school found for this user. Please contact administrator.',
                        'error': 'School not found'
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
            
            serializer = SchoolSerializer(school)
            return Response(
                {
                    'success': True,
                    'data': serializer.data
                },
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'error': 'Failed to fetch school'
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class EventViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Event management"""
    queryset = Event.objects.all()
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'status', 'date']
    search_fields = ['name', 'location', 'organizer', 'description']
    ordering_fields = ['date', 'created_at', 'name']
    ordering = ['-date', '-created_at']
    
    def get_permissions(self):
        """Allow read/create/update/delete without auth for development - can be adjusted"""
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]
    
    def perform_create(self, serializer):
        """Set school_id when creating event"""
        event = serializer.save()
        
        # Set school_id after save (since it's read-only in serializer)
        school_id = self.get_school_id()
        if school_id:
            from super_admin.models import School
            Event.objects.filter(pk=event.pk).update(school_id=school_id)
            try:
                school = School.objects.get(school_id=school_id)
                Event.objects.filter(pk=event.pk).update(school_name=school.school_name)
            except School.DoesNotExist:
                pass
    
    def perform_update(self, serializer):
        """Update event - school_id should already be set"""
        serializer.save()


class DepartmentViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Department management"""
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['name', 'code']
    search_fields = ['name', 'code', 'head_name', 'email']
    ordering_fields = ['name', 'faculty_count', 'student_count']
    ordering = ['name']

    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]

    def perform_create(self, serializer):
        """Set school reference when creating department"""
        department = serializer.save()
        
        school_id = self.get_school_id()
        if school_id:
            from super_admin.models import School
            try:
                school = School.objects.get(school_id=school_id)
                Department.objects.filter(pk=department.pk).update(
                    school=school,
                    school_name=school.school_name
                )
            except School.DoesNotExist:
                pass


class CampusFeatureViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for CampusFeature management"""
    queryset = CampusFeature.objects.all()
    serializer_class = CampusFeatureSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'status']
    search_fields = ['name', 'description', 'location']
    ordering_fields = ['name', 'category', 'date_added']
    ordering = ['-date_added']

    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]

    def perform_create(self, serializer):
        """Set school reference when creating campus feature"""
        feature = serializer.save()
        
        school_id = self.get_school_id()
        if school_id:
            from super_admin.models import School
            try:
                school = School.objects.get(school_id=school_id)
                CampusFeature.objects.filter(pk=feature.pk).update(
                    school=school,
                    school_name=school.school_name
                )
            except School.DoesNotExist:
                pass


class AwardViewSet(SchoolFilterMixin, viewsets.ModelViewSet):
    """ViewSet for Award management"""
    queryset = Award.objects.all()
    serializer_class = AwardSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'level', 'date']
    search_fields = ['title', 'recipient', 'description']
    ordering_fields = ['date', 'created_at', 'title']
    ordering = ['-date', '-created_at']
    
    def get_permissions(self):
        """Allow read/create/update/delete without auth for development - can be adjusted"""
        if self.action in ['list', 'retrieve', 'create', 'update', 'partial_update', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]
    
    def perform_create(self, serializer):
        """Set school_id when creating award"""
        award = serializer.save()
        
        # Set school_id after save (since it's read-only in serializer)
        school_id = self.get_school_id()
        if school_id:
            from super_admin.models import School
            Award.objects.filter(pk=award.pk).update(school_id=school_id)
            try:
                school = School.objects.get(school_id=school_id)
                Award.objects.filter(pk=award.pk).update(school_name=school.school_name)
            except School.DoesNotExist:
                pass
    
    def perform_update(self, serializer):
        """Update award - school_id should already be set"""
        serializer.save()
