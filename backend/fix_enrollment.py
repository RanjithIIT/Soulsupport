
from teacher.models import Exam, Class, ClassStudent
from management_admin.models import Student
from main_login.models import User

print("--- FIXING ENROLLMENT ---")

# 1. Identify the student (simulating 'vamshi' user or just the first student)
student = Student.objects.filter(student_name__icontains='Sushil').first()
if not student:
     student = Student.objects.first()

if not student:
    print("No student found!")
    exit()

print(f"Selected Student: {student.student_name} (ID: {student.student_id})")

# 2. Identify the target class from recent exams
latest_exam = Exam.objects.order_by('-id').first()
if not latest_exam:
    print("No exams found in the system.")
    exit()

target_class = latest_exam.class_obj
print(f"Most recent exam '{latest_exam.title}' is for class: {target_class.name} {target_class.section}")

# 3. Enroll the student
if not ClassStudent.objects.filter(student=student, class_obj=target_class).exists():
    print(f"Enrolling {student.student_name} into {target_class.name} {target_class.section}...")
    ClassStudent.objects.create(student=student, class_obj=target_class)
    print("SUCCESS: Student enrolled.")
else:
    print("Student is ALREADY enrolled in this class.")

# Verify
print("Verifying...")
count = ClassStudent.objects.filter(student=student).count()
print(f"Student now has {count} class enrollments.")
