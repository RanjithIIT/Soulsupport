import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';
import 'students.dart';
import 'teachers.dart';
import 'buses.dart';
import 'events.dart';
import 'notifications.dart';
import 'activities.dart';
import 'awards.dart';
import 'gallery.dart';
import 'calendar.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';

void main() {
  runApp(const AdmissionsManagementPage());
}

class AdmissionsManagementPage extends StatelessWidget {
  const AdmissionsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management - Admissions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: const Color(0xFF667EEA),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const AdmissionsScreen(),
    );
  }
}

// --- Data Model (Enhanced from Block 2) ---
class Admission {
  final int id;
  final String studentName;
  final String parentName;
  final DateTime dateOfBirth;
  final String gender;
  final String applyingClass;
  final String address;
  final String category;
  final String status;
  final String? admissionNumber;
  final String? studentId;
  final String? email;
  final String? parentPhone;
  final String? emergencyContact;
  final String? medicalInformation;
  final String? bloodGroup;
  final String? previousSchool;
  final String? remarks;

  Admission({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.dateOfBirth,
    required this.gender,
    required this.applyingClass,
    required this.address,
    required this.category,
    required this.status,
    this.admissionNumber,
    this.studentId,
    this.email,
    this.parentPhone,
    this.emergencyContact,
    this.medicalInformation,
    this.bloodGroup,
    this.previousSchool,
    this.remarks,
  });

  Admission copyWith({
    int? id,
    String? studentName,
    String? parentName,
    DateTime? dateOfBirth,
    String? gender,
    String? applyingClass,
    String? address,
    String? category,
    String? status,
    String? admissionNumber,
    String? studentId,
    String? email,
    String? parentPhone,
    String? emergencyContact,
    String? medicalInformation,
    String? bloodGroup,
    String? previousSchool,
    String? remarks,
  }) {
    return Admission(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      parentName: parentName ?? this.parentName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      applyingClass: applyingClass ?? this.applyingClass,
      address: address ?? this.address,
      category: category ?? this.category,
      status: status ?? this.status,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      parentPhone: parentPhone ?? this.parentPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalInformation: medicalInformation ?? this.medicalInformation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      previousSchool: previousSchool ?? this.previousSchool,
      remarks: remarks ?? this.remarks,
    );
  }
}

// --- Main Screen ---
class AdmissionsScreen extends StatefulWidget {
  const AdmissionsScreen({super.key});

  @override
  State<AdmissionsScreen> createState() => _AdmissionsScreenState();
}

class _AdmissionsScreenState extends State<AdmissionsScreen> {
  // -- State Variables --
  List<Admission> _allAdmissions = [];
  List<Admission> _filteredAdmissions = [];
  
  // Main Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _prevSchoolController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _medicalInfoController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  
  // Search/Filter Controllers
  final TextEditingController _searchController = TextEditingController();

  String? _selectedGender;
  String? _selectedClass;
  String? _selectedCategory;
  String? _selectedBloodGroup;
  DateTime? _selectedDob;

  String _filterStatus = "";
  String _filterClass = "";
  
  bool _isSubmitting = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadAdmissions();
    _searchController.addListener(_filterAdmissions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAdmissions);
    _searchController.dispose();
    _studentIdController.dispose();
    _admissionNoController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _parentController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _prevSchoolController.dispose();
    _emergencyContactController.dispose();
    _medicalInfoController.dispose();
    _remarksController.dispose();
    _gradeController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  // -- API Methods --

  Future<void> _loadAdmissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get(Endpoints.admissions);

