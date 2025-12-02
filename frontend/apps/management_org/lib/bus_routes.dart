import 'package:flutter/material.dart';
import 'dashboard.dart';

// --- Data Models ---

class RouteStop {
  final String name;
  final String time;
  final int students;

  RouteStop({
    required this.name,
    required this.time,
    required this.students,
  });

  RouteStop copyWith({
    String? name,
    String? time,
    int? students,
  }) {
    return RouteStop(
      name: name ?? this.name,
      time: time ?? this.time,
      students: students ?? this.students,
    );
  }
}

class BusRoute {
  final int id;
  final String name;
  final String number;
  final String driverName;
  final String? driverPhone;
  final String busNumber;
  final String startLocation;
  final String endLocation;
  final double? distance;
  final int? estimatedTime;
  final String status; // 'active', 'inactive', 'maintenance'
  final List<RouteStop> stops;

  BusRoute({
    required this.id,
    required this.name,
    required this.number,
    required this.driverName,
    this.driverPhone,
    required this.busNumber,
    required this.startLocation,
    required this.endLocation,
    this.distance,
    this.estimatedTime,
    required this.status,
    required this.stops,
  });

  BusRoute copyWith({
    int? id,
    String? name,
    String? number,
    String? driverName,
    String? driverPhone,
    String? busNumber,
    String? startLocation,
    String? endLocation,
    double? distance,
    int? estimatedTime,
    String? status,
    List<RouteStop>? stops,
  }) {
    return BusRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      busNumber: busNumber ?? this.busNumber,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      stops: stops ?? this.stops,
    );
  }
}

// --- Main Application Widget ---

void main() {
  runApp(const BusRoutesApp());
}

class BusRoutesApp extends StatelessWidget {
  const BusRoutesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Routes Management - SMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF667eea),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define text theme colors globally if needed
      ),
      home: const BusRoutesManagementPage(),
    );
  }
}

// --- Main Page State and Logic ---

class BusRoutesManagementPage extends StatefulWidget {
  const BusRoutesManagementPage({super.key});

  @override
  State<BusRoutesManagementPage> createState() =>
      _BusRoutesManagementPageState();
}

