import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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
  final _searchController = TextEditingController(); // Controller for search field

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
  
  // Missing State Variables
  bool _isLoadingSummary = false;
  String? _selectedStudentIdForView;
  Map<String, dynamic>? _studentFeeSummary;
  Set<int> _expandedFeeTypes = {};

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
        child: const material.flutter_material.Row(
          children: [
            Icon(Icons.arrow_back, size: 16, color: Colors.white),
            material.flutter_material.SizedBox(width: 8),
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
    _searchController.dispose();
    super.dispose();
  }

  // New method to load student fee summary - always fetches fresh data
  Future<void> _loadStudentFeeSummary(String studentId) async {
    // Clear old state first to ensure we don't show stale data
    setState(() {
      _isLoadingSummary = true;
      _selectedStudentIdForView = studentId;
      _studentFeeSummary = null; // Clear old data first
      _expandedFeeTypes = {}; // Clear old expanded states
    });

    try {
      // Always fetch fresh data with cache-busting timestamp to ensure latest data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _apiService.get(
        '${Endpoints.fees}student-summary/?student_id=$studentId&_t=$timestamp'
      );

      if (response.success && response.data != null) {
        final newSummary = response.data as Map<String, dynamic>;
        
        // Verify we have the data we need
        if (newSummary['fees_by_type'] != null && newSummary['student'] != null) {
          setState(() {
            _studentFeeSummary = newSummary;
            // Initialize expanded states for all fee types
            final feesByType = _studentFeeSummary!['fees_by_type'] as Map<String, dynamic>;
            feesByType.keys.forEach((feeType) {
              _expandedFeeTypes[feeType] = true; // All expanded by default
            });
          });
        } else {
          // Invalid data structure - clear summary silently
          setState(() {
            _studentFeeSummary = null;
          });
        }
      } else {
        // Clear summary on failure - no error message for search scenarios
        setState(() {
          _studentFeeSummary = null;
        });
      }
    } catch (e) {
      // Clear summary on error - no error message for search scenarios
      setState(() {
        _studentFeeSummary = null;
      });
      print('Error loading student fee summary: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }
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
    // Clear fields first
    if (mounted) {
      setState(() {
        _studentNameController.clear();
        _classController.clear();
        _selectedGrade = null;
        _studentEmail = null;
      });
    }
    
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
        
        // Find student by student_id (UUID or string)
        bool studentFound = false;
        for (var s in students) {
          if (s['student_id']?.toString().toUpperCase() == studentId.toUpperCase() || 
              s['id']?.toString() == studentId ||
              (s['student_id'] != null && s['student_id'].toString().contains(studentId))) {
            if (mounted) {
          setState(() {
                _studentNameController.text = s['student_name'] ?? '';
                _classController.text = s['applying_class'] ?? '';
                _selectedGrade = s['grade'];
                _studentEmail = s['email'];
          });
            }
            studentFound = true;
          // Load fees for this student
          await _loadFeesByStudentId(studentId);
            break;
          }
        }
        
        if (!studentFound && mounted) {
          // Student not found - fields already cleared above
          return;
        }
      } else {
        // No students found
        if (mounted) {
          return;
        }
      }
    } catch (e) {
      print('Error fetching student info: $e');
      if (mounted) {
        // Fields already cleared, just show error
        return;
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
          print('Γ£ô Data is a List with ${data.length} items');
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final fee = _parseFeeFromJson(item);
              if (fee != null) {
                fees.add(fee);
              } else {
                print('Γ£ù Failed to parse fee from: $item');
              }
            }
          }
        }
        // If response is an object with a 'results' field (pagination)
        else if (data is Map<String, dynamic>) {
          print('Γ£ô Data is a Map with keys: ${data.keys.toList()}');
          if (data['results'] != null && data['results'] is List) {
            print('Γ£ô Found results list with ${(data['results'] as List).length} items');
            for (var item in data['results'] as List) {
              if (item is Map<String, dynamic>) {
                final fee = _parseFeeFromJson(item);
                if (fee != null) {
                  fees.add(fee);
                } else {
                  print('Γ£ù Failed to parse fee from: $item');
                }
              }
            }
          }
          // If data itself is a list-like structure
          else if (data['data'] != null && data['data'] is List) {
            print('Γ£ô Found data list with ${(data['data'] as List).length} items');
            for (var item in data['data'] as List) {
              if (item is Map<String, dynamic>) {
                final fee = _parseFeeFromJson(item);
                if (fee != null) {
                  fees.add(fee);
                } else {
                  print('Γ£ù Failed to parse fee from: $item');
                }
              }
            }
          } else {
            print('Γ£ù No recognized data structure found in response. Keys: ${data.keys.toList()}');
            // Try to parse the entire map as a single fee (unlikely but possible)
            final fee = _parseFeeFromJson(data);
            if (fee != null) {
              fees.add(fee);
            }
          }
        } else {
          print('Γ£ù Unexpected data type: ${data.runtimeType}');
        }

        print('=== Successfully parsed ${fees.length} fees ===');
        
        if (mounted) {
          setState(() {
            _allFees = fees;
            _filterFees();
          });
          
          if (fees.isEmpty) {
            print('ΓÜá No fees found in database');
          }
        }
      } else {
        // Handle error
        print('Γ£ù Failed to load fees. Error: ${response.error ?? "Unknown error"}');
        print('Γ£ù Status code: ${response.statusCode}');
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
      print('Γ£ù Exception loading fees: $e');
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
      if (_searchQuery.isEmpty) {
        // Show all records if search is empty
        _visibleFees = List<FeeRecord>.from(_allFees);
      } else {
      _visibleFees = _allFees.where((fee) {
          final query = _searchQuery.toLowerCase();
          // Search by name or student ID
          return fee.studentName.toLowerCase().contains(query) ||
              (fee.studentId != null && fee.studentId!.toLowerCase().contains(query));
      }).toList();
      }
    });
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
                const material.flutter_material.SizedBox(height: 12),
                Text('Student: ${fee.studentName}'),
                Text('Fee Type: ${fee.typeLabel}'),
                const material.flutter_material.SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      material.flutter_material.Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Text(
                            'Rs.${fee.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const material.flutter_material.SizedBox(height: 8),
                      material.material.flutter_material.Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid:'),
                          Text(
                            'Rs.${fee.paidAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: fee.paidAmount > 0 ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const material.flutter_material.SizedBox(height: 8),
                      material.flutter_material.Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Due Amount:'),
                          Text(
                            'Rs.${fee.dueAmount.toStringAsFixed(2)}',
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
                const material.flutter_material.SizedBox(height: 12),
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
                    content: Text('Fee updated successfully! New total: Rs.${updatedTotal.toStringAsFixed(2)}'),
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
            
            // Load student fee summary stat card after adding fee (will show in Search & Filter section)
            await _loadStudentFeeSummary(studentId);
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
                  labelText: 'Payment Amount (Rs.)',
                  hintText: 'Enter amount to pay',
                ),
                keyboardType: TextInputType.number,
              ),
              const material.flutter_material.SizedBox(height: 16),
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
              const material.flutter_material.SizedBox(height: 16),
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
                    content: Text('Payment amount (Rs.${paymentAmount.toStringAsFixed(2)}) cannot exceed due amount (Rs.${fee.dueAmount.toStringAsFixed(2)})'),
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
                        print('  - First payment: Rs.${updatedFee.paymentHistory.first.paymentAmount} on ${updatedFee.paymentHistory.first.paymentDate}');
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
                        content: Text('Payment of Rs.${paymentAmount.toStringAsFixed(2)} recorded successfully'),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1100;
        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  child: material.flutter_material.SizedBox(
                    width: 280,
                    child: _Sidebar(gradient: gradient),
                  ),
                ),
          body: material.flutter_material.Row(
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
                            child: material.flutter_material.Row(
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
                                const material.flutter_material.SizedBox(width: 20),
                                _buildBackButton(),
                              ],
                            ),
                          ),
                          const material.flutter_material.SizedBox(height: 24),
                          // Stat Cards Overview
                          _StatsOverview(fees: _allFees),
                          const material.flutter_material.SizedBox(height: 24),
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
                                    flex: 1,
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
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          
                                          try {
                                          await _fetchStudentInfoByStudentId(studentId);
                                            
                                            // Check if student was found by checking if name field was populated
                                            if (_studentNameController.text.trim().isEmpty) {
                                              // Student not found
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('No student data found for this Student ID'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                              }
                                            }
                                            // Removed auto-sync to search field - forms are now independent
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        } else {
                                          // Clear fields if student ID is empty
                                          setState(() {
                                            _studentNameController.clear();
                                            _classController.clear();
                                            _selectedGrade = null;
                                          });
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
                                  material.flutter_material.SizedBox(
                                    width: stacked ? 0 : 24,
                                    height: stacked ? 24 : 0,
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _SearchFilterSection(
                                      searchQuery: _searchQuery,
                                      searchController: _searchController,
                                      onSearchChanged: (value) async {
                                        setState(() {
                                          _searchQuery = value;
                                          _isLoadingSummary = value.trim().isNotEmpty;
                                        });
                                        _filterFees();
                                        // If any search query is entered, try to load student fee summary
                                        if (value.trim().isNotEmpty) {
                                          // Convert to uppercase for consistent matching
                                          final searchQuery = value.trim().toUpperCase();
                                          
                                          // Try to load student fee summary for any search query
                                          // This handles both student IDs (STUD-XXX) and partial matches
                                          await _loadStudentFeeSummary(searchQuery);
                                          
                                          // Check if student was found
                                          if (_studentFeeSummary == null && mounted) {
                                            // If no summary found, keep the filtered list visible
                                            setState(() {
                                              _isLoadingSummary = false;
                                            });
                                          }
                                        } else {
                                          // Clear stat card if search is cleared
                                          setState(() {
                                            _studentFeeSummary = null;
                                            _expandedFeeTypes = {};
                                            _selectedStudentIdForView = null;
                                          });
                                        }
                                      },
                                      fees: _visibleFees,
                                      onMarkPaid: _markAsPaid,
                                      studentFeeSummary: _studentFeeSummary,
                                      expandedFeeTypes: _expandedFeeTypes,
                                      onToggleFeeType: (feeType) {
                                        setState(() {
                                          _expandedFeeTypes[feeType] = !(_expandedFeeTypes[feeType] ?? false);
                                        });
                                      },
                                      onMarkAsPaid: (feeId) async {
                                        final feesByType = _studentFeeSummary!['fees_by_type'] as Map<String, dynamic>;
                                        FeeRecord? feeRecordToUpdate;
                                        for (var feeList in feesByType.values) {
                                          for (var fee in feeList as List) {
                                            if (fee['id'] == feeId) {
                                              feeRecordToUpdate = _parseFeeFromJson(fee);
                                              break;
                                            }
                                          }
                                          if (feeRecordToUpdate != null) break;
                                        }
                                        
                                        if (feeRecordToUpdate == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Fee not found')),
                                          );
                                          return;
                                        }
                                        
                                        // Store in local variable for null safety (already checked above)
                                        final fee = feeRecordToUpdate;
                                        
                                        // Show payment dialog (same as _markAsPaid method)
                                        final defaultAmount = fee.dueAmount > 0 
                                            ? fee.dueAmount 
                                            : fee.totalAmount;
                                        final amountController = TextEditingController(text: defaultAmount.toStringAsFixed(0));
                                        final dateController = TextEditingController(
                                          text: DateFormat('yyyy-MM-dd').format(DateTime.now())
                                        );
                                        final receiptController = TextEditingController();
                                        
                                        final shouldRecord = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Record Payment for ${fee.studentName}'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: amountController,
                                                    decoration: const InputDecoration(
                                                      labelText: 'Payment Amount (Rs.)',
                                                      hintText: 'Enter amount to pay',
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                  const material.flutter_material.SizedBox(height: 16),
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
                                                  const material.flutter_material.SizedBox(height: 16),
                                                  TextField(
                                                    controller: receiptController,
                                                    decoration: const InputDecoration(
                                                      labelText: 'Receipt Number *',
                                                      hintText: 'Enter receipt number',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final paymentAmount = double.tryParse(amountController.text);
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
                                                        content: Text('Payment amount (Rs.${paymentAmount.toStringAsFixed(2)}) cannot exceed due amount (Rs.${fee.dueAmount.toStringAsFixed(2)})'),
                                                        backgroundColor: Colors.orange,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  if (receiptController.text.trim().isEmpty) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Please enter receipt number'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text('Record Payment'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (shouldRecord != true) return;
                                        
                                        try {
                                        setState(() {
                                            _isLoadingSummary = true;
                                          });
                                          
                                          final paymentAmount = double.parse(amountController.text);
                                          
                                          // Record payment via API with receipt number
                                          final paymentUrl = '${Endpoints.fees}${fee.id}/record-payment/';
                                          final response = await _apiService.post(
                                            paymentUrl,
                                            body: {
                                              'payment_amount': paymentAmount.toString(),
                                              'payment_date': dateController.text,
                                              'receipt_number': receiptController.text.trim(),
                                              'notes': 'Payment recorded from stat card',
                                            },
                                          );
                                          
                                          if (response.success) {
                                            // Reload student fee summary immediately
                                            if (_selectedStudentIdForView != null) {
                                              await _loadStudentFeeSummary(_selectedStudentIdForView!);
                                            }
                                            
                                            // Also reload all fees to update the list
                                            await _loadFees();
                                            
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Payment of Rs.${paymentAmount.toStringAsFixed(2)} recorded successfully with receipt number: ${receiptController.text.trim()}. If you upload a receipt with the same receipt number, it will be automatically linked.'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 4),
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
                                        } catch (e) {
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
                                              _isLoadingSummary = false;
                                            });
                                          }
                                        }
                                      },
                                      onUploadReceipt: (feeId) async {
                                        // Find the fee from student summary
                                        final feesByType = _studentFeeSummary!['fees_by_type'] as Map<String, dynamic>;
                                        Map<String, dynamic>? feeData;
                                        for (var feeList in feesByType.values) {
                                          for (var fee in feeList as List) {
                                            if (fee['id'] == feeId) {
                                              feeData = fee as Map<String, dynamic>;
                                              break;
                                            }
                                          }
                                          if (feeData != null) break;
                                        }
                                        
                                        if (feeData == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Fee not found')),
                                          );
                                          return;
                                        }
                                        
                                        // Show upload receipt dialog (same as teacher profile photo)
                                        final receiptNumberController = TextEditingController();
                                        Uint8List? receiptBytes;
                                        
                                        final result = await showDialog<Map<String, dynamic>>(
                                          context: context,
                                          builder: (dialogContext) => StatefulBuilder(
                                            builder: (context, setDialogState) => AlertDialog(
                                              title: const Text('Upload Receipt'),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: receiptNumberController,
                                                      decoration: const InputDecoration(
                                                        labelText: 'Receipt Number *',
                                                        hintText: 'Enter receipt number',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    const material.flutter_material.SizedBox(height: 16),
                                                    // Receipt preview/upload area (same style as teacher photo)
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final picker = ImagePicker();
                                                        final picked = await picker.pickImage(
                                                          source: ImageSource.gallery,
                                                        );
                                                        if (picked != null) {
                                                          final bytes = await picked.readAsBytes();
                                                          setDialogState(() {
                                                            receiptBytes = bytes;
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(24),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(
                                                            color: const Color(0xFF667EEA),
                                                            width: 2,
                                                          ),
                                                          color: const Color(0x1A667EEA),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(Icons.receipt, size: 48, color: Color(0xFF667EEA)),
                                                            const material.flutter_material.SizedBox(height: 10),
                                                            const Text(
                                                              'Click to upload receipt or drag and drop',
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(color: Color(0xFF666666)),
                                                            ),
                                                            if (receiptBytes != null) ...[
                                                              const material.flutter_material.SizedBox(height: 16),
                                                              Image.memory(
                                                                receiptBytes!,
                                                                height: 100,
                                                                fit: BoxFit.contain,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
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
                                                  onPressed: () {
                                                    if (receiptNumberController.text.trim().isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Please enter receipt number'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (receiptBytes == null) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Please select a receipt file'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    Navigator.pop(context, {
                                                      'receipt_number': receiptNumberController.text.trim(),
                                                      'receipt_bytes': receiptBytes,
                                                    });
                                                  },
                                                  child: const Text('Upload'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        
                                        if (result != null && result['receipt_bytes'] != null) {
                                          try {
                                        setState(() {
                                              _isLoadingSummary = true;
                                            });
                                            
                                            // Upload receipt via API using multipart/form-data (same as teacher profile)
                                            final uploadUrl = '${Endpoints.fees}${feeId}/upload-receipt/';
                                            final receiptNumber = result['receipt_number'] as String;
                                            final receiptBytes = result['receipt_bytes'] as Uint8List;
                                            
                                            // Prepare additional fields
                                            final additionalFields = <String, String>{
                                              'receipt_number': receiptNumber,
                                            };
                                            
                                            // Upload file using uploadFile method (same as teacher profile photo)
                                            final response = await _apiService.uploadFile(
                                              uploadUrl,
                                              fileBytes: receiptBytes,
                                              fileName: 'receipt_${receiptNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                              fieldName: 'receipt_file',
                                              additionalFields: additionalFields,
                                            );
                                            
                                            if (response.success) {
                                              // Reload student fee summary
                                              if (_selectedStudentIdForView != null) {
                                                await _loadStudentFeeSummary(_selectedStudentIdForView!);
                                              }
                                              
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Receipt uploaded successfully. If you mark as paid with receipt number "$receiptNumber", the receipt will be automatically linked.'),
                                                    backgroundColor: Colors.green,
                                                    duration: const Duration(seconds: 4),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to upload receipt: ${response.error ?? "Unknown error"}'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error uploading receipt: ${e.toString()}'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isLoadingSummary = false;
                                              });
                                            }
                                          }
                                        }
                                      },
                                      isLoadingSummary: _isLoadingSummary,
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

// Stats Overview Cards
class _StatsOverview extends StatelessWidget {
  final List<FeeRecord> fees;

  const _StatsOverview({required this.fees});

  @override
  Widget build(BuildContext context) {
    // Calculate totals across all fees
    double totalFees = 0.0;
    double totalPaid = 0.0;
    double totalPending = 0.0;
    double collectionRate = 0.0;

    for (var fee in fees) {
      totalFees += fee.totalAmount;
      totalPaid += fee.paidAmount;
      totalPending += fee.dueAmount;
    }

    // Calculate collection rate (percentage of paid vs total)
    if (totalFees > 0) {
      collectionRate = (totalPaid / totalFees) * 100;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: material.flutter_material.Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.amber,
              label: 'Total Fees',
              value: 'Rs.${totalFees.toStringAsFixed(0)}',
              valueColor: Colors.black87,
            ),
          ),
          const material.flutter_material.SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              label: 'Paid',
              value: 'Rs.${totalPaid.toStringAsFixed(0)}',
              valueColor: Colors.green,
            ),
          ),
          const material.flutter_material.SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.pending,
              iconColor: Colors.red,
              label: 'Pending',
              value: 'Rs.${totalPending.toStringAsFixed(0)}',
              valueColor: Colors.red,
            ),
          ),
          const material.flutter_material.SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.bar_chart,
              iconColor: Colors.blue,
              label: 'Collection Rate',
              value: '${collectionRate.toStringAsFixed(0)}%',
              valueColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const material.flutter_material.SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const material.flutter_material.SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
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
                    icon: '≡ƒôè',
                    title: 'Overview',
                    isActive: false,
                    onTap: () => _navigateToRoute(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '≡ƒæ¿ΓÇì≡ƒÅ½',
                    title: 'Teachers',
                    onTap: () => _navigateToRoute(context, '/teachers'),
                  ),
                  _NavItem(
                    icon: '≡ƒæÑ',
                    title: 'Students',
                    onTap: () => _navigateToRoute(context, '/students'),
                  ),
                  _NavItem(
                    icon: '≡ƒÜî',
                    title: 'Buses',
                    onTap: () => _navigateToRoute(context, '/buses'),
                  ),
                  _NavItem(
                    icon: '≡ƒÄ»',
                    title: 'Activities',
                    onTap: () => _navigateToRoute(context, '/activities'),
                  ),
                  _NavItem(
                    icon: '≡ƒôà',
                    title: 'Events',
                    onTap: () => _navigateToRoute(context, '/events'),
                  ),
                  _NavItem(
                    icon: '≡ƒôå',
                    title: 'Calendar',
                    onTap: () => _navigateToRoute(context, '/calendar'),
                  ),
                  _NavItem(
                    icon: '≡ƒöö',
                    title: 'Notifications',
                    onTap: () => _navigateToRoute(context, '/notifications'),
                  ),
                  _NavItem(
                    icon: '≡ƒ¢ú∩╕Å',
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
    final formatter = NumberFormat.currency(symbol: 'Rs.', decimalDigits: 0);
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
            icon: '≡ƒÆ░',
            color: const Color(0xFF667EEA),
          ),
          _StatCard(
            label: 'Paid',
            value: formatter.format(stats['paid']),
            icon: 'Γ£à',
            color: Colors.green,
          ),
          _StatCard(
            label: 'Pending',
            value: formatter.format(stats['pending']),
            icon: 'ΓÅ│',
            color: Colors.orange,
          ),
          _StatCard(
            label: 'Collection Rate',
            value: '${stats['collection']!.toStringAsFixed(0)}%',
            icon: '≡ƒôè',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

          const material.flutter_material.SizedBox(height: 15),
          material.flutter_material.Row(
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
              const material.flutter_material.SizedBox(width: 15),
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
              const material.flutter_material.SizedBox(width: 15),
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
          const material.flutter_material.SizedBox(height: 20),
          // Show stat card if student summary is available, otherwise show fee list
          if (isLoadingSummary)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
                    ),
            )
          else if (studentFeeSummary != null)
            // Show stat card - increased width to 75% for one record at a time
            Align(
              alignment: Alignment.topLeft,
              child: material.flutter_material.SizedBox(
                width: (MediaQuery.of(context).size.width - 200) * 0.75, // Increased width to ~75% for better visibility
                child: _StudentFeeDetailCard(
                  summary: studentFeeSummary!,
                  expandedFeeTypes: expandedFeeTypes,
                  onToggleFeeType: onToggleFeeType,
                  onMarkAsPaid: onMarkAsPaid,
                  onUploadReceipt: onUploadReceipt,
                ),
              ),
            )
          else if (searchQuery.trim().isNotEmpty && !isLoadingSummary)
            // Show "No student data" message when search query entered but not found
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const material.flutter_material.SizedBox(height: 16),
                    Text(
                      'No student data found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const material.flutter_material.SizedBox(height: 8),
                    Text(
                      'Please check the Student ID and try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Removed _FeeCard and _FeeCardState classes - using only _StudentFeeDetailCard now

// New widget for student search
class _StudentSearchSection extends StatelessWidget {
  final TextEditingController studentIdController;
  final Function(String) onSearch;

  const _StudentSearchSection({
    required this.studentIdController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: material.flutter_material.Row(
        children: [
          Expanded(
            child: TextField(
              controller: studentIdController,
              decoration: InputDecoration(
                labelText: 'Enter Student ID',
                hintText: 'e.g., STUD-001',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const material.flutter_material.SizedBox(width: 15),
          ElevatedButton.icon(
            onPressed: () => onSearch(studentIdController.text.trim()),
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for student fee detail card (matches image design)
class _StudentFeeDetailCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final Map<String, bool> expandedFeeTypes;
  final Function(String) onToggleFeeType;
  final Function(int) onMarkAsPaid;
  final Function(int) onUploadReceipt;

  const _StudentFeeDetailCard({
    required this.summary,
    required this.expandedFeeTypes,
    required this.onToggleFeeType,
    required this.onMarkAsPaid,
    required this.onUploadReceipt,
  });

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FULLY PAID':
        return Colors.green;
      case 'PARTIALLY PAID':
        return Colors.orange;
      case 'NOT PAID':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = summary['student'] as Map<String, dynamic>;
    final summaryData = summary['summary'] as Map<String, dynamic>;
    final feesByType = summary['fees_by_type'] as Map<String, dynamic>;
    final paymentHistory = summary['payment_history'] as List<dynamic>;

    final paymentStatus = summaryData['payment_status'] as String;
    final statusColor = _getPaymentStatusColor(paymentStatus);

    return Container(
      // Fixed height container - top bar fixed, content scrollable
      height: MediaQuery.of(context).size.height * 0.85, // Fixed height - increased for more space
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Student Header Section (not scrollable)
          _StudentHeaderSection(
            student: student,
            paymentStatus: paymentStatus,
            statusColor: statusColor,
          ),
          const material.flutter_material.SizedBox(height: 20),
          
          // Summary Boxes (Fixed - not scrollable)
          _SummaryBoxesSection(summary: summaryData),
          const material.flutter_material.SizedBox(height: 20),
          
          // Scrollable Fee Types Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fee Types (Collapsible sections)
                  ...feesByType.entries.map((entry) {
                    final feeType = entry.key;
                    final fees = entry.value as List<dynamic>;
                    final isExpanded = expandedFeeTypes[feeType] ?? true;
                    
                    return _FeeTypeSection(
                      feeType: feeType,
                      fees: fees,
                      isExpanded: isExpanded,
                      onToggle: () => onToggleFeeType(feeType),
                      onMarkAsPaid: onMarkAsPaid,
                      onUploadReceipt: onUploadReceipt,
                    );
                  }).toList(),
                  
                  const material.flutter_material.SizedBox(height: 20),
                  
                  // Payment History Table
                  _PaymentHistoryTable(paymentHistory: paymentHistory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Student Header Section (Fixed)
class _StudentHeaderSection extends StatelessWidget {
  final Map<String, dynamic> student;
  final String paymentStatus;
  final Color statusColor;

  const _StudentHeaderSection({
    required this.student,
    required this.paymentStatus,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return material.flutter_material.Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student['student_name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const material.flutter_material.SizedBox(height: 6),
              material.flutter_material.Row(
                children: [
                  _InfoChip(
                    icon: Icons.badge,
                    label: 'ID: ${student['student_id'] ?? 'N/A'}',
                  ),
                  const material.flutter_material.SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.class_,
                    label: 'Class: ${student['applying_class'] ?? 'N/A'}',
                  ),
                  const material.flutter_material.SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.grade,
                    label: 'Grade: ${student['grade'] ?? 'N/A'}',
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            paymentStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return material.flutter_material.Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const material.flutter_material.SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Summary Boxes Section
class _SummaryBoxesSection extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _SummaryBoxesSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: 'Rs.', decimalDigits: 2);
    final nextDueDate = summary['next_due_date'] != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(summary['next_due_date']))
        : 'N/A';

    // Parse values safely - handle both string and num types
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    final totalPayable = parseAmount(summary['total_payable']);
    final totalPaid = parseAmount(summary['total_paid']);
    final totalDue = parseAmount(summary['total_due']);

    return material.flutter_material.Row(
      children: [
        Expanded(
          child: _SummaryBox(
            label: 'Total Payable',
            value: formatter.format(totalPayable),
            color: Colors.green,
            icon: Icons.account_balance_wallet,
          ),
        ),
        const material.flutter_material.SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            label: 'Total Paid',
            value: formatter.format(totalPaid),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ),
        const material.flutter_material.SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            label: 'Due',
            value: formatter.format(totalDue),
            color: Colors.orange,
            icon: Icons.pending,
          ),
        ),
        const material.flutter_material.SizedBox(width: 8),
        Expanded(
          child: _SummaryBox(
            label: 'Next Due Date',
            value: nextDueDate,
            color: Colors.blue,
            icon: Icons.calendar_today,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          material.flutter_material.Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const material.flutter_material.SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const material.flutter_material.SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Fee Type Section (Collapsible)
class _FeeTypeSection extends StatelessWidget {
  final String feeType;
  final List<dynamic> fees;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(int) onMarkAsPaid;
  final Function(int) onUploadReceipt;

  const _FeeTypeSection({
    required this.feeType,
    required this.fees,
    required this.isExpanded,
    required this.onToggle,
    required this.onMarkAsPaid,
    required this.onUploadReceipt,
  });

  Color _getFeeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'examination':
        return Colors.blue;
      case 'transport':
        return Colors.orange;
      case 'tuition':
        return Colors.green;
      case 'library':
        return Colors.purple;
      case 'laboratory':
        return Colors.red;
      case 'sports':
        return Colors.amber;
      case 'hostel':
        return Colors.brown;
      case 'uniform':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getFeeTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'examination':
        return Icons.assignment;
      case 'transport':
        return Icons.directions_bus;
      case 'tuition':
        return Icons.school;
      case 'library':
        return Icons.library_books;
      case 'laboratory':
        return Icons.science;
      case 'sports':
        return Icons.sports;
      case 'hostel':
        return Icons.home;
      case 'uniform':
        return Icons.checkroom;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) return const SizedBox.shrink();
    
    final fee = fees.first as Map<String, dynamic>;
    
    // Safe parsing for amounts - handle both string and num types
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    final totalAmount = parseAmount(fee['total_amount']);
    final paidAmount = parseAmount(fee['paid_amount']);
    final dueAmount = parseAmount(fee['due_amount']);
    final status = fee['status'] as String? ?? 'pending';
    final isPaid = status == 'paid' || dueAmount == 0;
    
    final feeTypeColor = _getFeeTypeColor(feeType);
    final feeTypeIcon = _getFeeTypeIcon(feeType);
    final feeTypeLabel = feeType.replaceAll('-', ' ').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (always visible) - collapsible
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feeTypeColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: material.flutter_material.Row(
                children: [
                  Icon(feeTypeIcon, color: feeTypeColor, size: 24),
                  const material.flutter_material.SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feeTypeLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: feeTypeColor,
                      ),
                    ),
                  ),
                  // Show summary in header: Total: Rs.X Paid: Rs.Y Due: Rs.Z (with proper spacing and clear headings)
                  material.flutter_material.Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: Rs.${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const material.flutter_material.SizedBox(width: 20),
                      Text(
                        'Paid: Rs.${paidAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: paidAmount > 0 ? Colors.green.shade700 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const material.flutter_material.SizedBox(width: 20),
                      Text(
                        'Due: Rs.${dueAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: dueAmount > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isPaid)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PAID',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const material.flutter_material.SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          // Content (expandable)
          if (isExpanded)
            Builder(
              builder: (context) {
                // Safe parsing for late_fee
                final lateFee = parseAmount(fee['late_fee']);
                final lateFeeValue = lateFee > 0
                    ? 'Rs.${lateFee.toStringAsFixed(0)}'
                    : (isPaid ? 'Paid' : 'Rs.0');
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeeDetailRow(label: 'Total:', value: 'Rs.${totalAmount.toStringAsFixed(2)}'),
                      _FeeDetailRow(label: 'Paid:', value: 'Rs.${paidAmount.toStringAsFixed(2)}'),
                      _FeeDetailRow(
                        label: 'Due:',
                        value: 'Rs.${dueAmount.toStringAsFixed(2)}',
                        valueColor: dueAmount > 0 ? Colors.orange : Colors.grey,
                      ),
                      _FeeDetailRow(
                        label: 'Due Date:',
                        value: fee['due_date'] != null
                            ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(fee['due_date']))
                            : 'N/A',
                      ),
                      _FeeDetailRow(
                        label: 'Frequency:',
                        value: (fee['frequency'] as String? ?? '').replaceAll('-', ' ').toUpperCase(),
                      ),
                      _FeeDetailRow(
                        label: 'Late Fee:',
                        value: lateFeeValue,
                      ),
                      if (fee['description'] != null && fee['description'].toString().isNotEmpty)
                        _FeeDetailRow(
                          label: 'Description:',
                          value: fee['description'].toString(),
                        ),
                      const material.flutter_material.SizedBox(height: 12),
                      material.flutter_material.Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => onUploadReceipt(fee['id'] as int),
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Upload Receipt'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                          const material.flutter_material.SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isPaid ? null : () => onMarkAsPaid(fee['id'] as int),
                              icon: Icon(isPaid ? Icons.check_circle : Icons.payment),
                              label: Text(isPaid ? 'Paid' : 'Mark as Paid'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FeeDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _FeeDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: material.flutter_material.Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          material.flutter_material.SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    if (paymentHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Complete Payment History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const material.flutter_material.SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: const [
                  _TableHeaderCell('Date'),
                  _TableHeaderCell('Fee Type'),
                  _TableHeaderCell('Amount'),
                  _TableHeaderCell('Receipt No.'),
                  _TableHeaderCell('View Receipt'),
                  _TableHeaderCell('Status'),
                ],
              ),
              // Data rows
              ...paymentHistory.map((payment) {
                final date = payment['payment_date'] != null
                    ? DateFormat('MMM dd, yyyy').format(DateTime.parse(payment['payment_date']))
                    : 'N/A';
                final feeType = (payment['fee_type'] as String? ?? '').replaceAll('-', ' ').toUpperCase();
                // Safe parsing for payment_amount
                double parseAmount(dynamic value) {
                  if (value == null) return 0.0;
                  if (value is num) return value.toDouble();
                  if (value is String) {
                    return double.tryParse(value) ?? 0.0;
                  }
                  return 0.0;
                }
                final amount = 'Rs.${parseAmount(payment['payment_amount']).toStringAsFixed(2)}';
                final receiptNo = payment['receipt_number']?.toString() ?? 'N/A';
                final uploadReceipt = payment['upload_receipt']?.toString();

                return TableRow(
                  children: [
                    _TableCell(date),
                    _TableCell(feeType),
                    _TableCell(amount),
                    _TableCell(receiptNo),
                    _TableCell(
                      (receiptNo != 'N/A' && uploadReceipt != null && uploadReceipt.isNotEmpty) 
                        ? 'View Receipt' 
                        : '-',
                      isLink: (receiptNo != 'N/A' && uploadReceipt != null && uploadReceipt.isNotEmpty),
                      receiptPath: uploadReceipt,
                      receiptNumber: receiptNo,
                    ),
                    _TableCell(
                      'Paid',
                      statusColor: Colors.green,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isLink;
  final String? receiptPath;
  final String? receiptNumber;
  final Color? statusColor;

  const _TableCell(
    this.text, {
    this.isLink = false,
    this.receiptPath,
    this.receiptNumber,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLink && receiptPath != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () {
            // Show receipt dialog
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: Text('Receipt #${receiptNumber ?? ""}'),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        child: Image.network(
                          receiptPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Error loading receipt image'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: statusColor ?? Colors.black87,
          fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal,
        ),
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

  const _AddFeeSection({
    required this.formKey,
    required this.studentIdController,
    required this.studentNameController,
    required this.classController,
    this.selectedGrade,
    required this.onGradeChanged,
    required this.totalAmountController,
    required this.lateFeeController,
    required this.descriptionController,
    required this.onStudentIdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return material.Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: const material.Text('Add Fee Section Placeholder'),
    );
  }
}
