import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all places where event.status is used and replace with getDisplayStatus(event)
# In the event card status display
content = re.sub(
    r"Text\(\s*event\.status\s*,",
    r"Text(getDisplayStatus(event),",
    content
)

# In Container with status color
content = re.sub(
    r"color:\s*event\.status\s*==\s*'Upcoming'\s*\?\s*Colors\.blue\s*:\s*event\.status\s*==\s*'Ongoing'\s*\?\s*Colors\.green\s*:\s*Colors\.grey",
    r"color: getStatusColor(getDisplayStatus(event))",
    content
)

# Also update any direct status references in the view dialog
content = re.sub(
    r"Text\('Status:\s*\$\{event\.status\}'\)",
    r"Text('Status: ${getDisplayStatus(event)}')",
    content
)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated all status displays to use getDisplayStatus and getStatusColor")
