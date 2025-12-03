import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';

class Department {
  final int id;
  final String name;
  final String code;
  final String head;
  final String email;
  final int faculty;
  final int students;
  final int courses;
  final String? description;
  final String? phone;
  final DateTime? establishedDate;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.head,
    required this.email,
    required this.faculty,
    required this.students,
    required this.courses,
    this.description,
    this.phone,
    this.establishedDate,
  });

  Department copyWith({
    int? id,
    String? name,
    String? code,
    String? head,
    String? email,
    int? faculty,
    int? students,
    int? courses,
    String? description,
    String? phone,
    DateTime? establishedDate,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      head: head ?? this.head,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      students: students ?? this.students,
      courses: courses ?? this.courses,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      establishedDate: establishedDate ?? this.establishedDate,
    );
  }
}

class DepartmentsManagementPage extends StatefulWidget {
  const DepartmentsManagementPage({super.key});

  @override
  State<DepartmentsManagementPage> createState() =>
      _DepartmentsManagementPageState();
}

class _DepartmentsManagementPageState extends State<DepartmentsManagementPage> {
  final List<Department> _allDepartments = [
    Department(
      id: 1,
      name: 'Computer Science',
      code: 'CS',
      head: 'Dr. Sarah Johnson',
      email: 'cs@school.edu',
      faculty: 12,
      students: 180,
      courses: 8,
      description:
          'Leading department in computer science education with state-of-the-art facilities.',
      phone: '+1-234-567-8901',
      establishedDate: DateTime(2010, 1, 15),
    ),
    Department(
      id: 2,
      name: 'Mechanical Engineering',
      code: 'ME',
      head: 'Prof. Michael Chen',
      email: 'me@school.edu',
      faculty: 15,
      students: 220,
      courses: 10,
      description:
          'Comprehensive mechanical engineering program with modern laboratories.',
      phone: '+1-234-567-8902',
      establishedDate: DateTime(2008, 3, 20),
    ),
    Department(
      id: 3,
      name: 'Electrical Engineering',
      code: 'EE',
      head: 'Dr. Emily Davis',
      email: 'ee@school.edu',
      faculty: 14,
      students: 200,
      courses: 9,
      description:
          'Excellence in electrical engineering with focus on innovation and research.',
      phone: '+1-234-567-8903',
      establishedDate: DateTime(2009, 5, 10),
    ),
    Department(
      id: 4,
      name: 'Mathematics',
      code: 'MATH',
      head: 'Prof. Robert Wilson',
      email: 'math@school.edu',
      faculty: 8,
      students: 120,
      courses: 6,
      description:
          'Strong foundation in mathematical sciences and applied mathematics.',
      phone: '+1-234-567-8904',
      establishedDate: DateTime(2007, 8, 1),
    ),
    Department(
      id: 5,
      name: 'Physics',
      code: 'PHY',
      head: 'Dr. Lisa Thompson',
      email: 'physics@school.edu',
      faculty: 10,
      students: 150,
      courses: 7,
      description:
          'Advanced physics research and education with cutting-edge equipment.',
      phone: '+1-234-567-8905',
      establishedDate: DateTime(2006, 9, 15),
    ),
    Department(
      id: 6,
      name: 'Chemistry',
      code: 'CHEM',
      head: 'Prof. David Brown',
      email: 'chemistry@school.edu',
      faculty: 9,
      students: 130,
      courses: 5,
      description:
          'Comprehensive chemistry program with well-equipped laboratories.',
      phone: '+1-234-567-8906',
      establishedDate: DateTime(2007, 2, 28),
    ),
  ];

