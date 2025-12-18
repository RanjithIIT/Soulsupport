import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ApiService to load stored tokens and handle token refresh
  await ApiService().initialize();
  
  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schools Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

// --- 1. DATA MODEL ---
class School {
  final String id;
  final String name;
  final String location;
  final String? principal;
  final int students;
  final int teachers;
  final int buses;
  final String status;
  final String? established;
  final String? email;
  final String? phone;
  final String? address;
  final String? licenseExpiry;

  School({
    required this.id,
    required this.name,
    required this.location,
    this.principal,
    required this.students,
    required this.teachers,
    required this.buses,
    required this.status,
    this.established,
    this.email,
    this.phone,
    this.address,
    this.licenseExpiry,
  });

  // Factory constructor to create School from API response
  factory School.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>?;
    final establishedYear = json['established_year'] as int?;
    
    return School(
      id: json['school_id'] as String? ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      principal: json['principal_name'] as String?,
      students: stats != null ? (stats['total_students'] as int? ?? 0) : 0,
      teachers: stats != null ? (stats['total_teachers'] as int? ?? 0) : 0,
      buses: 0, // Not in backend model, default to 0
      status: json['status'] as String? ?? 'active',
      established: establishedYear?.toString(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      licenseExpiry: json['license_expiry'] as String?,
    );
  }
}

// --- 2. MAIN DASHBOARD SCREEN ---
class AdminDashboard extends StatefulWidget {
  final bool refreshOnMount;
  
  const AdminDashboard({super.key, this.refreshOnMount = false});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<School> _allSchools = [];
  List<School> _filteredSchools = [];
  String _searchQuery = "";
  String _statusFilter = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  @override
  void didUpdateWidget(AdminDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh if refreshOnMount is true
    if (widget.refreshOnMount && !oldWidget.refreshOnMount) {
      _fetchSchools();
    }
  }

  // Fetch schools from API
  Future<void> _fetchSchools() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.initialize();
      final response = await _apiService.get(Endpoints.adminSchools);

