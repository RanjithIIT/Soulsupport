# Generated migration to add school_id field to School model

from django.db import migrations, models
import uuid


def populate_school_ids(apps, schema_editor):
    """Populate school_id for existing schools"""
    School = apps.get_model('super_admin', 'School')
    for school in School.objects.all():
        if not school.school_id:
            school.school_id = uuid.uuid4()
            school.save(update_fields=['school_id'])


class Migration(migrations.Migration):

    dependencies = [
        ('super_admin', '0002_add_school_fields'),
    ]

    operations = [
        # Step 1: Add field as nullable and non-unique
        migrations.AddField(
            model_name='school',
            name='school_id',
            field=models.UUIDField(editable=False, help_text='Unique school identifier', null=True),
        ),
        # Step 2: Populate unique values for existing schools
        migrations.RunPython(populate_school_ids, migrations.RunPython.noop),
        # Step 3: Make it non-nullable and unique
        migrations.AlterField(
            model_name='school',
            name='school_id',
            field=models.UUIDField(default=uuid.uuid4, editable=False, help_text='Unique school identifier', unique=True),
        ),
    ]

