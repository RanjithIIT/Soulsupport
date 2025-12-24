"""
Models for student_parent app - API layer for App 4
"""
from django.db import models
from main_login.models import User
from management_admin.models import Student
from teacher.models import Class, Attendance, Assignment, Exam, Grade, Timetable, StudyMaterial


class Parent(models.Model):
    """Parent model"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='parent_profile')
    students = models.ManyToManyField(Student, related_name='parents')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    school_name = models.CharField(max_length=255, null=True, blank=True, editable=False, help_text='School name (read-only, auto-populated from schools table)')
    phone = models.CharField(max_length=20)
    address = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id and school_name from first student's school"""
        if self.students.exists():
            first_student = self.students.first()
            if first_student and first_student.school:
                if not self.school_id or self.school_id != first_student.school.school_id:
                    self.school_id = first_student.school.school_id
                if not self.school_name or self.school_name != first_student.school.school_name:
                    self.school_name = first_student.school.school_name
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"{self.user.get_full_name()}"
    
    class Meta:
        db_table = 'parents'
        verbose_name = 'Parent'
        verbose_name_plural = 'Parents'
        ordering = ['-created_at']


class Notification(models.Model):
    """Notification model for students/parents"""
    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    title = models.CharField(max_length=255)
    message = models.TextField()
    notification_type = models.CharField(
        max_length=50,
        choices=[
            ('attendance', 'Attendance'),
            ('assignment', 'Assignment'),
            ('exam', 'Exam'),
            ('grade', 'Grade'),
            ('general', 'General'),
        ],
        default='general'
    )
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id from recipient's school"""
        if not self.school_id and self.recipient:
            # Try to get school_id from recipient's student profile
            try:
                student = Student.objects.filter(user=self.recipient).first()
                if student and student.school:
                    self.school_id = student.school.school_id
            except Exception:
                pass
            # Try to get school_id from recipient's parent profile
            if not self.school_id:
                try:
                    parent = Parent.objects.filter(user=self.recipient).first()
                    if parent and parent.students.exists():
                        first_student = parent.students.first()
                        if first_student and first_student.school:
                            self.school_id = first_student.school.school_id
                except Exception:
                    pass
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'notifications'
        verbose_name = 'Notification'
        verbose_name_plural = 'Notifications'
        ordering = ['-created_at']


class Fee(models.Model):
    """Fee model"""
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='fees')
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    due_date = models.DateField()
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('paid', 'Paid'),
            ('overdue', 'Overdue'),
        ],
        default='pending'
    )
    payment_date = models.DateField(null=True, blank=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id from student's school"""
        if self.student and self.student.school and not self.school_id:
            self.school_id = self.student.school.school_id
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'fees'
        verbose_name = 'Fee'
        verbose_name_plural = 'Fees'
        ordering = ['-due_date']


class Communication(models.Model):
    """Communication model between teachers and parents/students"""
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    school_id = models.CharField(max_length=100, db_index=True, null=True, blank=True, editable=False, help_text='School ID for filtering (read-only, fetched from schools table)')
    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='received_messages'
    )
    subject = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        """Auto-populate school_id from sender or recipient's school and validate matching school_id"""
        from main_login.utils import get_user_school_id
        from django.core.exceptions import ValidationError
        
        # Get school_id for both sender and recipient
        sender_school_id = get_user_school_id(self.sender)
        recipient_school_id = get_user_school_id(self.recipient)
        
        # Validate that sender and recipient have matching school_id
        if sender_school_id and recipient_school_id:
            if sender_school_id != recipient_school_id:
                raise ValidationError(
                    f'Cannot send message: Sender and recipient must belong to the same school. '
                    f'Sender school: {sender_school_id}, Recipient school: {recipient_school_id}'
                )
            # Use the matching school_id
            self.school_id = sender_school_id
        elif sender_school_id:
            # If only sender has school_id, use it
            self.school_id = sender_school_id
        elif recipient_school_id:
            # If only recipient has school_id, use it
            self.school_id = recipient_school_id
        else:
            # If neither has school_id, try to populate from sender
            if not self.school_id:
                # Try to get school_id from sender's school
                if self.sender:
                    try:
                        from management_admin.models import Teacher
                        teacher = Teacher.objects.filter(user=self.sender).first()
                        if teacher:
                            if teacher.school_id:
                                self.school_id = teacher.school_id
                            elif teacher.department and teacher.department.school:
                                self.school_id = teacher.department.school.school_id
                    except Exception:
                        pass
                # If not found, try recipient
                if not self.school_id and self.recipient:
                    try:
                        student = Student.objects.filter(user=self.recipient).first()
                        if student and student.school:
                            self.school_id = student.school.school_id
                    except Exception:
                        pass
                    # Try parent
                    if not self.school_id:
                        try:
                            parent = Parent.objects.filter(user=self.recipient).first()
                            if parent:
                                if parent.school_id:
                                    self.school_id = parent.school_id
                                elif parent.students.exists():
                                    first_student = parent.students.first()
                                    if first_student and first_student.school:
                                        self.school_id = first_student.school.school_id
                        except Exception:
                            pass
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'communications'
        verbose_name = 'Communication'
        verbose_name_plural = 'Communications'
        ordering = ['-created_at']

