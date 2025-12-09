import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const _base = 'http://localhost:8000/api/management-admin';
  static const teachersEndpoint = '$_base/teachers/';
  static const studentsEndpoint = '$_base/students/';
  static const communicationsEndpoint = 'http://localhost:8000/api/student-parent/communications/';
  static const parentBase = 'http://localhost:8000/api/student-parent';
  static const parentEndpoint = '$parentBase/parent/';

  /// Fetch chat messages between two users (sender and recipient usernames)
  static Future<List<Map<String, dynamic>>> fetchCommunications(String senderUsername, String recipientUsername) async {
    final uri = Uri.parse('$communicationsEndpoint?sender=$senderUsername&recipient=$recipientUsername');
    final resp = await http.get(uri, headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return List<Map<String, dynamic>>.from(data);
      if (data is Map && data.containsKey('results')) {
        return List<Map<String, dynamic>>.from(data['results'] as List);
      }
      return [];
    }
    throw Exception('Failed to fetch communications: ${resp.statusCode}');
  }

  static Future<List<dynamic>> fetchTeachers() async {
    final resp = await http
        .get(Uri.parse(teachersEndpoint),
            headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('results')) {
        return data['results'] as List;
      }
      return [];
    }
    throw Exception('Failed to fetch teachers: ${resp.statusCode}');
  }

  static Future<List<dynamic>> fetchStudents() async {
    final resp = await http
        .get(Uri.parse(studentsEndpoint),
            headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('results')) {
        return data['results'] as List;
      }
      return [];
    }
    throw Exception('Failed to fetch students: ${resp.statusCode}');
  }

  /// Fetch parent profile data
  static Future<Map<String, dynamic>?> fetchParentProfile() async {
    try {
      final resp = await http
          .get(Uri.parse(parentEndpoint),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List && data.isNotEmpty) {
          return Map<String, dynamic>.from(data[0] as Map);
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch parent profile: $e');
    }
  }

  /// Fetch student data by student ID
  static Future<Map<String, dynamic>?> fetchStudentById(int studentId) async {
    try {
      final resp = await http
          .get(Uri.parse('$studentsEndpoint$studentId/'),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }
}
