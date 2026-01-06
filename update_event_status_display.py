import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update Event class to include computedStatus
pattern = r'(class Event \{\r?\n  final int id;\r?\n  final String name;\r?\n  final String category;\r?\n  final String\? startDatetime;\r?\n  final String\? endDatetime;\r?\n  final String location;\r?\n  final String organizer;\r?\n  final int participants;\r?\n  final String status;)'
replacement = r'\1\n  final String? computedStatus;'
content = re.sub(pattern, replacement, content)

# 2. Update Event constructor
pattern = r'(  const Event\(\{\r?\n    required this\.id,\r?\n    required this\.name,\r?\n    required this\.category,\r?\n    this\.startDatetime,\r?\n    this\.endDatetime,\r?\n    required this\.location,\r?\n    required this\.organizer,\r?\n    required this\.participants,\r?\n    required this\.status,)'
replacement = r'\1\n    this.computedStatus,'
content = re.sub(pattern, replacement, content)

# 3. Update fromJson to parse computedStatus
pattern = r'(      participants: json\[\'participants\'\] \?\? 0,\r?\n      status: json\[\'status\'\] \?\? \'Upcoming\',)'
replacement = r"\1\n      computedStatus: json['computed_status'],"
content = re.sub(pattern, replacement, content)

# 4. Add method to get display status (uses computed_status if available)
get_status_method = '''
  String getDisplayStatus(Event event) {
    // Use computed_status from API if available, otherwise use manual status
    if (event.computedStatus != null && event.computedStatus!.isNotEmpty) {
      return event.computedStatus!;
    }
    return event.status;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      case 'Postponed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
'''

# Add before _computeEventStatus method
pattern = r'(\r?\n  String _computeEventStatus\(Event event\) \{)'
if 'String getDisplayStatus' not in content:
    content = re.sub(pattern, get_status_method + r'\1', content)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated events.dart with computed_status support and status colors")
