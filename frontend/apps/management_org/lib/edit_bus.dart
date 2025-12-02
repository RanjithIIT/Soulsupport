import 'package:flutter/material.dart';

class EditBusPage extends StatefulWidget {
  final int? busId;

  const EditBusPage({super.key, this.busId});

  @override
  State<EditBusPage> createState() => _EditBusPageState();
}

class _EditBusPageState extends State<EditBusPage> {
  final _formKey = GlobalKey<FormState>();

  final _busNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _driverExperienceController = TextEditingController();
  final _routeNameController = TextEditingController();
  final _routeDistanceController = TextEditingController();
  final _routeDescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _busType;
  TimeOfDay? _morningStartTime;
  TimeOfDay? _morningEndTime;
  TimeOfDay? _afternoonStartTime;
  TimeOfDay? _afternoonEndTime;

  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  // Mock bus data - in real app, fetch from API based on busId
  final Map<String, dynamic> _mockBus = {
    'id': 1,
    'busNumber': 'BUS001',
    'busType': 'Standard Bus',
    'capacity': 45,
    'registrationNumber': 'REG2024001',
    'driverName': 'Mr. David Wilson',
    'driverPhone': '+1-555-0301',
    'driverLicense': 'DL123456789',
    'driverExperience': 8,
    'routeName': 'Route 1 - Downtown',
    'routeDistance': 12.5,
    'morningStartTime': '07:00',
    'morningEndTime': '08:30',
    'afternoonStartTime': '15:00',
    'afternoonEndTime': '16:30',
    'routeDescription':
        'Main route covering downtown area with multiple stops',
    'notes': 'Well-maintained bus, experienced driver',
  };

  @override
  void initState() {
    super.initState();
    _loadBusData();
  }

