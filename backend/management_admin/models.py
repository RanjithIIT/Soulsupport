"""
Models for management_admin app - API layer for App 2
"""
import uuid
from datetime import date
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
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
    teacher_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='user_id',
        related_name='teacher_profiles',
        help_text='If teacher has login'
    )
    employee_no = models.CharField(max_length=50, unique=True, null=True, blank=True)
    first_name = models.CharField(max_length=150, null=False, default="")
    last_name = models.CharField(max_length=150, null=True, blank=True)
    qualification = models.CharField(max_length=255, null=True, blank=True)
    joining_date = models.DateField(null=True, blank=True)
    dob = models.DateField(null=True, blank=True, help_text='Date of Birth')
    
    GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
        ('Other', 'Other'),
    ]
    gender = models.CharField(max_length=20, choices=GENDER_CHOICES, null=True, blank=True)
    designation = models.CharField(max_length=100, null=True, blank=True)
    
    # Foreign key to Department
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='department_id',
        related_name='teachers'
    )
    
    # Additional fields from schema
    blood_group = models.CharField(max_length=10, null=True, blank=True)
    nationality = models.CharField(max_length=100, null=True, blank=True)
    mobile_no = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    primary_room_id = models.CharField(max_length=50, null=True, blank=True, help_text='Primary room identifier')
    class_teacher_section_id = models.CharField(max_length=50, null=True, blank=True, help_text='Class teacher section identifier')
    subject_specialization = models.TextField(null=True, blank=True, help_text='Subject specialization details')
    emergency_contact = models.CharField(max_length=20, null=True, blank=True)
    
    profile_photo_id = models.UUIDField(null=True, blank=True, help_text='Reference to files.file_id for profile photo')
    is_active = models.BooleanField(default=True, null=False)
    created_at = models.DateTimeField(auto_now_add=True, null=False)
    updated_at = models.DateTimeField(auto_now=True, null=True, blank=True)
    
    def __str__(self):
        name = f"{self.first_name} {self.last_name}".strip() or self.employee_no or str(self.teacher_id)
        return f"{name} - {self.employee_no or 'N/A'}"
    
    class Meta:
        db_table = 'teachers'
        verbose_name = 'Teacher'
        verbose_name_plural = 'Teachers'


class Student(models.Model):
    """Student (final admission) model — same fields as NewAdmission except status."""

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

    student_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Login reference (optional)
    user = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='user_id',
        related_name='student_profiles',
        help_text='Linked login user account (if exists)'
    )

    # School link
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name='students')

    # 🔥 SAME FIELDS AS NewAdmission (without status)
    student_name = models.CharField(max_length=255, default="")
    parent_name = models.CharField(max_length=255, default="")
    date_of_birth = models.DateField(default=date(2000, 1, 1))
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default="Male")
    applying_class = models.CharField(max_length=50, default="")
    address = models.TextField(default="Address not provided")
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default="General")

    admission_number = models.CharField(
        max_length=50, 
        unique=True, 
        null=True, 
        blank=True,
        help_text="Generated after approval"
    )

    email = models.EmailField(
        unique=True,
        default="",
        help_text='Used as login credential if account created'
    )

    parent_phone = models.CharField(max_length=20, null=True, blank=True)
    emergency_contact = models.CharField(max_length=20, null=True, blank=True)

    medical_information = models.TextField(
        null=True, 
        blank=True,
        help_text='Medical notes or allergies'
    )

    blood_group = models.CharField(max_length=10, null=True, blank=True)
    previous_school = models.CharField(max_length=255, null=True, blank=True)
    remarks = models.TextField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.student_name} - {self.applying_class}"

    class Meta:
        db_table = 'students'
        verbose_name = 'Student'
        verbose_name_plural = 'Students'



