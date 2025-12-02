import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditActivityPage extends StatefulWidget {
  final int? activityId;

  const EditActivityPage({super.key, this.activityId});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();
  final _participantsController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _category;
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  // Mock activity data - in real app, fetch from API based on activityId
  final Map<String, dynamic> _mockActivity = {
    'id': 1,
    'name': 'Basketball Team',
    'category': 'Sports',
    'instructor': 'Mr. Michael Johnson',
    'participants': 25,
    'schedule': 'Monday, Wednesday, Friday 4:00 PM',
    'location': 'School Gymnasium',
    'status': 'Active',
    'startDate': '2024-01-15',
    'endDate': '2024-06-30',
    'description':
        'Competitive basketball team for students interested in sports. Regular practice sessions and participation in inter-school tournaments.',
    'requirements':
        'Basic basketball skills, commitment to regular practice, good physical fitness',
    'notes': 'Team has won 3 district championships in the last 2 years',
  };

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  void _loadActivityData() {
    // In real app, fetch activity data based on widget.activityId
    if (widget.activityId != null) {
      _nameController.text = _mockActivity['name'] ?? '';
      _category = _mockActivity['category'];
      _instructorController.text = _mockActivity['instructor'] ?? '';
      _participantsController.text =
          _mockActivity['participants']?.toString() ?? '';
      _scheduleController.text = _mockActivity['schedule'] ?? '';
      _locationController.text = _mockActivity['location'] ?? '';
      _status = _mockActivity['status'];
      if (_mockActivity['startDate'] != null) {
        _startDate = DateTime.parse(_mockActivity['startDate']);
      }
      if (_mockActivity['endDate'] != null) {
        _endDate = DateTime.parse(_mockActivity['endDate']);
      }
      _descriptionController.text = _mockActivity['description'] ?? '';
      _requirementsController.text = _mockActivity['requirements'] ?? '';
      _notesController.text = _mockActivity['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _participantsController.dispose();
    _scheduleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _notesController.dispose();
    super.dispose();
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = false;
        _showError = true;
        _errorMessage = 'Error updating activity information. Please try again.';
      });
    }
  }

  void _previewActivity() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎯 Activity Preview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewItem('Name', _nameController.text),
              _PreviewItem('Category', _category ?? 'Not provided'),
              _PreviewItem('Instructor', _instructorController.text),
              _PreviewItem('Participants',
                  _participantsController.text.isEmpty
                      ? 'Not specified'
                      : _participantsController.text),
              _PreviewItem('Schedule', _scheduleController.text),
              _PreviewItem('Location', _locationController.text),
              _PreviewItem('Status', _status ?? 'Not provided'),
              _PreviewItem('Start Date',
                  _startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : 'Not specified'),
              _PreviewItem('End Date',
                  _endDate != null
                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                      : 'Not specified'),
              _PreviewItem('Description', _descriptionController.text),
              _PreviewItem('Requirements',
                  _requirementsController.text.isEmpty
                      ? 'None specified'
                      : _requirementsController.text),
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
              color: Colors.white.withValues(alpha: 0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
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
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/students'),
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
                          isActive: true,
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
                              'Edit Activity',
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Management User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'School Manager',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/activities'),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back to Activities'),
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
                        constraints: const BoxConstraints(maxWidth: 800),
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
                                      '🎯 Edit Activity Information',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Update activity details and save changes',
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
                                          '✅ Activity information updated successfully!',
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
                                      Text('Updating activity information...'),
                                    ],
                                  ),
                                ),
                              // Form Fields
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Activity Name *',
                                        hintText: 'Enter activity name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter activity name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Category *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      value: _category,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Sports', child: Text('Sports')),
                                        DropdownMenuItem(
                                            value: 'Academic',
                                            child: Text('Academic')),
                                        DropdownMenuItem(
                                            value: 'Arts', child: Text('Arts')),
                                        DropdownMenuItem(
                                            value: 'Games', child: Text('Games')),
                                        DropdownMenuItem(
                                            value: 'Cultural',
                                            child: Text('Cultural')),
                                        DropdownMenuItem(
                                            value: 'Technical',
                                            child: Text('Technical')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _category = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select category';
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
                                      controller: _instructorController,
                                      decoration: InputDecoration(
                                        labelText: 'Instructor *',
                                        hintText: 'Enter instructor name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter instructor name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _participantsController,
                                      decoration: InputDecoration(
                                        labelText: 'Max Participants',
                                        hintText: 'Enter max participants',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _scheduleController,
                                      decoration: InputDecoration(
                                        labelText: 'Schedule *',
                                        hintText: 'e.g., Monday, Wednesday 3:00 PM',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter schedule';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        labelText: 'Location *',
                                        hintText: 'Enter activity location',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter location';
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
                                        labelText: 'Status *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      value: _status,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Active', child: Text('Active')),
                                        DropdownMenuItem(
                                            value: 'Inactive',
                                            child: Text('Inactive')),
                                        DropdownMenuItem(
                                            value: 'Suspended',
                                            child: Text('Suspended')),
                                        DropdownMenuItem(
                                            value: 'Completed',
                                            child: Text('Completed')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _status = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select status';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _startDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _startDate = date;
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
                                              _startDate == null
                                                  ? 'Start Date'
                                                  : DateFormat('yyyy-MM-dd')
                                                      .format(_startDate!),
                                              style: TextStyle(
                                                color: _startDate == null
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
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _endDate ?? DateTime.now(),
                                          firstDate: _startDate ?? DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _endDate = date;
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
                                              _endDate == null
                                                  ? 'End Date'
                                                  : DateFormat('yyyy-MM-dd')
                                                      .format(_endDate!),
                                              style: TextStyle(
                                                color: _endDate == null
                                                    ? Colors.grey[600]
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description *',
                                  hintText: 'Enter detailed activity description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _requirementsController,
                                decoration: InputDecoration(
                                  labelText: 'Requirements',
                                  hintText:
                                      'Enter any requirements or prerequisites',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
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
                                    label: const Text('Update Activity'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667EEA),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: _previewActivity,
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
                                        Navigator.pushReplacementNamed(
                                            context, '/activities'),
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
              ? const Color(0xFF667EEA).withValues(alpha: 0.3)
              : _isHovered
                  ? const Color(0xFF667EEA).withValues(alpha: 0.25)
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
          leading: Text(widget.icon, style: const TextStyle(fontSize: 20)),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.black87,
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
            width: 120,
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

