import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = 'http://localhost:8000/api';
  static const _base = 'http://localhost:8000/api/management-admin';
  static const teachersEndpoint = '$_base/teachers/';
  static const studentsEndpoint = '$_base/students/';

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
      debugPrint('Error getting auth headers: $e');
    }
    
    return headers;
  }

  /// Get authentication headers with token (public)
  static Future<Map<String, String>> getAuthHeaders() async {
    return await _getAuthHeaders();
  }

  static Future<List<dynamic>> fetchStudents() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse(studentsEndpoint), headers: headers)
          .timeout(const Duration(seconds: 15));
      
      debugPrint('Fetch students status: ${resp.statusCode}');
      final bodyPreview = resp.body.length > 200 ? resp.body.substring(0, 200) : resp.body;
      debugPrint('Fetch students response preview: $bodyPreview');
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          debugPrint('Fetched ${data.length} students');
          return data;
        }
        if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List;
          debugPrint('Fetched ${results.length} students from paginated response');
          return results;
        }
        debugPrint('No students found in response');
        return [];
      }
      throw Exception('Failed to fetch students: ${resp.statusCode}');
    } catch (e) {
      debugPrint('Error fetching students: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> fetchTeachers() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse(teachersEndpoint), headers: headers)
          .timeout(const Duration(seconds: 15));
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          debugPrint('Fetched ${data.length} teachers');
          return data;
        }
        if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List;
          debugPrint('Fetched ${results.length} teachers from paginated response');
          return results;
        }
        return [];
      }
      throw Exception('Failed to fetch teachers: ${resp.statusCode}');
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      rethrow;
    }
  }

  /// Fetch current logged-in teacher's profile
  static Future<Map<String, dynamic>?> fetchTeacherProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse('http://localhost:8000/api/teacher/profile/'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      debugPrint('Failed to fetch teacher profile: ${resp.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Failed to fetch teacher profile: $e');
      return null;
    }
  }

  /// Fetch all communications for the teacher
  static Future<List<dynamic>> fetchCommunications() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse('http://localhost:8000/api/teacher/communications/'), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) return data;
        return [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch communications: $e');
    }
  }

  /// Fetch chat messages between two users using ChatMessage API (new WhatsApp/Telegram-like chat)
  /// Uses the new ChatMessage model endpoint for real-time chat history
  static Future<List<Map<String, dynamic>>> fetchChatMessages(String senderUsername, String recipientUsername) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('http://localhost:8000/api/student-parent/chat-messages/').replace(
        queryParameters: {
          'sender': senderUsername,
          'recipient': recipientUsername,
        },
      );
      final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map && data.containsKey('results')) {
          return List<Map<String, dynamic>>.from(data['results'] as List);
        }
        return [];
      }
      debugPrint('Failed to fetch chat messages: ${resp.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Failed to fetch chat messages: $e');
      return [];
    }
  }

  /// Fetch chat history with a specific user
  /// @deprecated Use fetchChatMessages instead for real-time chat. This is kept for backward compatibility.
  static Future<List<dynamic>> fetchChatHistory(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('http://localhost:8000/api/teacher/chat-history/').replace(
        queryParameters: {'user_id': userId},
      );
      final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) return data;
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('Failed to fetch chat history: $e');
      return [];
    }
  }

  /// Fetch students from teacher's assigned classes via class-students endpoint
  static Future<List<dynamic>> fetchStudentsFromClasses() async {
    try {
      final headers = await _getAuthHeaders();
      final resp = await http
          .get(Uri.parse('http://localhost:8000/api/teacher/class-students/'), headers: headers)
          .timeout(const Duration(seconds: 15));
      
      debugPrint('Fetch class-students status: ${resp.statusCode}');
      final bodyPreview = resp.body.length > 200 ? resp.body.substring(0, 200) : resp.body;
      debugPrint('Fetch class-students response preview: $bodyPreview');
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        List<dynamic> classStudents = [];
        if (data is List) {
          classStudents = data;
        } else if (data is Map && data.containsKey('results')) {
          classStudents = data['results'] as List;
        }
        
        debugPrint('Fetched ${classStudents.length} class-student records');
        
        // Extract unique students from class-student records
        final studentsMap = <String, dynamic>{};
        for (var cs in classStudents) {
          try {
            final student = cs['student'];
            if (student != null && student is Map) {
              // Try multiple possible ID fields
              final studentId = student['id']?.toString() ?? 
                               student['student_id']?.toString() ?? 
                               student['user']?['user_id']?.toString() ?? '';
              
              if (studentId.isNotEmpty && !studentsMap.containsKey(studentId)) {
                // Ensure the student object has all necessary fields
                // If student comes from class-student, it might need user data merged
                final studentData = Map<String, dynamic>.from(student);
                
                // If student doesn't have 'user' field but has user data directly, structure it
                if (!studentData.containsKey('user') && studentData.containsKey('username')) {
                  studentData['user'] = {
                    'user_id': studentData['user_id'] ?? studentData['id'],
                    'username': studentData['username'],
                    'first_name': studentData['first_name'] ?? '',
                    'last_name': studentData['last_name'] ?? '',
                  };
                }
                
                studentsMap[studentId] = studentData;
              }
            }
          } catch (e) {
            debugPrint('Error processing class-student record: $e');
          }
        }
        
        final uniqueStudents = studentsMap.values.toList();
        debugPrint('Extracted ${uniqueStudents.length} unique students from classes');
        return uniqueStudents;
      } else {
        debugPrint('Failed to fetch class-students: ${resp.statusCode} - ${resp.body}');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching students from classes: $e');
      return [];
    }
  }


  /// General authenticated request helper
  static Future<http.Response> authenticatedRequest(String endpoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    final headers = await _getAuthHeaders();
    
    // Handle both full URLs and relative paths
    Uri uri;
    if (endpoint.startsWith('http')) {
      uri = Uri.parse(endpoint);
    } else {
      // Ensure clean slash handling
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      uri = Uri.parse('$cleanBase/$cleanEndpoint');
    }
    
    debugPrint('Making $method request to: $uri');
    
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }
      return response;
    } catch (e) {
      debugPrint('Error in authenticatedRequest: $e');
      // Return a 500 equivalent response on error
      return http.Response('{"error": "$e"}', 500); 
    }
  }
}

