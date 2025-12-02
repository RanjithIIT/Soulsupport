import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:main_login/main.dart' as main_login;
// Navigation imports
import 'teacher-assignment.dart';
import 'teacher-attendance.dart';
import 'teacher-exam.dart';
import 'teacher-grades.dart';
import 'teacher-profile.dart';
import 'Teacher_classes.dart';
import 'Teacher_class_students.dart';
import 'Teacher_Communication.dart';
import 'Teacher_Results.dart';
// Removed: import 'screens/stat_detail.dart';
// Definition for StatDetailScreen added below main file.

// --- MOCK DATA STRUCTURES ---
class DashboardData {
  final int totalStudents;
  final int totalClasses;
  final int upcomingExams;
  final int pendingAssignments;
  final int totalResults;
  // Metrics corresponding to the file list
  final int totalAttendanceRecords;
  final int totalStudyMaterials;
  final int totalGradesPending;
  final int totalCommunication;
  final int totalTimetableSlots;
  final int profileCompleteness; // New: Profile completeness percentage

  final String attendanceRate;
  final String avgGrade;
  final List<ClassData> classes;

  DashboardData({
    required this.totalStudents,
    required this.totalClasses,
    required this.upcomingExams,
    required this.pendingAssignments,
    required this.totalResults,
    required this.attendanceRate,
    required this.avgGrade,
    required this.classes,
    required this.totalAttendanceRecords,
    required this.totalStudyMaterials,
    required this.totalGradesPending,
    required this.totalCommunication,
    required this.totalTimetableSlots,
    this.profileCompleteness = 85, // Default 85% complete
  });
}

class ClassData {
  final String name;
  final int students;
  final List<String> subjects;

  ClassData({
    required this.name,
    required this.students,
    required this.subjects,
  });
}

class ChartData {
  final String day;
  final int present;
  final int absent;
  final int late;

  ChartData({
    required this.day,
    required this.present,
    required this.absent,
    required this.late,
  });
}

class SubjectData {
  final String subject;
  final int average;

  SubjectData({required this.subject, required this.average});
}

class ChatMessage {
  final String text;
  final String sender; // 'user', 'teacher', or 'system'
  final String time;
  final String? senderName; // Teacher name for individual chats
  final String? avatarEmoji;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
    this.senderName,
    this.avatarEmoji,
  });
}

class Teacher {
  final String id;
  final String name;
  final String subject;
  final String avatar;
  final bool isOnline;

  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.avatar,
    required this.isOnline,
  });
}

class GroupChat {
  final String id;
  final String name;
  final String description;

  final List<Teacher> members;
  final String avatar;
  final int unreadCount;

  GroupChat({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.avatar,
    required this.unreadCount,
  });
}

// --- MOCK DATA IMPLEMENTATION ---
Future<DashboardData> fetchDashboardData() async {
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
  return DashboardData(
    totalStudents: 150,
    totalClasses: 4,
    upcomingExams: 3,
    pendingAssignments: 7,
    totalResults: 12,
    attendanceRate: '92.5%',
    avgGrade: 'B+',
    classes: [
      ClassData(
        name: 'Class 10A',
        students: 35,
        subjects: ['Mathematics', 'Physics'],
      ),
      ClassData(
        name: 'Class 11B',
        students: 30,
        subjects: ['Chemistry', 'Biology'],
      ),
      ClassData(
        name: 'Class 9C',
        students: 32,
        subjects: ['English Core', 'History'],
      ),
      ClassData(
        name: 'Class 12A',
        students: 28,
        subjects: ['Economics', 'Psychology'],
      ),
    ],
    // New mock data initializations
    totalAttendanceRecords: 450,
    totalStudyMaterials: 35,
    totalGradesPending: 15,
    totalCommunication: 8,
    totalTimetableSlots: 40,
  );
}

// --- MAIN WIDGET ---
void main() {
  runApp(const TeacherDashboardApp());
}

class TeacherDashboardApp extends StatelessWidget {
  const TeacherDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Segoe UI',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardData> _dashboardData;
  DateTime _currentDate = DateTime.now();
  bool _isChatOpen = false;
  String _selectedAttendancePeriod =
      'Weekly'; // Separate for Attendance Performance
  String _selectedProgressPeriod =
      'Weekly'; // Separate for Class Progress Overview

  // Chat variables
  String _chatMode = 'individual'; // 'individual' or 'group'
  String? _selectedChatId;
  String _searchQuery = '';
  final TextEditingController _chatSearchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isEmojiPickerVisible = false;

  late List<Teacher> _teachers;
  late List<GroupChat> _groups;
  late Map<String, List<ChatMessage>> _chatMessages;

  @override
  void initState() {
    super.initState();
    _dashboardData = fetchDashboardData();
    _initializeChatData();
  }

