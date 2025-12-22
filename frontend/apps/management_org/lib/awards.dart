import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart' as app;
import 'dashboard.dart';

void main() {
  runApp(const AwardsManagementPage());
}

class AwardsManagementPage extends StatelessWidget {
  const AwardsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management - Awards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: const Color(0xFF667eea),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White background
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
      ),
      home: const AwardsScreen(),
    );
  }
}

// --- Data Model ---
class Award {
  final int id;
  final String title;
  final String category;
  final String recipient;
  final DateTime date;
  final String description;
  final String level;
  final String presentedBy;

  Award({
    required this.id,
    required this.title,
    required this.category,
    required this.recipient,
    required this.date,
    required this.description,
    required this.level,
    required this.presentedBy,
  });
}

// --- Main Screen ---
class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  // -- Mock Data (From HTML) --
  final List<Award> _allAwards = [
    Award(id: 1, title: "Best Academic Performance", category: "Academic", recipient: "Rahul Sharma", date: DateTime(2024, 1, 15), description: "Outstanding academic performance in Class 12 with 98% marks", level: "School", presentedBy: "Principal"),
    Award(id: 2, title: "State Level Science Olympiad Winner", category: "Academic", recipient: "Priya Patel", date: DateTime(2024, 2, 20), description: "First place in State Level Science Olympiad", level: "State", presentedBy: "State Education Board"),
    Award(id: 3, title: "District Football Championship", category: "Sports", recipient: "Amit Kumar", date: DateTime(2024, 3, 10), description: "Captain of winning football team in district championship", level: "District", presentedBy: "District Sports Authority"),
    Award(id: 4, title: "National Art Competition Winner", category: "Arts", recipient: "Sneha Reddy", date: DateTime(2024, 1, 25), description: "First prize in National Art Competition for painting", level: "National", presentedBy: "National Art Council"),
    Award(id: 5, title: "Student Council President", category: "Leadership", recipient: "Arjun Singh", date: DateTime(2024, 2, 1), description: "Exemplary leadership as Student Council President", level: "School", presentedBy: "School Management"),
    Award(id: 6, title: "Innovation in Science Project", category: "Innovation", recipient: "Kavya Iyer", date: DateTime(2024, 3, 5), description: "Innovative science project on renewable energy", level: "State", presentedBy: "State Science Council"),
    Award(id: 7, title: "Community Service Excellence", category: "Community", recipient: "Team Green Earth", date: DateTime(2024, 2, 15), description: "Outstanding contribution to environmental conservation", level: "District", presentedBy: "District Administration"),
    Award(id: 8, title: "International Mathematics Olympiad", category: "Academic", recipient: "Vikram Malhotra", date: DateTime(2024, 1, 30), description: "Bronze medal in International Mathematics Olympiad", level: "International", presentedBy: "International Mathematical Union"),
  ];

  List<Award> _filteredAwards = [];

  // -- Form Controllers --
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _presentedByController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  String? _selectedLevel;

  // -- Filter Controllers --
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = "All Categories";
  String _filterLevel = "All Levels";

  @override
  void initState() {
    super.initState();
    _filteredAwards = List.from(_allAwards);
  }

  // -- Logic --

  void _filterData() {
    setState(() {
      _filteredAwards = _allAwards.where((award) {
        final matchesSearch = award.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            award.recipient.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            award.description.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesCategory = _filterCategory == "All Categories" || award.category == _filterCategory;
        final matchesLevel = _filterLevel == "All Levels" || award.level == _filterLevel;

        return matchesSearch && matchesCategory && matchesLevel;
      }).toList();
    });
  }

  void _addNewAward() {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedCategory != null && _selectedLevel != null) {
      setState(() {
        _allAwards.insert(0, Award(
          id: _allAwards.length + 1,
          title: _titleController.text,
          category: _selectedCategory!,
          recipient: _recipientController.text,
          date: _selectedDate!,
          description: _descController.text,
          level: _selectedLevel!,
          presentedBy: _presentedByController.text,
        ));
        
        // Reset Form
        _titleController.clear();
        _recipientController.clear();
        _descController.clear();
        _presentedByController.clear();
        _selectedDate = null;
        _selectedCategory = null;
        _selectedLevel = null;
      });
      _filterData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Award added successfully!'), backgroundColor: Color(0xFF667eea)),
      );
    } else if (_selectedDate == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // -- UI Structure --

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (isDesktop)
            _buildSidebar(),

          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // Stats
                    _buildStatsOverview(),
                    const SizedBox(height: 30),

                    // Content Grid (Form + Search)
                    Column(
                      children: [
                        _buildAddAwardSection(),
                        const SizedBox(height: 30),
                        _buildFilterSection(),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Awards Grid
                    _buildSectionTitle("🏆", "All Awards"),
                    const SizedBox(height: 20),
                    _buildAwardsGrid(),
                  ],
                ),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
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

  // -- Widget Components --

  Widget _buildNavItem(String title, bool isActive) {
    return _NavItemWithHover(
      title: title,
      isActive: isActive,
      onTap: () {
        // Extract title without emoji (remove emoji and leading space)
        final titleWithoutEmoji = title.replaceAll(RegExp(r'^[^\s]+\s+'), '').trim();
        final routeMap = {
          'Dashboard': '/dashboard',
          'Students': '/students',
          'Teachers': '/teachers',
          'Buses': '/buses',
          'Events': '/events',
          'Notifications': '/notifications',
          'Activities': '/activities',
          'Awards': '/awards',
          'Photo Gallery': '/gallery',
          'Admissions': '/admissions',
          'Calendar': '/calendar',
          'RTI Act': null, // No route for RTI Act
        };
        final route = routeMap[titleWithoutEmoji];
        if (route != null && !isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "🏆 Awards Management",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Manage school awards, achievements, and recognitions",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Back to Dashboard"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final total = _allAwards.length;
    final thisYear = _allAwards.where((a) => a.date.year == DateTime.now().year).length;
    final academic = _allAwards.where((a) => a.category == "Academic").length;
    final sports = _allAwards.where((a) => a.category == "Sports").length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard("Total Awards", total.toString(), const Color(0xFF667EEA))),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard("This Year", thisYear.toString(),const Color(0xFF667EEA))),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard("Academic", academic.toString(), const Color(0xFF667EEA))),
          const SizedBox(width: 20),
          Expanded(child: _buildStatCard("Sports", sports.toString(), const Color(0xFF667EEA))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String number, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
      ],
    );
  }

  Widget _buildAddAwardSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("➕", "Add New Award"),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormRow([
                    _buildTextField("Award Title", _titleController),
                    _buildDropdownField("Category", ["Academic", "Sports", "Arts", "Leadership", "Innovation", "Community", "Other"], _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                  ]),
                  const SizedBox(height: 15),
                  _buildFormRow([
                    _buildTextField("Recipient Name", _recipientController),
                    _buildDateField("Award Date"),
                  ]),
                  const SizedBox(height: 15),
                  _buildTextField("Description", _descController, maxLines: 3, hint: "Describe the achievement and criteria..."),
                  const SizedBox(height: 15),
                  _buildFormRow([
                    _buildDropdownField("Level", ["School", "District", "State", "National", "International"], _selectedLevel, (val) => setState(() => _selectedLevel = val)),
                    _buildTextField("Presented By", _presentedByController, isRequired: false, hint: "Organization/Person"),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _addNewAward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            "Add Award",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("🔍", "Search & Filter"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _filterData(),
                  decoration: InputDecoration(
                    hintText: "Search awards...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2)),
                  ),
                  items: ["All Categories", "Academic", "Sports", "Arts", "Leadership", "Innovation", "Community", "Other"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() => _filterCategory = val!);
                    _filterData();
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterLevel,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2)),
                  ),
                  items: ["All Levels", "School", "District", "State", "National", "International"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() => _filterLevel = val!);
                    _filterData();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAwardsGrid() {
    if (_filteredAwards.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Text("No awards found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("Add some awards to get started!", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        int crossAxisCount = width > 1100 ? 3 : width > 700 ? 2 : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.2, // Decreased height - higher ratio = shorter cards
          ),
          itemCount: _filteredAwards.length,
          itemBuilder: (context, index) {
            return _buildAwardCard(_filteredAwards[index]);
          },
        );
      },
    );
  }

  Widget _buildAwardCard(Award award) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))
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
                  award.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  award.category,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            award.description,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "👤 ${award.recipient}",
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontStyle: FontStyle.italic),
              ),
              Text(
                "📅 ${DateFormat('MMM dd, yyyy').format(award.date)}",
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("🏆 ${award.level} Level", style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
              Expanded(
                child: Text(
                  "🎖️ ${award.presentedBy}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -- Form Building Helpers --

  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        int idx = entry.key;
        Widget w = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 15),
            child: w,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool isRequired = true, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: isRequired ? (val) => val!.isEmpty ? "Required" : null : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2)),
            contentPadding: const EdgeInsets.all(12),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text("Select $label"),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? "Required" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2)),
            contentPadding: const EdgeInsets.all(12),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null ? "Select Date" : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
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

class _NavItemWithHover extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWithHover({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItemWithHover> createState() => _NavItemWithHoverState();
}

class _NavItemWithHoverState extends State<_NavItemWithHover> {
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
        margin: const EdgeInsets.only(bottom: 10),
        transform: Matrix4.identity()
          ..translate(_isHovered ? 8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: widget.isActive
              ? Colors.white.withValues(alpha: 0.3)
              : _isHovered
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: widget.onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}