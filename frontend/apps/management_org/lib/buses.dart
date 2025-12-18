import 'dart:ui';

import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'widgets/student_list_dialog.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';

class BusStop {
  final String name;
  final String time;
  final int students;

  const BusStop({
    required this.name,
    required this.time,
    required this.students,
  });
}

class Bus {
  final int id;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final String route;
  final int stops;
  final int students;
  final int capacity;
  final String licensePlate;
  final String model;
  final String status;
  final List<BusStop> routeStops;
  final List<BusStop> returnStops;

  const Bus({
    required this.id,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.route,
    required this.stops,
    required this.students,
    required this.capacity,
    required this.licensePlate,
    required this.model,
    required this.status,
    required this.routeStops,
    required this.returnStops,
  });
}

class BusesManagementPage extends StatefulWidget {
  const BusesManagementPage({super.key});

  @override
  State<BusesManagementPage> createState() => _BusesManagementPageState();
}

class _BusesManagementPageState extends State<BusesManagementPage> {
  final List<Bus> _buses = [
    Bus(
      id: 1,
      busNumber: 'BUS-001',
      driverName: 'John Smith',
      driverPhone: '+1-555-0301',
      route: 'Downtown Route',
      stops: 8,
      students: 25,
      capacity: 45,
      licensePlate: 'ABC-123',
      model: '2020 Blue Bird',
      status: 'Active',
      routeStops: const [
        BusStop(name: 'Central Station', time: '07:00 AM', students: 5),
        BusStop(name: 'Downtown Mall', time: '07:15 AM', students: 8),
        BusStop(name: 'City Park', time: '07:25 AM', students: 6),
        BusStop(name: 'Library', time: '07:35 AM', students: 4),
        BusStop(name: 'School', time: '07:45 AM', students: 2),
      ],
      returnStops: const [
        BusStop(name: 'School', time: '02:30 PM', students: 2),
        BusStop(name: 'Library', time: '02:40 PM', students: 4),
        BusStop(name: 'City Park', time: '02:50 PM', students: 6),
        BusStop(name: 'Downtown Mall', time: '03:00 PM', students: 8),
        BusStop(name: 'Central Station', time: '03:15 PM', students: 5),
      ],
    ),
    Bus(
      id: 2,
      busNumber: 'BUS-002',
      driverName: 'Mike Johnson',
      driverPhone: '+1-555-0302',
      route: 'Northside Route',
      stops: 6,
      students: 20,
      capacity: 40,
      licensePlate: 'DEF-456',
      model: '2019 Thomas',
      status: 'Active',
      routeStops: const [
        BusStop(name: 'North Terminal', time: '07:10 AM', students: 4),
        BusStop(name: 'Shopping Center', time: '07:20 AM', students: 7),
        BusStop(name: 'Residential Area', time: '07:30 AM', students: 6),
        BusStop(name: 'School', time: '07:40 AM', students: 3),
      ],
      returnStops: const [
        BusStop(name: 'School', time: '02:30 PM', students: 3),
        BusStop(name: 'Residential Area', time: '02:40 PM', students: 6),
        BusStop(name: 'Shopping Center', time: '02:50 PM', students: 7),
        BusStop(name: 'North Terminal', time: '03:00 PM', students: 4),
      ],
    ),
    Bus(
      id: 3,
      busNumber: 'BUS-003',
      driverName: 'David Wilson',
      driverPhone: '+1-555-0303',
      route: 'Eastside Route',
      stops: 10,
      students: 30,
      capacity: 50,
      licensePlate: 'GHI-789',
      model: '2021 IC Bus',
      status: 'Active',
      routeStops: const [
        BusStop(name: 'East Station', time: '07:05 AM', students: 6),
        BusStop(name: 'Industrial Area', time: '07:15 AM', students: 4),
        BusStop(name: 'Business District', time: '07:25 AM', students: 8),
        BusStop(name: 'Residential Complex', time: '07:35 AM', students: 7),
        BusStop(name: 'School', time: '07:45 AM', students: 5),
      ],
      returnStops: const [
        BusStop(name: 'School', time: '02:30 PM', students: 5),
        BusStop(name: 'Residential Complex', time: '02:40 PM', students: 7),
        BusStop(name: 'Business District', time: '02:50 PM', students: 8),
        BusStop(name: 'Industrial Area', time: '03:00 PM', students: 4),
        BusStop(name: 'East Station', time: '03:10 PM', students: 6),
      ],
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  late List<Bus> _visibleBuses;

  @override
  void initState() {
    super.initState();
    _visibleBuses = List<Bus>.from(_buses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalBuses => _buses.length;
  int get _activeBuses => _buses.where((b) => b.status == 'Active').length;
  int get _totalStudents => _buses.fold(0, (sum, bus) => sum + bus.students);
  int get _totalRoutes => _buses.map((b) => b.route).toSet().length;

  void _filterBuses(String query) {
    setState(() {
      if (query.isEmpty) {
        _visibleBuses = List<Bus>.from(_buses);
      } else {
        final lower = query.toLowerCase();
        _visibleBuses = _buses.where((bus) {
          return bus.busNumber.toLowerCase().contains(lower) ||
              bus.driverName.toLowerCase().contains(lower) ||
              bus.route.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  void _viewBus(Bus bus) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
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
                        '${bus.busNumber} - Bus Details',
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
                            _buildProfileImage(bus),
                            const SizedBox(height: 20),
                            _buildProfileDetails(bus),
                            const SizedBox(height: 20),
                            _buildRouteMap(
                              'Morning Route (Pickup)',
                              bus.routeStops,
                              busId: bus.id.toString(),
                              routeType: 'morning',
                            ),
                            const SizedBox(height: 20),
                            _buildRouteMap(
                              'Afternoon Route (Drop-off)',
                              bus.returnStops,
                              busId: bus.id.toString(),
                              routeType: 'afternoon',
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileImage(bus),
                              const SizedBox(width: 30),
                              Expanded(child: _buildProfileDetails(bus)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildRouteMap(
                            'Morning Route (Pickup)',
                            bus.routeStops,
                            busId: bus.id.toString(),
                            routeType: 'morning',
                          ),
                          const SizedBox(height: 20),
                          _buildRouteMap(
                            'Afternoon Route (Drop-off)',
                            bus.returnStops,
                            busId: bus.id.toString(),
                            routeType: 'afternoon',
                          ),
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
                          Navigator.of(context).pop();
                          _editBus(bus);
                        },
                        child: const Text('Edit Bus'),
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

  Widget _buildProfileImage(Bus bus) {
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
          child: const Center(
            child: Text(
              '🚌',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          bus.busNumber,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          bus.route,
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        const SizedBox(height: 5),
        Text(
          bus.status,
          style: const TextStyle(
            color: Color(0xFF667EEA),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(Bus bus) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.2,
      children: [
        _DetailCard(
          title: 'Bus Information',
          items: [
            'Model: ${bus.model}',
            'License Plate: ${bus.licensePlate}',
            'Capacity: ${bus.capacity} students',
            'Current Load: ${bus.students} students',
          ],
        ),
        _DetailCard(
          title: 'Driver Information',
          items: [
            'Name: ${bus.driverName}',
            'Phone: ${bus.driverPhone}',
            'Route: ${bus.route}',
            'Stops: ${bus.stops}',
          ],
        ),
      ],
    );
  }

  Widget _buildRouteMap(String title, List<BusStop> stops, {String? busId, String? routeType}) {
    final ApiService apiService = ApiService();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛣️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (stops.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No stops added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...stops.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final stop = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      // Double tap to view students - for real API integration
                      if (busId != null) {
                        _viewStopStudents(context, stop.name, busId, routeType ?? 'morning', apiService);
                      }
                    },
                    onDoubleTap: () {
                      if (busId != null) {
                        _viewStopStudents(context, stop.name, busId, routeType ?? 'morning', apiService);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: busId != null ? const Color(0xFF667EEA) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stop.time,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              stop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          Text(
                            '${stop.students} students',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                            ),
                          ),
                          if (busId != null) ...[
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                _viewStopStudents(context, stop.name, busId, routeType ?? 'morning', apiService);
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _viewStopStudents(BuildContext context, String stopName, String busId, String routeType, ApiService apiService) async {
    try {
      // First, get bus stops for this bus and route type
      await apiService.initialize();
      final stopsResponse = await apiService.get('${Endpoints.buses}$busId/');
      
      if (!stopsResponse.success) {
        throw Exception('Failed to load bus stops');
      }

      final busData = stopsResponse.data as Map<String, dynamic>;
      final stops = routeType == 'morning' 
          ? (busData['morning_stops'] as List?) ?? []
          : (busData['afternoon_stops'] as List?) ?? [];

      // Find the stop by name
      final stop = stops.firstWhere(
        (s) => (s as Map)['stop_name'] == stopName,
        orElse: () => null,
      );

      if (stop == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stop not found')),
        );
        return;
      }

      final stopId = (stop as Map)['stop_id']?.toString();
      if (stopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stop ID not found')),
        );
        return;
      }

      // Load students for this stop
      final studentsResponse = await apiService.get('${Endpoints.busStops}$stopId/students/');
      final students = studentsResponse.success 
          ? ((studentsResponse.data as List?) ?? [])
          : <dynamic>[];

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => StudentListDialog(
            stopId: stopId,
            stopName: stopName,
            routeType: routeType,
            busId: busId,
            initialStudents: students,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  void _editBus(Bus bus) {
    Navigator.pushNamed(context, '/edit-bus', arguments: bus.id);
  }

  void _deleteBus(Bus bus) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Delete ${bus.busNumber}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _buses.removeWhere((b) => b.id == bus.id);
                });
                _filterBuses(_searchController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bus deleted successfully!')),
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

  void _addBus() {
    Navigator.pushNamed(context, '/add-new-bus');
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
              isActive: item['label'] == 'Buses',
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
                    'Buses Management',
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
                    Text('🚌', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 15),
                    Text(
                      'Buses Management',
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
                  'Manage bus routes, drivers, students, and transportation schedules',
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
                  _StatCard(label: 'Total Buses', value: '$_totalBuses'),
                  _StatCard(label: 'Active Buses', value: '$_activeBuses'),
                  _StatCard(
                    label: 'Students Transported',
                    value: '$_totalStudents',
                  ),
                  _StatCard(label: 'Bus Routes', value: '$_totalRoutes'),
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
                      onChanged: _filterBuses,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search buses by number, driver, or route...',
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
                  onTap: _addBus,
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
                          'Add New Bus',
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
                children: _visibleBuses.map((bus) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildBusCard(bus),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Bus bus) {
    return _BusCardWithHover(
      bus: bus,
      onView: () => _viewBus(bus),
      onEdit: () => _editBus(bus),
      onDelete: () => _deleteBus(bus),
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

class _BusCardWithHover extends StatefulWidget {
  final Bus bus;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BusCardWithHover({
    required this.bus,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_BusCardWithHover> createState() => _BusCardWithHoverState();
}

class _BusCardWithHoverState extends State<_BusCardWithHover> {
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
                        '🚌',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bus.busNumber,
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
                          '${widget.bus.route} • Driver: ${widget.bus.driverName}',
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
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 10) / 2;
                  final itemHeight = 70.0;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: _DetailItem(
                          title: 'Students',
                          value: '${widget.bus.students}/${widget.bus.capacity}',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: _DetailItem(
                          title: 'Stops',
                          value: '${widget.bus.stops}',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: _DetailItem(
                          title: 'Driver',
                          value: widget.bus.driverName,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: _DetailItem(
                          title: 'Status',
                          value: widget.bus.status,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('🛣️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text(
                          'Route Stops',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...widget.bus.routeStops.take(3).map(
                          (stop) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stop.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (widget.bus.routeStops.length > 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${widget.bus.routeStops.length - 3} more',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _GradientButton(
                      label: 'View Details',
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
      width: double.infinity,
      height: double.infinity,
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
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
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
                maxLines: 2,
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

