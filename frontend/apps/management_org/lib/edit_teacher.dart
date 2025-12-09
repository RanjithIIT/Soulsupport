import 'services/api_service.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditTeacherPage extends StatefulWidget {
  final int? teacherId;

  const EditTeacherPage({super.key, this.teacherId});

  @override
  State<EditTeacherPage> createState() => _EditTeacherPageState();
}

class _EditTeacherPageState extends State<EditTeacherPage> {
  final _formKey = GlobalKey<FormState>();

  final _teacherIdController = TextEditingController();
  final _employeeNoController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _primaryRoomIdController = TextEditingController();
  final _classTeacherSectionIdController = TextEditingController();
  final _subjectSpecializationController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  String? _designation;
  String? _gender;
  DateTime? _dob;
  DateTime? _joiningDate;
  Uint8List? _photoBytes;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    if (widget.teacherId == null) return;
    try {
      final data = await ApiService.fetchTeacherById(widget.teacherId!);
      
      _teacherIdController.text = data['teacher_id']?.toString() ?? '';
      _employeeNoController.text = data['employee_no'] as String? ?? '';
      _firstNameController.text = data['first_name'] as String? ?? '';
      _lastNameController.text = data['last_name'] as String? ?? '';
      _qualificationController.text = data['qualification'] as String? ?? '';
      _designation = data['designation'] as String?;
      _gender = data['gender'] as String?;
      _mobileNoController.text = data['mobile_no'] as String? ?? '';
      _emailController.text = data['email'] as String? ?? '';
      _addressController.text = data['address'] as String? ?? '';
      _bloodGroupController.text = data['blood_group'] as String? ?? '';
      _nationalityController.text = data['nationality'] as String? ?? '';
      _primaryRoomIdController.text = data['primary_room_id'] as String? ?? '';
      _classTeacherSectionIdController.text = data['class_teacher_section_id'] as String? ?? '';
      _subjectSpecializationController.text = data['subject_specialization'] as String? ?? '';
      _emergencyContactController.text = data['emergency_contact'] as String? ?? '';
      
      if (data['dob'] != null) {
        _dob = DateTime.tryParse(data['dob']);
      }
      if (data['joining_date'] != null) {
        _joiningDate = DateTime.tryParse(data['joining_date']);
      }
      
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load teacher: $e')),
      );
    }
  }

  @override
  void dispose() {
    _teacherIdController.dispose();
    _employeeNoController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _qualificationController.dispose();
    _mobileNoController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    _nationalityController.dispose();
    _primaryRoomIdController.dispose();
    _classTeacherSectionIdController.dispose();
    _subjectSpecializationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoBytes = bytes;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _showSuccess = false;
      _showError = false;
      _errorMessage = '';
    });

    try {
      final payload = {
        'employee_no': _employeeNoController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'joining_date': _joiningDate != null 
            ? DateFormat('yyyy-MM-dd').format(_joiningDate!) 
            : null,
        'dob': _dob != null 
            ? DateFormat('yyyy-MM-dd').format(_dob!) 
            : null,
        'gender': _gender,
        'designation': _designation,
        'mobile_no': _mobileNoController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'blood_group': _bloodGroupController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'primary_room_id': _primaryRoomIdController.text.trim(),
        'class_teacher_section_id': _classTeacherSectionIdController.text.trim(),
        'subject_specialization': _subjectSpecializationController.text.trim(),
        'emergency_contact': _emergencyContactController.text.trim(),
      };

      if (widget.teacherId != null) {
        await ApiService.updateTeacher(widget.teacherId!, payload);
      }

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
      });
      Navigator.pushReplacementNamed(context, '/teachers');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
        _errorMessage = 'Error updating teacher: $e';
      });
    }
  }

  void _previewTeacher() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('👨‍🏫 Teacher Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewItem('Teacher ID', _teacherIdController.text),
              _PreviewItem('Employee No', _employeeNoController.text),
              _PreviewItem('Name', '${_firstNameController.text} ${_lastNameController.text}'.trim()),
              _PreviewItem('Designation', _designation ?? 'Not provided'),
              _PreviewItem('Gender', _gender ?? 'Not provided'),
              _PreviewItem('Mobile No', _mobileNoController.text),
              _PreviewItem('Email', _emailController.text),
              _PreviewItem('Address', _addressController.text),
              _PreviewItem('Blood Group', _bloodGroupController.text),
              _PreviewItem('Nationality', _nationalityController.text),
              _PreviewItem('Qualification', _qualificationController.text),
              _PreviewItem('Class Teacher Section ID', _classTeacherSectionIdController.text),
              _PreviewItem('Subject Specialization', _subjectSpecializationController.text),
              _PreviewItem('Emergency Contact', _emergencyContactController.text),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close Preview'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(gradient: gradient),
          Expanded(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _Header(gradient: gradient),
                      _FormCard(
                        formKey: _formKey,
                        gradient: gradient,
                        teacherIdController: _teacherIdController,
                        employeeNoController: _employeeNoController,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        qualificationController: _qualificationController,
                        designation: _designation,
                        onDesignationChanged: (value) {
                          setState(() {
                            _designation = value;
                          });
                        },
                        gender: _gender,
                        onGenderChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        dob: _dob,
                        onDobChanged: (value) {
                          setState(() {
                            _dob = value;
                          });
                        },
                        joiningDate: _joiningDate,
                        onJoiningDateChanged: (value) {
                          setState(() {
                            _joiningDate = value;
                          });
                        },
                        mobileNoController: _mobileNoController,
                        emailController: _emailController,
                        addressController: _addressController,
                        bloodGroupController: _bloodGroupController,
                        nationalityController: _nationalityController,
                        primaryRoomIdController: _primaryRoomIdController,
                        classTeacherSectionIdController: _classTeacherSectionIdController,
                        subjectSpecializationController: _subjectSpecializationController,
                        emergencyContactController: _emergencyContactController,
                        photoBytes: _photoBytes,
                        onPickPhoto: _pickPhoto,
                        isSubmitting: _isSubmitting,
                        showSuccess: _showSuccess,
                        showError: _showError,
                        errorMessage: _errorMessage,
                        onSubmit: _submitForm,
                        onPreview: _previewTeacher,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final LinearGradient gradient;

  const _Sidebar({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
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
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  _NavItem(
                    icon: '📊',
                    title: 'Dashboard',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    isActive: true,
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/events'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final LinearGradient gradient;

  const _Header({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Edit Teacher',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Management User',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'School Manager',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/teachers');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Teachers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LinearGradient gradient;
  final TextEditingController teacherIdController;
  final TextEditingController employeeNoController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController qualificationController;
  final String? designation;
  final ValueChanged<String?> onDesignationChanged;
  final String? gender;
  final ValueChanged<String?> onGenderChanged;
  final DateTime? dob;
  final ValueChanged<DateTime?> onDobChanged;
  final DateTime? joiningDate;
  final ValueChanged<DateTime?> onJoiningDateChanged;
  final TextEditingController mobileNoController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController bloodGroupController;
  final TextEditingController nationalityController;
  final TextEditingController primaryRoomIdController;
  final TextEditingController classTeacherSectionIdController;
  final TextEditingController subjectSpecializationController;
  final TextEditingController emergencyContactController;
  final Uint8List? photoBytes;
  final Future<void> Function() onPickPhoto;
  final bool isSubmitting;
  final bool showSuccess;
  final bool showError;
  final String errorMessage;
  final Future<void> Function() onSubmit;
  final VoidCallback onPreview;

  const _FormCard({
    required this.formKey,
    required this.gradient,
    required this.teacherIdController,
    required this.employeeNoController,
    required this.firstNameController,
    required this.lastNameController,
    required this.qualificationController,
    required this.designation,
    required this.onDesignationChanged,
    required this.gender,
    required this.onGenderChanged,
    required this.dob,
    required this.onDobChanged,
    required this.joiningDate,
    required this.onJoiningDateChanged,
    required this.mobileNoController,
    required this.emailController,
    required this.addressController,
    required this.bloodGroupController,
    required this.nationalityController,
    required this.primaryRoomIdController,
    required this.classTeacherSectionIdController,
    required this.subjectSpecializationController,
    required this.emergencyContactController,
    required this.photoBytes,
    required this.onPickPhoto,
    required this.isSubmitting,
    required this.showSuccess,
    required this.showError,
    required this.errorMessage,
    required this.onSubmit,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 800),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    '👨‍🏫 Edit Teacher Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Update teacher details and save changes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (showSuccess)
              _MessageBanner(
                gradientColors: const [Color(0xFF51CF66), Color(0xFF40C057)],
                icon: Icons.check_circle,
                text: '✅ Teacher information updated successfully!',
              ),
            if (showError)
              _MessageBanner(
                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                icon: Icons.error,
                text: '❌ $errorMessage',
              ),
            if (isSubmitting)
              const _LoadingBanner(text: 'Updating teacher information...'),
            _PhotoUpload(
              gradient: gradient,
              photoBytes: photoBytes,
              onPickPhoto: onPickPhoto,
            ),
            const SizedBox(height: 20),
            // Teacher ID (read-only)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: teacherIdController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Teacher ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.badge),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: employeeNoController,
                    decoration: InputDecoration(
                      labelText: 'Employee Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.work),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // First Name and Last Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter first name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter last name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date of Birth and Gender
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dob ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        onDobChanged(date);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dob != null
                            ? DateFormat('yyyy-MM-dd').format(dob!)
                            : 'Select date of birth',
                        style: TextStyle(
                          color: dob != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.people),
                    ),
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: onGenderChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Qualification and Joining Date
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: qualificationController,
                    decoration: InputDecoration(
                      labelText: 'Qualification',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.school),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: joiningDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        onJoiningDateChanged(date);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Joining Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.event),
                      ),
                      child: Text(
                        joiningDate != null
                            ? DateFormat('yyyy-MM-dd').format(joiningDate!)
                            : 'Select joining date',
                        style: TextStyle(
                          color: joiningDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Designation
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Designation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    value: designation,
                    items: const [
                      'Mathematics',
                      'Physics',
                      'Chemistry',
                      'Biology',
                      'English',
                      'History',
                      'Geography',
                      'Computer Science',
                      'Physical Education',
                      'Art',
                      'Music',
                      'Principal',
                      'Vice Principal',
                      'Coordinator',
                    ]
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: onDesignationChanged,
            ),
            const SizedBox(height: 20),
            // Mobile No and Email
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: mobileNoController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Address
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Enter complete address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Blood Group and Nationality
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: bloodGroupController,
                    decoration: InputDecoration(
                      labelText: 'Blood Group',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.bloodtype),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: nationalityController,
                    decoration: InputDecoration(
                      labelText: 'Nationality',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.public),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Primary Room ID and Class Teacher Section ID
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: primaryRoomIdController,
              decoration: InputDecoration(
                      labelText: 'Primary Room ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.room),
                    ),
                  ),
              ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: classTeacherSectionIdController,
                    decoration: InputDecoration(
                      labelText: 'Class Teacher Section ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.class_),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Subject Specialization
            TextFormField(
              controller: subjectSpecializationController,
              decoration: InputDecoration(
                labelText: 'Subject Specialization',
                hintText: 'Enter subject specialization details',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.star),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Emergency Contact
            TextFormField(
              controller: emergencyContactController,
              decoration: InputDecoration(
                labelText: 'Emergency Contact',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.emergency),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: const Icon(Icons.save),
                  label: const Text('Update Teacher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD93D),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/teachers');
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: widget.isActive
              ? Colors.white.withValues(alpha: 0.3)
              : _isHovered
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: ListTile(
          leading: Text(widget.icon, style: const TextStyle(fontSize: 20, color: Colors.white)),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.white,
              fontWeight: widget.isActive || _isHovered
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: widget.isActive || _isHovered ? 15.0 : 14.0,
            ),
            child: Text(widget.title),
          ),
          selected: widget.isActive,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String text;

  const _MessageBanner({
    required this.gradientColors,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  final String text;

  const _LoadingBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
          ),
          const SizedBox(height: 15),
          Text(text),
        ],
      ),
    );
  }
}

class _PhotoUpload extends StatelessWidget {
  final LinearGradient gradient;
  final Uint8List? photoBytes;
  final Future<void> Function() onPickPhoto;

  const _PhotoUpload({
    required this.gradient,
    required this.photoBytes,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPickPhoto,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (photoBytes != null)
              ClipOval(
                child: Image.memory(
                  photoBytes!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.photo_camera, color: Colors.white, size: 40),
                ),
              ),
            const SizedBox(height: 15),
            const Text(
              'Tap to upload new photo or drag and drop',
              style: TextStyle(
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

