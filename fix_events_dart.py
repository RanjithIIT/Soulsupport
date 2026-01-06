import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the duplicate _formatDateTime method that was added in the wrong place
# It should only be in the _EventsManagementPageState class, not after LayoutBuilder
pattern = r'\n\n  String _formatDateTime\(String datetime\) \{\n    try \{\n      final dt = DateTime\.parse\(datetime\);\n      return \'\$\{dt\.day\}/\$\{dt\.month\}/\$\{dt\.year\} \$\{dt\.hour\}:\$\{dt\.minute\.toString\(\)\.padLeft\(2, \'0\'\)\}\';\n    \} catch \(e\) \{\n      return datetime;\n    \}\n  \}\n               const SizedBox'
replacement = '\n               const SizedBox'
content = re.sub(pattern, replacement, content)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed duplicate _formatDateTime method in events.dart")
