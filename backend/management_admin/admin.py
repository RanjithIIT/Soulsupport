"""
Admin configuration for management_admin app
"""
from django.contrib import admin
from .models import Department, Teacher, Student, DashboardStats, NewAdmission


@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ['name', 'school', 'head', 'created_at']
    list_filter = ['school', 'created_at']
    search_fields = ['name', 'school__name', 'head__username']


@admin.register(Teacher)
class TeacherAdmin(admin.ModelAdmin):
    list_display = ['teacher_id', 'first_name', 'last_name', 'user', 'department', 'employee_no', 'designation', 'joining_date', 'is_active']
    list_filter = ['department', 'designation', 'gender', 'is_active', 'joining_date']
    search_fields = ['first_name', 'last_name', 'employee_no', 'email', 'user__username', 'user__email']
    readonly_fields = ['teacher_id', 'created_at', 'updated_at']


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['student_id', 'admission_number', 'student_name', 'parent_name', 'user', 'school', 'applying_class', 'gender', 'category', 'created_at']
    list_filter = ['school', 'gender', 'category', 'applying_class', 'created_at']
    search_fields = ['admission_number', 'student_name', 'email', 'parent_name', 'parent_phone', 'user__username', 'user__email']
    readonly_fields = ['student_id', 'created_at', 'updated_at']


@admin.register(NewAdmission)
class NewAdmissionAdmin(admin.ModelAdmin):
    list_display = ['student_name', 'parent_name', 'school', 'applying_class', 'status', 'created_at']
    list_filter = ['school', 'status', 'applying_class', 'category', 'gender']
    search_fields = ['student_name', 'parent_name', 'email', 'admission_number']
    readonly_fields = ['created_at', 'updated_at']
    date_hierarchy = 'created_at'


@admin.register(DashboardStats)
class DashboardStatsAdmin(admin.ModelAdmin):
    list_display = ['school', 'total_teachers', 'total_students', 'total_departments', 'updated_at']
    search_fields = ['school__name']

