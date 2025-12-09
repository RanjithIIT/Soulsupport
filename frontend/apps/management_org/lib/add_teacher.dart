import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';
import 'services/api_service.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
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

  TeacherPreviewData get _previewData => TeacherPreviewData(
        teacherId: _teacherIdController.text,
        employeeNo: _employeeNoController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        designation: _designation,
        mobileNo: _mobileNoController.text,
        email: _emailController.text,
        address: _addressController.text,
        classTeacherSectionId: _classTeacherSectionIdController.text,
        qualification: _qualificationController.text,
        subjectSpecialization: _subjectSpecializationController.text,
      );

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
    });

    try {
      // Prepare teacher data for API
      final teacherData = {
        'employee_no': _employeeNoController.text.trim().isNotEmpty 
            ? _employeeNoController.text.trim() 
            : 'EMP-${DateTime.now().millisecondsSinceEpoch}',
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
        'is_active': true,
      };

      // Call API to create teacher
      final response = await ApiService.createTeacher(teacherData);
      
      if (!mounted) return;
      
      // Populate teacher_id from response if available
      if (response['teacher_id'] != null) {
        _teacherIdController.text = response['teacher_id'].toString();
      }
      
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
        _errorMessage = '';
      });
      
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/teachers');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _previewTeacher() async {
    final data = _previewData;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👨‍🏫 Teacher Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (data.teacherId != null && data.teacherId!.isNotEmpty)
                      _PreviewRow(label: 'Teacher ID', value: data.teacherId),
                    if (data.employeeNo != null && data.employeeNo!.isNotEmpty)
                      _PreviewRow(label: 'Employee No', value: data.employeeNo),
                    _PreviewRow(
                      label: 'Name',
                      value: '${data.firstName ?? ''} ${data.lastName ?? ''}'.trim(),
                    ),
                    _PreviewRow(label: 'Designation', value: data.designation),
                    _PreviewRow(label: 'Mobile No', value: data.mobileNo),
                    _PreviewRow(label: 'Email', value: data.email),
                    _PreviewRow(label: 'Address', value: data.address),
                    _PreviewRow(label: 'Class Teacher Section ID', value: data.classTeacherSectionId),
                    _PreviewRow(label: 'Qualification', value: data.qualification),
                    _PreviewRow(label: 'Subject Specialization', value: data.subjectSpecialization),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close Preview'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 768;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 16),
                            SizedBox(width: 6),
                            Text('Back to Dashboard'),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isCompact ? 20 : 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_showSuccess)
                              const _MessageBanner.success(
                                message:
                                    '✅ Teacher added successfully! Redirecting to dashboard...',
                              ),
                            if (_showError)
                              _MessageBanner.error(
                                message:
                                    _errorMessage.isNotEmpty ? _errorMessage : '❌ Error adding teacher. Please try again.',
                              ),
                            if (_isSubmitting)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: _LoadingIndicator(),
                              ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isTwoColumns = constraints.maxWidth > 600;
                                return Wrap(
                                  spacing: 30,
                                  runSpacing: 30,
                                  children: [
                                    // Teacher ID (read-only, auto-generated)
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Teacher ID',
                                        child: TextFormField(
                                          controller: _teacherIdController,
                                          enabled: false,
                                          decoration: _inputDecoration(
                                            hint: 'Auto-generated',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Employee No
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Employee Number',
                                        child: TextFormField(
                                          controller: _employeeNoController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter employee number (optional)',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // First Name *
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'First Name *',
                                        child: TextFormField(
                                          controller: _firstNameController,
                                          decoration: _inputDecoration(
                                            hint: "Enter teacher's first name",
                                          ),
                                          validator: _requiredValidator,
                                        ),
                                      ),
                                    ),
                                    // Last Name
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Last Name',
                                        child: TextFormField(
                                          controller: _lastNameController,
                                          decoration: _inputDecoration(
                                            hint: "Enter teacher's last name",
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Date of Birth
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Date of Birth',
                                        child: InkWell(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                                              firstDate: DateTime(1950),
                                              lastDate: DateTime.now(),
                                            );
                                            if (date != null) {
                                              setState(() => _dob = date);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: _inputDecoration(
                                              hint: 'Select date of birth',
                                            ),
                                            child: Text(
                                              _dob != null
                                                  ? DateFormat('yyyy-MM-dd').format(_dob!)
                                                  : 'Select date of birth',
                                              style: TextStyle(
                                                color: _dob != null ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Gender
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Gender',
                                        child: DropdownButtonFormField<String>(
                                          value: _gender,
                                          items: const [
                                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                                          ],
                                          decoration: _inputDecoration(
                                            hint: 'Select gender',
                                          ),
                                          onChanged: (value) => setState(() => _gender = value),
                                        ),
                                      ),
                                    ),
                                    // Qualification
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Qualification',
                                        child: TextFormField(
                                          controller: _qualificationController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter qualification',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Joining Date
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Joining Date',
                                        child: InkWell(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2030),
                                            );
                                            if (date != null) {
                                              setState(() => _joiningDate = date);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: _inputDecoration(
                                              hint: 'Select joining date',
                                            ),
                                            child: Text(
                                              _joiningDate != null
                                                  ? DateFormat('yyyy-MM-dd').format(_joiningDate!)
                                                  : 'Select joining date',
                                              style: TextStyle(
                                                color: _joiningDate != null ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Designation
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Designation',
                                        child: DropdownButtonFormField<String>(
                                          value: _designation,
                                          items: _designationOptions
                                              .map(
                                                (value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(value),
                                                ),
                                              )
                                              .toList(),
                                          decoration: _inputDecoration(
                                            hint: 'Select designation',
                                          ),
                                          onChanged: (value) =>
                                              setState(() => _designation = value),
                                        ),
                                      ),
                                    ),
                                    // Mobile No
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Mobile Number',
                                        child: TextFormField(
                                          controller: _mobileNoController,
                                          keyboardType: TextInputType.phone,
                                          decoration: _inputDecoration(
                                            hint: 'Enter mobile number',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Email
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Email Address',
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: _inputDecoration(
                                            hint: 'Enter email address',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Address
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Address',
                                        child: TextFormField(
                                          controller: _addressController,
                                          maxLines: 3,
                                          decoration: _inputDecoration(
                                            hint: 'Enter complete address',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Blood Group
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Blood Group',
                                        child: TextFormField(
                                          controller: _bloodGroupController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter blood group (e.g., A+, O-)',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Nationality
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Nationality',
                                        child: TextFormField(
                                          controller: _nationalityController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter nationality',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Primary Room ID
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Primary Room ID',
                                        child: TextFormField(
                                          controller: _primaryRoomIdController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter primary room identifier',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Class Teacher Section ID
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Class Teacher Section ID',
                                        child: TextFormField(
                                          controller: _classTeacherSectionIdController,
                                          decoration: _inputDecoration(
                                            hint: 'Enter class teacher section',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Subject Specialization
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Subject Specialization',
                                        child: TextFormField(
                                          controller: _subjectSpecializationController,
                                          maxLines: 3,
                                          decoration: _inputDecoration(
                                            hint: 'Enter subject specialization details',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Emergency Contact
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Emergency Contact',
                                        child: TextFormField(
                                          controller: _emergencyContactController,
                                          keyboardType: TextInputType.phone,
                                          decoration: _inputDecoration(
                                            hint: 'Enter emergency contact number',
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Profile Photo
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Profile Photo',
                                        child: _PhotoUploader(
                                          onTap: _pickPhoto,
                                          photoBytes: _photoBytes,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              alignment: WrapAlignment.center,
                              children: [
                                _GradientButton(
                                  label: '💾 Save Teacher',
                                  colors: const [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                  onTap: _isSubmitting ? null : _submitForm,
                                ),
                                _GradientButton(
                                  label: '👁️ Preview',
                                  colors: const [
                                    Color(0xFF6C757D),
                                    Color(0xFF495057),
                                  ],
                                  onTap: _previewTeacher,
                                ),
                                _GradientButton(
                                  label: '❌ Cancel',
                                  colors: const [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE5A52),
                                  ],
                                  onTap: () => Navigator.pushReplacementNamed(context, '/teachers'),
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '👨‍🏫 Add New Teacher',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fill in the details below to add a new teacher to the system',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E5E9), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E5E9), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  List<String> get _designationOptions => const [
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
      ];

}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PhotoUploader extends StatelessWidget {
  final VoidCallback onTap;
  final Uint8List? photoBytes;

  const _PhotoUploader({
    required this.onTap,
    required this.photoBytes,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF667EEA),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: const Color(0x1A667EEA),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera, size: 48, color: Color(0xFF667EEA)),
            const SizedBox(height: 10),
            const Text(
              'Click to upload photo or drag and drop',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666)),
            ),
            if (photoBytes != null) ...[
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(photoBytes!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final List<Color> colors;

  const _MessageBanner._({
    required this.message,
    required this.colors,
  });

  const _MessageBanner.success({required String message})
      : this._(
          message: message,
          colors: const [Color(0xFF51CF66), Color(0xFF40C057)],
        );

  const _MessageBanner.error({required String message})
      : this._(
          message: message,
          colors: const [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: colors),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Color(0xFF667EEA)),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Saving teacher information...',
          style: TextStyle(color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String? value;

  const _PreviewRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: (value?.isEmpty ?? true) ? 'Not provided' : value,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherPreviewData {
  final String? teacherId;
  final String? employeeNo;
  final String? firstName;
  final String? lastName;
  final String? designation;
  final String? mobileNo;
  final String? email;
  final String? address;
  final String? classTeacherSectionId;
  final String? qualification;
  final String? subjectSpecialization;

  const TeacherPreviewData({
    required this.teacherId,
    required this.employeeNo,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.mobileNo,
    required this.email,
    required this.address,
    required this.classTeacherSectionId,
    required this.qualification,
    required this.subjectSpecialization,
  });
}
