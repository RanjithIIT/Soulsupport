"""
URLs for student_parent app
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'student_parent'

router = DefaultRouter()
router.register(r'parent', views.ParentViewSet, basename='parent')
router.register(r'notifications', views.NotificationViewSet, basename='notification')
router.register(r'fees', views.FeeViewSet, basename='fee')
router.register(r'communications', views.CommunicationViewSet, basename='communication')
router.register(r'dashboard', views.StudentDashboardViewSet, basename='dashboard')

urlpatterns = [
    path('student-profile/', views.student_profile, name='student-profile'),
    path('', include(router.urls)),
]

