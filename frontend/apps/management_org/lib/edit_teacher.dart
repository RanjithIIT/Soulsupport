import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditTeacherPage extends StatefulWidget {
  final int? teacherId;

  const EditTeacherPage({super.key, this.teacherId});

  @override
  State<EditTeacherPage> createState() => _EditTeacherPageState();
}

class _EditTeacherPageState extends State<EditTeacherPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _specializationsController = TextEditingController();

  String? _designation;
  String? _classTeacher;
  Uint8List? _photoBytes;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  final Map<String, dynamic> _mockTeacher = {
    'id': 1,
    'name': 'Dr. Sarah Johnson',
    'designation': 'Mathematics',
    'phone': '+1-555-0101',
    'email': 'sarah.johnson@school.com',
    'address': '123 Teacher Street, Education City',
    'classTeacher': 'Grade 10A',
    'experience': 12,
    'qualifications': 'Ph.D. in Mathematics, M.Ed. in Education',
    'specializations': 'Advanced Algebra, Calculus, Statistics',
  };

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  void _loadTeacherData() {
    if (widget.teacherId != null) {
      _nameController.text = _mockTeacher['name'] ?? '';
      _designation = _mockTeacher['designation'];
      _phoneController.text = _mockTeacher['phone'] ?? '';
      _emailController.text = _mockTeacher['email'] ?? '';
      _addressController.text = _mockTeacher['address'] ?? '';
      _classTeacher = _mockTeacher['classTeacher'];
      _experienceController.text = _mockTeacher['experience']?.toString() ?? '';
      _qualificationsController.text = _mockTeacher['qualifications'] ?? '';
      _specializationsController.text = _mockTeacher['specializations'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _specializationsController.dispose();
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
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
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
        _errorMessage = 'Error updating teacher information. Please try again.';
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
              _PreviewItem('Name', _nameController.text),
              _PreviewItem('Designation', _designation ?? 'Not provided'),
              _PreviewItem('Phone', _phoneController.text),
              _PreviewItem('Email', _emailController.text),
              _PreviewItem('Address', _addressController.text),
              _PreviewItem('Class Teacher', _classTeacher ?? 'Not assigned'),
              _PreviewItem(
                  'Experience',
                  _experienceController.text.isEmpty
                      ? '0 years'
                      : '${_experienceController.text} years'),
              _PreviewItem(
                  'Qualifications',
                  _qualificationsController.text.isEmpty
                      ? 'Not provided'
                      : _qualificationsController.text),
              _PreviewItem(
                  'Specializations',
                  _specializationsController.text.isEmpty
                      ? 'Not provided'
                      : _specializationsController.text),
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
                        nameController: _nameController,
                        designation: _designation,
                        onDesignationChanged: (value) {
                          setState(() {
                            _designation = value;
                          });
                        },
                        phoneController: _phoneController,
                        emailController: _emailController,
                        addressController: _addressController,
                        classTeacher: _classTeacher,
                        onClassTeacherChanged: (value) {
                          setState(() {
                            _classTeacher = value;
                          });
                        },
                        experienceController: _experienceController,
                        qualificationsController: _qualificationsController,
                        specializationsController: _specializationsController,
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
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/teachers'),
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
  final TextEditingController nameController;
  final String? designation;
  final ValueChanged<String?> onDesignationChanged;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final String? classTeacher;
  final ValueChanged<String?> onClassTeacherChanged;
  final TextEditingController experienceController;
  final TextEditingController qualificationsController;
  final TextEditingController specializationsController;
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
    required this.nameController,
    required this.designation,
    required this.onDesignationChanged,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.classTeacher,
    required this.onClassTeacherChanged,
    required this.experienceController,
    required this.qualificationsController,
    required this.specializationsController,
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter teacher\'s full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Designation *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select designation';
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
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
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
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
            TextFormField(
              controller: addressController,
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
                      labelText: 'Class Teacher (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.class_),
                    ),
                    value: classTeacher,
                    items: const [
                      'Grade 9A',
                      'Grade 9B',
                      'Grade 9C',
                      'Grade 10A',
                      'Grade 10B',
                      'Grade 10C',
                      'Grade 11A',
                      'Grade 11B',
                      'Grade 11C',
                      'Grade 12A',
                      'Grade 12B',
                      'Grade 12C',
                    ]
                        .map((value) =>
                            DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: onClassTeacherChanged,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: experienceController,
                    decoration: InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.work_history),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: qualificationsController,
              decoration: InputDecoration(
                labelText: 'Qualifications',
                hintText: 'Enter educational qualifications and certifications',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.school),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: specializationsController,
              decoration: InputDecoration(
                labelText: 'Specializations',
                hintText: 'Enter areas of specialization or expertise',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.star),
              ),
              maxLines: 3,
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
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/teachers'),
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

