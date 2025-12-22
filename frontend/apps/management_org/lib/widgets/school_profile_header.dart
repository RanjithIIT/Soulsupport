import 'package:flutter/material.dart';
import 'package:core/api/api_service.dart';
import 'school_profile_dialog.dart';

/// Reusable widget for displaying school profile in the header
class SchoolProfileHeader extends StatefulWidget {
  final ApiService apiService;
  final bool isMobile;

  const SchoolProfileHeader({
    super.key,
    required this.apiService,
    this.isMobile = false,
  });

  @override
  State<SchoolProfileHeader> createState() => _SchoolProfileHeaderState();
}

class _SchoolProfileHeaderState extends State<SchoolProfileHeader> {
  String? _schoolName;
  String? _schoolId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    try {
      await widget.apiService.initialize();
      final response = await widget.apiService.get('/management-admin/schools/current/');
      
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map) {
          // The response might be wrapped in 'data' field or directly be the school data
          final schoolData = data['data'] ?? data;
          if (schoolData is Map) {
            setState(() {
              _schoolName = schoolData['name']?.toString() ?? 'School';
              _schoolId = schoolData['school_id']?.toString() ?? 
                         schoolData['id']?.toString();
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      setState(() {
        _schoolName = 'School';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _schoolName = 'School';
        _isLoading = false;
      });
    }
  }

  void _showSchoolProfile() {
    if (_schoolId != null) {
      showDialog(
        context: context,
        builder: (context) => SchoolProfileDialog(
          schoolId: _schoolId!,
          apiService: widget.apiService,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return InkWell(
        onTap: _showSchoolProfile,
        child: Row(
          children: [
            _buildSchoolAvatar(),
            const SizedBox(width: 15),
            Expanded(child: _buildSchoolLabels()),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _showSchoolProfile,
      child: Row(
        children: [
          _buildSchoolAvatar(),
          const SizedBox(width: 15),
          _buildSchoolLabels(),
        ],
      ),
    );
  }

  Widget _buildSchoolAvatar() {
    final initial = _schoolName?.isNotEmpty == true 
        ? _schoolName![0].toUpperCase() 
        : 'S';
    
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolLabels() {
    if (_isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 16,
            child: LinearProgressIndicator(),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: 80,
            height: 12,
            child: LinearProgressIndicator(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _schoolName ?? 'School',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Text(
          'School Profile',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

