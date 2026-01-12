import 'package:flutter/material.dart';
import 'package:main_login/main.dart' as main_login;
import 'services/api_service.dart' as api;
import 'services/download_service.dart';
import 'package:url_launcher/url_launcher.dart';

// --- UTILITY FUNCTION TO CREATE CUSTOM MATERIAL COLOR ---
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 0; i < 10; i++) {
    int strengthKey = (strengths[i] * 1000).round();
    if (strengthKey < 100) strengthKey = 50;
    swatch[strengthKey] = Color.fromRGBO(r, g, b, strengths[i]);
  }
  return MaterialColor(color.value, swatch);
}

// -------------------------------------------------------------------------
// 1. VOID MAIN (THE ENTRY POINT)
// -------------------------------------------------------------------------

void main() {
  runApp(const SchoolManagementSystemApp());
}

// -------------------------------------------------------------------------
// 2. THEME AND APP CONTAINER
// -------------------------------------------------------------------------

class SchoolManagementSystemApp extends StatelessWidget {
  const SchoolManagementSystemApp({super.key});

  // Define the custom colors based on the image
  static const Color primaryPurple = Color(0xFF667eea);
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color lightBackground = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Calendar - School Management App',
      theme: ThemeData(
        primarySwatch: createMaterialColor(primaryPurple),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
          secondary: accentAmber,
          background: lightBackground,
          onPrimary: Colors.white,
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
      ),
      home: const StudentProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// -------------------------------------------------------------------------
// 3. DATA MODELS
// -------------------------------------------------------------------------

class StudentData {
  final String name;
  final String id;
  final String grade;
  final String section;
  final String rollNumber;
  final String dob;
  final String age;
  final String gender;
  final String admissionNo;
  final String attendanceRate;
  final String gpa;
  final String classRank;
  final String achievementsCount;
  final String fatherName;
  final String motherName;
  final String phoneNumber;
  final String email;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String bloodGroup;
  final String transportMode;
  final String nationality;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final List<Map<String, String>> achievementsList;
  final List<Map<String, String>> currentSubjects;
  final List<Map<String, dynamic>> awards;
  final String activities;
  final String leadership;
  final String participation;
  final String otherAchievements;
  final String? profilePhotoUrl;


  StudentData.mock()
    : name = 'John Michael Smith',
      id = 'STU-2024-001',
      grade = 'Grade 9',
      section = 'Section A',
      rollNumber = '25',
      dob = 'March 15, 2010',
      age = '14 years',
      gender = 'Male',
      admissionNo = 'ADM-2020-42',
      attendanceRate = '95%',
      gpa = '3.8',
      classRank = '5',
      achievementsCount = '12',
      fatherName = "Michael Smith",
      motherName = "Sarah Smith",
      phoneNumber = "+1 (555) 123-4567",
      email = "smith.family@email.com",
      address = "123 Education Street",
      city = "Learning City",
      state = "Knowledge State",
      postalCode = "12345",
      bloodGroup = "O+",
      transportMode = "School Bus",
      nationality = "Indian",
      emergencyContactName = "Aunt Jane Doe",
      emergencyContactPhone = "+1 (555) 987-6543",
      currentSubjects = [
        {'subject': 'Mathematics', 'teacher': 'Mrs. K. Sharma'},
        {'subject': 'Science', 'teacher': 'Mr. D. Patel'},
        {'subject': 'English Lit.', 'teacher': 'Ms. A. Singh'},
        {'subject': 'World History', 'teacher': 'Dr. J. Khan'},
      ],
      achievementsList = [
        {
          'title': 'Academic Excellence Award',
          'date': '2024',
          'description': 'Outstanding performance in Mathematics and Science',
        },
        {
          'title': 'Sports Champion',
          'date': '2023',
          'description': 'First place in inter-school basketball tournament',
        },
        {
          'title': 'Science Fair Winner',
          'date': '2023',
          'description': 'Best project award for renewable energy model',
        },
      ],
      awards = [],
      activities = '',
      leadership = '',
      participation = '',
      otherAchievements = '',
      profilePhotoUrl = null;


