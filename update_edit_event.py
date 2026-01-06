import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add _selectedStartDateTime variable
content = re.sub(
    r'(  String\? _selectedCategory;\r?\n  String _selectedStatus = \'Upcoming\';)',
    r'\1\r\n  DateTime? _selectedStartDateTime;',
    content
)

# Add startDatetime to _previewData
content = re.sub(
    r'(  EventPreviewData get _previewData => EventPreviewData\(\r?\n        name: _nameController\.text,\r?\n        category: _selectedCategory,)',
    r'\1\r\n        startDatetime: _selectedStartDateTime != null ? _selectedStartDateTime!.toIso8601String() : null,',
    content
)

# Add start_datetime to eventData
content = re.sub(
    r"(      final eventData = \{\r?\n        'name': _nameController\.text\.trim\(\),\r?\n        'category': _selectedCategory,)",
    r"\1\r\n        if (_selectedStartDateTime != null)\r\n          'start_datetime': _selectedStartDateTime!.toIso8601String(),",
    content
)

# Add datetime parsing in _loadEventDetails
content = re.sub(
    r'(          _selectedCategory = _categories\.contains\(data\[\'category\'\]\) \? data\[\'category\'\] : null;)',
    r"\1\r\n          if (data['start_datetime'] != null) {\r\n            try {\r\n              _selectedStartDateTime = DateTime.parse(data['start_datetime']);\r\n            } catch (_) {}\r\n          }",
    content
)

# Add to preview dialog
content = re.sub(
    r'(                    _PreviewRow\(label: \'Category\', value: data\.category\),)',
    r"\1\r\n                    if (data.startDatetime != null)\r\n                      _PreviewRow(label: 'Start Date & Time', value: _formatDateTime(data.startDatetime!)),",
    content
)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated edit_event.dart with start_datetime code")
