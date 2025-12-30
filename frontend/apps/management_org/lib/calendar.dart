import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:core/api/api_service.dart';
import 'main.dart' as app;
import 'dashboard.dart';
import 'widgets/school_profile_dialog.dart';

// ==========================================

// ==========================================
// 1. ROBUST DATA MODEL
// ==========================================

class CalendarEvent {
  final int id;
  final String title;
  final String type;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String description;
  final String? location;
  final String? organizer;
  final bool isRecurring;
  final String? recurrencePattern; // 'daily', 'weekly', 'monthly', 'yearly'

  CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.startTime,
    this.endTime,
    required this.description,
    this.location,
    this.organizer,
    this.isRecurring = false,
    this.recurrencePattern,
  });

  // Helper to format TimeOfDay to String
  String get formattedTime {
    if (startTime == null) return "";
    final start = "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}";
    if (endTime == null) return start;
    final end = "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}";
    return "$start - $end";
  }
}

// ==========================================
// 2. MAIN SCREEN
// ==========================================

class CalendarManagementPage extends StatefulWidget {
  const CalendarManagementPage({super.key});

  @override
  State<CalendarManagementPage> createState() => _CalendarManagementPageState();
}

class _CalendarManagementPageState extends State<CalendarManagementPage> {
  // --- Design Constants ---
  final Color gradientStart = const Color(0xFF667eea);
  final Color gradientEnd = const Color(0xFF764ba2);

