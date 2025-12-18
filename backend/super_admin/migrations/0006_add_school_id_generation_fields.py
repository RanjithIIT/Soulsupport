# Generated migration to add state, district, registration_number fields
# and regenerate school_id for existing schools

from django.db import migrations, models
import re


def populate_school_fields(apps, schema_editor):
    """Populate state, district, registration_number for existing schools"""
    School = apps.get_model('super_admin', 'School')
    
    for school in School.objects.all():
        # For existing schools, we need to populate the new fields
        # If location contains state/district info, try to extract it
        # Otherwise, use defaults that can be updated later
        
        if not school.state:
            # Try to extract state from location or use default
            location = school.location or ""
            # Simple heuristic: if location has comma, might be "City, State" format
            if "," in location:
                parts = [p.strip() for p in location.split(",")]
                if len(parts) > 1:
                    school.state = parts[-1]  # Last part might be state
                else:
                    school.state = "Unknown"
            else:
                school.state = "Unknown"
        
        if not school.district:
            # Try to extract district from location or use default
            location = school.location or ""
            if "," in location:
                parts = [p.strip() for p in location.split(",")]
                if len(parts) > 1:
                    school.district = parts[0]  # First part might be district/city
                else:
                    school.district = "Unknown"
            else:
                school.district = location if location else "Unknown"
        
        if not school.registration_number:
            # Generate a unique registration number
            # Use part of school_id or name to create unique reg number
            existing_id = school.school_id or ""
            base = school.name.replace(" ", "").upper()[:6] if school.name else "SCH"
            # Create a unique registration number
            # Use a counter to ensure uniqueness
            counter = 1
            reg_num = f"REG{base}{counter:04d}"
            # Check for uniqueness, excluding current school
            while School.objects.exclude(pk=school.pk).filter(registration_number=reg_num).exists():
                counter += 1
                reg_num = f"REG{base}{counter:04d}"
            school.registration_number = reg_num
        
        # Save the fields
        school.save(update_fields=['state', 'district', 'registration_number'])
        print(f"Populated fields for school: {school.name} (state={school.state}, district={school.district}, reg={school.registration_number})")


def reverse_populate(apps, schema_editor):
    """Reverse migration - no action needed"""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('super_admin', '0005_fix_school_foreign_keys'),
    ]

    operations = [
        # Step 1: Add fields as nullable
        migrations.AddField(
            model_name='school',
            name='state',
            field=models.CharField(max_length=100, null=True, blank=True, help_text='State name - used for school_id generation'),
        ),
        migrations.AddField(
            model_name='school',
            name='district',
            field=models.CharField(max_length=100, null=True, blank=True, help_text='District name - used for school_id generation'),
        ),
        migrations.AddField(
            model_name='school',
            name='registration_number',
            field=models.CharField(max_length=100, unique=True, null=True, blank=True, help_text='School registration number - used for school_id generation'),
        ),
        # Step 2: Populate values for existing schools
        migrations.RunPython(populate_school_fields, reverse_populate),
        # Step 3: Make fields required (non-nullable)
        migrations.AlterField(
            model_name='school',
            name='state',
            field=models.CharField(max_length=100, help_text='State name - used for school_id generation'),
        ),
        migrations.AlterField(
            model_name='school',
            name='district',
            field=models.CharField(max_length=100, help_text='District name - used for school_id generation'),
        ),
        migrations.AlterField(
            model_name='school',
            name='registration_number',
            field=models.CharField(max_length=100, unique=True, help_text='School registration number - used for school_id generation'),
        ),
    ]