  void _initializeChatData() {
    _teachers = [
      Teacher(
        id: 't1',
        name: 'Mrs. Sarah Johnson',
        subject: 'Mathematics',
        avatar: '👩‍🏫',
        isOnline: true,
      ),
      Teacher(
        id: 't2',
        name: 'Mr. David Chen',
        subject: 'Physics',
        avatar: '👨‍🏫',
        isOnline: true,
      ),
      Teacher(
        id: 't3',
        name: 'Ms. Emily Watson',
        subject: 'English',
        avatar: '👩‍🏫',
        isOnline: false,
      ),
      Teacher(
        id: 't4',
        name: 'Mr. James Miller',
        subject: 'Chemistry',
        avatar: '👨‍🏫',
        isOnline: true,
      ),
      Teacher(
        id: 't5',
        name: 'Ms. Lisa Anderson',
        subject: 'History',
        avatar: '👩‍🏫',
        isOnline: true,
      ),
    ];

    _groups = [
      GroupChat(
        id: 'g1',
        name: 'Class 10A - All Teachers',
        description: '5 members',
        members: _teachers.sublist(0, 3),
        avatar: '👥',
        unreadCount: 2,
      ),
      GroupChat(
        id: 'g2',
        name: 'Science Department',
        description: '3 members',
        members: _teachers.sublist(1, 4),
        avatar: '🔬',
        unreadCount: 0,
      ),
      GroupChat(
        id: 'g3',
        name: 'Parent-Teacher Forum',
        description: '8 members',
        members: _teachers,
        avatar: '💬',
        unreadCount: 5,
      ),
    ];

    _chatMessages = {
      't1': [
        ChatMessage(
          text: "Hi! Your child did great on the mathematics test!",
          sender: 'teacher',
          time: DateFormat(
            'hh:mm a',
          ).format(DateTime.now().subtract(const Duration(hours: 2))),
          senderName: 'Mrs. Sarah Johnson',
          avatarEmoji: '👩‍🏫',
        ),
        ChatMessage(
          text: "Thank you! He/she prepared really well.",
          sender: 'user',
          time: DateFormat('hh:mm a').format(
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
          avatarEmoji: '👤',
        ),
      ],
      't2': [
        ChatMessage(
          text: "Good morning! Can we discuss the upcoming physics project?",
          sender: 'teacher',
          time: DateFormat(
            'hh:mm a',
          ).format(DateTime.now().subtract(const Duration(minutes: 45))),
          senderName: 'Mr. David Chen',
          avatarEmoji: '👨‍🏫',
        ),
      ],
      't3': [
        ChatMessage(
          text: "Please review the essay I shared yesterday.",
          sender: 'user',
          time: DateFormat(
            'hh:mm a',
          ).format(DateTime.now().subtract(const Duration(days: 1))),
          avatarEmoji: '👤',
        ),
      ],
      't4': [],
      't5': [],
      'g1': [
        ChatMessage(
          text: "Reminder: Parent-Teacher meeting on Friday at 4 PM",
          sender: 'teacher',
          time: DateFormat(
            'hh:mm a',
          ).format(DateTime.now().subtract(const Duration(hours: 3))),
          senderName: 'Mrs. Sarah Johnson',
          avatarEmoji: '👩‍🏫',
        ),
      ],
      'g2': [],
      'g3': [
        ChatMessage(
          text: "Don't forget to submit assignments by tomorrow!",
          sender: 'teacher',
          time: DateFormat(
            'hh:mm a',
          ).format(DateTime.now().subtract(const Duration(hours: 1))),
          senderName: 'Mr. David Chen',
          avatarEmoji: '👨‍🏫',
        ),
      ],
    };
  }

  // --- Core Functions ---

  // Navigation function to handle routing to different screens
  void _navigateToScreen(String label) {
    switch (label.toLowerCase()) {
      case 'add-assignment':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssignmentDashboardScreen()),
        );
        break;
      case 'attendance':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AttendanceDashboard()),
        );
        break;
      case 'class-students':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentDashboardScreen()),
        );
        break;
      case 'classes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyClassesPage()),
        );
        break;
      case 'communication':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherCommunicationScreen(
              onToggleTheme: () {},
              initialThemeMode: ThemeMode.light,
            ),
          ),
        );
        break;
      case 'exam':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeacherDashboard()),
        );
        break;
      case 'grades':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GradesDashboard()),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeacherProfilePage()),
        );
        break;
      case 'results':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EnterResultsScreen()),
        );
        break;
      case 'study materials':
        // Import StudyMaterialsDashboardScreen - using alias to avoid conflict
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Builder(
              builder: (ctx) => Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8E6BFF), Color(0xFF7A4BE6)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Text('Study Materials', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: const Center(child: Text('Study Materials - Coming Soon')),
              ),
            ),
          ),
        );
        break;
      case 'time-table':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Builder(
              builder: (ctx) => Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8E6BFF), Color(0xFF7A4BE6)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Text('Timetable', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: const Center(child: Text('Timetable - Coming Soon')),
              ),
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation to $label not implemented')),
        );
    }
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      // When opening the chat, ensure the list view is shown first.
      if (_isChatOpen) {
        _selectedChatId = null;
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<dynamic> _getFilteredChats() {
    final query = _searchQuery.toLowerCase();
    if (_chatMode == 'individual') {
      return _teachers.where((teacher) {
        return teacher.name.toLowerCase().contains(query) ||
            teacher.subject.toLowerCase().contains(query);
      }).toList();
    } else {
      return _groups.where((group) {
        return group.name.toLowerCase().contains(query) ||
            group.description.toLowerCase().contains(query);
      }).toList();
    }
  }

  List<ChatMessage> _getSelectedChatMessages() {
    if (_selectedChatId == null) return [];
    return _chatMessages[_selectedChatId] ?? [];
  }

  String _getSelectedChatName() {
    if (_selectedChatId == null) return '';
    if (_chatMode == 'individual') {
      final teacher = _teachers.firstWhere(
        (t) => t.id == _selectedChatId,
        orElse: () => _teachers.first,
      );
      return teacher.name;
    } else {
      final group = _groups.firstWhere(
        (g) => g.id == _selectedChatId,
        orElse: () => _groups.first,
      );
      return group.name;
    }
  }

  // Get attendance data based on selected period
  Map<String, String> _getAttendanceData(String period) {
    final data = {
      'Weekly': {'attendance': '92.5%', 'grade': 'B+'},
      'Monthly': {'attendance': '88.3%', 'grade': 'A-'},
      'Quarterly': {'attendance': '85.7%', 'grade': 'B'},
      'Yearly': {'attendance': '87.2%', 'grade': 'A'},
    };
    return data[period] ?? data['Weekly']!;
  }

  // Get progress chart data based on selected period
  List<SubjectData> _getProgressChartData(String period) {
    final dataMap = {
      'Weekly': [
        SubjectData(subject: 'Math', average: 85),
        SubjectData(subject: 'Science', average: 78),
        SubjectData(subject: 'English', average: 92),
        SubjectData(subject: 'History', average: 81),
      ],
      'Monthly': [
        SubjectData(subject: 'Math', average: 88),
        SubjectData(subject: 'Science', average: 82),
        SubjectData(subject: 'English', average: 90),
        SubjectData(subject: 'History', average: 85),
      ],
      'Quarterly': [
        SubjectData(subject: 'Math', average: 80),
        SubjectData(subject: 'Science', average: 75),
        SubjectData(subject: 'English', average: 87),
        SubjectData(subject: 'History', average: 78),
      ],
      'Yearly': [
        SubjectData(subject: 'Math', average: 86),
        SubjectData(subject: 'Science', average: 81),
        SubjectData(subject: 'English', average: 91),
        SubjectData(subject: 'History', average: 82),
      ],
    };
    return dataMap[period] ?? dataMap['Weekly']!;
  }

  // This is a complex mock function based on the JS logic.
  Map<String, dynamic> _generateAttendanceData(DateTime date) {
    final day = date.weekday;
    final isWeekend = day == DateTime.saturday || day == DateTime.sunday;

    if (isWeekend) {
      return {
        'present': 0,
        'absent': 0,
        'late': 0,
        'total': 0,
        'attendanceRate': 0,
        'classes': [],
      };
    }

    final classes = [
      {'name': 'Class 10A', 'subject': 'Mathematics'},
      {'name': 'Class 11B', 'subject': 'Physics'},
      {'name': 'Class 9C', 'subject': 'English'},
      {'name': 'Class 12A', 'subject': 'Chemistry'},
    ];

    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    int totalStudents = 0;

    // Using a seeded Random based on the date to make the mock data semi-consistent
    final random = Random(date.millisecondsSinceEpoch);

    final classData = classes.map((cls) {
      final totalClassStudents = random.nextInt(16) + 20; // 20-35 students
      final present =
          random.nextInt((totalClassStudents * 0.3).round()) +
          (totalClassStudents * 0.6).round(); // 60-90% present
      final late = random.nextInt(5) + 1; // 1-5 late
      final absent = max(0, totalClassStudents - present - late);
      final rate = ((present + late) / totalClassStudents * 100).round();

      totalPresent += present;
      totalAbsent += absent;
      totalLate += late;
      totalStudents += totalClassStudents;

      return {
        ...cls,
        'present': present,
        'absent': absent,
        'late': late,
        'rate': rate,
      };
    }).toList();

    final attendanceRate = totalStudents > 0
        ? (((totalPresent + totalLate) / totalStudents) * 100).round()
        : 0;

    return {
      'present': totalPresent,
      'absent': totalAbsent,
      'late': totalLate,
      'total': totalStudents,
      'attendanceRate': attendanceRate,
      'classes': classData,
    };
  }

  // --- UI Builders ---

  String _safeNumber(Object? v) {
    try {
      if (v == null) return '0';
      return v.toString();
    } catch (e) {
      return '0';
    }
  }

  Widget _buildStatCard(
    String icon,
    String number,
    String label, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFF667eea), width: 4),
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20).copyWith(top: 20 - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 10),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassData classItem) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFdee2e6), width: 2),
      ),
      elevation: 0,
      color: const Color(0xFFf8f9fa),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              classItem.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildClassStat(
                    classItem.students.toString(),
                    'Students',
                    const Color(0xFF667eea),
                  ),
                ),
                Expanded(
                  child: _buildClassStat(
                    classItem.subjects.length.toString(),
                    'Subjects',
                    const Color(0xFF667eea),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: classItem.subjects
                  .map((subject) => _buildSubjectTag(subject))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassStat(String number, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectTag(String subject) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showAttendanceModal(DateTime date) {
    final data = _generateAttendanceData(date);
    final dateString = DateFormat('EEEE, MMMM d, yyyy').format(date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width > 600
                ? 800
                : MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20).copyWith(left: 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Attendance Details - $dateString',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAttendanceSummaryGrid(data),
                        const SizedBox(height: 25),
                        _buildAttendanceRateCircle(
                          data['attendanceRate'] as int,
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'Class-wise Breakdown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Divider(height: 20),
                        ...((data['classes'] as List<Map<String, dynamic>>)
                            .map((cls) => _buildClassAttendanceItem(cls))
                            .toList()),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSummaryGrid(Map<String, dynamic> data) {
    // FIX: Safely retrieve and cast integers, providing a default of 0 if null.
    final present = (data['present'] as int?) ?? 0;
    final absent = (data['absent'] as int?) ?? 0;
    final late = (data['late'] as int?) ?? 0;
    final total = (data['total'] as int?) ?? 0;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          present,
          'Present',
          '✅',
          const Color(0xFF28a745),
          const Color(0xFFd4edda),
        ),
        _buildSummaryCard(
          absent,
          'Absent',
          '❌',
          const Color(0xFFdc3545),
          const Color(0xFFf8d7da),
        ),
        _buildSummaryCard(
          late,
          'Late',
          '⏰',
          const Color(0xFFffc107),
          const Color(0xFFfff3cd),
        ),
        _buildSummaryCard(
          total,
          'Total',
          '👥',
          const Color(0xFF667eea),
          const Color(0xFFe3f2fd),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    int number,
    String label,
    String icon,
    Color borderColor,
    Color backgroundColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          Text(
            number.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRateCircle(int rate) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFf0f4ff),
          border: Border.all(color: const Color(0xFF667eea), width: 3),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$rate%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF667eea),
              ),
            ),
            const Text(
              'Attendance Rate',
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassAttendanceItem(Map<String, dynamic> cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF667eea), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cls['name'].toString(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            cls['subject'].toString(),
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildStatDetail(
                'Present',
                cls['present'].toString(),
                const Color(0xFF28a745),
              ),
              _buildStatDetail(
                'Absent',
                cls['absent'].toString(),
                const Color(0xFFdc3545),
              ),
              _buildStatDetail(
                'Late',
                cls['late'].toString(),
                const Color(0xFFffc107),
              ),
              _buildStatDetail(
                'Rate',
                '${cls['rate']}%',
                const Color(0xFF667eea),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  // --- Chart CustomPainter Widgets ---

  Widget _buildTimePeriodButton(String period, String sectionType) {
    final isSelected = sectionType == 'attendance'
        ? _selectedAttendancePeriod == period
        : _selectedProgressPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (sectionType == 'attendance') {
            _selectedAttendancePeriod = period;
          } else {
            _selectedProgressPeriod = period;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.white,
          border: Border.all(color: const Color(0xFF667eea), width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF667eea),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // --- Message Input with Controls (NEW IMPLEMENTATION) ---
  Widget _buildMessageInputWithControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji Picker (shown when visible)
        if (_isEmojiPickerVisible) _buildEmojiPicker(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            color: Colors.white, // Ensure background is white
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Emoji Button
              IconButton(
                icon: Icon(
                  _isEmojiPickerVisible
                      ? Icons.keyboard
                      : Icons.sentiment_satisfied_outlined,
                  color: const Color(0xFF667eea),
                ),
                onPressed: () {
                  setState(() {
                    _isEmojiPickerVisible = !_isEmojiPickerVisible;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
              const SizedBox(width: 8),

              // File Attach Button
              IconButton(
                icon: const Icon(Icons.attach_file, color: Color(0xFF667eea)),
                onPressed: () {
                  _showSnackBar('Attach file (simulated)');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      _sendChatMessage(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Voice Button (Smaller for mic icon)
              IconButton(
                icon: const Icon(Icons.mic_none, color: Color(0xFF667eea)),
                onPressed: () {
                  _showSnackBar('Voice message (simulated)');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
              const SizedBox(width: 8),

              // Send Button (Action Button style)
              SizedBox(
                width: 40,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _sendChatMessage(_messageController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    // Common emojis organized by category
    final List<List<String>> emojiCategories = [
      // Smileys & People
      [
        '😀',
        '😃',
        '😄',
        '😁',
        '😆',
        '😅',
        '😂',
        '🤣',
        '😊',
        '😇',
        '🙂',
        '🙃',
        '😉',
        '😌',
        '😍',
        '🥰',
        '😘',
        '😗',
        '😙',
        '😚',
        '😋',
        '😛',
        '😝',
        '😜',
        '🤪',
        '🤨',
        '🧐',
        '🤓',
        '😎',
        '🤩',
        '🥳',
        '😏',
        '😒',
        '😞',
        '😔',
        '😟',
        '😕',
        '🙁',
        '☹️',
        '😣',
        '😖',
        '😫',
        '😩',
        '🥺',
        '😢',
        '😭',
        '😤',
        '😠',
        '😡',
        '🤬',
        '🤯',
        '😳',
        '🥵',
        '🥶',
        '😱',
        '😨',
        '😰',
        '😥',
        '😓',
        '🤗',
        '🤔',
        '🤭',
        '🤫',
        '🤥',
        '😶',
        '😐',
        '😑',
        '😬',
        '🙄',
        '😯',
        '😦',
        '😧',
        '😮',
        '😲',
        '🥱',
        '😴',
        '🤤',
        '😪',
        '😵',
        '🤐',
        '🥴',
        '🤢',
        '🤮',
        '🤧',
        '😷',
        '🤒',
        '🤕',
      ],
      // Gestures
      [
        '👋',
        '🤚',
        '🖐',
        '✋',
        '🖖',
        '👌',
        '🤏',
        '✌️',
        '🤞',
        '🤟',
        '🤘',
        '🤙',
        '👈',
        '👉',
        '👆',
        '🖕',
        '👇',
        '☝️',
        '👍',
        '👎',
        '✊',
        '👊',
        '🤛',
        '🤜',
        '👏',
        '🙌',
        '👐',
        '🤲',
        '🤝',
        '🙏',
        '✍️',
        '💪',
        '🦾',
        '🦿',
        '🦵',
        '🦶',
        '👂',
        '🦻',
        '👃',
        '🧠',
        '🦷',
        '🦴',
        '👀',
        '👁️',
        '👅',
        '👄',
      ],
      // Hearts & Love
      [
        '💋',
        '💌',
        '💘',
        '💝',
        '💖',
        '💗',
        '💓',
        '💞',
        '💕',
        '💟',
        '❣️',
        '💔',
        '❤️',
        '🧡',
        '💛',
        '💚',
        '💙',
        '💜',
        '🖤',
        '🤍',
        '🤎',
        '💯',
        '💢',
        '💥',
        '💫',
        '💦',
        '💨',
        '🕳️',
        '💣',
        '💬',
        '👁️‍🗨️',
        '🗨️',
        '🗯️',
        '💭',
        '💤',
      ],
      // Objects & Symbols
      [
        '🎉',
        '🎊',
        '🎈',
        '🎁',
        '🏆',
        '🥇',
        '🥈',
        '🥉',
        '⚽',
        '🏀',
        '🏈',
        '⚾',
        '🎾',
        '🏐',
        '🏉',
        '🎱',
        '🏓',
        '🏸',
        '🥅',
        '🏒',
        '🏑',
        '🏏',
        '⛳',
        '🏹',
        '🎣',
        '🥊',
        '🥋',
        '🎽',
        '🛹',
        '🛷',
        '⛸️',
        '🥌',
        '🎿',
        '⛷️',
        '🏂',
        '🏋️',
        '🤼',
        '🤸',
        '🤺',
        '🧘',
        '🏌️',
        '🏇',
        '🧗',
        '🚵',
        '🚴',
        '🏄',
        '🏊',
        '🤽',
        '🤾',
        '🤹',
        '🧝',
        '🧛',
        '🧜',
        '🧚',
        '🧞',
        '🧟',
        '🧙',
      ],
    ];

    // Flatten all emojis into one list
    final List<String> allEmojis = emojiCategories
        .expand((category) => category)
        .toList();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Emoji picker header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emoji',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _isEmojiPickerVisible = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Emoji grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: allEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    final emoji = allEmojis[index];
                    final currentText = _messageController.text;
                    final newText = currentText + emoji;
                    _messageController.text = newText;
                    _messageController.selection = TextSelection.fromPosition(
                      TextPosition(offset: newText.length),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        allEmojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Layout Build ---

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final statCardCount = isTablet ? 3 : 2;
    final classesGridCount = isTablet ? 2 : 1;
    final horizontalPadding = isDesktop ? 20.0 : 10.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: _buildHeader(),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: FutureBuilder<DashboardData>(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Title
                      _buildDashboardTitle(),
                      const SizedBox(height: 30),

                      // Calendar Section (At the Top)
                      _buildCalendarSection(context),
                      const SizedBox(height: 40),

                      // Stats Grid (Responsive)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 5 : statCardCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.2,
                        ),
                        itemCount:
                            11, // FIX: Increased to 11 for all modules + Profile
                        itemBuilder: (context, index) {
                          // Build stats defensively to avoid runtime null errors
                          List<Map<String, String>> stats;
                          try {
                            final dyn = data as dynamic;
                            // Build stats with exact labels requested by the user
                            stats = [
                              {
                                'icon': '📝',
                                'number': _safeNumber(dyn.pendingAssignments),
                                'label': 'Add-Assignment',
                              },
                              {
                                'icon': '✅',
                                'number': _safeNumber(
                                  dyn.totalAttendanceRecords,
                                ),
                                'label': 'Attendance',
                              },
                              {
                                'icon': '👨‍🎓',
                                'number': _safeNumber(dyn.totalStudents),
                                'label': 'Class-students',
                              },
                              {
                                'icon': '🏫',
                                'number': _safeNumber(dyn.totalClasses),
                                'label': 'classes',
                              },
                              {
                                'icon': '💬',
                                'number': _safeNumber(dyn.totalCommunication),
                                'label': 'communication',
                              },
                              {
                                'icon': '📅',
                                'number': _safeNumber(dyn.upcomingExams),
                                'label': 'exam',
                              },
                              {
                                'icon': '📊',
                                'number': _safeNumber(dyn.totalGradesPending),
                                'label': 'grades',
                              },
                              {
                                'icon': '👤',
                                'number': _safeNumber(dyn.profileCompleteness),
                                'label': 'profile',
                              },
                              {
                                'icon': '📈',
                                'number': _safeNumber(dyn.totalResults),
                                'label': 'results',
                              },
                              {
                                'icon': '📖',
                                'number': _safeNumber(dyn.totalStudyMaterials),
                                'label': 'study materials',
                              },
                              {
                                'icon': '⏰',
                                'number': _safeNumber(dyn.totalTimetableSlots),
                                'label': 'time-table',
                              },
                            ];
                          } catch (e) {
                            stats = List.generate(
                              11,
                              (i) => {
                                'icon': 'ℹ️',
                                'number': '0',
                                'label': 'N/A',
                              },
                            );
                          }
                          return _buildStatCard(
                            stats[index]['icon']!,
                            stats[index]['number']!,
                            stats[index]['label']!,
                            onTap: () => _navigateToScreen(stats[index]['label']!),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // Main Content Grid (2 Columns Desktop, 1 Column Mobile)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (isDesktop) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildMainSection(
                                    data,
                                    classesGridCount,
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Expanded(
                                  flex: 1,
                                  child: _buildSidebarSection(),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildMainSection(data, classesGridCount),
                                const SizedBox(height: 30),
                                _buildSidebarSection(),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
          // Chat container is now responsible for the toggle button in the closed state.
          _buildChatContainer(context),
        ],
      ),
    );
  }

  // --- Sub-Section Builders ---

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          // Title - allow to shrink with ellipsis on small widths
          Expanded(
            child: const Text(
              '🏫 School Management System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          // User info - keep to minimal intrinsic size and allow wrapping inside
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Text('👨‍🏫', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Teacher User', // user.name
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Teacher',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const main_login.LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('Logout', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.white24),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Teacher Dashboard',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
        const Text(
          'Academic management and student progress',
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            SizedBox(height: 20),
            Text(
              'Loading dashboard data...',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFff6b6b), Color(0xFFee5a52)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Error: $error',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final daysInMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    ).day;
    final weekdayOfFirstDay =
        firstDayOfMonth.weekday % 7; // Convert to 0=Sun, 1=Mon...

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Attendance Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Spacer(),
                // Month controls: allow the month label to shrink on small widths
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF667eea),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
                        });
                      },
                    ),
                    // Constrain the month label and scale it down when necessary
                    SizedBox(
                      width: 120,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              DateFormat('MMM yyyy').format(_currentDate),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF667eea),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                // adapt columns on very narrow screens so items don't overflow
                final availableWidth = constraints.maxWidth;
                int crossAxisCount = 7;
                if (availableWidth < 420) {
                  crossAxisCount =
                      7; // keep weekdays but reduce spacing via styles
                }

                // Responsive sizing tweaks
                final cellPadding = availableWidth < 420 ? 1.0 : 3.0;
                final headerFontSize = availableWidth < 420 ? 8.0 : 10.0;
                final dayFontSize = availableWidth < 420 ? 10.0 : 12.0;
                final spacing = availableWidth < 420 ? 1.0 : 2.0;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 7 + 42, // Headers + 6 rows of days
                  itemBuilder: (context, index) {
                    if (index < 7) {
                      // Day Headers
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: cellPadding,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667eea),
                            fontSize: headerFontSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final dayIndex = index - 7;
                    final dayOfMonth =
                        dayIndex -
                        (weekdayOfFirstDay == 0 ? 6 : weekdayOfFirstDay - 1) +
                        1; // 0=Mon, 6=Sun in Flutter

                    if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
                      return Container(); // Empty filler
                    }

                    final date = DateTime(
                      _currentDate.year,
                      _currentDate.month,
                      dayOfMonth,
                    );
                    final isToday =
                        date.day == now.day &&
                        date.month == now.month &&
                        date.year == now.year;
                    final hasAttendance =
                        date.weekday != DateTime.sunday &&
                        date.weekday != DateTime.saturday;

                    Color bgColor = Colors.transparent;
                    Color textColor = const Color(0xFF333333);
                    List<BoxShadow> shadows = [];

                    if (isToday) {
                      bgColor = const Color(0xFF51cf66);
                      textColor = Colors.white;
                    } else if (hasAttendance && date.isBefore(now)) {
                      bgColor = const Color(0xFF667eea);
                      textColor = Colors.white;
                    }

                    return InkWell(
                      onTap: hasAttendance
                          ? () => _showAttendanceModal(date)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: shadows,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            dayOfMonth.toString(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: dayFontSize,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSection(DashboardData data, int classesGridCount) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                '📚 My Classes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Divider(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: classesGridCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemCount: data.classes.length,
              itemBuilder: (context, index) =>
                  _buildClassCard(data.classes[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSection() {
    return Column(
      children: [
        // Performance & Charts (Moved to Top)
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📈 Attendance Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Time period toggle buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimePeriodButton('Weekly', 'attendance'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Monthly', 'attendance'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Quarterly', 'attendance'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Yearly', 'attendance'),
                    ],
                  ),
                ),
                const Divider(height: 20),
                // Average Stats - using dynamic data based on selected period
                Builder(
                  builder: (context) {
                    final attendanceData = _getAttendanceData(
                      _selectedAttendancePeriod,
                    );
                    return Column(
                      children: [
                        _buildPerformanceStat(
                          attendanceData['attendance']!,
                          'Average Attendance',
                          const Color(0xFF667eea),
                        ),
                        const SizedBox(height: 15),
                        _buildPerformanceStat(
                          attendanceData['grade']!,
                          'Average Grade',
                          const Color(0xFF51cf66),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 30),

                // (Attendance chart removed as requested)

                // Progress Overview Chart (Bar Chart - Fixed Visibility)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📈 Class Progress Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Time period toggle buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimePeriodButton('Weekly', 'progress'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Monthly', 'progress'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Quarterly', 'progress'),
                      const SizedBox(width: 8),
                      _buildTimePeriodButton('Yearly', 'progress'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(15),
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf8f9fa),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF667eea),
                      width: 2,
                    ),
                    boxShadow: [
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: BarChartPainter(
                            _getProgressChartData(_selectedProgressPeriod),
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Subject-wise Performance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 224, 19, 19),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Upcoming Section
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📅 Upcoming',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
                const Divider(height: 20),
                _buildUpcomingItem(
                  'Mathematics Test',
                  'Class 10A • Tomorrow • 2 hours',
                ),
                _buildUpcomingItem(
                  'Physics Assignment Due',
                  'Class 11B • Feb 1st • Lab Report',
                ),
                _buildUpcomingItem(
                  'Parent Meeting',
                  'Class 10A • Feb 5th • 3:00 PM',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Quick Actions (Moved to Bottom)
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.5,
                  children: [
                    _buildActionButton(
                      '📝 Create Assignment',
                      Icons.assignment_outlined,
                    ),
                    _buildActionButton(
                      '📋 Schedule Exam',
                      Icons.event_note_outlined,
                    ),
                    _buildActionButton(
                      '📈 View Grades',
                      Icons.leaderboard_outlined,
                    ),
                    _buildActionButton(
                      '📊 View Results',
                      Icons.bar_chart_outlined,
                    ),
                    _buildActionButton(
                      '📅 My Timetable',
                      Icons.calendar_today_outlined,
                    ),
                    _buildActionButton('👤 My Profile', Icons.person_outline),
                    _buildActionButton(
                      '💬 Communication',
                      Icons.message_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {
        // Default navigation based on label
        if (label.contains('Assignment')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentDashboardScreen()));
        } else if (label.contains('Exam')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherDashboard()));
        } else if (label.contains('Grades')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GradesDashboard()));
        } else if (label.contains('Results')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EnterResultsScreen()));
        } else if (label.contains('Timetable')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
        } else if (label.contains('Profile')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherProfilePage()));
        } else if (label.contains('Communication')) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherCommunicationScreen(
            onToggleTheme: () {},
            initialThemeMode: ThemeMode.light,
          )));
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: const Color(0xFF667eea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingItem(String title, String details) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF667eea), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          Text(
            details,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContainer(BuildContext context) {
    // Define sizes for animation
    const double chatClosedSize = 64.0;
    const double chatOpenWidth = 400.0;
    const double chatOpenHeight = 600.0;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final bool fullScreen = isMobile && _isChatOpen;

    return Positioned(
      bottom: fullScreen ? 0 : 20,
      right: fullScreen ? 0 : 20,
      top: fullScreen ? 0 : null,
      left: fullScreen ? 0 : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: fullScreen
            ? MediaQuery.of(context).size.width
            : (_isChatOpen ? chatOpenWidth : chatClosedSize),
        height: fullScreen
            ? MediaQuery.of(context).size.height
            : (_isChatOpen ? chatOpenHeight : chatClosedSize),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            fullScreen ? 0 : (_isChatOpen ? 15 : 32),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: _isChatOpen ? 30 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            fullScreen ? 0 : (_isChatOpen ? 15 : 32),
          ),
          child: Stack(
            children: [
              // Chat Content (Visible when open)
              if (_isChatOpen)
                Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(15).copyWith(right: 10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '💬 Messages',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    // Tabs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _chatMode = 'individual');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _chatMode == 'individual'
                                          ? const Color(0xFF667eea)
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Individual',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _chatMode == 'individual'
                                        ? const Color(0xFF667eea)
                                        : const Color(0xFF999999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _chatMode = 'group');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _chatMode == 'group'
                                          ? const Color(0xFF667eea)
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Groups',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _chatMode == 'group'
                                        ? const Color(0xFF667eea)
                                        : const Color(0xFF999999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _chatSearchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: _chatMode == 'individual'
                              ? 'Search teachers...'
                              : 'Search groups...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    // Main Content: Chat List or Message View
                    if (_selectedChatId == null)
                      Expanded(child: _buildChatList())
                    else
                      Expanded(
                        child: Column(
                          children: [
                            // Chat header (Inside conversation)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _getSelectedChatName(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Messages
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(15),
                                itemCount: _getSelectedChatMessages().length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  final messages = _getSelectedChatMessages();
                                  return _buildChatMessage(
                                    messages[messages.length - 1 - index],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Message input - only show when a chat is selected
                    if (_selectedChatId != null)
                      _buildMessageInputWithControls(),
                  ],
                ),
              // Collapsed Button (Visible when closed)
              if (!_isChatOpen)
                InkWell(
                  onTap: _toggleChat,
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: chatClosedSize,
                    height: chatClosedSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFF667eea),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('💬', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final filteredChats = _getFilteredChats();

    if (filteredChats.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty
              ? 'No ${_chatMode == 'individual' ? 'teachers' : 'groups'} available'
              : 'No results found',
          style: const TextStyle(color: Color(0xFF999999)),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        if (_chatMode == 'individual') {
          final teacher = filteredChats[index] as Teacher;

          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  teacher.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              teacher.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: Text(
              teacher.subject,
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: teacher.isOnline
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
            onTap: () {
              setState(() => _selectedChatId = teacher.id);
            },
          );
        } else {
          final group = filteredChats[index] as GroupChat;

          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(group.avatar, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: Text(
              group.description,
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
            ),
            trailing: group.unreadCount > 0
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        group.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
            onTap: () {
              setState(() => _selectedChatId = group.id);
            },
          );
        }
      },
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isSent = message.sender == 'user';
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFF667eea) : const Color(0xFFf1f3f4),
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomLeft: isSent
                ? const Radius.circular(15)
                : const Radius.circular(5),
            bottomRight: isSent
                ? const Radius.circular(5)
                : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isSent ? Colors.white : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 10,
                color: isSent ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendChatMessage(String message) {
    if (message.isEmpty || _selectedChatId == null) return;
    setState(() {
      final now = DateTime.now();
      final timeString = DateFormat('hh:mm a').format(now);

      if (!_chatMessages.containsKey(_selectedChatId)) {
        _chatMessages[_selectedChatId!] = [];
      }

      _chatMessages[_selectedChatId!]!.add(
        ChatMessage(
          text: message,
          sender: 'user',
          time: timeString,
          avatarEmoji: '👤',
        ),
      );
      _messageController.clear();

      // Simulate teacher response
      Future.delayed(const Duration(seconds: 1), () {
        final responses = [
          "That sounds great! Let's discuss further.",
          "I appreciate your input. Thank you!",
          "Got it, I'll work on that.",
          "This is very helpful information.",
          "Let's schedule a time to talk about this.",
        ];
        final randomResponse = responses[Random().nextInt(responses.length)];

        if (_chatMode == 'individual') {
          final teacher = _teachers.firstWhere(
            (t) => t.id == _selectedChatId,
            orElse: () => _teachers.first,
          );
          _chatMessages[_selectedChatId!]!.add(
            ChatMessage(
              text: randomResponse,
              sender: 'teacher',
              time: DateFormat('hh:mm a').format(DateTime.now()),
              senderName: teacher.name,
              avatarEmoji: teacher.avatar,
            ),
          );
        } else {
          _chatMessages[_selectedChatId!]!.add(
            ChatMessage(
              text: randomResponse,
              sender: 'teacher',
              time: DateFormat('hh:mm a').format(DateTime.now()),
              senderName: 'Mr. David Chen',
              avatarEmoji: '👨‍🏫',
            ),
          );
        }
        setState(() {}); // Rebuild to show response
      });
    });
  }
}

// --- CUSTOM PAINTERS FOR CHARTS ---

// Removed LineChartPainter as it was unused and marked for removal previously.

class BarChartPainter extends CustomPainter {
  final List<SubjectData> data;
  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const padding = 20.0;
    final chartWidth = width - 2 * padding;
    final chartHeight = height - 2 * padding;

    // Use a 0-10 scale for display; source data is 0-100 so convert by /10
    const maxScale = 10.0;
    final yScale = chartHeight / maxScale;
    final barGroupWidth = chartWidth / data.length;
    final barWidth = barGroupWidth * 0.3;
    // A list of distinct colors to use for different subject bars
    final barColors = [
      const Color(0xFF1E88E5), // blue
      const Color(0xFF51cf66), // green
      const Color(0xFFff6b6b), // red
      const Color(0xFF764ba2), // purple
      const Color(0xFF00BCD4), // cyan
      const Color(0xFF3949AB), // indigo
    ];

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final subjectData = data[i];
      // Center the bar inside its group
      final startX =
          padding + i * barGroupWidth + (barGroupWidth - barWidth) / 2;
      // Source data 0-100 -> convert to 0-10 scale
      final avgScaleValue = subjectData.average / 10.0;

      // Draw Average Bar
      final avgHeight = avgScaleValue * yScale;
      final avgY = height - padding - avgHeight;
      // Choose color for this subject
      final color = barColors[i % barColors.length];
      final avgPaint = Paint()..color = color;

      final avgRect = Rect.fromLTWH(startX, avgY, barWidth, avgHeight);
      canvas.drawRect(avgRect, avgPaint);

      // Draw average label above average bar (show actual average value 0-100)
      final avgLabel = subjectData.average.toString();
      // Always use black color for average numbers
      final textStyle = const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      );
      final tp = TextPainter(
        text: TextSpan(text: avgLabel, style: textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      );
      // Limit the avg label width to the bar width so it's centered over the bar
      tp.layout(minWidth: 0, maxWidth: barWidth);
      final labelX = avgRect.left + (avgRect.width - tp.width) / 2;
      final labelY = (avgRect.top - tp.height - 4).clamp(4.0, double.infinity);

      // Draw white background behind text for better visibility
      final bgRect = Rect.fromLTWH(
        labelX - 2,
        labelY - 1,
        tp.width + 4,
        tp.height + 2,
      );
      final bgPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(3)),
        bgPaint,
      );

      // Draw the black text
      tp.paint(canvas, Offset(labelX, labelY));

      // (Target bars removed as requested)
    }

    // Draw subject labels below each bar group
    final labelStyle = TextStyle(color: const Color(0xFF333333), fontSize: 12);
    for (int i = 0; i < data.length; i++) {
      final subject = data[i].subject;
      // center under the bar group and allow the label to take up the whole group
      final groupLeft = padding + i * barGroupWidth;
      final tp = TextPainter(
        text: TextSpan(text: subject, style: labelStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 2,
      );
      // Give the label the full group width so it stays centered under the bar
      tp.layout(minWidth: barGroupWidth, maxWidth: barGroupWidth);
      final labelX = groupLeft + (barGroupWidth - tp.width) / 2;
      final labelY = height - padding + 6; // slightly below the chart area
      tp.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- STAT DETAIL SCREEN DEFINITION (To resolve missing file error) ---
class StatDetailScreen extends StatelessWidget {
  final String title;
  final String value;

  const StatDetailScreen({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Details'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Value: $value',
              style: const TextStyle(fontSize: 24, color: Color(0xFF667eea)),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'This screen would typically show detailed analytics, historical trends, and management tools for this specific metric.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF764ba2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