  List<Department> _filteredDepartments = [];
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'code', 'faculty', 'students'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredDepartments = _allDepartments;
    _sortDepartments();
  }

  void _filterDepartments() {
    setState(() {
      _filteredDepartments = _allDepartments.where((dept) {
        final matchesSearch = _searchQuery.isEmpty ||
            dept.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dept.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dept.head.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            dept.email.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesSearch;
      }).toList();
      _sortDepartments();
    });
  }

  void _sortDepartments() {
    _filteredDepartments.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'code':
          comparison = a.code.compareTo(b.code);
          break;
        case 'faculty':
          comparison = a.faculty.compareTo(b.faculty);
          break;
        case 'students':
          comparison = a.students.compareTo(b.students);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  Map<String, dynamic> _getStats() {
    final totalFaculty =
        _allDepartments.fold(0, (sum, dept) => sum + dept.faculty);
    final totalStudents =
        _allDepartments.fold(0, (sum, dept) => sum + dept.students);
    final totalCourses =
        _allDepartments.fold(0, (sum, dept) => sum + dept.courses);
    final avgFacultyPerDept = totalFaculty / _allDepartments.length;

    return {
      'totalDepartments': _allDepartments.length,
      'totalFaculty': totalFaculty,
      'totalStudents': totalStudents,
      'totalCourses': totalCourses,
      'avgFaculty': avgFacultyPerDept.round(),
      'facultySatisfaction': '92%',
      'studentSuccessRate': '88%',
    };
  }

  void _addDepartment(Department department) {
    setState(() {
      _allDepartments.add(department);
      _filterDepartments();
    });
  }

  void _updateDepartment(Department updatedDepartment) {
    setState(() {
      final index = _allDepartments
          .indexWhere((d) => d.id == updatedDepartment.id);
      if (index != -1) {
        _allDepartments[index] = updatedDepartment;
        _filterDepartments();
      }
    });
  }

  void _deleteDepartment(int id) {
    setState(() {
      _allDepartments.removeWhere((d) => d.id == id);
      _filterDepartments();
    });
  }

  void _exportData() {
    final csv = StringBuffer();
    csv.writeln(
        'ID,Name,Code,Head,Email,Phone,Faculty,Students,Courses,Established Date');
    for (final dept in _filteredDepartments) {
      csv.writeln(
          '${dept.id},${dept.name},${dept.code},${dept.head},${dept.email},${dept.phone ?? 'N/A'},${dept.faculty},${dept.students},${dept.courses},${dept.establishedDate != null ? DateFormat('yyyy-MM-dd').format(dept.establishedDate!) : 'N/A'}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Export ready! ${_filteredDepartments.length} records prepared.'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // In a real app, you'd copy to clipboard or save to file
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '🏫 School Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Departments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        _NavItem(
                          icon: '📊',
                          title: 'Dashboard',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/dashboard'),
                        ),
                        _NavItem(
                          icon: '👨‍🏫',
                          title: 'Teachers',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/teachers'),
                        ),
                        _NavItem(
                          icon: '👥',
                          title: 'Students',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/students'),
                        ),
                        _NavItem(
                          icon: '🚌',
                          title: 'Buses',
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/buses'),
                        ),
                        _NavItem(
                          icon: '📅',
                          title: 'Events',
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/events'),
                        ),
                        _NavItem(
                          icon: '📚',
                          title: 'Activities',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/activities'),
                        ),
                        _NavItem(
                          icon: '🏆',
                          title: 'Awards',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/awards'),
                        ),
                        _NavItem(
                          icon: '🎓',
                          title: 'Admissions',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/admissions'),
                        ),
                        _NavItem(
                          icon: '📅',
                          title: 'Calendar',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/calendar'),
                        ),
                        _NavItem(
                          icon: '🏫',
                          title: 'Campus Life',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/campus-life'),
                        ),
                        _NavItem(
                          icon: '🏢',
                          title: 'Departments',
                          isActive: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                      decoration: BoxDecoration(gradient: gradient),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🏢 Department Management',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage academic departments, faculty, and courses',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.white),
                                onPressed: _exportData,
                                tooltip: 'Export Data',
                              ),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())), 
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text("Back to Dashboard"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Stats Overview
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: '🏢',
                              number: stats['totalDepartments']!.toString(),
                              label: 'Total Departments',
                              color: const Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _StatCard(
                              icon: '👨‍🏫',
                              number: stats['totalFaculty']!.toString(),
                              label: 'Total Faculty',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _StatCard(
                              icon: '📚',
                              number: stats['totalCourses']!.toString(),
                              label: 'Total Courses',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _StatCard(
                              icon: '👥',
                              number: stats['totalStudents']!.toString(),
                              label: 'Total Students',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search and Sort
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search departments...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                _filterDepartments();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButton<String>(
                              value: _sortBy,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'name', child: Text('Sort by Name')),
                                DropdownMenuItem(
                                    value: 'code', child: Text('Sort by Code')),
                                DropdownMenuItem(
                                    value: 'faculty',
                                    child: Text('Sort by Faculty')),
                                DropdownMenuItem(
                                    value: 'students',
                                    child: Text('Sort by Students')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _sortBy = value!;
                                  _sortDepartments();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(_sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward),
                            onPressed: () {
                              setState(() {
                                _sortAscending = !_sortAscending;
                                _sortDepartments();
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                            tooltip: 'Sort Order',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Main Content Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Departments Grid
                        Expanded(
                          flex: 2,
                          child: _filteredDepartments.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.business_outlined,
                                            size: 64, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No departments found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    mainAxisExtent: 210,
                                  ),
                                  itemCount: _filteredDepartments.length,
                                  itemBuilder: (context, index) {
                                    return _DepartmentCard(
                                      department: _filteredDepartments[index],
                                      onView: () => _viewDepartment(
                                          context, _filteredDepartments[index]),
                                      onEdit: () => _showEditDepartmentDialog(
                                          context,
                                          _filteredDepartments[index]),
                                      onDelete: () => _deleteDepartment(
                                          _filteredDepartments[index].id),
                                    );
                                  },
                                ),
                        ),
                        // Sidebar
                        Container(
                          width: 300,
                          margin: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                                // Quick Actions
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Quick Actions',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      _QuickActionItem(
                                        icon: Icons.add,
                                        label: 'Add New Department',
                                        onTap: () =>
                                            _showAddDepartmentDialog(context),
                                      ),
                                      _QuickActionItem(
                                        icon: Icons.bar_chart,
                                        label: 'View Statistics',
                                        onTap: () => _showStatisticsDialog(context),
                                      ),
                                      _QuickActionItem(
                                        icon: Icons.upload,
                                        label: 'Export Data',
                                        onTap: _exportData,
                                      ),
                                      _QuickActionItem(
                                        icon: Icons.people,
                                        label: 'Manage Faculty',
                                        onTap: () => _showFacultyManagementDialog(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Additional Stats
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      _MiniStatCard(
                                        icon: '📈',
                                        number: stats['facultySatisfaction']!,
                                        label: 'Faculty Satisfaction',
                                      ),
                                      const SizedBox(height: 15),
                                      _MiniStatCard(
                                        icon: '🎯',
                                        number: stats['studentSuccessRate']!,
                                        label: 'Student Success Rate',
                                      ),
                                      const SizedBox(height: 15),
                                      _MiniStatCard(
                                        icon: '👨‍🏫',
                                        number: '${stats['avgFaculty']}',
                                        label: 'Avg Faculty/Dept',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDepartment(BuildContext context, Department department) {
    showDialog(
      context: context,
      builder: (context) => _DepartmentDetailDialog(department: department),
    );
  }

  void _showAddDepartmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DepartmentFormDialog(
        onSave: (department) {
          _addDepartment(department);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Department added successfully!')),
          );
        },
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, Department department) {
    showDialog(
      context: context,
      builder: (context) => _DepartmentFormDialog(
        department: department,
        onSave: (updatedDepartment) {
          _updateDepartment(updatedDepartment);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Department updated successfully!')),
          );
        },
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    final stats = _getStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Department Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow('Total Departments', stats['totalDepartments']!.toString()),
              _StatRow('Total Faculty', stats['totalFaculty']!.toString()),
              _StatRow('Total Students', stats['totalStudents']!.toString()),
              _StatRow('Total Courses', stats['totalCourses']!.toString()),
              _StatRow('Average Faculty/Dept', stats['avgFaculty']!.toString()),
              _StatRow('Faculty Satisfaction', stats['facultySatisfaction']!),
              _StatRow('Student Success Rate', stats['studentSuccessRate']!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFacultyManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faculty Management'),
        content: const Text(
            'Faculty Management Interface:\n\n• Assign faculty to departments\n• View faculty profiles\n• Manage teaching assignments\n• Track faculty performance\n• Schedule classes\n• Manage workloads'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/teachers');
            },
            child: const Text('Go to Teachers'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.isActive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: widget.isActive
              ? Colors.white.withValues(alpha: 0.3)
              : _isHovered
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: ListTile(
          leading: Text(widget.icon, style: const TextStyle(fontSize: 20)),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.white,
              fontWeight: widget.isActive || _isHovered
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: widget.isActive || _isHovered ? 15.0 : 14.0,
            ),
            child: Text(widget.title),
          ),
          selected: widget.isActive,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String number;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DepartmentCard({
    required this.department,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      department.code[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                        department.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${department.code} Department',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    number: department.faculty.toString(),
                    label: 'Faculty',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    number: department.students.toString(),
                    label: 'Students',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatItem(
                    number: department.courses.toString(),
                    label: 'Courses',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Department'),
                          content: Text(
                              'Are you sure you want to delete ${department.name} Department?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Department deleted')),
                                );
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$number $label',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withValues(alpha: 0.1),
          border: Border.all(
            color: const Color(0xFF667EEA).withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF667EEA)),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String icon;
  final String number;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentDetailDialog extends StatelessWidget {
  final Department department;

  const _DepartmentDetailDialog({required this.department});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Department Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _DetailItem('Name', department.name),
              _DetailItem('Code', department.code),
              _DetailItem('Head of Department', department.head),
              _DetailItem('Email', department.email),
              if (department.phone != null)
                _DetailItem('Phone', department.phone!),
              _DetailItem('Faculty Members', department.faculty.toString()),
              _DetailItem('Students', department.students.toString()),
              _DetailItem('Courses', department.courses.toString()),
              if (department.establishedDate != null)
                _DetailItem('Established',
                    DateFormat('MMM dd, yyyy').format(department.establishedDate!)),
              if (department.description != null)
                _DetailItem('Description', department.description!),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentFormDialog extends StatefulWidget {
  final Department? department;
  final Function(Department) onSave;

  const _DepartmentFormDialog({
    this.department,
    required this.onSave,
  });

  @override
  State<_DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends State<_DepartmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _headController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _facultyController;
  late TextEditingController _studentsController;
  late TextEditingController _coursesController;
  late TextEditingController _descriptionController;

  DateTime? _establishedDate;

  @override
  void initState() {
    super.initState();
    final dept = widget.department;
    _nameController = TextEditingController(text: dept?.name ?? '');
    _codeController = TextEditingController(text: dept?.code ?? '');
    _headController = TextEditingController(text: dept?.head ?? '');
    _emailController = TextEditingController(text: dept?.email ?? '');
    _phoneController = TextEditingController(text: dept?.phone ?? '');
    _facultyController =
        TextEditingController(text: dept?.faculty.toString() ?? '');
    _studentsController =
        TextEditingController(text: dept?.students.toString() ?? '');
    _coursesController =
        TextEditingController(text: dept?.courses.toString() ?? '');
    _descriptionController =
        TextEditingController(text: dept?.description ?? '');
    _establishedDate = dept?.establishedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _headController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _studentsController.dispose();
    _coursesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final department = Department(
        id: widget.department?.id ??
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        head: _headController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        faculty: int.tryParse(_facultyController.text.trim()) ?? 0,
        students: int.tryParse(_studentsController.text.trim()) ?? 0,
        courses: int.tryParse(_coursesController.text.trim()) ?? 0,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        establishedDate: _establishedDate,
      );

      widget.onSave(department);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.department == null
                        ? 'Add New Department'
                        : 'Edit Department',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Department Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter department name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                labelText: 'Department Code *',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., CS, ME, EE',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter department code';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _headController,
                              decoration: const InputDecoration(
                                labelText: 'Head of Department *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter head of department';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _establishedDate ?? DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _establishedDate = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 8),
                                    Text(
                                      _establishedDate == null
                                          ? 'Established Date (Optional)'
                                          : DateFormat('MMM dd, yyyy')
                                              .format(_establishedDate!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _facultyController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Faculty *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of faculty';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _studentsController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Students *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of students';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _coursesController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Courses *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of courses';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                        widget.department == null ? 'Add Department' : 'Update Department'),
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

