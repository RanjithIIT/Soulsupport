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
  // State variables
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
  
  String? _selectedGrade;
  DateTime? _newDueDate;
  String? _newFrequency = 'monthly';
  String? _newFeeType = 'tuition';
  
  String _searchQuery = '';
  String? _statusFilter;
  String? _classFilter;
  String? _feeTypeFilter;
  
  // Missing State Variables
  bool _isLoadingSummary = false;
  String? _selectedStudentIdForView;
  Map<String, dynamic>? _studentFeeSummary;
  Set<int> _expandedFeeTypes = {};

  // Additional vars for payment
  String? _studentEmail; 

  @override
  void initState() {
    super.initState();
    _visibleFees = [];
    _loadFees();
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

  Future<void> _loadFees() async {
    // Stub
  }

  Widget _buildUserInfo() {
      // Stub
      return const SizedBox();
  }

  Widget _buildBackButton() {
      // Stub
      return const SizedBox();
  }

  // Stubbing the logic methods for now to isolate structure
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Center(child: Text('Debug 3')));
  }
}

// Stub AddFeeSection
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
    return flutter_material.Container(
      padding: const EdgeInsets.all(16),
      child: const flutter_material.Text('Add Fee Section Placeholder'),
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
    return Text(text);
  }
}
