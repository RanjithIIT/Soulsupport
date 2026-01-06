import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the DATE field section (from // DATE to // TIME)
pattern_date = r'                                          // DATE\s+SizedBox\(\s+width: isTwoColumns\s+\? \(constraints\.maxWidth - 30\) / 2\s+: constraints\.maxWidth,\s+child: _LabeledField\(\s+label: \'Date \*\',\s+child: InkWell\(\s+onTap: \(\) async \{[^}]+\},\s+child: InputDecorator\([^)]+\),\s+\),\s+\),\s+\),\s+'
content = re.sub(pattern_date, '', content, flags=re.DOTALL)

# Remove the TIME field section (from // TIME to // LOCATION)
pattern_time = r'                                          // TIME\s+SizedBox\(\s+width: isTwoColumns\s+\? \(constraints\.maxWidth - 30\) / 2\s+: constraints\.maxWidth,\s+child: _LabeledField\(\s+label: \'Time\',\s+child: TextFormField\(\s+controller: _timeController,\s+decoration: _inputDecoration\(hint: \'e\.g\., 09:00 AM - 12:00 PM\'\),\s+\),\s+\),\s+\),\s+'
content = re.sub(pattern_time, '', content, flags=re.DOTALL)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Date and time fields removed from add_event.dart")
