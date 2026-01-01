import 'package:flutter/material.dart';
import 'dart:io';
import 'services/api_service.dart' as api;
// image_picker removed for emulator/demo builds. Image picking is simulated.

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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        // === BOLDNESS/SHARPNESS INCREASED HERE ===
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        // ==========================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
      home: const TeacherProfilePage(),
    );
  }
}

// ============================================================================
// MAIN PAGE
// ============================================================================
class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ====================== METADATA VARIABLES ==========================
  // NOTE: These are made mutable for demonstration, but should typically remain read-only in a production environment.
  late String teacherId;
  late String schoolId;
  late String userId;
  late String createdBy;
  late String createdAt;
  late String updatedAt;

  // Personal Info
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
  late String profilePhotoId;
  String? profilePhotoUrl; // Added for remote image
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

  // Notifications
  late bool assignmentsEnabled;
  late bool examsEnabled;
  late bool parentMessagesEnabled;
  late bool attendanceAlertsEnabled;
  late bool gradeUpdatesEnabled;

  final TextEditingController _subjectController = TextEditingController();
  // image_picker plugin removed in demo; simulate pick behavior instead

  bool _isLoading = true;
  String? _error;

  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final teacherData = await api.ApiService.fetchTeacherProfile();
      if (teacherData != null) {
        _populateDataFromApi(teacherData);
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _error = 'No teacher data found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load teacher data: $e';
        _isLoading = false;
      });
      // Fallback to default data if API fails
      _initializeData();
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
    emergencyContactName = '';
    emergencyContactRelation = '';
    emergencyContactPhone = data['emergency_contact'] ?? '';
    isActive = data['is_active'] ?? true;

    // Parse profile photo URL
    profilePhotoUrl = null;
    if (data['profile_photo_url'] != null && data['profile_photo_url'].toString().isNotEmpty) {
      profilePhotoUrl = data['profile_photo_url'] as String;
    } else if (data['profile_photo'] != null) {
      if (data['profile_photo'] is Map) {
        final photo = data['profile_photo'] as Map<String, dynamic>;
        profilePhotoUrl = photo['file_url'] as String?;
      } else if (data['profile_photo'] is String && (data['profile_photo'] as String).isNotEmpty) {
        profilePhotoUrl = data['profile_photo'] as String;
      }
    }
    
    // Parse subject specialization
    final specialization = data['subject_specialization'] ?? '';
    if (specialization is String && specialization.isNotEmpty) {
      subjectsSpecialization = specialization.split(',').map((s) => s.trim()).toList();
    } else {
      subjectsSpecialization = [];
    }
    
    // Set defaults for missing fields
    middleName = '';
    religion = '';
    subCaste = '';
    addressCity = '';
    addressState = '';
    addressCountry = '';
    postalCode = '';
    profilePhotoId = '';
    schoolId = '';
    userId = data['user']?['user_id']?.toString() ?? '';
    createdBy = '';
    createdAt = data['created_at'] ?? '';
    updatedAt = data['updated_at'] ?? '';
    employmentStatus = isActive ? 'active' : 'inactive';
    isClassTeacher = classTeacherOfSectionId.isNotEmpty;
    availableFrom = '09:00';
    availableTo = '16:00';
    workDays = [1, 2, 3, 4, 5];
    notes = '';
    assignmentsEnabled = true;
    examsEnabled = true;
    parentMessagesEnabled = false;
    attendanceAlertsEnabled = true;
    gradeUpdatesEnabled = false;
  }

  void _initializeData() {
    teacherId = 'TID-0001';
    schoolId = 'SCH-01';
    userId = 'UID-100';
    createdBy = 'ADM-001';
    createdAt = '2024-01-01T12:00:00Z';
    updatedAt = '2024-06-10T15:30:00Z';

    employeeNo = 'TCH001';
    firstName = 'John';
    middleName = 'A.';
    lastName = 'Smith';
    profileName = 'John A. Smith';
    email = 'john.smith@school.edu';
    mobile = '+1 (555) 123-4567';
    dateOfBirth = '1985-03-15';
    gender = 'Male';
    religion = 'None';
    subCaste = '';
    bloodGroup = 'O+';
    nationality = 'American';
    addressFull = '123 Education Street, Learning City';
    addressCity = 'Learning City';
    addressState = 'LC State';
    addressCountry = 'United States';
    postalCode = '12345';
    profilePhotoId = 'PPH-5555';
    profilePhotoUrl = null;

    qualification = 'M.Ed Mathematics';
    subjectsSpecialization = ['Advanced Mathematics', 'Calculus'];
    department = 'Mathematics';
    departmentId = 'DEPT-MATH';
    designation = 'Teacher';
    joiningDate = '2016-06-01';
    employmentStatus = 'active';
    isClassTeacher = false;
    classTeacherOfSectionId = 'SEC-4A';
    primaryRoomId = 'RM-222';
    availableFrom = '09:00';
    availableTo = '16:00';
    workDays = [1, 2, 3, 4, 5];

    emergencyContactName = 'Jane Smith';
    emergencyContactRelation = 'Spouse';
    emergencyContactPhone = '+1 (555) 987-6543';

    notes = '';
    isActive = true;

    assignmentsEnabled = true;
    examsEnabled = true;
    parentMessagesEnabled = false;
    attendanceAlertsEnabled = true;
    gradeUpdatesEnabled = false;
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // Set defaults first
    _tabController = TabController(length: 4, vsync: this);
    _loadTeacherData(); // Then load from API
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // In emulator/demo builds we don't use the native image picker plugin.
    // Show a dialog to simulate image selection.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate Image Pick'),
        content: const Text('Select a sample profile image (simulated).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Use Sample'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _profileImage = null; // keep null but indicate selection via snackbar
      });
      _show('Sample image selected (simulated).');
    } else {
      _show('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 60,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B47E6), Color(0xFFC764A9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: const Text(
            'Teacher Profile',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 60,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B47E6), Color(0xFFC764A9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: const Text(
            'Teacher Profile',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Error loading profile'),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B47E6), Color(0xFFC764A9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Teacher Profile',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // Refresh profile data
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Already on profile page
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // -------------------- PROFILE HEADER TAB --------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                            ? NetworkImage(profilePhotoUrl!) as ImageProvider
                            : null),
                    child: _profileImage == null && (profilePhotoUrl == null || profilePhotoUrl!.isEmpty)
                        ? Icon(
                            Icons.camera_alt,
                            color: Colors.grey.shade600,
                            size: 30,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BOLDER NAME
                    Text(
                      profileName,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // BOLDER SUBJECT/DESIGNATION
                    Text(
                      '$designation - $department',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // BOLDER ID
                    Text(
                      'Employee ID: $employeeNo',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _show('Edit profile (simulated)');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          // -------------------- TABS --------------------
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Professional'),
                Tab(text: 'Notifications'),
                Tab(text: 'Security'),
              ],
            ),
          ),

          // -------------------- CONTENT --------------------
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(isMobile),
                _buildProfessionalTab(isMobile),
                _buildNotificationsTab(),
                _buildSecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PERSONAL TAB — ALL FIELDS EDITABLE
  // ============================================================================
  Widget _buildPersonalTab(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Personal Information'),

          _row(isMobile, [
            _input('First Name', firstName, (v) => firstName = v),
            _input('Middle Name', middleName, (v) => middleName = v),
            _input('Last Name', lastName, (v) => lastName = v),
            _input('Employee Number', employeeNo, (v) => employeeNo = v),
          ]),

          _row(isMobile, [
            _input(
              'Date of Birth (YYYY-MM-DD)',
              dateOfBirth,
              (v) => dateOfBirth = v,
            ),
            _input('Gender', gender, (v) => gender = v),
            _input('Blood Group', bloodGroup, (v) => bloodGroup = v),
            _input('Nationality', nationality, (v) => nationality = v),
          ]),

          const SizedBox(height: 20),
          _title('Contact'),

          _row(isMobile, [
            _input('Email', email, (v) => email = v),
            _input('Mobile', mobile, (v) => mobile = v),
          ]),

          const SizedBox(height: 20),
          _title('Location'),

          _row(isMobile, [
            _input('City', addressCity, (v) => addressCity = v),
            _input('State', addressState, (v) => addressState = v),
            _input('Country', addressCountry, (v) => addressCountry = v),
            _input('Postal Code', postalCode, (v) => postalCode = v),
          ]),

          _inputArea('Full Address', addressFull, (v) => addressFull = v),

          const SizedBox(height: 20),
          _title('Religious/Caste Details'),
          _row(isMobile, [
            _input('Religion', religion, (v) => religion = v),
            _input('Sub Caste', subCaste, (v) => subCaste = v),
          ]),

          const SizedBox(height: 30),
          _saveButton(() => _show('Personal Info Saved!')),
        ],
      ),
    );
  }

  // ============================================================================
  // PROFESSIONAL TAB — ALL FIELDS EDITABLE
  // ============================================================================
  Widget _buildProfessionalTab(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Professional Details'),

          _row(isMobile, [
            _input('Department', department, (v) => department = v),
            _input('Designation', designation, (v) => designation = v),
            _input('Qualification', qualification, (v) => qualification = v),
            _input(
              'Joining Date (YYYY-MM-DD)',
              joiningDate,
              (v) => joiningDate = v,
            ),
          ]),

          const SizedBox(height: 20),
          _title('System Assignment'),

          _row(isMobile, [
            _input('Primary Room ID', primaryRoomId, (v) => primaryRoomId = v),
            _input(
              'Class Teacher Section ID',
              classTeacherOfSectionId,
              (v) => classTeacherOfSectionId = v,
            ),
            _input('Department ID', departmentId, (v) => departmentId = v),
            _input(
              'Employment Status',
              employmentStatus,
              (v) => employmentStatus = v,
            ),
          ]),

          const SizedBox(height: 20),
          _title('Subjects Specialization'),
          Wrap(
            spacing: 8,
            children: [
              for (int i = 0; i < subjectsSpecialization.length; i++)
                Chip(
                  label: Text(
                    subjectsSpecialization[i],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onDeleted: () =>
                      setState(() => subjectsSpecialization.removeAt(i)),
                ),
            ],
          ),

          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(hintText: 'Add subject'),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                setState(() => subjectsSpecialization.add(v.trim()));
                _subjectController.clear();
              }
            },
          ),

          const SizedBox(height: 20),
          _title('Work Schedule'),
          _row(isMobile, [
            _input('Available From', availableFrom, (v) => availableFrom = v),
            _input('Available To', availableTo, (v) => availableTo = v),
            _input(
              'Active Work Days (List:Monday,Tuesday,Wednesday,Thursday,Friday & Saturday)',
              workDays.join(', '),
              (v) {
                // Note: This conversion is simplistic and assumes comma-separated integers.
                try {
                  workDays = v
                      .split(',')
                      .map((s) => int.parse(s.trim()))
                      .toList();
                } catch (_) {
                  /* handle error */
                }
              },
            ), // MADE EDITABLE
            _input(
              'Is Class Teacher (Yes/No)',
              isClassTeacher ? 'Yes' : 'No',
              (v) => isClassTeacher = (v.toLowerCase() == 'yes'),
            ),
          ]),

          const SizedBox(height: 20),
          _title('Emergency Contact'),
          _row(isMobile, [
            _input(
              'Contact Name',
              emergencyContactName,
              (v) => emergencyContactName = v,
            ),
            _input(
              'Relation',
              emergencyContactRelation,
              (v) => emergencyContactRelation = v,
            ),
            _input(
              'Phone',
              emergencyContactPhone,
              (v) => emergencyContactPhone = v,
            ),
          ]),

          const SizedBox(height: 20),
          _inputArea('Notes', notes, (v) => notes = v),

          const SizedBox(height: 20),
          _title('System IDs'),
          _row(isMobile, [
            _input('Teacher ID', teacherId, (v) => teacherId = v),
            _input('User ID', userId, (v) => userId = v),
            _input(
              'Account Active (True/False)',
              isActive.toString(),
              (v) => isActive = (v.toLowerCase() == 'true'),
            ),
          ]),

          const SizedBox(height: 30),

          _saveButton(() => _show('Professional Info Saved!')),
        ],
      ),
    );
  }

  // ============================================================================
  // NOTIFICATIONS TAB
  // ============================================================================
  Widget _buildNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _title('Alert Preferences'),
        _notifyTile(
          'Assignment Submissions',
          assignmentsEnabled,
          (v) => setState(() => assignmentsEnabled = v),
        ),
        _notifyTile(
          'Exam Reminders',
          examsEnabled,
          (v) => setState(() => examsEnabled = v),
        ),
        _notifyTile(
          'Parent Messages',
          parentMessagesEnabled,
          (v) => setState(() => parentMessagesEnabled = v),
        ),
        _notifyTile(
          'Attendance Alerts',
          attendanceAlertsEnabled,
          (v) => setState(() => attendanceAlertsEnabled = v),
        ),
        _notifyTile(
          'Grade Updates',
          gradeUpdatesEnabled,
          (v) => setState(() => gradeUpdatesEnabled = v),
        ),

        const SizedBox(height: 20),
        _saveButton(() => _show('Notification Preferences Saved!')),
      ],
    );
  }

  // ============================================================================
  // SECURITY TAB — System fields moved to Professional tab, security actions remain.
  // ============================================================================
  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _title('Account Status (Metadata)'),
        _readonly('School ID', schoolId),
        _readonly('Created By', createdBy),
        _readonly('Created At', createdAt),
        _readonly('Last Updated At', updatedAt),

        const SizedBox(height: 20),
        _title('Credentials and Sessions'),
        _securityTile(
          'Change Password',
          Icons.lock,
          () => _show('Change Password'),
        ),
        _securityTile(
          'Enable Two-Factor Authentication',
          Icons.security,
          () => _show('2FA Setup'),
        ),
        _securityTile(
          'Manage Active Sessions',
          Icons.devices,
          () => _show('Sessions Management'),
        ),

        const SizedBox(height: 20),
        _saveButton(() => _show('Security Settings Updated!')),
      ],
    );
  }

  // ============================================================================
  // -------------------------- UI HELPERS --------------------------------------
  // (Note: _input is used throughout for editable fields, _readonly is now only for pure metadata)
  // ============================================================================

  Widget _row(bool mobile, List<Widget> items) {
    return mobile
        ? Column(
            children: items
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: e,
                  ),
                )
                .toList(),
          )
        : Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((e) => SizedBox(width: 280, child: e)).toList(),
          );
  }

  Widget _input(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bolder Label
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: (v) => setState(() => onChanged(v)),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ), // Bolder input text
        ),
      ],
    );
  }

  Widget _readonly(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bolder Label
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ), // Slightly muted for metadata
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputArea(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bolder Label
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          maxLines: 3,
          onChanged: (v) => setState(() => onChanged(v)),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ), // Bolder input text
        ),
      ],
    );
  }

  Widget _notifyTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ), // Bolder title
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _securityTile(String title, IconData i, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ), // Bolder title
      leading: Icon(i, color: Colors.black54), // Sharper icon color
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black54,
      ), // Sharper icon color
      onTap: onTap,
    );
  }

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ), // Very bold section title
    ),
  );

  Widget _saveButton(VoidCallback f) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: f,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ), // Bolder button text
        ),
        child: const Text('Save'),
      ),
    );
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
