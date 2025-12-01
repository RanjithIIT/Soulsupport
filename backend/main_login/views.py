"""
Views for main_login app - Authentication and JWT
"""
from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from .models import Role
from .serializers import (
    UserRegistrationSerializer,
    UserLoginSerializer,
    UserSerializer,
    RoleSerializer,
    ChangePasswordSerializer
)

User = get_user_model()


def get_tokens_for_user(user):
    """Generate JWT tokens for user"""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def register(request):
    """User registration endpoint"""
    serializer = UserRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        tokens = get_tokens_for_user(user)
        user_data = UserSerializer(user).data
        return Response({
            'user': user_data,
            'tokens': tokens,
            'message': 'User registered successfully'
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def login(request):
    """User login endpoint"""
    serializer = UserLoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        tokens = get_tokens_for_user(user)
        user_data = UserSerializer(user).data
        return Response({
            'user': user_data,
            'tokens': tokens,
            'message': 'Login successful'
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def logout(request):
    """User logout endpoint"""
    try:
        refresh_token = request.data.get('refresh_token')
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def profile(request):
    """Get current user profile"""
    serializer = UserSerializer(request.user)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['PUT', 'PATCH'])
@permission_classes([permissions.IsAuthenticated])
def update_profile(request):
    """Update current user profile"""
    serializer = UserSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response({
            'user': serializer.data,
            'message': 'Profile updated successfully'
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def change_password(request):
    """Change user password"""
    serializer = ChangePasswordSerializer(data=request.data)
    if serializer.is_valid():
        user = request.user
        if not user.check_password(serializer.validated_data['old_password']):
            return Response(
                {'old_password': 'Wrong password.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        return Response({'message': 'Password changed successfully'}, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RoleListView(generics.ListAPIView):
    """List all available roles"""
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [permissions.AllowAny]


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def refresh_token(request):
    """Refresh JWT token"""
    try:
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response(
                {'error': 'Refresh token is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        token = RefreshToken(refresh_token)
        return Response({
            'access': str(token.access_token),
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response(
            {'error': 'Invalid or expired refresh token'},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def get_role_routes(request):
    """Get routing information for each role"""
    role_routes = {
        'admin': {
            'login_page': '/admin_login',
            'login_file': 'admin_login.dart',
            'dashboard_route': '/super-admin/dashboard',
            'api_base': '/api/super-admin/',
        },
        'management': {
            'login_page': '/management_login',
            'login_file': 'management_login.dart',
            'dashboard_route': '/management-admin/dashboard',
            'api_base': '/api/management-admin/',
        },
        'teacher': {
            'login_page': '/teacher_login',
            'login_file': 'teacher_login.dart',
            'dashboard_route': '/teacher/dashboard',
            'api_base': '/api/teacher/',
        },
        'parent': {
            'login_page': '/parent_login',
            'login_file': 'parent_login.dart',
            'dashboard_route': '/student-parent/dashboard',
            'api_base': '/api/student-parent/',
        },
        'student_parent': {
            'login_page': '/parent_login',
            'login_file': 'parent_login.dart',
            'dashboard_route': '/student-parent/dashboard',
            'api_base': '/api/student-parent/',
        },
    }
    
    role = request.query_params.get('role', '').lower()
    
    if role and role in role_routes:
        return Response({
            'success': True,
            'role': role,
            'route': role_routes[role],
        }, status=status.HTTP_200_OK)
    
    # Return all routes if no specific role requested
    return Response({
        'success': True,
        'routes': role_routes,
    }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([permissions.AllowAny])
def test_db_connection(request):
    """Test endpoint to verify database connection and list users"""
    try:
        from django.db import connection
        
        # Test database connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            db_version = cursor.fetchone()[0]
        
        # Get user count
        user_count = User.objects.count()
        role_count = Role.objects.count()
        
        # Get sample users
        users = User.objects.all()[:10]
        user_list = [
            {
                'email': user.email,
                'username': user.username,
                'role': user.role.name if user.role else None,
                'is_active': user.is_active
            }
            for user in users
        ]
        
        return Response({
            'success': True,
            'database': {
                'connected': True,
                'version': db_version.split(',')[0] if db_version else 'Unknown',
                'user_count': user_count,
                'role_count': role_count,
            },
            'users': user_list,
            'message': 'Database connection successful'
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e),
            'message': 'Database connection failed'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def role_login(request):
    """Role-specific login endpoint that validates role and returns routing info"""
    serializer = UserLoginSerializer(data=request.data)
    
    if serializer.is_valid():
        user = serializer.validated_data['user']
        requested_role = request.data.get('role', '').lower()
        
        # Map frontend role names to backend role names
        role_mapping = {
            'admin': 'super_admin',
            'management': 'management_admin',
            'teacher': 'teacher',
            'parent': 'student_parent',
        }
        
        backend_role = role_mapping.get(requested_role, requested_role)
        
        # Verify user has the correct role
        if user.role and user.role.name == backend_role:
            tokens = get_tokens_for_user(user)
            user_data = UserSerializer(user).data
            
            # Get routing information for the role
            route_info = {
                'admin': {
                    'login_page': '/admin_login',
                    'dashboard_route': '/super-admin/dashboard',
                },
                'management': {
                    'login_page': '/management_login',
                    'dashboard_route': '/management-admin/dashboard',
                },
                'teacher': {
                    'login_page': '/teacher_login',
                    'dashboard_route': '/teacher/dashboard',
                },
                'parent': {
                    'login_page': '/parent_login',
                    'dashboard_route': '/student-parent/dashboard',
                },
            }
            
            return Response({
                'success': True,
                'user': user_data,
                'tokens': tokens,
                'role': requested_role,
                'routes': route_info.get(requested_role, {}),
                'message': f'Login successful as {requested_role}'
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': f'User does not have {requested_role} role. Current role: {user.role.name if user.role else "None"}'
            }, status=status.HTTP_403_FORBIDDEN)
    
    return Response({
        'success': False,
        'errors': serializer.errors,
        'message': 'Invalid credentials'
    }, status=status.HTTP_400_BAD_REQUEST)

