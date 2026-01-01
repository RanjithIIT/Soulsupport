import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'main.dart' as app;
import 'dashboard.dart';
import 'widgets/school_profile_header.dart';

class Activity {
  final int id;
  final String name;
  final String category;
  final String instructor;
  final int participants;
  final String schedule;
  final String location;
  final String status;
  final String description;

  const Activity({
    required this.id,
    required this.name,
    required this.category,
    required this.instructor,
    required this.participants,
    required this.schedule,
    required this.location,
    required this.status,
    required this.description,
  });
}

class ActivitiesManagementPage extends StatefulWidget {
  const ActivitiesManagementPage({super.key});

  @override
  State<ActivitiesManagementPage> createState() =>
      _ActivitiesManagementPageState();
}

class _ActivitiesManagementPageState extends State<ActivitiesManagementPage> {
  final List<Activity> _activities = [
    const Activity(
      id: 1,
      name: 'Basketball Team',
      category: 'Sports',
      instructor: 'Coach Johnson',
      participants: 15,
      schedule: 'Mon, Wed, Fri 3:00 PM',
      location: 'Gymnasium',
      status: 'Active',
      description: 'Competitive basketball team for grades 9-12',
    ),
    const Activity(
      id: 2,
      name: 'Science Club',
      category: 'Academic',
      instructor: 'Dr. Sarah Chen',
      participants: 20,
      schedule: 'Tue, Thu 4:00 PM',
      location: 'Science Lab',
      status: 'Active',
      description: 'Advanced science experiments and projects',
    ),
    const Activity(
      id: 3,
      name: 'Music Band',
      category: 'Arts',
      instructor: 'Ms. Emily White',
      participants: 12,
      schedule: 'Mon, Wed 2:30 PM',
      location: 'Music Room',
      status: 'Active',
      description: 'School band performing various genres',
    ),
    const Activity(
      id: 4,
      name: 'Debate Club',
      category: 'Academic',
      instructor: 'Mr. David Brown',
      participants: 18,
      schedule: 'Fri 3:30 PM',
      location: 'Library',
      status: 'Active',
      description: 'Competitive debate and public speaking',
    ),
    const Activity(
      id: 5,
      name: 'Chess Club',
      category: 'Games',
      instructor: 'Prof. Michael Wilson',
      participants: 25,
      schedule: 'Tue, Thu 3:00 PM',
      location: 'Classroom 201',
      status: 'Active',
      description: 'Strategic thinking and chess tournaments',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  late List<Activity> _visibleActivities;

  @override
  void initState() {
    super.initState();
    _visibleActivities = List<Activity>.from(_activities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalActivities => _activities.length;
  int get _activeActivities =>
      _activities.where((activity) => activity.status == 'Active').length;
  int get _totalParticipants => _activities.fold(
        0,
        (sum, activity) => sum + activity.participants,
      );
  int get _activityCategories =>
      _activities.map((activity) => activity.category).toSet().length;

  void _filterActivities(String query) {
    setState(() {
      if (query.isEmpty) {
        _visibleActivities = List<Activity>.from(_activities);
      } else {
        final lower = query.toLowerCase();
        _visibleActivities = _activities.where((activity) {
          return activity.name.toLowerCase().contains(lower) ||
              activity.category.toLowerCase().contains(lower) ||
              activity.instructor.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _viewActivity(Activity activity) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(activity.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.description),
              const SizedBox(height: 8),
              Text('Instructor: ${activity.instructor}'),
              Text('Schedule: ${activity.schedule}'),
              Text('Location: ${activity.location}'),
              Text('Participants: ${activity.participants}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editActivity(Activity activity) {
    Navigator.pushNamed(context, '/edit-activity', arguments: activity.id);
  }

  void _deleteActivity(Activity activity) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Delete ${activity.name}?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _activities.removeWhere((a) => a.id == activity.id);
                });
                _filterActivities(_searchController.text);
                Navigator.of(context).pop();
                _showSnack('Activity deleted successfully!');
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

  void _addActivity() {
    // Navigate to add activity page (can be created later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add activity feature coming soon')),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF5F6FA),
                      child: _buildMainContent(isMobile: true),
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: _buildSidebar()),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F6FA),
                    child: _buildMainContent(isMobile: false),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Safe navigation helper for sidebar
    void navigateToRoute(String route) {
      final navigator = app.SchoolManagementApp.navigatorKey.currentState;
      if (navigator != null) {
        if (navigator.canPop() || route != '/dashboard') {
          navigator.pushReplacementNamed(route);
        } else {
          navigator.pushNamed(route);
        }
      }
    }

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
                    isActive: false,
                    onTap: () => navigateToRoute('/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () => navigateToRoute('/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () => navigateToRoute('/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () => navigateToRoute('/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    isActive: true,
                    onTap: () => navigateToRoute('/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    onTap: () => navigateToRoute('/events'),
                  ),
                  _NavItem(
                    icon: '📆',
                    title: 'Calendar',
                    onTap: () => navigateToRoute('/calendar'),
                  ),
                  _NavItem(
                    icon: '🔔',
                    title: 'Notifications',
                    onTap: () => navigateToRoute('/notifications'),
                  ),
                  _NavItem(
                    icon: '🛣️',
                    title: 'Bus Routes',
                    onTap: () => navigateToRoute('/bus-routes'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 15),
                          Text(
                            'Activities Management',
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Manage school activities, clubs, sports, and extracurricular programs',
                        style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                      ),
                    ],
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
                  Expanded(child: SchoolProfileHeader(apiService: ApiService(), isMobile: true)),
                  const Icon(Icons.arrow_back_ios_new, size: 16),
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
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _StatCard(
                    label: 'Total Activities',
                    value: '$_totalActivities',
                    icon: '🎯',
                    color: const Color(0xFF667EEA),
                  ),
                  _StatCard(
                    label: 'Active Activities',
                    value: '$_activeActivities',
                    icon: '🏃‍♂️',
                    color: Colors.green,
                  ),
                  _StatCard(
                    label: 'Total Participants',
                    value: '$_totalParticipants',
                    icon: '👥',
                    color: Colors.orange,
                  ),
                  _StatCard(
                    label: 'Activity Categories',
                    value: '$_activityCategories',
                    icon: '🏆',
                    color: Colors.blue,
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
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE1E5E9), width: 2),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterActivities,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Search activities by name, category, or instructor...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: isMobile ? 0 : 20,
                  height: isMobile ? 15 : 0,
                ),
                InkWell(
                  onTap: _addActivity,
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
                          'Add New Activity',
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
              const minCardWidth = 340.0;
              final rawCount = (constraints.maxWidth / minCardWidth).floor();
              final columns = rawCount.clamp(1, 4);
              final totalSpacing = 20 * (columns - 1);
              final cardWidth =
                  (constraints.maxWidth - totalSpacing) / columns.toDouble();

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _visibleActivities
                    .map(
                      (activity) => SizedBox(
                        width: cardWidth,
                        child: _buildActivityCard(activity),
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

  Widget _buildActivityCard(Activity activity) {
    return _ActivityCardWithHover(
      activity: activity,
      onView: () => _viewActivity(activity),
      onEdit: () => _editActivity(activity),
      onDelete: () => _deleteActivity(activity),
    );
  }

  Widget _buildUserInfo() {
    return SchoolProfileHeader(apiService: ApiService());
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
            Icon(Icons.arrow_back, color: Colors.white, size: 16),
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

class _ActivityCardWithHover extends StatefulWidget {
  final Activity activity;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCardWithHover({
    required this.activity,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ActivityCardWithHover> createState() => _ActivityCardWithHoverState();
}

class _ActivityCardWithHoverState extends State<_ActivityCardWithHover> {
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
                    child: const Center(
                      child: Text(
                        '🎯',
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.name,
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
                          '${widget.activity.category} • Instructor: ${widget.activity.instructor}',
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
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Participants',
                          value: '${widget.activity.participants}',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Schedule',
                          value: widget.activity.schedule,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Location',
                          value: widget.activity.location,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Status',
                          value: widget.activity.status,
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
                    child: _CardButton(
                      label: 'View Details',
                      colors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      textColor: Colors.white,
                      onTap: widget.onView,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CardButton(
                      label: 'Edit',
                      colors: const [Color(0xFFFFD93D), Color(0xFFFCC419)],
                      textColor: const Color(0xFF333333),
                      onTap: widget.onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CardButton(
                      label: 'Delete',
                      colors: const [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                      textColor: Colors.white,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 40, color: color)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
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
                fontWeight: FontWeight.w600,
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

class _CardButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color textColor;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.colors,
    required this.textColor,
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

