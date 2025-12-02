import 'package:flutter/material.dart';
import 'dart:convert'; // Required for JSON encoding/decoding

void main() {
  runApp(const HomeworkManagementApp());
}

class HomeworkManagementApp extends StatelessWidget {
  const HomeworkManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Management - Parent Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: const Color(0xff667eea),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(
              secondary: const Color(0xff764ba2),
              primary: const Color(0xff667eea),
            ),
        useMaterial3: true,
      ),
      home: const HomeworkManagementPage(),
    );
  }
}

// Data model with Persistence methods
class Homework {
  final int id;
  final String title;
  final String subject;
  final String dueDate;
  String status;
  final String description;
  final String teacher;
  final String priority;

  Homework({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    required this.description,
    required this.teacher,
    required this.priority,
  });

  // Convert Homework object to a JSON Map
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'dueDate': dueDate,
    'status': status,
    'description': description,
    'teacher': teacher,
    'priority': priority,
  };

  // Create Homework object from a JSON Map
  factory Homework.fromJson(Map<String, dynamic> json) => Homework(
    id: json['id'] as int,
    title: json['title'] as String,
    subject: json['subject'] as String,
    dueDate: json['dueDate'] as String,
    status: json['status'] as String,
    description: json['description'] as String,
    teacher: json['teacher'] as String,
    priority: json['priority'] as String,
  );
}

// Default Data (Used only if no saved data is found)
final List<Homework> _defaultHomeworkList = [
  Homework(
    id: 1,
    title: "Algebra Problem Set",
    subject: "Mathematics",
    dueDate: "2024-12-15",
    status: "pending",
    description:
        "Complete problems 1-20 from Chapter 5. Show all work and submit online.",
    teacher: "Mrs. Johnson",
    priority: "high",
  ),
  Homework(
    id: 2,
    title: "Science Lab Report",
    subject: "Science",
    dueDate: "2024-12-12",
    status: "completed",
    description:
        "Write a detailed report on the chemistry experiment conducted last week.",
    teacher: "Mr. Smith",
    priority: "medium",
  ),
  Homework(
    id: 3,
    title: "Essay on Shakespeare",
    subject: "English",
    dueDate: "2024-12-10",
    status: "overdue",
    description: "Write a 1000-word essay analyzing the themes in Hamlet.",
    teacher: "Ms. Davis",
    priority: "high",
  ),
  Homework(
    id: 4,
    title: "History Timeline Project",
    subject: "History",
    dueDate: "2024-12-18",
    status: "pending",
    description:
        "Create a timeline of major events during the Industrial Revolution.",
    teacher: "Mr. Wilson",
    priority: "medium",
  ),
  Homework(
    id: 5,
    title: "Geography Map Assignment",
    subject: "Geography",
    dueDate: "2024-12-14",
    status: "pending",
    description: "Label all countries in Europe on the provided map.",
    teacher: "Mrs. Brown",
    priority: "medium",
  ),
  Homework(
    id: 6,
    title: "Physics Calculations",
    subject: "Science",
    dueDate: "2024-12-11",
    status: "completed",
    description: "Solve the force and motion problems from the textbook.",
    teacher: "Mr. Smith",
    priority: "medium",
  ),
  Homework(
    id: 7,
    title: "Poetry Analysis",
    subject: "English",
    dueDate: "2024-12-13",
    status: "pending",
    description: "Analyze the poem 'The Road Not Taken' by Robert Frost.",
    teacher: "Ms. Davis",
    priority: "medium",
  ),
  Homework(
    id: 8,
    title: "Geometry Proofs",
    subject: "Mathematics",
    dueDate: "2024-12-09",
    status: "overdue",
    description: "Complete the geometric proofs for triangles and circles.",
    teacher: "Mrs. Johnson",
    priority: "high",
  ),
];

// ====================================================================
// Homework Details Page
// ====================================================================

