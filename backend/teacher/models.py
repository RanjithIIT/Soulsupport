"""
Models for teacher app - API layer for App 3
"""
from django.db import models
from main_login.models import User
from management_admin.models import Teacher, Student, Department


class Class(models.Model):
    """Class model"""
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    name = models.CharField(max_length=50)
    section = models.CharField(max_length=10)
    teacher = models.ForeignKey(
        Teacher,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='classes'
    )
    department = models.ForeignKey(
        Department,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='classes'
    )
    academic_year = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from teacher's department's school or student's school"""
        if not self.school_id:
            if self.teacher and self.teacher.department and self.teacher.department.school:
                self.school_id = self.teacher.department.school.school_id
                self.school_name = self.teacher.department.school.school_name
            # If no teacher, try to get from first student in class
            elif hasattr(self, 'class_students') and self.class_students.exists():
                first_student = self.class_students.first().student
                if first_student and first_student.school:
                    self.school_id = first_student.school.school_id
                    self.school_name = first_student.school.school_name
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.name} - {self.section}"
    
    class Meta:
        db_table = 'classes'
        verbose_name = 'Class'
        verbose_name_plural = 'Classes'
        unique_together = ['name', 'section', 'academic_year']


class ClassStudent(models.Model):
    """Many-to-many relationship between Class and Student"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='class_students')
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='student_classes')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    enrolled_date = models.DateField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id from student's school"""
        if self.student and self.student.school and not self.school_id:
            self.school_id = self.student.school.school_id
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'class_students'
        verbose_name = 'Class Student'
        verbose_name_plural = 'Class Students'
        unique_together = ['class_obj', 'student']


class Attendance(models.Model):
    """Attendance model"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='attendances')
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='attendances')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    date = models.DateField()
    status = models.CharField(
        max_length=10,
        choices=[
            ('present', 'Present'),
            ('absent', 'Absent'),
            ('late', 'Late'),
        ],
        default='present'
    )
    marked_by = models.ForeignKey(Teacher, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from student's school"""
        if self.student and self.student.school and not self.school_id:
            self.school_id = self.student.school.school_id
            self.school_name = self.student.school.school_name
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'attendances'
        verbose_name = 'Attendance'
        verbose_name_plural = 'Attendances'
        unique_together = ['class_obj', 'student', 'date']


class Assignment(models.Model):
    """Assignment model"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='assignments')
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='assignments')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    title = models.CharField(max_length=255)
    description = models.TextField()
    due_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from teacher's department's school"""
        if self.teacher and self.teacher.department and self.teacher.department.school and not self.school_id:
            self.school_id = self.teacher.department.school.school_id
            self.school_name = self.teacher.department.school.school_name
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'assignments'
        verbose_name = 'Assignment'
        verbose_name_plural = 'Assignments'
        ordering = ['-created_at']


class Exam(models.Model):
    """Exam model"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='exams')
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='exams')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    exam_date = models.DateTimeField()
    total_marks = models.DecimalField(max_digits=5, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from teacher's department's school"""
        if self.teacher and self.teacher.department and self.teacher.department.school and not self.school_id:
            self.school_id = self.teacher.department.school.school_id
            self.school_name = self.teacher.department.school.school_name
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'exams'
        verbose_name = 'Exam'
        verbose_name_plural = 'Exams'
        ordering = ['-exam_date']


class Grade(models.Model):
    """Grade model"""
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE, related_name='grades')
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='grades')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    marks_obtained = models.DecimalField(max_digits=5, decimal_places=2)
    remarks = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from student's school"""
        if self.student and self.student.school and not self.school_id:
            self.school_id = self.student.school.school_id
            self.school_name = self.student.school.school_name
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'grades'
        verbose_name = 'Grade'
        verbose_name_plural = 'Grades'
        unique_together = ['exam', 'student']


class Timetable(models.Model):
    """Timetable model"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='timetables')
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='teacher_timetables')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    day_of_week = models.IntegerField(choices=[
        (0, 'Monday'),
        (1, 'Tuesday'),
        (2, 'Wednesday'),
        (3, 'Thursday'),
        (4, 'Friday'),
        (5, 'Saturday'),
        (6, 'Sunday'),
    ])
    start_time = models.TimeField()
    end_time = models.TimeField()
    subject = models.CharField(max_length=100)
    room = models.CharField(max_length=50, blank=True, null=True, help_text='Room number or location')
    color = models.CharField(max_length=7, default='#667EEA', help_text='Color code for the subject (hex format)')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from teacher's department's school"""
        # Check if teacher_id is available
        if self.teacher_id:
            try:
                # Retrieve the teacher instance using the ID
                teacher = Teacher.objects.get(pk=self.teacher_id)
                if teacher.department and teacher.department.school and not self.school_id:
                    self.school_id = teacher.department.school.school_id
                    self.school_name = teacher.department.school.school_name
            except Exception:
                # Safely ignore if teacher/department/school missing
                pass
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'timetables'
        verbose_name = 'Timetable'
        verbose_name_plural = 'Timetables'
        unique_together = ['class_obj', 'day_of_week', 'start_time']


class StudyMaterial(models.Model):
    """Study Material model"""
    class_obj = models.ForeignKey(Class, on_delete=models.CASCADE, related_name='study_materials')
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='study_materials')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    file_url = models.URLField(blank=True)
    file_path = models.FileField(upload_to='study_materials/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from teacher's department's school"""
        if self.teacher and self.teacher.department and self.teacher.department.school and not self.school_id:
            self.school_id = self.teacher.department.school.school_id
            self.school_name = self.teacher.department.school.school_name
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'study_materials'
        verbose_name = 'Study Material'
        verbose_name_plural = 'Study Materials'
        ordering = ['-created_at']