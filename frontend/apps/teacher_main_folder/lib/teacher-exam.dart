import 'package:flutter/material.dart';
import 'teacher-profile.dart';

// --- Constants (Your Data) ---
const List<String> allSubjectsData = [
  'Mathematics',
  'General Science',
  'Social Studies',
  'Language I/II/III',
  'Physics',
  'Chemistry',
  'Biology',
  'English Core',
  'Computer Science',
  'History/Civics/Geography',
  'English Language/Literature',
  'Psychology',
  'Economics',
  'Art',
  'Music',
  'History',
];

const Map<String, List<String>> mockSectionsData = {
  'Nursery': ['Teddy Bears', 'Tiny Tots'],
  'LKG': ['Little Stars', 'Sunshine'],
  'UKG': ['Rising Stars', 'Bright Buds'],
  'I': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'II': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'III': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'IV': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'V': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'VI': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'VII': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'VIII': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'IX': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'X': ['A - Fredo Fighters', 'B - Galileo', 'C - Newton'],
  'XI': ['Science - A', 'Commerce - B', 'Arts - C'],
  'XII': ['Science - A', 'Commerce - B', 'Arts - C'],
};

const List<String> allClassesData = [
  'Nursery',
  'LKG',
  'UKG',
  'I',
  'II',
  'III',
  'IV',
  'V',
  'VI',
  'VII',
  'VIII',
  'IX',
  'X',
  'XI',
  'XII',
];

const List<String> initialExamTypes = [
  'Mid-Term',
  'Final',
  'Unit Test',
  'Quiz',
  'Practical',
  'Project',
];

// --- Data Model for Exam ---
class Exam {
  final int id;
  String title;
  String subject;
  String className; // Will store "Class - Section"
  String date;
  String startTime;
  int duration;
  int marks;
  String status;
  String description;
  String instructions;
  String type;
  String room;

  Exam({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.marks,
    required this.status,
    required this.description,
    required this.instructions,
    required this.type,
    required this.room,
  });
}

// --- Main Application Widget ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Management - Teacher Dashboard',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF667eea),
        useMaterial3: true,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      home: const TeacherDashboard(),
    );
  }
}

