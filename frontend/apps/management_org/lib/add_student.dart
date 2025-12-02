import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalInfoController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _grade;
  String? _section;
  String? _bloodGroup;
  Uint8List? _photoBytes;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _emergencyContactController.dispose();
    _medicalInfoController.dispose();
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
      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/students');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
        _errorMessage = 'Failed to add student. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(gradient: gradient),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🏫 School Management System',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 18),
                          SizedBox(width: 4),
                          Text('Back to Dashboard'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title
                      ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: const Text(
                          'Add New Student',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter student information to add to the system',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Success/Error Messages
                      if (_showSuccess)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF51CF66), Color(0xFF40C057)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Student added successfully!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Form Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo Upload
                              Center(
                                child: GestureDetector(
                                  onTap: _pickPhoto,
                                  child: Container(
                                    width: 120,
                                    height: 120,
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
                                        : const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Name Fields
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      decoration: InputDecoration(
                                        labelText: 'First Name *',
                                        hintText: 'Enter first name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
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
                                      controller: _lastNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name *',
                                        hintText: 'Enter last name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.person_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter last name';
                                        }
                                        return null;
                                      },
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
                                          initialDate: DateTime.now()
                                              .subtract(const Duration(days: 365 * 10)),
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
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(12),
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
                                                  : DateFormat('MMM dd, yyyy')
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
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.people),
                                      ),
                                      value: _gender,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'male', child: Text('Male')),
                                        DropdownMenuItem(
                                            value: 'female', child: Text('Female')),
                                        DropdownMenuItem(
                                            value: 'other', child: Text('Other')),
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
                              // Grade and Section
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Grade *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.school),
                                      ),
                                      value: _grade,
                                      items: List.generate(12, (i) {
                                        return DropdownMenuItem(
                                          value: (i + 1).toString(),
                                          child: Text('Grade ${i + 1}'),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          _grade = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select grade';
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
                                          borderRadius: BorderRadius.circular(12),
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
                              // Phone and Email
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number *',
                                        hintText: 'Enter phone number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.phone),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter phone number';
                                        }
                                        if (value.length < 10) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email *',
                                        hintText: 'Enter email address',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.email),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter email';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Address
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address *',
                                  hintText: 'Enter student address',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                              // Blood Group
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Blood Group (Optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                              const SizedBox(height: 20),
                              // Parent Information
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
                                        hintText: 'Enter parent name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
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
                                        hintText: 'Enter parent phone',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.phone_android),
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
                              // Emergency Contact
                              TextFormField(
                                controller: _emergencyContactController,
                                decoration: InputDecoration(
                                  labelText: 'Emergency Contact (Optional)',
                                  hintText: 'Enter emergency contact',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.emergency),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Medical Information
                              TextFormField(
                                controller: _medicalInfoController,
                                decoration: InputDecoration(
                                  labelText: 'Medical Information (Optional)',
                                  hintText: 'Enter any medical information',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.medical_services),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 30),
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667EEA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSubmitting
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                        Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Adding student...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Add Student',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

