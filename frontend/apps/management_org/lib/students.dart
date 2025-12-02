import 'dart:ui';

import 'package:flutter/material.dart';
import 'dashboard.dart';

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

  const Student({
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
}

class StudentsManagementPage extends StatefulWidget {
  const StudentsManagementPage({super.key});

  @override
  State<StudentsManagementPage> createState() => _StudentsManagementPageState();
}

class _StudentsManagementPageState extends State<StudentsManagementPage> {
  final List<Student> _students = [
    Student(
      id: 1,
      name: 'Alice Brown',
      studentClass: '10th',
      section: 'A',
      bloodGroup: 'O+',
      initials: 'AB',
      parentsName: 'John & Mary Brown',
      contact: '+1-555-0201',
      email: 'alice.brown@student.school.com',
      address: '123 Student Street, Education City',
      admissionDate: '2022-06-15',
      rollNumber: 'STU001',
      attendance: 95,
      busRoute: 'Route A',
      emergencyContact: '+1-555-0202',
      medicalInfo: 'No known allergies',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '92.5%',
        subjects: 'Math, Science, English, History, Geography',
        performance: 'Excellent',
        lastExam: 'Mid-Term',
      ),
      extracurricular: const StudentExtracurricular(
        activities: 'NCC, Sports, Music, Debate',
        leadership: 'Class Monitor',
        achievements: 'Sports Champion, Music Competition Winner',
        participation: 'Very Active',
      ),
      fees: const StudentFees(
        total: '₹45,000',
        paid: '₹45,000',
        due: '₹0',
        status: 'Fully Paid',
      ),
    ),
    Student(
      id: 2,
      name: 'Charlie Wilson',
      studentClass: '11th',
      section: 'B',
      bloodGroup: 'A+',
      initials: 'CW',
      parentsName: 'Robert & Sarah Wilson',
      contact: '+1-555-0203',
      email: 'charlie.wilson@student.school.com',
      address: '456 Learning Avenue, Knowledge District',
      admissionDate: '2021-08-20',
      rollNumber: 'STU002',
      attendance: 92,
      busRoute: 'Route B',
      emergencyContact: '+1-555-0204',
      medicalInfo: 'Asthma - carries inhaler',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '88.3%',
        subjects: 'Physics, Chemistry, Biology, English, Math',
        performance: 'Good',
        lastExam: 'Unit Test',
      ),
      extracurricular: const StudentExtracurricular(
        activities: 'NSS, Science Club, Photography',
        leadership: 'Science Club Secretary',
        achievements: 'Science Fair Winner, Photography Award',
        participation: 'Active',
      ),
      fees: const StudentFees(
        total: '₹48,000',
        paid: '₹42,000',
        due: '₹6,000',
        status: 'Partially Paid',
      ),
    ),
    Student(
      id: 3,
      name: 'Diana Davis',
      studentClass: '12th',
      section: 'C',
      bloodGroup: 'B+',
      initials: 'DD',
      parentsName: 'Michael & Lisa Davis',
      contact: '+1-555-0205',
      email: 'diana.davis@student.school.com',
      address: '789 Education Road, Wisdom Town',
      admissionDate: '2020-09-01',
      rollNumber: 'STU003',
      attendance: 98,
      busRoute: 'Route C',
      emergencyContact: '+1-555-0206',
      medicalInfo: 'No medical conditions',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '95.2%',
        subjects: 'Math, Physics, Chemistry, English, Computer Science',
        performance: 'Outstanding',
        lastExam: 'Final Term',
      ),
      extracurricular: const StudentExtracurricular(
        activities: 'NCC, Coding Club, Dance, Debate',
        leadership: 'School Captain',
        achievements: 'National Coding Champion, Dance Competition Winner',
        participation: 'Very Active',
      ),
      fees: const StudentFees(
        total: '₹50,000',
        paid: '₹50,000',
        due: '₹0',
        status: 'Fully Paid',
      ),
    ),
    Student(
      id: 4,
      name: 'Ethan Miller',
      studentClass: '9th',
      section: 'A',
      bloodGroup: 'AB+',
      initials: 'EM',
      parentsName: 'James & Anna Miller',
      contact: '+1-555-0207',
      email: 'ethan.miller@student.school.com',
      address: '321 Knowledge Boulevard, Learning City',
      admissionDate: '2023-06-10',
      rollNumber: 'STU004',
      attendance: 89,
      busRoute: 'Route A',
      emergencyContact: '+1-555-0208',
      medicalInfo: 'Diabetes - requires monitoring',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '82.1%',
        subjects: 'Math, Science, English, Social Studies, Hindi',
        performance: 'Average',
        lastExam: 'Quarterly',
      ),
      extracurricular: const StudentExtracurricular(
        activities: 'Sports, Art Club, Music',
        leadership: 'Sports Team Member',
        achievements: 'Art Competition Participant',
        participation: 'Moderate',
      ),
      fees: const StudentFees(
        total: '₹42,000',
        paid: '₹38,000',
        due: '₹4,000',
        status: 'Partially Paid',
      ),
    ),
    Student(
      id: 5,
      name: 'Fiona Taylor',
      studentClass: '10th',
      section: 'B',
      bloodGroup: 'O-',
      initials: 'FT',
      parentsName: 'William & Emma Taylor',
      contact: '+1-555-0209',
      email: 'fiona.taylor@student.school.com',
      address: '654 Student Way, Education District',
      admissionDate: '2022-08-25',
      rollNumber: 'STU005',
      attendance: 96,
      busRoute: 'Route B',
      emergencyContact: '+1-555-0210',
      medicalInfo: 'No known conditions',
      status: 'Active',
      academics: const StudentAcademics(
        overallScore: '90.7%',
        subjects: 'Math, Science, English, History, Geography',
        performance: 'Very Good',
        lastExam: 'Mid-Term',
      ),
      extracurricular: const StudentExtracurricular(
        activities: 'NSS, Literature Club, Drama',
        leadership: 'Literature Club President',
        achievements: 'Drama Competition Winner, Essay Writing Award',
        participation: 'Active',
      ),
      fees: const StudentFees(
        total: '₹45,000',
        paid: '₹40,000',
        due: '₹5,000',
        status: 'Partially Paid',
      ),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String? _selectedClass;
  late List<Student> _visibleStudents;

  @override
  void initState() {
    super.initState();
    _visibleStudents = List<Student>.from(_students);
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
  int get _totalClasses =>
      _students.map((s) => s.studentClass).toSet().length;
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
    return '₹${total.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  void _filterStudents() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      final selectedClass = _selectedClass;

      _visibleStudents = _students.where((student) {
        final matchesSearch = query.isEmpty ||
            student.name.toLowerCase().contains(query) ||
            student.studentClass.toLowerCase().contains(query) ||
            student.rollNumber.toLowerCase().contains(query);
        final matchesClass = selectedClass == null ||
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
        _DetailCard(
          title: 'Medical Information',
          items: [student.medicalInfo],
        ),
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
              onPressed: () {
                setState(() {
                  _students.removeWhere((s) => s.id == student.id);
                });
                _filterStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted successfully!')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addStudent() {
    Navigator.pushNamed(context, '/add-student');
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
                children: [
                  Expanded(child: _buildMainContent(isMobile: true)),
                ],
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
                    _StatCard(
                      label: 'Total Classes',
                      value: '$_totalClasses',
                    ),
                    _StatCard(
                      label: 'Academics',
                      value: '${_academicsScore.toStringAsFixed(1)}%',
                    ),
                    _StatCard(
                      label: 'Extracurricular Activities',
                      value: '$_extracurricularCount',
                    ),
                    _StatCard(
                      label: 'Fees Collection',
                      value: _feesPaid,
                    ),
                  ],
                );
              }
              final cardWidth = 200.0;
              final spacing = 20.0;
              final availableWidth = constraints.maxWidth;
              final crossAxisCount = ((availableWidth + spacing) / (cardWidth + spacing)).floor().clamp(1, 7);
              final childAspectRatio = 1.35;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
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
                  _StatCard(
                    label: 'Total Classes',
                    value: '$_totalClasses',
                  ),
                  _StatCard(
                    label: 'Academics',
                    value: '${_academicsScore.toStringAsFixed(1)}%',
                  ),
                  _StatCard(
                    label: 'Extracurricular Activities',
                    value: '$_extracurricularCount',
                  ),
                  _StatCard(
                    label: 'Fees Collection',
                    value: _feesPaid,
                  ),
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
                            DropdownMenuItem(value: null, child: Text('All Classes')),
                            DropdownMenuItem(value: '9', child: Text('Grade 9')),
                            DropdownMenuItem(value: '10', child: Text('Grade 10')),
                            DropdownMenuItem(value: '11', child: Text('Grade 11')),
                            DropdownMenuItem(value: '12', child: Text('Grade 12')),
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
                SizedBox(
                  width: isMobile ? 0 : 20,
                  height: isMobile ? 15 : 0,
                ),
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
                          color: const Color(0xFF51CF66).withValues(alpha: 0.25),
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
              final crossAxisCount = ((availableWidth + spacing) / (cardWidth + spacing)).floor().clamp(1, 4);
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _visibleStudents.map((student) {
                  return SizedBox(
                    width: (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount,
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
        Text(
          'Management User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'School Manager',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
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
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0),
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
  final Color? accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: accentColor != null
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(color: accentColor!, width: 5),
                ),
              )
            : null,
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

  const _DetailCard({
    required this.title,
    required this.items,
  });

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