// --- Stateful Dashboard Widget ---
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  // Mock Data (Pre-filled examples)
  List<Exam> exams = [
    Exam(
      id: 1,
      title: "Mathematics Mid-Term",
      subject: "Mathematics",
      className: "X - A - Fredo Fighters",
      date: "2024-01-15",
      startTime: "09:00",
      duration: 120,
      marks: 100,
      status: "upcoming",
      description: "Covers Algebra, Geometry, and Trigonometry",
      instructions: "Bring calculator, show all work",
      type: "Mid-Term",
      room: "Room 201",
    ),
  ];

  // Form State Variables
  final _formKey = GlobalKey<FormState>();

  // Dynamic Lists (Mutable State)
  List<String> _availableSubjects = [];
  Map<String, List<String>> _sectionsMap = {}; // Mutable map of sections
  List<String> _availableSections = []; // Currently visible sections
  List<String> _examTypesList = [];

  // Input Variables
  String _title = '';
  String? _subject;
  String? _class;
  String? _section;
  String _date = '';
  String _startTime = '';
  int? _duration;
  int? _marks;
  String _description = '';
  String _instructions = '';
  String? _type;
  String _room = '';

  @override
  void initState() {
    super.initState();
    // Initialize mutable lists from constants
    _availableSubjects = List.from(allSubjectsData);
    _sectionsMap = Map.from(mockSectionsData);
    _examTypesList = List.from(initialExamTypes);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _date =
        "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
  }

  // --- Logic to Add Items Dynamically ---

  // Generic Dialog for Adding Items
  void _showAddItemDialog(String title, Function(String) onAdd) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $title value",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAdd(text);
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              "Add",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Add Subject Logic
  void _promptAddSubject() {
    _showAddItemDialog("Subject", (newItem) {
      setState(() {
        _availableSubjects.add(newItem);
        _availableSubjects.sort();
        _subject = newItem; // Auto-select
      });
    });
  }

  // 2. Add Section Logic
  void _promptAddSection() {
    if (_class == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Class before adding a Section."),
        ),
      );
      return;
    }
    _showAddItemDialog("Section", (newItem) {
      setState(() {
        // Add to the map so it persists for this class
        if (!_sectionsMap.containsKey(_class)) {
          _sectionsMap[_class!] = [];
        }
        _sectionsMap[_class]!.add(newItem);
        _sectionsMap[_class]!.sort();

        // Update currently displayed list
        _availableSections = _sectionsMap[_class]!;
        _section = newItem; // Auto-select
      });
    });
  }

  // 3. Add Exam Type Logic
  void _promptAddExamType() {
    _showAddItemDialog("Exam Type", (newItem) {
      setState(() {
        _examTypesList.add(newItem);
        _type = newItem; // Auto-select
      });
    });
  }

  // --- Header Construction ---
  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Exam Management',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFFf093fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Refreshed data')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TeacherProfilePage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          'Schedule and manage exams for your classes',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- UI Components ---

  // UPDATED: Stat Card with White Background and Blue Top Border
  Widget _buildStatCard(String label, int number, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white, // White Background
        borderRadius: BorderRadius.circular(12),
        // Subtle shadow to make the white card pop
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Top Border Blue
        border: const Border(
          top: BorderSide(
            color: Color(0xFF667eea), // Theme Blue
            width: 4.0,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color, // Keep the specific stats color for the number
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700], // Grey text for contrast on white
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Side-by-side Scrolling Row
  Widget _buildStatsScrollableRow() {
    final upcomingCount = exams.where((e) => e.status == 'upcoming').length;
    final ongoingCount = exams.where((e) => e.status == 'ongoing').length;
    final completedCount = exams.where((e) => e.status == 'completed').length;

    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Total Exams',
        'count': exams.length,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'label': 'Upcoming',
        'count': upcomingCount,
        'color': Theme.of(context).colorScheme.tertiary,
      },
      {
        'label': 'Ongoing',
        'count': ongoingCount,
        'color': const Color(0xFF51cf66),
      },
      {
        'label': 'Completed',
        'count': completedCount,
        'color': Theme.of(context).colorScheme.outline,
      },
    ];

    return SizedBox(
      height: 110, // Fixed height for the slider area
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 130, // Fixed width for uniform cards
            child: _buildStatCard(
              stats[index]['label'],
              stats[index]['count'],
              stats[index]['color'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    String hint,
    Function(String?) onSaved, {
    TextInputType type = TextInputType.text,
    dynamic initialValue,
    int maxLines = 1,
  }) {
    String? stringInitialValue;
    if (initialValue is int || initialValue is double) {
      stringInitialValue = initialValue.toString();
    } else if (initialValue is String) {
      stringInitialValue = initialValue.isNotEmpty ? initialValue : null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
        TextFormField(
          initialValue: stringInitialValue,
          keyboardType: type,
          maxLines: maxLines,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (type == TextInputType.number && int.tryParse(value) == null) {
              return 'Must be a valid number';
            }
            return null;
          },
          onSaved: onSaved,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? currentValue,
    List<T> options,
    String hint,
    Function(T?) onSaved, {
    Function(T?)? onChangedOverride,
    VoidCallback? onAddPressed, // Generic callback for "Add New"
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
              if (onAddPressed != null)
                InkWell(
                  onTap: onAddPressed,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "+ Add New",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        DropdownButtonFormField<T>(
          initialValue: currentValue,
          isExpanded: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            ),
          ),
          items: options.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(value.toString(), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged:
              onChangedOverride ??
              (value) {
                setState(() {
                  if (label == 'Subject') _subject = value as String;
                  if (label == 'Exam Type') _type = value as String;
                  // Class changes are handled by override
                });
              },
          validator: (value) => value == null ? 'Please select $label' : null,
          onSaved: onSaved,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return Column(children: children);
        } else {
          final childrenWithSeparators = List.generate(
            children.length * 2 - 1,
            (index) {
              if (index.isEven) {
                return Expanded(child: children[index ~/ 2]);
              } else {
                return const SizedBox(width: 20);
              }
            },
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childrenWithSeparators,
          );
        }
      },
    );
  }

  Widget _buildExamCard(Exam exam) {
    Color statusColor;
    String statusText;
    switch (exam.status) {
      case 'upcoming':
        statusColor = const Color(0xFF6f42c1);
        statusText = 'Upcoming';
        break;
      case 'ongoing':
        statusColor = const Color(0xFF51cf66);
        statusText = 'Ongoing';
        break;
      case 'completed':
        statusColor = Colors.grey.shade700;
        statusText = 'Completed';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${exam.subject} • ${exam.className}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${exam.date} at ${exam.startTime}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Marks',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exam.marks.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${exam.duration} min',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Room',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exam.room,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _viewExam(exam),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF51cf66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _editExam(exam),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6f42c1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _deleteExam(exam.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfa5252),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildExamDetailGrid(Exam exam) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildDetailItem(Icons.calendar_today, 'Date', exam.date),
        _buildDetailItem(Icons.access_time, 'Time', exam.startTime),
        _buildDetailItem(Icons.timer, 'Duration', '${exam.duration} min'),
        _buildDetailItem(Icons.score, 'Marks', exam.marks.toString()),
        _buildDetailItem(Icons.meeting_room, 'Room', exam.room),
        _buildDetailItem(Icons.label, 'Type', exam.type),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Logic Methods ---

  void _scheduleExam() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final fullClassString = "$_class - $_section";

      final newExam = Exam(
        id: exams.isNotEmpty
            ? exams.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1
            : 1,
        title: _title,
        subject: _subject!,
        className: fullClassString,
        date: _date,
        startTime: _startTime,
        duration: _duration!,
        marks: _marks!,
        status: 'upcoming',
        description: _description,
        instructions: _instructions,
        type: _type!,
        room: _room,
      );

      setState(() {
        exams.insert(0, newExam);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam scheduled successfully!')),
      );

      _formKey.currentState!.reset();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      setState(() {
        _date =
            "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
        _title = '';
        _startTime = '';
        _description = '';
        _instructions = '';
        _room = '';
        _subject = null;
        _class = null;
        _section = null;
        _availableSections = [];
        _type = null;
        _duration = null;
        _marks = null;
      });
    }
  }

  void _editExam(Exam exam) {
    // Populate form with exam data
    setState(() {
      _title = exam.title;
      _subject = exam.subject;
      _date = exam.date;
      _startTime = exam.startTime;
      _duration = exam.duration;
      _marks = exam.marks;
      _description = exam.description;
      _instructions = exam.instructions;
      _type = exam.type;
      _room = exam.room;
      // Parse class and section from className string
      final parts = exam.className.split(' - ');
      if (parts.length >= 2) {
        _class = parts[0];
        _section = parts[1];
        if (_sectionsMap.containsKey(_class)) {
          _availableSections = _sectionsMap[_class]!;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Form populated for editing: ${exam.title}. Update and save.')),
    );
  }

  void _deleteExam(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this exam?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                exams.removeWhere((e) => e.id == id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exam deleted successfully')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _viewExam(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          exam.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${exam.subject} • ${exam.className}'),
              const SizedBox(height: 10),
              Text('Date & Time: ${exam.date} at ${exam.startTime}'),
              Text('Duration: ${exam.duration} min'),
              Text('Marks: ${exam.marks}'),
              Text('Room: ${exam.room}'),
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(exam.description),
              const SizedBox(height: 12),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(exam.instructions),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: _buildHeader(context),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            _buildStatsScrollableRow(),
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 900;

                if (isWideScreen) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildFormSection()),
                      const SizedBox(width: 30),
                      Expanded(child: _buildExamsSection()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildFormSection(),
                      const SizedBox(height: 30),
                      _buildExamsSection(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Schedule New Exam',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              _buildFormRow([
                _buildTextFormField(
                  'Exam Title',
                  'Enter exam title',
                  (value) => _title = value ?? '',
                  initialValue: _title,
                  maxLines: 1,
                ),
              ]),

              _buildFormRow([
                _buildDropdown<String>(
                  'Class',
                  _class,
                  allClassesData,
                  'Select class...',
                  (value) => _class = value,
                  onChangedOverride: (val) {
                    setState(() {
                      _class = val;
                      _section = null;
                      if (val != null && _sectionsMap.containsKey(val)) {
                        _availableSections = _sectionsMap[val]!;
                      } else {
                        _availableSections = [];
                      }
                    });
                  },
                ),
                _buildDropdown<String>(
                  'Section',
                  _section,
                  _availableSections,
                  _availableSections.isEmpty
                      ? 'Select class first'
                      : 'Select section...',
                  (value) => _section = value,
                  onAddPressed: _promptAddSection,
                ),
              ]),

              _buildDropdown<String>(
                'Subject',
                _subject,
                _availableSubjects,
                'Select subject...',
                (value) => _subject = value,
                onAddPressed: _promptAddSubject,
              ),

              _buildFormRow([
                _buildTextFormField(
                  'Exam Date',
                  'YYYY-MM-DD',
                  (value) => _date = value ?? '',
                  initialValue: _date,
                ),
                _buildTextFormField(
                  'Start Time',
                  'HH:MM',
                  (value) => _startTime = value ?? '',
                  initialValue: _startTime,
                ),
              ]),

              _buildFormRow([
                _buildTextFormField(
                  'Duration (minutes)',
                  '120',
                  (value) => _duration = int.tryParse(value ?? ''),
                  type: TextInputType.number,
                  initialValue: _duration,
                ),
                _buildTextFormField(
                  'Total Marks',
                  '100',
                  (value) => _marks = int.tryParse(value ?? ''),
                  type: TextInputType.number,
                  initialValue: _marks,
                ),
              ]),

              _buildTextFormField(
                'Exam Description',
                'Enter exam description and topics covered...',
                (value) => _description = value ?? '',
                initialValue: _description,
                maxLines: 3,
              ),
              _buildTextFormField(
                'Instructions',
                'Enter exam instructions for students...',
                (value) => _instructions = value ?? '',
                initialValue: _instructions,
                maxLines: 3,
              ),

              _buildFormRow([
                _buildDropdown<String>(
                  'Exam Type',
                  _type,
                  _examTypesList,
                  'Select type...',
                  (value) => _type = value,
                  onAddPressed: _promptAddExamType,
                ),
                _buildTextFormField(
                  'Room/Classroom',
                  'Room 101',
                  (value) => _room = value ?? '',
                  initialValue: _room,
                ),
              ]),

              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _scheduleExam,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Schedule Exam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51cf66),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamsSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Scheduled Exams',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            if (exams.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No exams scheduled yet.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...exams.map((exam) => _buildExamCard(exam)),
          ],
        ),
      ),
    );
  }
}
