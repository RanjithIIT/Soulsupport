import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the START DATE & TIME section and add END DATE & TIME after it
# The pattern to find is the closing of START DATE & TIME SizedBox followed by // CATEGORY

end_datetime_field = '''                                          // END DATE & TIME
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'End Date & Time',
                                              child: InkWell(
                                                onTap: () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: _selectedEndDateTime ?? _selectedStartDateTime ?? DateTime.now(),
                                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                                  );
                                                  if (date != null) {
                                                    if (!mounted) return;
                                                    final time = await showTimePicker(
                                                      context: context,
                                                      initialTime: _selectedEndDateTime != null
                                                          ? TimeOfDay.fromDateTime(_selectedEndDateTime!)
                                                          : TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      setState(() {
                                                        _selectedEndDateTime = DateTime(
                                                          date.year,
                                                          date.month,
                                                          date.day,
                                                          time.hour,
                                                          time.minute,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                                child: InputDecorator(
                                                  decoration: _inputDecoration(hint: 'Select End Date & Time'),
                                                  child: Text(
                                                    _selectedEndDateTime != null
                                                        ? _formatDateTime(_selectedEndDateTime!.toIso8601String())
                                                        : 'Select End Date & Time',
                                                    style: TextStyle(
                                                      color: _selectedEndDateTime != null ? const Color(0xFF333333) : const Color(0xFF555555),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
'''

# Insert END DATE & TIME field before // CATEGORY
content = content.replace('                                          // CATEGORY', end_datetime_field + '                                          // CATEGORY')

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully added End Date & Time field to add_event.dart")
