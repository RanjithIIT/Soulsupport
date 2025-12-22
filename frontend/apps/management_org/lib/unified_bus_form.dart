import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';
import 'buses.dart';

// Data model for stops in the unified form
class StopData {
  String name = '';
  String address = '';
  String? time;
  int order = 1;
  String? stopId; // For existing stops
  List<Map<String, dynamic>> students = [];

  StopData({
    this.name = '',
    this.address = '',
    this.time,
    this.order = 1,
    this.stopId,
    List<Map<String, dynamic>>? students,
  }) : students = students ?? [];

  Map<String, dynamic> toJson() {
    return {
      'stop_name': name,
      'stop_address': address,
      'stop_time': time,
      'stop_order': order,
    };
  }
}

// Unified Bus Form Dialog
class UnifiedBusFormDialog extends StatefulWidget {
  final Bus? bus;
  final VoidCallback onSave;

  const UnifiedBusFormDialog({
    super.key,
    this.bus,
    required this.onSave,
  });

  @override
  State<UnifiedBusFormDialog> createState() => _UnifiedBusFormDialogState();
}

class _UnifiedBusFormDialogState extends State<UnifiedBusFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // === BUS DETAILS CONTROLLERS ===
  final _busNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _driverExperienceController = TextEditingController();
  final _routeNameController = TextEditingController();
  final _routeDistanceController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _busType;
  TimeOfDay? _morningStartTime;
  TimeOfDay? _morningEndTime;
  TimeOfDay? _afternoonStartTime;
  TimeOfDay? _afternoonEndTime;
  bool _isActive = true;
  
  // === STOPS DATA ===
  List<StopData> _morningStops = [];
  List<StopData> _afternoonStops = [];
  
  // === STATE ===
  bool _isSubmitting = false;
  bool _isLoading = false;
  int _currentStep = 0;
  bool _autoSyncAfternoonStops = true; // Auto-sync afternoon stops from morning
  
  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _loadBusData();
    } else {
      _morningStops.add(StopData(order: 1));
      _syncAfternoonStopsFromMorning();
    }
  }
  
  // Auto-generate afternoon stops from morning stops (reverse order)
  // Morning 1st stop = Afternoon last stop
  // IMPORTANT: Syncs name, address, and students from morning stops
  // Students from morning stops are copied to afternoon stops when they match by name
  void _syncAfternoonStopsFromMorning() {
    if (!_autoSyncAfternoonStops) return;
    
    setState(() {
      // Create a map of existing afternoon stops by name to preserve times, students, and stopId
      final existingAfternoonMap = <String, StopData>{};
      for (var stop in _afternoonStops) {
        if (stop.name.isNotEmpty) {
          existingAfternoonMap[stop.name] = stop;
        }
      }
      
      // Generate afternoon stops in reverse order
      final reversedMorningStops = _morningStops.reversed.toList();
      _afternoonStops = reversedMorningStops.asMap().entries.map((entry) {
        final index = entry.key;
        final morningStop = entry.value;
        
        // Find existing afternoon stop with same name to preserve time, students, and stopId
        final existingAfternoonStop = existingAfternoonMap[morningStop.name];
        
        // If afternoon stop exists, preserve its time and stopId, but sync students from morning
        if (existingAfternoonStop != null) {
          // Merge students: start with morning students, then add any unique afternoon students
          final mergedStudents = <String, Map<String, dynamic>>{};
          
          // Add all morning students
          for (var student in morningStop.students) {
            final studentId = student['student_id_string']?.toString() ?? 
                             student['id']?.toString() ?? '';
            if (studentId.isNotEmpty) {
              mergedStudents[studentId] = Map<String, dynamic>.from(student);
            }
          }
          
          // Add any afternoon students that aren't already in morning (preserve unique afternoon students)
          for (var student in existingAfternoonStop.students) {
            final studentId = student['student_id_string']?.toString() ?? 
                             student['id']?.toString() ?? '';
            if (studentId.isNotEmpty && !mergedStudents.containsKey(studentId)) {
              mergedStudents[studentId] = Map<String, dynamic>.from(student);
            }
          }
          
          return StopData(
            name: morningStop.name, // Update name from morning
            address: morningStop.address, // Update address from morning
            time: existingAfternoonStop.time, // Preserve existing afternoon time
            order: index + 1,
            stopId: existingAfternoonStop.stopId, // Preserve stopId
            students: mergedStudents.values.toList(), // Sync students from morning, preserve unique afternoon students
          );
        } else {
          // New afternoon stop - copy students from morning stop
          return StopData(
            name: morningStop.name,
            address: morningStop.address,
            time: null, // No time set yet - user must set it
            order: index + 1,
            stopId: null,
            students: List<Map<String, dynamic>>.from(morningStop.students), // Copy students from morning stop
          );
        }
      }).toList();
    });
  }
  
  // Get all students across all stops to check for duplicates
  Map<String, Map<String, dynamic>> _getAllAssignedStudents() {
    final allStudents = <String, Map<String, dynamic>>{};
    for (var stop in [..._morningStops, ..._afternoonStops]) {
      for (var student in stop.students) {
        final studentId = student['student_id_string']?.toString() ?? 
                         student['id']?.toString() ?? '';
        if (studentId.isNotEmpty) {
          allStudents[studentId] = {
            'student': student,
            'stop_name': stop.name,
            'stop_index': _morningStops.indexOf(stop) >= 0 
                ? _morningStops.indexOf(stop) + 1
                : _afternoonStops.indexOf(stop) + 1,
            'route_type': _morningStops.contains(stop) ? 'morning' : 'afternoon',
          };
        }
      }
    }
    return allStudents;
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
    _startLocationController.dispose();
    _endLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBusData() async {
    if (widget.bus == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _apiService.initialize();
      final response = await _apiService.get('${Endpoints.buses}${widget.bus!.id}/');
      
      if (response.success && response.data is Map) {
        final busData = response.data as Map<String, dynamic>;
        
        // Load bus details
        _busNumberController.text = busData['bus_number'] ?? '';
        _capacityController.text = (busData['capacity'] ?? '').toString();
        _registrationNumberController.text = busData['registration_number'] ?? '';
        _driverNameController.text = busData['driver_name'] ?? '';
        _driverPhoneController.text = busData['driver_phone'] ?? '';
        _driverLicenseController.text = busData['driver_license'] ?? '';
        _driverExperienceController.text = (busData['driver_experience'] ?? '').toString();
        _routeNameController.text = busData['route_name'] ?? '';
        _routeDistanceController.text = (busData['route_distance'] ?? '').toString();
        _startLocationController.text = busData['start_location'] ?? '';
        _endLocationController.text = busData['end_location'] ?? '';
        _notesController.text = busData['notes'] ?? '';
        _busType = busData['bus_type'];
        _isActive = busData['is_active'] ?? true;
        
        // Parse times
        if (busData['morning_start_time'] != null) {
          final time = _parseTime(busData['morning_start_time']);
          if (time != null) _morningStartTime = time;
        }
        if (busData['morning_end_time'] != null) {
          final time = _parseTime(busData['morning_end_time']);
          if (time != null) _morningEndTime = time;
        }
        if (busData['afternoon_start_time'] != null) {
          final time = _parseTime(busData['afternoon_start_time']);
          if (time != null) _afternoonStartTime = time;
        }
        if (busData['afternoon_end_time'] != null) {
          final time = _parseTime(busData['afternoon_end_time']);
          if (time != null) _afternoonEndTime = time;
        }
        
        // Load stops
        final morningStopsData = busData['morning_stops'] as List? ?? [];
        final afternoonStopsData = busData['afternoon_stops'] as List? ?? [];
        
        _morningStops = morningStopsData.map((stop) {
          final stopMap = stop as Map<String, dynamic>;
          // Load students for this stop
          final students = (stopMap['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          return StopData(
            name: stopMap['stop_name'] ?? '',
            address: stopMap['stop_address'] ?? '',
            time: stopMap['stop_time']?.toString(),
            order: stopMap['stop_order'] ?? 1,
            stopId: stopMap['stop_id']?.toString(),
            students: students,
          );
        }).toList();
        
        // Load afternoon stops but preserve their times
        _afternoonStops = afternoonStopsData.map((stop) {
          final stopMap = stop as Map<String, dynamic>;
          final students = (stopMap['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          return StopData(
            name: stopMap['stop_name'] ?? '',
            address: stopMap['stop_address'] ?? '',
            time: stopMap['stop_time']?.toString(),
            order: stopMap['stop_order'] ?? 1,
            stopId: stopMap['stop_id']?.toString(),
            students: students,
          );
        }).toList();
        
        if (_morningStops.isEmpty) {
          _morningStops.add(StopData(order: 1));
        }
        
        // Sync afternoon stops from morning if they don't exist
        if (_afternoonStops.isEmpty && _morningStops.isNotEmpty) {
          _syncAfternoonStopsFromMorning();
        } else {
          // Sync students from morning stops to afternoon stops (students assigned to morning should appear in afternoon)
          _syncAfternoonStopsFromMorning();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bus data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  TimeOfDay? _parseTime(dynamic timeValue) {
    if (timeValue == null) return null;
    final timeStr = timeValue.toString();
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 850),
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.bus == null ? 'Add New Bus' : 'Edit Bus',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Stepper
                  Expanded(
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepContinue: _currentStep < 2
                          ? () {
                              if (_validateCurrentStep()) {
                                setState(() => _currentStep++);
                              }
                            }
                          : null,
                      onStepCancel: _currentStep > 0
                          ? () {
                              setState(() => _currentStep--);
                            }
                          : null,
                      steps: [
                        Step(
                          title: const Text('Bus Details'),
                          content: _buildBusDetailsSection(),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0
                              ? StepState.complete
                              : StepState.indexed,
                        ),
                        Step(
                          title: const Text('Morning Route Stops'),
                          content: _buildStopsSection('morning'),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1
                              ? StepState.complete
                              : StepState.indexed,
                        ),
                        Step(
                          title: const Text('Afternoon Route Stops'),
                          content: _buildStopsSection('afternoon'),
                          isActive: _currentStep >= 2,
                          state: _currentStep >= 2
                              ? StepState.complete
                              : StepState.indexed,
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.bus == null
                                ? 'Create Bus'
                                : 'Update Bus'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildBusDetailsSection() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bus Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _busNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Bus Number *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Bus Type *',
                      border: OutlineInputBorder(),
                    ),
                    value: _busType,
                    items: ['Mini Bus', 'Standard Bus', 'Large Bus', 'AC Bus']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _busType = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registrationNumberController,
              decoration: const InputDecoration(
                labelText: 'Registration Number *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Driver Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _driverPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _driverLicenseController,
                    decoration: const InputDecoration(
                      labelText: 'Driver License *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _driverExperienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience (Years)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Route Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeNameController,
              decoration: const InputDecoration(
                labelText: 'Route Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _routeDistanceController,
                    decoration: const InputDecoration(
                      labelText: 'Route Distance (km)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _startLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Start Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _endLocationController,
                    decoration: const InputDecoration(
                      labelText: 'End Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Schedule Times',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Morning Start Time *'),
                    subtitle: Text(_morningStartTime?.format(context) ?? 'Select time'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _morningStartTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _morningStartTime = time);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Morning End Time *'),
                    subtitle: Text(_morningEndTime?.format(context) ?? 'Select time'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _morningEndTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _morningEndTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Afternoon Start Time *'),
                    subtitle: Text(_afternoonStartTime?.format(context) ?? 'Select time'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _afternoonStartTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _afternoonStartTime = time);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Afternoon End Time *'),
                    subtitle: Text(_afternoonEndTime?.format(context) ?? 'Select time'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _afternoonEndTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _afternoonEndTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStopsSection(String routeType) {
    final stops = routeType == 'morning' ? _morningStops : _afternoonStops;
    final isAfternoon = routeType == 'afternoon';
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${routeType == 'morning' ? 'Morning' : 'Afternoon'} Route Stops',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAfternoon)
                    const Text(
                      'Auto-generated from morning stops (read-only except time)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              if (!isAfternoon)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      final newOrder = stops.isEmpty
                          ? 1
                          : (stops.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1);
                      _morningStops.add(StopData(order: newOrder));
                      _syncAfternoonStopsFromMorning();
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF51CF66),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (stops.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No stops added. Click "Add Stop" to add one.'),
              ),
            )
          else
            ...stops.asMap().entries.map((entry) {
              final index = entry.key;
              final stop = entry.value;
              return _StopCard(
                stop: stop,
                index: index,
                routeType: routeType,
                onUpdate: (updatedStop) {
                  setState(() {
                    if (routeType == 'morning') {
                      _morningStops[index] = updatedStop;
                      // Sync name and address to afternoon stops, but preserve afternoon times
                      _syncAfternoonStopsFromMorning();
                    } else {
                      // Afternoon stops: allow all updates (name, address, time are all editable)
                      // But name and address will be synced from morning, so only time and students matter here
                      _afternoonStops[index] = updatedStop;
                    }
                  });
                },
                onDelete: () {
                  if (routeType == 'morning') {
                    setState(() {
                      _morningStops.removeAt(index);
                      // Reorder remaining stops
                      for (var i = 0; i < _morningStops.length; i++) {
                        _morningStops[i].order = i + 1;
                      }
                      _syncAfternoonStopsFromMorning();
                    });
                  }
                  // Afternoon stops cannot be deleted (they're auto-generated)
                },
                onAddStudents: () => _showAddStudentsDialog(stop, routeType, index),
              );
            }).toList(),
        ],
      ),
    );
  }
  
  Widget _StopCard({
    required StopData stop,
    required int index,
    required String routeType,
    required Function(StopData) onUpdate,
    required VoidCallback onDelete,
    required VoidCallback onAddStudents,
  }) {
    final isAfternoon = routeType == 'afternoon';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text('Stop ${index + 1}: ${stop.name.isEmpty ? "New Stop" : stop.name}'),
        subtitle: Text('${stop.students.length} students'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  initialValue: stop.name,
                  decoration: InputDecoration(
                    labelText: 'Stop Name *',
                    border: const OutlineInputBorder(),
                    filled: isAfternoon,
                    fillColor: isAfternoon ? Colors.grey[200] : null,
                  ),
                  readOnly: isAfternoon,
                  onChanged: isAfternoon ? null : (v) {
                    stop.name = v;
                    onUpdate(stop);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: stop.address,
                  decoration: InputDecoration(
                    labelText: 'Stop Address',
                    border: const OutlineInputBorder(),
                    filled: isAfternoon,
                    fillColor: isAfternoon ? Colors.grey[200] : null,
                  ),
                  readOnly: isAfternoon,
                  onChanged: isAfternoon ? null : (v) {
                    stop.address = v;
                    onUpdate(stop);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Stop Time *'),
                        subtitle: Text(
                          stop.time ?? 'Not set - Click to select time',
                          style: TextStyle(
                            color: stop.time == null ? Colors.orange : Colors.black,
                            fontStyle: stop.time == null ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        trailing: const Icon(Icons.access_time, color: Colors.blue),
                        onTap: () async {
                          // Both morning and afternoon stops: time is editable
                          TimeOfDay? initialTime;
                          if (stop.time != null && stop.time!.isNotEmpty) {
                            final parts = stop.time!.split(':');
                            if (parts.length >= 2) {
                              initialTime = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 0,
                                minute: int.tryParse(parts[1]) ?? 0,
                              );
                            }
                          }
                          final time = await showTimePicker(
                            context: context,
                            initialTime: initialTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            stop.time =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            onUpdate(stop);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: stop.order.toString(),
                        decoration: InputDecoration(
                          labelText: 'Stop Order *',
                          border: const OutlineInputBorder(),
                          filled: isAfternoon,
                          fillColor: isAfternoon ? Colors.grey[200] : null,
                        ),
                        keyboardType: TextInputType.number,
                        readOnly: isAfternoon,
                        onChanged: isAfternoon ? null : (v) {
                          stop.order = int.tryParse(v) ?? 1;
                          onUpdate(stop);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Students at this stop:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: onAddStudents,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Students'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF51CF66),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (stop.students.isEmpty)
                  const Text(
                    'No students assigned',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...stop.students.map((student) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (student['student_name'] ?? '?')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(student['student_name'] ?? 'Unknown'),
                      subtitle: Text('ID: ${student['student_id_string'] ?? student['id'] ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            final studentId = student['student_id_string']?.toString() ?? 
                                             student['id']?.toString() ?? '';
                            stop.students.remove(student);
                            
                            // If morning stop, also remove from corresponding afternoon stop
                            if (routeType == 'morning') {
                              final correspondingAfternoonStop = _afternoonStops.firstWhere(
                                (afternoonStop) => afternoonStop.name == stop.name,
                                orElse: () => StopData(),
                              );
                              if (correspondingAfternoonStop.name.isNotEmpty && studentId.isNotEmpty) {
                                correspondingAfternoonStop.students.removeWhere(
                                  (s) => (s['student_id_string']?.toString() ?? s['id']?.toString()) == studentId
                                );
                              }
                              // Sync to ensure consistency
                              _syncAfternoonStopsFromMorning();
                            }
                            
                            onUpdate(stop);
                          });
                        },
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 8),
                if (!isAfternoon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete Stop', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showAddStudentsDialog(
      StopData stop, String routeType, int stopIndex) async {
    final studentIdController = TextEditingController();
    bool isLoadingStudents = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Students to ${stop.name.isEmpty ? "Stop ${stopIndex + 1}" : stop.name}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Student ID',
                    hintText: 'Search by Student ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) async {
                    if (value.isEmpty) return;
                    setDialogState(() => isLoadingStudents = true);
                    try {
                      await _apiService.initialize();
                      final response = await _apiService.get(Endpoints.students);
                      if (response.success) {
                        List<dynamic> allStudents = [];
                        if (response.data is List) {
                          allStudents = response.data as List;
                        } else if (response.data is Map &&
                            (response.data as Map)['results'] != null) {
                          allStudents = (response.data as Map)['results'] as List;
                        }
                        final student = allStudents.firstWhere(
                          (s) =>
                              s['student_id']?.toString() == value ||
                              s['id']?.toString() == value,
                          orElse: () => null,
                        );
                        if (student != null) {
                          final studentIdString = student['student_id']?.toString() ??
                              student['id']?.toString();
                          
                          // Check if student is already assigned to any stop
                          final allAssignedStudents = _getAllAssignedStudents();
                          if (allAssignedStudents.containsKey(studentIdString)) {
                            final assignedInfo = allAssignedStudents[studentIdString]!;
                            final assignedStopName = assignedInfo['stop_name'] as String;
                            final assignedStopIndex = assignedInfo['stop_index'] as int;
                            final assignedRouteType = assignedInfo['route_type'] as String;
                            
                            // Check if it's the same stop
                            if (stop.name == assignedStopName && 
                                routeType == assignedRouteType) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Student already added to this stop'),
                                ),
                              );
                            } else {
                              // Show popup that student is already assigned
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Student Already Assigned'),
                                  content: Text(
                                    'This student is already assigned to:\n'
                                    'Stop ${assignedStopIndex} (${assignedRouteType == 'morning' ? 'Morning' : 'Afternoon'} Route): $assignedStopName\n\n'
                                    'Please remove the student from that stop first before assigning to a different stop.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            // Student not assigned, add them
                            final studentMap = {
                              'id': student['student_id'] ?? student['id'],
                              'student_id_string': studentIdString,
                              'student_name': student['student_name'] ?? 'Unknown',
                              'student_class': student['applying_class'] ?? '',
                            };
                            
                            setState(() {
                              stop.students.add(studentMap);
                              // If morning stop, sync to corresponding afternoon stop
                              if (routeType == 'morning') {
                                // Find corresponding afternoon stop by name and add the student
                                final correspondingAfternoonStop = _afternoonStops.firstWhere(
                                  (afternoonStop) => afternoonStop.name == stop.name,
                                  orElse: () => StopData(),
                                );
                                if (correspondingAfternoonStop.name.isNotEmpty) {
                                  // Check if student is not already in afternoon stop
                                  final studentId = studentMap['student_id_string']?.toString() ?? 
                                                   studentMap['id']?.toString() ?? '';
                                  final alreadyExists = correspondingAfternoonStop.students.any(
                                    (s) => (s['student_id_string']?.toString() ?? s['id']?.toString()) == studentId
                                  );
                                  if (!alreadyExists) {
                                    correspondingAfternoonStop.students.add(Map<String, dynamic>.from(studentMap));
                                  }
                                }
                                // Also sync all stops to ensure consistency
                                _syncAfternoonStopsFromMorning();
                              } else if (routeType == 'afternoon') {
                                // If afternoon stop, also sync
                                _syncAfternoonStopsFromMorning();
                              }
                            });
                            studentIdController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Student added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Student with ID $value not found'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      setDialogState(() => isLoadingStudents = false);
                    }
                  },
                ),
                if (isLoadingStudents)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return false;
      if (_morningStartTime == null ||
          _morningEndTime == null ||
          _afternoonStartTime == null ||
          _afternoonEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select all schedule times'),
          ),
        );
        return false;
      }
    }
    return true;
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_morningStartTime == null ||
        _morningEndTime == null ||
        _afternoonStartTime == null ||
        _afternoonEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all schedule times'),
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      await _apiService.initialize();
      
      // Get school ID
      final schoolResponse =
          await _apiService.get('/management-admin/schools/current/');
      String? schoolId;
      if (schoolResponse.success && schoolResponse.data != null) {
        final data = schoolResponse.data;
        if (data is Map) {
          final schoolData = data['data'] ?? data;
          if (schoolData is Map) {
            schoolId = schoolData['school_id']?.toString() ??
                schoolData['id']?.toString();
          }
        }
      }
      
      if (schoolId == null) {
        throw Exception(
            'No school found. Please contact administrator to assign a school to your account.');
      }
      
      // 1. Create/Update Bus
      final busData = {
        'school': schoolId,
        'bus_number': _busNumberController.text.trim(),
        'bus_type': _busType ?? 'Standard Bus',
        'capacity': int.parse(_capacityController.text.trim()),
        'registration_number': _registrationNumberController.text.trim(),
        'driver_name': _driverNameController.text.trim(),
        'driver_phone': _driverPhoneController.text.trim(),
        'driver_license': _driverLicenseController.text.trim(),
        'driver_experience': _driverExperienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_driverExperienceController.text.trim()),
        'route_name': _routeNameController.text.trim(),
        'route_distance': _routeDistanceController.text.trim().isEmpty
            ? null
            : double.tryParse(_routeDistanceController.text.trim()),
        'start_location': _startLocationController.text.trim(),
        'end_location': _endLocationController.text.trim(),
        'morning_start_time':
            '${_morningStartTime!.hour.toString().padLeft(2, '0')}:${_morningStartTime!.minute.toString().padLeft(2, '0')}',
        'morning_end_time':
            '${_morningEndTime!.hour.toString().padLeft(2, '0')}:${_morningEndTime!.minute.toString().padLeft(2, '0')}',
        'afternoon_start_time':
            '${_afternoonStartTime!.hour.toString().padLeft(2, '0')}:${_afternoonStartTime!.minute.toString().padLeft(2, '0')}',
        'afternoon_end_time':
            '${_afternoonEndTime!.hour.toString().padLeft(2, '0')}:${_afternoonEndTime!.minute.toString().padLeft(2, '0')}',
        'notes': _notesController.text.trim(),
        'is_active': _isActive,
      };
      
      final busResponse = widget.bus == null
          ? await _apiService.post(Endpoints.buses, body: busData)
          : await _apiService.put(
              '${Endpoints.buses}${widget.bus!.id}/', body: busData);
      
      if (!busResponse.success) {
        // Get detailed error message
        String errorMessage = 'Failed to save bus';
        if (busResponse.data is Map) {
          final errorData = busResponse.data as Map<String, dynamic>;
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData.isNotEmpty) {
            // Format validation errors
            final errors = errorData.entries.map((e) => '${e.key}: ${e.value}').join(', ');
            errorMessage = 'Validation errors: $errors';
          }
        } else if (busResponse.error != null) {
          errorMessage = busResponse.error!;
        }
        throw Exception(errorMessage);
      }
      
      // Extract bus_number from response
      String busNumber;
      if (widget.bus != null) {
        busNumber = widget.bus!.id;
      } else {
        // For new bus, get bus_number from response
        final responseData = busResponse.data;
        if (responseData is Map) {
          busNumber = responseData['bus_number']?.toString() ?? 
                     _busNumberController.text.trim();
        } else {
          busNumber = _busNumberController.text.trim();
        }
        
        // Validate that we got a bus_number
        if (busNumber.isEmpty) {
          throw Exception('Bus created but no bus number returned from server');
        }
      }
      
      // 2. Delete existing stops for this bus (if editing)
      if (widget.bus != null) {
        final existingStopsResponse = await _apiService.get(
            '${Endpoints.busStops}?bus=$busNumber');
        if (existingStopsResponse.success &&
            existingStopsResponse.data is List) {
          final existingStops = existingStopsResponse.data as List;
          for (var stop in existingStops) {
            final stopId = stop['stop_id']?.toString();
            if (stopId != null) {
              await _apiService.delete('${Endpoints.busStops}$stopId/');
            }
          }
        }
      }
      
      // 3. Create Morning Stops
      final createdMorningStopIds = <String>[];
      for (var stop in _morningStops) {
        if (stop.name.isEmpty) continue; // Skip empty stops
        final stopData = {
          'bus': busNumber,
          'stop_name': stop.name,
          'stop_address': stop.address,
          'stop_time': stop.time,
          'route_type': 'morning',
          'stop_order': stop.order,
        };
        final stopResponse =
            await _apiService.post(Endpoints.busStops, body: stopData);
        if (!stopResponse.success) {
          final errorMsg = stopResponse.error ?? 
              (stopResponse.data is Map ? stopResponse.data['detail']?.toString() ?? 
               stopResponse.data.toString() : 'Failed to create stop');
          throw Exception('Failed to create morning stop "${stop.name}": $errorMsg');
        }
        
        // Extract stop_id from response
        final responseData = stopResponse.data;
        String? stopId;
        if (responseData is Map) {
          stopId = responseData['stop_id']?.toString() ?? 
                   responseData['id']?.toString();
        }
        
        if (stopId == null || stopId.isEmpty) {
          throw Exception('Failed to create morning stop "${stop.name}": No stop ID returned from server');
        }
        
        createdMorningStopIds.add(stopId);
        stop.stopId = stopId;
      }
      
      // 4. Create Afternoon Stops
      final createdAfternoonStopIds = <String>[];
      for (var stop in _afternoonStops) {
        if (stop.name.isEmpty) continue; // Skip empty stops
        final stopData = {
          'bus': busNumber,
          'stop_name': stop.name,
          'stop_address': stop.address,
          'stop_time': stop.time,
          'route_type': 'afternoon',
          'stop_order': stop.order,
        };
        final stopResponse =
            await _apiService.post(Endpoints.busStops, body: stopData);
        if (!stopResponse.success) {
          final errorMsg = stopResponse.error ?? 
              (stopResponse.data is Map ? stopResponse.data['detail']?.toString() ?? 
               stopResponse.data.toString() : 'Failed to create stop');
          throw Exception('Failed to create afternoon stop "${stop.name}": $errorMsg');
        }
        
        // Extract stop_id from response
        final responseData = stopResponse.data;
        String? stopId;
        if (responseData is Map) {
          stopId = responseData['stop_id']?.toString() ?? 
                   responseData['id']?.toString();
        }
        
        if (stopId == null || stopId.isEmpty) {
          throw Exception('Failed to create afternoon stop "${stop.name}": No stop ID returned from server');
        }
        
        createdAfternoonStopIds.add(stopId);
        stop.stopId = stopId;
      }
      
      // 5. Assign Students to Stops
      final assignedStudentIds = <String>{}; // Track assigned students to prevent duplicates
      for (var stop in [..._morningStops, ..._afternoonStops]) {
        if (stop.stopId != null && stop.students.isNotEmpty) {
          for (var student in stop.students) {
            final studentId = student['student_id_string']?.toString() ?? 
                             student['id']?.toString() ?? '';
            
            if (studentId.isEmpty) continue;
            
            // Check for duplicates in our local data
            if (assignedStudentIds.contains(studentId)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Warning: Student ${student['student_name']} is assigned to multiple stops. Only the first assignment will be saved.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              continue;
            }
            
            try {
              final response = await _apiService.post(Endpoints.busStopStudents, body: {
                'stop': stop.stopId,
                'student_id': studentId,
              });
              
              if (response.success) {
                assignedStudentIds.add(studentId);
              } else {
                // Show error message from backend only if still mounted
                if (mounted) {
                  final errorMsg = response.error ?? response.data?.toString() ?? 'Failed to assign student';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error assigning ${student['student_name']}: $errorMsg'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              // Only show error if still mounted
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error assigning ${student['student_name']}: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      }
      
      // Reset submitting state
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      
      // Close dialog immediately and return true to indicate success
      // The parent will handle the refresh and success message
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Reset submitting state on error
      if (mounted) {
        setState(() => _isSubmitting = false);
        // Don't close dialog on error, just show error message
        // Check if context is still valid before showing SnackBar
        try {
          if (Navigator.of(context).canPop()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (contextError) {
          // Context is invalid, just log the error
          debugPrint('Error showing snackbar: $contextError');
          debugPrint('Original error: $e');
        }
      }
    }
  }
}

