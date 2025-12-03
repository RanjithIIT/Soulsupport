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
    list_display = ['user', 'school', 'department', 'employee_id', 'designation', 'hire_date']
    list_filter = ['school', 'department', 'designation', 'hire_date']
    search_fields = ['user__username', 'user__email', 'employee_id', 'designation']


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['user', 'school', 'student_id', 'class_name', 'section', 'admission_date']
    list_filter = ['school', 'class_name', 'section', 'admission_date']
    search_fields = ['user__username', 'user__email', 'student_id', 'parent_name']


@admin.register(NewAdmission)
class NewAdmissionAdmin(admin.ModelAdmin):
    list_display = ['student_name', 'parent_name', 'school', 'applying_class', 'status', 'application_date']
    list_filter = ['school', 'status', 'applying_class', 'category', 'gender', 'application_date']
    search_fields = ['student_name', 'parent_name', 'contact_number', 'email', 'admission_number']
    readonly_fields = ['created_at', 'updated_at']
    date_hierarchy = 'application_date'


@admin.register(DashboardStats)
class DashboardStatsAdmin(admin.ModelAdmin):
    list_display = ['school', 'total_teachers', 'total_students', 'total_departments', 'updated_at']
    search_fields = ['school__name']

