import 'package:flutter/material.dart';
import 'dart:ui';
import 'main.dart' as app;
import 'dashboard.dart';
import 'package:core/api/api_service.dart';
import 'widgets/school_profile_header.dart';
import 'widgets/management_sidebar.dart';

class RTIActPage extends StatefulWidget {
  const RTIActPage({super.key});

  @override
  State<RTIActPage> createState() => _RTIActPageState();
}

class _RTIActPageState extends State<RTIActPage> {
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
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final gradient = const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (isDesktop)
            ManagementSidebar(gradient: gradient, activeRoute: '/rti-act'),

          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // Content
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                    const Text(
                      '📋 RTI Act',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Right to Information Act - Transparency & Accountability',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              _buildUserInfo(),
            ],
          ),
          const SizedBox(height: 20),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About RTI Act',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'The Right to Information Act, 2005 (RTI Act) is an Act of the Parliament of India to provide for setting out the practical regime of right to information for citizens.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),
          
          // Information Cards
          _buildInfoCard(
            '📄',
            'Public Information Officer (PIO)',
            'Contact details and information about the designated PIO for the institution.',
          ),
          const SizedBox(height: 15),
          _buildInfoCard(
            '📝',
            'How to File an RTI Application',
            'Step-by-step guide on filing RTI applications and obtaining information.',
          ),
          const SizedBox(height: 15),
          _buildInfoCard(
            '📋',
            'Proactive Disclosure',
            'Information mandatorily disclosed under Section 4 of the RTI Act.',
          ),
          const SizedBox(height: 15),
          _buildInfoCard(
            '⏱️',
            'Response Timeline',
            'RTI applications are typically responded to within 30 days of receipt.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
