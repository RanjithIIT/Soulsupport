import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:main_login/main.dart' as main_login;
import 'main.dart' as app;
import 'dashboard.dart';
import 'package:core/api/api_service.dart';
import 'package:core/api/endpoints.dart';
import 'widgets/school_profile_header.dart';

enum FeeStatus { paid, pending, overdue }

class PaymentHistoryRecord {
  final int id;
  final double paymentAmount;
  final DateTime paymentDate;
  final String receiptNumber;
  final String notes;
  final DateTime? createdAt;

  PaymentHistoryRecord({
    required this.id,
    required this.paymentAmount,
    required this.paymentDate,
    required this.receiptNumber,
    required this.notes,
    this.createdAt,
  });
}

class FeeRecord {
  final int id;
  final String? studentId; // UUID string for student
  final String studentName;
  final String applyingClass;
  final String feeType;
  final String grade;
  final double totalAmount;
  final String frequency;
  final DateTime dueDate;
  final double lateFee;
  final String description;
  FeeStatus status;
  double paidAmount;
  double dueAmount;
  DateTime? lastPaidDate;
  List<PaymentHistoryRecord> paymentHistory;
  DateTime? createdAt;
  DateTime? updatedAt;

  FeeRecord({
    required this.id,
    this.studentId,
    required this.studentName,
    required this.applyingClass,
    required this.feeType,
    required this.grade,
    required this.totalAmount,
    required this.frequency,
    required this.dueDate,
    required this.lateFee,
    required this.description,
    required this.status,
    required this.paidAmount,
    required this.dueAmount,
    this.lastPaidDate,
    required this.paymentHistory,
    this.createdAt,
    this.updatedAt,
  });

