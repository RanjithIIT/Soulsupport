"""
Utility functions for school-based data isolation
"""
from super_admin.models import School


def get_user_school_id(user):
    """
    Get the school_id for a given user.
    
    For management_admin users: Get from School.user relationship (school_account)
    For teacher users: Get from Teacher -> Department -> School
    For student/parent users: Get from Student -> School or Parent -> Student -> School
    
    Returns:
        str: school_id if found, None otherwise
    """
    if not user or not user.is_authenticated:
        return None
    
    # Check if user is a management admin (has school_account)
    try:
        school = School.objects.filter(user=user).first()
        if school:
            return school.school_id
    except Exception:
        pass
    
    # Check if user is a teacher
    try:
        from management_admin.models import Teacher
        teacher = Teacher.objects.filter(user=user).first()
        if teacher and teacher.department and teacher.department.school:
            return teacher.department.school.school_id
    except Exception:
        pass
    
    # Check if user is a student
    try:
        from management_admin.models import Student
        student = Student.objects.filter(user=user).first()
        if student and student.school:
            return student.school.school_id
    except Exception:
        pass
    
    # Check if user is a parent (through parent_profile -> students -> school)
    try:
        from student_parent.models import Parent
        parent = Parent.objects.filter(user=user).first()
        if parent and parent.students.exists():
            first_student = parent.students.first()
            if first_student and first_student.school:
                return first_student.school.school_id
    except Exception:
        pass
    
    return None


def get_user_school(user):
    """
    Get the School object for a given user.
    
    Returns:
        School: School object if found, None otherwise
    """
    school_id = get_user_school_id(user)
    if school_id:
        try:
            return School.objects.get(school_id=school_id)
        except School.DoesNotExist:
            pass
    return None

