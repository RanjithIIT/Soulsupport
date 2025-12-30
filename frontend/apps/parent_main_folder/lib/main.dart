import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math; // Used for random data generation
import 'package:intl/intl.dart' as intl;
import 'package:main_login/main.dart' as main_login;
import 'package:http/http.dart' as http;
import 'parent-profile.dart';
import 'parent-academics.dart';
import 'parent-bus.dart';
import 'parent-calendar.dart';
import 'parent-daily-task.dart';
import 'parent-Extracurricular.dart';
import 'parent-gallery.dart';
import 'parent-homework.dart';
import 'parent-projects.dart';
import 'parent-results.dart';
import 'parent-test.dart';
import 'parent_fees.dart';
import 'services/api_service.dart' as api;
import 'services/realtime_chat_service.dart';

// -------------------------------------------------------------------------
// 1. UTILITY FUNCTIONS & DATA MODELS
// -------------------------------------------------------------------------

/// Utility function to create a MaterialColor from a single color value.
MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  swatch[50] = Color.fromRGBO(r, g, b, 0.05);

  for (int i = 0; i < 9; i++) {
    int key = (i + 1) * 100;
    if (i + 1 < strengths.length) {
      swatch[key] = Color.fromRGBO(r, g, b, strengths[i + 1]);
    } else {
      swatch[key] = Color.fromRGBO(r, g, b, 1.0);
    }
  }

  return MaterialColor(color.value, swatch);
}

class DashboardData {
  // Dashboard data will be fetched from API, no dummy data
  final String userName;
  final String totalHomework;
  final String upcomingTests;
  final String totalResults;
  final String academicsScore;
  final String extracurricularCount;
  final String feesStatus;
  final Map<String, dynamic> busDetails;
  final List<Map<String, String>> homework;
  final List<Map<String, String>> tests;
  final List<Map<String, dynamic>> results;

  DashboardData({
    this.userName = '',
    this.totalHomework = '0',
    this.upcomingTests = '0',
    this.totalResults = '0',
    this.academicsScore = '0%',
    this.extracurricularCount = '0',
    this.feesStatus = 'Unknown',
    Map<String, dynamic>? busDetails,
    List<Map<String, String>>? homework,
    List<Map<String, String>>? tests,
    List<Map<String, dynamic>>? results,
  })  : busDetails = busDetails ?? {},
        homework = homework ?? [],
        tests = tests ?? [],
        results = results ?? [];
}

// -------------------------------------------------------------------------
// 2. MAIN APP SETUP & CONSTANTS
// -------------------------------------------------------------------------

void main() {
  runApp(const SchoolManagementSystemApp());
}

class SchoolManagementSystemApp extends StatelessWidget {
  const SchoolManagementSystemApp({super.key});

  // Sharpened primary color for better contrast
  static const Color primaryPurple = Color(
    0xFF5A67C4,
  ); // Darker than 0xFF667eea
  static const Color lightBackground = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Performance Dashboard',
      theme: ThemeData(
        // Using createMaterialColor requires calling the function
        primarySwatch: createMaterialColor(primaryPurple),
        primaryColor: primaryPurple,
        fontFamily: 'Segoe UI',
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold, // Bolder title
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// -------------------------------------------------------------------------
// 3. HOME SCREEN (STATEFUL WIDGET)
// -------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardData mockData = DashboardData();
  final math.Random _random = math.Random();

  // Initialize state variables for Calendar
  int currentMonth = DateTime.now().month - 1; // 0-indexed for month names
  int currentYear = DateTime.now().year;

  String _overallScore = '84%';
  String _attendanceRate = '97%';
  String _classRank = '7th';
  String _selectedPeriod = 'Monthly'; // For performance period selection
  String? _schoolName;
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    _loadParentProfile();
  }

  Future<void> _loadParentProfile() async {
    try {
      final parentData = await api.ApiService.fetchParentProfile();
      if (parentData != null) {
        // Extract school_id and school_name from parent profile
        _schoolId = parentData['school_id']?.toString();
        _schoolName = parentData['school_name']?.toString();
        
        debugPrint('Parent profile - school_id: $_schoolId, school_name: $_schoolName');
        
        // Check for null, empty, or 'null' string values
        final isSchoolIdEmpty = _schoolId == null || _schoolId!.isEmpty || _schoolId == 'null';
        final isSchoolNameEmpty = _schoolName == null || _schoolName!.isEmpty || _schoolName == 'null';
        
        if (isSchoolIdEmpty || isSchoolNameEmpty) {
          // Try to get from students
          final students = parentData['students'];
          if (students is List && students.isNotEmpty) {
            // Try all students to find one with school data
            for (var student in students) {
              if (student is Map) {
                // Try to get school_id
                if (isSchoolIdEmpty) {
                  final extractedSchoolId = student['school_id']?.toString() ?? 
                                          student['school']?['school_id']?.toString();
                  if (extractedSchoolId != null && extractedSchoolId.isNotEmpty && extractedSchoolId != 'null') {
                    _schoolId = extractedSchoolId;
                  }
                }
                // Try to get school_name
                if (isSchoolNameEmpty) {
                  final extractedSchoolName = student['school_name']?.toString() ?? 
                                             student['school']?['school_name']?.toString() ??
                                             student['school']?['name']?.toString();
                  if (extractedSchoolName != null && extractedSchoolName.isNotEmpty && extractedSchoolName != 'null') {
                    _schoolName = extractedSchoolName;
                  }
                }
                
                // If we found both, break
                if ((_schoolId != null && _schoolId!.isNotEmpty && _schoolId != 'null') &&
                    (_schoolName != null && _schoolName!.isNotEmpty && _schoolName != 'null')) {
                  debugPrint('Extracted from student - school_id: $_schoolId, school_name: $_schoolName');
                  break;
                }
              }
            }
          }
        }
        
        // Update UI
        if (mounted) {
          setState(() {});
        }
        
        // If school name is still not available, try to load it
        if ((_schoolName == null || _schoolName!.isEmpty) && _schoolId != null && _schoolId!.isNotEmpty) {
          // Fallback: try to load school name if not in profile
          await _loadSchoolName();
        }
      }
    } catch (e) {
      debugPrint('Failed to load parent profile: $e');
    }
  }

