# Generated manually

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('management_admin', '0033_fix_busstop_bus_column'),
    ]

    operations = [
        migrations.AddField(
            model_name='busstop',
            name='stop_time',
            field=models.TimeField(blank=True, null=True, help_text='Time when bus arrives at this stop'),
        ),
    ]

