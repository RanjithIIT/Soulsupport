import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
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

  TeacherPreviewData get _previewData => TeacherPreviewData(
        name: _nameController.text,
        designation: _designation,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        classTeacher: _classTeacher,
        experience: _experienceController.text,
        qualifications: _qualificationsController.text,
        specializations: _specializationsController.text,
      );

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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
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
                    _PreviewRow(label: 'Name', value: data.name),
                    _PreviewRow(label: 'Designation', value: data.designation),
                    _PreviewRow(label: 'Phone', value: data.phone),
                    _PreviewRow(label: 'Email', value: data.email),
                    _PreviewRow(label: 'Address', value: data.address),
                    _PreviewRow(label: 'Class Teacher', value: data.classTeacher),
                    _PreviewRow(
                      label: 'Experience',
                      value: data.experience?.isEmpty ?? true
                          ? '0 years'
                          : '${data.experience} years',
                    ),
                    _PreviewRow(
                      label: 'Qualifications',
                      value: data.qualifications,
                    ),
                    _PreviewRow(
                      label: 'Specializations',
                      value: data.specializations,
                    ),
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
                              const _MessageBanner.error(
                                message:
                                    '❌ Error adding teacher. Please try again.',
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
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Full Name *',
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: _inputDecoration(
                                            hint: "Enter teacher's full name",
                                          ),
                                          validator: _requiredValidator,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Designation *',
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
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Please choose a designation'
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Phone Number *',
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: _inputDecoration(
                                            hint: 'Enter phone number',
                                          ),
                                          validator: _requiredValidator,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Email Address *',
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: _inputDecoration(
                                            hint: 'Enter email address',
                                          ),
                                          validator: _requiredValidator,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Address *',
                                        child: TextFormField(
                                          controller: _addressController,
                                          maxLines: 3,
                                          decoration: _inputDecoration(
                                            hint: 'Enter complete address',
                                          ),
                                          validator: _requiredValidator,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Class Teacher',
                                        child: DropdownButtonFormField<String>(
                                          value: _classTeacher,
                                          items: _classTeacherOptions
                                              .map(
                                                (value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(value),
                                                ),
                                              )
                                              .toList(),
                                          decoration: _inputDecoration(
                                            hint: 'Select class (optional)',
                                          ),
                                          onChanged: (value) =>
                                              setState(() => _classTeacher = value),
                                          validator: (_) => null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          isTwoColumns ? (constraints.maxWidth - 30) / 2 : constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Years of Experience',
                                        child: TextFormField(
                                          controller: _experienceController,
                                          keyboardType: TextInputType.number,
                                          decoration: _inputDecoration(
                                            hint: 'Enter years of experience',
                                          ),
                                        ),
                                      ),
                                    ),
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
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Qualifications',
                                        child: TextFormField(
                                          controller: _qualificationsController,
                                          maxLines: 3,
                                          decoration: _inputDecoration(
                                            hint:
                                                'Enter educational qualifications and certifications',
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth,
                                      child: _LabeledField(
                                        label: 'Specializations',
                                        child: TextFormField(
                                          controller: _specializationsController,
                                          maxLines: 3,
                                          decoration: _inputDecoration(
                                            hint:
                                                'Enter areas of specialization or expertise',
                                          ),
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

  List<String> get _classTeacherOptions => const [
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
  final String? name;
  final String? designation;
  final String? phone;
  final String? email;
  final String? address;
  final String? classTeacher;
  final String? experience;
  final String? qualifications;
  final String? specializations;

  const TeacherPreviewData({
    required this.name,
    required this.designation,
    required this.phone,
    required this.email,
    required this.address,
    required this.classTeacher,
    required this.experience,
    required this.qualifications,
    required this.specializations,
  });
}