  Future<void> _loadSchoolName() async {
    try {
      if (_schoolId == null || _schoolId!.isEmpty) return;
      
      final headers = await api.ApiService.getAuthHeaders();
      
      // Try super-admin endpoint to get school by school_id
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/super-admin/schools/$_schoolId/'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          setState(() {
            _schoolName = data['school_name']?.toString() ?? 'School';
          });
          return;
        }
      }
      
      // Fallback: try to extract from parent profile if student.school is available
      try {
        final parentData = await api.ApiService.fetchParentProfile();
        if (parentData != null) {
          final students = parentData['students'];
          if (students is List && students.isNotEmpty) {
            final student = students[0];
            if (student is Map) {
              final school = student['school'];
              if (school is Map && school['school_name'] != null) {
                setState(() {
                  _schoolName = school['school_name']?.toString() ?? 'School';
                });
                return;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to extract school from profile: $e');
      }
      
      setState(() {
        _schoolName = 'School';
      });
    } catch (e) {
      debugPrint('Failed to load school name: $e');
      setState(() {
        _schoolName = 'School';
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _refreshPerformanceStats() {
    setState(() {
      final overallScoreValue = (_random.nextDouble() * 30 + 70)
          .toStringAsFixed(1);
      final attendanceRateValue = (_random.nextInt(20) + 80);
      final classRankValue = _random.nextInt(30) + 1;

      _overallScore = '$overallScoreValue%';
      _attendanceRate = '$attendanceRateValue%';
      _classRank = '$classRankValue${_getOrdinalSuffix(classRankValue)}';
    });
    _showSnackBar('Performance data refreshed!');
  }

  String _getOrdinalSuffix(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // --- Calendar Control Methods ---
  void previousMonth() {
    setState(() {
      currentMonth--;
      if (currentMonth < 0) {
        currentMonth = 11;
        currentYear--;
      }
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth++;
      if (currentMonth > 11) {
        currentMonth = 0;
        currentYear++;
      }
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildStatsGrid() {
    final stats = [
      {
        'icon': Icons.person,
        'number': 'Profile',
        'label': 'Student Profile',
        'color': const Color(0xFF5A67C4), // Primary
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentProfilePage()),
        ),
      },
      {
        'icon': Icons.directions_bus,
        'number': (mockData.busDetails['busNumber'] as String?) ?? 'N/A',
        'label': 'Bus Details',
        'color': const Color(0xFF17a2b8),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BusDetailsPage()),
        ),
      },
      {
        'icon': Icons.science,
        'number': 'Projects',
        'label': 'Student Projects',
        'color': const Color(0xFF6f42c1),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentProjectsPage()),
        ),
      },
      {
        'icon': Icons.check_circle_outline,
        'number': 'Tasks',
        'label': 'Daily Tasks',
        'color': const Color(0xFF20c997),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyTasksPage()),
        ),
      },
      {
        'icon': Icons.assessment,
        'number': mockData.upcomingTests,
        'label': 'Tests',
        'color': const Color(0xFFf093fb),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestManagementPage()),
        ),
      },
      {
        'icon': Icons.bar_chart,
        'number': mockData.totalResults,
        'label': 'Results',
        'color': const Color(0xFF28a745),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultsPage()),
        ),
      },
      {
        'icon': Icons.assignment,
        'number': mockData.totalHomework,
        'label': 'Homework',
        'color': const Color(0xFF764ba2),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeworkManagementPage()),
        ),
      },
      {
        'icon': Icons.school,
        'number': mockData.academicsScore,
        'label': 'Academics',
        'color': const Color(0xFF5A67C4), // Primary
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AcademicsPage()),
        ),
      },
      {
        'icon': Icons.sports_soccer,
        'number': mockData.extracurricularCount,
        'label': 'Activities',
        'color': const Color(0xFFFFC107),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActivityScreen()),
        ),
      },
      {
        'icon': Icons.house,
        'number': 'Gallery',
        'label': 'School Gallery',
        'color': const Color(0xFFfd7e14),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SchoolGalleryPage()),
        ),
      },
      {
        'icon': Icons.payment,
        'number': mockData.feesStatus,
        'label': 'Fees',
        'color': const Color(0xFF20c997),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentFeesPage()),
        ),
      },
      {
        'icon': Icons.message,
        'number': 'Contact',
        'label': 'Teacher',
        'color': const Color(0xFFe83e8c),
        'action': () => _showChatDialog(context),
      },
      {
        'icon': Icons.calendar_month,
        'number': 'Calendar',
        'label': 'Academic Calendar',
        'color': const Color(0xFF6c757d),
        'action': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AcademicCalendarPage()),
        ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600
            ? 2
            : (MediaQuery.of(context).size.width < 900 ? 3 : 4),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final item = stats[index];
        return _StatCard(
          icon: item['icon'] as IconData,
          number: item['number'] as String,
          label: item['label'] as String,
          color: item['color'] as Color,
          onTap: item['action'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildPerformanceStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use responsive sizing based on available width
        final isNarrow = constraints.maxWidth < 600;

        if (isNarrow) {
          // For narrow screens, use scrollable horizontal list
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: _PerformanceStatItem(
                    label: 'Overall Score',
                    value: _overallScore,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: _PerformanceStatItem(
                    label: 'Attendance',
                    value: _attendanceRate,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: _PerformanceStatItem(
                    label: 'Class Rank',
                    value: _classRank,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          );
        } else {
          // For wider screens, use flexible row
          return Row(
            children: [
              Expanded(
                child: _PerformanceStatItem(
                  label: 'Overall Score',
                  value: _overallScore,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PerformanceStatItem(
                  label: 'Attendance',
                  value: _attendanceRate,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PerformanceStatItem(
                  label: 'Class Rank',
                  value: _classRank,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPerformanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '📊 Student Performance Overview',
                  // Increased font size and contrast for the title
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _refreshPerformanceStats,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A745),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),

          // Grades Chart
          _buildGradesChart(),
          const SizedBox(height: 20),

          // Attendance Chart
          _buildAttendanceChart(),
          const SizedBox(height: 30),

          // Performance Stats Grid
          _buildPerformanceStats(),
        ],
      ),
    );
  }

  Widget _buildGradesChart() {
    // Data for different periods
    Map<String, Map<String, dynamic>> periodData = {
      'Monthly': {
        'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        'percentages': [93, 94, 86, 90, 89, 86],
      },
      'Quarterly': {
        'labels': ['Q1', 'Q2', 'Q3', 'Q4'],
        'percentages': [91, 89, 92, 88],
      },
      'Half-Yearly': {
        'labels': ['H1 2024', 'H2 2024'],
        'percentages': [90, 90],
      },
      'Annually': {
        'labels': ['2022', '2023', '2024'],
        'percentages': [88, 91, 90],
      },
    };

    final currentData = periodData[_selectedPeriod]!;
    final labels = currentData['labels'] as List<String>;
    final percentages = currentData['percentages'] as List<int>;
    final maxPercentage = 100;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      color: Color(0xFF5A67C4),
                      size: 22, // Increased icon size
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$_selectedPeriod Grades Performance',
                        style: const TextStyle(
                          fontSize: 17, // Increased font size
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Period Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Monthly', 'Quarterly', 'Half-Yearly', 'Annually'].map(
                (period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5A67C4) // Sharpened color
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Bar Chart
          // FIX: Increased height from 200 to 220 to prevent overflow in the chart column
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(labels.length, (index) {
                final percentage = percentages[index];
                // Base bar height scaled down from the new total height (220 - padding/labels)
                final barHeight = (percentage / maxPercentage) * 160;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Percentage label
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 14, // Increased size
                            fontWeight: FontWeight.w700, // Increased boldness
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        Container(
                          width: double.infinity,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5A67C4), Color(0xFF764BA2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 13, // Increased size
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Extra space to prevent overflow
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF5A67C4), size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Column Chart: Monthly grade percentages showing academic performance',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    // Data for different periods
    Map<String, Map<String, dynamic>> periodData = {
      'Monthly': {
        'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        'percentages': [85, 89, 93, 90, 93, 90],
      },
      'Quarterly': {
        'labels': ['Q1', 'Q2', 'Q3', 'Q4'],
        'percentages': [89, 91, 92, 90],
      },
      'Half-Yearly': {
        'labels': ['H1 2024', 'H2 2024'],
        'percentages': [90, 91],
      },
      'Annually': {
        'labels': ['2022', '2023', '2024'],
        'percentages': [87, 90, 91],
      },
    };

    final currentData = periodData[_selectedPeriod]!;
    final months = currentData['labels'] as List<String>;
    final percentages = currentData['percentages'] as List<int>;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_chart,
                      color: Color(0xFF4CAF50), // Sharper green
                      size: 22, // Increased icon size
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$_selectedPeriod Attendance Performance',
                        style: const TextStyle(
                          fontSize: 17, // Increased font size
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Period Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Monthly', 'Quarterly', 'Half-Yearly', 'Annually'].map(
                (period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4CAF50) // Sharper green
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Line Chart
          // FIX: Increased height from 180 to 200 for safe rendering of labels
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _LineChartPainter(
                months: months,
                percentages: percentages,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF4CAF50), size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Line Chart: Monthly attendance percentages showing attendance trends',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCalendar() {
    // Get month name
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    // Safety check for index
    final monthName = (currentMonth >= 0 && currentMonth < 12)
        ? monthNames[currentMonth]
        : 'Invalid Month';

    // Calculate days in current month
    final daysInMonth = DateTime(currentYear, currentMonth + 2, 0).day;
    final firstDayOfMonth = DateTime(currentYear, currentMonth + 1, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Mock attendance data (Present days) - will vary by month
    final presentDays = [
      3,
      4,
      5,
      7,
      10,
      11,
      12,
      13,
      14,
      17,
      18,
      19,
      20,
      21,
      24,
      25,
      26,
      27,
      28,
    ];
    final absentDays = [6, 15]; // Red color

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF5A67C4),
                      size: 24, // Increased icon size
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Student Calendar',
                        style: TextStyle(
                          fontSize: 20, // Increased font size for title
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF5A67C4),
                    ),
                    onPressed: previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A67C4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$monthName $currentYear',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14, // Increased font size
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF5A67C4),
                    ),
                    onPressed: nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calendar Grid
          Column(
            children: [
              // Weekday headers
              Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(
                  (day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700, // Bolder
                            color: Color(0xFF5A67C4), // Primary color
                            fontSize: 15, // Increased size
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),

              // Calendar days
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: firstWeekday + daysInMonth, // Total cells needed
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekday + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    // Empty cell for days outside current month
                    return Container();
                  }

                  final now = DateTime.now();
                  final isPresent = presentDays.contains(dayNumber);
                  final isAbsent = absentDays.contains(dayNumber);
                  final isToday =
                      dayNumber == now.day &&
                      currentMonth == now.month - 1 &&
                      currentYear == now.year;

                  Color bgColor = Colors.grey.shade100; // Default background
                  Color textColor = Colors.black87;
                  String? statusText;

                  if (isPresent) {
                    bgColor = const Color(0xFF4CAF50).withOpacity(0.9);
                    textColor = Colors.white;
                    statusText = 'P';
                  } else if (isAbsent) {
                    bgColor = const Color(0xFFEF5350).withOpacity(0.9);
                    textColor = Colors.white;
                    statusText = 'A';
                  }

                  return InkWell(
                    onTap: () => _showDateDetails(
                      context,
                      dayNumber,
                      isPresent,
                      isAbsent,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: isToday
                            ? Border.all(
                                color: const Color(0xFF5A67C4),
                                width: 3, // Thicker border for Today
                              )
                            : null,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            4.0,
                          ), // Increased padding
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 16, // Increased font size
                                  fontWeight: FontWeight.w800, // Extra bold
                                  color: textColor,
                                ),
                              ),
                              if (statusText != null) ...[
                                const SizedBox(height: 1),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 10, // Increased font size
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(const Color(0xFF4CAF50), 'Present'),
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFFEF5350), 'Absent'),
              const SizedBox(width: 20),
              _buildLegendItem(
                Colors.grey.shade100, // Use the actual default cell color
                'No Record',
                hasBorder: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: Colors.grey.shade400) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // Method to show date details dialog
  void _showDateDetails(
    BuildContext context,
    int day,
    bool isPresent,
    bool isAbsent,
  ) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateString = '${monthNames[currentMonth]} $day, $currentYear';

    // Mock data for the selected date
    final List<Map<String, dynamic>> dayEvents = day == 17
        ? []
        : [
            // Make one date empty
            {
              'type': 'event',
              'icon': Icons.event,
              'title': 'Science Fair',
              'time': '10:00 AM',
              'color': Colors.blue,
            },
            {
              'type': 'event',
              'icon': Icons.celebration,
              'title': 'Sports Day',
              'time': '2:00 PM',
              'color': Colors.orange,
            },
          ];

    final List<Map<String, dynamic>> dayExams = day == 17
        ? [
            {
              'subject': 'Physics',
              'time': '11:00 AM',
              'duration': '1 hour',
              'type': 'Quiz',
            },
          ]
        : [
            {
              'subject': 'Mathematics',
              'time': '9:00 AM',
              'duration': '2 hours',
              'type': 'Mid-Term',
            },
          ];

    final List<Map<String, dynamic>> dayHomework = day == 17
        ? [
            {
              'subject': 'English',
              'title': 'Essay on Climate Change',
              'status': 'pending',
            },
          ]
        : [
            {
              'subject': 'History',
              'title': 'Chapter 5 Questions',
              'status': 'completed',
            },
          ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateString,
                            style: const TextStyle(
                              fontSize: 22, // Increased size
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A67C4), // Sharper color
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPresent
                                    ? Icons.check_circle
                                    : (isAbsent
                                          ? Icons.cancel
                                          : Icons.help_outline),
                                color: isPresent
                                    ? Colors.green
                                    : (isAbsent ? Colors.red : Colors.grey),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPresent
                                    ? 'Present'
                                    : (isAbsent ? 'Absent' : 'No Record'),
                                style: TextStyle(
                                  fontSize: 15, // Increased size
                                  color: isPresent
                                      ? Colors.green
                                      : (isAbsent ? Colors.red : Colors.grey),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Scrollable content
                Flexible(
                  // Use Flexible to allow the column to take space and the SingleChildScrollView to work
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Events Section
                        if (dayEvents.isNotEmpty) ...[
                          _buildDetailSection(
                            '📅 Events',
                            dayEvents
                                .map(
                                  (event) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      event['icon'] as IconData,
                                      color: event['color'] as Color,
                                      size: 20, // Increased size
                                    ),
                                    title: Text(
                                      event['title'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700, // Bolder
                                        fontSize: 15, // Increased size
                                      ),
                                    ),
                                    subtitle: Text(
                                      event['time'] as String,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Exams Section
                        if (dayExams.isNotEmpty) ...[
                          _buildDetailSection(
                            '📝 Exams',
                            dayExams
                                .map(
                                  (exam) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                exam['subject'] as String,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize:
                                                      16, // Increased size
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${exam['type']} • ${exam['time']} • ${exam['duration']}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Homework Section
                        if (dayHomework.isNotEmpty) ...[
                          _buildDetailSection(
                            '📚 Homework',
                            dayHomework
                                .map(
                                  (hw) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hw['subject'] as String,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                hw['title'] as String,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          hw['status'] == 'completed'
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          color: hw['status'] == 'completed'
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18, // Increased size
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and School Name
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double side = (constraints.maxHeight * 0.9).clamp(
                      60.0,
                      120.0,
                    );
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26, 
                            blurRadius: 4, 
                            offset: Offset(0, 2)
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Transform.scale(
                          scale: 1.2, // Zoom in to crop out the baked-in border
                          child: Image.asset(
                            'assets/images/vidhyarambh_logo.png',
                            package: 'parent_app',
                            fit: BoxFit.cover,
                            width: side,
                            height: side,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('LOGO LOAD ERROR: $error');
                              return const Icon(
                                Icons.school, // Fallback icon
                                size: 40,
                                color: Color(0xFFFFD700),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    _schoolName ?? 'School',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          
          // User Info and Logout
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with Navigation
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentProfilePage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE1BEE7),
                      child: Text('👨‍👩‍👧', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Logout Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const main_login.LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.logout, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Matching Teacher App size
        child: _buildHeader(),
      ),
      // Add Floating Action Button for Chat
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Title Section (Gradient Text simulated with ShaderMask)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: <Color>[
                    SchoolManagementSystemApp.primaryPurple,
                    Color(0xFF764ba2),
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: const Text(
                'Parent Dashboard',
                style: TextStyle(
                  fontSize: 34, // Increased size
                  fontWeight: FontWeight.w800, // Extra bold
                  color: Colors.white, // Color is overridden by the shader
                ),
              ),
            ),
            const Text(
              'Student progress and information',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Student Calendar Section (moved to top)
            _buildAttendanceCalendar(),
            const SizedBox(height: 30),

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 30),

            // Performance Overview Section
            _buildPerformanceOverview(),
            const SizedBox(height: 30),

            // Recent Homework Section
            _SectionCard(
              title: '📚 Recent Homework',
              child: _HomeworkList(homework: mockData.homework),
            ),
            const SizedBox(height: 30),

            // Upcoming Tests Section
            _SectionCard(
              title: '📋 Upcoming Tests',
              child: _TestsList(tests: mockData.tests),
            ),
            const SizedBox(height: 30),

            // Recent Results Section
            _SectionCard(
              title: '📊 Recent Results',
              child: _ResultsList(results: mockData.results),
            ),
            const SizedBox(height: 30),

            // Bus Details Section
            _SectionCard(
              title: '🚌 Bus Details',
              child: _BusDetailsCard(details: mockData.busDetails),
            ),
            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChatDialog(context),
        backgroundColor: Colors
            .lightBlueAccent
            .shade700, // Using blue for chat FAB as requested
        // UPDATED: Changed icon to chat bubble outline for visual flair
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Chat', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // WhatsApp-like chat dialog
  void _showChatDialog(BuildContext context) {
    // Open chat as a full-screen route instead of a dialog
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => _WhatsAppChatScreen()));
  }
}

// -------------------------------------------------------------------------
// 4. REUSABLE COMPONENTS
// -------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20, // Increased size
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A67C4), // Sharper color
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext classContext) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28), // Increased icon size
            const SizedBox(height: 8),
            // Number/Main Status (e.g., '3', '85.6%')
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 26, // Increased size
                  fontWeight: FontWeight.w900, // Extra bold
                  color: Colors.black,
                  height: 1.1,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2),
            // Label (e.g., 'Student Profile', 'Bus Details')
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18, // Increased base size
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerformanceStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 32, // Significantly increased size
                fontWeight: FontWeight.w900, // Extra bold
                color: color,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, // Increased size
              color: Colors.grey,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BusDetailsCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const _BusDetailsCard({required this.details});

  String _safeGet(String key, [String defaultValue = 'N/A']) {
    final value = details[key];
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  Widget _buildDetailRow(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800, // Bolder
              color: Color(0xFF5A67C4),
              fontSize: 18, // Increased size
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ), // Increased size
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_bus,
                color: Color(0xFF5A67C4),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bus ${_safeGet('busNumber', 'N/A')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailRow('Route', _safeGet('route')),
              _buildDetailRow('Driver', _safeGet('driver')),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailRow('Pickup Time', _safeGet('pickupTime')),
              _buildDetailRow('Drop Time', _safeGet('dropTime')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeworkList extends StatelessWidget {
  final List<Map<String, String>> homework;

  const _HomeworkList({required this.homework});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homework.length,
      itemBuilder: (context, index) {
        final item = homework[index];
        final isPending = item['status'] == 'pending';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: isPending ? Colors.orange : Colors.green,
                width: 4,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              item['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ), // Bolder
            ),
            subtitle: Text(
              '${item['subject']!} - Due: ${item['dueDate']!}',
              style: const TextStyle(fontSize: 13), // Adjusted size
            ),
            trailing: Chip(
              label: Text(
                item['status']!,
                style: TextStyle(
                  color: isPending ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.w600, // Bolder chip text
                ),
              ),
              backgroundColor: isPending
                  ? const Color(0xFFFFC107).withOpacity(0.5)
                  : const Color(0xFF40c057),
            ),
          ),
        );
      },
    );
  }
}

class _TestsList extends StatelessWidget {
  final List<Map<String, String>> tests;

  const _TestsList({required this.tests});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final item = tests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: Color(0xFFf093fb), width: 4),
            ),
          ),
          child: ListTile(
            title: Text(
              '${item['subject']!} Test',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ), // Bolder
            ),
            subtitle: Text(
              'Date: ${item['date']!} • Duration: ${item['duration']!}',
              style: const TextStyle(fontSize: 13), // Adjusted size
            ),
            trailing: Chip(
              label: const Text(
                'Upcoming',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFFf093fb).withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: Color(0xFF28a745), width: 4),
            ),
          ),
          child: ListTile(
            title: Text(
              '${item['subject']} - ${item['examType']}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ), // Bolder
            ),
            subtitle: Text(
              'Score: ${item['score']}% • Grade: ${item['grade']} • Date: ${item['date']}',
              style: const TextStyle(fontSize: 13), // Adjusted size
            ),
            trailing: const Chip(
              label: Text(
                'Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Color(0xFF40c057),
            ),
          ),
        );
      },
    );
  }
}

// Line Chart Painter for Attendance Performance
class _LineChartPainter extends CustomPainter {
  final List<String> months;
  final List<int> percentages;

  _LineChartPainter({required this.months, required this.percentages});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF4CAF50) // Sharper green line
      ..strokeWidth =
          3.5 // Thicker line
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color =
          const Color(0xFF4CAF50) // Sharper green point
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate positions
    // Chart height is based on the container size defined in _buildAttendanceChart (200)
    final chartHeight = size.height - 60;
    final chartWidth = size.width - 40;

    // Check for empty data to prevent division by zero
    if (months.length <= 1) return;

    final xSpacing = chartWidth / (months.length - 1);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = 20 + (chartHeight / 4) * i;
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), gridPaint);
    }

    // Draw line
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < percentages.length; i++) {
      final x = 20 + (i * xSpacing);
      // Normalize values from 100-0 to fit chart area
      final normalizedValue = (100 - percentages[i]) / 100;
      final y = 20 + (normalizedValue * chartHeight);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points and labels
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw point
      canvas.drawCircle(point, 6, pointPaint); // Larger point
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);

      // Draw percentage label
      textPainter.text = TextSpan(
        text: '${percentages[i]}%',
        style: const TextStyle(
          color: Color(0xFF4CAF50), // Sharper color for label
          fontSize: 12, // Slightly larger font
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy - 20),
      );

      // Draw month label
      textPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
        ), // Sharper month label
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, size.height - 25),
      );
    }

    // Draw Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final percentage = 100 - (i * 25);
      final y = 20 + (chartHeight / 4) * i;

      textPainter.text = TextSpan(
        text: '$percentage%',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 11,
        ), // Sharper Y-axis label
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 5));
    }
  }

  // Set shouldRepaint to true if the data is dynamic (it is, based on _selectedPeriod)
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -------------------------------------------------------------------------
// WhatsApp-Like Chat Dialog
// -------------------------------------------------------------------------

