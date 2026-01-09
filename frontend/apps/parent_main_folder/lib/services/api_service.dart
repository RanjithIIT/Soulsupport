import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const baseUrl = 'http://localhost:8000/api';
    /// Fetch bus details for a student by student ID
    static Future<Map<String, dynamic>?> fetchStudentBusDetails(String studentId) async {
      final headers = await _getAuthHeaders();
      final resp = await http.get(
        Uri.parse('http://localhost:8000/api/management-admin/student/$studentId/bus-details/'),
        headers: headers,
      );
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return null;
    }
  static const _base = 'http://localhost:8000/api/management-admin';
  static const teachersEndpoint = '$_base/teachers/';
  static const studentsEndpoint = '$_base/students/';
  static const communicationsEndpoint = 'http://localhost:8000/api/student-parent/communications/';
  static const chatMessagesEndpoint = 'http://localhost:8000/api/student-parent/chat-messages/';
  static const parentBase = 'http://localhost:8000/api/student-parent';
  static const parentEndpoint = '$parentBase/parent/';
  static const teacherBase = 'http://localhost:8000/api/teacher';

  static Future<List<dynamic>> fetchTeacherClasses() async {
    final headers = await _getAuthHeaders();
    final resp = await http.get(Uri.parse('$teacherBase/classes/'), headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    return [];
  }

  static Future<List<dynamic>> fetchTeacherExams() async {
    final headers = await _getAuthHeaders();
    final resp = await http.get(Uri.parse('$teacherBase/exams/'), headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> createExam(Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    print('Creating exam: $data');
    final resp = await http.post(
      Uri.parse('$teacherBase/exams/'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (resp.statusCode != 201) {
      print('Failed to create exam: ${resp.body}');
    }
    return resp.statusCode == 201;
  }
  
  static Future<bool> deleteExam(int id) async {
    final headers = await _getAuthHeaders();
    final resp = await http.delete(Uri.parse('$teacherBase/exams/$id/'), headers: headers);
    return resp.statusCode == 204;
  }

  /// Get authentication headers with token (private)
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // If SharedPreferences fails, continue without token
    }
    
    return headers;
  }

  /// Get authentication headers with token (public)
  static Future<Map<String, String>> getAuthHeaders() async {
    return await _getAuthHeaders();
  }

  /// Fetch chat messages between two users using ChatMessage API (new WhatsApp/Telegram-like chat)
  /// Uses the new ChatMessage model endpoint for real-time chat history
  static Future<List<Map<String, dynamic>>> fetchChatMessages(String senderUsername, String recipientUsername) async {
    final uri = Uri.parse('$chatMessagesEndpoint?sender=$senderUsername&recipient=$recipientUsername');
    final headers = await _getAuthHeaders();
    final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data is List) return List<Map<String, dynamic>>.from(data);
      if (data is Map && data.containsKey('results')) {
        return List<Map<String, dynamic>>.from(data['results'] as List);
      }
      return [];
    }
    throw Exception('Failed to fetch chat messages: ${resp.statusCode}');
  }

  /// Fetch chat messages between two users (sender and recipient usernames)
  /// @deprecated Use fetchChatMessages instead for real-time chat. This is kept for backward compatibility.
  static Future<List<Map<String, dynamic>>> fetchCommunications(String senderUsername, String recipientUsername) async {
    final uri = Uri.parse('$communicationsEndpoint?sender=$senderUsername&recipient=$recipientUsername');
    final headers = await _getAuthHeaders();
    final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
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
    final headers = await _getAuthHeaders();
    final resp = await http
        .get(Uri.parse(teachersEndpoint), headers: headers)
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
    final headers = await _getAuthHeaders();
    final resp = await http
        .get(Uri.parse(studentsEndpoint), headers: headers)
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
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse(parentEndpoint), headers: headers)
          .timeout(const Duration(seconds: 10));
      
      // Log response for debugging
      print('Parent profile API response: status=${resp.statusCode}, body=${resp.body}');
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List && data.isNotEmpty) {
          return Map<String, dynamic>.from(data[0] as Map);
        }
        if (data is Map) {
          // Check if it's an error response
          if (data.containsKey('error')) {
            print('Parent profile API returned error: ${data['error']}');
            return null;
          }
          return Map<String, dynamic>.from(data);
        }
      } else if (resp.statusCode == 404) {
        print('Parent profile not found (404)');
        return null;
      } else {
        print('Parent profile API error: status=${resp.statusCode}, body=${resp.body}');
        return null;
      }
      return null;
    } catch (e) {
      print('Exception fetching parent profile: $e');
      return null; // Return null instead of throwing to allow fallback handling
    }
  }

  /// Fetch student data by student ID
  static Future<Map<String, dynamic>?> fetchStudentById(int studentId) async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse('$studentsEndpoint$studentId/'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  /// Fetch current logged-in student's profile
  static Future<Map<String, dynamic>?> fetchStudentProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse('$parentBase/student-profile/'), headers: headers)
          .timeout(const Duration(seconds: 10));
      
      print('Student profile API response: status=${resp.statusCode}');
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('Student profile data keys: ${data is Map<String, dynamic> ? data.keys : 'not a map'}');
        if (data is Map) {
          print('Student name in profile: ${data['student_name']}');
          print('Student email in profile: ${data['email']}');
          return Map<String, dynamic>.from(data);
        }
      } else {
        print('Student profile API error: status=${resp.statusCode}, body=${resp.body}');
      }
      return null;
    } catch (e) {
      print('Exception fetching student profile: $e');
      return null; // Return null instead of throwing to allow fallback handling
    }
  }

  static Future<Map<String, dynamic>?> fetchAttendanceHistory({String? studentId}) async {
    try {
      final headers = await _getAuthHeaders();
      String url = '$parentBase/dashboard/attendance_history/';
      if (studentId != null) {
        url += '?student_id=$studentId';
      }
      final resp = await http.get(Uri.parse(url), headers: headers);
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching attendance history: $e');
      return null;
    }
  }
  static Future<Map<String, dynamic>?> fetchDayDetails({
    required DateTime date,
    required String studentId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final url = '$parentBase/dashboard/day_details/?date=$dateStr&student_id=$studentId';
      
      print('Fetching day details: $url');
      final resp = await http.get(Uri.parse(url), headers: headers);
      
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        print('Error fetching day details: ${resp.body}');
      }
      return null;
    } catch (e) {
      print('Exception fetching day details: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchStudentExams({
    required String studentId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = '$parentBase/dashboard/student_exams/?student_id=$studentId';
      
      print('Fetching student exams: $url');
      final resp = await http.get(Uri.parse(url), headers: headers);
      
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as List<dynamic>;
      } else {
        print('Error fetching student exams: ${resp.body}');
      }
      return null;
    } catch (e) {
      print('Exception fetching student exams: $e');
      return null;
    }
  }
}
