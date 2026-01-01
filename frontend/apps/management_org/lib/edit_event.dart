import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';
import 'dashboard.dart';

class EditEventPage extends StatefulWidget {
  final int? eventId;
  const EditEventPage({super.key, this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  final _participantsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();

  String? _selectedCategory;
  String _selectedStatus = 'Upcoming';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Academic',
    'Sports',
    'Cultural',
    'Administrative',
    'Career',
    'Other',
  ];

  final List<String> _statuses = [
    'Upcoming',
    'Completed',
    'Cancelled',
    'Postponed',
  ];

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = '';

  EventPreviewData get _previewData => EventPreviewData(
        name: _nameController.text,
        category: _selectedCategory,
        date: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
        time: _timeController.text,
        location: _locationController.text,
        organizer: _organizerController.text,
        participants: _participantsController.text,
        status: _selectedStatus,
        description: _descriptionController.text,
      );

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEventDetails();
    }
  }

  Future<void> _loadEventDetails() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      await apiService.initialize();
      // Assuming GET /management-admin/events/{id}/
      final endpoint = '${Endpoints.events}${widget.eventId}/';
      final response = await apiService.get(endpoint);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (!mounted) return;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _selectedCategory = _categories.contains(data['category']) ? data['category'] : null;
          if (data['date'] != null) {
            try {
              _selectedDate = DateTime.parse(data['date']);
            } catch (_) {}
          }
          _timeController.text = data['time'] ?? '';
          _locationController.text = data['location'] ?? '';
          _organizerController.text = data['organizer'] ?? '';
          _participantsController.text = (data['participants'] ?? '').toString();
          _selectedStatus = _statuses.contains(data['status']) ? data['status'] : 'Upcoming';
          _descriptionController.text = data['description'] ?? '';
        });
      }
    } catch (e) {
      // Handle error or just show empty form
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _participantsController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showSuccess = false;
      _showError = false;
    });

    try {
      final eventData = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': _timeController.text.trim(),
        'location': _locationController.text.trim(),
        'organizer': _organizerController.text.trim(),
        'participants': int.tryParse(_participantsController.text) ?? 0,
        'status': _selectedStatus,
        'description': _descriptionController.text.trim(),
      };

      final apiService = ApiService();
      await apiService.initialize();
      
      final endpoint = '${Endpoints.events}${widget.eventId}/';
      // Use PUT for update
      final response = await apiService.put(endpoint, body: eventData);

      if (!response.success) {
        throw Exception(response.error ?? 'Failed to update event');
      }

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
        _showError = false;
        _errorMessage = '';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/events');
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

  Future<void> _previewEvent() async {
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
                      '📅 Event Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PreviewRow(label: 'Name', value: data.name),
                    _PreviewRow(label: 'Category', value: data.category),
                    _PreviewRow(label: 'Date', value: data.date),
                    _PreviewRow(label: 'Time', value: data.time),
                    _PreviewRow(label: 'Location', value: data.location),
                    _PreviewRow(label: 'Organizer', value: data.organizer),
                    _PreviewRow(label: 'Participants', value: data.participants),
                    _PreviewRow(label: 'Status', value: data.status),
                    _PreviewRow(label: 'Description', value: data.description),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 768; // Matching add_teacher breakpoint
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
            width: 280,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'packages/management_org/assets/Vidyarambh.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school,
                              size: 56,
                              color: Color(0xFF667EEA),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _NavItem(
                          icon: '📊',
                          title: 'Overview',
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
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/activities'),
                        ),
                        _NavItem(
                          icon: '📅',
                          title: 'Events',
                          isActive: true, // Active for Events
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/events'),
                        ),
                        _NavItem(
                          icon: '📆',
                          title: 'Calendar',
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/calendar'),
                        ),
                        _NavItem(
                          icon: '🔔',
                          title: 'Notifications',
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/notifications'),
                        ),
                         _NavItem(
                          icon: '🛣️',
                          title: 'Bus Routes',
                          onTap: () => navigateToRoute(context, '/bus-routes'),
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
              color: const Color(0xFFF5F6FA),
              child: SafeArea(
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
                          Padding(
                            padding: EdgeInsets.all(isCompact ? 20 : 40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (_showSuccess)
                                    const _MessageBanner.success(
                                      message:
                                          '✅ Event updated successfully! Redirecting to events list...',
                                    ),
                                  if (_showError)
                                    _MessageBanner.error(
                                      message:
                                          _errorMessage.isNotEmpty ? _errorMessage : '❌ Error updating event. Please try again.',
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
                                          // NAME
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Event Name *',
                                              child: TextFormField(
                                                controller: _nameController,
                                                decoration: _inputDecoration(
                                                  hint: 'Enter event name',
                                                ),
                                                validator: _requiredValidator,
                                              ),
                                            ),
                                          ),
                                          // CATEGORY
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Category *',
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedCategory,
                                                items: _categories
                                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                                    .toList(),
                                                onChanged: (v) => setState(() => _selectedCategory = v),
                                                decoration: _inputDecoration(hint: 'Select Category'),
                                                validator: (v) => v == null ? 'Required' : null,
                                              ),
                                            ),
                                          ),
                                          // DATE
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Date *',
                                              child: InkWell(
                                                onTap: () async {
                                                  final date = await showDatePicker(
                                                    context: context,
                                                    initialDate: _selectedDate ?? DateTime.now(),
                                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                                  );
                                                  if (date != null) {
                                                    setState(() => _selectedDate = date);
                                                  }
                                                },
                                                child: InputDecorator(
                                                  decoration: _inputDecoration(hint: 'Select Date'),
                                                  child: Text(
                                                    _selectedDate != null
                                                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                                        : 'Select Date',
                                                    style: TextStyle(
                                                      color: _selectedDate != null ? const Color(0xFF333333) : const Color(0xFF555555),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // TIME
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Time',
                                              child: TextFormField(
                                                controller: _timeController,
                                                decoration: _inputDecoration(hint: 'e.g., 09:00 AM - 12:00 PM'),
                                              ),
                                            ),
                                          ),
                                          // LOCATION
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Location',
                                              child: TextFormField(
                                                controller: _locationController,
                                                decoration: _inputDecoration(hint: 'Enter location'),
                                              ),
                                            ),
                                          ),
                                          // ORGANIZER
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Organizer',
                                              child: TextFormField(
                                                controller: _organizerController,
                                                decoration: _inputDecoration(hint: 'Enter organizer'),
                                              ),
                                            ),
                                          ),
                                          // PARTICIPANTS
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Participants (Est.)',
                                              child: TextFormField(
                                                controller: _participantsController,
                                                keyboardType: TextInputType.number,
                                                decoration: _inputDecoration(hint: 'e.g., 150'),
                                              ),
                                            ),
                                          ),
                                          // STATUS
                                          SizedBox(
                                            width: isTwoColumns
                                                ? (constraints.maxWidth - 30) / 2
                                                : constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Status',
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedStatus,
                                                items: _statuses
                                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                                    .toList(),
                                                onChanged: (v) => setState(() => _selectedStatus = v!),
                                                decoration: _inputDecoration(hint: 'Select Status'),
                                              ),
                                            ),
                                          ),
                                          // DESCRIPTION
                                          SizedBox(
                                            width: constraints.maxWidth,
                                            child: _LabeledField(
                                              label: 'Description',
                                              child: TextFormField(
                                                controller: _descriptionController,
                                                maxLines: 4,
                                                decoration: _inputDecoration(hint: 'Enter event details...'),
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
                                        label: '💾 Update Event',
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
                                        onTap: _previewEvent,
                                      ),
                                      _GradientButton(
                                        label: '❌ Cancel',
                                        colors: const [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFEE5A52),
                                        ],
                                        onTap: () => Navigator.pushReplacementNamed(context, '/events'),
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
          ),
        ],
      ),
    );
  }

  void navigateToRoute(BuildContext context, String route) {
     Navigator.pushReplacementNamed(context, route);
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
            '📅 Edit Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Update the details below to modify the event',
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
}

// ----------------------------------------------------------------------------
// HELPER WIDGETS COPIED FROM ADD_TEACHER
// ----------------------------------------------------------------------------

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
          'Saving event information...',
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

class EventPreviewData {
  final String? name;
  final String? category;
  final String? date;
  final String? time;
  final String? location;
  final String? organizer;
  final String? participants;
  final String? status;
  final String? description;

  const EventPreviewData({
    required this.name,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.participants,
    required this.status,
    required this.description,
  });
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
