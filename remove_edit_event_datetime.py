import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove _timeController declaration
content = re.sub(r'  final _timeController = TextEditingController\(\);\r?\n', '', content)

# Remove _selectedDate declaration
content = re.sub(r'  DateTime\? _selectedDate;\r?\n', '', content)

# Remove date and time from _previewData getter
content = re.sub(r"        date: _selectedDate != null \? DateFormat\('yyyy-MM-dd'\)\.format\(_selectedDate!\) : null,\r?\n", '', content)
content = re.sub(r'        time: _timeController\.text,\r?\n', '', content)

# Remove _timeController.dispose()
content = re.sub(r'    _timeController\.dispose\(\);\r?\n', '', content)

# Remove date validation
content = re.sub(r"    if \(_selectedDate == null\) \{\r?\n      ScaffoldMessenger\.of\(context\)\.showSnackBar\(\r?\n        const SnackBar\(content: Text\('Please select a date'\)\),\r?\n      \);\r?\n      return;\r?\n    \}\r?\n", '', content)

# Remove date and time from eventData
content = re.sub(r"        'date': DateFormat\('yyyy-MM-dd'\)\.format\(_selectedDate!\),\r?\n", '', content)
content = re.sub(r"        'time': _timeController\.text\.trim\(\),\r?\n", '', content)

# Remove date parsing in _loadEventDetails
content = re.sub(r"          if \(data\['date'\] != null\) \{\r?\n            try \{\r?\n              _selectedDate = DateTime\.parse\(data\['date'\]\);\r?\n            \} catch \(_\) \{\}\r?\n          \}\r?\n", '', content)
content = re.sub(r"          _timeController\.text = data\['time'\] \?\? '';\r?\n", '', content)

# Remove date and time from preview dialog
content = re.sub(r"                    _PreviewRow\(label: 'Date', value: data\.date\),\r?\n", '', content)
content = re.sub(r"                    _PreviewRow\(label: 'Time', value: data\.time\),\r?\n", '', content)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Removed date and time code from edit_event.dart")
