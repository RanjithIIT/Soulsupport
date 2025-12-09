import 'dart:ui';

import 'package:flutter/material.dart';
import 'main.dart' as app;
import 'dashboard.dart';
import 'admissions.dart';
import 'services/api_service.dart';

class StudentAcademics {
  final String overallScore;
  final String subjects;
  final String performance;
  final String lastExam;

  const StudentAcademics({
    required this.overallScore,
    required this.subjects,
    required this.performance,
    required this.lastExam,
  });
}

class StudentExtracurricular {
  final String activities;
  final String leadership;
  final String achievements;
  final String participation;

  const StudentExtracurricular({
    required this.activities,
    required this.leadership,
    required this.achievements,
    required this.participation,
  });
}

class StudentFees {
  final String total;
  final String paid;
  final String due;
  final String status;

  const StudentFees({
    required this.total,
    required this.paid,
    required this.due,
    required this.status,
  });
}

class Student {
  final int id;
  final String name;
  final String studentClass;
  final String section;
  final String bloodGroup;
  final String initials;
  final String parentsName;
  final String contact;
  final String email;
  final String address;
  final String admissionDate;
  final String rollNumber;
  final double attendance;
  final String busRoute;
  final String emergencyContact;
  final String medicalInfo;
  final String status;
  final StudentAcademics academics;
  final StudentExtracurricular extracurricular;
  final StudentFees fees;

  Student({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.section,
    required this.bloodGroup,
    required this.initials,
    required this.parentsName,
    required this.contact,
    required this.email,
    required this.address,
    required this.admissionDate,
    required this.rollNumber,
    required this.attendance,
    required this.busRoute,
    required this.emergencyContact,
    required this.medicalInfo,
    required this.status,
    required this.academics,
    required this.extracurricular,
    required this.fees,
  });

  // Factory constructor to parse from JSON (database response)
  factory Student.fromJson(Map<String, dynamic> json) {
    final firstName = json['user']?['first_name'] as String? ?? '';
    final lastName = json['user']?['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return Student(
      id: json['id'] as int? ?? 0,
      name: fullName.isNotEmpty ? fullName : 'Unknown Student',
      studentClass: json['class_name'] as String? ?? '',
      section: json['section'] as String? ?? '',
      bloodGroup: json['blood_group'] as String? ?? '',
      initials: _getInitials(firstName, lastName),
      parentsName: json['parent_name'] as String? ?? '',
      contact: json['parent_phone'] as String? ?? '',
      email:
          json['email'] as String? ?? json['user']?['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      admissionDate: json['admission_date'] as String? ?? '',
      rollNumber: json['student_id'] as String? ?? '',
      attendance: 0.0,
      busRoute: '',
      emergencyContact: json['emergency_contact'] as String? ?? '',
      medicalInfo: json['medical_info'] as String? ?? '',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '0%',
        subjects: '',
        performance: '',
        lastExam: '',
      ),
      extracurricular: const StudentExtracurricular(
        activities: '',
        leadership: '',
        achievements: '',
        participation: '',
      ),
      fees: const StudentFees(total: '₹0', paid: '₹0', due: '₹0', status: ''),
    );
  }

  static String _getInitials(String firstName, String lastName) {
    return (firstName.isNotEmpty ? firstName[0] : '') +
        (lastName.isNotEmpty ? lastName[0] : '');
  }
}

class StudentsManagementPage extends StatefulWidget {
  const StudentsManagementPage({super.key});

  @override
  State<StudentsManagementPage> createState() => _StudentsManagementPageState();
}