  // --- State Variables (Data) ---
  final List<CalendarEvent> _allEvents = [
    CalendarEvent(
      id: 1,
      title: 'Annual Sports Day',
      type: 'Sports',
      date: DateTime(2024, 3, 15),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      description: 'Annual sports day with various athletic events',
      location: 'School Ground',
      organizer: 'Sports Department',
    ),
    CalendarEvent(
      id: 2,
      title: 'Parent-Teacher Meeting',
      type: 'Administrative',
      date: DateTime(2024, 3, 20),
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      description: 'Quarterly parent-teacher meeting for all classes',
      location: 'School Auditorium',
      organizer: 'Administration',
    ),
    CalendarEvent(
      id: 3,
      title: 'Science Fair',
      type: 'Academic',
      date: DateTime(2024, 3, 25),
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 0),
      description: 'Annual science fair showcasing student projects',
      location: 'School Hall',
      organizer: 'Science Department',
    ),
    CalendarEvent(
      id: 4,
      title: 'Cultural Festival',
      type: 'Cultural',
      date: DateTime(2024, 3, 30),
      startTime: const TimeOfDay(hour: 18, minute: 0),
      endTime: const TimeOfDay(hour: 22, minute: 0),
      description: 'Annual cultural festival with performances',
      location: 'School Stage',
      organizer: 'Cultural Committee',
    ),
    CalendarEvent(
      id: 5,
      title: 'Holi Holiday',
      type: 'Holiday',
      date: DateTime(2024, 3, 8),
      description: 'Holi festival holiday',
    ),
  ];

  List<CalendarEvent> _filteredEvents = [];

  // --- Form Controllers (Embedded "Add Event" Form) ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  
  String? _selectedType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  // --- Filter & Sort State ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterType;
  int? _filterMonth;
  String _sortBy = 'date';
  bool _sortAscending = true;

  // --- Calendar View State ---
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _filterEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locController.dispose();
    _orgController.dispose();
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // 3. LOGIC METHODS
  // ==========================================

  void _filterEvents() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final matchesSearch = _searchQuery.isEmpty ||
            event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            event.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _filterType == null || _filterType!.isEmpty || event.type == _filterType;
        final matchesMonth = _filterMonth == null || event.date.month == _filterMonth;
        return matchesSearch && matchesType && matchesMonth;
      }).toList();
      _sortEvents();
    });
  }

  void _sortEvents() {
    _filteredEvents.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date': comparison = a.date.compareTo(b.date); break;
        case 'title': comparison = a.title.compareTo(b.title); break;
        case 'type': comparison = a.type.compareTo(b.type); break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _addEvent(CalendarEvent event) {
    setState(() {
      _allEvents.insert(0, event); // Add to top
      _filterEvents();
    });
  }

  void _updateEvent(CalendarEvent updatedEvent) {
    setState(() {
      final index = _allEvents.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        _allEvents[index] = updatedEvent;
        _filterEvents();
      }
    });
  }

  void _deleteEvent(int id) {
    setState(() {
      _allEvents.removeWhere((e) => e.id == id);
      _filterEvents();
    });
  }

  void _exportData() {
    final csv = StringBuffer();
    csv.writeln('ID,Title,Type,Date,Start Time,End Time,Location,Organizer,Description');
    for (final event in _filteredEvents) {
      csv.writeln(
          '${event.id},${event.title},${event.type},${DateFormat('yyyy-MM-dd').format(event.date)},${event.startTime?.format(context) ?? ""},${event.endTime?.format(context) ?? ""},${event.location ?? ""},${event.organizer ?? ""},"${event.description}"');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${_filteredEvents.length} events to Clipboard (Simulated)'), backgroundColor: Colors.green),
    );
  }

  void _submitEmbeddedForm() {
    if (_formKey.currentState!.validate()) {
      final event = CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        type: _selectedType!,
        date: _selectedDate!,
        startTime: _selectedStartTime,
        endTime: _selectedEndTime,
        description: _descController.text,
        location: _locController.text.isEmpty ? null : _locController.text,
        organizer: _orgController.text.isEmpty ? null : _orgController.text,
      );
      _addEvent(event);
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _locController.clear();
    _orgController.clear();
    _dateController.clear();
    _startController.clear();
    _endController.clear();
    setState(() {
      _selectedType = null;
      _selectedDate = null;
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  // ==========================================
  // 4. UI WIDGETS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6FA), // Main Content Background
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isDesktop)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Menu tapped')),
                                ),
                              ),
                            ),
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildStatsOverview(),
                          const SizedBox(height: 30),
                          
                          // Responsive Layout for Form and Search
                          LayoutBuilder(builder: (context, constraints) {
                            if (constraints.maxWidth > 1000) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _buildAddEventSection()),
                                  const SizedBox(width: 30),
                                  Expanded(flex: 2, child: _buildSearchFilterSection()),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildAddEventSection(),
                                  const SizedBox(height: 30),
                                  _buildSearchFilterSection(),
                                ],
                              );
                            }
                          }),

                          const SizedBox(height: 30),
                          _buildEventsGrid(),
                          const SizedBox(height: 30),
                          _buildCalendarView(),
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
                    isActive: true,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📅 School Calendar", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Manage school events, holidays, and important dates", style: TextStyle(color: Colors.white70)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _exportData,
                icon: const Icon(Icons.download, color: Colors.white),
                tooltip: "Export CSV",
              ),
              const SizedBox(width: 10),
              // School Profile Header with white text for gradient background
              _WhiteSchoolProfileHeader(apiService: ApiService()),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())), 
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text("Back to Dashboard"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final currentMonth = DateTime.now();
    int total = _allEvents.length;
    int thisMonth = _allEvents.where((e) => e.date.month == currentMonth.month && e.date.year == currentMonth.year).length;
    int academic = _allEvents.where((e) => e.type == "Academic").length;
    int sports = _allEvents.where((e) => e.type == "Sports").length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _statCard(total.toString(), "Total Events"),
            _statCard(thisMonth.toString(), "This Month"),
            _statCard(academic.toString(), "Academic"),
            _statCard(sports.toString(), "Sports"),
          ],
        );
      }
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(number, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: gradientStart)),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required String icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // --- The Embedded Add Form (Matches HTML Design) ---
  Widget _buildAddEventSection() {
    return _buildSectionContainer(
      title: "Add New Event",
      icon: "➕",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Event Type'),
                    initialValue: _selectedType,
                    items: ["Academic", "Sports", "Cultural", "Administrative", "Holiday", "Other"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startController,
                    decoration: const InputDecoration(labelText: 'Start Time'),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) {
                        setState(() {
                          _selectedStartTime = picked;
                          _startController.text = picked.format(context);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _endController,
                    decoration: const InputDecoration(labelText: 'End Time'),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) {
                        setState(() {
                          _selectedEndTime = picked;
                          _endController.text = picked.format(context);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', hintText: "Describe the event..."),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                   child: TextFormField(
                    controller: _orgController,
                    decoration: const InputDecoration(labelText: 'Organizer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: _submitEmbeddedForm,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text("Add Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return _buildSectionContainer(
      title: "Search & Filter",
      icon: "🔍",
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Search events...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
              _filterEvents();
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Sort By"),
                  initialValue: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                    DropdownMenuItem(value: 'type', child: Text('Type')),
                  ],
                  onChanged: (v) {
                    setState(() => _sortBy = v!);
                    _sortEvents();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() => _sortAscending = !_sortAscending);
                    _sortEvents();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Filter by Type"),
            initialValue: _filterType,
            items: [
              const DropdownMenuItem(value: null, child: Text("All Types")),
              ...["Academic", "Sports", "Cultural", "Administrative", "Holiday", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            ],
            onChanged: (v) {
              setState(() => _filterType = v);
              _filterEvents();
            },
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: "Filter by Month"),
            initialValue: _filterMonth,
            items: [
               const DropdownMenuItem(value: null, child: Text("All Months")),
              ...List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(DateFormat('MMMM').format(DateTime(2024, index + 1)))))
            ],
            onChanged: (v) {
              setState(() => _filterMonth = v);
              _filterEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid() {
    if (_filteredEvents.isEmpty) {
      return _buildSectionContainer(
        title: "All Events",
        icon: "📅",
        child: const SizedBox(
          height: 100,
          child: Center(child: Text("No events found matching your criteria.", style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    return _buildSectionContainer(
      title: "All Events",
      icon: "📅",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 280, 
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_filteredEvents[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Row(
                children: [
                  _eventTypeBadge(event.type),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (context) => _EventFormDialog(
                            event: event,
                            onSave: (updatedEvent) {
                              _updateEvent(updatedEvent);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      } else if (value == 'delete') {
                        _deleteEvent(event.id);
                      } else if (value == 'view') {
                        showDialog(
                          context: context,
                          builder: (context) => _EventDetailDialog(event: event),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, size: 16), SizedBox(width: 8), Text('View')])),
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          _detailRow("📅 Date:", DateFormat('MMM dd, yyyy').format(event.date)),
          if (event.startTime != null)
            _detailRow("🕐 Time:", event.formattedTime),
          _detailRow("📍 Location:", event.location ?? "Not specified"),
          
          const Spacer(),
          Text(
            "📝 ${event.description}",
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _eventTypeBadge(String type) {
    Color bg;
    Color text;
    switch (type) {
      case 'Academic': bg = const Color(0xFFE3F2FD); text = const Color(0xFF1976D2); break;
      case 'Sports': bg = const Color(0xFFF3E5F5); text = const Color(0xFF7B1FA2); break;
      case 'Cultural': bg = const Color(0xFFFFF3E0); text = const Color(0xFFF57C00); break;
      case 'Administrative': bg = const Color(0xFFE8F5E8); text = const Color(0xFF388E3C); break;
      case 'Holiday': bg = const Color(0xFFFFEBEE); text = const Color(0xFFD32F2F); break;
      default: bg = Colors.grey.shade100; text = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(type, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 85, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF333333), fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final int offset = firstDay.weekday == 7 ? 0 : firstDay.weekday; 

    return _buildSectionContainer(
      title: "Calendar View",
      icon: "📆",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(backgroundColor: gradientStart, foregroundColor: Colors.white),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                icon: const Icon(Icons.arrow_forward),
                style: IconButton.styleFrom(backgroundColor: gradientStart, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 13),
          // Days Header
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: Colors.grey.shade200)),
                child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )).toList(),
          ),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 2.2),
            itemCount: daysInMonth + offset,
            itemBuilder: (context, index) {
              if (index < offset) return Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200)));
              
              final day = index - offset + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              
              // Find events for this day
              final dayEvents = _allEvents.where((e) => DateUtils.isSameDay(e.date, date)).toList();
              final hasEvents = dayEvents.isNotEmpty;

              return InkWell(
                onTap: () {
                  if (hasEvents) {
                    showDialog(
                       context: context,
                       builder: (ctx) => _DayEventsDialog(date: date, events: dayEvents),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? gradientStart : (hasEvents ? const Color(0xFFE3F2FD) : Colors.white),
                    border: Border.all(color: hasEvents ? gradientStart : Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$day",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isToday ? Colors.white : Colors.black,
                        ),
                      ),
                      if (hasEvents)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "${dayEvents.length} event(s)",
                            style: TextStyle(fontSize: 9, color: isToday ? Colors.white70 : Colors.grey[600]),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

// ==========================================
// SIDEBAR NAVIGATION ITEM WITH HOVER
// ==========================================

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

// ==========================================
// 5. DIALOG WIDGETS
// ==========================================

class _EventFormDialog extends StatefulWidget {
  final CalendarEvent? event;
  final Function(CalendarEvent) onSave;

  const _EventFormDialog({
    this.event,
    required this.onSave,
  });

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _organizerController;

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _type = '';
  bool _isRecurring = false;
  String _recurrencePattern = 'weekly';

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _organizerController = TextEditingController(text: event?.organizer ?? '');
    _eventDate = event?.date ?? DateTime.now();
    _startTime = event?.startTime;
    _endTime = event?.endTime;
    _type = event?.type ?? '';
    _isRecurring = event?.isRecurring ?? false;
    _recurrencePattern = event?.recurrencePattern ?? 'weekly';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(widget.event == null ? 'Add Event' : 'Edit Event', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _type.isEmpty ? null : _type,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: ["Academic", "Sports", "Cultural", "Administrative", "Holiday", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _type = v!),
                validator: (v) => v == null ? 'Required' : null,
              ),
               const SizedBox(height: 15),
               // Date Picker
               ListTile(
                 title: Text(_eventDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_eventDate!)),
                 trailing: const Icon(Icons.calendar_today),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade300)),
                 tileColor: Colors.white,
                 onTap: () async {
                   final picked = await showDatePicker(context: context, initialDate: _eventDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                   if (picked != null) setState(() => _eventDate = picked);
                 },
               ),
               const SizedBox(height: 10),
               Row(children: [
                 Expanded(
                   child: ListTile(
                     title: Text(_startTime == null ? 'Start Time' : _startTime!.format(context)),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade300)),
                     tileColor: Colors.white,
                     onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if(t!=null) setState(() => _startTime = t);
                     },
                   ),
                 ),
                 const SizedBox(width: 10),
                 Expanded(
                   child: ListTile(
                     title: Text(_endTime == null ? 'End Time' : _endTime!.format(context)),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade300)),
                     tileColor: Colors.white,
                     onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if(t!=null) setState(() => _endTime = t);
                     },
                   ),
                 ),
               ]),
               const SizedBox(height: 10),
               TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
               const SizedBox(height: 10),
               CheckboxListTile(
                 title: const Text("Recurring Event"),
                 value: _isRecurring,
                 onChanged: (v) => setState(() => _isRecurring = v!),
               ),
               if (_isRecurring)
                  DropdownButtonFormField<String>(
                    initialValue: _recurrencePattern,
                    decoration: const InputDecoration(labelText: "Recurrence Pattern"),
                    items: ['daily', 'weekly', 'monthly', 'yearly'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                    onChanged: (v) => setState(() => _recurrencePattern = v!),
                  ),
               const SizedBox(height: 20),
               SizedBox(
                 height: 50,
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF667eea), 
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                   ),
                   onPressed: () {
                     if (_formKey.currentState!.validate()) {
                       final event = CalendarEvent(
                         id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch,
                         title: _titleController.text,
                         type: _type,
                         date: _eventDate!,
                         startTime: _startTime,
                         endTime: _endTime,
                         description: _descriptionController.text,
                         location: _locationController.text,
                         organizer: _organizerController.text,
                         isRecurring: _isRecurring,
                         recurrencePattern: _isRecurring ? _recurrencePattern : null,
                       );
                       widget.onSave(event);
                     }
                   },
                   child: const Text("Save Event", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDetailDialog extends StatelessWidget {
  final CalendarEvent event;
  const _EventDetailDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(event.type, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            _row("Date", DateFormat('yyyy-MM-dd').format(event.date)),
            if(event.startTime != null) _row("Time", event.formattedTime),
            _row("Location", event.location ?? 'N/A'),
            _row("Organizer", event.organizer ?? 'N/A'),
            if(event.isRecurring) _row("Recurrence", event.recurrencePattern!.toUpperCase()),
            const SizedBox(height: 10),
            const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(event.description),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DayEventsDialog extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  const _DayEventsDialog({required this.date, required this.events});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Events on ${DateFormat('MMM dd').format(date)}"),
      content: SizedBox(
        width: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            return ListTile(
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${e.type} • ${e.formattedTime}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (ctx) => _EventDetailDialog(event: e));
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
      ],
    );
  }
}

// Custom school profile header with white text for gradient background
class _WhiteSchoolProfileHeader extends StatefulWidget {
  final ApiService apiService;

  const _WhiteSchoolProfileHeader({required this.apiService});

  @override
  State<_WhiteSchoolProfileHeader> createState() => _WhiteSchoolProfileHeaderState();
}

class _WhiteSchoolProfileHeaderState extends State<_WhiteSchoolProfileHeader> {
  String? _schoolName;
  String? _schoolId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    try {
      await widget.apiService.initialize();
      final response = await widget.apiService.get('/management-admin/schools/current/');
      
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map) {
          final schoolData = data['data'] ?? data;
          if (schoolData is Map) {
            setState(() {
              _schoolName = schoolData['name']?.toString() ?? 'School';
              _schoolId = schoolData['school_id']?.toString() ?? 
                         schoolData['id']?.toString();
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      setState(() {
        _schoolName = 'School';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _schoolName = 'School';
        _isLoading = false;
      });
    }
  }

  void _showSchoolProfile() {
    if (_schoolId != null) {
      showDialog(
        context: context,
        builder: (context) => SchoolProfileDialog(
          schoolId: _schoolId!,
          apiService: widget.apiService,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _schoolName?.isNotEmpty == true 
        ? _schoolName![0].toUpperCase() 
        : 'S';
    
    return InkWell(
      onTap: _showSchoolProfile,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _isLoading
                ? const SizedBox(
                    width: 100,
                    height: 16,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _schoolName ?? 'School',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'School Profile',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
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