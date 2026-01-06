import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and remove the DATE and TIME field sections
output_lines = []
skip_until_location = False
i = 0
while i < len(lines):
    line = lines[i]
    
    # Check if this is the start of the DATE section
    if '// DATE' in line and 'LOCATION' not in line:
        skip_until_location = True
        i += 1
        continue
    
    # Check if we've reached LOCATION
    if skip_until_location and '// LOCATION' in line:
        skip_until_location = False
        output_lines.append(line)
        i += 1
        continue
    
    # Skip lines if we're in the DATE section
    if skip_until_location:
        i += 1
        continue
    
    output_lines.append(line)
    i += 1

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\edit_event.dart', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print(f"Removed DATE and TIME fields from edit_event.dart. Total lines: {len(lines)} -> {len(output_lines)}")
