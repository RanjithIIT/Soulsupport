import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:main_login/main.dart' as main_login;
import 'dashboard.dart';

enum FeeStatus { paid, pending, overdue }

class FeeRecord {
  final int id;
  final String studentName;
  final String feeType;
  final String grade;
  final double amount;
  final String frequency;
  final DateTime dueDate;
  final double lateFee;
  final String description;
  FeeStatus status;
  double paidAmount;
  DateTime? paidDate;

  FeeRecord({
    required this.id,
    required this.studentName,
    required this.feeType,
    required this.grade,
    required this.amount,
    required this.frequency,
    required this.dueDate,
    required this.lateFee,
    required this.description,
    required this.status,
    required this.paidAmount,
    this.paidDate,
  });

  String get typeLabel => feeType.replaceAll('-', ' ').toUpperCase();
  String get classLabel => grade.replaceAll('-', ' ').toUpperCase();
  String get frequencyLabel => frequency.replaceAll('-', ' ').toUpperCase();
}

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  final List<FeeRecord> _allFees = [
    FeeRecord(
      id: 1,
      studentName: 'Rahul Kumar',
      feeType: 'tuition',
      grade: 'class-10',
      amount: 5000,
      frequency: 'monthly',
      dueDate: DateTime(2024, 1, 15),
      lateFee: 100,
      description: 'Monthly tuition fee for Class 10',
      status: FeeStatus.paid,
      paidAmount: 5000,
      paidDate: DateTime(2024, 1, 10),
    ),
    FeeRecord(
      id: 2,
      studentName: 'Priya Sharma',
      feeType: 'transport',
      grade: 'class-8',
      amount: 1500,
      frequency: 'monthly',
      dueDate: DateTime(2024, 1, 20),
      lateFee: 50,
      description: 'Monthly transport fee for Class 8',
      status: FeeStatus.pending,
      paidAmount: 0,
    ),
    FeeRecord(
      id: 3,
      studentName: 'Amit Patel',
      feeType: 'laboratory',
      grade: 'class-11',
      amount: 2000,
      frequency: 'quarterly',
      dueDate: DateTime(2024, 1, 25),
      lateFee: 75,
      description: 'Quarterly laboratory fee for Class 11',
      status: FeeStatus.overdue,
      paidAmount: 0,
    ),
    FeeRecord(
      id: 4,
      studentName: 'Neha Singh',
      feeType: 'examination',
      grade: 'class-12',
      amount: 3000,
      frequency: 'one-time',
      dueDate: DateTime(2024, 1, 30),
      lateFee: 200,
      description: 'One-time examination fee for Class 12',
      status: FeeStatus.paid,
      paidAmount: 3000,
      paidDate: DateTime(2024, 1, 5),
    ),
    FeeRecord(
      id: 5,
      studentName: 'Vikram Mehta',
      feeType: 'library',
      grade: 'class-9',
      amount: 800,
      frequency: 'yearly',
      dueDate: DateTime(2024, 2, 1),
      lateFee: 25,
      description: 'Yearly library fee for Class 9',
      status: FeeStatus.pending,
      paidAmount: 0,
    ),
    FeeRecord(
      id: 6,
      studentName: 'Anjali Gupta',
      feeType: 'sports',
      grade: 'class-7',
      amount: 1200,
      frequency: 'half-yearly',
      dueDate: DateTime(2024, 1, 18),
      lateFee: 60,
      description: 'Half-yearly sports fee for Class 7',
      status: FeeStatus.paid,
      paidAmount: 1200,
      paidDate: DateTime(2024, 1, 12),
    ),
  ];

  late List<FeeRecord> _visibleFees;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _studentController = TextEditingController();
  final _amountController = TextEditingController();
  final _lateFeeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _newFeeType;
  String? _newClass;
  String? _newFrequency;
  DateTime? _newDueDate;

  String _searchQuery = '';
  String? _statusFilter;
  String? _classFilter;

  @override
  void initState() {
    super.initState();
    _visibleFees = List<FeeRecord>.from(_allFees);
  }

  @override
  void dispose() {
    _studentController.dispose();
    _amountController.dispose();
    _lateFeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _filterFees() {
    setState(() {
      _visibleFees = _allFees.where((fee) {
        final matchesSearch = _searchQuery.isEmpty ||
            fee.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fee.feeType.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus =
            _statusFilter == null || fee.status.name == _statusFilter;
        final matchesClass =
            _classFilter == null || fee.grade == _classFilter;
        return matchesSearch && matchesStatus && matchesClass;
      }).toList();
    });
  }

  Map<String, double> _stats() {
    final total = _allFees.fold<double>(0, (sum, fee) => sum + fee.amount);
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

  void _addFee() {
    if (!_formKey.currentState!.validate()) return;
    if (_newFeeType == null ||
        _newClass == null ||
        _newFrequency == null ||
        _newDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final fee = FeeRecord(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      studentName: _studentController.text.trim().isEmpty
          ? 'New Student'
          : _studentController.text.trim(),
      feeType: _newFeeType!,
      grade: _newClass!,
      amount: double.parse(_amountController.text.trim()),
      frequency: _newFrequency!,
      dueDate: _newDueDate!,
      lateFee: double.tryParse(_lateFeeController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      status: FeeStatus.pending,
      paidAmount: 0,
    );

    setState(() {
      _allFees.insert(0, fee);
      _filterFees();
    });

    _formKey.currentState!.reset();
    _studentController.clear();
    _amountController.clear();
    _lateFeeController.clear();
    _descriptionController.clear();
    setState(() {
      _newFeeType = null;
      _newClass = null;
      _newFrequency = null;
      _newDueDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fee structure added successfully!')),
    );
  }

  void _markAsPaid(FeeRecord fee) async {
    final controller =
        TextEditingController(text: fee.amount.toStringAsFixed(0));
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark ${fee.studentName} as Paid'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount Paid (₹)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final paid = double.tryParse(controller.text) ?? fee.amount;
              setState(() {
                fee.paidAmount = paid;
                fee.status = FeeStatus.paid;
                fee.paidDate = DateTime.now();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fee marked as paid')),
              );
            },
            child: const Text('Confirm'),
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
                  color: Colors.white,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BackButton(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage())),
                          ),
                          const SizedBox(height: 16),
                          _Header(
                            showMenuButton: !showSidebar,
                            onMenuTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            onLogout: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Navigate to main login page
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const main_login.LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
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
                                      studentController: _studentController,
                                      amountController: _amountController,
                                      lateFeeController: _lateFeeController,
                                      descriptionController:
                                          _descriptionController,
                                      feeType: _newFeeType,
                                      onFeeTypeChanged: (value) =>
                                          setState(() => _newFeeType = value),
                                      feeClass: _newClass,
                                      onFeeClassChanged: (value) =>
                                          setState(() => _newClass = value),
                                      frequency: _newFrequency,
                                      onFrequencyChanged: (value) =>
                                          setState(() => _newFrequency = value),
                                      dueDate: _newDueDate,
                                      onPickDueDate: _pickDueDate,
                                      onSubmit: _addFee,
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
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _NavItem(
                    icon: '📊',
                    title: 'Dashboard',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/students'),
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
                    icon: '💰',
                    title: 'Fees',
                    isActive: true,
                    onTap: () {},
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
          borderRadius: BorderRadius.circular(12),
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
          leading: Text(widget.icon, style: const TextStyle(fontSize: 18, color: Colors.white)),
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
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C757D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back),
          SizedBox(width: 8),
          Text('Back to Dashboard'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final VoidCallback onLogout;

  const _Header({
    required this.showMenuButton,
    this.onMenuTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              if (showMenuButton)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu, color: Colors.black87),
                ),
              const Text(
                '💰 Fees Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'School Manager',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: [
        _StatCard(
          icon: '💰',
          number: formatter.format(stats['total']),
          label: 'Total Fees',
        ),
        _StatCard(
          icon: '✅',
          number: formatter.format(stats['paid']),
          label: 'Paid',
        ),
        _StatCard(
          icon: '⏰',
          number: formatter.format(stats['pending']),
          label: 'Pending',
        ),
        _StatCard(
          icon: '📊',
          number: '${stats['collection']!.toStringAsFixed(0)}%',
          label: 'Collection Rate',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String number;
  final String label;

  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 15),
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddFeeSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController studentController;
  final TextEditingController amountController;
  final TextEditingController lateFeeController;
  final TextEditingController descriptionController;
  final String? feeType;
  final ValueChanged<String?> onFeeTypeChanged;
  final String? feeClass;
  final ValueChanged<String?> onFeeClassChanged;
  final String? frequency;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? dueDate;
  final VoidCallback onPickDueDate;
  final VoidCallback onSubmit;

  const _AddFeeSection({
    required this.formKey,
    required this.studentController,
    required this.amountController,
    required this.lateFeeController,
    required this.descriptionController,
    required this.feeType,
    required this.onFeeTypeChanged,
    required this.feeClass,
    required this.onFeeClassChanged,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.dueDate,
    required this.onPickDueDate,
    required this.onSubmit,
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
                  child: DropdownButtonFormField<String>(
                    value: feeType,
                    decoration: InputDecoration(
                      labelText: 'Fee Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tuition', child: Text('Tuition Fee')),
                      DropdownMenuItem(value: 'transport', child: Text('Transport Fee')),
                      DropdownMenuItem(value: 'library', child: Text('Library Fee')),
                      DropdownMenuItem(value: 'laboratory', child: Text('Laboratory Fee')),
                      DropdownMenuItem(value: 'sports', child: Text('Sports Fee')),
                      DropdownMenuItem(value: 'examination', child: Text('Examination Fee')),
                      DropdownMenuItem(value: 'development', child: Text('Development Fee')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: onFeeTypeChanged,
                    validator: (value) =>
                        value == null ? 'Please select fee type' : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: feeClass,
                    decoration: InputDecoration(
                      labelText: 'Class',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: List.generate(12, (i) => i + 1).map((i) {
                      return DropdownMenuItem(
                        value: 'class-$i',
                        child: Text('Class $i'),
                      );
                    }).toList(),
                    onChanged: onFeeClassChanged,
                    validator: (value) =>
                        value == null ? 'Please select class' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter amount' : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: frequency,
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
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Fee Structure'),
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
  final String? statusFilter;
  final ValueChanged<String?> onStatusChanged;
  final String? classFilter;
  final ValueChanged<String?> onClassChanged;
  final List<FeeRecord> fees;
  final ValueChanged<FeeRecord> onMarkPaid;

  const _SearchFilterSection({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.classFilter,
    required this.onClassChanged,
    required this.fees,
    required this.onMarkPaid,
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
          TextField(
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.collapsed(offset: searchQuery.length),
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search fees...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: statusFilter,
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
                  value: classFilter,
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
          if (fees.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No fees found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 1 column for mobile, 2 for tablet, 3 for desktop, 4 for large screens
                final width = constraints.maxWidth;
                final crossAxisCount = width > 1400
                    ? 4
                    : width > 1000
                        ? 3
                        : width > 600
                            ? 2
                            : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 310,
                  ),
                  itemCount: fees.length,
                  itemBuilder: (context, index) => _FeeCard(
                    fee: fees[index],
                    onMarkPaid: () => onMarkPaid(fees[index]),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final FeeRecord fee;
  final VoidCallback onMarkPaid;

  const _FeeCard({
    required this.fee,
    required this.onMarkPaid,
  });

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final formatter = DateFormat('MMMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusColor, width: 5),
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
          Text(
            fee.studentName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${fee.typeLabel}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Class: ${fee.classLabel}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Amount: ₹${fee.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Frequency: ${fee.frequencyLabel}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Due Date: ${formatter.format(fee.dueDate)}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Late Fee: ₹${fee.lateFee.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (fee.paidAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Paid: ₹${fee.paidAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.green, fontSize: 13),
            ),
            if (fee.paidDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Paid Date: ${formatter.format(fee.paidDate!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            fee.description,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusLabel(),
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (fee.status != FeeStatus.paid) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMarkPaid,
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