class _BusRoutesManagementPageState extends State<BusRoutesManagementPage> {
  // Enhanced Mock Data including new routes from the second block
  final List<BusRoute> _allRoutes = [
    BusRoute(
      id: 1,
      name: 'Downtown Express',
      number: 'R001',
      driverName: 'Mr. John Smith',
      driverPhone: '+1-555-0101',
      busNumber: 'BUS-001',
      startLocation: 'Central Station',
      endLocation: 'School Campus',
      distance: 12.5,
      estimatedTime: 45,
      status: 'active',
      stops: [
        RouteStop(name: 'Central Station', time: '07:00 AM', students: 15),
        RouteStop(name: 'Downtown Mall', time: '07:15 AM', students: 8),
        RouteStop(name: 'Residential Area A', time: '07:30 AM', students: 12),
        RouteStop(name: 'School Gate', time: '08:00 AM', students: 35),
      ],
    ),
    BusRoute(
      id: 2,
      name: 'North Campus Route',
      number: 'R002',
      driverName: 'Ms. Sarah Johnson',
      driverPhone: '+1-555-0102',
      busNumber: 'BUS-002',
      startLocation: 'North Terminal',
      endLocation: 'School Campus',
      distance: 8.2,
      estimatedTime: 30,
      status: 'active',
      stops: [
        RouteStop(name: 'North Terminal', time: '07:10 AM', students: 10),
        RouteStop(name: 'Shopping Center', time: '07:25 AM', students: 6),
        RouteStop(name: 'Housing Complex', time: '07:40 AM', students: 14),
        RouteStop(name: 'School Gate', time: '08:05 AM', students: 30),
      ],
    ),
    BusRoute(
      id: 3,
      name: 'East Side Route',
      number: 'R003',
      driverName: 'Mr. David Wilson',
      driverPhone: '+1-555-0103',
      busNumber: 'BUS-003',
      startLocation: 'East Station',
      endLocation: 'School Campus',
      distance: 15.8,
      estimatedTime: 55,
      status: 'maintenance',
      stops: [
        RouteStop(name: 'East Station', time: '06:45 AM', students: 12),
        RouteStop(name: 'Industrial Area', time: '07:00 AM', students: 5),
        RouteStop(name: 'Suburban Homes', time: '07:20 AM', students: 18),
        RouteStop(name: 'School Gate', time: '08:10 AM', students: 35),
      ],
    ),
    BusRoute(
      id: 4,
      name: 'West Campus Express',
      number: 'R004',
      driverName: 'Ms. Emily Brown',
      driverPhone: '+1-555-0104',
      busNumber: 'BUS-004',
      startLocation: 'West Terminal',
      endLocation: 'School Campus',
      distance: 10.3,
      estimatedTime: 35,
      status: 'active',
      stops: [
        RouteStop(name: 'West Terminal', time: '07:05 AM', students: 8),
        RouteStop(name: 'Business District', time: '07:20 AM', students: 4),
        RouteStop(name: 'Residential Area B', time: '07:35 AM', students: 16),
        RouteStop(name: 'School Gate', time: '08:00 AM', students: 28),
      ],
    ),
    // Additional Routes from the second block
    BusRoute(
      id: 5,
      name: 'South Park Route',
      number: 'R005',
      driverName: 'Mr. Robert Davis',
      driverPhone: '+1-555-0105',
      busNumber: 'BUS-005',
      startLocation: 'South Park',
      endLocation: 'School Campus',
      distance: 9.5,
      estimatedTime: 40,
      status: 'active',
      stops: [
        RouteStop(name: 'South Park', time: '07:00 AM', students: 9),
        RouteStop(name: 'Community Center', time: '07:15 AM', students: 7),
        RouteStop(name: 'Residential Area C', time: '07:30 AM', students: 11),
        RouteStop(name: 'School Gate', time: '08:00 AM', students: 27),
      ],
    ),
    BusRoute(
      id: 6,
      name: 'City Center Route',
      number: 'R006',
      driverName: 'Ms. Lisa Anderson',
      driverPhone: '+1-555-0106',
      busNumber: 'BUS-006',
      startLocation: 'City Center',
      endLocation: 'School Campus',
      distance: 11.2,
      estimatedTime: 42,
      status: 'inactive',
      stops: [
        RouteStop(name: 'City Center', time: '07:00 AM', students: 12),
        RouteStop(name: 'Main Street', time: '07:18 AM', students: 6),
        RouteStop(name: 'Park Avenue', time: '07:32 AM', students: 10),
        RouteStop(name: 'School Gate', time: '08:05 AM', students: 22),
      ],
    ),
  ];

