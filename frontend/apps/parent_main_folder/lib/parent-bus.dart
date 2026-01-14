import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';

void main() {
  runApp(const BusDetailsApp());
}

// Define the overall application structure and theme
class BusDetailsApp extends StatelessWidget {
  const BusDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define primary colors used across the app (matching your HTML gradient)
    const Color primaryBlue = Color(0xFF667eea);
    const Color primaryPurple = Color(0xFF764ba2);

    return MaterialApp(
      title: 'Bus Tracker - School Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: primaryPurple,
          surface: const Color(0xFFF8F9FA), // Light surface background
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const BusDetailsPage(),
    );
  }
}

// Converted to StatefulWidget to manage alert state
class BusDetailsPage extends StatefulWidget {
  final String? studentId;
  const BusDetailsPage({super.key, this.studentId});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // State variables for bus data
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _busData;
  List<dynamic> _morningStops = [];
  List<dynamic> _afternoonStops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBusDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBusDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _apiService.initialize();
      
      String? targetStudentId = widget.studentId;
      
      // If studentId not provided, fetch current student profile
      if (targetStudentId == null) {
        final profileResponse = await _apiService.get('/student-parent/student-profile/');
        if (profileResponse.success && profileResponse.data != null) {
          final profileData = profileResponse.data as Map<String, dynamic>;
          targetStudentId = profileData['student_id']?.toString() ?? profileData['id']?.toString();
        }
      }

