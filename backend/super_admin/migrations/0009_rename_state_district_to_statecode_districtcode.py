# Generated migration to rename state -> statecode and district -> districtcode

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('super_admin', '0008_alter_activity_school_alter_school_school_id'),
    ]

    operations = [
        migrations.RenameField(
            model_name='school',
            old_name='state',
            new_name='statecode',
        ),
        migrations.RenameField(
            model_name='school',
            old_name='district',
            new_name='districtcode',
        ),
        migrations.AlterField(
            model_name='school',
            name='statecode',
            field=models.CharField(max_length=100, help_text='State code (e.g., TG) - used for school_id generation'),
        ),
        migrations.AlterField(
            model_name='school',
            name='districtcode',
            field=models.CharField(max_length=100, help_text='District code (e.g., HYD) - used for school_id generation'),
        ),
    ]

