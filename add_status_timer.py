import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add Timer import at the top
if 'import \'dart:async\';' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'dart:async';\nimport 'package:flutter/material.dart';")

# 2. Add Timer variable to _EventsManagementPageState class
# Find the class and add timer after the state variables
pattern = r'(class _EventsManagementPageState extends State<EventsManagementPage> \{\r?\n  List<Event> _events = \[\];)'
replacement = r'\1\n  Timer? _statusUpdateTimer;'
content = re.sub(pattern, replacement, content)

# 3. Add initState to start the timer
init_state = '''
  @override
  void initState() {
    super.initState();
    _loadEvents();
    // Update status every minute
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and recalculate all statuses
        });
      }
    });
  }
'''

# Find where _loadEvents is defined and add initState before it
pattern = r'(\r?\n  Future<void> _loadEvents\(\) async \{)'
if '@override\n  void initState()' not in content:
    content = re.sub(pattern, init_state + r'\1', content)

# 4. Add dispose to clean up timer
dispose_method = '''
  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }
'''

# Add dispose method before _loadEvents if it doesn't exist
if '@override\n  void dispose()' not in content:
    pattern = r'(\r?\n  Future<void> _loadEvents\(\) async \{)'
    content = re.sub(pattern, dispose_method + r'\1', content)

# 5. Add method to compute status from datetime
compute_status_method = '''
  String _computeEventStatus(Event event) {
    if (event.startDatetime == null && event.endDatetime == null) {
      return event.status;
    }

    final now = DateTime.now();
    
    try {
      final start = event.startDatetime != null ? DateTime.parse(event.startDatetime!) : null;
      final end = event.endDatetime != null ? DateTime.parse(event.endDatetime!) : null;

      if (start != null && end != null) {
        if (now.isBefore(start)) {
          return 'Upcoming';
        } else if (now.isAfter(start) && now.isBefore(end)) {
          return 'Ongoing';
        } else {
          return 'Completed';
        }
      } else if (start != null) {
        return now.isBefore(start) ? 'Upcoming' : 'Ongoing';
      } else if (end != null) {
        return now.isBefore(end) ? 'Upcoming' : 'Completed';
      }
    } catch (e) {
      // If parsing fails, return the manual status
      return event.status;
    }

    return event.status;
  }
'''

# Add before _formatDateTime method
pattern = r'(\r?\n  String _formatDateTime\(String datetime\) \{)'
if '_computeEventStatus' not in content:
    content = re.sub(pattern, compute_status_method + r'\1', content)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Added auto-update timer and status computation to events.dart")