  List<BusRoute> _filteredRoutes = [];
  String _searchQuery = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _filteredRoutes = _allRoutes;
  }

  // --- State Management Methods ---

  void _filterRoutes() {
    setState(() {
      _filteredRoutes = _allRoutes.where((route) {
        final matchesSearch = _searchQuery.isEmpty ||
            route.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            route.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            route.driverName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            route.busNumber
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesStatus =
            _statusFilter.isEmpty || route.status == _statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Map<String, int> _getStats() {
    final activeRoutes =
        _allRoutes.where((r) => r.status == 'active').length;
    final totalStops =
        _allRoutes.fold(0, (sum, route) => sum + route.stops.length);
    final totalStudents = _allRoutes.fold(0, (total, route) {
      return total +
          route.stops.fold(0, (stopTotal, stop) => stopTotal + stop.students);
    });

    return {
      'totalRoutes': _allRoutes.length,
      'activeRoutes': activeRoutes,
      'totalStops': totalStops,
      'totalStudents': totalStudents,
    };
  }

  void _addRoute(BusRoute route) {
    setState(() {
      // Find the next highest ID for persistent storage simulation
      final newId = (_allRoutes.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1);
      _allRoutes.insert(0, route.copyWith(id: newId));
      _filterRoutes();
    });
  }

  void _updateRoute(BusRoute updatedRoute) {
    setState(() {
      final index =
          _allRoutes.indexWhere((r) => r.id == updatedRoute.id);
      if (index != -1) {
        _allRoutes[index] = updatedRoute;
        _filterRoutes();
      }
    });
  }

  void _deleteRoute(int id) {
    setState(() {
      _allRoutes.removeWhere((r) => r.id == id);
      _filterRoutes();
    });
  }
  
  void _exportData() {
    final csv = StringBuffer();
    csv.writeln(
        'ID,Route Name,Route Number,Driver,Bus Number,Start Location,End Location,Distance,Estimated Time,Status,Total Stops,Total Students');
    for (final route in _filteredRoutes) {
      final totalStudents = route.stops.fold(
          0, (sum, stop) => sum + stop.students);
      csv.writeln(
          '${route.id},${route.name},${route.number},${route.driverName},${route.busNumber},${route.startLocation},${route.endLocation},${route.distance ?? 'N/A'},${route.estimatedTime ?? 'N/A'},${route.status},${route.stops.length},$totalStudents');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Export ready! ${_filteredRoutes.length} records prepared.'),
        action: SnackBarAction(
          label: 'Copy CSV',
          onPressed: () {
            // In a real app, this data would be copied to clipboard or saved to a file.
          },
        ),
      ),
    );
  }

  // --- Dialog Methods (for form submission) ---

  void _showAddRouteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RouteFormDialog(
        onSave: (route) {
          _addRoute(route);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route added successfully!')),
          );
        },
      ),
    );
  }

  void _showEditRouteDialog(BuildContext context, BusRoute route) {
    showDialog(
      context: context,
      builder: (context) => _RouteFormDialog(
        route: route,
        onSave: (updatedRoute) {
          _updateRoute(updatedRoute);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route updated successfully!')),
          );
        },
      ),
    );
  }
  
  void _viewRoute(BuildContext context, BusRoute route) {
    showDialog(
      context: context,
      builder: (context) => _RouteDetailDialog(route: route),
    );
  }

  // --- Build Method (Layout) ---

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: isDesktop
            ? Row(
                children: [
                  const _Sidebar(),
                  Expanded(child: _MainContent(
                    stats: stats,
                    gradient: gradient,
                    filteredRoutes: _filteredRoutes,
                    onSearchChanged: (query) {
                      _searchQuery = query;
                      _filterRoutes();
                    },
                    onStatusFilterChanged: (status) {
                      _statusFilter = status;
                      _filterRoutes();
                    },
                    onAddRoute: () => _showAddRouteDialog(context),
                    onExportData: _exportData,
                    onViewRoute: _viewRoute,
                    onEditRoute: (route) => _showEditRouteDialog(context, route),
                    onDeleteRoute: _deleteRoute,
                  )),
                ],
              )
            : Column(
                children: [
                   _Header(gradient: gradient, isMobile: true), // Simplified mobile header
                   _StatsRow(stats: stats), // Simplified mobile stats view
                  Expanded(child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _ActionsBar(
                            onSearchChanged: (query) {
                              _searchQuery = query;
                              _filterRoutes();
                            },
                            onStatusFilterChanged: (status) {
                              _statusFilter = status;
                              _filterRoutes();
                            },
                            onAddRoute: () => _showAddRouteDialog(context),
                            onExportData: _exportData,
                          ),
                          const SizedBox(height: 20),
                          _RoutesGrid(
                            routes: _filteredRoutes,
                            onView: _viewRoute,
                            onEdit: (route) => _showEditRouteDialog(context, route),
                            onDelete: _deleteRoute,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
      ),
    );
  }
}

// --- Sidebar Widget ---

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(2, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Text(
                  '🏫 SMS',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'School Management System',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Nav Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _NavItem(icon: '📊', title: 'Dashboard', onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')),
                _NavItem(icon: '👨‍🏫', title: 'Teachers', onTap: () => Navigator.pushReplacementNamed(context, '/teachers')),
                _NavItem(icon: '👥', title: 'Students', onTap: () => Navigator.pushReplacementNamed(context, '/students')),
                _NavItem(icon: '🚌', title: 'Buses', onTap: () => Navigator.pushReplacementNamed(context, '/buses')),
                const _NavItem(icon: '🛣️', title: 'Bus Routes', isActive: true), 
                _NavItem(icon: '🎯', title: 'Activities', onTap: () => Navigator.pushReplacementNamed(context, '/activities')),
                _NavItem(icon: '📅', title: 'Events', onTap: () => Navigator.pushReplacementNamed(context, '/events')),
                _NavItem(icon: '🔔', title: 'Notifications', onTap: () => Navigator.pushReplacementNamed(context, '/notifications')),
              ],
            ),
          ),
        ],
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
    final color = isActive ? Colors.white : const Color(0xFF333333);
    final background = isActive
        ? const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xB3FFFFFF), Color(0xB3FFFFFF)]); 

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              gradient: background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                          color: Color(0x1A667eea),
                          blurRadius: 10,
                          offset: Offset(0, 5))
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 18, color: color)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

