import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Update the timer to reload events from API instead of just setState
timer_code = '''  @override
  void initState() {
    super.initState();
    _loadEvents();
    // Reload events every minute to get updated computed_status from API
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _loadEvents(); // Reload from API to get fresh computed_status
      }
    });
  }'''

# Replace the existing initState
pattern = r'  @override\r?\n  void initState\(\) \{[^}]+\}\r?\n  \}'
content = re.sub(pattern, timer_code, content, flags=re.DOTALL)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated timer to reload events from API every minute")
