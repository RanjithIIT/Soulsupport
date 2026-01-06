import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the line with "// CATEGORY" and add datetime picker before it
output_lines = []
for i, line in enumerate(lines):
    # Add datetime picker field before CATEGORY
    if '// CATEGORY' in line:
        # Add the datetime picker field
        datetime_picker = '''                                          // START DATE & TIME
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Start Date & Time',
                                              child: InkWell(
                                                onTap: () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                                  );
                                                  if (date != null) {
                                                    if (!mounted) return;
                                                    final time = await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      setState(() {
                                                        _selectedStartDateTime = DateTime(
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
                                                  decoration: _inputDecoration(hint: 'Select Date & Time'),
                                                  child: Text(
                                                    _selectedStartDateTime != null
                                                        ? _formatDateTime(_selectedStartDateTime!.toIso8601String())
                                                        : 'Select Date & Time',
                                                    style: TextStyle(
                                                      color: _selectedStartDateTime != null ? const Color(0xFF333333) : const Color(0xFF555555),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
'''
        output_lines.append(datetime_picker)
    
    output_lines.append(line)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\add_event.dart', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print(f"Added datetime picker to add_event.dart")