// --- Main Content Widget (Desktop View) ---

class _MainContent extends StatelessWidget {
  final Map<String, int> stats;
  final LinearGradient gradient;
  final List<BusRoute> filteredRoutes;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onAddRoute;
  final VoidCallback onExportData;
  final Function(BuildContext, BusRoute) onViewRoute;
  final Function(BusRoute) onEditRoute;
  final Function(int) onDeleteRoute;


  const _MainContent({
    required this.stats,
    required this.gradient,
    required this.filteredRoutes,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onAddRoute,
    required this.onExportData,
    required this.onViewRoute,
    required this.onEditRoute,
    required this.onDeleteRoute,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(gradient: gradient),
            const SizedBox(height: 30),
            _StatsRow(stats: stats),
            const SizedBox(height: 30),
            _ActionsBar(
              onSearchChanged: onSearchChanged,
              onStatusFilterChanged: onStatusFilterChanged,
              onAddRoute: onAddRoute,
              onExportData: onExportData,
            ),
            const SizedBox(height: 30),
            _RoutesGrid(
              routes: filteredRoutes,
              onView: onViewRoute,
              onEdit: onEditRoute,
              onDelete: onDeleteRoute,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Header Widget ---

class _Header extends StatelessWidget {
  final LinearGradient gradient;
  final bool isMobile;
  const _Header({required this.gradient, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bus Routes Management',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          Wrap(
            spacing: 15,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isMobile)
                const _UserInfo(),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
                icon: const Text('←', style: TextStyle(fontSize: 18)),
                label: const Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF6c757d), 
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 22.5,
          backgroundColor: Color(0xFF667eea),
          child: Text('M',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Management User',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('School Manager', style: TextStyle(color: Color(0xFF666666))),
          ],
        ),
      ],
    );
  }
}

// --- Stats Row Widget ---

class _StatsRow extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.5, // Adjusted for card content
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
                number: stats['totalRoutes']!.toString(), label: 'Total Routes',
                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])),
            _StatCard(
                number: stats['activeRoutes']!.toString(), label: 'Active Routes',
                gradient: const LinearGradient(colors: [Color(0xFF51cf66), Color(0xFF40c057)])),
            _StatCard(number: stats['totalStops']!.toString(), label: 'Total Stops',
                gradient: const LinearGradient(colors: [Color(0xFFffd93d), Color(0xFFfcc419)])),
            _StatCard(
                number: stats['totalStudents']!.toString(), label: 'Students Transported',
                gradient: const LinearGradient(colors: [Color(0xFF42a5f5), Color(0xFF1976d2)])),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final LinearGradient gradient;

  const _StatCard({required this.number, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white, // Color is masked by ShaderMask
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Actions Bar Widget ---

class _ActionsBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onAddRoute;
  final VoidCallback onExportData;

  const _ActionsBar({
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onAddRoute,
    required this.onExportData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Box
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search routes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667eea)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe1e5e9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xE6FFFFFF),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Status Dropdown and Export/Add Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFe1e5e9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: null, // Use null to show hint initially
                hint: const Text('All Status'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All Status')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                ],
                onChanged: (value) {
                  onStatusFilterChanged(value ?? '');
                },
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF495057)),
            onPressed: onExportData,
            tooltip: 'Export Data (CSV)',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
          ),
          
          const SizedBox(width: 15),
          
          ElevatedButton(
            onPressed: onAddRoute,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              constraints: const BoxConstraints(minHeight: 36.0, minWidth: 88.0),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Route Cards Grid Widget ---

class _RoutesGrid extends StatelessWidget {
  final List<BusRoute> routes;
  final Function(BuildContext, BusRoute) onView;
  final Function(BusRoute) onEdit;
  final Function(int) onDelete;

  const _RoutesGrid({
    required this.routes,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route_outlined, size: 64, color: Colors.white70),
              SizedBox(height: 16),
              Text(
                'No routes found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: routes.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 450, 
            mainAxisExtent: 420, 
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return _RouteCard(
              route: routes[index],
              onView: () => onView(context, routes[index]),
              onEdit: () => onEdit(routes[index]),
              onDelete: () => onDelete(routes[index].id),
            );
          },
        );
      },
    );
  }
}

