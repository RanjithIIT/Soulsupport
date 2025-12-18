# Generated migration to add new fields to School model

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('super_admin', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name='school',
            name='email',
            field=models.EmailField(blank=True, help_text='School email address - used for login credentials', max_length=254, null=True, unique=True),
        ),
        migrations.AddField(
            model_name='school',
            name='phone',
            field=models.CharField(blank=True, help_text='School contact phone number', max_length=20, null=True),
        ),
        migrations.AddField(
            model_name='school',
            name='address',
            field=models.TextField(blank=True, help_text='Full address of the school', null=True),
        ),
        migrations.AddField(
            model_name='school',
            name='principal_name',
            field=models.CharField(blank=True, help_text='Name of the principal', max_length=255, null=True),
        ),
        migrations.AddField(
            model_name='school',
            name='established_year',
            field=models.IntegerField(blank=True, help_text='Year the school was established', null=True),
        ),
        migrations.AddField(
            model_name='school',
            name='user',
            field=models.ForeignKey(blank=True, help_text='User account created for this school (for login)', null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='school_account', to=settings.AUTH_USER_MODEL),
        ),
    ]

