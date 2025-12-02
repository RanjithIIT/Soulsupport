import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- CONSTANTS & MOCK DATA CONFIGURATION ---

const List<String> allClasses = [
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

const Map<String, List<String>> mockSections = {
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

// --- MODELS ---

class Student {
  final int id;
  final String name;
  final String rollNo;
  final String avatarInitials;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.avatarInitials,
  });
}

enum AttendanceStatus { present, absent, late }

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green.shade700;
      case AttendanceStatus.absent:
        return Colors.red.shade700;
      case AttendanceStatus.late:
        return Colors.orange.shade700;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green.shade100;
      case AttendanceStatus.absent:
      case AttendanceStatus.late:
        return Colors.grey.shade200;
    }
  }
}

// --- MOCK DATA POPULATION ---
// We map the complex Section names to our student lists using a composite key: "$Class_$Section"
final Map<String, List<Student>> mockStudents = {
  // Nursery
  'Nursery_Teddy Bears': [
    Student(id: 16, name: 'Leo Khan', rollNo: 'NA01', avatarInitials: 'LK'),
    Student(id: 17, name: 'Mia Ray', rollNo: 'NA02', avatarInitials: 'MR'),
  ],
  'Nursery_Tiny Tots': [
    Student(id: 48, name: 'Naveen Raj', rollNo: 'NB01', avatarInitials: 'NR'),
    Student(id: 49, name: 'Priya Sen', rollNo: 'NB02', avatarInitials: 'PS'),
  ],

  // LKG
  'LKG_Little Stars': [
    Student(id: 18, name: 'Noah Bell', rollNo: 'LA01', avatarInitials: 'NB'),
    Student(id: 19, name: 'Olivia Gray', rollNo: 'LA02', avatarInitials: 'OG'),
  ],

  // UKG
  'UKG_Rising Stars': [
    Student(id: 20, name: 'Peter Hall', rollNo: 'UA01', avatarInitials: 'PH'),
    Student(id: 21, name: 'Quinn Ivy', rollNo: 'UA02', avatarInitials: 'QI'),
  ],

  // Class I
  'I_A - Fredo Fighters': [
    Student(id: 24, name: 'Tyler Lewis', rollNo: '1A01', avatarInitials: 'TL'),
    Student(id: 25, name: 'Vera Moon', rollNo: '1A02', avatarInitials: 'VM'),
  ],
  'I_B - Galileo': [
    Student(id: 56, name: 'Wanda Paul', rollNo: '1B01', avatarInitials: 'WP'),
    Student(id: 57, name: 'Yusuf Chen', rollNo: '1B02', avatarInitials: 'YC'),
  ],

  // Class X
  'X_A - Fredo Fighters': [
    Student(
      id: 1,
      name: 'Sarah Johnson',
      rollNo: '10A01',
      avatarInitials: 'SJ',
    ),
    Student(id: 2, name: 'Mike Chen', rollNo: '10A02', avatarInitials: 'MC'),
    Student(id: 3, name: 'Emma Davis', rollNo: '10A03', avatarInitials: 'ED'),
  ],
  'X_B - Galileo': [
    Student(id: 6, name: 'David Wilson', rollNo: '10B01', avatarInitials: 'DW'),
    Student(id: 7, name: 'Maria Garcia', rollNo: '10B02', avatarInitials: 'MG'),
  ],

  // Class XI
  'XI_Science - A': [
    Student(
      id: 11,
      name: 'Rachel Green',
      rollNo: '11S01',
      avatarInitials: 'RG',
    ),
    Student(id: 12, name: 'Kevin Patel', rollNo: '11S02', avatarInitials: 'KP'),
  ],
  'XI_Commerce - B': [
    Student(id: 42, name: 'Max Stone', rollNo: '11C01', avatarInitials: 'MS'),
    Student(id: 43, name: 'Zoe Vance', rollNo: '11C02', avatarInitials: 'ZV'),
  ],

  // Class XII
  'XII_Science - A': [
    Student(id: 44, name: 'John Baker', rollNo: '12S01', avatarInitials: 'JB'),
    Student(id: 45, name: 'Tina Clark', rollNo: '12S02', avatarInitials: 'TC'),
  ],
  'XII_Arts - C': [
    Student(
      id: 99,
      name: 'Artie Fischel',
      rollNo: '12A01',
      avatarInitials: 'AF',
    ),
  ],
};

// --- THEME COLORS ---
const Color primaryColor = Color(0xFF1565C0);
const Color accentColor = Color(0xFFFFC107);
const Color backgroundColor = Color(0xFFEEEEEE);

// --- MAIN APPLICATION ---
void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(
              secondary: accentColor,
              primary: primaryColor,
              surface: Colors.white,
            ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
      ),
      home: const AttendanceDashboard(),
    );
  }
}