class HomeworkDetailsPage extends StatelessWidget {
  final Homework homework;
  const HomeworkDetailsPage({super.key, required this.homework});

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: color ?? Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = homework.status == 'pending'
        ? Colors.orange
        : homework.status == 'completed'
        ? const Color(0xff40c057)
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          homework.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                homework.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              homework.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30, thickness: 1),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Due Date',
              homework.dueDate,
              color: statusColor,
            ),
            _buildDetailRow(context, Icons.school, 'Subject', homework.subject),
            _buildDetailRow(
              context,
              Icons.person,
              'Assigned By',
              homework.teacher,
            ),
            _buildDetailRow(
              context,
              Icons.priority_high,
              'Priority',
              homework.priority.toUpperCase(),
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Detailed Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                homework.description,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  'Mark as Completed',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff40c057),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Homework Management Page (Main)
// ====================================================================

class HomeworkManagementPage extends StatefulWidget {
  const HomeworkManagementPage({super.key});

  @override
  State<HomeworkManagementPage> createState() => _HomeworkManagementPageState();
}

class _HomeworkManagementPageState extends State<HomeworkManagementPage> {
  List<Homework> homeworkList = [];

  String activeStatusFilter = 'all';
  String subjectFilter = 'all';
  String searchTerm = '';
  String sortCriteria = 'due_date_asc';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  // MOCKED SAVING FUNCTION
  Future<void> _saveHomework() async {
    final jsonList = homeworkList.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await Future.delayed(const Duration(milliseconds: 100));
    // In a real app, this is where you'd write to SharedPreferences or a database.
    print("Homework Saved: $jsonString");
  }