class _StudentsManagementPageState extends State<StudentsManagementPage> {
  late List<Student> _students;
  late List<Student> _visibleStudents;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedClass;
  @override
  void initState() {
    super.initState();
    _students = [];
    _visibleStudents = [];
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final data = await ApiService.fetchStudents();
      final students = data
          .map((item) => Student.fromJson(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _students = students;
        _visibleStudents = List<Student>.from(_students);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching students: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalStudents => _students.length;
  int get _activeStudents =>
      _students.where((s) => s.status == 'Active').length;
  double get _avgAttendance =>
      _students.fold(0.0, (sum, s) => sum + s.attendance) / _students.length;
  int get _totalClasses => _students.map((s) => s.studentClass).toSet().length;
  double get _academicsScore {
    final scores = _students.map((s) {
      final scoreStr = s.academics.overallScore.replaceAll('%', '');
      return double.tryParse(scoreStr) ?? 85.6;
    });
    return scores.fold(0.0, (sum, score) => sum + score) / _students.length;
  }

  int get _extracurricularCount {
    return _students.fold(0, (sum, s) {
      final count = s.extracurricular.activities.split(',').length;
      return sum + count;
    });
  }

  String get _feesPaid {
    final total = _students.fold(0, (sum, s) {
      final paidStr = s.fees.paid.replaceAll('₹', '').replaceAll(',', '');
      return sum + (int.tryParse(paidStr) ?? 42000);
    });
    return '₹${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _filterStudents() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      final selectedClass = _selectedClass;

      _visibleStudents = _students.where((student) {
        final matchesSearch =
            query.isEmpty ||
            student.name.toLowerCase().contains(query) ||
            student.studentClass.toLowerCase().contains(query) ||
            student.rollNumber.toLowerCase().contains(query);
        final matchesClass =
            selectedClass == null ||
            selectedClass.isEmpty ||
            student.studentClass.contains(selectedClass);
        return matchesSearch && matchesClass;
      }).toList();
    });
  }

  void _viewStudent(Student student) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${student.name} - Student Profile',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFAAAAAA)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 600;
                      if (isCompact) {
                        return Column(
                          children: [
                            _buildProfileImage(student),
                            const SizedBox(height: 20),
                            _buildProfileDetails(student),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileImage(student),
                          const SizedBox(width: 30),
                          Expanded(child: _buildProfileDetails(student)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _editStudent(student);
                        },
                        child: const Text('Edit Profile'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C757D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(Student student) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
          child: Center(
            child: Text(
              student.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          student.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${student.studentClass} • Section ${student.section}',
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        const SizedBox(height: 5),
        Text(
          'Roll: ${student.rollNumber}',
          style: const TextStyle(
            color: Color(0xFF667EEA),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          student.status,
          style: const TextStyle(
            color: Color(0xFF667EEA),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(Student student) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _DetailCard(
          title: 'Academic Information',
          items: [
            'Class: ${student.studentClass}',
            'Section: ${student.section}',
            'Roll Number: ${student.rollNumber}',
            'Admission Date: ${student.admissionDate}',
          ],
        ),
        _DetailCard(
          title: 'Contact Information',
          items: [
            'Email: ${student.email}',
            'Phone: ${student.contact}',
            'Address: ${student.address}',
          ],
        ),
        _DetailCard(
          title: 'Parent Information',
          items: [
            'Parents: ${student.parentsName}',
            'Emergency Contact: ${student.emergencyContact}',
          ],
        ),
        _DetailCard(
          title: 'Additional Details',
          items: [
            'Blood Group: ${student.bloodGroup}',
            'Bus Route: ${student.busRoute}',
            'Attendance: ${student.attendance}%',
          ],
        ),
        _DetailCard(title: 'Medical Information', items: [student.medicalInfo]),
        _DetailCard(
          title: 'Academics',
          items: [
            'Overall Score: ${student.academics.overallScore}',
            'Subjects: ${student.academics.subjects}',
            'Performance: ${student.academics.performance}',
            'Last Exam: ${student.academics.lastExam}',
          ],
        ),
        _DetailCard(
          title: 'Extracurricular Activities',
          items: [
            'Activities: ${student.extracurricular.activities}',
            'Leadership: ${student.extracurricular.leadership}',
            'Achievements: ${student.extracurricular.achievements}',
            'Participation: ${student.extracurricular.participation}',
          ],
        ),
        _DetailCard(
          title: 'Fees Information',
          items: [
            'Total Fees: ${student.fees.total}',
            'Paid Amount: ${student.fees.paid}',
            'Due Amount: ${student.fees.due}',
            'Payment Status: ${student.fees.status}',
          ],
        ),
      ],
    );
  }

  void _editStudent(Student student) {
    Navigator.pushNamed(context, '/edit-student', arguments: student.id);
  }

  void _deleteStudent(Student student) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Delete ${student.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the confirmation dialog first
                Navigator.of(context).pop();

                // Use root navigator so the loading dialog is guaranteed to close
                final rootContext = app.SchoolManagementApp.navigatorKey.currentContext ?? context;

                showDialog(
                  context: rootContext,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                Future<void> closeLoading() async {
                  if (Navigator.of(rootContext, rootNavigator: true).canPop()) {
                    Navigator.of(rootContext, rootNavigator: true).pop();
                  }
                }

                try {
                  await ApiService.deleteStudent(student.id);
                  await closeLoading();

                  if (!mounted) return;
                  setState(() {
                    _students.removeWhere((s) => s.id == student.id);
                    _visibleStudents.removeWhere((s) => s.id == student.id);
                  });

                  // Attempt to close any profile dialog underneath
                  if (Navigator.of(rootContext, rootNavigator: true).canPop()) {
                    Navigator.of(rootContext, rootNavigator: true).maybePop();
                  }

                  final messengerContext = app.SchoolManagementApp.navigatorKey.currentContext;
                  if (messengerContext != null) {
                    ScaffoldMessenger.of(messengerContext).showSnackBar(
                      const SnackBar(content: Text('Student deleted successfully!')),
                    );
                  }
                } catch (e) {
                  await closeLoading();
                  final messengerContext = app.SchoolManagementApp.navigatorKey.currentContext;
                  if (messengerContext != null) {
                    ScaffoldMessenger.of(messengerContext).showSnackBar(
                      SnackBar(content: Text('Error deleting student: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addStudent() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdmissionsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 900;

            if (isCompact) {
              return Column(
                children: [Expanded(child: _buildMainContent(isMobile: true))],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: _buildSidebar()),
                Expanded(child: _buildMainContent(isMobile: false)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    const navItems = [
      {'icon': '📊', 'label': 'Dashboard'},
      {'icon': '👨‍🏫', 'label': 'Teachers'},
      {'icon': '👥', 'label': 'Students'},
      {'icon': '🚌', 'label': 'Buses'},
      {'icon': '🎯', 'label': 'Activities'},
      {'icon': '📅', 'label': 'Events'},
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      drawRightBorder: true,
      borderRadius: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: const [
                Text(
                  '🏫 SMS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'School Management System',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          for (final item in navItems)
            _NavTile(
              icon: item['icon']!,
              label: item['label']!,
              isActive: item['label'] == 'Students',
              onTap: () {
                final routeMap = {
                  'Dashboard': '/dashboard',
                  'Teachers': '/teachers',
                  'Students': '/students',
                  'Buses': '/buses',
                  'Activities': '/activities',
                  'Events': '/events',
                };
                final route = routeMap[item['label']];
                if (route != null) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent({required bool isMobile}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            margin: const EdgeInsets.only(bottom: 30),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Students Management',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  _buildUserInfo(),
                  const SizedBox(width: 20),
                  _buildBackButton(),
                ],
              ],
            ),
          ),
          if (isMobile)
            GlassContainer(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  _buildUserAvatar(),
                  const SizedBox(width: 15),
                  Expanded(child: _buildUserLabels()),
                  const Icon(Icons.arrow_back_ios_new, size: 16),
                ],
              ),
            ),
          GlassContainer(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Text('👥', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 15),
                    Text(
                      'Students Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Manage all students, their profiles, academic records, and attendance',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 3.4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _StatCard(
                      label: 'Total Students',
                      value: '$_totalStudents',
                    ),
                    _StatCard(
                      label: 'Active Students',
                      value: '$_activeStudents',
                    ),
                    _StatCard(
                      label: 'Average Attendance',
                      value: '${_avgAttendance.toStringAsFixed(1)}%',
                    ),
                    _StatCard(label: 'Total Classes', value: '$_totalClasses'),
                    _StatCard(
                      label: 'Academics',
                      value: '${_academicsScore.toStringAsFixed(1)}%',
                    ),
                    _StatCard(
                      label: 'Extracurricular Activities',
                      value: '$_extracurricularCount',
                    ),
                    _StatCard(label: 'Fees Collection', value: _feesPaid),
                  ],
                );
              }
              final cardWidth = 200.0;
              final spacing = 20.0;
              final availableWidth = constraints.maxWidth;
              final crossAxisCount =
                  ((availableWidth + spacing) / (cardWidth + spacing))
                      .floor()
                      .clamp(1, 7);
              final childAspectRatio = 1.35;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _StatCard(label: 'Total Students', value: '$_totalStudents'),
                  _StatCard(
                    label: 'Active Students',
                    value: '$_activeStudents',
                  ),
                  _StatCard(
                    label: 'Average Attendance',
                    value: '${_avgAttendance.toStringAsFixed(1)}%',
                  ),
                  _StatCard(label: 'Total Classes', value: '$_totalClasses'),
                  _StatCard(
                    label: 'Academics',
                    value: '${_academicsScore.toStringAsFixed(1)}%',
                  ),
                  _StatCard(
                    label: 'Extracurricular Activities',
                    value: '$_extracurricularCount',
                  ),
                  _StatCard(label: 'Fees Collection', value: _feesPaid),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 30),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE1E5E9),
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _filterStudents(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Search students by name, class, or ID...',
                              prefixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE1E5E9),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedClass,
                          hint: const Text('All Classes'),
                          isExpanded: false,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Classes'),
                            ),
                            DropdownMenuItem(
                              value: '9',
                              child: Text('Grade 9'),
                            ),
                            DropdownMenuItem(
                              value: '10',
                              child: Text('Grade 10'),
                            ),
                            DropdownMenuItem(
                              value: '11',
                              child: Text('Grade 11'),
                            ),
                            DropdownMenuItem(
                              value: '12',
                              child: Text('Grade 12'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                            _filterStudents();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 15 : 0),
                InkWell(
                  onTap: _addStudent,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: isMobile ? double.infinity : null,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF51CF66), Color(0xFF40C057)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF51CF66,
                          ).withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add New Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = 350.0;
              final spacing = 20.0;
              final availableWidth = constraints.maxWidth;
              final crossAxisCount =
                  ((availableWidth + spacing) / (cardWidth + spacing))
                      .floor()
                      .clamp(1, 4);
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _visibleStudents.map((student) {
                  return SizedBox(
                    width:
                        (availableWidth - (spacing * (crossAxisCount - 1))) /
                        crossAxisCount,
                    child: _buildStudentCard(student),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return _StudentCardWithHover(
      student: student,
      onView: () => _viewStudent(student),
      onEdit: () => _editStudent(student),
      onDelete: () => _deleteStudent(student),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 15),
        _buildUserLabels(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: const Center(
        child: Text(
          'M',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildUserLabels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Management User', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          'School Manager',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C757D), Color(0xFF495057)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF495057).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.arrow_back, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Back to Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCardWithHover extends StatefulWidget {
  final Student student;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentCardWithHover({
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_StudentCardWithHover> createState() => _StudentCardWithHoverState();
}

class _StudentCardWithHoverState extends State<_StudentCardWithHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.student.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.student.studentClass} • Section ${widget.student.section} • Roll: ${widget.student.rollNumber}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Attendance',
                          value: '${widget.student.attendance}%',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Blood Group',
                          value: widget.student.bloodGroup,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Parents',
                          value: widget.student.parentsName,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Contact',
                          value: widget.student.contact,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _GradientButton(
                      label: 'View',
                      colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onTap: widget.onView,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GradientButton(
                      label: 'Edit',
                      colors: const [Color(0xFFFFD93D), Color(0xFFFCC419)],
                      textColor: const Color(0xFF333333),
                      onTap: widget.onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GradientButton(
                      label: 'Delete',
                      colors: const [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                      onTap: widget.onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool drawRightBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.borderRadius = 15,
    this.drawRightBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = drawRightBorder
        ? BorderRadius.zero
        : BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: radius,
              border: Border(
                right: drawRightBorder
                    ? BorderSide(color: Colors.white.withValues(alpha: 0.2))
                    : BorderSide.none,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: isActive ? null : Colors.white.withValues(alpha: 0.7),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF333333),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _StatCard({
    required this.label,
    required this.value,
  }) : accentColor = const Color(0xFF667EEA);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Container(
        // Removed accent border for cleaner stat cards
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _DetailItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF666666),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color textColor;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.colors,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(colors: colors),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _DetailCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                item,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
