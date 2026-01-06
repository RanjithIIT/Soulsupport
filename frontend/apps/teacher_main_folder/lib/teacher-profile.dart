import 'package:flutter/material.dart';
import 'dart:io';
import 'services/api_service.dart' as api;

void main() {
  runApp(const TeacherProfileApp());
}

class TeacherProfileApp extends StatelessWidget {
  const TeacherProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teacher Profile',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA), // Light grey background
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4CF6)),
        fontFamily: 'Poppins', // Assuming font is available, else uses default
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      home: const TeacherProfilePage(),
    );
  }
}

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  // ====================== DATA VARIABLES ==========================
  late String teacherId;
  late String employeeNo;
  late String firstName;
  late String middleName;
  late String lastName;
  late String profileName;
  late String email;
  late String mobile;
  late String dateOfBirth;
  late String gender;
  late String religion;
  late String subCaste;
  late String bloodGroup;
  late String nationality;
  late String addressFull;
  late String addressCity;
  late String addressState;
  late String addressCountry;
  late String postalCode;
  
  String? profilePhotoUrl;
  File? _profileImage;

  // Professional
  late String qualification;
  late List<String> subjectsSpecialization;
  late String department;
  late String departmentId;
  late String designation;
  late String joiningDate;
  late String employmentStatus;
  late bool isClassTeacher;
  late String classTeacherOfSectionId;
  late String primaryRoomId;
  late String availableFrom;
  late String availableTo;
  late List<int> workDays;

  // Emergency
  late String emergencyContactName;
  late String emergencyContactRelation;
  late String emergencyContactPhone;

  // Other
  late String notes;
  late bool isActive;
  late String userId;

  // Notifications
  late bool assignmentsEnabled;
  late bool examsEnabled;
  late bool parentMessagesEnabled;
  late bool attendanceAlertsEnabled;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    _loadTeacherData();
  }

  void _initializeDefaults() {
    // Set safe defaults to avoid late initialization errors before API load
    teacherId = '';
    employeeNo = '';
    firstName = '';
    middleName = '';
    lastName = '';
    profileName = 'Loading...';
    email = '';
    mobile = '';
    dateOfBirth = '';
    gender = '';
    religion = '';
    subCaste = '';
    bloodGroup = '';
    nationality = '';
    addressFull = '';
    addressCity = '';
    addressState = '';
    addressCountry = '';
    postalCode = '';
    
    qualification = '';
    subjectsSpecialization = [];
    department = '';
    departmentId = '';
    designation = '';
    joiningDate = '';
    employmentStatus = '';
    isClassTeacher = false;
    classTeacherOfSectionId = '';
    primaryRoomId = '';
    availableFrom = '';
    availableTo = '';
    workDays = [];

    emergencyContactName = '';
    emergencyContactRelation = '';
    emergencyContactPhone = '';

    notes = '';
    isActive = true;
    userId = '';

    assignmentsEnabled = true;
    examsEnabled = true;
    parentMessagesEnabled = false;
    attendanceAlertsEnabled = true;
  }

  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final teacherData = await api.ApiService.fetchTeacherProfile();
      if (teacherData != null) {
        _populateDataFromApi(teacherData);
      } else {
        _error = 'No teacher data found';
      }
    } catch (e) {
      _error = 'Failed to load teacher data: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateDataFromApi(Map<String, dynamic> data) {
    teacherId = data['teacher_id']?.toString() ?? 'N/A';
    employeeNo = data['employee_no'] ?? '';
    firstName = data['first_name'] ?? '';
    lastName = data['last_name'] ?? '';
    profileName = '$firstName $lastName'.trim();
    email = data['email'] ?? '';
    mobile = data['mobile_no'] ?? '';
    dateOfBirth = data['dob'] ?? '';
    gender = data['gender'] ?? '';
    bloodGroup = data['blood_group'] ?? '';
    nationality = data['nationality'] ?? '';
    addressFull = data['address'] ?? '';
    qualification = data['qualification'] ?? '';
    designation = data['designation'] ?? '';
    joiningDate = data['joining_date'] ?? '';
    department = data['department_name'] ?? '';
    departmentId = data['department']?.toString() ?? '';
    primaryRoomId = data['primary_room_id'] ?? '';
    classTeacherOfSectionId = data['class_teacher_section_id'] ?? '';
    emergencyContactPhone = data['emergency_contact'] ?? '';
    isActive = data['is_active'] ?? true;
    userId = data['user']?['user_id']?.toString() ?? '';

    // Photo
    profilePhotoUrl = null;
    if (data['profile_photo_url'] != null && data['profile_photo_url'].toString().isNotEmpty) {
      profilePhotoUrl = data['profile_photo_url'] as String;
    } else if (data['profile_photo'] != null) {
       if (data['profile_photo'] is String) {
         profilePhotoUrl = data['profile_photo'];
       } else if (data['profile_photo'] is Map) {
         profilePhotoUrl = data['profile_photo']['file_url'];
       }
    }

    // Specialization
    final specialization = data['subject_specialization'] ?? '';
    if (specialization is String && specialization.isNotEmpty) {
      subjectsSpecialization = specialization.split(',').map((s) => s.trim()).toList();
    } else {
      subjectsSpecialization = [];
    }

    // Work days (dummy/default for now as not in main API response usually)
    workDays = [1, 2, 3, 4, 5]; 
    availableFrom = '09:00 AM';
    availableTo = '05:00 PM';
    
    // Derived
    isClassTeacher = classTeacherOfSectionId.isNotEmpty;
    employmentStatus = isActive ? 'Active' : 'Inactive';
  }

  Future<void> _pickImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Photo'),
        content: const Text('This would open the image picker in a real device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simulate Selection'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulated image selection')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTeacherData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // -------------------- APP BAR WITH HEADER --------------------
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6B4CF6),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B4CF6), Color(0xFF8B47E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (profilePhotoUrl != null
                                      ? NetworkImage(profilePhotoUrl!) as ImageProvider
                                      : null),
                              child: (_profileImage == null && profilePhotoUrl == null)
                                  ? const Icon(Icons.person, size: 60, color: Color(0xFF6B4CF6))
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Color(0xFF6B4CF6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$designation • $department',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon')),
                  );
                },
              ),
            ],
          ),

          // -------------------- CONTENT SECTIONS --------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Employee ID', employeeNo),
                      _buildInfoRow('Date of Birth', dateOfBirth.isNotEmpty ? dateOfBirth : 'N/A'),
                      _buildInfoRow('Gender', gender.isNotEmpty ? gender : 'N/A'),
                      _buildInfoRow('Blood Group', bloodGroup.isNotEmpty ? bloodGroup : 'N/A'),
                      _buildInfoRow('Nationality', nationality.isNotEmpty ? nationality : 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Contact Details',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      _buildInfoRow('Email', email, icon: Icons.email_outlined),
                      _buildInfoRow('Mobile', mobile, icon: Icons.phone_outlined),
                      const Divider(height: 24),
                      _buildInfoRow('Address', addressFull.isNotEmpty ? addressFull : 'N/A', icon: Icons.location_on_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Professional Details',
                    icon: Icons.work_outline,
                    children: [
                      _buildInfoRow('Qualification', qualification.isNotEmpty ? qualification : 'N/A'),
                      _buildInfoRow('Joining Date', joiningDate.isNotEmpty ? joiningDate : 'N/A'),
                      _buildInfoRow('Primary Room', primaryRoomId.isNotEmpty ? primaryRoomId : 'N/A'),
                      if (subjectsSpecialization.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Specializations',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: subjectsSpecialization
                              .map((s) => Chip(
                                    label: Text(s),
                                    backgroundColor: const Color(0xFFF0EBFF),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF6B4CF6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    side: BorderSide.none,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Emergency Contact',
                    icon: Icons.emergency_outlined,
                    children: [
                      _buildInfoRow('Phone', emergencyContactPhone.isNotEmpty ? emergencyContactPhone : 'N/A', icon: Icons.phone_callback),
                      // Add more fields if available in API
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'System Settings',
                    icon: Icons.settings_outlined,
                    children: [
                      _buildSwitchRow(
                        'Assignment Alerts',
                        assignmentsEnabled,
                        (v) => setState(() => assignmentsEnabled = v),
                      ),
                      _buildSwitchRow(
                        'Exam Reminders',
                        examsEnabled,
                        (v) => setState(() => examsEnabled = v),
                      ),
                      _buildSwitchRow(
                        'Attendance Alerts',
                        attendanceAlertsEnabled,
                        (v) => setState(() => attendanceAlertsEnabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Status',
            value: employmentStatus,
            color: isActive ? Colors.green : Colors.red,
            icon: isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Class Teacher',
            value: isClassTeacher ? classTeacherOfSectionId : 'No',
            color: isClassTeacher ? Colors.orange : Colors.grey,
            icon: Icons.class_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B4CF6), size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6B4CF6),
            activeTrackColor: const Color(0xFFF0EBFF),
          ),
        ],
      ),
    );
  }
}
