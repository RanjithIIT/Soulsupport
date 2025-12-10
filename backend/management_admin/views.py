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
from .models import Department, Teacher, Student, DashboardStats, NewAdmission
from .serializers import (
    DepartmentSerializer,
    TeacherSerializer,
    StudentSerializer,
    DashboardStatsSerializer,
    NewAdmissionSerializer
)
from main_login.permissions import IsManagementAdmin


class DepartmentViewSet(viewsets.ModelViewSet):
    """ViewSet for Department management"""
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'head']
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    ordering = ['-created_at']


class TeacherViewSet(viewsets.ModelViewSet):
    """ViewSet for Teacher management"""
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['department', 'designation', 'is_active']
    search_fields = ['user__first_name', 'user__last_name', 'employee_no', 'designation', 'email', 'first_name', 'last_name']
    ordering_fields = ['joining_date', 'created_at']
    ordering = ['-created_at']

    def get_permissions(self):
        """Allow read/create/delete without auth to match frontend behavior"""
        if self.action in ['list', 'retrieve', 'create', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]


class StudentViewSet(viewsets.ModelViewSet):
    """ViewSet for Student management"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'applying_class', 'category', 'gender']
    search_fields = ['student_name', 'parent_name', 'admission_number', 'email']
    ordering_fields = ['created_at', 'student_name']
    ordering = ['-created_at']

    def get_permissions(self):
        """Allow read/create/delete without auth to match frontend behavior"""
        if self.action in ['list', 'retrieve', 'create', 'destroy']:
            return [AllowAny()]
        return [IsAuthenticated(), IsManagementAdmin()]


class NewAdmissionViewSet(viewsets.ModelViewSet):
    """ViewSet for New Admission management"""
    queryset = NewAdmission.objects.all()
    serializer_class = NewAdmissionSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'applying_class', 'category', 'gender']
    search_fields = ['student_name', 'parent_name', 'parent_phone', 'email', 'admission_number']
    ordering_fields = ['created_at', 'status', 'student_name']
    ordering = ['-created_at']
    
    def create(self, request, *args, **kwargs):
        """Override create to provide better error messages"""
        serializer = self.get_serializer(data=request.data)
        
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
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'error': 'Failed to create admission',
                },
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def perform_create(self, serializer):
        """Override to create user account for admission"""
        from main_login.models import User, Role
        
        # Get email and student_name from validated data
        email = serializer.validated_data.get('email')
        student_name = serializer.validated_data.get('student_name', '')
        
        # Split student_name into first_name and last_name
        name_parts = student_name.strip().split(maxsplit=1)
        first_name = name_parts[0] if name_parts else student_name
        last_name = name_parts[1] if len(name_parts) > 1 else ''
        
        # Generate 8-character random password (alphanumeric)
        characters = string.ascii_letters + string.digits
        generated_password = ''.join(random.choice(characters) for _ in range(8))
        
        # Get or create student_parent role
        role, _ = Role.objects.get_or_create(
            name='student_parent',
            defaults={'description': 'Student/Parent role'}
        )
        
        # Create username from email (part before @)
        username = email.split('@')[0] if email else f'student_{random.randint(1000, 9999)}'
        # Ensure username is unique
        base_username = username
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f'{base_username}{counter}'
            counter += 1
        
        # Create User account
        user, user_created = User.objects.get_or_create(
            email=email,
            defaults={
                'username': username,
                'first_name': first_name,
                'last_name': last_name,
                'role': role,
                'is_active': True,
                'has_custom_password': False,  # User needs to create their own password
            }
        )
        
        # Set password_hash to the generated 8-character password
        # Set password field to null/unusable so authentication backend checks password_hash
        user.password_hash = generated_password
        user.set_unusable_password()  # This sets password field to unusable (effectively null)
        user.has_custom_password = False  # Ensure flag is set
        user.save()
        
        # Store generated password in serializer context to return in response
        serializer.context['generated_password'] = generated_password
        
        # Save the admission (without school and user links)
        admission = serializer.save()
        
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
            timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
            admission_number = f'ADM-{datetime.datetime.now().year}-{timestamp[-6:]}'
            # Ensure uniqueness
            while Student.objects.filter(admission_number=admission_number).exists() or \
                  NewAdmission.objects.filter(admission_number=admission_number).exists():
                timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')
                admission_number = f'ADM-{datetime.datetime.now().year}-{timestamp[-6:]}'
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