// --- Single Route Card Widget ---

class _RouteCard extends StatelessWidget {
  final BusRoute route;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.route,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF51cf66); 
      case 'inactive':
        return const Color(0xFFff6b6b); 
      case 'maintenance':
        return const Color(0xFFffd93d); 
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(route.status);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFF667eea), width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                  child: const Center(
                    child: Text('🛣️', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Route ${route.number} • ${route.driverName}',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF666666)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusLabel(route.status),
                          style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Route Stops Container
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF667eea)),
                      const SizedBox(width: 8),
                      Text(
                        'Stops (${route.stops.length})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...route.stops.asMap().entries.take(4).map((entry) {
                    final index = entry.key;
                    final stop = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF667eea),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text('${stop.time} • ${stop.students} students',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF666666))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (route.stops.length > 4) 
                    const Text('...and more stops', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF667eea))),
                ],
              ),
            ),
            const Spacer(),
            // Route Actions
            Row(
              children: [
                _buildActionButton(context, 'View', onView, const Color(0xFF667eea), Icons.visibility),
                const SizedBox(width: 8),
                _buildActionButton(context, 'Edit', onEdit, const Color(0xFFffd93d), Icons.edit, textColor: const Color(0xFF333333)),
                const SizedBox(width: 8),
                _buildActionButton(context, 'Delete', () {
                   showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete route ${route.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              onDelete();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Route deleted!')));
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                }, const Color(0xFFff6b6b), Icons.delete_forever),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(BuildContext context, String text, VoidCallback onPressed, Color color, IconData icon, {Color textColor = Colors.white}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// --- Route Detail Dialog (Reused from second block) ---

class _RouteDetailDialog extends StatelessWidget {
  final BusRoute route;

  const _RouteDetailDialog({required this.route});

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
                    'Route Details',
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
              _DetailItem('Route Name', route.name),
              _DetailItem('Route Number', route.number),
              _DetailItem('Driver Name', route.driverName),
              if (route.driverPhone != null && route.driverPhone!.isNotEmpty)
                _DetailItem('Driver Phone', route.driverPhone!),
              _DetailItem('Bus Number', route.busNumber),
              _DetailItem('Start Location', route.startLocation),
              _DetailItem('End Location', route.endLocation),
              if (route.distance != null)
                _DetailItem('Distance', '${route.distance} km'),
              if (route.estimatedTime != null)
                _DetailItem('Estimated Time', '${route.estimatedTime} minutes'),
              _DetailItem('Status', route.status[0].toUpperCase() + route.status.substring(1)),
              _DetailItem('Total Stops', route.stops.length.toString()),
              _DetailItem('Total Students', route.stops.fold(0, (sum, stop) => sum + stop.students).toString()),
              const SizedBox(height: 16),
              const Text(
                'Stops:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...route.stops.asMap().entries.map((entry) {
                final index = entry.key;
                final stop = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                              stop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${stop.time} • ${stop.students} students',
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
              }),
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

// --- Route Form Dialog (Reused and slightly adapted) ---

class _RouteFormDialog extends StatefulWidget {
  final BusRoute? route;
  final Function(BusRoute) onSave;

  const _RouteFormDialog({
    this.route,
    required this.onSave,
  });

  @override
  State<_RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<_RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _busNumberController;
  late TextEditingController _startLocationController;
  late TextEditingController _endLocationController;
  late TextEditingController _distanceController;
  late TextEditingController _estimatedTimeController;

  String _status = 'active';
  List<RouteStop> _stops = [];

  @override
  void initState() {
    super.initState();
    final route = widget.route;
    _nameController = TextEditingController(text: route?.name ?? '');
    _numberController = TextEditingController(text: route?.number ?? '');
    _driverNameController =
        TextEditingController(text: route?.driverName ?? '');
    _driverPhoneController =
        TextEditingController(text: route?.driverPhone ?? '');
    _busNumberController =
        TextEditingController(text: route?.busNumber ?? '');
    _startLocationController =
        TextEditingController(text: route?.startLocation ?? '');
    _endLocationController =
        TextEditingController(text: route?.endLocation ?? '');
    _distanceController = TextEditingController(
        text: route?.distance?.toString() ?? '');
    _estimatedTimeController = TextEditingController(
        text: route?.estimatedTime?.toString() ?? '');
    _status = route?.status ?? 'active';
    _stops = route != null
        ? List<RouteStop>.from(route.stops)
        : [
            RouteStop(name: '', time: '', students: 0),
          ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _busNumberController.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _addStop() {
    setState(() {
      _stops.add(RouteStop(name: '', time: '', students: 0));
    });
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  void _updateStop(int index, RouteStop stop) {
    setState(() {
      _stops[index] = stop;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validate stops
    final validStops = _stops
        .where((stop) =>
            stop.name.isNotEmpty && stop.time.isNotEmpty && stop.students > 0)
        .toList();

    if (validStops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid stop')),
      );
      return;
    }

    final route = BusRoute(
      id: widget.route?.id ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
      name: _nameController.text.trim(),
      number: _numberController.text.trim(),
      driverName: _driverNameController.text.trim(),
      driverPhone: _driverPhoneController.text.trim().isEmpty
          ? null
          : _driverPhoneController.text.trim(),
      busNumber: _busNumberController.text.trim(),
      startLocation: _startLocationController.text.trim(),
      endLocation: _endLocationController.text.trim(),
      distance: _distanceController.text.trim().isEmpty
          ? null
          : double.tryParse(_distanceController.text.trim()),
      estimatedTime: _estimatedTimeController.text.trim().isEmpty
          ? null
          : int.tryParse(_estimatedTimeController.text.trim()),
      status: _status,
      stops: validStops,
    );

    widget.onSave(route);
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
                    widget.route == null
                        ? 'Add New Bus Route'
                        : 'Edit Bus Route',
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
                            child: _buildInput('Route Name *', _nameController, isRequired: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput('Route Number *', _numberController, isRequired: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Driver Name *', _driverNameController, isRequired: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput('Driver Phone (Optional)', _driverPhoneController, keyboardType: TextInputType.phone),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInput('Bus Number *', _busNumberController, isRequired: true),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Start Location *', _startLocationController, isRequired: true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput('End Location *', _endLocationController, isRequired: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Distance (km) (Optional)', _distanceController, keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInput('Estimated Time (minutes) (Optional)', _estimatedTimeController, keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        value: _status,
                        items: const [
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'maintenance',
                              child: Text('Maintenance')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _status = value ?? 'active';
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Route Stops *',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addStop,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._stops.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stop = entry.value;
                        return _StopEditor(
                          stop: stop,
                          index: index,
                          onUpdate: (updatedStop) =>
                              _updateStop(index, updatedStop),
                          onRemove: () => _removeStop(index),
                          canRemove: _stops.length > 1,
                        );
                      }),
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
                        widget.route == null ? 'Create Route' : 'Update Route'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInput(String label, TextEditingController controller, {bool isRequired = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        if (keyboardType == TextInputType.number && value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Must be a valid number';
        }
        return null;
      },
    );
  }
}

class _StopEditor extends StatefulWidget {
  final RouteStop stop;
  final int index;
  final Function(RouteStop) onUpdate;
  final VoidCallback onRemove;
  final bool canRemove;

  const _StopEditor({
    required this.stop,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  State<_StopEditor> createState() => _StopEditorState();
}

class _StopEditorState extends State<_StopEditor> {
  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late TextEditingController _studentsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stop.name);
    _timeController = TextEditingController(text: widget.stop.time);
    _studentsController =
        TextEditingController(text: widget.stop.students.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _studentsController.dispose();
    super.dispose();
  }

  void _updateStop() {
    widget.onUpdate(RouteStop(
      name: _nameController.text.trim(),
      time: _timeController.text.trim(),
      students: int.tryParse(_studentsController.text.trim()) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Stop Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => _updateStop(),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    border: OutlineInputBorder(),
                    hintText: '07:00 AM',
                    isDense: true,
                  ),
                  onChanged: (_) => _updateStop(),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _studentsController,
                  decoration: const InputDecoration(
                    labelText: 'Students *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateStop(),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}