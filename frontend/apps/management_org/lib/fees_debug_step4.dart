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
  final _searchController = TextEditingController(); // Added missing controller
  
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFees() async {}
  Future<void> _fetchStudentInfoByStudentId(String id) async {}
  void _pickDueDate() {}
  void _addFee() {}
  
  void _filterFees() {}
  Future<void> _loadStudentFeeSummary(String query) async {}
  
  // ignore: unused_element
  void _markAsPaid(FeeRecord fee) {}

  Widget _buildUserInfo() {
      return const SizedBox();
  }

  Widget _buildBackButton() {
      return const SizedBox();
  }
  
  FeeRecord? _parseFeeFromJson(dynamic json) { return null; }

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
                  child: flutter_material.SizedBox(
                    width: 280,
                    child: _Sidebar(gradient: gradient),
                  ),
                ),
          body: flutter_material.Row(
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
                            child: flutter_material.Row(
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
                                const flutter_material.SizedBox(width: 20),
                                _buildBackButton(),
                              ],
                            ),
                          ),
                          const flutter_material.SizedBox(height: 24),
                          // Stat Cards Overview
                          _StatsOverview(fees: _allFees),
                          const flutter_material.SizedBox(height: 24),
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
                                        // Empty stub intent
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
                                  flutter_material.SizedBox(
                                    width: stacked ? 0 : 24,
                                    height: stacked ? 24 : 0,
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _SearchFilterSection(
                                      searchQuery: _searchQuery,
                                      searchController: _searchController,
                                      onSearchChanged: (value) async {
                                        // Stub
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
                                        // Stub
                                      },
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

// --- MISSING CLASS STUBS ---

class _Sidebar extends StatelessWidget {
  final Gradient gradient;
  const _Sidebar({required this.gradient});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  const GlassContainer({required this.child, required this.padding, required this.margin});
  @override
  Widget build(BuildContext context) => Container(padding: padding, margin: margin, child: child);
}

class _StatsOverview extends StatelessWidget {
  final List<FeeRecord> fees;
  const _StatsOverview({required this.fees});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _AddFeeSection extends StatelessWidget {
  // Add all named parameters used in build
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
  final VoidCallback onSubmit;
  final bool isSubmitting;

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
    this.feeType,
    required this.onFeeTypeChanged,
    this.frequency,
    required this.onFrequencyChanged,
    this.dueDate,
    required this.onPickDueDate,
    required this.onSubmit,
    required this.isSubmitting,
  });
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<FeeRecord> fees;
  final void Function(FeeRecord) onMarkPaid;
  final Map<String, dynamic>? studentFeeSummary;
  final Set<int> expandedFeeTypes;
  final ValueChanged<int> onToggleFeeType;
  final ValueChanged<int> onMarkAsPaid;

  const _SearchFilterSection({
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.fees,
    required this.onMarkPaid,
    this.studentFeeSummary,
    required this.expandedFeeTypes,
    required this.onToggleFeeType,
    required this.onMarkAsPaid,
  });
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isLink;
  final String? receiptPath;
  final String? receiptNumber;
  final Color? statusColor;

  const _TableCell(this.text, {this.isLink = false, this.receiptPath, this.receiptNumber, this.statusColor});

  @override
  Widget build(BuildContext context) => Text(text);
}