  String get typeLabel => feeType.replaceAll('-', ' ').toUpperCase();
  String get classLabel => applyingClass.replaceAll('-', ' ').toUpperCase();
  String get gradeLabel => grade.replaceAll('-', ' ').toUpperCase();
  String get frequencyLabel => frequency.replaceAll('-', ' ').toUpperCase();
}

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  List<FeeRecord> _allFees = [];
  late List<FeeRecord> _visibleFees;
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isSubmitting = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _classController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _newFeeType;
  String? _newFrequency;
  String? _selectedGrade;
  DateTime? _newDueDate;
  
  String? _selectedStudentIdForFilter; // For filtering displayed fees
  String? _studentEmail; // Store student email for POST request

  String _searchQuery = '';
  String _studentIdSearchQuery = '';
  String? _statusFilter;
  String? _classFilter;
  String? _feeTypeFilter;
  // -- Helper Widgets --

  Widget _buildUserInfo() {
    return SchoolProfileHeader(apiService: ApiService());
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C757D), Color(0xFF495057)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF495057).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.arrow_back, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Back to Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    _visibleFees = List<FeeRecord>.from(_allFees);
    // Load fees immediately when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFees();
    });
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _classController.dispose();
    _totalAmountController.dispose();
    _lateFeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper method to clear all form fields completely
  void _clearForm() {
    if (!mounted) return;
    
    // Clear all text controllers first
    _studentIdController.text = '';
    _studentNameController.text = '';
    _classController.text = '';
    _totalAmountController.text = '';
    _lateFeeController.text = '';
    _descriptionController.text = '';
    
    // Reset form validation state
    _formKey.currentState?.reset();
    
    // Clear all state variables and force UI update
    setState(() {
      _selectedGrade = null;
      _studentEmail = null;
      _newFeeType = null;
      _newFrequency = null;
      _newDueDate = null;
      _selectedStudentIdForFilter = null;
    });
    
    // Ensure controllers are cleared (in case setState didn't trigger properly)
    Future.microtask(() {
      if (mounted) {
        _studentIdController.clear();
        _studentNameController.clear();
        _classController.clear();
        _totalAmountController.clear();
        _lateFeeController.clear();
        _descriptionController.clear();
        setState(() {}); // Force another rebuild to ensure UI reflects cleared state
      }
    });
  }

  // Fetch admission fees and student info by student_id
  Future<void> _fetchStudentInfoByStudentId(String studentId) async {
    try {
      // Try to find in NewAdmission first (by student_id field)
      final admissionsResponse = await _apiService.get(
        '${Endpoints.admissions}?student_id=$studentId'
      );
      
      if (admissionsResponse.success && admissionsResponse.data != null) {
        dynamic data = admissionsResponse.data;
        List<dynamic> admissions = [];
        
        if (data is List) {
          admissions = data;
        } else if (data is Map && data['results'] != null) {
          admissions = data['results'] as List;
        }
        
        if (admissions.isNotEmpty) {
          final admission = admissions.first as Map<String, dynamic>;
          if (mounted) {
            setState(() {
            _studentNameController.text = admission['student_name'] ?? '';
            _classController.text = admission['applying_class'] ?? '';
            _selectedGrade = admission['grade'];
              _studentEmail = admission['email'];
            });
          }
          // Load fees for this student
          await _loadFeesByStudentId(studentId);
          return;
        }
      }
      
      // If not found in admissions, try Student table by UUID
      final studentsResponse = await _apiService.get(Endpoints.students);
      if (studentsResponse.success && studentsResponse.data != null) {
        dynamic data = studentsResponse.data;
        List<dynamic> students = [];
        
        if (data is List) {
          students = data;
        } else if (data is Map && data['results'] != null) {
          students = data['results'] as List;
        }
        
        // Find student by student_id (UUID)
        final student = students.firstWhere(
          (s) => s['student_id']?.toString() == studentId || 
                 s['id']?.toString() == studentId,
          orElse: () => null,
        );
        
        if (student != null && mounted) {
          setState(() {
            _studentNameController.text = student['student_name'] ?? '';
            _classController.text = student['applying_class'] ?? '';
            _studentEmail = student['email'];
          });
          // Load fees for this student
          await _loadFeesByStudentId(studentId);
        }
      }
    } catch (e) {
      print('Error fetching student info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching student information: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Load fees filtered by student_id
  Future<void> _loadFeesByStudentId(String? studentId) async {
    if (studentId == null || studentId.isEmpty) {
      // If no student ID, load all fees instead of filtering
      await _loadFees();
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedStudentIdForFilter = studentId;
    });

    try {
      // First, try to find the Student UUID by student_id
      String? studentUuid;
      
      // Try NewAdmission first
      final admissionsResponse = await _apiService.get(
        '${Endpoints.admissions}?student_id=$studentId'
      );
      
      if (admissionsResponse.success && admissionsResponse.data != null) {
        dynamic data = admissionsResponse.data;
        List<dynamic> admissions = [];
        
        if (data is List) {
          admissions = data;
        } else if (data is Map && data['results'] != null) {
          admissions = data['results'] as List;
        }
        
        if (admissions.isNotEmpty) {
          final admission = admissions.first as Map<String, dynamic>;
          // Try to get the created student's UUID
          if (admission['created_student'] != null) {
            studentUuid = admission['created_student']['student_id']?.toString();
          }
        }
      }
      
      // If not found, try Student table directly
      if (studentUuid == null) {
        final studentsResponse = await _apiService.get(Endpoints.students);
        if (studentsResponse.success && studentsResponse.data != null) {
          dynamic data = studentsResponse.data;
          List<dynamic> students = [];
          
          if (data is List) {
            students = data;
          } else if (data is Map && data['results'] != null) {
            students = data['results'] as List;
          }
          
          // Find by student_id field (UUID or string)
          final student = students.firstWhere(
            (s) => s['student_id']?.toString() == studentId || 
                   s['id']?.toString() == studentId,
            orElse: () => null,
          );
          
          if (student != null) {
            studentUuid = student['student_id']?.toString() ?? student['id']?.toString();
          }
        }
      }
      
      // If still not found, use the studentId as-is (might be UUID)
      studentUuid ??= studentId;
      
      // Filter fees by student UUID
      final response = await _apiService.get(
        '${Endpoints.fees}?student=$studentUuid'
      );

      if (response.success && response.data != null) {
        List<FeeRecord> fees = [];
        
        dynamic data = response.data;
        if (data is List) {
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final fee = _parseFeeFromJson(item);
              if (fee != null) {
                fees.add(fee);
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          if (data['results'] != null && data['results'] is List) {
            for (var item in data['results'] as List) {
              if (item is Map<String, dynamic>) {
                final fee = _parseFeeFromJson(item);
                if (fee != null) {
                  fees.add(fee);
                }
              }
            }
          }
        }

        setState(() {
          _allFees = fees;
          _filterFees();
        });
      }
    } catch (e) {
      print('Error loading fees by student ID: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // -- API Methods --
  
  Future<void> _loadFees() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('=== Loading ALL fees from: ${Endpoints.baseUrl}${Endpoints.fees} ===');
      
      // Ensure API service is initialized
      await _apiService.initialize();
      
      final response = await _apiService.get(Endpoints.fees);
      
      print('Response success: ${response.success}');
      print('Response status code: ${response.statusCode}');
      print('Response data type: ${response.data?.runtimeType ?? "null"}');
      
      if (response.data != null) {
        if (response.data is List) {
          print('Response data: List with ${(response.data as List).length} items');
        } else if (response.data is Map) {
          print('Response data: Map with keys: ${(response.data as Map).keys.toList()}');
        }
      } else {
        print('Response data is null');
      }
      
      if (response.error != null) {
        print('Response error: ${response.error}');
      }

      if (response.success && response.data != null) {
        List<FeeRecord> fees = [];
        
        // Handle different response formats
        dynamic data = response.data;
        
        // If response is a list, use it directly
        if (data is List) {
          print('✓ Data is a List with ${data.length} items');
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final fee = _parseFeeFromJson(item);
              if (fee != null) {
                fees.add(fee);
              } else {
                print('✗ Failed to parse fee from: $item');
              }
            }
          }
        }
        // If response is an object with a 'results' field (pagination)
        else if (data is Map<String, dynamic>) {
          print('✓ Data is a Map with keys: ${data.keys.toList()}');
          if (data['results'] != null && data['results'] is List) {
            print('✓ Found results list with ${(data['results'] as List).length} items');
            for (var item in data['results'] as List) {
              if (item is Map<String, dynamic>) {
                final fee = _parseFeeFromJson(item);
                if (fee != null) {
                  fees.add(fee);
                } else {
                  print('✗ Failed to parse fee from: $item');
                }
              }
            }
          }
          // If data itself is a list-like structure
          else if (data['data'] != null && data['data'] is List) {
            print('✓ Found data list with ${(data['data'] as List).length} items');
            for (var item in data['data'] as List) {
              if (item is Map<String, dynamic>) {
                final fee = _parseFeeFromJson(item);
                if (fee != null) {
                  fees.add(fee);
                } else {
                  print('✗ Failed to parse fee from: $item');
                }
              }
            }
          } else {
            print('✗ No recognized data structure found in response. Keys: ${data.keys.toList()}');
            // Try to parse the entire map as a single fee (unlikely but possible)
            final fee = _parseFeeFromJson(data);
            if (fee != null) {
              fees.add(fee);
            }
          }
        } else {
          print('✗ Unexpected data type: ${data.runtimeType}');
        }

        print('=== Successfully parsed ${fees.length} fees ===');
        
        if (mounted) {
          setState(() {
            _allFees = fees;
            _filterFees();
          });
          
          if (fees.isEmpty) {
            print('⚠ No fees found in database');
          }
        }
      } else {
        // Handle error
        print('✗ Failed to load fees. Error: ${response.error ?? "Unknown error"}');
        print('✗ Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load fees: ${response.error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('✗ Exception loading fees: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading fees: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  FeeRecord? _parseFeeFromJson(Map<String, dynamic> json) {
    try {
      print('Parsing fee JSON: $json');
      
      // Parse dates
      DateTime? dueDate;
      DateTime? createdAt;
      DateTime? updatedAt;
      
      if (json['due_date'] != null) {
        if (json['due_date'] is String) {
          dueDate = DateTime.tryParse(json['due_date']);
          dueDate ??= DateTime.tryParse('${json['due_date']}T00:00:00');
        } else if (json['due_date'] is DateTime) {
          dueDate = json['due_date'];
        }
      }
      
      if (json['created_at'] != null) {
        if (json['created_at'] is String) {
          createdAt = DateTime.tryParse(json['created_at']);
        } else if (json['created_at'] is DateTime) {
          createdAt = json['created_at'];
        }
      }
      
      if (json['updated_at'] != null) {
        if (json['updated_at'] is String) {
          updatedAt = DateTime.tryParse(json['updated_at']);
        } else if (json['updated_at'] is DateTime) {
          updatedAt = json['updated_at'];
        }
      }
      
      // Parse status
      FeeStatus status;
      final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';
      switch (statusStr) {
        case 'paid':
          status = FeeStatus.paid;
          break;
        case 'overdue':
          status = FeeStatus.overdue;
          break;
        default:
          status = FeeStatus.pending;
      }

      // Parse numeric fields - handle both String and numeric types
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          return double.tryParse(value) ?? 0.0;
        }
        return 0.0;
      }

      // Parse amounts from backend (backend calculates due_amount correctly)
      final totalAmt = parseDouble(json['total_amount']);
      final paidAmt = parseDouble(json['paid_amount']);
      
      // Parse payment history
      List<PaymentHistoryRecord> paymentHistory = [];
      if (json['payment_history'] != null && json['payment_history'] is List) {
        for (var item in json['payment_history'] as List) {
          if (item is Map<String, dynamic>) {
            DateTime? historyDate;
            if (item['payment_date'] != null) {
              if (item['payment_date'] is String) {
                historyDate = DateTime.tryParse(item['payment_date']);
                historyDate ??= DateTime.tryParse('${item['payment_date']}T00:00:00');
              } else if (item['payment_date'] is DateTime) {
                historyDate = item['payment_date'];
              }
            }
            
            if (historyDate != null) {
              // Parse created_at timestamp
              DateTime? createdAt;
              if (item['created_at'] != null) {
                if (item['created_at'] is String) {
                  createdAt = DateTime.tryParse(item['created_at']);
                } else if (item['created_at'] is DateTime) {
                  createdAt = item['created_at'];
                }
              }
              
              paymentHistory.add(PaymentHistoryRecord(
                id: item['id'] is int ? item['id'] : int.tryParse(item['id']?.toString() ?? '0') ?? 0,
                paymentAmount: parseDouble(item['payment_amount']),
                paymentDate: historyDate,
                receiptNumber: item['receipt_number']?.toString() ?? '',
                notes: item['notes']?.toString() ?? '',
                createdAt: createdAt,
              ));
            }
          }
        }
      }
      // Sort payment history by date (newest first)
      paymentHistory.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      
      // Parse last paid date
      DateTime? lastPaidDate;
      if (json['last_paid_date'] != null) {
        if (json['last_paid_date'] is String) {
          lastPaidDate = DateTime.tryParse(json['last_paid_date']);
          lastPaidDate ??= DateTime.tryParse('${json['last_paid_date']}T00:00:00');
        } else if (json['last_paid_date'] is DateTime) {
          lastPaidDate = json['last_paid_date'];
        }
      }
      
      final fee = FeeRecord(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        studentId: json['student_id']?.toString() ?? 
                   json['student']?.toString() ?? 
                   (json['student'] is Map ? json['student']['student_id']?.toString() : null) ?? '',
        studentName: json['student_name']?.toString() ?? 
                     (json['student'] is Map ? json['student']['student_name']?.toString() : null) ?? 
                     'Unknown Student',
        applyingClass: json['applying_class']?.toString() ?? 
                       (json['student'] is Map ? json['student']['applying_class']?.toString() : null) ?? 
                       '',
        feeType: json['fee_type']?.toString() ?? 'tuition',
        grade: json['grade']?.toString() ?? '',
        totalAmount: totalAmt,
        frequency: json['frequency']?.toString() ?? 'monthly',
        dueDate: dueDate ?? DateTime.now(),
        lateFee: parseDouble(json['late_fee']),
        description: json['description']?.toString() ?? '',
        status: status,
        paidAmount: paidAmt,
        dueAmount: parseDouble(json['due_amount']), // Always use the backend calculated value
        lastPaidDate: lastPaidDate,
        paymentHistory: paymentHistory,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      print('Successfully parsed fee: ${fee.studentName} - ${fee.feeType}');
      return fee;
    } catch (e, stackTrace) {
      print('Error parsing fee: $e');
      print('Stack trace: $stackTrace');
      print('JSON that failed: $json');
      return null;
    }
  }

  Map<String, dynamic> _feeToJson(FeeRecord fee) {
    return {
      if (fee.studentId != null) 'student': fee.studentId,
      'fee_type': fee.feeType,
      'grade': fee.grade,
      'total_amount': fee.totalAmount.toString(),
      'frequency': fee.frequency,
      'due_date': DateFormat('yyyy-MM-dd').format(fee.dueDate),
      'late_fee': fee.lateFee.toString(),
      'description': fee.description,
      'status': fee.status.name,
      'paid_amount': fee.paidAmount.toString(),
      if (fee.lastPaidDate != null)
        'last_paid_date': DateFormat('yyyy-MM-dd').format(fee.lastPaidDate!),
    };
  }

  void _filterFees() {
    setState(() {
      _visibleFees = _allFees.where((fee) {
        // Search by name, fee type, or student ID
        final matchesSearch = _searchQuery.isEmpty ||
            fee.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fee.feeType.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Search by student ID specifically
        final matchesStudentId = _studentIdSearchQuery.isEmpty ||
            (fee.studentId != null && fee.studentId!.toLowerCase().contains(_studentIdSearchQuery.toLowerCase()));
        
        // Status filter
        final matchesStatus =
            _statusFilter == null || fee.status.name == _statusFilter;
        
        // Class filter - normalize comparison (handle "Class 2", "class-2", "class 2", etc.)
        final matchesClass = _classFilter == null || (() {
          if (_classFilter == null) return true;
          // Extract class number from filter (e.g., "class-2" -> "2")
          final filterClassNum = _classFilter!.replaceAll('class-', '').replaceAll('Class ', '').trim();
          // Normalize applyingClass for comparison
          final feeClass = fee.applyingClass.toLowerCase()
              .replaceAll('class ', '')
              .replaceAll('class-', '')
              .replaceAll('-', '')
              .trim();
          return feeClass == filterClassNum || fee.applyingClass.toLowerCase().contains(filterClassNum);
        })();
        
        // Fee type filter
        final matchesFeeType = _feeTypeFilter == null ||
            fee.feeType.toLowerCase() == _feeTypeFilter!.toLowerCase();
        
        return matchesSearch && matchesStudentId && matchesStatus && matchesClass && matchesFeeType;
      }).toList();
    });
  }

  Map<String, double> _stats() {
    final total = _allFees.fold<double>(0, (sum, fee) => sum + fee.totalAmount);
    final paid = _allFees.fold<double>(0, (sum, fee) => sum + fee.paidAmount);
    final pending = total - paid;
    final collection =
        total == 0 ? 0.0 : double.parse(((paid / total) * 100).toStringAsFixed(0));
    return {
      'total': total,
      'paid': paid,
      'pending': pending,
      'collection': collection,
    };
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _newDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _newDueDate = date;
      });
    }
  }

  Future<void> _addFee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newFeeType == null ||
        _newFrequency == null ||
        _newDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate student_id
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student ID')),
      );
      return;
    }

    // Find the Student email (primary key) and fetch grade
    String? studentEmail;
    String? gradeFromAdmission;
    
    // Use stored email if available
    if (_studentEmail != null && _studentEmail!.isNotEmpty) {
      studentEmail = _studentEmail;
    } else {
      // Try to find Student by student_id
      try {
        final studentsResponse = await _apiService.get(Endpoints.students);
        if (studentsResponse.success && studentsResponse.data != null) {
          dynamic data = studentsResponse.data;
          List<dynamic> students = [];
          
          if (data is List) {
            students = data;
          } else if (data is Map && data['results'] != null) {
            students = data['results'] as List;
          }
          
          // Find student by student_id
          final student = students.firstWhere(
            (s) => s['student_id']?.toString() == studentId,
            orElse: () => null,
          );
          
          if (student != null) {
            studentEmail = student['email']?.toString();
            // If grade is empty in form, try to get from student
            if ((_selectedGrade == null || _selectedGrade!.isEmpty) && student['grade'] != null) {
              gradeFromAdmission = student['grade']?.toString();
            }
          }
        }
      } catch (e) {
        print('Error finding student: $e');
      }
      
      // If not found, try to get from admission
      if (studentEmail == null || studentEmail.isEmpty) {
        try {
          final admissionsResponse = await _apiService.get(
            '${Endpoints.admissions}?student_id=$studentId'
          );
          
          if (admissionsResponse.success && admissionsResponse.data != null) {
            dynamic data = admissionsResponse.data;
            List<dynamic> admissions = [];
            
            if (data is List) {
              admissions = data;
            } else if (data is Map && data['results'] != null) {
              admissions = data['results'] as List;
            }
            
            if (admissions.isNotEmpty) {
              final admission = admissions.first as Map<String, dynamic>;
              // Get grade from admission if not already set
              if ((_selectedGrade == null || _selectedGrade!.isEmpty) && admission['grade'] != null) {
                gradeFromAdmission = admission['grade']?.toString();
              }
              studentEmail = admission['email']?.toString();
            }
          }
        } catch (e) {
          print('Error finding student from admission: $e');
        }
      }
    }
    
    // Validate that we have student email
    if (studentEmail == null || studentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find student. Please ensure the student ID is correct.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Update grade dropdown if grade was found and form field is empty
    if (gradeFromAdmission != null && gradeFromAdmission.isNotEmpty && (_selectedGrade == null || _selectedGrade!.isEmpty)) {
      setState(() {
        _selectedGrade = gradeFromAdmission;
      });
    }

    // Check if student already has ANY fee of the same type (not just paid)
    FeeRecord? existingFee;
    try {
      existingFee = _allFees.firstWhere(
        (fee) => fee.studentId == studentId && 
                 fee.feeType.toLowerCase() == _newFeeType!.toLowerCase(),
      );
    } catch (e) {
      // No existing fee found, which is fine
      existingFee = null;
    }
    
    if (existingFee != null) {
      // Show warning dialog with existing fee details
      final feeTypeLabel = _newFeeType!.replaceAll('-', ' ').toUpperCase();
      final fee = existingFee; // Local variable for null safety
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Existing ${fee.typeLabel} Fee Found'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This student already has a $feeTypeLabel fee.\n',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Student: ${fee.studentName}'),
                Text('Fee Type: ${fee.typeLabel}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Text(
                            '₹${fee.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid:'),
                          Text(
                            '₹${fee.paidAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: fee.paidAmount > 0 ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Due Amount:'),
                          Text(
                            '₹${fee.dueAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: fee.dueAmount > 0 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose an action:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('update'),
              child: const Text('Update Fee'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('add'),
              child: const Text('Add New'),
            ),
          ],
        ),
      );
      
      if (action == null || action.isEmpty) {
        // User cancelled - clear all form fields completely
        if (mounted) {
          _clearForm();
        }
        return; // User cancelled
      }
      
      // If user chose to update existing fee
      if (action == 'update') {
        final newAmount = double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
        final currentTotal = existingFee.totalAmount;
        final updatedTotal = currentTotal + newAmount;
        
        // Update existing fee
        final updateData = {
          'total_amount': updatedTotal.toString(),
          'due_date': DateFormat('yyyy-MM-dd').format(_newDueDate!),
          'late_fee': (_lateFeeController.text.trim().isEmpty) ? '0' : _lateFeeController.text.trim(),
          'description': _descriptionController.text.trim(),
        };
        
        setState(() {
          _isSubmitting = true;
        });
        
        try {
          final updateResponse = await _apiService.patch(
            '${Endpoints.fees}${existingFee.id}/',
            body: updateData,
          );
          
          if (updateResponse.success && updateResponse.data != null) {
            final updatedFee = _parseFeeFromJson(updateResponse.data);
            if (updatedFee != null) {
              final feeId = existingFee.id;
              setState(() {
                final index = _allFees.indexWhere((f) => f.id == feeId);
                if (index != -1) {
                  _allFees[index] = updatedFee;
                } else {
                  _allFees.add(updatedFee);
                }
                _filterFees();
              });
              
              await _loadFees();
              _clearForm();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fee updated successfully! New total: ₹${updatedTotal.toStringAsFixed(2)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } else {
            throw Exception(updateResponse.error ?? 'Failed to update fee');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating fee: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
        }
        return; // Exit after updating
      }
      // If user chose 'add', continue to create new fee below
    }
    
    // Prepare fee data
    final totalAmountValue = _totalAmountController.text.trim();
    
    final feeData = {
      'student': studentEmail, // Student email (primary key) for ForeignKey
      'fee_type': _newFeeType!,
      'grade': _selectedGrade ?? '',
      'total_amount': totalAmountValue,
      'frequency': _newFrequency!,
      'due_date': DateFormat('yyyy-MM-dd').format(_newDueDate!),
      'late_fee': (_lateFeeController.text.trim().isEmpty) ? '0' : _lateFeeController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': 'pending',
      'paid_amount': '0',
    };
    
    print('Submitting fee data: $feeData');

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API to create fee
      // Note: Student lookup by name should be handled on backend or we need student ID
      final response = await _apiService.post(
        Endpoints.fees,
        body: feeData,
      );

      if (response.success && response.data != null) {
        // Parse the created fee from response
        final createdFee = _parseFeeFromJson(response.data);
        
        if (createdFee != null) {
          setState(() {
            _allFees.insert(0, createdFee);
            _filterFees();
          });

          // Reload fees for this student after adding
          await _loadFeesByStudentId(studentId);
          
          // Clear form using helper method
          _clearForm();
          
          // Reload all fees after adding
          await _loadFees();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fee added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to parse created fee');
        }
      } else {
        throw Exception(response.error ?? 'Failed to create fee');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding fee: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _markAsPaid(FeeRecord fee) async {
    // Default to remaining due amount, or total amount if nothing paid yet
    final defaultAmount = fee.dueAmount > 0 ? fee.dueAmount : fee.totalAmount;
    final controller = TextEditingController(text: defaultAmount.toStringAsFixed(0));
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now())
    );
    final receiptController = TextEditingController();
    
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment for ${fee.studentName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (₹)',
                  hintText: 'Enter amount to pay',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateController.text),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: receiptController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number',
                  hintText: 'Enter receipt number',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final paymentAmount = double.tryParse(controller.text);
              if (paymentAmount == null || paymentAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid payment amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (paymentAmount > fee.dueAmount && fee.dueAmount > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment amount (₹${paymentAmount.toStringAsFixed(2)}) cannot exceed due amount (₹${fee.dueAmount.toStringAsFixed(2)})'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Show loading
              setState(() {
                _isLoading = true;
              });
              
              try {
                // Record payment via API
                final paymentUrl = '${Endpoints.fees}${fee.id}/record-payment/';
                print('Recording payment to: $paymentUrl');
                print('Payment amount: $paymentAmount');
                print('Payment date: ${dateController.text}');
                
                final response = await _apiService.post(
                  paymentUrl,
                  body: {
                    'payment_amount': paymentAmount.toString(),
                    'payment_date': dateController.text,
                    'receipt_number': receiptController.text.trim(),
                    'notes': '',
                  },
                );
                
                print('Payment response success: ${response.success}');
                print('Payment response status: ${response.statusCode}');
                print('Payment response data type: ${response.data?.runtimeType}');
                if (response.data != null) {
                  print('Payment response data: ${response.data}');
                  if (response.data is Map) {
                    final dataMap = response.data as Map;
                    print('Payment response - paid_amount: ${dataMap['paid_amount']}');
                    print('Payment response - due_amount: ${dataMap['due_amount']}');
                    print('Payment response - payment_history: ${dataMap['payment_history']}');
                    if (dataMap['payment_history'] != null) {
                      print('Payment history count: ${(dataMap['payment_history'] as List).length}');
                    }
                  }
                }
                print('Payment response error: ${response.error}');
                
                if (response.success) {
                  // Parse the updated fee from response if available
                  if (response.data != null) {
                    print('=== Parsing updated fee from response ===');
                    if (response.data is Map) {
                      final dataMap = response.data as Map;
                      print('Response data - paid_amount: ${dataMap['paid_amount']} (type: ${dataMap['paid_amount']?.runtimeType})');
                      print('Response data - due_amount: ${dataMap['due_amount']} (type: ${dataMap['due_amount']?.runtimeType})');
                      print('Response data - last_paid_date: ${dataMap['last_paid_date']}');
                    }
                    
                    final updatedFee = _parseFeeFromJson(response.data);
                    if (updatedFee != null) {
                      print('Updated fee parsed successfully:');
                      print('  - paid_amount: ${updatedFee.paidAmount}');
                      print('  - due_amount: ${updatedFee.dueAmount}');
                      print('  - last_paid_date: ${updatedFee.lastPaidDate}');
                      print('  - payment_history_count: ${updatedFee.paymentHistory.length}');
                      if (updatedFee.paymentHistory.isNotEmpty) {
                        print('  - First payment: ₹${updatedFee.paymentHistory.first.paymentAmount} on ${updatedFee.paymentHistory.first.paymentDate}');
                      }
                      
                      // Update the fee in the list immediately
                      final index = _allFees.indexWhere((f) => f.id == fee.id);
                      if (index != -1) {
                        print('Updating fee at index $index');
                        setState(() {
                          _allFees[index] = updatedFee;
                          _filterFees();
                          print('Fee updated in list at index $index');
                          print('  - paid_amount: ${_allFees[index].paidAmount}');
                          print('  - due_amount: ${_allFees[index].dueAmount}');
                          print('  - last_paid_date: ${_allFees[index].lastPaidDate}');
                          print('  - payment_history: ${_allFees[index].paymentHistory.length} items');
                        });
                      } else {
                        print('Fee not found in list, adding it');
                        setState(() {
                          _allFees.add(updatedFee);
                          _filterFees();
                        });
                      }
                      
                      // Force multiple rebuilds to ensure UI updates
                      if (mounted) {
                        setState(() {});
                        // Additional rebuild after a short delay
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      }
                    } else {
                      print('Failed to parse updated fee from response, reloading all fees');
                      // Reload fees if parsing failed
                      await _loadFees();
                    }
                  } else {
                    print('Response data is null, reloading all fees');
                    // Reload fees to get updated data with payment history
                    await _loadFees();
                  }
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of ₹${paymentAmount.toStringAsFixed(2)} recorded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to record payment: ${response.error ?? "Unknown error"}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e, stackTrace) {
                print('Exception recording payment: $e');
                print('Stack trace: $stackTrace');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error recording payment: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Record Payment'),
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
    final stats = _stats();

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1100;
        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  child: SizedBox(
                    width: 280,
                    child: _Sidebar(gradient: gradient),
                  ),
                ),
          body: Row(
            children: [
              if (showSidebar) _Sidebar(gradient: gradient),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F6FA),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- TOP HEADER ---
                          GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                            margin: const EdgeInsets.only(bottom: 30),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Fees Management',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                _buildUserInfo(),
                                const SizedBox(width: 20),
                                _buildBackButton(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _StatsOverview(stats: stats),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, inner) {
                              final stacked = inner.maxWidth < 1100;
                              return Flex(
                                mainAxisSize: MainAxisSize.min,
                                direction:
                                    stacked ? Axis.vertical : Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _AddFeeSection(
                                      formKey: _formKey,
                                      studentIdController: _studentIdController,
                                      studentNameController: _studentNameController,
                                      classController: _classController,
                                      selectedGrade: _selectedGrade,
                                      onGradeChanged: (value) => setState(() => _selectedGrade = value),
                                      totalAmountController: _totalAmountController,
                                      lateFeeController: _lateFeeController,
                                      descriptionController: _descriptionController,
                                      onStudentIdChanged: () async {
                                        final studentId = _studentIdController.text.trim();
                                        if (studentId.isNotEmpty) {
                                          await _fetchStudentInfoByStudentId(studentId);
                                        }
                                      },
                                      feeType: _newFeeType,
                                      onFeeTypeChanged: (value) =>
                                          setState(() => _newFeeType = value),
                                      frequency: _newFrequency,
                                      onFrequencyChanged: (value) =>
                                          setState(() => _newFrequency = value),
                                      dueDate: _newDueDate,
                                      onPickDueDate: _pickDueDate,
                                      onSubmit: _addFee,
                                      isSubmitting: _isSubmitting,
                                    ),
                                  ),
                                  SizedBox(
                                    width: stacked ? 0 : 24,
                                    height: stacked ? 24 : 0,
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _SearchFilterSection(
                                      searchQuery: _searchQuery,
                                      onSearchChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                        _filterFees();
                                      },
                                      studentIdSearchQuery: _studentIdSearchQuery,
                                      onStudentIdSearchChanged: (value) {
                                        setState(() {
                                          _studentIdSearchQuery = value;
                                        });
                                        _filterFees();
                                      },
                                      feeTypeFilter: _feeTypeFilter,
                                      onFeeTypeChanged: (value) {
                                        setState(() {
                                          _feeTypeFilter = value;
                                        });
                                        _filterFees();
                                      },
                                      statusFilter: _statusFilter,
                                      onStatusChanged: (value) {
                                        setState(() {
                                          _statusFilter = value;
                                        });
                                        _filterFees();
                                      },
                                      classFilter: _classFilter,
                                      onClassChanged: (value) {
                                        setState(() {
                                          _classFilter = value;
                                        });
                                        _filterFees();
                                      },
                                      fees: _visibleFees,
                                      onMarkPaid: _markAsPaid,
                                      onFeeUpdated: (updatedFeeData) {
                                        print('=== Parent onFeeUpdated callback called ===');
                                        print('Updated fee data received: $updatedFeeData');
                                        
                                        final updatedFee = _parseFeeFromJson(updatedFeeData);
                                        if (updatedFee != null) {
                                          print('Parent updating fee:');
                                          print('  - Fee ID: ${updatedFee.id}');
                                          print('  - Paid Amount: ${updatedFee.paidAmount}');
                                          print('  - Due Amount: ${updatedFee.dueAmount}');
                                          print('  - Payment History Count: ${updatedFee.paymentHistory.length}');
                                          
                                          setState(() {
                                            final index = _allFees.indexWhere((f) => f.id == updatedFee.id);
                                            if (index != -1) {
                                              print('Updating fee at index $index');
                                              print('  - Old paidAmount: ${_allFees[index].paidAmount}');
                                              print('  - Old dueAmount: ${_allFees[index].dueAmount}');
                                              _allFees[index] = updatedFee;
                                              print('  - New paidAmount: ${_allFees[index].paidAmount}');
                                              print('  - New dueAmount: ${_allFees[index].dueAmount}');
                                              _filterFees();
                                            } else {
                                              print('Fee not found in list, adding it');
                                              _allFees.add(updatedFee);
                                              _filterFees();
                                            }
                                          });
                                          
                                          // Force multiple rebuilds to ensure UI updates
                                          Future.microtask(() {
                                            if (mounted) {
                                              setState(() {
                                                print('Force rebuild triggered');
                                              });
                                            }
                                          });
                                          
                                          // Additional rebuild after a short delay
                                          Future.delayed(const Duration(milliseconds: 100), () {
                                            if (mounted) {
                                              setState(() {
                                                print('Delayed rebuild triggered');
                                              });
                                            }
                                          });
                                        } else {
                                          print('Failed to parse updated fee from parent callback');
                                          print('Raw data: $updatedFeeData');
                                        }
                                      },
                                      isLoading: _isLoading,
                                    ),
                                  ),
                                ],
                              );
                            },
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
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final LinearGradient gradient;

  const _Sidebar({required this.gradient});

  // Safe navigation helper for sidebar
  void _navigateToRoute(BuildContext context, String route) {
    final navigator = app.SchoolManagementApp.navigatorKey.currentState;
    if (navigator != null) {
      if (navigator.canPop() || route != '/dashboard') {
        navigator.pushReplacementNamed(route);
      } else {
        navigator.pushNamed(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    isActive: false,
                    onTap: () => _navigateToRoute(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () => _navigateToRoute(context, '/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () => _navigateToRoute(context, '/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () => _navigateToRoute(context, '/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    onTap: () => _navigateToRoute(context, '/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    onTap: () => _navigateToRoute(context, '/events'),
                  ),
                  _NavItem(
                    icon: '📆',
                    title: 'Calendar',
                    onTap: () => _navigateToRoute(context, '/calendar'),
                  ),
                  _NavItem(
                    icon: '🔔',
                    title: 'Notifications',
                    onTap: () => _navigateToRoute(context, '/notifications'),
                  ),
                  _NavItem(
                    icon: '🛣️',
                    title: 'Bus Routes',
                    onTap: () => _navigateToRoute(context, '/bus-routes'),
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

class _StatsOverview extends StatelessWidget {
  final Map<String, double> stats;

  const _StatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.35,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _StatCard(
            label: 'Total Fees',
            value: formatter.format(stats['total']),
            icon: '💰',
            color: const Color(0xFF667EEA),
          ),
          _StatCard(
            label: 'Paid',
            value: formatter.format(stats['paid']),
            icon: '✅',
            color: Colors.green,
          ),
          _StatCard(
            label: 'Pending',
            value: formatter.format(stats['pending']),
            icon: '⏳',
            color: Colors.orange,
          ),
          _StatCard(
            label: 'Collection Rate',
            value: '${stats['collection']!.toStringAsFixed(0)}%',
            icon: '📊',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 40, color: color)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFeeSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController studentIdController;
  final TextEditingController studentNameController;
  final TextEditingController classController;
  final String? selectedGrade;
  final ValueChanged<String?> onGradeChanged;
  final TextEditingController totalAmountController;
  final TextEditingController lateFeeController;
  final TextEditingController descriptionController;
  final VoidCallback onStudentIdChanged;
  final String? feeType;
  final ValueChanged<String?> onFeeTypeChanged;
  final String? frequency;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? dueDate;
  final VoidCallback onPickDueDate;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  const _AddFeeSection({
    required this.formKey,
    required this.studentIdController,
    required this.studentNameController,
    required this.classController,
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.totalAmountController,
    required this.lateFeeController,
    required this.descriptionController,
    required this.onStudentIdChanged,
    required this.feeType,
    required this.onFeeTypeChanged,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.dueDate,
    required this.onPickDueDate,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Text('➕', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text(
                  'Add Fee Structure',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.badge),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: onStudentIdChanged,
                      ),
                    ),
                    onChanged: (value) {
                      // Auto-fetch when student ID is entered
                      if (value.trim().isNotEmpty) {
                        onStudentIdChanged();
                      }
                    },
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter student ID' : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: studentNameController,
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    readOnly: true,
                    enabled: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: classController,
                    decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.class_),
                    ),
                    readOnly: true,
                    enabled: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: selectedGrade,
              decoration: InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.grade),
              ),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('A')),
                DropdownMenuItem(value: 'B', child: Text('B')),
                DropdownMenuItem(value: 'C', child: Text('C')),
                DropdownMenuItem(value: 'D', child: Text('D')),
              ],
              onChanged: onGradeChanged,
              validator: (value) =>
                  value == null ? 'Please select grade' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: feeType,
                    decoration: InputDecoration(
                      labelText: 'Fee Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tuition', child: Text('Tuition')),
                      DropdownMenuItem(value: 'transport', child: Text('Transport')),
                      DropdownMenuItem(value: 'library', child: Text('Library')),
                      DropdownMenuItem(value: 'laboratory', child: Text('Laboratory')),
                      DropdownMenuItem(value: 'sports', child: Text('Sports')),
                      DropdownMenuItem(value: 'examination', child: Text('Examination')),
                      DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
                      DropdownMenuItem(value: 'uniform', child: Text('Uniform')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: onFeeTypeChanged,
                    validator: (value) =>
                        value == null ? 'Please select fee type' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: totalAmountController,
                    decoration: InputDecoration(
                      labelText: 'Total Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter total amount' : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                      DropdownMenuItem(value: 'half-yearly', child: Text('Half Yearly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      DropdownMenuItem(value: 'one-time', child: Text('One Time')),
                    ],
                    onChanged: onFrequencyChanged,
                    validator: (value) =>
                        value == null ? 'Please select frequency' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onPickDueDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dueDate == null
                            ? 'Select date'
                            : DateFormat('yyyy-MM-dd').format(dueDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: lateFeeController,
                    decoration: InputDecoration(
                      labelText: 'Late Fee (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add Fee Structure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String studentIdSearchQuery;
  final ValueChanged<String> onStudentIdSearchChanged;
  final String? statusFilter;
  final ValueChanged<String?> onStatusChanged;
  final String? classFilter;
  final ValueChanged<String?> onClassChanged;
  final String? feeTypeFilter;
  final ValueChanged<String?> onFeeTypeChanged;
  final List<FeeRecord> fees;
  final ValueChanged<FeeRecord> onMarkPaid;
  final Function(Map<String, dynamic>) onFeeUpdated;
  final bool isLoading;

  const _SearchFilterSection({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.studentIdSearchQuery,
    required this.onStudentIdSearchChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.classFilter,
    required this.onClassChanged,
    required this.feeTypeFilter,
    required this.onFeeTypeChanged,
    required this.fees,
    required this.onMarkPaid,
    required this.onFeeUpdated,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Text('🔍', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Search & Filter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: searchQuery)
                    ..selection = TextSelection.collapsed(offset: searchQuery.length),
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by name or fee type...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: studentIdSearchQuery)
                    ..selection = TextSelection.collapsed(offset: studentIdSearchQuery.length),
                  onChanged: onStudentIdSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by Student ID...',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: feeTypeFilter,
                  decoration: InputDecoration(
                    labelText: 'Fee Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Fee Types')),
                    DropdownMenuItem(value: 'tuition', child: Text('Tuition')),
                    DropdownMenuItem(value: 'transport', child: Text('Transport')),
                    DropdownMenuItem(value: 'laboratory', child: Text('Laboratory')),
                    DropdownMenuItem(value: 'examination', child: Text('Examination')),
                    DropdownMenuItem(value: 'library', child: Text('Library')),
                    DropdownMenuItem(value: 'sports', child: Text('Sports')),
                    DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
                    DropdownMenuItem(value: 'uniform', child: Text('Uniform')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: onFeeTypeChanged,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: classFilter,
                  decoration: InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes')),
                    ...List.generate(12, (i) => i + 1).map((i) {
                      return DropdownMenuItem(
                        value: 'class-$i',
                        child: Text('Class $i'),
                      );
                    }),
                  ],
                  onChanged: onClassChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (fees.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No fees found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive card width: calculate based on screen size
                final width = constraints.maxWidth;
                final cardWidth = width > 1400
                    ? (width - 60) / 4  // 4 columns with spacing
                    : width > 1000
                        ? (width - 50) / 3  // 3 columns with spacing
                        : width > 600
                            ? (width - 40) / 2  // 2 columns with spacing
                            : width - 32;  // 1 column with padding
                
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: fees.map((fee) => SizedBox(
                    width: cardWidth,
                    child: _FeeCard(
                      fee: fee,
                      onMarkPaid: () => onMarkPaid(fee),
                      onFeeUpdated: onFeeUpdated,
                    ),
                  )).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FeeCard extends StatefulWidget {
  final FeeRecord fee;
  final VoidCallback onMarkPaid;
  final Function(Map<String, dynamic>) onFeeUpdated;

  const _FeeCard({
    required this.fee,
    required this.onMarkPaid,
    required this.onFeeUpdated,
  });

  @override
  State<_FeeCard> createState() => _FeeCardState();
}

class _FeeCardState extends State<_FeeCard> {
  late FeeRecord fee;
  
  // Helper function to parse fee from JSON (needed for _editPayment)
  FeeRecord? _parseFeeFromJson(Map<String, dynamic> json) {
    try {
      // Parse dates
      DateTime? dueDate;
      if (json['due_date'] != null) {
        dueDate = DateTime.tryParse(json['due_date']);
        dueDate ??= DateTime.tryParse('${json['due_date']}T00:00:00');
      }
      
      DateTime? lastPaidDate;
      if (json['last_paid_date'] != null) {
        lastPaidDate = DateTime.tryParse(json['last_paid_date']);
      }
      
      DateTime? createdAt;
      if (json['created_at'] != null) {
        final createdStr = json['created_at'];
        if (createdStr is String) {
          createdAt = DateTime.tryParse(createdStr);
        }
      }
      
      DateTime? updatedAt;
      if (json['updated_at'] != null) {
        final updatedStr = json['updated_at'];
        if (updatedStr is String) {
          updatedAt = DateTime.tryParse(updatedStr);
        }
      }
      
      // Parse payment history
      List<PaymentHistoryRecord> paymentHistory = [];
      if (json['payment_history'] != null && json['payment_history'] is List) {
        for (var paymentJson in json['payment_history'] as List) {
          if (paymentJson is Map<String, dynamic>) {
            DateTime? paymentDate;
            if (paymentJson['payment_date'] != null) {
              paymentDate = DateTime.tryParse(paymentJson['payment_date']);
            }
            
            DateTime? paymentCreatedAt;
            if (paymentJson['created_at'] != null) {
              final createdStr = paymentJson['created_at'];
              if (createdStr is String) {
                paymentCreatedAt = DateTime.tryParse(createdStr);
              }
            }
            
            paymentHistory.add(PaymentHistoryRecord(
              id: paymentJson['id'] as int? ?? 0,
              paymentAmount: (paymentJson['payment_amount'] is num)
                  ? (paymentJson['payment_amount'] as num).toDouble()
                  : double.tryParse(paymentJson['payment_amount'].toString()) ?? 0.0,
              paymentDate: paymentDate ?? DateTime.now(),
              receiptNumber: paymentJson['receipt_number']?.toString() ?? '',
              notes: paymentJson['notes']?.toString() ?? '',
              createdAt: paymentCreatedAt,
            ));
          }
        }
      }
      
      // Parse status
      FeeStatus status = FeeStatus.pending;
      final statusStr = json['status']?.toString().toLowerCase() ?? '';
      if (statusStr == 'paid') {
        status = FeeStatus.paid;
      } else if (statusStr == 'overdue') {
        status = FeeStatus.overdue;
      }
      
      return FeeRecord(
        id: json['id'] as int? ?? 0,
        studentId: json['student_id']?.toString(),
        studentName: json['student_name']?.toString() ?? '',
        applyingClass: json['applying_class']?.toString() ?? '',
        feeType: json['fee_type']?.toString() ?? '',
        grade: json['grade']?.toString() ?? '',
        totalAmount: (json['total_amount'] is num)
            ? (json['total_amount'] as num).toDouble()
            : double.tryParse(json['total_amount'].toString()) ?? 0.0,
        frequency: json['frequency']?.toString() ?? '',
        dueDate: dueDate ?? DateTime.now(),
        lateFee: (json['late_fee'] is num)
            ? (json['late_fee'] as num).toDouble()
            : double.tryParse(json['late_fee'].toString()) ?? 0.0,
        description: json['description']?.toString() ?? '',
        status: status,
        paidAmount: (json['paid_amount'] is num)
            ? (json['paid_amount'] as num).toDouble()
            : double.tryParse(json['paid_amount'].toString()) ?? 0.0,
        dueAmount: (json['due_amount'] is num)
            ? (json['due_amount'] as num).toDouble()
            : double.tryParse(json['due_amount'].toString()) ?? 0.0,
        lastPaidDate: lastPaidDate,
        paymentHistory: paymentHistory,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing fee from JSON: $e');
      print('JSON: $json');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fee = widget.fee;
  }

  @override
  void didUpdateWidget(_FeeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always update local fee when widget.fee changes
    if (oldWidget.fee.id != widget.fee.id || 
        oldWidget.fee.paidAmount != widget.fee.paidAmount ||
        oldWidget.fee.dueAmount != widget.fee.dueAmount ||
        oldWidget.fee.paymentHistory.length != widget.fee.paymentHistory.length) {
      setState(() {
        fee = widget.fee;
      });
    }
  }

  Color _getStatusColor() {
    switch (fee.status) {
      case FeeStatus.paid:
        return Colors.green;
      case FeeStatus.pending:
        return Colors.orange;
      case FeeStatus.overdue:
        return Colors.red;
    }
  }

  String _getStatusLabel() {
    switch (fee.status) {
      case FeeStatus.paid:
        return 'PAID';
      case FeeStatus.pending:
        return 'PENDING';
      case FeeStatus.overdue:
        return 'OVERDUE';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _editPayment(PaymentHistoryRecord payment) async {
    final amountController = TextEditingController(text: payment.paymentAmount.toStringAsFixed(2));
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(payment.paymentDate)
    );
    final receiptController = TextEditingController(text: payment.receiptNumber);
    bool isUpdating = false;
    
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  enabled: !isUpdating,
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount (₹)',
                    hintText: 'Enter amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: isUpdating ? null : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: payment.paymentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(date);
                      setDialogState(() {});
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(dateController.text),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: receiptController,
                  enabled: !isUpdating,
                  decoration: const InputDecoration(
                    labelText: 'Receipt Number',
                    hintText: 'Enter receipt number',
                  ),
                ),
                if (isUpdating) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating ? null : () async {
                final newAmount = double.tryParse(amountController.text);
                if (newAmount == null || newAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid payment amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Show loading state
                setDialogState(() {
                  isUpdating = true;
                });
                
                try {
                  final updateUrl = '${Endpoints.fees}${fee.id}/payment-history/${payment.id}/';
                  print('Updating payment at: $updateUrl');
                  print('Payment amount: ${amountController.text}');
                  print('Payment date: ${dateController.text}');
                  print('Receipt number: ${receiptController.text.trim()}');
                  
                  final apiService = ApiService();
                  final response = await apiService.patch(
                    updateUrl,
                    body: {
                      'payment_amount': amountController.text,
                      'payment_date': dateController.text,
                      'receipt_number': receiptController.text.trim(),
                    },
                  );
                  
                  print('Update payment response success: ${response.success}');
                  print('Update payment response status: ${response.statusCode}');
                  print('Update payment response data: ${response.data}');
                  print('Update payment response error: ${response.error}');
                  
                  if (response.success && response.data != null) {
                    // Parse the updated fee
                    final updatedFeeData = response.data as Map<String, dynamic>;
                    
                    print('Parsed updated fee data:');
                    print('  - paid_amount: ${updatedFeeData['paid_amount']}');
                    print('  - due_amount: ${updatedFeeData['due_amount']}');
                    print('  - total_amount: ${updatedFeeData['total_amount']}');
                    
                    // Close dialog first
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    
                    // Call the callback to update the fee in parent
                    widget.onFeeUpdated(updatedFeeData);
                    
                    // Then update local fee state
                    final updatedFee = _parseFeeFromJson(updatedFeeData);
                    if (updatedFee != null) {
                      print('Updated fee parsed:');
                      print('  - paidAmount: ${updatedFee.paidAmount}');
                      print('  - dueAmount: ${updatedFee.dueAmount}');
                      print('  - totalAmount: ${updatedFee.totalAmount}');
                      print('  - paymentHistory count: ${updatedFee.paymentHistory.length}');
                      if (updatedFee.paymentHistory.isNotEmpty) {
                        print('  - First payment: ₹${updatedFee.paymentHistory.first.paymentAmount}');
                      }
                      
                      if (mounted) {
                        setState(() {
                          fee = updatedFee;
                          print('Local fee state updated in _FeeCardState');
                        });
                        
                        // Force additional rebuild
                        Future.microtask(() {
                          if (mounted) {
                            setState(() {
                              print('Additional rebuild in _FeeCardState');
                            });
                          }
                        });
                      }
                    } else {
                      print('Failed to parse updated fee in _FeeCardState');
                    }
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    throw Exception(response.error ?? 'Failed to update payment');
                  }
                } catch (e) {
                  print('Error updating payment: $e');
                  
                  // Hide loading state on error
                  setDialogState(() {
                    isUpdating = false;
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating payment: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final formatter = DateFormat('MMMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (fee.studentId != null && fee.studentId!.isNotEmpty)
                      Text(
                        'ID: ${fee.studentId}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Type:', fee.typeLabel),
                    const SizedBox(height: 4),
                    _buildInfoRow('Class:', fee.classLabel),
                    const SizedBox(height: 4),
                    _buildInfoRow('Grade:', fee.gradeLabel),
                    const SizedBox(height: 4),
                    _buildInfoRow('Frequency:', fee.frequencyLabel),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Due Date:', formatter.format(fee.dueDate)),
                    const SizedBox(height: 4),
                    _buildInfoRow('Late Fee:', '₹${fee.lateFee.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${fee.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fee.paidAmount > 0 ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Paid:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${fee.paidAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: fee.paidAmount > 0 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: fee.dueAmount > 0 ? Colors.orange.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due Amount:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${fee.dueAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: fee.dueAmount > 0 ? Colors.orange.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (fee.paymentHistory.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment History:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...fee.paymentHistory.map((payment) {
                    final dateFormatter = DateFormat('MMM dd, yyyy');
                    final displayDate = dateFormatter.format(payment.paymentDate);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayDate,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (payment.receiptNumber.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Receipt: ${payment.receiptNumber}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '₹${payment.paymentAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      color: Colors.blue,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _editPayment(payment),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (fee.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fee.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (fee.createdAt != null || fee.updatedAt != null) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (fee.createdAt != null)
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(fee.createdAt!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (fee.updatedAt != null)
                  Text(
                    'Updated: ${DateFormat('MMM dd, yyyy').format(fee.updatedAt!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (fee.status != FeeStatus.paid) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onMarkPaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Mark as Paid'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}



// Glass Container Widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool drawRightBorder;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.drawRightBorder = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final radius = drawRightBorder
        ? BorderRadius.zero
        : BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: radius,
              border: Border(
                right: drawRightBorder
                    ? BorderSide(color: Colors.white.withValues(alpha: 0.2))
                    : BorderSide.none,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
