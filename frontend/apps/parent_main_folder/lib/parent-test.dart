import 'package:flutter/material.dart';
import 'services/api_service.dart' as api;

void main() {
  runApp(const ParentPortalApp());
}

class ParentPortalApp extends StatelessWidget {
  const ParentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Management - Parent Portal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF6A67FC),
        fontFamily: 'Roboto',
      ),
      home: const TestManagementPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestManagementPage extends StatefulWidget {
  final String? studentId;
  const TestManagementPage({super.key, this.studentId});

  @override
  State<TestManagementPage> createState() => _TestManagementPageState();
}

class _TestManagementPageState extends State<TestManagementPage> {
  // State variables
  List<dynamic> _tests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? targetStudentId = widget.studentId;
      String? classId;
      String? sectionId;

      // Ensure we have a student ID to work with
      if (targetStudentId == null) {
          final profile = await api.ApiService.fetchStudentProfile();
          if (profile != null) {
            if (profile['student_id'] != null) {
              targetStudentId = profile['student_id'].toString();
            } else if (profile['id'] != null) {
               targetStudentId = profile['id'].toString();
            }

            // EXTRACT CLASS INFO FROM PROFILE (Now available via updated serializer)
            if (profile['student_classes'] != null && (profile['student_classes'] as List).isNotEmpty) {
                final firstClass = (profile['student_classes'] as List)[0];
                classId = firstClass['class_id']?.toString();
            }
          }
      }

