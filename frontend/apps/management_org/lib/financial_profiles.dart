import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/auth_service.dart';
import 'package:core/api/endpoints.dart';
import 'management_routes.dart';
import 'package:intl/intl.dart';

class FinancialProfilesPage extends StatefulWidget {
  const FinancialProfilesPage({super.key});

  @override
  State<FinancialProfilesPage> createState() => _FinancialProfilesPageState();
}

class _FinancialProfilesPageState extends State<FinancialProfilesPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _financialUsers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFinancialUsers();
  }

  Future<void> _fetchFinancialUsers() async {
    try {
      final token = _apiService.authToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse(Endpoints.buildUrl(Endpoints.financialUsers)), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        setState(() {
          if (decodedData is List) {
            _financialUsers = decodedData;
          } else if (decodedData is Map<String, dynamic>) {
            if (decodedData.containsKey('results') && decodedData['results'] is List) {
              _financialUsers = decodedData['results'];
            } else if (decodedData.containsKey('data') && decodedData['data'] is List) {
              _financialUsers = decodedData['data'];
            } else {
              // Handle case where Map doesn't contain expected list
              _financialUsers = []; 
              print('Warning: Unexpected JSON format. Received Map without results/data list.');
            }
          } else {
            _financialUsers = [];
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['username']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Handle ID as dynamic (can be String UUID or potentially int)
      final dynamic idVal = user['id'] ?? user['user_id'];
      String? userId = idVal?.toString();
      
      if (userId != null && userId.isNotEmpty) {
        _deleteUser(userId);
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not determine User ID')),
        );
      }
    }
  }

  Future<void> _deleteUser(String? userId) async {
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final token = _apiService.authToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('${Endpoints.buildUrl(Endpoints.financialUsers)}$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _fetchFinancialUsers(); // Refresh list
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }
  


  void _showEditUserDialog(Map<String, dynamic> user) {
    // ... form setup omitted (unchanged) ...
    final formKey = GlobalKey<FormState>();
    final Map<String, dynamic> formData = {
      'username': user['username'],
      'email': user['email'],
      'first_name': user['first_name'],
      'last_name': user['last_name'],
      'mobile': user['mobile'],
      'address': user['address'],
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: formData['username'],
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSaved: (value) => formData['username'] = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: formData['email'],
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSaved: (value) => formData['email'] = value,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: formData['first_name'],
                  decoration: const InputDecoration(labelText: 'First Name'),
                  onSaved: (value) => formData['first_name'] = value,
                ),
                TextFormField(
                  initialValue: formData['last_name'],
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  onSaved: (value) => formData['last_name'] = value,
                ),
                TextFormField(
                  initialValue: formData['mobile'],
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  onSaved: (value) => formData['mobile'] = value,
                ),
                 TextFormField(
                  initialValue: formData['address'],
                  decoration: const InputDecoration(labelText: 'Address'),
                  onSaved: (value) => formData['address'] = value,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.of(context).pop();
                
                final dynamic idVal = user['id'] ?? user['user_id'];
                String? userId = idVal?.toString();
                
                if (userId != null && userId.isNotEmpty) {
                  await _updateUser(userId, formData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Could not determine User ID')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(String? userId, Map<String, dynamic> data) async {
    if (userId == null) return;
    setState(() => _isLoading = true);
    
    try {
      final token = _apiService.authToken;
      if (token == null) throw Exception('Not authenticated');

      final url = '${Endpoints.buildUrl(Endpoints.financialUsers)}$userId/';
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
        _fetchFinancialUsers();
      } else {
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['username'] ?? 'User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Full Name', '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
              _buildDetailItem('Email', user['email']),
              _buildDetailItem('Mobile', user['mobile']),
              _buildDetailItem('Role', user['role_name'] ?? 'Financial Staff'),
              _buildDetailItem('Address', user['address']),
              _buildDetailItem('Date of Birth', user['date_of_birth']),
              _buildDetailItem('Gender', user['gender']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Text(value ?? 'N/A', style: const TextStyle(fontSize: 14)),
          const Divider(height: 8),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4F8), Color(0xFFE1E8ED)],
          ),
        ),
        child: Row(
          children: [
            // We would usually have a sidebar here, but for now let's focus on the content
            // Assuming this page is pushed into the main layout or handles its own structure.
            // If it's a full page replacement, we might need the Sidebar.
            // For now, let's keep it simple as a full generic page.
            Expanded(
              child: Column(
                children: [
                   _buildHeader(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage.isNotEmpty
                            ? Center(child: Text('Error: $_errorMessage'))
                            : _buildUserList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE1E8ED)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          const Text(
            'Financial Staff Profiles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const Spacer(),
          if (ApiService().userRole != 'financial')
            ElevatedButton.icon(
              onPressed: () async {
                // Show dialog to create financial credentials
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const _CreateFinancialCredentialsDialog(),
                );

                if (result == true) {
                  _fetchFinancialUsers();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA), // Purple gradient color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Create Financial Details'),
            ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_financialUsers.isEmpty) {
      return const Center(child: Text('No financial staff found.'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Adjust for responsiveness later
          childAspectRatio: 1.5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: _financialUsers.length,
        itemBuilder: (context, index) {
          final user = _financialUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF667EEA).withValues(alpha: 0.1),
                child: Text(
                  (user['username'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, user['mobile'] ?? 'N/A'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                tooltip: 'View Details',
                onPressed: () {
                  _showUserDetails(user);
                },
              ),
              if (ApiService().userRole != 'financial') ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit User',
                  onPressed: () {
                    _showEditUserDialog(user);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: () => _confirmDeleteUser(user),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// Create Financial Credentials Dialog
class _CreateFinancialCredentialsDialog extends StatefulWidget {
  const _CreateFinancialCredentialsDialog();

  @override
  State<_CreateFinancialCredentialsDialog> createState() => _CreateFinancialCredentialsDialogState();
}

class _CreateFinancialCredentialsDialogState extends State<_CreateFinancialCredentialsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCreating = false;
  DateTime? _dateOfBirth;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadSchoolId();
  }

  Future<void> _loadSchoolId() async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      final response = await apiService.get('/management-admin/schools/current/');
      
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map) {
          final schoolData = data['data'] ?? data;
          if (schoolData is Map) {
            final schoolId = schoolData['school_id']?.toString() ?? 
                           schoolData['id']?.toString();
            if (schoolId != null && mounted) {
              setState(() {
                _schoolIdController.text = schoolId;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error loading school ID: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _schoolIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createCredentials() async {
    print('=== Create Credentials Started ===');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      print('Passwords do not match');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    print('Creating financial user...');

    try {
      final apiService = ApiService();
      await apiService.initialize();

      final requestBody = {
        'email': _emailController.text.trim(),
        if (_schoolIdController.text.trim().isNotEmpty) 'school_id': _schoolIdController.text.trim(),
        'password': _passwordController.text,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        if (_dateOfBirth != null) 'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
        if (_selectedGender != null) 'gender': _selectedGender,
      };
      
      print('Request body: $requestBody');

      final response = await apiService.post(
        '/auth/create-financial-user/',
        body: requestBody,
      );

      print('Response success: ${response.success}');
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('Response error: ${response.error}');

      if (mounted) {
        if (response.success) {
          // Close dialog first
          Navigator.of(context).pop(true);
          // Then show success message using root context
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Financial details created successfully!'),
              backgroundColor: Color(0xFF667EEA),
            ),
          );
        } else {
          
          // Parse specific error message if available
          String errorMessage = response.error ?? 'Failed to create details';
          try {
            if (response.data != null && response.data is Map) {
               final data = response.data as Map;
               if (data.containsKey('message')) {
                 errorMessage = data['message'];
               } else if (data.containsKey('errors')) {
                 errorMessage = data['errors'].toString();
               }
            }
          } catch (_) {}

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error creating financial user: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
        print('=== Create Credentials Finished ===');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Financial Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Enter complete profile details for financial staff',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _schoolIdController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'School ID',
                    hintText: 'Auto-filled from your school',
                    prefixIcon: const Icon(Icons.school_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                
                // Address Field
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter address',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                
                // Date of Birth Field
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF667EEA),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _dateOfBirth = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select date of birth',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF667EEA),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                          : 'Select date',
                      style: TextStyle(
                        color: _dateOfBirth != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    hintText: 'Select gender',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  // Gender is optional - no validator
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF667EEA),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createCredentials,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isCreating
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
