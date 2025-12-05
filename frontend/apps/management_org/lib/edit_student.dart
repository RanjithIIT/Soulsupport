import 'services/api_service.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditStudentPage extends StatefulWidget {
  final int? studentId;

  const EditStudentPage({super.key, this.studentId});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _studentClass;
  String? _section;
  String? _bloodGroup;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _busRoute;
  Uint8List? _photoBytes;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    if (widget.studentId == null) return;

    try {
      final data = await ApiService.fetchStudentById(widget.studentId!);

      final user = data['user'] as Map<String, dynamic>? ?? {};
      final firstName = user['first_name'] as String? ?? '';
      final lastName = user['last_name'] as String? ?? '';
      final fullName = '$firstName $lastName'.trim();

      _nameController.text = fullName.isNotEmpty ? fullName : (data['name'] as String? ?? '');
      _studentClass = data['class_name'] as String?;
      _section = data['section'] as String?;
      _bloodGroup = data['blood_group'] as String?;

      final dob = data['date_of_birth'] as String?;
      if (dob != null && dob.isNotEmpty) {
        _dateOfBirth = DateTime.tryParse(dob);
      }

      _gender = data['gender'] as String?;
      _admissionNumberController.text = data['student_id'] as String? ?? '';
      _rollNumberController.text = data['student_id'] as String? ?? '';
      _parentNameController.text = data['parent_name'] as String? ?? '';
      _parentPhoneController.text = data['parent_phone'] as String? ?? '';
      _parentEmailController.text = user['email'] as String? ?? '';
      _emergencyContactController.text =
          data['emergency_contact'] as String? ?? '';
      _addressController.text = data['address'] as String? ?? '';
      _busRoute = data['bus_route'] as String?;
      _medicalConditionsController.text =
          data['medical_info'] as String? ?? '';
      _notesController.text = data['notes'] as String? ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load student: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    _rollNumberController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    _medicalConditionsController.dispose();
    _notesController.dispose();
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

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }
    if (_gender == null || _gender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }
    if (_studentClass == null || _studentClass!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class')),
      );
      return;
    }
    if (_section == null || _section!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select section')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showSuccess = false;
      _showError = false;
      _errorMessage = '';
    });

    try {
      final payload = {
        'student_id': _admissionNumberController.text.trim().isNotEmpty
            ? _admissionNumberController.text.trim()
            : _rollNumberController.text.trim(),
        'class_name': _studentClass,
        'section': _section,
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        'gender': _gender,
        'blood_group': _bloodGroup,
        'address': _addressController.text.trim(),
        'emergency_contact': _emergencyContactController.text.trim(),
        'medical_info': _medicalConditionsController.text.trim(),
        'parent_name': _parentNameController.text.trim(),
        'parent_phone': _parentPhoneController.text.trim(),
        'bus_route': _busRoute,
      };

      if (widget.studentId != null) {
        await ApiService.updateStudent(widget.studentId!, payload);
      }

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
        _errorMessage = 'Error updating student: $e';
      });
    }
  }

  void _previewStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('👥 Student Preview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewItem('Name', _nameController.text),
              _PreviewItem('Class',
                  '${_studentClass ?? 'Not provided'} • Section ${_section ?? 'Not provided'}'),
              _PreviewItem('Admission Number', _admissionNumberController.text),
              _PreviewItem('Roll Number', _rollNumberController.text),
              _PreviewItem('Date of Birth',
                  _dateOfBirth != null
                      ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
                      : 'Not provided'),
              _PreviewItem('Gender', _gender ?? 'Not provided'),
              _PreviewItem('Blood Group', _bloodGroup ?? 'Not provided'),
              _PreviewItem('Parent Name', _parentNameController.text),
              _PreviewItem('Parent Phone', _parentPhoneController.text),
              _PreviewItem('Parent Email', _parentEmailController.text),
              _PreviewItem('Emergency Contact',
                  _emergencyContactController.text.isEmpty
                      ? 'Not provided'
                      : _emergencyContactController.text),
              _PreviewItem('Address', _addressController.text),
              _PreviewItem('Bus Route',
                  _busRoute == null || _busRoute!.isEmpty
                      ? 'Not assigned'
                      : _busRoute!),
              _PreviewItem('Medical Conditions',
                  _medicalConditionsController.text.isEmpty
                      ? 'None'
                      : _medicalConditionsController.text),
              _PreviewItem('Notes',
                  _notesController.text.isEmpty
                      ? 'No additional notes'
                      : _notesController.text),
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
          // Sidebar
          Container(
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
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/dashboard'),
                        ),
                        _NavItem(
                          icon: '👨‍🏫',
                          title: 'Teachers',
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/teachers'),
                        ),
                        _NavItem(
                          icon: '👥',
                          title: 'Students',
                          isActive: true,
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
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/activities'),
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
          ),
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
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
                              'Edit Student',
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
                                      Navigator.pushReplacementNamed(context, '/students');
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back to Students'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Form Container
                      Container(
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
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form Header
                              const Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '👥 Edit Student Information',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Update student details and save changes',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Success/Error Messages
                              if (_showSuccess)
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF51CF66),
                                        Color(0xFF40C057)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '✅ Student information updated successfully!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_showError)
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error, color: Colors.white),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '❌ $_errorMessage',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_isSubmitting)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: const Column(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF667EEA)),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text('Updating student information...'),
                                    ],
                                  ),
                                ),
                              // Photo Upload
                              Center(
                                child: GestureDetector(
                                  onTap: _pickPhoto,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: gradient,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: _photoBytes != null
                                        ? ClipOval(
                                            child: Image.memory(
                                              _photoBytes!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '📷',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white.withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Form Fields
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name *',
                                  hintText: 'Enter student\'s full name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter student name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Class *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.school),
                                      ),
                                      value: _studentClass,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Grade 9',
                                            child: Text('Grade 9')),
                                        DropdownMenuItem(
                                            value: 'Grade 10',
                                            child: Text('Grade 10')),
                                        DropdownMenuItem(
                                            value: 'Grade 11',
                                            child: Text('Grade 11')),
                                        DropdownMenuItem(
                                            value: 'Grade 12',
                                            child: Text('Grade 12')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _studentClass = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select class';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Section *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.class_),
                                      ),
                                      value: _section,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'A', child: Text('Section A')),
                                        DropdownMenuItem(
                                            value: 'B', child: Text('Section B')),
                                        DropdownMenuItem(
                                            value: 'C', child: Text('Section C')),
                                        DropdownMenuItem(
                                            value: 'D', child: Text('Section D')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _section = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select section';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Blood Group',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.bloodtype),
                                      ),
                                      value: _bloodGroup,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'A+', child: Text('A+')),
                                        DropdownMenuItem(
                                            value: 'A-', child: Text('A-')),
                                        DropdownMenuItem(
                                            value: 'B+', child: Text('B+')),
                                        DropdownMenuItem(
                                            value: 'B-', child: Text('B-')),
                                        DropdownMenuItem(
                                            value: 'AB+', child: Text('AB+')),
                                        DropdownMenuItem(
                                            value: 'AB-', child: Text('AB-')),
                                        DropdownMenuItem(
                                            value: 'O+', child: Text('O+')),
                                        DropdownMenuItem(
                                            value: 'O-', child: Text('O-')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _bloodGroup = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _dateOfBirth ??
                                              DateTime.now().subtract(
                                                  const Duration(days: 365 * 10)),
                                          firstDate: DateTime(1990),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _dateOfBirth = date;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 10),
                                            Text(
                                              _dateOfBirth == null
                                                  ? 'Date of Birth *'
                                                  : DateFormat('yyyy-MM-dd')
                                                      .format(_dateOfBirth!),
                                              style: TextStyle(
                                                color: _dateOfBirth == null
                                                    ? Colors.grey[600]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Gender *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.people),
                                      ),
                                      value: _gender,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Male', child: Text('Male')),
                                        DropdownMenuItem(
                                            value: 'Female', child: Text('Female')),
                                        DropdownMenuItem(
                                            value: 'Other', child: Text('Other')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _gender = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select gender';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (_dateOfBirth == null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, top: 4, bottom: 8),
                                  child: Text(
                                    'Please select date of birth',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _admissionNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Admission Number *',
                                        hintText: 'Enter admission number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.badge),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter admission number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _rollNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Roll Number',
                                        hintText: 'Enter roll number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.numbers),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Parent/Guardian Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _parentNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Parent/Guardian Name *',
                                        hintText: 'Enter parent/guardian name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.family_restroom),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter parent name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _parentPhoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Parent Phone *',
                                        hintText: 'Enter parent phone number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.phone),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter parent phone';
                                        }
                                        if (value.length < 10) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _parentEmailController,
                                      decoration: InputDecoration(
                                        labelText: 'Parent Email',
                                        hintText: 'Enter parent email',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.email),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value != null &&
                                            value.isNotEmpty &&
                                            !value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emergencyContactController,
                                      decoration: InputDecoration(
                                        labelText: 'Emergency Contact',
                                        hintText: 'Enter emergency contact',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.emergency),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address *',
                                  hintText: 'Enter complete address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.location_on),
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Bus Route',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.directions_bus),
                                      ),
                                      value: _busRoute,
                                      items: const [
                                        DropdownMenuItem(
                                            value: null, child: Text('Not assigned')),
                                        DropdownMenuItem(
                                            value: 'Route 1', child: Text('Route 1')),
                                        DropdownMenuItem(
                                            value: 'Route 2', child: Text('Route 2')),
                                        DropdownMenuItem(
                                            value: 'Route 3', child: Text('Route 3')),
                                        DropdownMenuItem(
                                            value: 'Route 4', child: Text('Route 4')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _busRoute = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _medicalConditionsController,
                                decoration: InputDecoration(
                                  labelText: 'Medical Conditions',
                                  hintText:
                                      'Enter any medical conditions or allergies',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.medical_services),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  labelText: 'Additional Notes',
                                  hintText: 'Enter any additional notes or comments',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.note),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 30),
                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isSubmitting ? null : _submitForm,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Update Student'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667EEA),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: _previewStudent,
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
                                    onPressed: () => Navigator.pushReplacementNamed(context, '/students'),
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
                      ),
                      const SizedBox(height: 20),
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
                  ? Colors.white.withValues(alpha: 0.2)
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
          leading:
              Text(widget.icon, style: const TextStyle(fontSize: 20, color: Colors.white)),
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

