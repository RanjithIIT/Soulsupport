import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';

/// Dialog to display school profile details
class SchoolProfileDialog extends StatefulWidget {
  final String schoolId;
  final ApiService apiService;

  const SchoolProfileDialog({
    super.key,
    required this.schoolId,
    required this.apiService,
  });

  @override
  State<SchoolProfileDialog> createState() => _SchoolProfileDialogState();
}

class _SchoolProfileDialogState extends State<SchoolProfileDialog> {
  Map<String, dynamic>? _schoolData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchoolDetails();
  }

  Future<void> _loadSchoolDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.apiService.initialize();
      // Try to get school details from super admin endpoint first
      final response = await widget.apiService.get('${Endpoints.adminSchools}${widget.schoolId}/');
      
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map) {
          setState(() {
            _schoolData = data as Map<String, dynamic>;
            _isLoading = false;
          });
          return;
        }
      }
      
      // If that fails, try the current school endpoint
      final currentResponse = await widget.apiService.get('/management-admin/schools/current/');
      if (currentResponse.success && currentResponse.data != null) {
        final data = currentResponse.data;
        if (data is Map) {
          final schoolData = data['data'] ?? data;
          if (schoolData is Map) {
            setState(() {
              _schoolData = schoolData as Map<String, dynamic>;
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      setState(() {
        _errorMessage = 'Failed to load school details';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'School Profile',
                  style: TextStyle(
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, 
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSchoolDetails,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: _buildSchoolDetails(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolDetails() {
    if (_schoolData == null) return const SizedBox();

    final school = _schoolData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // School Logo/Initial
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: Center(
              child: Text(
                (school['name']?.toString() ?? 'S')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // School Name
        _buildInfoRow('School Name', school['name']?.toString() ?? 'N/A'),
        const SizedBox(height: 16),
        
        // School ID
        _buildInfoRow('School ID', school['school_id']?.toString() ?? 'N/A'),
        const SizedBox(height: 16),
        
        // Principal Name
        if (school['principal_name'] != null)
          _buildInfoRow('Principal Name', school['principal_name']?.toString() ?? 'N/A'),
        if (school['principal_name'] != null) const SizedBox(height: 16),
        
        // Phone Number
        if (school['phone'] != null)
          _buildInfoRow('Phone Number', school['phone']?.toString() ?? 'N/A'),
        if (school['phone'] != null) const SizedBox(height: 16),
        
        // Email
        if (school['email'] != null)
          _buildInfoRow('Email', school['email']?.toString() ?? 'N/A'),
        if (school['email'] != null) const SizedBox(height: 16),
        
        // Address
        if (school['address'] != null)
          _buildInfoRow('Address', school['address']?.toString() ?? 'N/A'),
        if (school['address'] != null) const SizedBox(height: 16),
        
        // Location
        if (school['location'] != null)
          _buildInfoRow('Location', school['location']?.toString() ?? 'N/A'),
        if (school['location'] != null) const SizedBox(height: 16),
        
        // Established Year
        if (school['established_year'] != null)
          _buildInfoRow('Established Year', school['established_year']?.toString() ?? 'N/A'),
        if (school['established_year'] != null) const SizedBox(height: 16),
        
        // Status
        if (school['status'] != null)
          _buildInfoRow('Status', 
              (school['status']?.toString() ?? 'N/A').toUpperCase()),
        if (school['status'] != null) const SizedBox(height: 16),
        
        // Registration Number
        if (school['registration_number'] != null)
          _buildInfoRow('Registration Number', 
              school['registration_number']?.toString() ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