class NewAdmission(models.Model):
    """New Admission model for managing student admissions - same fields as Student plus status"""
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
    
    # Same fields as Student model
    student_name = models.CharField(max_length=255)
    parent_name = models.CharField(max_length=255)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    applying_class = models.CharField(max_length=50)
    grade = models.CharField(max_length=50, null=True, blank=True, help_text="Grade/Level of the student")
    fees = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Admission fees")
    address = models.TextField(default = "Address not provided")
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default = "")
    
    # Student ID field
    student_id = models.CharField(max_length=100, null=True, blank=True, help_text="Student ID (can be provided during admission)")
    
    # Status field - unique to NewAdmission (not in Student)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    
    admission_number = models.CharField(
        max_length=50, 
        unique=True, 
        null=True, 
        blank=True,
        help_text="Generated after approval"
    )
    
    email = models.EmailField(
        unique=True,
        help_text='Required. Used to create login credentials.'
    )
    
    parent_phone = models.CharField(max_length=20, null=True, blank=True)
    emergency_contact = models.CharField(max_length=20, null=True, blank=True)
    
    medical_information = models.TextField(
        null=True, 
        blank=True,
        help_text='Medical information and allergies'
    )
    
    blood_group = models.CharField(max_length=10, null=True, blank=True)
    previous_school = models.CharField(max_length=255, null=True, blank=True)
    remarks = models.TextField(null=True, blank=True)
    
    # Password field - stores hashed password after user creates it
    password = models.CharField(max_length=128, null=True, blank=True, help_text='Hashed password created by user')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.student_name} - {self.applying_class} ({self.status})"
    
    @property
    def created_student(self):
        """
        Get the Student record created from this admission (if approved).
        Returns the Student instance if found, None otherwise.
        """
        if self.status != 'Approved':
            return None
        
        # Try to find student by admission number first, then by email
        if self.admission_number:
            try:
                return Student.objects.get(admission_number=self.admission_number)
            except Student.DoesNotExist:
                pass
        
        if self.email:
            try:
                return Student.objects.get(email=self.email)
            except Student.DoesNotExist:
                pass
        
        return None
    
    def create_student_from_admission(self):
        """
        Create a Student record from this approved NewAdmission.
        This method should be called when status changes to 'Approved'.
        Returns the created or updated Student instance.
        """
        from django.db import IntegrityError
        import datetime
        
        # Check if student already exists with this admission number or email
        existing_student = None
        if self.admission_number:
            existing_student = Student.objects.filter(admission_number=self.admission_number).first()
        if not existing_student and self.email:
            existing_student = Student.objects.filter(email=self.email).first()
        
        if existing_student:
            # Student already exists, update it with latest admission data
            for field in ['student_name', 'parent_name', 'date_of_birth', 'gender', 
                         'applying_class', 'address', 'category',
                         'parent_phone', 'emergency_contact', 'medical_information',
                         'blood_group', 'previous_school', 'remarks']:
                setattr(existing_student, field, getattr(self, field, None))
            
            # Note: user link is no longer stored in NewAdmission
            
            # Update admission number if not set
            if self.admission_number and not existing_student.admission_number:
                existing_student.admission_number = self.admission_number
            
            existing_student.save()
            return existing_student
        
        # Generate admission number if not provided
        admission_number = self.admission_number
        if not admission_number:
            timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
            admission_number = f'ADM-{datetime.datetime.now().year}-{timestamp[-6:]}'
            # Ensure uniqueness
            while Student.objects.filter(admission_number=admission_number).exists():
                timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')
                admission_number = f'ADM-{datetime.datetime.now().year}-{timestamp[-6:]}'
            # Update the admission record with generated number
            self.admission_number = admission_number
            self.save(update_fields=['admission_number'])
        
        # Create Student record - map all fields from NewAdmission (except status)
        # Note: school and user are not stored in NewAdmission, so we need to get a default school
        from super_admin.models import School
        default_school = School.objects.first()
        if not default_school:
            # Create a default school if none exists
            default_school = School.objects.create(
                name='Default School',
                location='Default Location',
                status='active'
            )
        
        student_data = {
            'school': default_school,
            'student_name': self.student_name,
            'parent_name': self.parent_name,
            'date_of_birth': self.date_of_birth,
            'gender': self.gender,
            'applying_class': self.applying_class,
            'address': self.address or "Address not provided",
            'category': self.category or "General",
            'admission_number': admission_number,
            'email': self.email,
            'parent_phone': self.parent_phone,
            'emergency_contact': self.emergency_contact,
            'medical_information': self.medical_information,
            'blood_group': self.blood_group,
            'previous_school': self.previous_school,
            'remarks': self.remarks,
            # Note: user is not stored in NewAdmission, so it will be None
        }
        
        try:
            # Create student
            student = Student.objects.create(**student_data)
            return student
        except IntegrityError as e:
            # Handle unique constraint violations (email or admission_number)
            # Try to get existing student by email
            if self.email:
                try:
                    student = Student.objects.get(email=self.email)
                    # Update the existing student
                    for key, value in student_data.items():
                        if key != 'email':  # Don't update email if it's the same
                            setattr(student, key, value)
                    student.save()
                    return student
                except Student.DoesNotExist:
                    pass
            # If we can't find existing student, re-raise the error
            raise
    
    class Meta:
        db_table = 'new_admissions'
        verbose_name = 'New Admission'
        verbose_name_plural = 'New Admissions'
        ordering = ['-created_at']


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

