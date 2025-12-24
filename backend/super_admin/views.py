"""
Views for super_admin app - API layer for App 1
"""
import random
import string
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.db import transaction
from .models import School, SchoolStats, Activity
from .serializers import SchoolSerializer, ActivitySerializer
from main_login.permissions import IsSuperAdmin
from main_login.models import User, Role


class SchoolViewSet(viewsets.ModelViewSet):
    """ViewSet for School management"""
    queryset = School.objects.all()
    serializer_class = SchoolSerializer
    permission_classes = [IsAuthenticated, IsSuperAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'location']
    search_fields = ['school_name', 'location', 'email', 'phone']
    ordering_fields = ['school_name', 'created_at', 'updated_at']
    ordering = ['-created_at']
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """Override create to create user account for school"""
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
            # Get email from validated data
            email = serializer.validated_data.get('email')
            school_name = serializer.validated_data.get('school_name', '')
            
            if not email:
                return Response(
                    {
                        'success': False,
                        'message': 'Email is required for school creation',
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check if user with this email already exists
            if User.objects.filter(email=email).exists():
                return Response(
                    {
                        'success': False,
                        'message': f'User with email {email} already exists',
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Generate 8-character random password (alphanumeric)
            characters = string.ascii_letters + string.digits
            generated_password = ''.join(random.choice(characters) for _ in range(8))
            
            # Get or create management_admin role
            role, _ = Role.objects.get_or_create(
                name='management_admin',
                defaults={'description': 'Management Admin role'}
            )
            
            # Create username from email (part before @)
            username = email.split('@')[0] if email else f'school_{random.randint(1000, 9999)}'
            # Ensure username is unique
            base_username = username
            counter = 1
            while User.objects.filter(username=username).exists():
                username = f'{base_username}{counter}'
                counter += 1
            
            # Split school name into first_name and last_name
            name_parts = school_name.strip().split(maxsplit=1)
            first_name = name_parts[0] if name_parts else school_name
            last_name = name_parts[1] if len(name_parts) > 1 else ''
            
            # Create User account
            user = User.objects.create(
                email=email,
                username=username,
                first_name=first_name,
                last_name=last_name,
                role=role,
                is_active=True,
                has_custom_password=False,  # User needs to create their own password
            )
            
            # Set password_hash to the generated 8-character password
            user.password_hash = generated_password
            user.set_unusable_password()  # This sets password field to unusable (effectively null)
            user.has_custom_password = False
            user.save()
            
            # Store generated password in serializer context to return in response
            serializer.context['generated_password'] = generated_password
            
            # Create school with user link
            school = serializer.save(user=user)
            
            # Prepare response data
            response_data = serializer.data.copy()
            response_data['generated_password'] = generated_password
            response_data['login_credentials'] = {
                'email': email,
                'password': generated_password,
                'username': username,
                'message': 'Please save these credentials. You can use them to login.'
            }
            
            return Response(
                {
                    'success': True,
                    'message': 'School created successfully. User account created with generated password.',
                    'data': response_data,
                },
                status=status.HTTP_201_CREATED
            )
        except Exception as e:
            return Response(
                {
                    'success': False,
                    'message': str(e),
                    'error': 'Failed to create school',
                },
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        """Get detailed statistics for a school"""
        school = self.get_object()
        stats, created = SchoolStats.objects.get_or_create(school=school)
        serializer = SchoolSerializer(school)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        """Get dashboard data"""
        total_schools = School.objects.count()
        active_schools = School.objects.filter(status='active').count()
        total_students = sum(
            stats.total_students for stats in SchoolStats.objects.all()
        )
        total_teachers = sum(
            stats.total_teachers for stats in SchoolStats.objects.all()
        )
        total_revenue = sum(
            float(stats.total_revenue) for stats in SchoolStats.objects.all()
        )
        
        return Response({
            'total_schools': total_schools,
            'active_schools': active_schools,
            'total_students': total_students,
            'total_teachers': total_teachers,
            'total_revenue': total_revenue,
        })


class ActivityViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Activity logs"""
    queryset = Activity.objects.all()
    serializer_class = ActivitySerializer
    permission_classes = [IsAuthenticated, IsSuperAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['activity_type', 'school']
    search_fields = ['description', 'activity_type']
    ordering_fields = ['created_at']
    ordering = ['-created_at']