  void _loadBusData() {
    // In real app, fetch bus data based on widget.busId
    if (widget.busId != null) {
      _busNumberController.text = _mockBus['busNumber'] ?? '';
      _busType = _mockBus['busType'];
      _capacityController.text = _mockBus['capacity']?.toString() ?? '';
      _registrationNumberController.text =
          _mockBus['registrationNumber'] ?? '';
      _driverNameController.text = _mockBus['driverName'] ?? '';
      _driverPhoneController.text = _mockBus['driverPhone'] ?? '';
      _driverLicenseController.text = _mockBus['driverLicense'] ?? '';
      _driverExperienceController.text =
          _mockBus['driverExperience']?.toString() ?? '';
      _routeNameController.text = _mockBus['routeName'] ?? '';
      _routeDistanceController.text =
          _mockBus['routeDistance']?.toString() ?? '';
      _routeDescriptionController.text =
          _mockBus['routeDescription'] ?? '';
      _notesController.text = _mockBus['notes'] ?? '';

      // Parse times
      if (_mockBus['morningStartTime'] != null) {
        final timeParts = _mockBus['morningStartTime'].split(':');
        _morningStartTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]));
      }
      if (_mockBus['morningEndTime'] != null) {
        final timeParts = _mockBus['morningEndTime'].split(':');
        _morningEndTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]));
      }
      if (_mockBus['afternoonStartTime'] != null) {
        final timeParts = _mockBus['afternoonStartTime'].split(':');
        _afternoonStartTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]));
      }
      if (_mockBus['afternoonEndTime'] != null) {
        final timeParts = _mockBus['afternoonEndTime'].split(':');
        _afternoonEndTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]));
      }
    }
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _capacityController.dispose();
    _registrationNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _driverLicenseController.dispose();
    _driverExperienceController.dispose();
    _routeNameController.dispose();
    _routeDistanceController.dispose();
    _routeDescriptionController.dispose();
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
        _errorMessage = 'Error updating bus information. Please try again.';
      });
    }
  }

  void _previewBus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🚌 Bus Preview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewItem('Bus Number', _busNumberController.text),
              _PreviewItem('Bus Type', _busType ?? 'Not provided'),
              _PreviewItem('Capacity',
                  _capacityController.text.isEmpty
                      ? 'Not provided'
                      : '${_capacityController.text} passengers'),
              _PreviewItem('Registration',
                  _registrationNumberController.text),
              _PreviewItem('Driver Name', _driverNameController.text),
              _PreviewItem('Driver Phone', _driverPhoneController.text),
              _PreviewItem('License Number', _driverLicenseController.text),
              _PreviewItem('Experience',
                  _driverExperienceController.text.isEmpty
                      ? '0 years'
                      : '${_driverExperienceController.text} years'),
              _PreviewItem('Route Name', _routeNameController.text),
              _PreviewItem('Distance',
                  _routeDistanceController.text.isEmpty
                      ? 'Not provided'
                      : '${_routeDistanceController.text} km'),
              _PreviewItem(
                  'Morning Schedule',
                  _morningStartTime != null && _morningEndTime != null
                      ? '${_morningStartTime!.format(context)} - ${_morningEndTime!.format(context)}'
                      : 'Not provided'),
              _PreviewItem(
                  'Afternoon Schedule',
                  _afternoonStartTime != null && _afternoonEndTime != null
                      ? '${_afternoonStartTime!.format(context)} - ${_afternoonEndTime!.format(context)}'
                      : 'Not provided'),
              _PreviewItem('Route Description',
                  _routeDescriptionController.text.isEmpty
                      ? 'Not provided'
                      : _routeDescriptionController.text),
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
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/students'),
                        ),
                        _NavItem(
                          icon: '🚌',
                          title: 'Buses',
                          isActive: true,
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
                              'Edit Bus',
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
                                  onPressed: () => Navigator.pushReplacementNamed(context, '/buses'),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back to Buses'),
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
                                      '🚌 Edit Bus Information',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Update bus details, driver information, and route',
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
                                          '✅ Bus information updated successfully!',
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
                                      Text('Updating bus information...'),
                                    ],
                                  ),
                                ),
                              // Form Fields
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _busNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Bus Number *',
                                        hintText: 'Enter bus number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.directions_bus),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter bus number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Bus Type *',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.category),
                                      ),
                                      value: _busType,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Mini Bus',
                                            child: Text('Mini Bus')),
                                        DropdownMenuItem(
                                            value: 'Standard Bus',
                                            child: Text('Standard Bus')),
                                        DropdownMenuItem(
                                            value: 'Large Bus',
                                            child: Text('Large Bus')),
                                        DropdownMenuItem(
                                            value: 'AC Bus', child: Text('AC Bus')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _busType = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select bus type';
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
                                      controller: _capacityController,
                                      decoration: InputDecoration(
                                        labelText: 'Passenger Capacity *',
                                        hintText: 'Enter passenger capacity',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.people),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter capacity';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Please enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _registrationNumberController,
                                      decoration: InputDecoration(
                                        labelText: 'Registration Number *',
                                        hintText: 'Enter registration number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.badge),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter registration number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Driver Information',
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
                                      controller: _driverNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Driver Name *',
                                        hintText: 'Enter driver\'s full name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.person),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter driver name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _driverPhoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Driver Phone *',
                                        hintText: 'Enter driver\'s phone number',
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
                                          return 'Please enter driver phone';
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
                                      controller: _driverLicenseController,
                                      decoration: InputDecoration(
                                        labelText: 'Driver License Number *',
                                        hintText: 'Enter license number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.credit_card),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter license number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _driverExperienceController,
                                      decoration: InputDecoration(
                                        labelText: 'Years of Experience',
                                        hintText: 'Enter years of experience',
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
                              const Text(
                                'Route Information',
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
                                      controller: _routeNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Route Name *',
                                        hintText: 'Enter route name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.route),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter route name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _routeDistanceController,
                                      decoration: InputDecoration(
                                        labelText: 'Route Distance (km)',
                                        hintText: 'Enter route distance',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.straighten),
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Schedule',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _morningStartTime ?? TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _morningStartTime = time;
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
                                            Icon(Icons.access_time,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 10),
                                            Text(
                                              _morningStartTime == null
                                                  ? 'Morning Start Time *'
                                                  : _morningStartTime!.format(context),
                                              style: TextStyle(
                                                color: _morningStartTime == null
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
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _morningEndTime ??
                                              const TimeOfDay(hour: 8, minute: 30),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _morningEndTime = time;
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
                                            Icon(Icons.access_time,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 10),
                                            Text(
                                              _morningEndTime == null
                                                  ? 'Morning End Time *'
                                                  : _morningEndTime!.format(context),
                                              style: TextStyle(
                                                color: _morningEndTime == null
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
                              if (_morningStartTime == null || _morningEndTime == null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, top: 4, bottom: 8),
                                  child: Text(
                                    'Please select morning schedule times',
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
                                    child: InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _afternoonStartTime ?? TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _afternoonStartTime = time;
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
                                            Icon(Icons.access_time,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 10),
                                            Text(
                                              _afternoonStartTime == null
                                                  ? 'Afternoon Start Time *'
                                                  : _afternoonStartTime!.format(context),
                                              style: TextStyle(
                                                color: _afternoonStartTime == null
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
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _afternoonEndTime ??
                                              const TimeOfDay(hour: 16, minute: 30),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _afternoonEndTime = time;
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
                                            Icon(Icons.access_time,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 10),
                                            Text(
                                              _afternoonEndTime == null
                                                  ? 'Afternoon End Time *'
                                                  : _afternoonEndTime!.format(context),
                                              style: TextStyle(
                                                color: _afternoonEndTime == null
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
                              if (_afternoonStartTime == null ||
                                  _afternoonEndTime == null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, top: 4, bottom: 8),
                                  child: Text(
                                    'Please select afternoon schedule times',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _routeDescriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Route Description',
                                  hintText: 'Enter detailed route description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.description),
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
                                    label: const Text('Update Bus'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF667EEA),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: _previewBus,
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
                                    onPressed: () => Navigator.pushReplacementNamed(context, '/buses'),
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