      if (response.success && response.data != null) {
        List<School> schools = [];
        
        // Handle both list and paginated responses
        if (response.data is List) {
          schools = (response.data as List)
              .map((json) => School.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          // Check if it's a paginated response
          if (data.containsKey('results')) {
            schools = (data['results'] as List)
                .map((json) => School.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            // Single school object
            schools = [School.fromJson(data)];
          }
        }

        setState(() {
          _allSchools = schools;
          _filteredSchools = List.from(_allSchools);
          _isLoading = false;
        });
        _filterSchools();
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to fetch schools';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading schools: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Refresh schools list
  Future<void> _refreshSchools() async {
    await _fetchSchools();
  }

  void _filterSchools() {
    setState(() {
      _filteredSchools = _allSchools.where((school) {
        final matchesSearch =
            school.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            school.location.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (school.principal != null && 
             school.principal!.toLowerCase().contains(_searchQuery.toLowerCase()));
        final matchesStatus =
            _statusFilter.isEmpty || school.status == _statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteSchool(String id) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School'),
        content: const Text('Are you sure you want to delete this school? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _apiService.delete(
        Endpoints.adminSchoolDetails.replaceAll('{id}', id),
      );

      if (response.success) {
        // Remove from local list
        setState(() {
          _allSchools.removeWhere((s) => s.id == id);
          _filterSchools();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("School deleted successfully")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? "Failed to delete school"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting school: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewSchoolDetails(School school) {
    // Navigation/dialog removed — show brief info instead
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Details view disabled for ${school.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: !isDesktop
              ? AppBar(
                  title: const Text("School Management"),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 1,
                  iconTheme: const IconThemeData(color: Colors.black),
                  titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          drawer: !isDesktop ? const Drawer(child: SidebarContent()) : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                const SizedBox(width: 250, child: SidebarContent()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDesktop) ...[
                        _buildHeader(),
                        const SizedBox(height: 15),
                      ],
                      _buildSearchAndFilter(),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : _errorMessage != null
                                ? _buildErrorState()
                                : _filteredSchools.isEmpty
                                    ? _buildEmptyState()
                                    : RefreshIndicator(
                                        onRefresh: _refreshSchools,
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                maxCrossAxisExtent: 400,
                                                mainAxisExtent: 245,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                                childAspectRatio: 1.0,
                                              ),
                                          itemCount: _filteredSchools.length,
                                          itemBuilder: (context, index) {
                                            return SchoolCard(
                                              school: _filteredSchools[index],
                                              onDelete: () => _deleteSchool(
                                                _filteredSchools[index].id,
                                              ),
                                              onEdit: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Edit ${_filteredSchools[index].name}",
                                                    ),
                                                  ),
                                                );
                                              },
                                              onView: () => _viewSchoolDetails(
                                                _filteredSchools[index],
                                              ),
                                            );
                                          },
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
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Schools Management",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "A",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Admin User",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 45,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  _searchQuery = val;
                  _filterSchools();
                },
                style: const TextStyle(fontSize: 15),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Search schools...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF007BFF),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 1,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter.isEmpty ? null : _statusFilter,
                  hint: const Text(
                    "All Status",
                    style: TextStyle(fontSize: 14),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                    size: 24,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text("All Status", style: TextStyle(fontSize: 14)),
                    ),
                    DropdownMenuItem(
                      value: "active",
                      child: Text("Active", style: TextStyle(fontSize: 14)),
                    ),
                    DropdownMenuItem(
                      value: "pending",
                      child: Text("Pending", style: TextStyle(fontSize: 14)),
                    ),
                    DropdownMenuItem(
                      value: "expired",
                      child: Text("Expired", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _statusFilter = val ?? "";
                      _filterSchools();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 15),
          Text(
            _searchQuery.isNotEmpty || _statusFilter.isNotEmpty
                ? "No schools found matching your search"
                : "No schools found",
            style: const TextStyle(fontSize: 20, color: Color(0xFF333333)),
          ),
          if (_searchQuery.isEmpty && _statusFilter.isEmpty) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _refreshSchools,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 15),
          Text(
            _errorMessage ?? 'Error loading schools',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshSchools,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// --- 3. SIDEBAR COMPONENT ---
class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: const [
                Text(
                  "School Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  "Admin Dashboard",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: const [
                NavItem(icon: "📊", title: "Dashboard", isActive: false),
                NavItem(icon: "🏫", title: "Schools", isActive: true),
                NavItem(icon: "➕", title: "Add School", isActive: false),
                NavItem(icon: "👥", title: "Users", isActive: false),
                NavItem(icon: "📈", title: "Reports", isActive: false),
                NavItem(icon: "⚙️", title: "Settings", isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool isActive;

  const NavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: isActive
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.standard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        leading: Text(icon, style: const TextStyle(fontSize: 20)),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF333333),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        onTap: () {
          // Navigate based on menu item
          switch (title) {
            case 'Dashboard':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Dashboard')),
              );
              break;
            case 'Schools':
              // Already on schools page
              break;
            case 'Add School':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Add School')),
              );
              break;
            case 'Users':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Users')),
              );
              break;
            case 'Reports':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Reports')),
              );
              break;
            case 'Settings':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Settings')),
              );
              break;
          }
          // Close drawer on mobile
          if (Scaffold.of(context).hasDrawer) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

// --- 4. SCHOOL CARD COMPONENT (NO BOTTOM WHITE SPACE) ---
class SchoolCard extends StatefulWidget {
  final School school;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const SchoolCard({
    super.key,
    required this.school,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  State<SchoolCard> createState() => _SchoolCardState();
}

class _SchoolCardState extends State<SchoolCard> {
  bool isHovered = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF28A745);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'expired':
        return const Color(0xFFDC3545);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBg(String status) {
    return _getStatusColor(status).withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onView,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered
              ? Matrix4.translationValues(0, -4, 0)
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFF007BFF)
                  : const Color(0xFFE9ECEF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.1 : 0.03),
                blurRadius: isHovered ? 12 : 5,
                offset: Offset(0, isHovered ? 5 : 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Border
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                    ),
                  ),
                ),

                // Main Card Content
                Expanded(
                  child: Padding(
                    // ZERO Bottom Padding
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF007BFF),
                                    Color(0xFF0056B3),
                                  ],
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.school.name.isNotEmpty
                                    ? widget.school.name[0]
                                    : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SCHOOL NAME
                                  Text(
                                    widget.school.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // DETAILS
                                  Text(
                                    "📍 ${widget.school.location}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.school.principal != null)
                                    Text(
                                      "👨‍💼 ${widget.school.principal}",
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
                        const SizedBox(height: 8),

                        // Status Badge
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBg(widget.school.status),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.school.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(widget.school.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Stats Box
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                "${widget.school.students}",
                                "Students",
                              ),
                              _buildStatItem(
                                "${widget.school.teachers}",
                                "Teachers",
                              ),
                              _buildStatItem("${widget.school.buses}", "Buses"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                "View Details",
                                const Color(0xFF007BFF),
                                widget.onView,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionBtn(
                                "Edit",
                                const Color(0xFFFFC107),
                                widget.onEdit,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionBtn(
                                "Delete",
                                const Color(0xFFDC3545),
                                widget.onDelete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007BFF),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.9)]),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