      if (targetStudentId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not identify student. Please login again.';
        });
        return;
      }
      
      debugPrint('Loading bus details for student: $targetStudentId');

      // Get current student's bus assignments - filter by student ID string
      final response = await _apiService.get('${Endpoints.busStopStudents}?search=$targetStudentId');
      
      if (response.success && response.data != null) {
        // Handle paginated response
        List assignments;
        if (response.data is Map) {
          final dataMap = response.data as Map<String, dynamic>;
          assignments = dataMap['results'] as List? ?? [];
        } else if (response.data is List) {
          assignments = response.data as List;
        } else {
          throw Exception('Unexpected response format');
        }
        
        // Filter assignments strictly to match this student name/ID
        // search parameter is good, but let's double check the results
        final filteredAssignments = assignments.where((a) {
          final assignment = a as Map<String, dynamic>;
          final sid = assignment['student_id_string']?.toString() ?? 
                     assignment['student_id']?.toString();
          
          String? nestedSid;
          if (assignment['student'] is Map) {
            nestedSid = assignment['student']['student_id']?.toString() ?? 
                      assignment['student']['id']?.toString();
          } else if (assignment['student'] is String) {
            nestedSid = assignment['student'];
          }
          
          return sid == targetStudentId || nestedSid == targetStudentId;
        }).toList();

        if (filteredAssignments.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No bus assigned to you yet. Please contact the school office.';
          });
          return;
        }

        // Get the first assignment - it now includes bus_details and stop_details
        final firstAssignment = filteredAssignments.first as Map<String, dynamic>;
        final busDetails = firstAssignment['bus_details'] as Map<String, dynamic>?;
        
        if (busDetails == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Bus details not available. Please contact the school office.';
          });
          return;
        }

        // Group assignments by route type to separate morning and afternoon stops
        final morningStops = <Map<String, dynamic>>[];
        final afternoonStops = <Map<String, dynamic>>[];
        
        for (var assignment in filteredAssignments) {
          final assignmentMap = assignment as Map<String, dynamic>;
          final stopDetails = assignmentMap['stop_details'] as Map<String, dynamic>?;
          
          if (stopDetails != null) {
            final routeType = stopDetails['route_type']?.toString() ?? '';
            
            if (routeType == 'morning') {
              morningStops.add(stopDetails);
            } else if (routeType == 'afternoon') {
              afternoonStops.add(stopDetails);
            }
          }
        }
        
        // Sort stops by stop_order
        morningStops.sort((a, b) => (a['stop_order'] ?? 0).compareTo(b['stop_order'] ?? 0));
        afternoonStops.sort((a, b) => (a['stop_order'] ?? 0).compareTo(b['stop_order'] ?? 0));
        
        setState(() {
          _busData = busDetails;
          _morningStops = morningStops;
          _afternoonStops = afternoonStops;
          _isLoading = false;
        });
        
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load bus details. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading bus details: ${e.toString()}';
      });
    }
  }

  // Helper method to format time to 12-hour format
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == 'N/A') return 'N/A';
    try {
      // Split by ':' - handle HH:mm:ss or HH:mm
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      final period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12;
      
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return timeStr;
    }
  }

  // Helper method to filter stops by type
  List<Map<String, String>> _filterStops(String type) {
    final stops = type == 'morning' ? _morningStops : _afternoonStops;
    return stops.map((stop) => {
      'name': stop['stop_name']?.toString() ?? 'Unknown',
      'time': _formatTime(stop['stop_time']?.toString()),
      'type': type,
      'address': stop['address']?.toString() ?? 'No address',
    }).toList();
  }

  // ✅ Header (Refactored to AppBar)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Bus Details",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      // Apply the exact gradient from the HTML header
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadBusDetails,
        ),
      ],
    );
  }

  // ✅ Top Stats Grid
  Widget _statsGrid(BuildContext context) {
    if (_busData == null) {
      return const SizedBox.shrink();
    }

    final firstMorningStop = _morningStops.isNotEmpty ? _morningStops.first : null;
    
    List<Map<String, dynamic>> stats = [
      {
        "icon": "🚌",
        "value": _busData!['bus_number'] ?? 'Bus',
        "label": "Bus",
        "color": Theme.of(context).colorScheme.primary,
      },
      {
        "icon": "🛣️",
        "value": _busData!['route'] ?? 'Bus_route_name',
        "label": "Route",
        "color": Theme.of(context).colorScheme.secondary,
      },
      {
        "icon": "👨‍💼",
        "value": _busData!['driver_name'] ?? 'N/A',
        "label": "Driver",
        "color": Colors.orange,
      },
      {
        "icon": "⏰",
        "value": _formatTime(firstMorningStop?['stop_time']?.toString()),
        "label": "Pickup Time",
        "color": Colors.green,
      },
    ];

    return SizedBox(
      height: 120, // Fixed height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: stats.length,
        itemBuilder: (c, i) {
          return Container(
            width: 150, // Fixed width for each card
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: (stats[i]["color"] as Color).withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
              border: Border(
                top: BorderSide(color: stats[i]["color"] as Color, width: 4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats[i]["icon"] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  stats[i]["value"] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stats[i]["label"] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Main Content Section
  Widget _content(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadBusDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("🚌 Bus Information"),
        _busInfoCard(context),
        const SizedBox(height: 25),

        _title("🛣️ Route Stops"),
        _buildRouteTabs(context),
        const SizedBox(height: 25),

        _title("⚡ Quick Actions"),
        _actionButtons(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xff333333),
        ),
      ),
    );
  }

  // 🔄 MODIFIED: Bus Info Box (Now uses real data)
  Widget _busInfoCard(BuildContext context) {
    if (_busData == null) {
      return const SizedBox.shrink();
    }

    final firstMorningStop = _morningStops.isNotEmpty ? _morningStops.first : null;
    final firstAfternoonStop = _afternoonStops.isNotEmpty ? _afternoonStops.first : null;

    Map<String, String> info = {
      "Route": _busData!['route'] ?? 'N/A',
      "Driver": _busData!['driver_name'] ?? 'N/A',
      "Pickup Time": _formatTime(firstMorningStop?['stop_time']?.toString()),
      "Drop Time": _formatTime(firstAfternoonStop?['stop_time']?.toString()),
      "Contact": _busData!['driver_contact'] ?? 'N/A',
      "Capacity": '${_busData!['capacity'] ?? 'N/A'} Students',
    };

    return _box(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Bus Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("🚌", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    _busData!['bus_number'] ?? 'Bus',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xff333333),
                    ),
                  ),
                ],
              ),
              // Status Badge
              Row(
                children: [
                  Icon(
                    _busData!['status'] == 'Active' ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: _busData!['status'] == 'Active' ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _busData!['status'] ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _busData!['status'] == 'Active' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Row 2: Static Details Grid
          Column(
            children: info.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    Text(
                      e.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Tabbed Route View Container
  Widget _buildRouteTabs(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar for Pickup/Drop-off
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.pin_drop), text: "Morning Stops"),
                Tab(icon: Icon(Icons.school), text: "Afternoon Stops"),
              ],
            ),
          ),

          // Tab View for the lists
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _routeListContent(_filterStops('morning'), true),
                _routeListContent(_filterStops('afternoon'), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Route List Content (Used inside TabBarView)
  Widget _routeListContent(List<Map<String, String>> stops, bool isMorning) {
    if (stops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No ${isMorning ? 'morning' : 'afternoon'} stops available',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        Color color = isMorning
            ? const Color(0xFF51cf66)
            : Theme.of(context).colorScheme.secondary;

        return GestureDetector(
          onTap: () => _showStopDetailsModal(context, stop),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: color, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (isMorning ? "⬆️ " : "⬇️ ") + stop["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stop["time"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Address: ${stop["address"]!}",
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Button List (Includes Emergency Alert)
  Widget _actionButtons(BuildContext context) {
    List<Map<String, dynamic>> actions = [
      {
        "text": "📍 Track Bus Live",
        "icon": Icons.location_on,
        "color": Theme.of(context).colorScheme.primary,
        "onTap": () => _msg(context, "Live tracking coming soon!"),
      },
      {
        "text": "📞 Contact Driver",
        "icon": Icons.phone,
        "color": Theme.of(context).colorScheme.secondary,
        "onTap": () {
          if (_busData != null && _busData!['driver_contact'] != null) {
            _msg(context, "Driver: ${_busData!['driver_contact']}");
          } else {
            _msg(context, "Driver contact not available");
          }
        },
      },
      {
        "text": "⚠️ Report Issue",
        "icon": Icons.warning,
        "color": Colors.orange,
        "onTap": () => _msg(context, "Issue reporting coming soon!"),
      },
      {
        "text": "🔄 Refresh",
        "icon": Icons.refresh,
        "color": Colors.green,
        "onTap": _loadBusDetails,
      },
    ];

    return Column(
      children: actions.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: a["color"] as Color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            onPressed: a["onTap"] as VoidCallback,
            icon: Icon(a["icon"] as IconData, size: 20),
            label: Text(
              a["text"] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 🆕 NEW FEATURE: Stop Details Modal
  void _showStopDetailsModal(BuildContext context, Map<String, String> stop) {
    final bool isMorning = stop['type'] == 'morning';
    final Color accentColor = isMorning
        ? Colors.green
        : Theme.of(context).colorScheme.secondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${isMorning ? 'Morning' : 'Afternoon'} Stop Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const Divider(height: 25),

              _modalDetailRow("Stop Name:", stop['name']!),
              _modalDetailRow("Scheduled Time:", stop['time']!),
              _modalDetailRow("Stop Type:", stop['type']!.toUpperCase()),
              _modalDetailRow("Address:", stop['address']!),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper for Modal Info Rows
  Widget _modalDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF666666))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reusable Box decorator (Mimics the main-section box style)
  Widget _box(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  void _msg(BuildContext c, String m) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statsGrid(context),
            const SizedBox(height: 20),
            _content(context),
          ],
        ),
      ),
    );
  }
}
