# Generated migration to make Activity.school field required

from django.db import migrations, models
import django.db.models.deletion


def populate_activity_schools(apps, schema_editor):
    """Populate school field for existing activities that have null school"""
    Activity = apps.get_model('super_admin', 'Activity')
    School = apps.get_model('super_admin', 'School')
    
    # Get activities with null school
    activities_without_school = Activity.objects.filter(school__isnull=True)
    
    if activities_without_school.exists():
        # Try to get a default school (first active school)
        default_school = School.objects.filter(status='active').first()
        
        if default_school:
            # Update all activities without school to use default school
            activities_without_school.update(school=default_school)
            print(f"Updated {activities_without_school.count()} activities to use default school: {default_school.name}")
        else:
            # If no school exists, we need to create one or delete these activities
            # For safety, we'll create a default school
            default_school = School.objects.create(
                school_id='unknown_unknown_reg000001',
                name='Default School',
                location='Unknown',
                state='Unknown',
                district='Unknown',
                registration_number='REG000001',
                status='active'
            )
            activities_without_school.update(school=default_school)
            print(f"Created default school and updated {activities_without_school.count()} activities")
    else:
        print("No activities with null school found")


def reverse_populate(apps, schema_editor):
    """Reverse migration - no action needed"""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('super_admin', '0006_add_school_id_generation_fields'),
    ]

    operations = [
        # Step 1: Populate null school values for existing activities
        migrations.RunPython(populate_activity_schools, reverse_populate),
        # Step 2: Make school field required (non-nullable)
        migrations.AlterField(
            model_name='activity',
            name='school',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='activities',
                to='super_admin.school',
                null=False,
                blank=False
            ),
        ),
    ]

