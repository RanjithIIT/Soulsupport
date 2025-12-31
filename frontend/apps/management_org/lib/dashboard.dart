import 'package:flutter/material.dart';
import 'package:main_login/main.dart' as main_login;
import 'package:core/api/api_service.dart';
import 'main.dart' as app;
import 'widgets/school_profile_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Safe navigation helper that ensures context is valid
  void _navigateToRoute(String route) {
    // Use the global navigator key to ensure correct navigation
    final navigator = app.SchoolManagementApp.navigatorKey.currentState;
    if (navigator != null) {
      if (navigator.canPop() || route != '/dashboard') {
        navigator.pushReplacementNamed(route);
      } else {
        navigator.pushNamed(route);
      }
    }
  }

  final List<Map<String, dynamic>> _recentTeachers = [
    {
      'name': 'Dr. Sarah Johnson',
      'designation': 'Mathematics',
      'initials': 'SJ',
    },
    {
      'name': 'Prof. Michael Chen',
      'designation': 'Physics',
      'initials': 'MC',
    },
    {
      'name': 'Ms. Emily White',
      'designation': 'English',
      'initials': 'EW',
    },
    {
      'name': 'Mr. David Brown',
      'designation': 'History',
      'initials': 'DB',
    },
    {
      'name': 'Mrs. Lisa Garcia',
      'designation': 'Biology',
      'initials': 'LG',
    },
  ];

  final List<Map<String, dynamic>> _recentStudents = [
    {
      'name': 'Alice Brown',
      'class': '10th',
      'section': 'A',
      'initials': 'AB',
    },
    {
      'name': 'Charlie Wilson',
      'class': '11th',
      'section': 'B',
      'initials': 'CW',
    },
    {
      'name': 'Diana Davis',
      'class': '12th',
      'section': 'C',
      'initials': 'DD',
    },
    {
      'name': 'Ethan Miller',
      'class': '9th',
      'section': 'A',
      'initials': 'EM',
    },
    {
      'name': 'Fiona Taylor',
      'class': '10th',
      'section': 'B',
      'initials': 'FT',
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'icon': '🏀',
      'title': 'Basketball Practice',
      'description': 'Team practice session completed',
      'time': '2 hours ago',
    },
    {
      'icon': '🔬',
      'title': 'Science Club Meeting',
      'description': 'New experiment planning session',
      'time': '4 hours ago',
    },
    {
      'icon': '🎵',
      'title': 'Music Band Rehearsal',
      'description': 'Spring concert preparation',
      'time': '6 hours ago',
    },
    {
      'icon': '📚',
      'title': 'Debate Club',
      'description': 'Regional competition preparation',
      'time': '1 day ago',
    },
    {
      'icon': '♟️',
      'title': 'Chess Tournament',
      'description': 'Inter-school chess competition',
      'time': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> _recentNotifications = [
    {
      'icon': '⚠️',
      'title': 'Bus Delay',
      'description': 'Bus #1 running 10 minutes late',
      'time': '1 hour ago',
    },
    {
      'icon': '📝',
      'title': 'Exam Schedule',
      'description': 'Mid-term exam schedule updated',
      'time': '3 hours ago',
    },
    {
      'icon': '👨‍🏫',
      'title': 'Teacher Absence',
      'description': 'Ms. White will be absent tomorrow',
      'time': '4 hours ago',
    },
    {
      'icon': '📚',
      'title': 'Library Notice',
      'description': 'New books available in library',
      'time': '1 day ago',
    },
    {
      'icon': '🎯',
      'title': 'Sports Event',
      'description': 'Annual sports day next week',
      'time': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> _recentAwards = [
    {
      'name': 'Best Academic Performance',
      'student': 'Alice Brown',
      'category': 'Academic',
      'date': '2024-01-15',
    },
    {
      'name': 'Sports Excellence',
      'student': 'Charlie Wilson',
      'category': 'Sports',
      'date': '2024-01-20',
    },
    {
      'name': 'Cultural Achievement',
      'student': 'Diana Davis',
      'category': 'Cultural',
      'date': '2024-01-25',
    },
    {
      'name': 'Leadership Award',
      'student': 'Ethan Miller',
      'category': 'Leadership',
      'date': '2024-01-30',
    },
  ];

  final List<Map<String, dynamic>> _galleryItems = [
    {
      'id': 1,
      'title': 'Annual Sports Day',
      'image': 'https://via.placeholder.com/150/667eea/ffffff?text=Sports',
      'date': '2024-01-15',
    },
    {
      'id': 2,
      'title': 'Science Fair',
      'image': 'https://via.placeholder.com/150/764ba2/ffffff?text=Science',
      'date': '2024-01-20',
    },
    {
      'id': 3,
      'title': 'Cultural Program',
      'image': 'https://via.placeholder.com/150/fa709a/ffffff?text=Culture',
      'date': '2024-01-25',
    },
    {
      'id': 4,
      'title': 'Teacher\'s Day',
      'image': 'https://via.placeholder.com/150/43e97b/ffffff?text=Teachers',
      'date': '2024-01-30',
    },
    {
      'id': 5,
      'title': 'Independence Day',
      'image': 'https://via.placeholder.com/150/ffd700/ffffff?text=Independence',
      'date': '2024-02-01',
    },
    {
      'id': 6,
      'title': 'Republic Day',
      'image': 'https://via.placeholder.com/150/ff6347/ffffff?text=Republic',
      'date': '2024-02-05',
    },
  ];

  final List<Map<String, dynamic>> _recentAdmissions = [
    {
      'name': 'Rahul Sharma',
      'class': '10th',
      'status': 'Approved',
      'date': '2024-01-28',
    },
    {
      'name': 'Priya Patel',
      'class': '9th',
      'status': 'Pending',
      'date': '2024-01-27',
    },
    {
      'name': 'Amit Kumar',
      'class': '11th',
      'status': 'Approved',
      'date': '2024-01-26',
    },
    {
      'name': 'Neha Singh',
      'class': '12th',
      'status': 'Under Review',
      'date': '2024-01-25',
    },
  ];

  final List<Map<String, dynamic>> _rtiRequests = [
    {
      'id': 1,
      'title': 'Student Records Request',
      'requester': 'Mr. Robert Brown',
      'status': 'Pending',
      'date': '2024-01-28',
    },
    {
      'id': 2,
      'title': 'Financial Information',
      'requester': 'Ms. Sarah Wilson',
      'status': 'Approved',
      'date': '2024-01-25',
    },
    {
      'id': 3,
      'title': 'Infrastructure Details',
      'requester': 'Mr. David Davis',
      'status': 'In Progress',
      'date': '2024-01-22',
    },
  ];

  final List<Map<String, dynamic>> _extracurricularActivities = [
    {
      'id': 1,
      'name': 'NCC (National Cadet Corps)',
      'type': 'ncc',
      'icon': '🎖️',
      'description': 'Military training and discipline',
      'incharge': 'Capt. Rajesh Kumar',
      'schedule': 'Every Saturday 8:00 AM',
    },
    {
      'id': 2,
      'name': 'NSS (National Service Scheme)',
      'type': 'nss',
      'icon': '🤝',
      'description': 'Community service and social work',
      'incharge': 'Dr. Priya Sharma',
      'schedule': 'Every Sunday 9:00 AM',
    },
    {
      'id': 3,
      'name': 'Basketball Team',
      'type': 'sports',
      'icon': '🏀',
      'description': 'School basketball team training',
      'incharge': 'Mr. Amit Singh',
      'schedule': 'Mon, Wed, Fri 4:00 PM',
    },
    {
      'id': 4,
      'name': 'Music Band',
      'type': 'arts',
      'icon': '🎵',
      'description': 'School music band and orchestra',
      'incharge': 'Ms. Neha Patel',
      'schedule': 'Tue, Thu 3:30 PM',
    },
    {
      'id': 5,
      'name': 'Science Club',
      'type': 'academic',
      'icon': '🔬',
      'description': 'Science experiments and projects',
      'incharge': 'Dr. Sanjay Verma',
      'schedule': 'Every Friday 2:00 PM',
    },
    {
      'id': 6,
      'name': 'Debate Club',
      'type': 'academic',
      'icon': '🎤',
      'description': 'Public speaking and debates',
      'incharge': 'Ms. Ritu Gupta',
      'schedule': 'Every Wednesday 3:00 PM',
    },
    {
      'id': 7,
      'name': 'Chess Club',
      'type': 'academic',
      'icon': '♟️',
      'description': 'Chess training and tournaments',
      'incharge': 'Mr. Deepak Malhotra',
      'schedule': 'Every Tuesday 4:30 PM',
    },
    {
      'id': 8,
      'name': 'Art & Craft',
      'type': 'arts',
      'icon': '🎨',
      'description': 'Creative arts and crafts',
      'incharge': 'Ms. Kavita Joshi',
      'schedule': 'Every Thursday 2:30 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1100;
        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  child: SizedBox(
                    width: 280,
                    child: _Sidebar(gradient: gradient),
                  ),
                ),
          body: Row(
            children: [
              if (showSidebar) _Sidebar(gradient: gradient),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F6FA),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            showMenuButton: !showSidebar,
                            onMenuTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            onLogout: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Navigate to main login page
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
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _StatsGrid(
                            onNavigate: (section) {
                              _navigateToRoute('/$section');
                            },
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, inner) {
                              final stacked = inner.maxWidth < 800;
                              return Flex(
                                mainAxisSize: MainAxisSize.min,
                                direction:
                                    stacked ? Axis.vertical : Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _RecentTeachersSection(
                                      teachers: _recentTeachers,
                                    ),
                                  ),
                                  SizedBox(
                                    width: stacked ? 0 : 24,
                                    height: stacked ? 24 : 0,
                                  ),
                                  Expanded(
                                    child: _RecentStudentsSection(
                                      students: _recentStudents,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _AnalyticsSection(),
                          const SizedBox(height: 24),
                          _RecentActivitiesSection(
                            activities: _recentActivities,
                          ),
                          const SizedBox(height: 24),
                          _RecentNotificationsSection(
                            notifications: _recentNotifications,
                          ),
                          const SizedBox(height: 24),
                          _RecentAwardsSection(
                            awards: _recentAwards,
                          ),
                          const SizedBox(height: 24),
                          _GallerySection(
                            galleryItems: _galleryItems,
                          ),
                          const SizedBox(height: 24),
                          _RecentAdmissionsSection(
                            admissions: _recentAdmissions,
                          ),
                          const SizedBox(height: 24),
                          _ExtracurricularSection(
                            activities: _extracurricularActivities,
                          ),
                          const SizedBox(height: 24),
                          _RTISection(
                            rtiRequests: _rtiRequests,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final LinearGradient gradient;

  const _Sidebar({required this.gradient});

  // Safe navigation helper for sidebar
  void _navigateToRoute(BuildContext context, String route) {
    final navigator = Navigator.of(context);
    if (navigator.canPop() || route != '/dashboard') {
      navigator.pushReplacementNamed(route);
    } else {
      navigator.pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
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
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'packages/management_org/assets/Vidyarambh.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image is not found
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 56,
                        color: Color(0xFF667EEA),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _NavItem(
                    icon: '📊',
                    title: 'Overview',
                    isActive: true,
                    onTap: () => _navigateToRoute(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () => _navigateToRoute(context, '/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () => _navigateToRoute(context, '/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () => _navigateToRoute(context, '/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    onTap: () => _navigateToRoute(context, '/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    onTap: () => _navigateToRoute(context, '/events'),
                  ),
                  _NavItem(
                    icon: '📆',
                    title: 'Calendar',
                    onTap: () => _navigateToRoute(context, '/calendar'),
                  ),
                  _NavItem(
                    icon: '🔔',
                    title: 'Notifications',
                    onTap: () => _navigateToRoute(context, '/notifications'),
                  ),
                  _NavItem(
                    icon: '🛣️',
                    title: 'Bus Routes',
                    onTap: () => _navigateToRoute(context, '/buses'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final VoidCallback onLogout;

  const _Header({
    required this.showMenuButton,
    this.onMenuTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showMenuButton)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu, color: Colors.black87),
                ),
              const Text(
                'Management Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SchoolProfileHeader(apiService: ApiService()),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to main login page
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
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const _StatsGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'icon': '🎓',
        'number': '45',
        'label': 'Admissions',
        'description': 'Click to manage new admissions',
        'color': const Color(0xFFFF6347),
        'route': 'admissions',
      },
      {
        'icon': '👨‍🏫',
        'number': '28',
        'label': 'Total Teachers',
        'description': 'Click to manage teachers',
        'color': const Color(0xFF667EEA),
        'route': 'teachers',
      },
      {
        'icon': '👥',
        'number': '450',
        'label': 'Total Students',
        'description': 'Click to manage students',
        'color': const Color(0xFF764BA2),
        'route': 'students',
      },
      {
        'icon': '🚌',
        'number': '8',
        'label': 'Total Buses',
        'description': 'Click to manage bus routes',
        'color': const Color(0xFF4FACFE),
        'route': 'buses',
      },
      {
        'icon': '📝',
        'number': '12',
        'label': 'Examination Section',
        'description': 'Click to manage exams',
        'color': const Color(0xFFFF6B35),
        'route': 'examinations',
      },
      {
        'icon': '💰',
        'number': '450',
        'label': 'Fees',
        'description': 'Click to manage fee structure',
        'color': const Color(0xFF28A745),
        'route': 'fees',
      },
      {
        'icon': '🔔',
        'number': '5',
        'label': 'Notifications',
        'description': 'Important updates',
        'color': const Color(0xFFFED6E3),
        'route': 'notifications',
      },
      {
        'icon': '🎯',
        'number': '15',
        'label': 'Activities',
        'description': 'Click to manage activities',
        'color': const Color(0xFFA8EDEA),
        'route': 'activities',
      },
      {
        'icon': '🛣️',
        'number': '6',
        'label': 'Bus Routes',
        'description': 'Transportation network',
        'color': const Color(0xFFFFECD2),
        'route': 'buses',
      },
      {
        'icon': '📅',
        'number': '8',
        'label': 'Events',
        'description': 'Click to manage events',
        'color': const Color(0xFFFA709A),
        'route': 'events',
      },
      {
        'icon': '📊',
        'number': '12',
        'label': 'Calendar Events',
        'description': 'Upcoming activities',
        'color': const Color(0xFF43E97B),
        'route': 'calendar',
      },
      {
        'icon': '🏆',
        'number': '25',
        'label': 'Awards',
        'description': 'Click to manage awards',
        'color': const Color(0xFFFFD700),
        'route': 'awards',
      },
      {
        'icon': '📸',
        'number': '150',
        'label': 'Photo Gallery',
        'description': 'Click to manage photos',
        'color': const Color(0xFFFF69B4),
        'route': 'gallery',
      },
      {
        'icon': '🎭',
        'number': '8',
        'label': 'Extra Curricular',
        'description': 'Click to manage activities',
        'color': const Color(0xFF9370DB),
        'route': 'activities',
      },
      {
        'icon': '📋',
        'number': '3',
        'label': 'RTI Act',
        'description': 'Right to Information',
        'color': const Color(0xFF20B2AA),
        'route': null,
      },
      {
        'icon': '🏫',
        'number': '12',
        'label': 'Campus Life',
        'description': 'Campus speciality',
        'color': const Color(0xFF32CD32),
        'route': 'campus-life',
      },
      {
        'icon': '🏢',
        'number': '6',
        'label': 'Departments',
        'description': 'Academic departments',
        'color': const Color(0xFF6F42C1),
        'route': 'departments',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive columns based on screen width
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1600) {
          crossAxisCount = 6;
          childAspectRatio = 1.4;
        } else if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.3;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.5;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 15,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _StatCard(
              icon: stat['icon'] as String,
              number: stat['number'] as String,
              label: stat['label'] as String,
              description: stat['description'] as String,
              color: stat['color'] as Color,
              onTap: stat['route'] != null
                  ? () => onNavigate(stat['route'] as String)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final String icon;
  final String number;
  final String label;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(15),
            border: Border(
              left: BorderSide(color: widget.color, width: 5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.1),
                blurRadius: _isHovered ? 16 : 12,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (_isHovered)
                Positioned(
                  top: 0,
                  left: 5,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTeachersSection extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;

  const _RecentTeachersSection({required this.teachers});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👨‍🏫', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Teachers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/teachers');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...teachers.map((teacher) => _ListItem(
                avatar: teacher['initials'] as String,
                title: teacher['name'] as String,
                subtitle: teacher['designation'] as String,
                onTap: () {
                  app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/teachers');
                },
              )),
        ],
      ),
    );
  }
}

class _RecentStudentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const _RecentStudentsSection({required this.students});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👥', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Students',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/students');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...students.map((student) => _ListItem(
                avatar: student['initials'] as String,
                title: student['name'] as String,
                subtitle:
                    '${student['class']} • Section ${student['section']}',
                onTap: () {
                  app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/students');
                },
              )),
        ],
      ),
    );
  }
}

class _ListItem extends StatefulWidget {
  final String avatar;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ListItem({
    required this.avatar,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<_ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<_ListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? null
                : Colors.white.withValues(alpha: 0.7),
            gradient: _isHovered
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isHovered ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isHovered ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📊 Analytics & Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 800;
              return Flex(
                mainAxisSize: MainAxisSize.min,
                direction: stacked ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    child: _AttendanceChart(),
                  ),
                  if (!stacked) const SizedBox(width: 20),
                  if (stacked) const SizedBox(height: 20),
                  Expanded(
                    child: _PerformanceChart(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AttendanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Adjusted data to match image: medium, lower, highest, lower, lowest, medium, medium
    final data = [75, 65, 95, 80, 55, 70, 75];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            'Attendance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: data[index] * 1.8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      {'subject': 'Mathematics', 'score': 85},
      {'subject': 'Science', 'score': 92},
      {'subject': 'English', 'score': 78},
      {'subject': 'History', 'score': 88},
      {'subject': 'Computer Science', 'score': 95},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            'Academic Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...data.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['subject'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (item['score'] as int) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${item['score']}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667EEA),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RecentActivitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const _RecentActivitiesSection({required this.activities});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/activities');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activities.map((activity) => _ActivityItem(
                icon: activity['icon'] as String,
                title: activity['title'] as String,
                description: activity['description'] as String,
                time: activity['time'] as String,
              )),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? null
              : Colors.white.withValues(alpha: 0.7),
          gradient: _isHovered
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.description} • ${widget.time}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isHovered ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _RecentNotificationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const _RecentNotificationsSection({required this.notifications});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text('🔔', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Recent Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...notifications.map((notification) => _NotificationItem(
                icon: notification['icon'] as String,
                title: notification['title'] as String,
                description: notification['description'] as String,
                time: notification['time'] as String,
              )),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? null
              : Colors.white.withValues(alpha: 0.7),
          gradient: _isHovered
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.description} • ${widget.time}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _isHovered ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAwardsSection extends StatelessWidget {
  final List<Map<String, dynamic>> awards;

  const _RecentAwardsSection({required this.awards});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Awards',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/awards');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...awards.map((award) => _ListItem(
                avatar: '🏆',
                title: award['name'] as String,
                subtitle:
                    '${award['student']} • ${award['category']} • ${award['date']}',
                onTap: () {
                  app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/awards');
                },
              )),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final List<Map<String, dynamic>> galleryItems;

  const _GallerySection({required this.galleryItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📸', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Photo Gallery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/gallery');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: galleryItems.length,
                itemBuilder: (context, index) => _GalleryItem(
                  item: galleryItems[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryItem extends StatefulWidget {
  final Map<String, dynamic> item;

  const _GalleryItem({required this.item});

  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.pushReplacementNamed('/gallery');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: _isHovered
                    ? const Color(0xFF667EEA).withValues(alpha: 0.6)
                    : const Color(0xFF667EEA).withValues(alpha: 0.3),
                child: Center(
                  child: Text(
                    widget.item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    widget.item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _RecentAdmissionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> admissions;

  const _RecentAdmissionsSection({required this.admissions});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎓', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Recent Admissions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/admissions');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...admissions.map((admission) => _ListItem(
                avatar: '🎓',
                title: admission['name'] as String,
                subtitle:
                    'Class ${admission['class']} • ${admission['status']} • ${admission['date']}',
                onTap: () {
                  app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/admissions');
                },
              )),
        ],
      ),
    );
  }
}

class _ExtracurricularSection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const _ExtracurricularSection({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎭', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Extra Curricular Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    app.SchoolManagementApp.navigatorKey.currentState?.pushReplacementNamed('/activities');
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Add New'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemCount: activities.length,
                itemBuilder: (context, index) => _ExtracurricularCard(
                  activity: activities[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExtracurricularCard extends StatefulWidget {
  final Map<String, dynamic> activity;

  const _ExtracurricularCard({required this.activity});

  @override
  State<_ExtracurricularCard> createState() => _ExtracurricularCardState();
}

class _ExtracurricularCardState extends State<_ExtracurricularCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered
              ? null
              : Colors.white,
          gradient: _isHovered
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isHovered ? Colors.white : const Color(0xFF667EEA),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.activity['icon'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    color: _isHovered ? const Color(0xFF667EEA) : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.activity['name'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.activity['description'] as String,
              style: TextStyle(
                fontSize: 12,
                color: _isHovered ? Colors.white70 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Incharge: ${widget.activity['incharge'] as String}',
              style: TextStyle(
                fontSize: 11,
                color: _isHovered ? Colors.white70 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RTISection extends StatelessWidget {
  final List<Map<String, dynamic>> rtiRequests;

  const _RTISection({required this.rtiRequests});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📋', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Right to Information Act',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    // RTI page can be added later if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('RTI requests feature coming soon')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...rtiRequests.map((rti) => _RTIItem(
                title: rti['title'] as String,
                requester: rti['requester'] as String,
                status: rti['status'] as String,
                date: rti['date'] as String,
              )),
        ],
      ),
    );
  }
}

class _RTIItem extends StatefulWidget {
  final String title;
  final String requester;
  final String status;
  final String date;

  const _RTIItem({
    required this.title,
    required this.requester,
    required this.status,
    required this.date,
  });

  @override
  State<_RTIItem> createState() => _RTIItemState();
}

class _RTIItemState extends State<_RTIItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? null
              : Colors.white.withValues(alpha: 0.7),
          gradient: _isHovered
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF667EEA),
              ),
              child: const Center(
                child: Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.requester} • ${widget.status} • ${widget.date}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isHovered ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


