"""
Views for management_admin app - API layer for App 2
"""
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
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
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'department', 'designation']
    search_fields = ['user__first_name', 'user__last_name', 'employee_id', 'designation']
    ordering_fields = ['hire_date', 'created_at']
    ordering = ['-created_at']


class StudentViewSet(viewsets.ModelViewSet):
    """ViewSet for Student management"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'class_name', 'section']
    search_fields = ['user__first_name', 'user__last_name', 'student_id', 'parent_name']
    ordering_fields = ['admission_date', 'created_at']
    ordering = ['-created_at']


class NewAdmissionViewSet(viewsets.ModelViewSet):
    """ViewSet for New Admission management"""
    queryset = NewAdmission.objects.all()
    serializer_class = NewAdmissionSerializer
    permission_classes = [IsAuthenticated, IsManagementAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['school', 'status', 'applying_class', 'category', 'gender']
    search_fields = ['student_name', 'parent_name', 'contact_number', 'email', 'admission_number']
    ordering_fields = ['application_date', 'created_at', 'status']
    ordering = ['-application_date', '-created_at']
    
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
            return Response(
                {
                    'success': True,
                    'message': 'Admission created successfully',
                    'data': serializer.data,
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
        """Override to handle school validation"""
        from super_admin.models import School
        
        # Get school from validated_data (could be School object or ID)
        school = serializer.validated_data.get('school')
        
        # If school is provided as an ID (integer), get the School object
        if isinstance(school, int):
            try:
                school = School.objects.get(id=school)
            except School.DoesNotExist:
                # If school doesn't exist, use first available or create default
                school = School.objects.first()
                if not school:
                    school = School.objects.create(
                        name='Default School',
                        location='Default Location',
                        status='active'
                    )
        
        # If no school provided, use first available or create default
        if not school:
            school = School.objects.first()
            if not school:
                school = School.objects.create(
                    name='Default School',
                    location='Default Location',
                    status='active'
                )
        
        serializer.save(school=school)
    
    def update(self, request, *args, **kwargs):
        """Override update to provide better error messages and handle partial updates"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
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
            self.perform_update(serializer)
            
            if getattr(instance, '_prefetched_objects_cache', None):
                instance._prefetched_objects_cache = {}
            
            return Response(
                {
                    'success': True,
                    'message': 'Admission updated successfully',
                    'data': serializer.data,
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

