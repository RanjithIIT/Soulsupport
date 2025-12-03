import 'dart:ui';

import 'package:flutter/material.dart';
import 'main.dart' as app;
import 'dashboard.dart';

class Teacher {
  final int id;
  final String name;
  final String designation;
  final String phone;
  final String email;
  final String address;
  final String initials;
  final String? classTeacher;
  final double experience;
  final String qualifications;
  final String specializations;
  final List<String> subjects;
  final String joiningDate;
  final String salary;
  final String status;

  const Teacher({
    required this.id,
    required this.name,
    required this.designation,
    required this.phone,
    required this.email,
    required this.address,
    required this.initials,
    required this.classTeacher,
    required this.experience,
    required this.qualifications,
    required this.specializations,
    required this.subjects,
    required this.joiningDate,
    required this.salary,
    required this.status,
  });
}

class TeachersManagementPage extends StatefulWidget {
  const TeachersManagementPage({super.key});

  @override
  State<TeachersManagementPage> createState() => _TeachersManagementPageState();
}

class _TeachersManagementPageState extends State<TeachersManagementPage> {
  final List<Teacher> _teachers = [
    const Teacher(
      id: 1,
      name: 'Dr. Sarah Johnson',
      designation: 'Mathematics',
      phone: '+1-555-0101',
      email: 'sarah.johnson@school.com',
      address: '123 Teacher Street, Education City',
      initials: 'SJ',
      classTeacher: 'Grade 10A',
      experience: 12,
      qualifications: 'Ph.D. in Mathematics, M.Ed. in Education',
      specializations: 'Advanced Algebra, Calculus, Statistics',
      subjects: ['Mathematics', 'Advanced Mathematics'],
      joiningDate: '2012-08-15',
      salary: '\$65,000',
      status: 'Active',
    ),
    const Teacher(
      id: 2,
      name: 'Prof. Michael Chen',
      designation: 'Physics',
      phone: '+1-555-0102',
      email: 'michael.chen@school.com',
      address: '456 Educator Avenue, Learning District',
      initials: 'MC',
      classTeacher: 'Grade 11B',
      experience: 15,
      qualifications: 'Ph.D. in Physics, B.Ed. in Science Education',
      specializations: 'Quantum Mechanics, Thermodynamics, Electromagnetism',
      subjects: ['Physics', 'Advanced Physics'],
      joiningDate: '2009-03-20',
      salary: '\$70,000',
      status: 'Active',
    ),
    const Teacher(
      id: 3,
      name: 'Ms. Emily White',
      designation: 'English',
      phone: '+1-555-0103',
      email: 'emily.white@school.com',
      address: '789 Learning Road, Knowledge Town',
      initials: 'EW',
      classTeacher: 'Grade 9C',
      experience: 8,
      qualifications: 'M.A. in English Literature, PGCE',
      specializations: 'British Literature, Creative Writing, Grammar',
      subjects: ['English', 'Literature'],
      joiningDate: '2016-09-01',
      salary: '\$55,000',
      status: 'Active',
    ),
    const Teacher(
      id: 4,
      name: 'Mr. David Brown',
      designation: 'History',
      phone: '+1-555-0104',
      email: 'david.brown@school.com',
      address: '321 Knowledge Boulevard, Wisdom City',
      initials: 'DB',
      classTeacher: 'Grade 12A',
      experience: 10,
      qualifications: 'M.A. in History, B.Ed. in Social Studies',
      specializations: 'World History, American History, Political Science',
      subjects: ['History', 'Social Studies'],
      joiningDate: '2014-01-15',
      salary: '\$58,000',
      status: 'Active',
    ),
    const Teacher(
      id: 5,
      name: 'Mrs. Lisa Garcia',
      designation: 'Biology',
      phone: '+1-555-0105',
      email: 'lisa.garcia@school.com',
      address: '654 Science Way, Discovery District',
      initials: 'LG',
      classTeacher: 'Grade 10B',
      experience: 9,
      qualifications: 'M.S. in Biology, B.Ed. in Science',
      specializations: 'Molecular Biology, Ecology, Human Anatomy',
      subjects: ['Biology', 'Environmental Science'],
      joiningDate: '2015-08-20',
      salary: '\$60,000',
      status: 'Active',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  late List<Teacher> _visibleTeachers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _visibleTeachers = List<Teacher>.from(_teachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalTeachers => _teachers.length;
  int get _activeTeachers =>
      _teachers.where((teacher) => teacher.status == 'Active').length;
  int get _classTeachers =>
      _teachers.where((teacher) => (teacher.classTeacher ?? '').isNotEmpty).length;
  double get _avgExperience =>
      _teachers.fold<double>(0, (sum, teacher) => sum + teacher.experience) /
      _teachers.length;

  void _filterTeachers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _visibleTeachers = List<Teacher>.from(_teachers);
        return;
      }
      final lower = query.toLowerCase();
      _visibleTeachers = _teachers.where((teacher) {
        return teacher.name.toLowerCase().contains(lower) ||
            teacher.designation.toLowerCase().contains(lower) ||
            (teacher.classTeacher?.toLowerCase().contains(lower) ?? false);
      }).toList();
    });
  }

  void _addTeacher() {
    app.SchoolManagementApp.navigatorKey.currentState?.pushNamed('/add-teacher');
  }

  void _editTeacher(Teacher teacher) {
    app.SchoolManagementApp.navigatorKey.currentState?.pushNamed('/edit-teacher', arguments: teacher.id);
  }

  void _deleteTeacher(Teacher teacher) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete ${teacher.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _teachers.removeWhere((t) => t.id == teacher.id);
                _filterTeachers(_searchQuery);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teacher deleted successfully!')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewTeacher(Teacher teacher) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 750),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${teacher.name} - Teacher Profile',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isNarrow = constraints.maxWidth < 600;
                                      return Flex(
                                        direction:
                                            isNarrow ? Axis.vertical : Axis.horizontal,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width:
                                                isNarrow ? double.infinity : 220,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 150,
                                                  height: 150,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF667EEA),
                                                        Color(0xFF764BA2),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      teacher.initials,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 48,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  teacher.name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  teacher.designation,
                                                  style: const TextStyle(
                                                    color: Color(0xFF666666),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  teacher.status,
                                                  style: const TextStyle(
                                                    color: Color(0xFF667EEA),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16, width: 30),
                                          Expanded(
                                            child: GridView.count(
                                              crossAxisCount: isNarrow ? 1 : 2,
                                              shrinkWrap: true,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: 1.5,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: [
                                                _DetailCard(
                                                  title: 'Contact Information',
                                                  lines: [
                                                    'Phone: ${teacher.phone}',
                                                    'Email: ${teacher.email}',
                                                    'Address: ${teacher.address}',
                                                  ],
                                                ),
                                                _DetailCard(
                                                  title: 'Professional Details',
                                                  lines: [
                                                    'Experience: ${teacher.experience.toStringAsFixed(0)} years',
                                                    'Joining Date: ${teacher.joiningDate}',
                                                    'Salary: ${teacher.salary}',
                                                  ],
                                                ),
                                                _DetailCard(
                                                  title: 'Academic Information',
                                                  lines: [
                                                    'Class Teacher: ${teacher.classTeacher ?? 'Not Assigned'}',
                                                    'Subjects: ${teacher.subjects.join(', ')}',
                                                    'Qualifications: ${teacher.qualifications}',
                                                  ],
                                                ),
                                                _DetailCard(
                                                  title: 'Specializations',
                                                  lines: [teacher.specializations],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _GradientButton(
                                        label: 'Edit Profile',
                                        colors: const [
                                          Color(0xFF667EEA),
                                          Color(0xFF764BA2)
                                        ],
                                        onTap: () {
                                          _editTeacher(teacher);
                                        },
                                      ),
                                      _GradientButton(
                                        label: 'Close',
                                        colors: const [
                                          Color(0xFF6C757D),
                                          Color(0xFF495057)
                                        ],
                                        onTap: () => Navigator.of(context).pop(),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
              isActive: item['label'] == 'Teachers',
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
                  // Use the global navigator key to ensure correct navigation
                  app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed(route);
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
                    'Teachers Management',
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
                    Text('👨‍🏫', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 15),
                    Text(
                      'Teachers Management',
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
                  'Manage all teachers, their profiles, assignments, and performance',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isMobile ? 1 : 4;
              final childAspectRatio = isMobile ? 3.4 : 1.35;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                shrinkWrap: true,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(label: 'Total Teachers', value: '$_totalTeachers'),
                  _StatCard(label: 'Active Teachers', value: '$_activeTeachers'),
                  _StatCard(label: 'Class Teachers', value: '$_classTeachers'),
                  _StatCard(
                    label: 'Avg Experience (Years)',
                    value: _avgExperience.toStringAsFixed(1),
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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE1E5E9), width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterTeachers,
                      decoration: const InputDecoration(
                        hintText:
                            'Search teachers by name, designation, or class...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 15 : 0),
                _GradientButton(
                  label: '+ Add New Teacher',
                  colors: const [Color(0xFF51CF66), Color(0xFF40C057)],
                  onTap: _addTeacher,
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 350.0;
              final columns = (constraints.maxWidth / minWidth).floor().clamp(1, 4);
              final spacing = 20.0;
              final totalSpacing = spacing * (columns - 1);
              final width =
                  (constraints.maxWidth - totalSpacing) / columns.toDouble();

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _visibleTeachers
                    .map(
                      (teacher) => SizedBox(
                        width: width,
                        child: _buildTeacherCard(teacher),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    return _TeacherCardWithHover(
      teacher: teacher,
      onView: () => _viewTeacher(teacher),
      onEdit: () => _editTeacher(teacher),
      onDelete: () => _deleteTeacher(teacher),
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

class _TeacherCardWithHover extends StatefulWidget {
  final Teacher teacher;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherCardWithHover({
    required this.teacher,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TeacherCardWithHover> createState() => _TeacherCardWithHoverState();
}

class _TeacherCardWithHoverState extends State<_TeacherCardWithHover> {
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
                        widget.teacher.initials,
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
                          widget.teacher.name,
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
                          '${widget.teacher.designation} • ${widget.teacher.classTeacher ?? 'No Class Assigned'}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 13,
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
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Experience',
                          value: '${widget.teacher.experience.toStringAsFixed(0)} years',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Phone',
                          value: widget.teacher.phone,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Email',
                          value: widget.teacher.email,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Status',
                          value: widget.teacher.status,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
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
    final radius =
        drawRightBorder ? BorderRadius.zero : BorderRadius.circular(borderRadius);

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

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _DetailCard({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 12,
              color: Color(0xFF666666),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                line,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

