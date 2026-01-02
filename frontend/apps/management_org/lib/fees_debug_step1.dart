import 'package:flutter/material.dart';
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
  const PaymentHistoryRecord({required this.id});
}

class FeeRecord {
  final int id;
  const FeeRecord({required this.id});
}

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Debug'),
      ),
    );
  }
}