      if (response.success && response.data != null) {
        List<Admission> admissions = [];
        
        // Handle different response formats
        dynamic data = response.data;
        
        // If response is a list, use it directly
        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final admission = _parseAdmissionFromJson(item);
              if (admission != null) {
                admissions.add(admission);
              }
            }
          }
        }
        // If response is an object with a 'results' field (pagination)
        else if (data is Map<String, dynamic>) {
          if (data['results'] != null && data['results'] is List) {
            for (var item in data['results'] as List) {
              if (item is Map<String, dynamic>) {
                final admission = _parseAdmissionFromJson(item);
                if (admission != null) {
                  admissions.add(admission);
                }
              }
            }
          }
          // If data itself is a list-like structure
          else if (data['data'] != null && data['data'] is List) {
            for (var item in data['data'] as List) {
              if (item is Map<String, dynamic>) {
                final admission = _parseAdmissionFromJson(item);
                if (admission != null) {
                  admissions.add(admission);
                }
              }
            }
          }
        }

        setState(() {
          _allAdmissions = admissions;
          _filteredAdmissions = List.from(_allAdmissions);
        });
      } else {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load admissions: ${response.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading admissions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Admission? _parseAdmissionFromJson(Map<String, dynamic> json) {
    try {
      // Parse dates
      DateTime? dateOfBirth;
      
      if (json['date_of_birth'] != null) {
        if (json['date_of_birth'] is String) {
          dateOfBirth = DateTime.tryParse(json['date_of_birth']);
        } else if (json['date_of_birth'] is DateTime) {
          dateOfBirth = json['date_of_birth'];
        }
      }

      if (dateOfBirth == null) {
        return null;
      }

      return Admission(
        id: json['id'] ?? 0,
        studentName: json['student_name'] ?? '',
        parentName: json['parent_name'] ?? '',
        dateOfBirth: dateOfBirth,
        gender: json['gender'] ?? '',
        applyingClass: json['applying_class'] ?? '',
        address: json['address'] ?? '',
        category: json['category'] ?? '',
        status: json['status'] ?? 'Pending',
        admissionNumber: json['admission_number'],
        studentId: json['student_id'],
        email: json['email'],
        parentPhone: json['parent_phone'],
        emergencyContact: json['emergency_contact'],
        medicalInformation: json['medical_information'],
        bloodGroup: json['blood_group'],
        previousSchool: json['previous_school'],
        remarks: json['remarks'],
      );
    } catch (e) {
      print('Error parsing admission: $e');
      return null;
    }
  }

  // -- Logic Methods --

  void _filterAdmissions() {
    setState(() {
      _filteredAdmissions = _allAdmissions.where((admission) {
        final matchesSearch = _searchController.text.isEmpty ||
            admission.studentName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            admission.parentName.toLowerCase().contains(_searchController.text.toLowerCase());

        final matchesStatus = _filterStatus.isEmpty || admission.status == _filterStatus;
        final matchesClass = _filterClass.isEmpty || admission.applyingClass == _filterClass;

        return matchesSearch && matchesStatus && matchesClass;
      }).toList();
    });
  }

  Future<void> _addNewAdmissionFromPage() async {
    if (_formKey.currentState!.validate() &&
        _admissionNoController.text.trim().isNotEmpty &&
        _firstNameController.text.trim().isNotEmpty &&
        _selectedDob != null &&
        _selectedGender != null &&
        _selectedClass != null &&
        _selectedCategory != null) {
      
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Prepare data for API
        final admissionData = {
          'student_name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
          'parent_name': _parentController.text.trim(),
          'date_of_birth': DateFormat('yyyy-MM-dd').format(_selectedDob!),
          'gender': _selectedGender!,
          'applying_class': _selectedClass!,
          'address': _addressController.text.trim(),
          'category': _selectedCategory!,
          'status': 'Pending',
          'admission_number': _admissionNoController.text.trim(),
          if (_studentIdController.text.trim().isNotEmpty)
            'student_id': _studentIdController.text.trim(),
          if (_gradeController.text.trim().isNotEmpty)
            'grade': _gradeController.text.trim(),
          if (_feesController.text.trim().isNotEmpty)
            'fees': double.tryParse(_feesController.text.trim()),
          if (_emailController.text.trim().isNotEmpty)
            'email': _emailController.text.trim(),
          if (_parentPhoneController.text.trim().isNotEmpty)
            'parent_phone': _parentPhoneController.text.trim(),
          if (_emergencyContactController.text.trim().isNotEmpty)
            'emergency_contact': _emergencyContactController.text.trim(),
          if (_medicalInfoController.text.trim().isNotEmpty)
            'medical_information': _medicalInfoController.text.trim(),
          if (_selectedBloodGroup != null)
            'blood_group': _selectedBloodGroup!,
          if (_prevSchoolController.text.trim().isNotEmpty)
            'previous_school': _prevSchoolController.text.trim(),
          if (_remarksController.text.trim().isNotEmpty)
            'remarks': _remarksController.text.trim(),
        };

        // Call backend API
        final response = await _apiService.post(
          Endpoints.admissions,
          body: admissionData,
        );

        if (response.success && response.data != null) {
        // Parse response - backend returns {success, message, data: {...}}
        final responseData = response.data as Map<String, dynamic>;
        
        // Check if response has success field
        final isSuccess = responseData['success'] as bool? ?? true;
        
        if (!isSuccess) {
          final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Failed to create admission';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Admission data will be loaded from server after successful creation

          // Reset Form
          _studentIdController.clear();
          _admissionNoController.clear();
          _firstNameController.clear();
          _lastNameController.clear();
          _parentController.clear();
          _parentPhoneController.clear();
          _addressController.clear();
          _emailController.clear();
          _prevSchoolController.clear();
          _emergencyContactController.clear();
          _medicalInfoController.clear();
          _remarksController.clear();
          _gradeController.clear();
          _feesController.clear();
          _selectedGender = null;
          _selectedClass = null;
          _selectedCategory = null;
          _selectedBloodGroup = null;
          _selectedDob = null;

          // Reload admissions from server
          await _loadAdmissions();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Application submitted successfully!"),
                backgroundColor: Color(0xFF667EEA),
              ),
            );
          }
        } else {
          // Handle API error
          String errorMessage = 'Failed to submit application. Please try again.';
          
          if (response.data != null && response.data is Map) {
            final errorData = response.data as Map<String, dynamic>;
            
            // Check for validation errors
            if (errorData['errors'] != null) {
              final errors = errorData['errors'] as Map<String, dynamic>;
              final errorList = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  errorList.addAll(value.map((e) => '$key: $e').toList());
                } else {
                  errorList.add('$key: $value');
                }
              });
              errorMessage = errorList.join(', ');
            } else {
              errorMessage = errorData['message'] ?? 
                            errorData['error'] ?? 
                            errorMessage;
            }
          } else if (response.error != null) {
            errorMessage = response.error!;
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else if (_admissionNoController.text.trim().isEmpty || _firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill student ID, admission number, and first name."), backgroundColor: Colors.red),
      );
    } else if (_selectedDob == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date of birth."), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields."), backgroundColor: Colors.red),
      );
    }
  }

  void _updateAdmission(Admission updatedAdmission) {
    setState(() {
      final index = _allAdmissions.indexWhere((a) => a.id == updatedAdmission.id);
      if (index != -1) {
        _allAdmissions[index] = updatedAdmission;
        _filterAdmissions();
      }
    });
  }

  Future<void> _deleteAdmission(int id) async {
    try {
      // Call backend API to delete
      final response = await _apiService.delete('${Endpoints.admissions}$id/');

      if (response.success) {
        // Reload admissions from server
        await _loadAdmissions();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admission deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${response.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting admission: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeStatus(int id, String newStatus) async {
    try {
      final index = _allAdmissions.indexWhere((a) => a.id == id);
      if (index == -1) return;

      final admission = _allAdmissions[index];
      
      // Generate admission number if approving and not already set
      String? admissionNumber = admission.admissionNumber;
      if (newStatus == 'Approved' && admissionNumber == null) {
        // Generate unique admission number
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        admissionNumber = 'ADM-${DateTime.now().year}-${timestamp.toString().substring(timestamp.toString().length - 6)}';
      }

      // Prepare update data
      final updateData = {
        'status': newStatus,
      };
      
      // Include admission number if it's being set
      if (admissionNumber != null) {
        updateData['admission_number'] = admissionNumber;
      }

      // Call backend API to update status
      final response = await _apiService.patch(
        '${Endpoints.admissions}$id/',
        body: updateData,
      );

      if (response.success && response.data != null) {
        // If status is Approved, create Student record
        if (newStatus == 'Approved') {
          try {
            // Get admission data to create student
            final admissionData = response.data as Map<String, dynamic>;
            
            // Prepare student data from admission
            final studentData = {
              'admission_no': admissionNumber ?? admissionData['admission_number'] ?? 'ADM-${DateTime.now().millisecondsSinceEpoch}',
              'first_name': admission.studentName.split(' ').first,
              'last_name': admission.studentName.split(' ').length > 1 
                  ? admission.studentName.split(' ').sublist(1).join(' ')
                  : null,
              'date_of_birth': DateFormat('yyyy-MM-dd').format(admission.dateOfBirth),
              'gender': admission.gender,
              'address': admission.address,
              'email': admission.email,
              'parent_name': admission.parentName,
              if (admission.parentPhone != null)
                'parent_phone': admission.parentPhone,
              if (admission.emergencyContact != null)
                'emergency_contact': admission.emergencyContact,
              'is_active': true,
              if (admissionData['blood_group'] != null)
                'blood_group': admissionData['blood_group'],
              if (admissionData['medical_information'] != null)
                'medical_information': admissionData['medical_information'],
            };

            // Call backend API to create student
            await _apiService.post(
              Endpoints.students,
              body: studentData,
            );
          } catch (e) {
            print('Error creating student: $e');
            // Continue even if student creation fails
          }
        }

        // Reload admissions to get updated data from server
        await _loadAdmissions();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newStatus == 'Approved' 
                  ? 'Status updated and student created successfully!'
                  : 'Status updated to $newStatus successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Handle error
        String errorMessage = 'Failed to update status. Please try again.';
        if (response.data != null && response.data is Map) {
          final errorData = response.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        errorMessage;
        } else if (response.error != null) {
          errorMessage = response.error!;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // -- Helpers --
  Future<void> _pickDate(BuildContext context, bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _selectedDob = picked;
        }
      });
    }
  }

  // -- UI Builders --
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // --- Sidebar ---
          if (isDesktop)
            Container(
              width: 250,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "🏫 School Management",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text("Admissions", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: [
                        _buildNavItem("📊 Dashboard", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()))),
                        _buildNavItem("👥 Students", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentsManagementPage()))),
                        _buildNavItem("👨‍🏫 Teachers", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeachersManagementPage()))),
                        _buildNavItem("🚌 Buses", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BusesManagementPage()))),
                        _buildNavItem("📅 Events", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventsManagementPage()))),
                        _buildNavItem("🔔 Notifications", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationsManagementPage()))),
                        _buildNavItem("📚 Activities", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ActivitiesManagementPage()))),
                        _buildNavItem("🏆 Awards", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AwardsManagementPage()))),
                        _buildNavItem("📷 Photo Gallery", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PhotoGalleryPage()))),
                        _buildNavItem("📄 RTI Act", false, () {}),
                        _buildNavItem("🎓 Admissions", true, () {}), // Active
                        _buildNavItem("📅 Calendar", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarManagementPage()))),
                      ],
                    ),
                  )
                ],
              ),
            ),

          // --- Main Content ---
          Expanded(
            child: Container(
              color: Colors.white,
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

                    // Form and Grid Area
                    LayoutBuilder(builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add Application Form (Embedded)
                          _buildSectionTitle("➕", "New Admission Application"),
                          const SizedBox(height: 15),
                          _buildFormSection(),
                          
                          const SizedBox(height: 30),
                          
                          // Search and Filter
                          _buildSectionTitle("🔍", "Search & Filter"),
                          const SizedBox(height: 15),
                          _buildSearchFilterSection(),

                          const SizedBox(height: 30),
                          
                          // Applications Grid
                          _buildSectionTitle("📋", "All Applications"),
                          const SizedBox(height: 15),
                          _buildAdmissionsGrid(),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive, VoidCallback onTap) {
    return _NavItemWithHover(
      title: title,
      isActive: isActive,
      onTap: onTap,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🎓 Admissions Management",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Manage student admissions, applications, and enrollment",
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
    final pending = _allAdmissions.where((a) => a.status == 'Pending').length;
    final approved = _allAdmissions.where((a) => a.status == 'Approved').length;
    final enrolled = _allAdmissions.where((a) => a.status == 'Enrolled').length;

    return Row(
      children: [
        
        Expanded(
          child: _buildStatCard("Total Applications", _allAdmissions.length.toString(), const Color(0xFF667EEA)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("Pending Review", pending.toString(), Colors.orange),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("Approved", approved.toString(), Colors.green),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("Enrolled", enrolled.toString(), Colors.blue),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student ID and Admission Number
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _admissionNoController,
                    decoration: InputDecoration(
                      labelText: 'Admission Number *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // First Name and Last Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Parent Name and Parent Phone
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _parentController,
                    decoration: InputDecoration(
                      labelText: 'Parent/Guardian Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _parentPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Parent Phone (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: 'yyyy-mm-dd',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      child: Text(
                        _selectedDob != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDob!)
                            : 'yyyy-mm-dd',
                        style: TextStyle(
                          color: _selectedDob != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      hintText: 'Select Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Applying for Class',
                      hintText: 'Select Class',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _selectedClass,
                    items: List.generate(12, (i) {
                      final className = 'Class ${i + 1}';
                      return DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _gradeController,
                    decoration: InputDecoration(
                      labelText: 'Grade (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _feesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fees (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Email
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Blood Group
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Blood Group (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _selectedBloodGroup,
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),
            // Emergency Contact and Medical Info
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emergencyContactController,
                    decoration: InputDecoration(
                      labelText: 'Emergency Contact (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _medicalInfoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Medical Information (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    value: _selectedCategory,
                    items: const [
                      DropdownMenuItem(value: 'General', child: Text('General')),
                      DropdownMenuItem(value: 'OBC', child: Text('OBC')),
                      DropdownMenuItem(value: 'SC', child: Text('SC')),
                      DropdownMenuItem(value: 'ST', child: Text('ST')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _prevSchoolController,
              decoration: InputDecoration(
                labelText: 'Previous School (Optional)',
                hintText: 'Enter previous school name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Remarks (Optional)',
                hintText: 'Enter any additional remarks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _addNewAdmissionFromPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search applications...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    _filterAdmissions();
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'All Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  value: _filterStatus.isEmpty ? null : _filterStatus,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Status')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                    DropdownMenuItem(value: 'Enrolled', child: Text('Enrolled')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value ?? '';
                    });
                    _filterAdmissions();
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'All Classes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  value: _filterClass.isEmpty ? null : _filterClass,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Classes')),
                    ...List.generate(12, (i) {
                      final className = 'Class ${i + 1}';
                      return DropdownMenuItem(
                        value: className,
                        child: Text(className),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterClass = value ?? '';
                    });
                    _filterAdmissions();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionsGrid() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
        ),
      );
    }

    if (_filteredAdmissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _allAdmissions.isEmpty 
                  ? 'No admissions found. Add a new admission to get started.'
                  : 'No admissions match your search criteria.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredAdmissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _allAdmissions.isEmpty 
                  ? 'No admissions found. Add a new admission to get started.'
                  : 'No admissions match your search criteria.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
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
            childAspectRatio: 1.4,
          ),
          itemCount: _filteredAdmissions.length,
          itemBuilder: (context, index) {
            return _AdmissionCard(
              admission: _filteredAdmissions[index],
              onView: () => _viewAdmission(context, _filteredAdmissions[index]),
              onEdit: () => _showEditAdmissionDialog(context, _filteredAdmissions[index]),
              onDelete: () => _deleteAdmission(_filteredAdmissions[index].id),
              onChangeStatus: (status) => _changeStatus(_filteredAdmissions[index].id, status),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String label, String number, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
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
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _viewAdmission(BuildContext context, Admission admission) {
    showDialog(
      context: context,
      builder: (context) => _AdmissionDetailDialog(admission: admission),
    );
  }

  void _showEditAdmissionDialog(BuildContext context, Admission admission) {
    showDialog(
      context: context,
      builder: (context) => _AdmissionFormDialog(
        admission: admission,
        onSave: (updatedAdmission) {
          _updateAdmission(updatedAdmission);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application updated successfully!')),
          );
        },
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

// --- Widgets from Block 2 for Card & Dialogs ---

class _AdmissionCard extends StatelessWidget {
  final Admission admission;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onChangeStatus;

  const _AdmissionCard({
    required this.admission,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeStatus,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xFF856404);
      case 'Approved': return const Color(0xFF155724);
      case 'Rejected': return const Color(0xFF721C24);
      case 'Enrolled': return const Color(0xFF004085);
      default: return Colors.black;
    }
  }

  Color _getStatusBg(String status) {
     switch (status) {
      case 'Pending': return const Color(0xFFFFF3CD);
      case 'Approved': return const Color(0xFFD4EDDA);
      case 'Rejected': return const Color(0xFFF8D7DA);
      case 'Enrolled': return const Color(0xFFCCE5FF);
      default: return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  admission.studentName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBg(admission.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  admission.status,
                  style: TextStyle(color: _getStatusColor(admission.status), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  else if (value == 'delete') {
                     showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Application'),
                        content: const Text('Are you sure you want to delete this application?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(onPressed: () { onDelete(); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  } else if (value.startsWith('status_')) {
                    onChangeStatus(value.replaceFirst('status_', ''));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                  const PopupMenuItem(value: 'status_Approved', child: Row(children: [Icon(Icons.check_circle, size: 18, color: Colors.green), SizedBox(width: 8), Text('Approve')])),
                  const PopupMenuItem(value: 'status_Rejected', child: Row(children: [Icon(Icons.cancel, size: 18, color: Colors.red), SizedBox(width: 8), Text('Reject')])),
                  const PopupMenuItem(value: 'status_Enrolled', child: Row(children: [Icon(Icons.school, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Enroll')])),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                ],
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DetailRow(label: "👤 Parent", value: admission.parentName),
                _DetailRow(label: "📚 Class", value: admission.applyingClass),
                _DetailRow(label: "📅 DOB", value: DateFormat('MMM dd, yyyy').format(admission.dateOfBirth)),
                _DetailRow(label: "🏷️ Category", value: admission.category),
              ],
            ),
          ),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               InkWell(
                 onTap: onView,
                 borderRadius: BorderRadius.circular(8),
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                   decoration: BoxDecoration(
                     gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: const Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.visibility, size: 16, color: Colors.white),
                       SizedBox(width: 8),
                       Text(
                         "View Details",
                         style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                       ),
                     ],
                   ),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w500, fontSize: 13)),
        Text(value, style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _AdmissionDetailDialog extends StatelessWidget {
  final Admission admission;
  const _AdmissionDetailDialog({required this.admission});

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
                  const Text('Admission Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              if (admission.studentId != null) _DetailItem('Student ID', admission.studentId!),
              if (admission.admissionNumber != null) _DetailItem('Admission Number', admission.admissionNumber!),
              _DetailItem('Student Name', admission.studentName),
              _DetailItem('Parent/Guardian', admission.parentName),
              if (admission.parentPhone != null) _DetailItem('Parent Phone', admission.parentPhone!),
              _DetailItem('Date of Birth', DateFormat('MMM dd, yyyy').format(admission.dateOfBirth)),
              _DetailItem('Gender', admission.gender),
              if (admission.bloodGroup != null) _DetailItem('Blood Group', admission.bloodGroup!),
              _DetailItem('Applying for Class', admission.applyingClass),
              if (admission.email != null) _DetailItem('Email', admission.email!),
              _DetailItem('Address', admission.address),
              if (admission.emergencyContact != null) _DetailItem('Emergency Contact', admission.emergencyContact!),
              if (admission.medicalInformation != null) _DetailItem('Medical Information', admission.medicalInformation!),
              _DetailItem('Category', admission.category),
              _DetailItem('Status', admission.status),
              if (admission.previousSchool != null) _DetailItem('Previous School', admission.previousSchool!),
              if (admission.remarks != null) _DetailItem('Remarks', admission.remarks!),
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
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _AdmissionFormDialog extends StatefulWidget {
  final Admission? admission;
  final Function(Admission) onSave;

  const _AdmissionFormDialog({this.admission, required this.onSave});

  @override
  State<_AdmissionFormDialog> createState() => _AdmissionFormDialogState();
}

class _AdmissionFormDialogState extends State<_AdmissionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _studentNameController;
  late TextEditingController _parentNameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _previousSchoolController;
  late TextEditingController _remarksController;

  DateTime? _dateOfBirth;
  String? _gender;
  String? _applyingClass;
  String? _category;

  @override
  void initState() {
    super.initState();
    final admission = widget.admission;
    _studentNameController = TextEditingController(text: admission?.studentName ?? '');
    _parentNameController = TextEditingController(text: admission?.parentName ?? '');
    _addressController = TextEditingController(text: admission?.address ?? '');
    _emailController = TextEditingController(text: admission?.email ?? '');
    _previousSchoolController = TextEditingController(text: admission?.previousSchool ?? '');
    _remarksController = TextEditingController(text: admission?.remarks ?? '');
    _dateOfBirth = admission?.dateOfBirth;
    _gender = admission?.gender;
    _applyingClass = admission?.applyingClass;
    _category = admission?.category;
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _parentNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _previousSchoolController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_dateOfBirth == null || _gender == null || _applyingClass == null || _category == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
        return;
      }

      final admission = Admission(
        id: widget.admission?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        studentName: _studentNameController.text.trim(),
        parentName: _parentNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        applyingClass: _applyingClass!,
        address: _addressController.text.trim(),
        category: _category!,
        status: widget.admission?.status ?? 'Pending',
        admissionNumber: widget.admission?.admissionNumber,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        previousSchool: _previousSchoolController.text.trim().isEmpty ? null : _previousSchoolController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      );

      widget.onSave(admission);
    }
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
                  Text(widget.admission == null ? 'New Admission' : 'Edit Admission', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(child: _buildTextField("Student Name *", _studentNameController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField("Parent Name *", _parentNameController)),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildDateField("Date of Birth *", _dateOfBirth, (d) => setState(() => _dateOfBirth = d))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("Gender *", ["Male", "Female", "Other"], _gender, (v) => setState(() => _gender = v))),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                         Expanded(child: _buildDropdown("Class *", List.generate(12, (i) => "Class ${i + 1}"), _applyingClass, (v) => setState(() => _applyingClass = v))),
                      ]),
                      const SizedBox(height: 16),
                      _buildTextField("Address *", _addressController, maxLines: 2),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildDropdown("Category *", ["General", "OBC", "SC", "ST", "EWS"], _category, (v) => setState(() => _category = v))),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                         Expanded(child: _buildTextField("Email", _emailController, isRequired: false)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildTextField("Prev. School", _previousSchoolController, isRequired: false)),
                      ]),
                      const SizedBox(height: 16),
                      _buildTextField("Remarks", _remarksController, maxLines: 2, isRequired: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667EEA), foregroundColor: Colors.white),
                    child: Text(widget.admission == null ? 'Submit' : 'Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool isRequired = true, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? val, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: val,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(date == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(date)),
      ),
    );
  }
}