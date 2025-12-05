"""
Models for management_admin app - API layer for App 2
"""
from django.db import models
from main_login.models import User
from super_admin.models import School


class Department(models.Model):
    """Department model"""
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='departments')
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    head = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='headed_departments'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.name} - {self.school.name}"
    
    class Meta:
        db_table = 'departments'
        verbose_name = 'Department'
        verbose_name_plural = 'Departments'
        unique_together = ['school', 'name']


class Teacher(models.Model):
    """Teacher model"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='teacher_profile')
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='teachers')
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='teachers'
    )
    employee_id = models.CharField(max_length=50, unique=True)
    designation = models.CharField(max_length=100)
    hire_date = models.DateField(null=True, blank=True)
    # Additional profile fields requested by frontend forms
    phone = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    experience = models.CharField(
        max_length=50, null=True, blank=True,
        help_text='Years of experience or freeform description'
    )
    qualifications = models.TextField(null=True, blank=True)
    specializations = models.TextField(null=True, blank=True)
    class_teacher = models.CharField(max_length=50, null=True, blank=True)
    # Store uploaded photo as raw bytes (nullable) to avoid requiring Pillow for now
    photo = models.BinaryField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.school.name}"
    
    class Meta:
        db_table = 'teachers'
        verbose_name = 'Teacher'
        verbose_name_plural = 'Teachers'


class Student(models.Model):
    """Student model"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='students')
    student_id = models.CharField(max_length=50, unique=True)
    class_name = models.CharField(max_length=50)
    section = models.CharField(max_length=10)
    admission_date = models.DateField(null=True, blank=True)
    # Additional student profile fields requested by frontend forms
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)
    blood_group = models.CharField(max_length=5, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    emergency_contact = models.CharField(max_length=20, null=True, blank=True)
    medical_info = models.TextField(null=True, blank=True)
    parent_name = models.CharField(max_length=255, blank=True)
    parent_phone = models.CharField(max_length=20, blank=True)
    # Store uploaded photo as raw bytes (nullable) to avoid requiring Pillow for now
    photo = models.BinaryField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.student_id}"
    
    class Meta:
        db_table = 'students'
        verbose_name = 'Student'
        verbose_name_plural = 'Students'


class NewAdmission(models.Model):
    """New Admission model for managing student admissions"""
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Approved', 'Approved'),
        ('Rejected', 'Rejected'),
        ('Under Review', 'Under Review'),
        ('Waitlisted', 'Waitlisted'),
        ('Enrolled', 'Enrolled'),
    ]
    
    GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
        ('Other', 'Other'),
    ]
    
    CATEGORY_CHOICES = [
        ('General', 'General'),
        ('OBC', 'OBC'),
        ('SC', 'SC'),
        ('ST', 'ST'),
        ('EWS', 'EWS'),
        ('Other', 'Other'),
    ]
    
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='new_admissions')
    student_name = models.CharField(max_length=255)
    parent_name = models.CharField(max_length=255)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    applying_class = models.CharField(max_length=50)
    contact_number = models.CharField(max_length=20)
    address = models.TextField()
    application_date = models.DateField()
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    admission_number = models.CharField(max_length=50, unique=True, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    previous_school = models.CharField(max_length=255, null=True, blank=True)
    remarks = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.student_name} - {self.applying_class} ({self.status})"
    
    class Meta:
        db_table = 'new_admissions'
        verbose_name = 'New Admission'
        verbose_name_plural = 'New Admissions'
        ordering = ['-application_date', '-created_at']


class DashboardStats(models.Model):
    """Dashboard statistics for management admin"""
    school = models.OneToOneField(School, on_delete=models.CASCADE, related_name='dashboard_stats')
    total_teachers = models.IntegerField(default=0)
    total_students = models.IntegerField(default=0)
    total_departments = models.IntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'dashboard_stats'
        verbose_name = 'Dashboard Statistics'
        verbose_name_plural = 'Dashboard Statistics'

