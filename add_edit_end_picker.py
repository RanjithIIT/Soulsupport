import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the START DATE & TIME picker and add END DATE & TIME picker after it
output_lines = []
added_end_picker = False
for i, line in enumerate(lines):
    output_lines.append(line)
    
    # After the START DATE & TIME picker closes, add END DATE & TIME picker
    if not added_end_picker and '// START DATE & TIME' in line:
        # Find the closing of this SizedBox (look ahead for the pattern)
        j = i + 1
        bracket_count = 0
        found_start = False
        while j < len(lines):
            if 'SizedBox(' in lines[j]:
                if not found_start:
                    found_start = True
                    bracket_count = 1
                else:
                    bracket_count += 1
            if found_start and '),' in lines[j]:
                bracket_count -= 1
                if bracket_count == 0:
                    # Found the end of START DATE & TIME SizedBox
                    # Add END DATE & TIME picker after this
                    end_picker = '''                                          // END DATE & TIME
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
                                                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                                  );
                                                  if (date != null) {
                                                    if (!mounted) return;
                                                    final time = await showTimePicker(
                                                      context: context,
                                                      initialTime: _selectedEndDateTime != null
                                                          ? TimeOfDay.fromDateTime(_selectedEndDateTime!)
                                                          : _selectedStartDateTime != null
                                                              ? TimeOfDay.fromDateTime(_selectedStartDateTime!)
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
                    # Insert after line j
                    for k in range(len(output_lines)):
                        if k == len(output_lines) - (i - j):
                            output_lines.insert(k + 1, end_picker)
                            break
                    added_end_picker = True
                    break
            j += 1

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print(f"Added end datetime picker UI to edit_event.dart")
