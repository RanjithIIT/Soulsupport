from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Event, CalendarRecord

@receiver(post_save, sender=Event)
def sync_event_to_calendar(sender, instance, created, **kwargs):
    """
    Sync Event model changes to CalendarRecord.
    Creates or updates a corresponding CalendarRecord when an Event is saved.
    """
    # Determine color based on category
    color_map = {
        'Academic': '#E3F2FD', # Light Blue
        'Sports': '#F3E5F5',   # Light Purple
        'Cultural': '#FFF3E0', # Light Orange
        'Administrative': '#E8F5E8', # Light Green
        'Holiday': '#FFEBEE',  # Light Red
        'Exam': '#EDE7F6',     # Deep Purple
        'Career': '#E0F2F1',   # Teal
        'Other': '#F5F5F5',    # Grey
    }

    # Use structured fields directly
    start_time = instance.start_time
    end_time = instance.end_time
    end_date = instance.end_date if instance.end_date else instance.date

    CalendarRecord.objects.update_or_create(
        title=instance.name, # Sync Name to Title
        date=instance.date,
        defaults={
            'event_type': instance.category,
            'start_time': start_time,
            'end_time': end_time,
            'end_date': end_date,
            'description': instance.description,
            'location': instance.location,
            'school_id': instance.school_id,
            'school_name': instance.school_name,
            'color': color_map.get(instance.category, '#FFFFFF'),
            'is_public': True
        }
    )

@receiver(post_delete, sender=Event)
def delete_event_from_calendar(sender, instance, **kwargs):
    """
    Remove corresponding CalendarRecord when Event is deleted.
    """
    CalendarRecord.objects.filter(title=instance.name, date=instance.date).delete()