  // Constructor to create StudentData from API response
  StudentData.fromJson(Map<String, dynamic> studentJson, Map<String, dynamic> parentJson)
      : name = _getFullName(studentJson),
        id = _safeString(studentJson['student_id']),
        grade = _safeString(studentJson['class_name']),
        section = _safeString(studentJson['section']),
        rollNumber = _safeString(studentJson['student_id']),
        dob = _formatDate(_safeString(studentJson['date_of_birth'])),
        age = _calculateAge(_safeString(studentJson['date_of_birth'])),
        gender = _safeString(studentJson['gender']),
        admissionNo = _safeString(studentJson['student_id']),
        attendanceRate = '0%', // TODO: Calculate from attendance data
        gpa = '0.0', // TODO: Calculate from grades
        classRank = '0', // TODO: Calculate from class data
        fatherName = _safeString(studentJson['parent_name']),
        motherName = '', // Not available in current schema
        phoneNumber = _safeString(studentJson['parent_phone']),
        email = _getEmail(studentJson),
        address = _safeString(studentJson['address']),
        city = '', // Extract from address if needed
        state = '', // Extract from address if needed
        postalCode = '', // Extract from address if needed
        bloodGroup = _safeString(studentJson['blood_group']),
        transportMode = _safeString(studentJson['bus_route']).isNotEmpty ? _safeString(studentJson['bus_route']) : 'N/A',
        nationality = 'Indian', // Default
        emergencyContactName = _safeString(studentJson['emergency_contact']),
        emergencyContactPhone = '', // Not available in current schema
        currentSubjects = [], // TODO: Fetch from timetable/classes
        awards = _getSortedAwards(studentJson['awards']),
        achievementsList = _parseAwardsToAchievements(_getSortedAwards(studentJson['awards'])),
        achievementsCount = (studentJson['awards'] as List?)?.length.toString() ?? '0',
        activities = _safeString(studentJson['activities']),
        leadership = _safeString(studentJson['leadership']),
        participation = _safeString(studentJson['participation']),
        otherAchievements = _safeString(studentJson['achievements']),
        profilePhotoUrl = _safeString(studentJson['profile_photo_url']).isNotEmpty 
            ? _safeString(studentJson['profile_photo_url']) 
            : (_safeString(studentJson['profile_photo']).isNotEmpty ? _safeString(studentJson['profile_photo']) : null);

  static List<Map<String, String>> _parseAwardsToAchievements(dynamic awardsJson) {
    if (awardsJson == null || awardsJson is! List) return [];
    return awardsJson.map((award) {
      if (award is! Map) return {'title': '', 'date': '', 'description': ''};
      return {
        'title': _safeString(award['title']),
        'date': _safeString(award['date']),
        'description': '${_safeString(award['category'])} - ${_safeString(award['level'])}\n${_safeString(award['description'])}',
      };
    }).toList().cast<Map<String, String>>();
  }

  static List<Map<String, dynamic>> _getSortedAwards(dynamic awardsJson) {
    if (awardsJson == null || awardsJson is! List) return [];
    final list = List<Map<String, dynamic>>.from(awardsJson);
    
    list.sort((a, b) {
      // Primary: ID (Latest addition)
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      if (idB != idA) return idB.compareTo(idA);
      
      // Secondary: Date
      final dateA = a['date']?.toString() ?? '';
      final dateB = b['date']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });
    
    return list;
  }


  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static String _getFullName(Map<String, dynamic> studentJson) {
    try {
      final user = studentJson['user'];
      if (user != null && user is Map) {
        final userMap = user as Map<String, dynamic>;
        final first = _safeString(userMap['first_name']);
        final last = _safeString(userMap['last_name']);
        final fullName = ('$first $last').trim();
        if (fullName.isNotEmpty) {
          return fullName;
        }
      }
      final studentId = _safeString(studentJson['student_id']);
      return studentId.isNotEmpty ? studentId : 'Student';
    } catch (e) {
      return 'Student';
    }
  }

