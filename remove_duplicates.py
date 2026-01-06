import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find and remove duplicate getDisplayStatus and getStatusColor methods
output_lines = []
skip_until_line = -1
found_first_getDisplayStatus = False

for i, line in enumerate(lines):
    # Skip lines if we're in a duplicate section
    if i < skip_until_line:
        continue
    
    # Check if this is a duplicate getDisplayStatus
    if 'String getDisplayStatus(Event event)' in line:
        if found_first_getDisplayStatus:
            # This is a duplicate, skip until we find the closing brace
            brace_count = 0
            j = i
            while j < len(lines):
                if '{' in lines[j]:
                    brace_count += lines[j].count('{')
                if '}' in lines[j]:
                    brace_count -= lines[j].count('}')
                    if brace_count == 0:
                        skip_until_line = j + 1
                        break
                j += 1
            continue
        else:
            found_first_getDisplayStatus = True
    
    output_lines.append(line)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print("Removed duplicate getDisplayStatus methods")
