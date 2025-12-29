import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'main.dart' as app;
import 'dashboard.dart';
import 'widgets/school_profile_header.dart';

class Event {
  final int id;
  final String name;
  final String category;
  final String date;
  final String time;
  final String location;
  final String organizer;
  final int participants;
  final String status;
  final String description;

  const Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.participants,
    required this.status,
    required this.description,
  });
}

class EventsManagementPage extends StatefulWidget {
  const EventsManagementPage({super.key});

  @override
  State<EventsManagementPage> createState() => _EventsManagementPageState();
}

class _EventsManagementPageState extends State<EventsManagementPage> {
  final List<Event> _events = [
    const Event(
      id: 1,
      name: 'Annual Sports Day',
      category: 'Sports',
      date: '2024-03-15',
      time: '09:00 AM - 04:00 PM',
      location: 'School Ground',
      organizer: 'Sports Department',
      participants: 450,
      status: 'Upcoming',
      description: 'Annual sports competition with various athletic events',
    ),
    const Event(
      id: 2,
      name: 'Science Fair',
      category: 'Academic',
      date: '2024-03-20',
      time: '10:00 AM - 02:00 PM',
      location: 'Science Lab & Auditorium',
      organizer: 'Science Department',
      participants: 200,
      status: 'Upcoming',
      description: 'Student science projects and experiments exhibition',
    ),
    const Event(
      id: 3,
      name: 'Parent-Teacher Meeting',
      category: 'Administrative',
      date: '2024-03-10',
      time: '02:00 PM - 05:00 PM',
      location: 'Classrooms',
      organizer: 'School Administration',
      participants: 300,
      status: 'Completed',
      description: 'Quarterly parent-teacher conference',
    ),
    const Event(
      id: 4,
      name: 'Music Concert',
      category: 'Cultural',
      date: '2024-03-25',
      time: '06:00 PM - 08:00 PM',
      location: 'Auditorium',
      organizer: 'Music Department',
      participants: 150,
      status: 'Upcoming',
      description: 'Annual music performance by school bands and choirs',
    ),
    const Event(
      id: 5,
      name: 'Career Fair',
      category: 'Career',
      date: '2024-03-30',
      time: '11:00 AM - 03:00 PM',
      location: 'Gymnasium',
      organizer: 'Career Counseling',
      participants: 400,
      status: 'Upcoming',
      description: 'Career guidance and college information session',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  late List<Event> _visibleEvents;

  @override
  void initState() {
    super.initState();
    _visibleEvents = List<Event>.from(_events);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalEvents => _events.length;
  int get _upcomingEvents =>
      _events.where((e) => e.status == 'Upcoming').length;
  int get _completedEvents =>
      _events.where((e) => e.status == 'Completed').length;
  int get _eventCategories => _events.map((e) => e.category).toSet().length;

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        _visibleEvents = List<Event>.from(_events);
      } else {
        final lower = query.toLowerCase();
        _visibleEvents = _events.where((event) {
          return event.name.toLowerCase().contains(lower) ||
              event.category.toLowerCase().contains(lower) ||
              event.date.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _viewEvent(Event event) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${event.description}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text('Date: ${event.date}'),
                  ],
                ),
                Text('Time: ${event.time}'),
                Text('Location: ${event.location}'),
                Text('Organizer: ${event.organizer}'),
                Text('Participants: ${event.participants}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(Event event) {
    // Navigate to edit event page (can be created later)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit event feature coming soon for ${event.name}')),
    );
  }

  void _deleteEvent(Event event) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Delete ${event.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _events.removeWhere((e) => e.id == event.id);
                });
                _filterEvents(_searchController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully!')),
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

  void _addEvent() {
    // Navigate to add event page (can be created later)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add event feature coming soon')),
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
    void _navigateToRoute(String route) {
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
                    onTap: () => _navigateToRoute('/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () => _navigateToRoute('/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () => _navigateToRoute('/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () => _navigateToRoute('/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    onTap: () => _navigateToRoute('/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    isActive: true,
                    onTap: () => _navigateToRoute('/events'),
                  ),
                  _NavItem(
                    icon: '📆',
                    title: 'Calendar',
                    onTap: () => _navigateToRoute('/calendar'),
                  ),
                  _NavItem(
                    icon: '🔔',
                    title: 'Notifications',
                    onTap: () => _navigateToRoute('/notifications'),
                  ),
                  _NavItem(
                    icon: '🛣️',
                    title: 'Bus Routes',
                    onTap: () => _navigateToRoute('/bus-routes'),
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
                  child: Text(
                    'Events Management',
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
                  Expanded(child: SchoolProfileHeader(apiService: ApiService(), isMobile: true)),
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
                    Text('📅', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 15),
                    Text(
                      'Events Management',
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
                  'Manage school events, calendar, and scheduling',
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
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _StatCard(label: 'Total Events', value: '$_totalEvents'),
                  _StatCard(
                    label: 'Upcoming Events',
                    value: '$_upcomingEvents',
                  ),
                  _StatCard(
                    label: 'Completed Events',
                    value: '$_completedEvents',
                  ),
                  _StatCard(
                    label: 'Event Categories',
                    value: '$_eventCategories',
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
                      border: Border.all(
                        color: const Color(0xFFE1E5E9),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterEvents,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search events by name, category, or date...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: isMobile ? 0 : 20,
                  height: isMobile ? 15 : 0,
                ),
                InkWell(
                  onTap: _addEvent,
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
                          'Add New Event',
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
              final spacing = 20.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _visibleEvents.map((event) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: cardWidth,
                    ),
                    child: _buildEventCard(event),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return _EventCardWithHover(
      event: event,
      onView: () => _viewEvent(event),
      onEdit: () => _editEvent(event),
      onDelete: () => _deleteEvent(event),
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

class _EventCardWithHover extends StatefulWidget {
  final Event event;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventCardWithHover({
    required this.event,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_EventCardWithHover> createState() => _EventCardWithHoverState();
}

class _EventCardWithHoverState extends State<_EventCardWithHover> {
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.event.category,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                          title: 'Time',
                          value: widget.event.time,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Location',
                          value: widget.event.location,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Organizer',
                          value: widget.event.organizer,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _DetailItem(
                          title: 'Status',
                          value: widget.event.status,
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