  static String _getEmail(Map<String, dynamic> studentJson) {
    try {
      final user = studentJson['user'];
      if (user != null && user is Map) {
        final userMap = user as Map<String, dynamic>;
        return _safeString(userMap['email']);
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  static String _calculateAge(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      return '';
    }
  }
}

// -------------------------------------------------------------------------
// 5. GENERIC HELPER METHODS (Static/External)
// -------------------------------------------------------------------------

void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 800),
    ),
  );
}

Widget _buildPageHeader(BuildContext context, Color primaryColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Student Profile',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'View and manage student details.',
        style: TextStyle(color: Color(0xff666666), fontSize: 16),
      ),
    ],
  );
}

Widget _buildSectionTitle(String emoji, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Widget _buildInfoCard(String title, List<Map<String, String>> items) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xfff8f9fa),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xff333333),
          ),
        ),
        const Divider(height: 15),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['label']}:',
                  style: const TextStyle(
                    color: Color(0xff666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  // Use Expanded to handle long values
                  child: Text(
                    item['value']!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w600,
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

// 🆕 EDIT MOCK MODAL (External definition)
void _showEditProfileModal(BuildContext context, StudentData data) {
  final phoneController = TextEditingController(text: data.phoneNumber);
  final emailController = TextEditingController(text: data.email);
  final emergencyNameController = TextEditingController(
    text: data.emergencyContactName,
  );
  final emergencyPhoneController = TextEditingController(
    text: data.emergencyContactPhone,
  );
  final addressController = TextEditingController(text: data.address);
  final cityController = TextEditingController(text: data.city);
  final stateController = TextEditingController(text: data.state);
  final postalCodeController = TextEditingController(text: data.postalCode);

  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom + 25,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "✏️ Edit Contact & Address",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 25),

                // Contact Section Title
                Text(
                  "Parent Contact",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 15),

                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Primary Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Phone cannot be empty' : null,
                ),
                const SizedBox(height: 15),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Primary Email Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Email cannot be empty' : null,
                ),
                const Divider(height: 30),

                // Emergency Contact Title
                Text(
                  "Emergency Contact",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 15),

                // Emergency Name
                TextFormField(
                  controller: emergencyNameController,
                  decoration: const InputDecoration(
                    labelText: "Emergency Contact Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // Emergency Phone
                TextFormField(
                  controller: emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Emergency Phone",
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(height: 30),

                // Address Title
                Text(
                  "Residential Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 15),

                // Address Line
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Street Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // City, State, Postal Code
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: "City",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: stateController,
                        decoration: const InputDecoration(
                          labelText: "State",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: postalCodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "P. Code",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Mock save and close
                        Navigator.pop(context);
                        _showSnackbar(
                          context,
                          "Changes saved successfully! (Mock)",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// 🆕 NEW FEATURE: Mock Profile Picture Update Modal (External definition)
void _showPictureUpdateModal(BuildContext context) {
  final primaryColor = Theme.of(context).primaryColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("📸 Update Profile Photo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload a new photo for the student profile.",
              style: TextStyle(color: Color(0xff666666)),
            ),
            const SizedBox(height: 20),

            // Mock File Input Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: primaryColor),
                  const SizedBox(height: 10),
                  const Text(
                    "Click to select file (Max: 2MB)",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Note: Uploads are restricted to 2MB maximum size to ensure fast loading across the portal.",
              style: TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(
                context,
                "Upload Initiated (Mock file size check complete!)",
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Upload Photo"),
          ),
        ],
      );
    },
  );
}

// Achievement Details Modal
void _showAchievementDetailsModal(
  BuildContext context,
  Map<String, String> achievement,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🏆 Achievement Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 25),

            // Title and Date
            Text(
              achievement['title']!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              achievement['date']!,
              style: const TextStyle(color: Color(0xff666666), fontSize: 16),
            ),

            const Divider(height: 30),

            // Description
            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['description']!,
              style: const TextStyle(
                color: Color(0xff333333),
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// In-app certificate viewer (similar to management portal for consistency)
void _showCertificateDialog(BuildContext context, Map<String, dynamic> award, {String? studentId}) {
  String? docUrl;
  
  // 1. Try to find a specific certificate for this student in a team award
  if (studentId != null && award['certificates'] is List) {
    try {
      final certs = award['certificates'] as List;
      final studentCert = certs.firstWhere(
        (c) => c is Map && c['student_id']?.toString() == studentId,
        orElse: () => null,
      );
      if (studentCert != null) {
        docUrl = studentCert['document_url'] ?? studentCert['document'];
      }
    } catch (e) {
      debugPrint("Error finding student specific certificate: $e");
    }
  }

  // 2. Fallback to main award document
  docUrl ??= award['document_url'] ?? award['document'];

  if (docUrl == null || docUrl.toString().isEmpty) {
    _showSnackbar(context, "No certificate document available");
    return;
  }

  // Ensure full URL
  String fullUrl = docUrl.toString();
  if (!fullUrl.startsWith('http')) {
    // If it doesn't start with http, it's a relative path.
    // Try to determine if it needs the /media/ prefix.
    String path = fullUrl;
    if (!path.startsWith('/media/') && !path.startsWith('media/')) {
      path = '/media/${path.startsWith('/') ? path.substring(1) : path}';
    }
    fullUrl = 'http://127.0.0.1:8000${path.startsWith('/') ? '' : '/'}$path';
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Certificate: ${award['title']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Image Viewer
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text("Could not load certificate image"),
                            TextButton(
                              onPressed: () => launchUrl(Uri.parse(fullUrl)),
                              child: const Text("Open in Browser"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Footer Actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text("Download Certificate", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745), // Green for download
                      ),
                      onPressed: () async {
                        try {
                          _showSnackbar(context, "Starting download...");
                          final fileName = "Certificate_${award['title']}.png".replaceAll(' ', '_');
                          await DownloadService.downloadCertificate(fullUrl, fileName);
                          _showSnackbar(context, "Download successful!");
                        } catch (e) {
                          _showSnackbar(context, "Download failed: $e");
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Open in Browser"),
                      onPressed: () => launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -------------------------------------------------------------------------
// 4. STUDENT PROFILE PAGE
// -------------------------------------------------------------------------

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  StudentData? _studentData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch current logged-in student's profile
      final studentData = await api.ApiService.fetchStudentProfile();
      if (studentData != null) {
        // Try to get parent data for additional context (optional)
        Map<String, dynamic>? parentData;
        try {
          parentData = await api.ApiService.fetchParentProfile();
        } catch (e) {
          // Parent data is optional, continue without it
        }
        
        setState(() {
          _studentData = StudentData.fromJson(studentData, parentData ?? {});
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _error = 'No student data found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load student data: $e';
        _isLoading = false;
      });
    }
  }

  // Generic container for main content blocks (Personal Info, Contact, Achievements)
  Widget _buildInfoContainer(
    BuildContext context,
    Widget title,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, content],
      ),
    );
  }

  Widget _buildProfileSummary(
    BuildContext context,
    StudentData data,
    Color primary,
    Color secondary,
  ) {
    // accentColor extracted from theme if needed for custom styling

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Center for profile photo
        children: [
          // Profile Photo
          GestureDetector(
            onTap: () =>
                _showPictureUpdateModal(context), // 🎯 Linked to update modal
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primary, secondary]),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: data.profilePhotoUrl != null && data.profilePhotoUrl!.isNotEmpty
                        ? Image.network(
                            data.profilePhotoUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Text(
                              '👨‍🎓',
                              style: TextStyle(fontSize: 40, color: Colors.white),
                            ),
                          )
                        : const Text(
                            '👨‍🎓',
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                  ),
                  // Edit icon overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 14, color: primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text(
            data.id,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff666666), fontSize: 13),
          ),
          const Divider(height: 30),

          // Stats Grid (Horizontal ListView for scrolling stats)
          SizedBox(
            height: 115, // Fixed height for horizontal scrolling
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                // Overall GPA (Primary Purple)
                _buildStatCard(
                  Icons.menu_book,
                  data.gpa,
                  'Overall GPA',
                  primary,
                ),
                // Class Rank (Accent Amber/Gold)
                _buildStatCard(
                  Icons.emoji_events,
                  data.classRank,
                  'Class Rank',
                  secondary,
                ),
                // Attendance (Primary Purple)
                _buildStatCard(
                  Icons.show_chart,
                  data.attendanceRate,
                  'Attendance',
                  primary,
                ),
                // Awards (Accent Amber/Gold)
                _buildStatCard(
                  Icons.workspace_premium,
                  data.achievementsCount,
                  'Awards',
                  secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          _buildActionButtons(context, primary, data),
        ],
      ),
    );
  }

  // Redefined Stat Card to match the image look (Icons and colors)
  Widget _buildStatCard(
    IconData icon,
    String number,
    String label,
    Color accentColor,
  ) {
    return Container(
      width: 140, // Fixed width for horizontal list
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start, // Left aligned content
            children: [
              Row(
                // Icon and number alignment
                children: [
                  Icon(icon, size: 24, color: accentColor), // Icon
                ],
              ),
              const SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ), // Number
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 12, color: Color(0xff666666)),
              ), // Label
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, StudentData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🏆', 'Achievements & Awards'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.awards.length,
            itemBuilder: (context, index) {
              final award = data.awards[index];
              return _buildDetailedAwardCard(context, award, data.id);
            },
          ),
          if (data.awards.isEmpty && data.achievementsList.isNotEmpty)
             ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.achievementsList.length,
              itemBuilder: (context, index) {
                final achievement = data.achievementsList[index];
                return GestureDetector(
                  onTap: () => _showAchievementDetailsModal(
                    context,
                    achievement,
                  ), // Modal trigger
                  child: _buildAchievementCard(achievement),
                );
              },
            ),
          if (data.awards.isEmpty && data.achievementsList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No records found", style: TextStyle(color: Colors.grey))),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedAwardCard(BuildContext context, Map<String, dynamic> award, String studentId) {
    bool hasDoc = award['document'] != null && award['document'].toString().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xff28a745), width: 4),
        ), // Green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  award['title'] ?? 'Award',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  award['level'] ?? 'N/A',
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            '${award['date'] ?? 'N/A'} • ${award['category'] ?? 'General'}',
            style: const TextStyle(color: Color(0xff666666), fontSize: 13),
          ),
          if ((award['description'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                award['description'],
                style: const TextStyle(color: Color(0xff666666), fontSize: 14),
              ),
            ),
          if ((award['presented_by'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Presented by: ${award['presented_by']}',
                style: const TextStyle(color: Color(0xff666666), fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          if (hasDoc) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: TextButton.icon(
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text("View Certificate", style: TextStyle(fontSize: 12)),
                onPressed: () => _showCertificateDialog(context, award, studentId: studentId),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, String> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xff28a745), width: 4),
        ), // Green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement['title']!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            achievement['date']!,
            style: const TextStyle(color: Color(0xff666666), fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            achievement['description']!,
            style: const TextStyle(color: Color(0xff666666), fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Color primary,
    StudentData data,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () =>
              _showEditProfileModal(context, data), // 🎯 LINKED TO EDIT MODAL
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 45),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        // 🆕 Download Report button with icon
        ElevatedButton.icon(
          onPressed: () => _showSnackbar(context, "Downloading Report..."),
          icon: const Icon(
            Icons.download_for_offline,
            color: Colors.white,
            size: 20,
          ),
          label: const Text(
            'Download Report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
        const SizedBox(height: 10),
        // 🆕 Contact Teacher button with icon
        ElevatedButton.icon(
          onPressed: () => _showSnackbar(context, "Contacting Teacher..."),
          icon: const Icon(Icons.contact_mail, color: Colors.white, size: 20),
          label: const Text(
            'Contact Teacher',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Student Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _studentData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Student Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'No student data available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStudentData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _studentData!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Action Menu Button (replaces direct Logout)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
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
                              builder: (context) => const main_login.LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Page Header (Now uses external helper)
            _buildPageHeader(context, primaryColor),
            const SizedBox(height: 20),

            // 2. Profile Summary (Photo + SLIDING Stats + Actions)
            _buildProfileSummary(context, data, primaryColor, secondaryColor),
            const SizedBox(height: 20),

            // 3. Personal Information
            _buildInfoContainer(
              context,
              _buildSectionTitle('👤', 'Personal Information'),
              Column(
                children: [
                  _buildInfoCard('Basic Details', [
                    {'label': 'Full Name', 'value': data.name},
                    {'label': 'Date of Birth', 'value': data.dob},
                    {'label': 'Age', 'value': data.age},
                    {'label': 'Gender', 'value': data.gender},
                    {'label': 'Blood Group', 'value': data.bloodGroup},
                    {'label': 'Transport Mode', 'value': data.transportMode},
                    {'label': 'Nationality', 'value': data.nationality},
                  ]),
                  // 🆕 New: Current Subjects List
                  _buildInfoCard(
                    'Current Subjects',
                    data.currentSubjects
                        .map(
                          (s) => {
                            'label': s['subject']!,
                            'value': s['teacher']!,
                          },
                        )
                        .toList(),
                  ),

                  _buildInfoCard('Academic Information', [
                    {'label': 'Grade', 'value': data.grade},
                    {'label': 'Section', 'value': data.section},
                    {'label': 'Roll Number', 'value': data.rollNumber},
                    {'label': 'Admission No.', 'value': data.admissionNo},
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Contact Information
            _buildInfoContainer(
              context,
              _buildSectionTitle('📞', 'Contact Information'),
              Column(
                children: [
                  _buildInfoCard("Parent/Guardian Details", [
                    {'label': "Father's Name", 'value': data.fatherName},
                    {'label': "Mother's Name", 'value': data.motherName},
                    {'label': 'Phone Number', 'value': data.phoneNumber},
                    {'label': 'Email', 'value': data.email},
                  ]),
                  // 🆕 Added Emergency Contact
                  _buildInfoCard("Emergency Contact", [
                    {
                      'label': 'Contact Name',
                      'value': data.emergencyContactName,
                    },
                    {'label': 'Phone', 'value': data.emergencyContactPhone},
                  ]),
                  _buildInfoCard("Address", [
                    {'label': 'Address', 'value': data.address},
                    {'label': 'City', 'value': data.city},
                    {'label': 'State', 'value': data.state},
                    {'label': 'Postal Code', 'value': data.postalCode},
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Achievements
            _buildAchievementsSection(context, data),
            const SizedBox(height: 20),

            // 6. Extracurricular & Leadership
            if (data.activities.isNotEmpty || data.leadership.isNotEmpty || data.participation.isNotEmpty || data.otherAchievements.isNotEmpty)
              _buildInfoContainer(
                context,
                _buildSectionTitle('🌟', 'Extracurricular & Leadership'),
                Column(
                  children: [
                    if (data.activities.isNotEmpty)
                      _buildInfoCard('Activities', [
                        {'label': 'Details', 'value': data.activities},
                      ]),
                    if (data.leadership.isNotEmpty)
                      _buildInfoCard('Leadership', [
                        {'label': 'Roles', 'value': data.leadership},
                      ]),
                    if (data.participation.isNotEmpty)
                      _buildInfoCard('Participation', [
                        {'label': 'Record', 'value': data.participation},
                      ]),
                    if (data.otherAchievements.isNotEmpty)
                      _buildInfoCard('Other Achievements', [
                        {'label': 'Records', 'value': data.otherAchievements},
                      ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