      if (targetStudentId != null) {
          // If we still don't have classId, try to fetch full details (fallback)
          if (classId == null) {
              try {
                  final studentData = await api.ApiService.fetchStudentById(int.parse(targetStudentId));
                  if (studentData != null) {
                    if (studentData['student_classes'] != null && (studentData['student_classes'] as List).isNotEmpty) {
                        final firstClass = (studentData['student_classes'] as List)[0];
                        classId = (firstClass['class_obj']?['id'] ?? firstClass['class_id'])?.toString();
                    }
                  }
              } catch (e) {
                print('Error fetching extra student details for class info: $e');
              }
          }

          // 2. Fetch exams for this student with class fallback
          final exams = await api.ApiService.fetchStudentExams(
              studentId: targetStudentId,
              classId: classId,
              sectionId: sectionId
          );
          
          if (exams != null) {
            setState(() {
              _tests = exams;
              _isLoading = false;
            });
            return;
          }
      }

      
      // Fallback if no profile or empty
       setState(() {
        _isLoading = false;
        _tests = []; // Verify with user if empty state is OK
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load exams: $e";
      });
    }
  }

  void _showAction(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- Status and Icon Mapping ---
  Map<String, dynamic> _getStatusStyle(String status) {
    // Normalize status to lowercase
    final s = status.toLowerCase();
    
    if (s == 'upcoming') {
      return {
        'color': Colors.orange,
        'icon': Icons.schedule,
        'label': 'Upcoming',
        'badgeBg': Colors.orange.withValues(alpha: 0.15),
        'badgeFg': Colors.deepOrange, // Darkened manually
      };
    }
    if (s == 'completed') {
      return {
        'color': Colors.green,
        'icon': Icons.check_circle_outline,
        'label': 'Completed',
        'badgeBg': Colors.green.withValues(alpha: 0.15),
        'badgeFg': Colors.green[800],
      };
    }
     return {
      'color': Colors.grey,
      'icon': Icons.help_outline,
      'label': s.toUpperCase(),
      'badgeBg': Colors.grey.withValues(alpha: 0.15),
      'badgeFg': Colors.grey[800],
    };
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _loadData, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }

    final totalTests = _tests.length;
    final upcomingTests = _tests
        .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'upcoming')
        .length;
    final completedTests = _tests
        .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'completed')
        .length;

    // Days to Next Test
    int daysToNextTest = 0;
    try {
      final upcomingDates = _tests
          .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'upcoming')
          .map((t) => DateTime.parse(t['date'] ?? DateTime.now().toIso8601String()))
          .toList();
      upcomingDates.sort();
      if (upcomingDates.isNotEmpty) {
        final nextDate = upcomingDates.first;
        final now = DateTime.now();
        // Calculate difference in days, ignoring time for "days to"
        final nextDay = DateTime(nextDate.year, nextDate.month, nextDate.day);
        final today = DateTime(now.year, now.month, now.day);
        daysToNextTest = nextDay.difference(today).inDays;
        
        if (daysToNextTest < 0) daysToNextTest = 0;
      }
    } catch (_) {
      daysToNextTest = 0;
    }
    
    // Sort tests: Upcoming first, then by date
    // Note: This modifies the list order for display
    final sortedTests = List.from(_tests);
    sortedTests.sort((a, b) {
       // Custom sort: Upcoming at top
       final statusA = (a['status'] ?? '').toString().toLowerCase();
       final statusB = (b['status'] ?? '').toString().toLowerCase();
       if (statusA == 'upcoming' && statusB != 'upcoming') return -1;
       if (statusA != 'upcoming' && statusB == 'upcoming') return 1;
       // Then by date
       return (b['date'] ?? '').compareTo(a['date'] ?? '');
    });


    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6A67FC),
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Exams Dashboard",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              _buildStatsRow(
                totalTests,
                upcomingTests,
                completedTests,
                daysToNextTest,
              ),

              const SizedBox(height: 25),

              // Test List
              _buildUpcomingTestsSection(context, sortedTests),

              const SizedBox(height: 25),

              // Quick Actions
              _buildQuickActionsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildStatsRow(
    int total,
    int upcoming,
    int completed,
    int daysToNext,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            icon: Icons.collections_bookmark,
            iconColor: Colors.teal,
            value: total.toString(),
            label: "Total Tests",
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.hourglass_top,
            iconColor: const Color(0xFF7A63F5),
            value: upcoming.toString(),
            label: "Upcoming",
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.check_box,
            iconColor: const Color(0xFF27DFA2),
            value: completed.toString(),
            label: "Completed",
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.calendar_today,
            iconColor: Colors.redAccent,
            value: daysToNext.toString(),
            label: "Days to Next",
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTestsSection(
    BuildContext context,
    List<dynamic> tests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📅 Upcoming & Recent Tests",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 15),
        if (tests.isEmpty)
           const Padding(
             padding: EdgeInsets.all(20.0),
             child: Text("No exams scheduled found."),
           )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return _TestItemCard(
                test: test,
                style: _getStatusStyle(test['status']?.toString() ?? 'upcoming'),
                onTap: () => _showTestDetailsDialog(context, test),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚡ Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const Divider(height: 20),
          _ActionRow(
            icon: Icons.menu_book,
            label: "View Syllabus",
            onPressed: () => _showAction(context, "Syllabus requested."),
          ),
          _ActionRow(
            icon: Icons.download,
            label: "Download Materials",
            onPressed: () =>
                _showAction(context, "Materials download simulated."),
          ),
          _ActionRow(
            icon: Icons.chat,
            label: "Contact Teacher",
            onPressed: () => _showAction(context, "Opening chat with teacher."),
          ),
          _ActionRow(
            icon: Icons.help,
            label: "Request Clarification",
            onPressed: () => _showAction(context, "Clarification form opened."),
          ),
        ],
      ),
    );
  }

  void _showTestDetailsDialog(BuildContext context, dynamic test) {
    final style = _getStatusStyle(test['status']?.toString() ?? 'upcoming');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            test["title"]?.toString() ?? "Exam Details",
            style: TextStyle(color: style['color'] as Color),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow("Subject", test["subject"]),
                _detailRow("Teacher", test["teacher"]),
                _detailRow("Room", test["room"]),
                _detailRow("Date", test["date"]),
                _detailRow("Time", test["start_time"]),
                _detailRow("Duration", test["duration"]),
                const Divider(),
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(test["description"]?.toString() ?? "No description provided."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 15.5, color: Colors.black87),
      ),
    );
  }
}

// --- Reusable Component Widgets ---

class _StatCard extends StatelessWidget {
  final IconData icon; 
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, 
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: iconColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TestItemCard extends StatelessWidget {
  final dynamic test;
  final Map style;
  final VoidCallback onTap;

  const _TestItemCard({
    required this.test,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: style['color'] as Color, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      test["title"]?.toString() ?? "Exam",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        color: Color(0xFF333333),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: style['badgeBg'] as Color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      style['label'] as String,
                      style: TextStyle(
                        color: style['badgeFg'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "📅 ${test["date"] ?? 'N/A'} at ${test["start_time"] ?? 'TBA'} | ${test["subject"] ?? ''}",
                style: const TextStyle(fontSize: 13.5, color: Colors.black87),
              ),
              Text(
                "👨‍🏫 ${test["teacher"] ?? 'TBA'} in ${test["room"] ?? 'TBA'} (${test["duration"] ?? 'N/A'})",
                style: const TextStyle(fontSize: 13.5, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Info: ${test["description"] ?? ''}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Theme.of(context).primaryColor),
        label: Text(label, style: const TextStyle(fontSize: 15)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          alignment: Alignment.centerLeft,
          foregroundColor: const Color(0xFF333333),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }
}