// --- DASHBOARD SCREEN ---

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  // State for Class & Section Separation
  String? _selectedClass; // e.g., "I", "X"
  String? _selectedSection; // e.g., "A - Fredo Fighters"

  DateTime _selectedDate = DateTime.now();
  List<Student> _students = [];
  final Map<int, AttendanceStatus> _attendanceRecords = {};
  final Map<int, String> _remarks = {};

  @override
  void initState() {
    super.initState();
    _initializeAllPossibleAttendance();

    // Default selection initialization
    _selectedClass = allClasses.first;
    _selectedSection = mockSections[_selectedClass]!.first;
    _loadStudents();
  }

  // Initializes records for all students in mock db to avoid null errors
  void _initializeAllPossibleAttendance() {
    for (var list in mockStudents.values) {
      for (var student in list) {
        if (!_attendanceRecords.containsKey(student.id)) {
          _attendanceRecords[student.id] = AttendanceStatus.present;
          _remarks[student.id] = '';
        }
      }
    }
  }

  void _loadStudents() {
    if (_selectedClass == null || _selectedSection == null) return;

    // Construct the composite key to look up students
    final String lookupKey = "${_selectedClass}_$_selectedSection";

    setState(() {
      _students = mockStudents[lookupKey] ?? [];
    });
  }

  void _updateAttendance(int studentId, AttendanceStatus status) {
    setState(() {
      _attendanceRecords[studentId] = status;
    });
  }

  Map<String, int> _getAttendanceStats() {
    int present = 0;
    int absent = 0;
    int late = 0;

    for (var student in _students) {
      final status = _attendanceRecords[student.id] ?? AttendanceStatus.present;
      if (status == AttendanceStatus.present) {
        present++;
      } else if (status == AttendanceStatus.absent)
        absent++;
      else if (status == AttendanceStatus.late)
        late++;
    }
    return {
      'total': _students.length,
      'present': present,
      'absent': absent,
      'late': late,
    };
  }

  // --- UI WIDGETS ---

  void _showEditRemarkDialog(Student student) {
    String currentRemark = _remarks[student.id] ?? '';
    final TextEditingController controller = TextEditingController(
      text: currentRemark,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Remarks for ${student.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _remarks[student.id] = controller.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
      ),
      title: const Text(
        'Teacher Attendance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      elevation: 8,
    );
  }

  // --- REVISED CONTROLS CARD (Split Class & Section) ---
  Widget _buildControlsCard(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    // Get available sections based on selected class
    final List<String> availableSections = _selectedClass != null
        ? (mockSections[_selectedClass] ?? [])
        : [];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            const Divider(color: Colors.black12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // 1. GRADE DROPDOWN
                SizedBox(
                  width: isWide
                      ? 180
                      : (MediaQuery.of(context).size.width / 2 - 32),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Class / Grade',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    initialValue: _selectedClass,
                    hint: const Text('Select'),
                    items: allClasses.map((String cls) {
                      return DropdownMenuItem<String>(
                        value: cls,
                        child: Text(cls),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        // Reset section when class changes
                        _selectedSection = null;
                        _students = []; // Clear list until section selected
                      });
                    },
                  ),
                ),

                // 2. SECTION DROPDOWN (Dependent on Grade)
                SizedBox(
                  width: isWide
                      ? 240
                      : (MediaQuery.of(context).size.width / 2 - 32),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    initialValue: _selectedSection,
                    hint: const Text('Select Section'),
                    disabledHint: const Text('Select Class first'),
                    // If no class selected, disable this dropdown
                    items: _selectedClass == null
                        ? []
                        : availableSections.map((String sec) {
                            return DropdownMenuItem<String>(
                              value: sec,
                              child: Text(sec, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                    onChanged: _selectedClass == null
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _selectedSection = newValue;
                              _loadStudents(); // Load automatically on section select
                            });
                          },
                    isExpanded:
                        true, // Handle long section names like "Fredo Fighters"
                  ),
                ),

                // 3. DATE PICKER
                SizedBox(
                  width: isWide ? 180 : double.infinity,
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_students.isEmpty) return const SizedBox.shrink();
    final stats = _getAttendanceStats();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard('Total Students', stats['total'] ?? 0, primaryColor),
            const SizedBox(width: 6),
            _buildStatCard(
              'Present',
              stats['present'] ?? 0,
              AttendanceStatus.present.color,
            ),
            const SizedBox(width: 6),
            _buildStatCard(
              'Absent',
              stats['absent'] ?? 0,
              AttendanceStatus.absent.color,
            ),
            const SizedBox(width: 6),
            _buildStatCard(
              'Late',
              stats['late'] ?? 0,
              AttendanceStatus.late.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color statusColor) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_selectedClass == null || _selectedSection == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Please select a Class and Section.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(Icons.person_off, size: 48, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                'No student records found for\n$_selectedClass - $_selectedSection',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student Records',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save, color: Colors.white, size: 20),
                label: const Text(
                  'Save All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AttendanceStatus.present.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final student = _students[index];
            final currentStatus = _attendanceRecords[student.id]!;
            return _buildStudentCard(student, currentStatus);
          },
        ),
      ],
    );
  }

  void _saveAttendance() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  Widget _buildStudentCard(Student student, AttendanceStatus currentStatus) {
    final String remarksText = _remarks[student.id]!.isNotEmpty
        ? ' | Remarks: ${_remarks[student.id]}'
        : '';
    final String rollAndRemark = 'Roll No: ${student.rollNo}$remarksText';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: currentStatus.color.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: currentStatus.color.withValues(alpha: 0.1),
                  foregroundColor: currentStatus.color,
                  child: Text(
                    student.avatarInitials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_note,
                              size: 28,
                              color: primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showEditRemarkDialog(student),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rollAndRemark,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontStyle: _remarks[student.id]!.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: currentStatus.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currentStatus.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              'Change Status:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: AttendanceStatus.values
                  .map(
                    (status) =>
                        _buildStatusButton(student.id, status, currentStatus),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    int studentId,
    AttendanceStatus status,
    AttendanceStatus currentStatus,
  ) {
    final isSelected = currentStatus == status;
    return GestureDetector(
      onTap: () => _updateAttendance(studentId, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? status.color
              : status.backgroundColor.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected ? status.color : Colors.black26,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildControlsCard(context),
                const SizedBox(height: 25),
                _buildStatsGrid(),
                const SizedBox(height: 10),
                _buildAttendanceList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
