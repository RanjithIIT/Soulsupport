import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'school_backend.settings')
django.setup()

from django.db import connection

def check_data(table_name, col1, col2):
    with connection.cursor() as cursor:
        query = f"SELECT {col1}, {col2} FROM {table_name} LIMIT 5;"
        cursor.execute(query)
        rows = cursor.fetchall()
        print(f"Data in {table_name} ({col1}, {col2}): {rows}")

check_data('teachers', 'class_teacher_grade', 'class_teacher_section')
check_data('bus_stop_students', 'student_grade', 'student_section')
check_data('management_fees', 'section', 'id') # Just checking section exists