  // NEW: Loading data from storage
  Future<void> _loadHomework() async {
    await Future.delayed(const Duration(milliseconds: 500));
    String? savedString = null; // Simulate no saved data initially

    if (savedString != null) {
      final jsonList = jsonDecode(savedString) as List;
      homeworkList = jsonList.map((json) => Homework.fromJson(json)).toList();
      _showMsg("Homework loaded from device storage.");
    } else {
      homeworkList = List.from(_defaultHomeworkList);
      _showMsg("Using default homework list.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleHomeworkStatus(Homework homework) {
    // NOTE: homework.status is a String, which is a mutable property in your Homework class.
    if (homework.status != 'completed') {
      setState(() {
        homework.status = 'completed';
      });
      _saveHomework();
      _showMsg("${homework.title} marked as completed! ✅");
    }
  }

  (String, Color) _getDueDateStatus(String dueDateString, String status) {
    if (status == 'completed') {
      return ('Submitted', const Color(0xff40c057));
    }

    DateTime dueDate = DateTime.parse(dueDateString);
    DateTime today = DateTime.now();

    DateTime normalizedDue = DateTime(dueDate.year, dueDate.month, dueDate.day);
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    final difference = normalizedDue.difference(normalizedToday);
    final days = difference.inDays;

    if (days < 0) {
      return ('OVERDUE', Colors.red);
    } else if (days == 0) {
      return ('Due TODAY', Colors.red.shade700);
    } else if (days == 1) {
      return ('Due Tomorrow', Colors.orange);
    } else {
      return ('Due in $days days', const Color(0xff667eea));
    }
  }

  List<Homework> get filteredHomework {
    var list = homeworkList.where((homework) {
      final statusMatch =
          activeStatusFilter == 'all' || homework.status == activeStatusFilter;
      final subjectMatch =
          subjectFilter == 'all' || homework.subject == subjectFilter;
      final searchMatch =
          homework.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
          homework.description.toLowerCase().contains(searchTerm.toLowerCase());
      return statusMatch && subjectMatch && searchMatch;
    }).toList();

    list.sort((a, b) {
      switch (sortCriteria) {
        case 'due_date_desc':
          return b.dueDate.compareTo(a.dueDate);
        case 'title_asc':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'priority_desc':
          final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
          return priorityOrder[b.priority]!.compareTo(
            priorityOrder[a.priority]!,
          );
        case 'due_date_asc':
        default:
          return a.dueDate.compareTo(b.dueDate);
      }
    });

    return list;
  }

  void _showDetailsPage(Homework homework) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeworkDetailsPage(homework: homework),
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = homeworkList.length;
    final completed = homeworkList.where((h) => h.status == 'completed').length;
    final pending = homeworkList.where((h) => h.status == 'pending').length;
    final overdue = homeworkList.where((h) => h.status == 'overdue').length;
    final completionRate = total > 0
        ? ((completed / total) * 100).roundToDouble()
        : 0.0;

    final Color primaryAccent = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: const Text(
          "Homework Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _showMsg("Back to Dashboard (Simulated)"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _loadHomework(),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showMsg("User Profile (Simulated)"),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🚀 Progress Overview
                  _buildProgressOverview(completionRate, completed, total),
                  const SizedBox(height: 16),

                  // ➡️ HORIZONTAL STATS GRID
                  _buildHorizontalStats(
                    total,
                    pending,
                    completed,
                    overdue,
                    primaryAccent,
                  ),
                  const SizedBox(height: 20),
                  _buildFilters(),
                  const SizedBox(height: 10),

                  Text(
                    "📝 Recent Homework (${filteredHomework.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildHomeworkList(),
                  const SizedBox(height: 20),

                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  // --- Widget Builders ---

  // STAT CARD FOR HORIZONTAL SCROLL
  Widget _buildStatCard(
    String icon,
    int number,
    String label,
    Color accentColor,
  ) {
    return Container(
      width: 150, // Fixed width for horizontal scrolling
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          top: BorderSide(color: accentColor, width: 4), // Top accent border
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // HORIZONTAL SCROLLING STATS
  Widget _buildHorizontalStats(
    int total,
    int pending,
    int completed,
    int overdue,
    Color primaryAccent,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          // Total Homework card
          _buildStatCard("📘", total, "Total Homework", primaryAccent),
          const SizedBox(width: 12),
          // Pending card
          _buildStatCard("⏳", pending, "Pending", Colors.orange),
          const SizedBox(width: 12),
          // Completed card
          _buildStatCard("✔️", completed, "Completed", const Color(0xff40c057)),
          const SizedBox(width: 12),
          // Overdue card
          _buildStatCard("🚨", overdue, "Overdue", Colors.red),
          const SizedBox(width: 12), // Spacing after the last card
        ],
      ),
    );
  }

  Widget _buildProgressOverview(
    double completionRate,
    int completed,
    int total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor, width: 6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Completion Rate",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${completionRate.toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff40c057),
                ),
              ),
              Text(
                '$completed / $total Tasks',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xff40c057),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xffe2e2e2)),
            boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
          ),
          child: TextField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: Color(0xff764ba2)),
              border: InputBorder.none,
              hintText: "Search title, event, or description...",
            ),
            onChanged: (v) => setState(() => searchTerm = v),
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Status Chips
              _filterChip(
                'All Status',
                'all',
                activeStatusFilter,
                (v) => setState(() => activeStatusFilter = v),
                isStatusFilter: true, // Marker for status chips
              ),
              _filterChip(
                'Pending',
                'pending',
                activeStatusFilter,
                (v) => setState(() => activeStatusFilter = v),
                isStatusFilter: true,
              ),
              _filterChip(
                'Completed',
                'completed',
                activeStatusFilter,
                (v) => setState(() => activeStatusFilter = v),
                isStatusFilter: true,
              ),
              _filterChip(
                'Overdue',
                'overdue',
                activeStatusFilter,
                (v) => setState(() => activeStatusFilter = v),
                isStatusFilter: true,
              ),
              const SizedBox(width: 12),

              // Subject Chips
              _filterChip(
                'All Subjects',
                'all',
                subjectFilter,
                (v) => setState(() => subjectFilter = v),
                isStatusFilter: false, // Marker for subject chips
              ),
              _filterChip(
                'Math',
                'Mathematics',
                subjectFilter,
                (v) => setState(() => subjectFilter = v),
                isStatusFilter: false,
              ),
              _filterChip(
                'Science',
                'Science',
                subjectFilter,
                (v) => setState(() => subjectFilter = v),
                isStatusFilter: false,
              ),
              _filterChip(
                'English',
                'English',
                subjectFilter,
                (v) => setState(() => subjectFilter = v),
                isStatusFilter: false,
              ),
              _filterChip(
                'History',
                'History',
                subjectFilter,
                (v) => setState(() => subjectFilter = v),
                isStatusFilter: false,
              ),

              const SizedBox(width: 12),
              _buildSortDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    final primaryColor = Theme.of(context).primaryColor;
    final Map<String, String> items = {
      'due_date_asc': 'Due Date (Soonest)',
      'priority_desc': 'Priority (High First)',
      'title_asc': 'Title (A-Z)',
      'due_date_desc': 'Due Date (Farthest)',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: sortCriteria,
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => sortCriteria = v!),
          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
    String current,
    ValueChanged<String> onChanged, {
    required bool isStatusFilter, // New flag to distinguish filter types
  }) {
    final isActive = current == value;
    final primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isActive ? Colors.white : primaryColor,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: isActive ? primaryColor : Colors.white,
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        onPressed: () {
          // 🛠️ FIX: Correctly set the right filter based on the flag
          if (isStatusFilter) {
            setState(() => activeStatusFilter = value);
          } else {
            setState(() => subjectFilter = value);
          }
        },
      ),
    );
  }

  Widget _buildHomeworkList() {
    if (filteredHomework.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            "🎉 All caught up! Or maybe check your filters?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredHomework.length,
      itemBuilder: (context, index) {
        return _buildHomeworkItem(filteredHomework[index]);
      },
    );
  }

  Widget _buildHomeworkItem(Homework hw) {
    final color = hw.status == 'pending'
        ? Colors.orange
        : hw.status == 'completed'
        ? const Color(0xff40c057)
        : Colors.red;

    final (statusText, statusColor) = _getDueDateStatus(hw.dueDate, hw.status);

    String subjectEmoji;
    switch (hw.subject) {
      case 'Mathematics':
        subjectEmoji = '📐';
        break;
      case 'Science':
        subjectEmoji = '🔬';
        break;
      case 'English':
        subjectEmoji = '✍️';
        break;
      case 'History':
        subjectEmoji = '🏛️';
        break;
      case 'Geography':
        subjectEmoji = '🗺️';
        break;
      default:
        subjectEmoji = '📁';
    }

    final bool showMarkDone = hw.status != 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(subjectEmoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          hw.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Teacher: ${hw.teacher} | Priority: ${hw.priority[0].toUpperCase() + hw.priority.substring(1)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              hw.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),

                // DYNAMIC MARK DONE BUTTON/ICON
                if (showMarkDone)
                  SizedBox(
                    height: 30,
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleHomeworkStatus(hw),
                      icon: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Mark Done',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff40c057),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff40c057),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            hw.status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        onTap: () => _showDetailsPage(hw),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "⚡ Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff333333),
          ),
        ),
        const SizedBox(height: 12),
        // Stacked full-width action buttons (one per row)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                Icons.check_circle_outline,
                "Mark Done",
                const Color(0xff40c057),
                () {
                  _showMsg("Mark as Completed functionality");
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                Icons.download,
                "Download Files",
                Theme.of(context).primaryColor,
                () {
                  _showMsg("Download Materials functionality");
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                Icons.message,
                "Contact Teacher",
                Theme.of(context).colorScheme.secondary,
                () {
                  _showMsg("Contact Teacher functionality");
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _actionButton(
                Icons.timer,
                "Request Extension",
                Colors.blue,
                () {
                  _showMsg("Request Extension functionality");
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
      ),
      onPressed: onPressed,
    );
  }
}