class _WhatsAppChatDialog extends StatefulWidget {
  @override
  State<_WhatsAppChatDialog> createState() => _WhatsAppChatDialogState();
}

class _WhatsAppChatDialogState extends State<_WhatsAppChatDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _groups = [];
  bool _loadingTeachers = false;
  String? _schoolId; // Parent's school_id for filtering
  Map<String, int> _unreadCounts = {}; // Track unread messages per teacher

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadParentSchoolId();
    _loadTeachers();
  }

  Future<void> _loadParentSchoolId() async {
    try {
      final parentData = await api.ApiService.fetchParentProfile();
      if (parentData != null) {
        _schoolId = parentData['school_id']?.toString();
        // Try to get from students if not in parent profile
        if ((_schoolId == null || _schoolId!.isEmpty || _schoolId == 'null')) {
          final students = parentData['students'];
          if (students is List && students.isNotEmpty) {
            final student = students[0];
            if (student is Map) {
              _schoolId = student['school_id']?.toString() ?? 
                         student['school']?['school_id']?.toString();
            }
          }
        }
        debugPrint('Parent school_id for filtering: $_schoolId');
      }
    } catch (e) {
      debugPrint('Failed to load parent school_id: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    if (_loadingTeachers) return [];
    
    // First filter by school_id match (if parent has school_id)
    var filtered = _teachers;
    if (_schoolId != null && _schoolId!.isNotEmpty) {
      filtered = _teachers.where((teacher) {
        final teacherSchoolId = teacher['school_id']?.toString();
        return teacherSchoolId == null || teacherSchoolId == _schoolId;
      }).toList();
    }
    
    // Then apply search filter
    if (_searchQuery.isEmpty) return filtered;
    return filtered
        .where(
          (teacher) =>
              teacher['name'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              teacher['subject'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  List<Map<String, dynamic>> get _filteredGroups {
    if (_loadingTeachers) return [];
    if (_searchQuery.isEmpty) return _groups;
    return _groups
        .where(
          (group) =>
              group['name'].toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _loadTeachers() async {
    setState(() => _loadingTeachers = true);
    try {
      final data = await api.ApiService.fetchTeachers();
      final mapped = data.map<Map<String, dynamic>>((t) {
        final user = t['user'] as Map<String, dynamic>? ?? {};
        final first = (user['first_name'] as String? ?? '').trim();
        final last = (user['last_name'] as String? ?? '').trim();
        final fullName = ('$first $last').trim();
        final designation = t['designation'] as String? ?? '';
        return {
          'name': fullName.isNotEmpty ? fullName : 'Teacher',
          'subject': designation,
          'online': false,
          'unread': 0,
          'lastMessage': '',
          'time': '',
          'avatar': _buildInitials(fullName.isNotEmpty ? fullName : 'T'),
        };
      }).toList();
      setState(() {
        _teachers = mapped;
        _groups = [
          {
            'name': 'All Teachers',
            'members': _teachers.length,
            'unread': 0,
            'lastMessage': '',
            'time': '',
            'avatar': '👥',
          },
        ];
      });
    } catch (e) {
      debugPrint('Failed to load teachers: $e');
    } finally {
      if (mounted) setState(() => _loadingTeachers = false);
    }
  }

  String _buildInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '👤';
    final initials = parts.take(2).map((p) => p[0]).join();
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SchoolManagementSystemApp.primaryPurple,
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          // Chat icon (kept the new trending icon)
                          Icon(
                            Icons.send_time_extension,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'School Chat',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // REMOVED: Icons.more_vert (three dots) button here
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search teachers, groups...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              color: Colors.grey.shade100,
              child: TabBar(
                controller: _tabController,
                labelColor: SchoolManagementSystemApp.primaryPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: SchoolManagementSystemApp.primaryPurple,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.chat), text: 'Chats'),
                  Tab(icon: Icon(Icons.group), text: 'Groups'),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildChatsTab(), _buildGroupsTab()],
              ),
            ),
            // New chat button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showNewChatDialog(context),
                backgroundColor: SchoolManagementSystemApp.primaryPurple,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Start New Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsTab() {
    return Container(
      color: Colors.grey.shade50,
      child: _filteredTeachers.isEmpty
          ? const Center(
              child: Text(
                'No teachers found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeachers[index];
                return _buildChatTile(
                  avatar: teacher['avatar'],
                  name: teacher['name'],
                  subtitle: teacher['subject'] ?? teacher['lastMessage'] ?? '',
                  time: teacher['time'],
                  unread: teacher['unread'],
                  online: teacher['online'],
                  onTap: () => _openChatWithTeacher(context, teacher),
                );
              },
            ),
    );
  }

  Widget _buildGroupsTab() {
    return Container(
      color: Colors.grey.shade50,
      child: _filteredGroups.isEmpty
          ? const Center(
              child: Text(
                'No groups found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final group = _filteredGroups[index];
                return _buildChatTile(
                  avatar: group['avatar'],
                  name: group['name'],
                  subtitle: group['lastMessage'],
                  time: group['time'],
                  unread: group['unread'],
                  isGroup: true,
                  members: group['members'],
                  onTap: () => _openGroup(context, group),
                );
              },
            ),
    );
  }

  Widget _buildChatTile({
    required String avatar,
    required String name,
    required String subtitle,
    required String time,
    int unread = 0,
    bool online = false,
    bool isGroup = false,
    int members = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SchoolManagementSystemApp.primaryPurple.withOpacity(
                      0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                if (online && !isGroup)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            // Darkened Name Text
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors
                                .black, // Changed to pure black for max visibility
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: unread > 0
                              ? SchoolManagementSystemApp.primaryPurple
                              : Colors.black54, // Darker time stamp
                          fontSize: 13,
                          fontWeight: unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isGroup ? '$members members · $subtitle' : subtitle,
                          style: const TextStyle(
                            // Darkened Subtitle Text
                            color: Colors
                                .black, // Changed to pure black for max visibility
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: SchoolManagementSystemApp.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatWithTeacher(
    BuildContext context,
    Map<String, dynamic> teacher,
  ) {
    // Reset unread count when opening chat
    final teacherName = teacher['name'] as String;
    setState(() {
      _unreadCounts[teacherName] = 0;
      // Update the teacher in the list
      final teacherIndex = _teachers.indexWhere((t) => t['name'] == teacherName);
      if (teacherIndex != -1) {
        _teachers[teacherIndex]['unread'] = 0;
      }
    });
    
    // Close the parent dialog, then open the teacher chat as a full-screen route
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TeacherChatScreen(teacher: teacher),
      ),
    );
  }
  
  // Method to update unread count (can be called from chat screen)
  void _updateUnreadCount(String teacherName, {bool increment = true}) {
    setState(() {
      if (increment) {
        _unreadCounts[teacherName] = (_unreadCounts[teacherName] ?? 0) + 1;
      } else {
        _unreadCounts[teacherName] = 0; // Reset when chat is opened
      }
      
      // Update the teacher in the list
      final teacherIndex = _teachers.indexWhere((t) => t['name'] == teacherName);
      if (teacherIndex != -1) {
        _teachers[teacherIndex]['unread'] = _unreadCounts[teacherName] ?? 0;
      }
    });
  }

  void _openGroup(BuildContext context, Map<String, dynamic> group) {
    // Close the parent dialog, then open the group chat as a full-screen route
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _GroupChatScreen(group: group)),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a teacher:'),
            const SizedBox(height: 8),
            ..._teachers.map(
              (teacher) => ListTile(
                leading: Text(
                  teacher['avatar'],
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  teacher['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(teacher['subject']),
                onTap: () {
                  Navigator.of(context).pop();
                  _openChatWithTeacher(context, teacher);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Implementation removed as requested in the prompt
  // _showOptions and local _showSnackBar were unused; removed to avoid
  // analyzer warnings about unused private declarations.
}

// Full-screen chat screen (uses a Scaffold) — opened from the FAB
class _WhatsAppChatScreen extends StatefulWidget {
  @override
  State<_WhatsAppChatScreen> createState() => _WhatsAppChatScreenState();
}

class _WhatsAppChatScreenState extends State<_WhatsAppChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _groups = [];
  bool _loadingTeachers = false;
  String? _schoolId; // Parent's school_id for filtering
  Map<String, int> _unreadCounts = {}; // Track unread messages per teacher

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadParentSchoolId();
    _loadTeachers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParentSchoolId() async {
    try {
      final parentData = await api.ApiService.fetchParentProfile();
      if (parentData != null) {
        _schoolId = parentData['school_id']?.toString();
        // Try to get from students if not in parent profile
        if ((_schoolId == null || _schoolId!.isEmpty || _schoolId == 'null')) {
          final students = parentData['students'];
          if (students is List && students.isNotEmpty) {
            final student = students[0];
            if (student is Map) {
              _schoolId = student['school_id']?.toString() ?? 
                         student['school']?['school_id']?.toString();
            }
          }
        }
        debugPrint('Parent school_id for filtering: $_schoolId');
      }
    } catch (e) {
      debugPrint('Failed to load parent school_id: $e');
    }
  }

  String _buildInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '👤';
    final initials = parts.take(2).map((p) => p[0]).join();
    return initials;
  }

  Future<void> _loadTeachers() async {
    setState(() => _loadingTeachers = true);
    try {
      final data = await api.ApiService.fetchTeachers();
      final mapped = data.map<Map<String, dynamic>>((t) {
        final user = t['user'] as Map<String, dynamic>? ?? {};
        final first = (user['first_name'] as String? ?? '').trim();
        final last = (user['last_name'] as String? ?? '').trim();
        final fullName = ('$first $last').trim();
        final designation = t['designation'] as String? ?? 'Teacher';
        final teacherSchoolId = t['school_id']?.toString();
        final teacherKey = fullName.isNotEmpty ? fullName : 'Teacher';
        
        // Get unread count for this teacher (default to 0 if not set)
        final unreadCount = _unreadCounts[teacherKey] ?? 0;
        
        return {
          'name': fullName.isNotEmpty ? fullName : 'Teacher',
          'subject': designation,
          'school_id': teacherSchoolId,
          'online': false,
          'unread': unreadCount, // Use tracked unread count
          'lastMessage': '',
          'time': '',
          'avatar': _buildInitials(fullName.isNotEmpty ? fullName : 'T'),
        };
      }).toList();
      
      // Filter teachers by matching school_id (if parent has school_id)
      final filteredTeachers = _schoolId != null && _schoolId!.isNotEmpty
          ? mapped.where((teacher) {
              final teacherSchoolId = teacher['school_id']?.toString();
              final matches = teacherSchoolId == null || teacherSchoolId == _schoolId;
              if (!matches) {
                debugPrint('Filtered out teacher - school_id mismatch: teacher=$teacherSchoolId, parent=$_schoolId');
              }
              return matches;
            }).toList()
          : mapped;
      
      setState(() {
        _teachers = filteredTeachers;
        _groups = [
          {
            'name': 'All Teachers',
            'members': _teachers.length,
            'unread': 0,
            'lastMessage': '',
            'time': '',
            'avatar': '👥',
          },
        ];
      });
    } catch (e) {
      debugPrint('Failed to load teachers: $e');
    } finally {
      if (mounted) setState(() => _loadingTeachers = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    if (_loadingTeachers) return [];
    
    // First filter by school_id match (if parent has school_id)
    var filtered = _teachers;
    if (_schoolId != null && _schoolId!.isNotEmpty) {
      filtered = _teachers.where((teacher) {
        final teacherSchoolId = teacher['school_id']?.toString();
        return teacherSchoolId == null || teacherSchoolId == _schoolId;
      }).toList();
    }
    
    // Then apply search filter
    if (_searchQuery.isEmpty) return filtered;
    return filtered
        .where(
          (teacher) =>
              teacher['name'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              teacher['subject'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  List<Map<String, dynamic>> get _filteredGroups {
    if (_loadingTeachers) return [];
    if (_searchQuery.isEmpty) return _groups;
    return _groups
        .where(
          (group) =>
              group['name'].toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SchoolManagementSystemApp.primaryPurple,
        title: const Text('School Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search teachers, groups...',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: SchoolManagementSystemApp.primaryPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: SchoolManagementSystemApp.primaryPurple,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.chat), text: 'Chats'),
                Tab(icon: Icon(Icons.group), text: 'Groups'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildChatsTab(), _buildGroupsTab()],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showNewChatDialog(context),
              backgroundColor: SchoolManagementSystemApp.primaryPurple,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Start New Chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    return Container(
      color: Colors.grey.shade50,
      child: _filteredTeachers.isEmpty
          ? const Center(
              child: Text(
                'No teachers found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeachers[index];
                return _buildChatTile(
                  avatar: teacher['avatar'],
                  name: teacher['name'],
                  subtitle: teacher['subject'] ?? teacher['lastMessage'] ?? '',
                  time: teacher['time'],
                  unread: teacher['unread'],
                  online: teacher['online'],
                  onTap: () => _openChatWithTeacher(context, teacher),
                );
              },
            ),
    );
  }

  Widget _buildGroupsTab() {
    return Container(
      color: Colors.grey.shade50,
      child: _filteredGroups.isEmpty
          ? const Center(
              child: Text(
                'No groups found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final group = _filteredGroups[index];
                return _buildChatTile(
                  avatar: group['avatar'],
                  name: group['name'],
                  subtitle: group['lastMessage'],
                  time: group['time'],
                  unread: group['unread'],
                  isGroup: true,
                  members: group['members'],
                  onTap: () => _openGroup(context, group),
                );
              },
            ),
    );
  }

  // Reuse helper methods from the dialog version by copying the same names
  Widget _buildChatTile({
    required String avatar,
    required String name,
    required String subtitle,
    required String time,
    int unread = 0,
    bool online = false,
    bool isGroup = false,
    int members = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SchoolManagementSystemApp.primaryPurple.withOpacity(
                      0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                if (online && !isGroup)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: unread > 0
                              ? SchoolManagementSystemApp.primaryPurple
                              : Colors.black54,
                          fontSize: 13,
                          fontWeight: unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isGroup ? '$members members · $subtitle' : subtitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: SchoolManagementSystemApp.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatWithTeacher(
    BuildContext context,
    Map<String, dynamic> teacher,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _TeacherChatScreen(teacher: teacher),
      ),
    );
  }

  void _openGroup(BuildContext context, Map<String, dynamic> group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _GroupChatScreen(group: group)),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a teacher:'),
            const SizedBox(height: 8),
            ..._teachers.map(
              (teacher) => ListTile(
                leading: Text(
                  teacher['avatar'],
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  teacher['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(teacher['subject']),
                onTap: () {
                  Navigator.of(context).pop();
                  _openChatWithTeacher(context, teacher);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // (no local _showSnackBar needed here)
}

// -------------------------------------------------------------------------
// Teacher Chat Screen
// -------------------------------------------------------------------------

class _TeacherChatScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;
  const _TeacherChatScreen({required this.teacher});

  @override
  State<_TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<_TeacherChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = true;

  // State variable to track if text field is empty
  bool _isTextFieldEmpty = true;
  RealtimeChatService? _chatService;
  StreamSubscription? _chatSubscription;
  String? _chatRoomId;
  String? _studentUsername; // Display name (used for room ID)
  String? _teacherUsername; // Display name (used for room ID)
  String? _studentEmail; // Student email/username for API calls and message saving
  String? _teacherEmail; // Teacher email/username for API calls and message saving
  
  // Helper function to normalize names for room IDs
  String normalizeNameForRoomId(String name) {
    if (name.isEmpty) return '';
    // Convert to lowercase, replace spaces with underscores, remove special characters
    return name
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // Keep only alphanumeric and underscore
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateTextFieldState);
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateTextFieldState);
    _messageController.dispose();
    _chatSubscription?.cancel();
    _chatService?.disconnect();
    super.dispose();
  }

  void _updateTextFieldState() {
    final isEmpty = _messageController.text.isEmpty;
    if (_isTextFieldEmpty != isEmpty) {
      setState(() {
        _isTextFieldEmpty = isEmpty;
      });
    }
  }

  void _sendMessage() {
    final trimmed = _messageController.text.trim();
    if (trimmed.isEmpty) return;
    
    if (_studentUsername == null || _studentUsername!.isEmpty) {
      debugPrint('Cannot send message: student name not initialized');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, initializing chat...')),
      );
      _initializeChat(); // Retry initialization
      return;
    }
    
    if (_teacherUsername == null || _teacherUsername!.isEmpty) {
      debugPrint('Cannot send message: teacher username not initialized');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher information not available.')),
      );
      return;
    }
    
    // Add to UI immediately
    setState(() {
      _messages.add({
        'text': trimmed,
        'isTeacher': false,
        'time': intl.DateFormat('hh:mm a').format(DateTime.now()),
      });
      _messageController.clear();
    });
    
    if (_chatService == null) {
      debugPrint('Cannot send message: chat service not initialized');
      _initializeRealtimeChat().catchError((error) {
        debugPrint('Failed to reconnect: $error');
      });
      return;
    }
    
    try {
      if (_chatService!.isConnected) {
        // Use emails/usernames for message saving (backend expects usernames)
        // But room ID uses names (already set)
        final senderForWs = _studentEmail ?? _studentUsername!;
        final recipientForWs = _teacherEmail ?? _teacherUsername!;
        
        _chatService!.sendMessage(
          sender: senderForWs,
          recipient: recipientForWs,
          message: trimmed,
        );
        debugPrint('Message sent: student name=$_studentUsername, teacher=$_teacherUsername');
        debugPrint('WebSocket sender=$senderForWs, recipient=$recipientForWs');
      } else {
        debugPrint('Chat service not connected, reconnecting...');
        _initializeRealtimeChat();
      }
    } catch (error) {
      debugPrint('Realtime chat send error: $error');
    }
  }

  void _sendVoiceMessage() {
    _showSnackBar("Recording voice message...");
    // Implement actual recording logic here (start/stop)
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isLoadingMessages = true;
      });
      
      // Fetch parent profile to get student data
      Map<String, dynamic>? parentData = await api.ApiService.fetchParentProfile();
      debugPrint('Parent data received: ${parentData?.keys}');
      
      // If parent profile is null, try to fetch student profile as fallback
      // (since parent and student are in same portal)
      if (parentData == null) {
        debugPrint('Parent profile is null, trying student profile as fallback...');
        try {
          final studentData = await api.ApiService.fetchStudentProfile();
          if (studentData != null) {
            debugPrint('Found student profile, converting to parent-like structure');
            debugPrint('Student data keys: ${studentData.keys}');
            debugPrint('Student name from profile: ${studentData['student_name']}');
            
            // Convert student data to parent-like structure
            parentData = {
              'user': studentData['user'],
              'students': [studentData], // Wrap student in students array
              'school_id': studentData['school_id'],
              'school_name': studentData['school_name'],
              // Add student_name at top level for easier access
              'student_name': studentData['student_name'],
            };
            debugPrint('Converted student profile to parent-like structure');
            debugPrint('Student name in converted data: ${parentData['student_name']}');
          } else {
            debugPrint('Student profile is also null');
          }
        } catch (e) {
          debugPrint('Failed to fetch student profile as fallback: $e');
        }
      }
      
      if (parentData != null) {
        // First, try to get student_name directly from parentData (for student profile fallback)
        if (parentData.containsKey('student_name')) {
          final studentNameValue = parentData['student_name'];
          final directStudentName = studentNameValue != null ? studentNameValue.toString().trim() : null;
          if (directStudentName != null && directStudentName.isNotEmpty && directStudentName != 'null') {
            debugPrint('✓ Found student_name directly in parentData: $directStudentName');
            _studentUsername = directStudentName;
            
            // Also extract username/email for room ID
        final students = parentData['students'];
        if (students is List && students.isNotEmpty) {
              final firstStudent = students[0] as Map<String, dynamic>?;
              if (firstStudent != null) {
                // Room ID will use student name (no email needed)
                debugPrint('  Student name for room ID: $_studentUsername');
              }
            }
          }
        }
        
        final students = parentData['students'];
        debugPrint('Students in parent data: ${students is List ? students.length : 'not a list'}');
        
        if (students is List && students.isNotEmpty) {
          // Iterate through all students to find one with valid name
          Map<String, dynamic>? validStudentData;
          String? extractedStudentName;
          
          debugPrint('Processing ${students.length} students from parent profile...');
          
          for (var studentItem in students) {
            if (studentItem is Map<String, dynamic>) {
              debugPrint('Student item keys: ${studentItem.keys}');
              final studentUser = studentItem['user'] as Map<String, dynamic>?;
              
              // Try to get student name - check multiple fields
              String studentName = '';
              
              // Priority 1: student_name field (MOST IMPORTANT - this is the actual student name like "rakesh")
              if (studentItem['student_name'] != null) {
                final studentNameValue = studentItem['student_name'].toString().trim();
                if (studentNameValue.isNotEmpty && studentNameValue != 'null' && studentNameValue.toLowerCase() != 'null') {
                  studentName = studentNameValue;
                  debugPrint('✓ Found student_name: $studentName');
                }
              }
              
              // Priority 2: name field
              if (studentName.isEmpty && studentItem['name'] != null) {
                final nameValue = studentItem['name'].toString().trim();
                if (nameValue.isNotEmpty && nameValue != 'null') {
                  studentName = nameValue;
                  debugPrint('Found name field: $studentName');
                }
              }
              
              // Priority 3: user's first_name + last_name
              if (studentName.isEmpty && studentUser != null) {
                final firstName = (studentUser['first_name'] as String? ?? '').trim();
                final lastName = (studentUser['last_name'] as String? ?? '').trim();
                if (firstName.isNotEmpty || lastName.isNotEmpty) {
                  studentName = '$firstName $lastName'.trim();
                  debugPrint('Found name from user: $studentName');
                }
              }
              
              // Use the first student with a valid name
              if (studentName.isNotEmpty) {
                validStudentData = studentItem;
                extractedStudentName = studentName;
                debugPrint('✓ Selected student: $studentName');
                break;
              } else {
                debugPrint('✗ Skipped student - no valid name found');
              }
            } else {
              debugPrint('✗ Student item is not a Map: ${studentItem.runtimeType}');
            }
          }
          
          if (validStudentData != null && extractedStudentName != null) {
            _studentUsername = extractedStudentName;
            
            // Get teacher username/name/email
            final teacherUser = widget.teacher['user'] as Map<String, dynamic>?;
            String teacherFirstName = '';
            String teacherLastName = '';
            String teacherEmail = '';
            String teacherUsername = '';
            if (teacherUser != null) {
              teacherFirstName = (teacherUser['first_name'] as String? ?? '').trim();
              teacherLastName = (teacherUser['last_name'] as String? ?? '').trim();
              teacherEmail = teacherUser['email'] as String? ?? '';
              teacherUsername = teacherUser['username'] as String? ?? '';
            }
            final teacherFullName = '$teacherFirstName $teacherLastName'.trim();
            final teacherName = (widget.teacher['name'] as String? ?? '').trim();
            final finalTeacherName = teacherName.isNotEmpty ? teacherName : teacherFullName;
            
            _teacherUsername = finalTeacherName.isNotEmpty 
                ? finalTeacherName 
                : 'Teacher';
            
            // Store emails/usernames for API calls and message saving
            final studentUser = validStudentData['user'] as Map<String, dynamic>?;
            final studentEmailValue = validStudentData['email']?.toString() ?? 
                                     studentUser?['email']?.toString() ?? '';
            final studentUsernameValue = studentUser?['username']?.toString();
            _studentEmail = studentUsernameValue ?? 
                          (studentEmailValue.isNotEmpty ? studentEmailValue : '');
            
            _teacherEmail = teacherUsername.isNotEmpty ? teacherUsername : 
                          (teacherEmail.isNotEmpty ? teacherEmail : '');
            
            debugPrint('Student name set: $_studentUsername, Teacher: $_teacherUsername');
            debugPrint('Student email/username for API: $_studentEmail, Teacher email/username: $_teacherEmail');
            
            // Create room ID using names only (no email fallback)
            if ((_studentUsername != null && _studentUsername!.isNotEmpty) &&
                (_teacherUsername != null && _teacherUsername!.isNotEmpty)) {
              final normalizedStudentName = normalizeNameForRoomId(_studentUsername!);
              final normalizedTeacherName = normalizeNameForRoomId(_teacherUsername!);
              
              if (normalizedStudentName.isNotEmpty && normalizedTeacherName.isNotEmpty) {
                final identifiers = [normalizedStudentName, normalizedTeacherName]..sort();
                _chatRoomId = identifiers.join('_');
                debugPrint('Room ID using names - Student: $_studentUsername -> $normalizedStudentName');
                debugPrint('  Teacher: $_teacherUsername -> $normalizedTeacherName');
                debugPrint('  Final room ID: $_chatRoomId');
            } else {
                debugPrint('ERROR: Normalized names are empty (student: $normalizedStudentName, teacher: $normalizedTeacherName)');
                _chatRoomId = null;
              }
            } else {
              debugPrint('ERROR: Student or teacher name is missing (student: $_studentUsername, teacher: $_teacherUsername)');
              _chatRoomId = null;
            }
            
            debugPrint('Chat initialized - student: $_studentUsername, teacher: $_teacherUsername, room: $_chatRoomId');
            
            // Load existing messages from API
            await _loadExistingMessages();
            
            // Initialize real-time chat
            _initializeRealtimeChat();
            
            setState(() {
              _isLoadingMessages = false;
            });
            return;
          } else {
            debugPrint('No valid student found with name in students list');
        }
        } else {
          debugPrint('No students found in parent profile. Students: $students');
          
          // Try to find student data in a different structure or retry with better extraction
          // Check if students might be in a different format
          if (students == null || (students is List && students.isEmpty)) {
            debugPrint('Students list is empty or null, checking alternative data structures...');
            
            // Try to get student from any available source
            Map<String, dynamic>? alternativeStudentData;
            
            // Check if there's student data elsewhere in parentData
            if (parentData.containsKey('student')) {
              alternativeStudentData = parentData['student'] as Map<String, dynamic>?;
              debugPrint('Found student data in parentData[\'student\']');
            }
            
            // If still no student found, use parent as last resort but try to get student name from elsewhere
            if (alternativeStudentData == null) {
              debugPrint('No alternative student data found, will use parent info but prefer student name if available');
            } else {
              // Process alternative student data
              final studentUser = alternativeStudentData['user'] as Map<String, dynamic>?;
              String studentName = '';
              if (alternativeStudentData['student_name'] != null && 
                  alternativeStudentData['student_name'].toString().trim().isNotEmpty) {
                studentName = alternativeStudentData['student_name'].toString().trim();
              } else if (studentUser != null) {
                final firstName = (studentUser['first_name'] as String? ?? '').trim();
                final lastName = (studentUser['last_name'] as String? ?? '').trim();
                studentName = '$firstName $lastName'.trim();
              }
              
              if (studentName.isNotEmpty) {
                _studentUsername = studentName;
                
                // Get student email/username for API calls
                final studentEmailValue = alternativeStudentData['email']?.toString() ?? 
                                         studentUser?['email']?.toString() ?? '';
                final studentUsernameValue = studentUser?['username']?.toString();
                _studentEmail = studentUsernameValue ?? 
                              (studentEmailValue.isNotEmpty ? studentEmailValue : '');
                
                // Get teacher info
                final teacherUser = widget.teacher['user'] as Map<String, dynamic>?;
                String teacherFirstName = '';
                String teacherLastName = '';
                String teacherEmail = '';
                String teacherUsername = '';
                if (teacherUser != null) {
                  teacherFirstName = (teacherUser['first_name'] as String? ?? '').trim();
                  teacherLastName = (teacherUser['last_name'] as String? ?? '').trim();
                  teacherEmail = teacherUser['email'] as String? ?? '';
                  teacherUsername = teacherUser['username'] as String? ?? '';
                }
                final teacherFullName = '$teacherFirstName $teacherLastName'.trim();
                final teacherName = (widget.teacher['name'] as String? ?? '').trim();
                final finalTeacherName = teacherName.isNotEmpty ? teacherName : teacherFullName;
                
                _teacherUsername = finalTeacherName.isNotEmpty 
                    ? finalTeacherName 
                    : 'Teacher';
                
                _teacherEmail = teacherUsername.isNotEmpty ? teacherUsername : 
                              (teacherEmail.isNotEmpty ? teacherEmail : '');
                
                // Create room ID using names only (no email fallback)
                if ((_studentUsername != null && _studentUsername!.isNotEmpty) &&
                    (_teacherUsername != null && _teacherUsername!.isNotEmpty)) {
                  final normalizedStudentName = normalizeNameForRoomId(_studentUsername!);
                  final normalizedTeacherName = normalizeNameForRoomId(_teacherUsername!);
                  
                  if (normalizedStudentName.isNotEmpty && normalizedTeacherName.isNotEmpty) {
                    final identifiers = [normalizedStudentName, normalizedTeacherName]..sort();
                    _chatRoomId = identifiers.join('_');
                  } else {
                    _chatRoomId = null;
                  }
                  
                  debugPrint('Using alternative student data - student: $_studentUsername, teacher: $_teacherUsername');
                  debugPrint('Room ID: $_chatRoomId');
                  await _loadExistingMessages();
      _initializeRealtimeChat();
      setState(() {
        _isLoadingMessages = false;
      });
                  return;
                }
              }
            }
          }
          
          // Since parent and student are in same portal, try to use parent user as fallback
          // But first, try to extract student name from any available source
          final parentUser = parentData['user'] as Map<String, dynamic>?;
          final parentEmail = parentUser?['email']?.toString() ?? '';
          final parentFirstName = parentUser?['first_name']?.toString() ?? '';
          final parentLastName = parentUser?['last_name']?.toString() ?? '';
          final parentName = '$parentFirstName $parentLastName'.trim();
          
          // Try to get student name from parent profile if available
          String? studentNameFromParent;
          if (parentData.containsKey('student_name')) {
            studentNameFromParent = (parentData['student_name'] as String?)?.trim();
            if (studentNameFromParent != null && studentNameFromParent.isNotEmpty) {
              debugPrint('Found student_name in parent profile: $studentNameFromParent');
            }
          }
          
          if (parentEmail.isNotEmpty || parentName.isNotEmpty) {
            // Use student name if found, otherwise use parent name, but never use "Parent" as default
            _studentUsername = studentNameFromParent ?? (parentName.isNotEmpty ? parentName : 'Student');
            
            final teacherUser = widget.teacher['user'] as Map<String, dynamic>?;
            String teacherFirstName = '';
            String teacherLastName = '';
            if (teacherUser != null) {
              teacherFirstName = (teacherUser['first_name'] as String? ?? '').trim();
              teacherLastName = (teacherUser['last_name'] as String? ?? '').trim();
            }
            final teacherFullName = '$teacherFirstName $teacherLastName'.trim();
            final teacherName = (widget.teacher['name'] as String? ?? '').trim();
            final finalTeacherName = teacherName.isNotEmpty ? teacherName : teacherFullName;
            
            _teacherUsername = finalTeacherName.isNotEmpty 
                ? finalTeacherName 
                : 'Teacher';
            
            // Create room ID using names only (no email fallback)
            if ((_studentUsername != null && _studentUsername!.isNotEmpty) &&
                (_teacherUsername != null && _teacherUsername!.isNotEmpty)) {
              final normalizedStudentName = normalizeNameForRoomId(_studentUsername!);
              final normalizedTeacherName = normalizeNameForRoomId(_teacherUsername!);
              
              if (normalizedStudentName.isNotEmpty && normalizedTeacherName.isNotEmpty) {
                final identifiers = [normalizedStudentName, normalizedTeacherName]..sort();
                _chatRoomId = identifiers.join('_');
              } else {
                _chatRoomId = null;
              }
              
              debugPrint('Using parent as fallback - student: $_studentUsername, teacher: $_teacherUsername');
              await _loadExistingMessages();
              _initializeRealtimeChat();
              setState(() {
                _isLoadingMessages = false;
              });
              return;
            }
          }
        }
      } else {
        debugPrint('Parent data is null');
      }
      
      // Final fallback: retry student extraction with more thorough checking
      debugPrint('Using final fallback for chat initialization - retrying student extraction');
      try {
        Map<String, dynamic>? parentData = await api.ApiService.fetchParentProfile();
        
        // If parent profile is null, try student profile as fallback
        if (parentData == null) {
          debugPrint('Parent profile is null in final fallback, trying student profile...');
          try {
            final studentData = await api.ApiService.fetchStudentProfile();
            if (studentData != null) {
              debugPrint('Found student profile in final fallback');
              debugPrint('Student name from profile: ${studentData['student_name']}');
              debugPrint('Student email: ${studentData['email']}');
              
              parentData = {
                'user': studentData['user'],
                'students': [studentData],
                'school_id': studentData['school_id'],
                'school_name': studentData['school_name'],
                'student_name': studentData['student_name'], // Add for direct access
              };
              
              // Immediately try to extract student name from the converted data
              if (studentData['student_name'] != null) {
                final name = studentData['student_name'].toString().trim();
                if (name.isNotEmpty && name != 'null') {
                  _studentUsername = name;
                  debugPrint('✓ Set student name from student profile: $_studentUsername');
                  
                  debugPrint('  Student name for room ID: $_studentUsername');
                }
              }
            }
    } catch (e) {
            debugPrint('Failed to fetch student profile in final fallback: $e');
          }
        }
        
        if (parentData != null) {
          // Retry students extraction with more thorough checking
          final students = parentData['students'];
          debugPrint('Final fallback - Students type: ${students.runtimeType}, is List: ${students is List}');
          
          if (students is List && students.isNotEmpty) {
            debugPrint('Final fallback - Found ${students.length} students, retrying extraction...');
            
            for (var studentItem in students) {
              if (studentItem is Map<String, dynamic>) {
                debugPrint('Final fallback - Student keys: ${studentItem.keys}');
                final studentUser = studentItem['user'] as Map<String, dynamic>?;
                
                // Try multiple ways to get student name
                String studentName = '';
                
                // Check student_name (MOST IMPORTANT - actual student name like "rakesh")
                if (studentItem['student_name'] != null) {
                  final val = studentItem['student_name'].toString().trim();
                  if (val.isNotEmpty && val != 'null' && val.toLowerCase() != 'null') {
                    studentName = val;
                    debugPrint('✓ Final fallback - Found student_name: $studentName');
                  }
                }
                
                // Check name field
                if (studentName.isEmpty && studentItem['name'] != null) {
                  final val = studentItem['name'].toString().trim();
                  if (val.isNotEmpty && val != 'null') studentName = val;
                }
                
                // Check user first_name + last_name
                if (studentName.isEmpty && studentUser != null) {
                  final firstName = (studentUser['first_name'] as String? ?? '').trim();
                  final lastName = (studentUser['last_name'] as String? ?? '').trim();
                  if (firstName.isNotEmpty || lastName.isNotEmpty) {
                    studentName = '$firstName $lastName'.trim();
                  }
                }
                
                if (studentName.isNotEmpty) {
                  _studentUsername = studentName;
                  debugPrint('✓ Final fallback - Found student: $_studentUsername');
                  break;
                }
              }
            }
          }
          
          // If still no student name found, check if parent profile has student_name directly
          if ((_studentUsername == null || _studentUsername!.isEmpty) && parentData.containsKey('student_name')) {
            final studentNameFromProfile = (parentData['student_name'] as String?)?.trim();
            if (studentNameFromProfile != null && studentNameFromProfile.isNotEmpty && studentNameFromProfile != 'null') {
              _studentUsername = studentNameFromProfile;
              debugPrint('✓ Found student_name in parent profile: $_studentUsername');
            }
          }
          
          // Last resort: use parent name but log warning
          if (_studentUsername == null || _studentUsername!.isEmpty) {
            final parentUser = parentData['user'] as Map<String, dynamic>?;
            if (parentUser != null) {
              final parentFirstName = (parentUser['first_name'] as String? ?? '').trim();
              final parentLastName = (parentUser['last_name'] as String? ?? '').trim();
              final parentName = '$parentFirstName $parentLastName'.trim();
              _studentUsername = parentName.isNotEmpty ? parentName : 'Student';
              debugPrint('⚠ WARNING: Using parent name as student name: $_studentUsername');
            } else {
              _studentUsername = 'Student';
            }
          }
        } else {
          _studentUsername = 'Student';
        }
      } catch (e) {
        debugPrint('Error in final fallback: $e');
        _studentUsername = 'Student';
      }
      
      // Get teacher info for final fallback
      final teacherUser = widget.teacher['user'] as Map<String, dynamic>?;
      String teacherFirstName = '';
      String teacherLastName = '';
      if (teacherUser != null) {
        teacherFirstName = (teacherUser['first_name'] as String? ?? '').trim();
        teacherLastName = (teacherUser['last_name'] as String? ?? '').trim();
      }
      final teacherFullName = '$teacherFirstName $teacherLastName'.trim();
      final teacherName = (widget.teacher['name'] as String? ?? '').trim();
      final finalTeacherName = teacherName.isNotEmpty ? teacherName : (teacherFullName.isNotEmpty ? teacherFullName : 'Teacher');
      _teacherUsername = finalTeacherName;
      
      // Create room ID using names only (no email fallback)
      if ((_studentUsername != null && _studentUsername!.isNotEmpty) &&
          (_teacherUsername != null && _teacherUsername!.isNotEmpty)) {
        final normalizedStudentName = normalizeNameForRoomId(_studentUsername!);
        final normalizedTeacherName = normalizeNameForRoomId(_teacherUsername!);
        
        if (normalizedStudentName.isNotEmpty && normalizedTeacherName.isNotEmpty) {
          final identifiers = [normalizedStudentName, normalizedTeacherName]..sort();
          _chatRoomId = identifiers.join('_');
          debugPrint('Final fallback room ID: $_chatRoomId');
          debugPrint('  Student: $_studentUsername -> $normalizedStudentName');
          debugPrint('  Teacher: $_teacherUsername -> $normalizedTeacherName');
        } else {
          _chatRoomId = null;
          debugPrint('ERROR: Normalized names are empty (student: $normalizedStudentName, teacher: $normalizedTeacherName)');
        }
      } else {
        _chatRoomId = null;
        debugPrint('ERROR: Student or teacher name is missing (student: $_studentUsername, teacher: $_teacherUsername)');
      }
      
      _initializeRealtimeChat();
      setState(() {
        _isLoadingMessages = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing chat: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _loadExistingMessages() async {
    if (_studentEmail == null || _teacherEmail == null) {
      debugPrint('Cannot load messages: missing email/username (student: $_studentEmail, teacher: $_teacherEmail)');
      return;
    }
    
    try {
      // Fetch messages using email/username identifiers (backend expects usernames/emails)
      final messages = await api.ApiService.fetchCommunications(_studentEmail!, _teacherEmail!);
      
      debugPrint('Loaded ${messages.length} existing messages');
      
      setState(() {
        _messages = messages.map((msg) {
          final sender = msg['sender'] as Map<String, dynamic>?;
          final senderUsername = sender?['username']?.toString() ?? '';
          final senderEmail = sender?['email']?.toString() ?? '';
          final senderFirstName = sender?['first_name']?.toString() ?? '';
          final senderLastName = sender?['last_name']?.toString() ?? '';
          final senderName = '$senderFirstName $senderLastName'.trim();
          
          // Check if sender is teacher by comparing username, email, or name
          final isTeacher = senderUsername == _teacherUsername || 
                           senderEmail == _teacherUsername ||
                           senderName == _teacherUsername ||
                           (widget.teacher['user'] != null && 
                            (widget.teacher['user'] as Map)['username']?.toString() == senderUsername);
          
          return {
            'text': msg['message']?.toString() ?? msg['subject']?.toString() ?? '',
            'isTeacher': isTeacher,
            'time': _formatMessageTime(msg['created_at']?.toString()),
          };
        }).toList();
      });
      
      debugPrint('Processed ${_messages.length} messages for display');
    } catch (e) {
      debugPrint('Failed to load existing messages: $e');
    }
  }

  String _formatMessageTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return intl.DateFormat('hh:mm a').format(DateTime.now());
    }
    try {
      final dateTime = DateTime.parse(timeStr);
      return intl.DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return intl.DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  Future<void> _initializeRealtimeChat() async {
    if (_chatRoomId == null || _studentUsername == null || _teacherUsername == null) return;
    
    try {
      debugPrint('=== Student Chat Connection ===');
      debugPrint('Room ID: $_chatRoomId');
      debugPrint('Student name: $_studentUsername');
      debugPrint('Teacher username: $_teacherUsername');
      debugPrint('Chat type: teacher-student');
      
      _chatService = RealtimeChatService(baseWsUrl: 'ws://localhost:8000'); // Use localhost for web
      await _chatService!.connect(roomId: _chatRoomId!, chatType: 'teacher-student');
      _chatSubscription = _chatService!.stream?.listen((event) {
        try {
          final payload = event is String ? event : event.toString();
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          
          final messageType = decoded['type']?.toString() ?? 'message';
          
          // Handle connection messages
          if (messageType == 'connection') {
            debugPrint('Connected to chat: ${decoded['user']}');
            return;
          }
          
          // Only process actual messages
          if (messageType == 'message') {
            final messageText = decoded['message']?.toString() ?? '';
            if (messageText.isEmpty) return;
            
            final sender = decoded['sender']?.toString() ?? '';
            
            // Determine if sender is teacher by comparing with teacher's username/email
            final teacherUser = widget.teacher['user'] as Map<String, dynamic>?;
            final teacherUsername = teacherUser?['username']?.toString() ?? '';
            final teacherEmail = teacherUser?['email']?.toString() ?? '';
            final teacherName = widget.teacher['name']?.toString() ?? '';
            
            final isTeacher = sender == teacherUsername || 
                            sender == teacherEmail ||
                            sender == teacherName ||
                            sender == _teacherUsername ||
                            sender == 'teacher';
            
            debugPrint('Received message from: $sender (isTeacher: $isTeacher, message: $messageText)');
            
            // Check if message already exists to avoid duplicates
            final messageExists = _messages.any((msg) => 
              msg['text'] == messageText && 
              msg['isTeacher'] == isTeacher
            );
            
            if (!messageExists) {
            setState(() {
              _messages.add({
                'text': messageText,
                'isTeacher': isTeacher,
                'time': intl.DateFormat('hh:mm a').format(DateTime.now()),
              });
            });
              debugPrint('Added new message to list (total: ${_messages.length})');
            } else {
              debugPrint('Message already exists, skipping duplicate');
            }
          } else if (messageType == 'error') {
            debugPrint('Chat error: ${decoded['message']}');
          }
        } catch (error) {
          debugPrint('Realtime chat parse error: $error');
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize realtime chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SchoolManagementSystemApp.primaryPurple,
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    widget.teacher['avatar'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.teacher['name'] ?? 'Teacher',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (widget.teacher['subject'] != null)
                          Text(
                            'Subject: ${widget.teacher['subject']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        if (widget.teacher['class_assigned'] != null || widget.teacher['classes_assigned'] != null)
                          Text(
                            'Class Assigned: ${widget.teacher['class_assigned'] ?? widget.teacher['classes_assigned'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        if (widget.teacher['subject'] == null && widget.teacher['class_assigned'] == null && widget.teacher['classes_assigned'] == null)
                          Text(
                            widget.teacher['online'] ? 'Online' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Removed video and audio call buttons as requested.
                ],
              ),
            ),
            // Messages
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: _isLoadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              'No messages yet. Start the conversation!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessage(
                      message['text'],
                      message['isTeacher'],
                      message['time'],
                    );
                  },
                ),
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: SchoolManagementSystemApp.primaryPurple,
                    ),
                    onPressed: () => _showSnackBar("Attach file dialog"),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) {
                        // Only handle submission if the send button is active (text mode)
                        if (!_isTextFieldEmpty) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Voice/Send Button logic
                  _isTextFieldEmpty
                      ? // Show voice button if text field is empty
                        GestureDetector(
                          onLongPress: _sendVoiceMessage,
                          onLongPressUp: () => _showSnackBar(
                            "Voice recording stopped. Message sent!",
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SchoolManagementSystemApp.primaryPurple,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic, color: Colors.white),
                          ),
                        )
                      : // Show send button if text field has text
                        FloatingActionButton(
                          mini: true,
                          onPressed: _sendMessage,
                          backgroundColor:
                              SchoolManagementSystemApp.primaryPurple,
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, bool isTeacher, String time) {
    return Align(
      alignment: isTeacher ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: isTeacher
              ? Colors.white
              : SchoolManagementSystemApp.primaryPurple,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                // UPDATED: Changed text color to pure black/white for maximum contrast
                color: isTeacher ? Colors.black : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                // UPDATED: Increased contrast on timestamps
                color: isTeacher ? Colors.black54 : Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// -------------------------------------------------------------------------
// Group Chat Screen
// -------------------------------------------------------------------------

class _GroupChatScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  const _GroupChatScreen({required this.group});

  @override
  State<_GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<_GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Parent meeting scheduled for Friday at 3 PM',
      'sender': 'Admin',
      'time': '1:15 PM',
    },
    {
      'text': 'Thanks for the update!',
      'sender': 'Sarah\'s Mom',
      'time': '1:16 PM',
    },
    {
      'text': 'Will there be a virtual option?',
      'sender': 'John\'s Dad',
      'time': '1:18 PM',
    },
    {
      'text': 'Yes, we\'ll share the meeting link tomorrow.',
      'sender': 'Admin',
      'time': '1:20 PM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'sender': 'You',
          'time': 'Just now',
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SchoolManagementSystemApp.primaryPurple,
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    widget.group['avatar'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${widget.group['members']} members',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () => _showSnackBar("Group Info"),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message['sender'] == 'You';
                    return _buildGroupMessage(
                      message['text'],
                      message['sender'],
                      message['time'],
                      isMe,
                    );
                  },
                ),
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: SchoolManagementSystemApp.primaryPurple,
                    ),
                    onPressed: () => _showSnackBar("Attach file dialog"),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _sendMessage,
                    backgroundColor: SchoolManagementSystemApp.primaryPurple,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupMessage(
    String text,
    String sender,
    String time,
    bool isMe,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: isMe ? SchoolManagementSystemApp.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                sender,
                style: const TextStyle(
                  // UPDATED: Changed color to green (like WhatsApp) for contrast
                  color: Color(0xFF075E54),
                  fontWeight: FontWeight.w800, // Extra bold for emphasis
                  fontSize: 13,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                // UPDATED: Changed text color to pure black/white for maximum contrast
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                // UPDATED: Increased contrast on timestamps
                color: isMe ? Colors.white : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
