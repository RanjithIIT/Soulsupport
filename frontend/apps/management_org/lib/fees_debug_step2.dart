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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Debug 2')));
  }
}
