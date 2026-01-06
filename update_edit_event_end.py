import re

# Update edit_event.dart with end_datetime support

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add _selectedEndDateTime variable
content = re.sub(
    r'(  DateTime\? _selectedStartDateTime;)',
    r'\1\r\n  DateTime? _selectedEndDateTime;',
    content
)

# Add endDatetime to _previewData
content = re.sub(
    r'(        startDatetime: _selectedStartDateTime != null \? _selectedStartDateTime!\.toIso8601String\(\) : null,)',
    r'\1\r\n        endDatetime: _selectedEndDateTime != null ? _selectedEndDateTime!.toIso8601String() : null,',
    content
)

# Add end_datetime to eventData
content = re.sub(
    r"(        if \(_selectedStartDateTime != null\)\r?\n          'start_datetime': _selectedStartDateTime!\.toIso8601String\(\),)",
    r"\1\r\n        if (_selectedEndDateTime != null)\r\n          'end_datetime': _selectedEndDateTime!.toIso8601String(),",
    content
)

# Add datetime parsing in _loadEventDetails
content = re.sub(
    r'(          if \(data\[\'start_datetime\'\] != null\) \{\r?\n            try \{\r?\n              _selectedStartDateTime = DateTime\.parse\(data\[\'start_datetime\'\]\);\r?\n            \} catch \(_\) \{\}\r?\n          \})',
    r"\1\r\n          if (data['end_datetime'] != null) {\r\n            try {\r\n              _selectedEndDateTime = DateTime.parse(data['end_datetime']);\r\n            } catch (_) {}\r\n          }",
    content
)

# Add to preview dialog
content = re.sub(
    r'(                    if \(data\.startDatetime != null\)\r?\n                      _PreviewRow\(label: \'Start Date & Time\', value: _formatDateTime\(data\.startDatetime!\)\),)',
    r"\1\r\n                    if (data.endDatetime != null)\r\n                      _PreviewRow(label: 'End Date & Time', value: _formatDateTime(data.endDatetime!)),",
    content
)

# Update EventPreviewData class
content = re.sub(
    r'(class EventPreviewData \{\r?\n  final String\? name;\r?\n  final String\? category;\r?\n  final String\? startDatetime;)',
    r'\1\r\n  final String? endDatetime;',
    content
)

content = re.sub(
    r'(  const EventPreviewData\(\{\r?\n    required this\.name,\r?\n    required this\.category,\r?\n    this\.startDatetime,)',
    r'\1\r\n    this.endDatetime,',
    content
)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated edit_event.dart with end_datetime code")
