import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ---------------------- Main Function ----------------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const TeacherTimetableScreen(),
    );
  }
}

// ---------------------- TeacherTimetableScreen ----------------------

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  // --------------------- State Variables ---------------------
  DateTime currentWeek = DateTime.now();
  String currentView = 'weekly'; // Corresponds to the active view-btn

  // --------------------- Timetable Data ---------------------
  final Map<String, Map<String, Map<String, String>?>> timetableData = const {
    "8:00 AM": {
      "Monday": {
        "subject": "mathematics",
        "class": "Class 10A",
        "room": "Room 101",
      },
      "Tuesday": {
        "subject": "physics",
        "class": "Class 11B",
        "room": "Lab 201",
      },
      "Wednesday": {
        "subject": "mathematics",
        "class": "Class 12A",
        "room": "Room 102",
      },
      "Thursday": {
        "subject": "chemistry",
        "class": "Class 11A",
        "room": "Lab 202",
      },
      "Friday": {
        "subject": "mathematics",
        "class": "Class 10B",
        "room": "Room 101",
      },
      "Saturday": null,
    },
    "9:00 AM": {
      "Monday": {"subject": "science", "class": "Class 9A", "room": "Lab 101"},
      "Tuesday": {
        "subject": "mathematics",
        "class": "Class 10A",
        "room": "Room 101",
      },
      "Wednesday": {
        "subject": "english",
        "class": "Class 11A",
        "room": "Room 103",
      },
      "Thursday": {
        "subject": "mathematics",
        "class": "Class 12B",
        "room": "Room 102",
      },
      "Friday": {"subject": "physics", "class": "Class 11B", "room": "Lab 201"},
      "Saturday": null,
    },
    "10:00 AM": {
      "Monday": {"subject": "history", "class": "Class 8A", "room": "Room 104"},
      "Tuesday": {
        "subject": "chemistry",
        "class": "Class 12A",
        "room": "Lab 202",
      },
      "Wednesday": {
        "subject": "mathematics",
        "class": "Class 10B",
        "room": "Room 101",
      },
      "Thursday": {
        "subject": "english",
        "class": "Class 9A",
        "room": "Room 103",
      },
      "Friday": {
        "subject": "mathematics",
        "class": "Class 11A",
        "room": "Room 101",
      },
      "Saturday": null,
    },
    "11:00 AM": {
      "Monday": {
        "subject": "mathematics",
        "class": "Class 11A",
        "room": "Room 101",
      },
      "Tuesday": {
        "subject": "science",
        "class": "Class 10A",
        "room": "Lab 101",
      },
      "Wednesday": {
        "subject": "physics",
        "class": "Class 12A",
        "room": "Lab 201",
      },
      "Thursday": {
        "subject": "mathematics",
        "class": "Class 10A",
        "room": "Room 101",
      },
      "Friday": {
        "subject": "chemistry",
        "class": "Class 11B",
        "room": "Lab 202",
      },
      "Saturday": null,
    },
    "12:00 PM": {
      "Monday": null,
      "Tuesday": null,
      "Wednesday": null,
      "Thursday": null,
      "Friday": null,
      "Saturday": null,
    },
    "1:00 PM": {
      "Monday": {
        "subject": "english",
        "class": "Class 10A",
        "room": "Room 103",
      },
      "Tuesday": {
        "subject": "mathematics",
        "class": "Class 12A",
        "room": "Room 101",
      },
      "Wednesday": {
        "subject": "chemistry",
        "class": "Class 11A",
        "room": "Lab 202",
      },
      "Thursday": {
        "subject": "physics",
        "class": "Class 10B",
        "room": "Lab 201",
      },
      "Friday": {
        "subject": "english",
        "class": "Class 11A",
        "room": "Room 103",
      },
      "Saturday": null,
    },
    "2:00 PM": {
      "Monday": {"subject": "physics", "class": "Class 11A", "room": "Lab 201"},
      "Tuesday": {
        "subject": "english",
        "class": "Class 9A",
        "room": "Room 103",
      },
      "Wednesday": {
        "subject": "mathematics",
        "class": "Class 10A",
        "room": "Room 101",
      },
      "Thursday": {
        "subject": "science",
        "class": "Class 11B",
        "room": "Lab 101",
      },
      "Friday": {
        "subject": "mathematics",
        "class": "Class 12A",
        "room": "Room 102",
      },
      "Saturday": null,
    },
    "3:00 PM": {
      "Monday": {
        "subject": "chemistry",
        "class": "Class 10A",
        "room": "Lab 202",
      },
      "Tuesday": {
        "subject": "mathematics",
        "class": "Class 11B",
        "room": "Room 101",
      },
      "Wednesday": {
        "subject": "english",
        "class": "Class 12A",
        "room": "Room 103",
      },
      "Thursday": {
        "subject": "mathematics",
        "class": "Class 10B",
        "room": "Room 101",
      },
      "Friday": {"subject": "physics", "class": "Class 11A", "room": "Lab 201"},
      "Saturday": null,
    },
  };

  // ----------------------- Navigation Logic ------------------------
  void nextWeek() {
    setState(() => currentWeek = currentWeek.add(const Duration(days: 7)));
  }

  void previousWeek() {
    setState(() => currentWeek = currentWeek.subtract(const Duration(days: 7)));
  }

  void setView(String view) {
    setState(() {
      currentView = view;
      // Removed mock alerts here as the views will now render the content below
    });
  }

  String get weekDisplay {
    // Dart's weekday starts with Monday=1, Sunday=7. The logic below calculates the Monday of the current week.
    DateTime start = currentWeek.subtract(
      Duration(days: currentWeek.weekday == 7 ? 6 : currentWeek.weekday - 1),
    );
    return "Week of ${DateFormat('MMMM d, yyyy').format(start)}";
  }

  // Helper to get today's classes for the Daily view
  List<Map<String, String>> get dailyClasses {
    final today = DateFormat('EEEE').format(DateTime.now());
    List<Map<String, String>> list = [];
    for (var entry in timetableData.entries) {
      final classData = entry.value[today];
      if (classData != null) {
        list.add({...classData, 'time': entry.key});
      }
    }
    return list;
  }

  // ----------------------- UI BUILD ------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          // --- Custom AppBar Implementation (Matching Image) ---
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent, // Use Container gradient
                elevation: 0,
                // Leading: Back Arrow
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Back action
                  },
                ),
                // Title: "Teacher Timetable"
                title: const Text(
                  "Teacher Timetable",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Actions: Refresh/Loop icon and Person icon
                actions: [

                ],
              ),
            ),
          ),
          // --- END AppBar Implementation ---
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 30),
                          // Stat Cards: Horizontal, sliding view (Overflow fixed by reducing height)
                          _buildStatsHorizontalList(),
                          const SizedBox(height: 30),
                          _buildTimetableControls(),
                          const SizedBox(height: 30),
                          // Conditional content rendering based on selected view
                          _buildTimetableContent(),
                          const SizedBox(height: 20),
                          _buildLegend(),
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

  // --- Page Header Section
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // Removed the large gradient "Teacher Timetable" title as it's in the AppBar now
        SizedBox(height: 10),
        Text(
          "Manage your class schedule and view upcoming sessions",
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // --- Stats Horizontal List Section (Reduced height to fix overflow)
  Widget _buildStatsHorizontalList() {
    final List<Map<String, String>> stats = [
      {"icon": "📅", "number": "25", "label": "Classes This Week"},
      {"icon": "⏰", "number": "5", "label": "Hours Today"},
      {"icon": "👥", "number": "150", "label": "Total Students"},
      {"icon": "📚", "number": "4", "label": "Subjects"},
    ];

    return SizedBox(
      // REDUCED HEIGHT to clear vertical overflow on small screens
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Padding(
            padding: EdgeInsets.only(right: index < stats.length - 1 ? 20 : 0),
            child: _statCard(stat["icon"]!, stat["number"]!, stat["label"]!),
          );
        },
      ),
    );
  }

  Widget _statCard(String icon, String number, String label) {
    return Container(
      width: 170, // Fixed width for horizontal scrolling
      // REDUCED VERTICAL PADDING to ensure content fits
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10), // Reduced spacing
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  // --- Timetable Controls Section
  Widget _buildTimetableControls() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        // Use Wrap for layout flexibility to avoid overflow on small screens
        alignment: WrapAlignment.spaceBetween,
        spacing: 20, // Horizontal space between children
        runSpacing: 20, // Vertical space between lines when wrapping
        children: [
          // Week navigation group (FIX: Added Expanded to the Text widget)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navButton("‹", previousWeek),
              const SizedBox(width: 15),
              // FIX: Use Expanded to force the date text to wrap or shrink if necessary
              Expanded(
                child: Text(
                  weekDisplay,
                  textAlign: TextAlign
                      .center, // Added alignment for better appearance when wrapped
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              _navButton("›", nextWeek),
            ],
          ),

          // View Modes group
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _viewButton("Weekly", "weekly"),
              _viewButton("Daily", "daily"),
              _viewButton("Monthly", "monthly"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(String t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          t,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _viewButton(String name, String key) {
    bool active = currentView == key;
    return GestureDetector(
      onTap: () => setView(key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: active ? const Color(0xFF667eea) : Colors.white,
          border: Border.all(color: const Color(0xFF667eea), width: 2),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF667eea),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // --- Main Timetable Content Switcher ---
  Widget _buildTimetableContent() {
    switch (currentView) {
      case 'daily':
        return _buildDailyTimetable();
      case 'monthly':
        return _buildMonthlyView();
      case 'weekly':
      default:
        return _buildTimetableBox();
    }
  }

  // --- Weekly View (The original table) ---
  Widget _buildTimetableBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(20), // Reduced table padding slightly
          child: Table(
            border: TableBorder.all(color: const Color(0xFFE9ECEF), width: 1),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            columnWidths: const {0: IntrinsicColumnWidth(flex: 1.0)},
            children: [
              _buildTableHeader(),
              ...timetableData.entries.map(
                (entry) => _buildTableRow(entry.key, entry.value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      children: [
        _headerCell("Time"),
        _headerCell("Monday"),
        _headerCell("Tuesday"),
        _headerCell("Wednesday"),
        _headerCell("Thursday"),
        _headerCell("Friday"),
        _headerCell("Saturday"),
      ],
    );
  }

  Widget _headerCell(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Center(
        child: Text(
          t,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String time,
    Map<String, Map<String, String>?> sessions,
  ) {
    DateTime now = DateTime.now();
    String today = DateFormat('EEEE').format(now);

    return TableRow(
      children: [
        _timeCell(time),
        ...[
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
        ].map((day) {
          bool highlight = (day == today);
          var classData = sessions[day];
          return _classCell(classData, highlight);
        }),
      ],
    );
  }

  Widget _timeCell(String time) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF667eea),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _classCell(Map<String, String>? data, bool highlight) {
    Color cellColor = highlight
        ? const Color(0xFF667eea).withOpacity(0.1)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(10),
      color: cellColor,
      child: data == null
          ? const Center(
              child: Text(
                "Free",
                style: TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            )
          : InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Class Details:\n\nSubject: ${data["subject"]!.toUpperCase()}\nClass: ${data["class"]}\nRoom: ${data["room"]}',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: _subjectColor(data["subject"] ?? ""),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data["class"] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data["subject"]!.substring(0, 1).toUpperCase() +
                          data["subject"]!.substring(1),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data["room"] ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Daily View (Detailed List) ---
  Widget _buildDailyTimetable() {
    final today = DateFormat('EEEE').format(DateTime.now());
    final classes = dailyClasses;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Schedule for $today (${classes.length} classes)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
          ),
          if (classes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  '🎉 No classes scheduled for today!',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final data = classes[index];
                final gradient = _subjectColor(data['subject']!);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data['time']!.split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(data['class']!),
                    subtitle: Text(
                      '${data['subject']!.substring(0, 1).toUpperCase() + data['subject']!.substring(1)} • ${data['room']}',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Class Details: ${data['class']} at ${data['time']}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Monthly View (Placeholder Calendar) ---
  Widget _buildMonthlyView() {
    final month = DateFormat('MMMM yyyy').format(currentWeek);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '$month Calendar Overview',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE9ECEF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Monthly Calendar Grid Placeholder',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Click on any date to view classes for that day.',
            style: TextStyle(color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  // --- Subject Color Mapping
  LinearGradient _subjectColor(String subject) {
    switch (subject) {
      case "mathematics":
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "science":
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "english":
        return const LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFCC419)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "history":
        return const LinearGradient(
          colors: [Color(0xFF51CF66), Color(0xFF40C057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "physics":
        return const LinearGradient(
          colors: [Color(0xFF845EF7), Color(0xFF7048E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "chemistry":
        return const LinearGradient(
          colors: [Color(0xFFFd7e14), Color(0xFFe8590c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // --- Legend Section
  Widget _buildLegend() {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _legendItem("Mathematics", _subjectColor("mathematics")),
        _legendItem("Science", _subjectColor("science")),
        _legendItem("English", _subjectColor("english")),
        _legendItem("History", _subjectColor("history")),
        _legendItem("Physics", _subjectColor("physics")),
        _legendItem("Chemistry", _subjectColor("chemistry")),
      ],
    );
  }

  Widget _legendItem(String title, LinearGradient color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}