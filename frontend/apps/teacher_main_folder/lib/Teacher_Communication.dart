import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart' as api;
import 'services/realtime_chat_service.dart';

class TeacherCommunicationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode initialThemeMode;

  const TeacherCommunicationScreen({
    super.key,
    required this.onToggleTheme,
    this.initialThemeMode = ThemeMode.light,
  });

  @override
  State<TeacherCommunicationScreen> createState() => _TeacherCommunicationScreenState();
}

class _TeacherCommunicationScreenState extends State<TeacherCommunicationScreen> {
  // Data
  final Map<String, ChatContact> _contacts = {};
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, int> _unreadCounts = {}; // Track unread messages per contact
  String? _selectedContactId;
  String? _currentTeacherUsername;
  String? _currentTeacherName; // Teacher's display name for room ID
  String? _currentTeacherUserId;
  bool _isLoading = true;
  
  // Helper function to normalize names for room IDs
  String normalizeNameForRoomId(String name) {
    if (name.isEmpty) return '';
    // Convert to lowercase, replace spaces with underscores, remove special characters
    return name
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // Keep only alphanumeric and underscore
  }
  
  // Search and filters
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedClassFilter;
  String? _selectedGradeFilter;
  bool _showTeachersOnly = false;
  bool _showGroupsOnly = false;
  
  // Groups
  final Map<String, ChatGroup> _groups = {};
  
  // Chat
  final TextEditingController _messageController = TextEditingController();
  RealtimeChatService? _chatService;
  StreamSubscription? _chatSubscription;
  
  // Global chat listener for unread counts
  RealtimeChatService? _globalChatService;
  StreamSubscription? _globalChatSubscription;
  
  // UI
  final ScrollController _scrollController = ScrollController();
  
  static const List<String> _availableClasses = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  static const List<String> _availableGrades = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadData();
    _initializeGlobalChatListener();
  }
  
  // Initialize global chat listener to track unread counts
  Future<void> _initializeGlobalChatListener() async {
    try {
      if (_currentTeacherName == null || _currentTeacherName!.isEmpty) {
        // Wait for teacher data to load
        await Future.delayed(const Duration(seconds: 2));
        if (_currentTeacherName == null || _currentTeacherName!.isEmpty) {
          debugPrint('Cannot initialize global chat listener: teacher name not available');
          return;
        }
      }
      
      // Connect to a general room to listen for all messages
      final teacherName = normalizeNameForRoomId(_currentTeacherName!);
      if (teacherName.isEmpty) {
        debugPrint('Cannot initialize global chat listener: normalized teacher name is empty');
        return;
      }
      
      _globalChatService = RealtimeChatService(baseWsUrl: 'ws://localhost:8000');
      // Use a general room ID - we'll filter by recipient in the listener
      await _globalChatService!.connect(roomId: 'teacher_$teacherName', chatType: 'teacher-student');
      
      _globalChatSubscription = _globalChatService!.stream?.listen((event) {
        try {
          final data = event is String ? jsonDecode(event) : event;
          if (data is Map) {
            final messageType = data['type']?.toString() ?? 'message';
            if (messageType == 'message') {
              final sender = data['sender']?.toString() ?? '';
              final senderUsername = data['sender_username']?.toString() ?? sender;
              final senderId = data['sender_id']?.toString() ?? '';
              final recipient = data['recipient']?.toString() ?? '';
              final recipientUsername = data['recipient_username']?.toString() ?? recipient;
              final messageText = data['message']?.toString() ?? '';
              final timestamp = data['timestamp']?.toString() ?? DateTime.now().toIso8601String();
              final messageId = data['message_id']?.toString() ?? '';
              
              if (messageText.isEmpty) return;
              
              // Check if message is for this teacher (from any contact)
              final normalizedTeacherName = normalizeNameForRoomId(_currentTeacherName ?? '');
              final normalizedRecipient = normalizeNameForRoomId(recipient);
              
              final isToThisTeacher = (
                recipient == _currentTeacherUsername ||
                recipientUsername == _currentTeacherUsername ||
                normalizedRecipient == normalizedTeacherName ||
                recipient.toLowerCase().contains(_currentTeacherName!.toLowerCase())
              );
              
              // Also check by name/username
              ChatContact? matchedContact;
              for (var contact in _contacts.values) {
                if (senderId == contact.id ||
                    senderUsername == contact.username ||
                    sender == contact.name ||
                    sender.toLowerCase().contains(contact.name.toLowerCase())) {
                  matchedContact = contact;
                  break;
                }
              }
              
              if (isToThisTeacher && matchedContact != null) {
                // Update messages for this contact
                setState(() {
                  // Add message to contact's message list
                  _messages[matchedContact!.id] ??= [];
                  
                  // Check for duplicates
                  final isDuplicate = _messages[matchedContact.id]!.any((msg) => 
                    msg.id == messageId || 
                    (msg.text == messageText && msg.timestamp == timestamp)
                  );
                  
                  if (!isDuplicate && messageId.isNotEmpty) {
                    _messages[matchedContact.id]!.add(ChatMessage(
                      id: messageId,
                      text: messageText,
                      senderId: senderId,
                      isSent: false, // Received message
                      timestamp: timestamp,
                    ));
                    
                    // Increment unread count if chat is not open
                    if (_selectedContactId != matchedContact.id) {
                      _unreadCounts[matchedContact.id] = (_unreadCounts[matchedContact.id] ?? 0) + 1;
                      debugPrint('✓ Unread count updated for ${matchedContact.name}: ${_unreadCounts[matchedContact.id]}');
                    }
                  }
                });
              }
            }
          }
        } catch (e) {
          debugPrint('Error in global chat listener: $e');
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize global chat listener: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _chatService?.disconnect();
    _chatSubscription?.cancel();
    _globalChatService?.disconnect();
    _globalChatSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load teacher profile
      final teacherProfile = await api.ApiService.fetchTeacherProfile();
      String? currentSchoolId;
      if (teacherProfile != null) {
        final user = teacherProfile['user'] as Map<String, dynamic>?;
        _currentTeacherUsername = user?['username'] as String?;
        _currentTeacherUserId = user?['user_id']?.toString();
        
        // Get teacher's display name for room ID (not email/username)
        final teacherFirstName = user?['first_name'] as String? ?? '';
        final teacherLastName = user?['last_name'] as String? ?? '';
        final teacherFullName = '$teacherFirstName $teacherLastName'.trim();
        final teacherName = teacherProfile['name'] as String? ?? '';
        _currentTeacherName = teacherName.isNotEmpty ? teacherName : 
                            (teacherFullName.isNotEmpty ? teacherFullName : 
                            (_currentTeacherUsername ?? 'Teacher'));
        
        debugPrint('Teacher loaded: $_currentTeacherUsername (ID: $_currentTeacherUserId, Name: $_currentTeacherName)');
        
        // Get school_id from teacher profile for filtering
        currentSchoolId = teacherProfile['school_id']?.toString();
        final schoolName = teacherProfile['school_name']?.toString() ?? 'unknown';
        debugPrint('Teacher school - ID: $currentSchoolId, Name: $schoolName');
      }

      // Fetch students - try class-students first, then fallback
      debugPrint('Fetching students...');
      List<dynamic> students = await api.ApiService.fetchStudentsFromClasses();
      debugPrint('Fetched ${students.length} students from class-students');
      
      if (students.isEmpty) {
        try {
          students = await api.ApiService.fetchStudents();
          debugPrint('Fetched ${students.length} students from management-admin');
          if (students.isEmpty) {
            debugPrint('WARNING: No students found. This might mean:');
            debugPrint('1. No students are assigned to this school');
            debugPrint('2. Students are not linked to classes');
            debugPrint('3. School filtering is too restrictive');
          }
        } catch (e) {
          debugPrint('Error fetching students: $e');
        }
      }

      // Fetch teachers
      debugPrint('Fetching teachers...');
      final teachers = await api.ApiService.fetchTeachers();
      debugPrint('Fetched ${teachers.length} teachers');

      // Process students
      for (var studentData in students) {
        try {
          Map<String, dynamic>? user;
          Map<String, dynamic> studentMap = studentData is Map<String, dynamic> ? studentData : {};
          
          // Handle both nested and flat structures
          if (studentMap.containsKey('user') && studentMap['user'] is Map) {
            user = studentMap['user'] as Map<String, dynamic>?;
          } else if (studentMap.containsKey('username') || studentMap.containsKey('first_name')) {
            user = studentMap;
          } else {
            user = {};
          }
          
          // Get student ID - use email (primary key) or student_id
          final studentId = studentMap['email']?.toString() ?? 
                           studentMap['student_id']?.toString() ?? 
                           user?['user_id']?.toString() ?? 
                           studentMap['user_id']?.toString() ?? '';
          
          // Use student_name as primary identifier (not username)
          final studentName = studentMap['student_name']?.toString() ?? 
                            studentMap['name']?.toString() ?? '';
          
          // Fallback to user name if student_name not available
          final firstName = user?['first_name'] as String? ?? '';
          final lastName = user?['last_name'] as String? ?? '';
          final userName = '$firstName $lastName'.trim();
          
          // Use student_name, or user name, or email as display name
          final displayName = studentName.isNotEmpty 
              ? studentName 
              : (userName.isNotEmpty ? userName : studentMap['email']?.toString() ?? 'Student');
          
          // Use email or student_id as username for chat
          final username = studentMap['email']?.toString() ?? 
                          user?['email']?.toString() ?? 
                          studentMap['student_id']?.toString() ?? 
                          studentId;
          
          final className = studentMap['applying_class'] as String? ?? 
                           studentMap['class_name'] as String? ?? '';
          final grade = studentMap['grade'] as String? ?? '';

          // Get student's school_id for filtering
          final studentSchoolId = studentMap['school_id']?.toString();
          
          // Only add students with matching school_id (if currentSchoolId is available)
          final schoolMatches = currentSchoolId == null || studentSchoolId == null || currentSchoolId == studentSchoolId;
          
          // Accept students if we have at least studentId and displayName, and school_id matches
          if (studentId.isNotEmpty && displayName.isNotEmpty && schoolMatches) {
            _contacts[studentId] = ChatContact(
              id: studentId,
              name: displayName,
              username: username.isNotEmpty ? username : studentId,
              type: ContactType.student,
              className: className,
              grade: grade,
              avatar: _getInitials(displayName),
            );
            _messages[studentId] = [];
            debugPrint('Added student: $displayName (ID: $studentId, School: $studentSchoolId)');
          } else {
            if (!schoolMatches) {
              debugPrint('Skipped student - school_id mismatch: student=$studentSchoolId, teacher=$currentSchoolId');
            } else {
              debugPrint('Skipped student - missing ID or name: studentId=$studentId, displayName=$displayName');
            }
          }
        } catch (e) {
          debugPrint('Error processing student: $e');
        }
      }

      // Process teachers
      for (var teacherData in teachers) {
        try {
          Map<String, dynamic>? user;
          Map<String, dynamic> teacherMap = teacherData is Map<String, dynamic> ? teacherData : {};
          
          if (teacherMap.containsKey('user') && teacherMap['user'] is Map) {
            user = teacherMap['user'] as Map<String, dynamic>?;
          } else if (teacherMap.containsKey('username') || teacherMap.containsKey('first_name')) {
            user = teacherMap;
          } else {
            user = {};
          }
          
          final userId = user?['user_id']?.toString() ?? 
                        teacherMap['user_id']?.toString() ?? '';
          final username = user?['username'] as String? ?? 
                          user?['email'] as String? ?? 
                          teacherMap['username'] as String? ?? '';
          final firstName = user?['first_name'] as String? ?? '';
          final lastName = user?['last_name'] as String? ?? '';
          final name = '$firstName $lastName'.trim();
          final subject = teacherMap['subject'] as String? ?? '';
          final className = teacherMap['class_assigned'] as String? ?? '';
          
          // Get teacher's school_id for filtering
          final teacherSchoolId = teacherMap['school_id']?.toString();
          
          // Only add teachers with matching school_id (if currentSchoolId is available)
          final schoolMatches = currentSchoolId == null || teacherSchoolId == null || currentSchoolId == teacherSchoolId;

          if (userId.isNotEmpty && username.isNotEmpty && userId != _currentTeacherUserId && schoolMatches) {
            _contacts[userId] = ChatContact(
              id: userId,
              name: name.isNotEmpty ? name : username,
              username: username,
              type: ContactType.teacher,
              subject: subject,
              className: className,
              avatar: _getInitials(name.isNotEmpty ? name : username),
            );
            _messages[userId] = [];
            debugPrint('Added teacher: ${name.isNotEmpty ? name : username} (ID: $userId, School: $teacherSchoolId)');
          } else if (!schoolMatches) {
            debugPrint('Skipped teacher - school_id mismatch: teacher=$teacherSchoolId, current=$currentSchoolId');
          }
        } catch (e) {
          debugPrint('Error processing teacher: $e');
        }
      }

      debugPrint('Total contacts loaded: ${_contacts.length}');
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Load chat history - now handled in ChatScreen widget
  // Keeping this for reference but not called anymore
  @Deprecated('Use ChatScreen widget instead')
  Future<void> _loadChatHistory() async {
    if (_selectedContactId == null || _currentTeacherUserId == null || _currentTeacherUsername == null) return;
    
    final contact = _contacts[_selectedContactId];
    if (contact == null) {
      debugPrint('Contact not found for ID: $_selectedContactId');
      return;
    }
    
    try {
      debugPrint('Loading chat history for: ${contact.name} (${contact.username})');
      debugPrint('Teacher username: $_currentTeacherUsername');
      
      // Use the new ChatMessage API with sender and recipient usernames
      final messages = await api.ApiService.fetchChatMessages(_currentTeacherUsername!, contact.username);
      
      if (messages.isNotEmpty) {
        setState(() {
          _messages[_selectedContactId!] = messages.map((msg) {
            final sender = msg['sender'] is Map ? Map<String, dynamic>.from(msg['sender'] as Map) : null;
            final senderId = sender?['user_id']?.toString() ?? '';
            final senderUsername = sender?['username']?.toString() ?? '';
            
            // Determine if message was sent by current teacher
            final isSent = senderId == _currentTeacherUserId || 
                          senderUsername == _currentTeacherUsername;
            
            // Use message_text from ChatMessage model (fallback to message for backward compatibility)
            final messageText = msg['message_text']?.toString() ?? 
                               msg['message']?.toString() ?? '';
            
            return ChatMessage(
              id: msg['message_id']?.toString() ?? 
                  msg['id']?.toString() ?? 
                  DateTime.now().millisecondsSinceEpoch.toString(),
              text: messageText,
              senderId: senderId,
              isSent: isSent,
              timestamp: msg['created_at'] as String? ?? DateTime.now().toIso8601String(),
            );
          }).toList();
        });
        _scrollToBottom();
        debugPrint('Loaded ${_messages[_selectedContactId!]!.length} chat messages');
      } else {
        debugPrint('No chat messages found');
        // Try fallback to old API if new API returns empty
        try {
          debugPrint('Trying fallback to old chat history API...');
          final history = await api.ApiService.fetchChatHistory(_selectedContactId!);
          if (history.isNotEmpty) {
            setState(() {
              _messages[_selectedContactId!] = history.map((msg) {
                final sender = msg['sender'] as Map<String, dynamic>?;
                final senderId = sender?['user_id']?.toString() ?? '';
                return ChatMessage(
                  id: msg['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  text: msg['message'] as String? ?? '',
                  senderId: senderId,
                  isSent: senderId == _currentTeacherUserId,
                  timestamp: msg['created_at'] as String? ?? DateTime.now().toIso8601String(),
                );
              }).toList();
            });
            _scrollToBottom();
            debugPrint('Loaded ${_messages[_selectedContactId!]!.length} messages from fallback API');
          }
        } catch (fallbackError) {
          debugPrint('Fallback API also failed: $fallbackError');
        }
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      // Try fallback to old API
      try {
        debugPrint('Trying fallback to old chat history API...');
        final history = await api.ApiService.fetchChatHistory(_selectedContactId!);
        if (history.isNotEmpty) {
          setState(() {
            _messages[_selectedContactId!] = history.map((msg) {
              final sender = msg['sender'] as Map<String, dynamic>?;
              final senderId = sender?['user_id']?.toString() ?? '';
              return ChatMessage(
                id: msg['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                text: msg['message'] as String? ?? '',
                senderId: senderId,
                isSent: senderId == _currentTeacherUserId,
                timestamp: msg['created_at'] as String? ?? DateTime.now().toIso8601String(),
              );
            }).toList();
          });
          _scrollToBottom();
        }
      } catch (fallbackError) {
        debugPrint('Fallback API also failed: $fallbackError');
      }
    }
  }

  List<ChatContact> get _filteredContacts {
    final filtered = _contacts.values.where((contact) {
      // Search filter
      if (_searchQuery.isNotEmpty && !contact.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      
      // Type filters
      if (_showTeachersOnly && contact.type != ContactType.teacher) return false;
      if (_showGroupsOnly && contact.type != ContactType.group) return false;
      // Show students by default (when neither Teachers nor Groups is selected)
      if (!_showTeachersOnly && !_showGroupsOnly && contact.type != ContactType.student) return false;
      
      // Class filter - normalize comparison (handle "Class 10" vs "10" format)
      if (_selectedClassFilter != null) {
        final contactClass = (contact.className ?? '').trim();
        final filterClass = _selectedClassFilter!.trim();
        // Extract just the number from "Class 10" format or use as-is
        final contactClassNum = contactClass.replaceAll(RegExp(r'[^0-9]'), '');
        final filterClassNum = filterClass.replaceAll(RegExp(r'[^0-9]'), '');
        if (contactClassNum.isNotEmpty && filterClassNum.isNotEmpty) {
          if (contactClassNum != filterClassNum) return false;
        } else if (contactClass.toLowerCase() != filterClass.toLowerCase()) {
          return false;
        }
      }
      
      // Grade filter - normalize comparison
      if (_selectedGradeFilter != null) {
        final contactGrade = (contact.grade ?? '').trim().toUpperCase();
        final filterGrade = _selectedGradeFilter!.trim().toUpperCase();
        if (contactGrade != filterGrade) return false;
      }
      
      return true;
    }).toList();
    
    // Sort by most recent message time (WhatsApp/Telegram style)
    filtered.sort((a, b) {
      final aMessages = _messages[a.id];
      final bMessages = _messages[b.id];
      
      // Get last message timestamp for each contact
      DateTime? aTime;
      DateTime? bTime;
      
      if (aMessages != null && aMessages.isNotEmpty) {
        try {
          aTime = DateTime.parse(aMessages.last.timestamp);
        } catch (e) {
          aTime = null;
        }
      }
      
      if (bMessages != null && bMessages.isNotEmpty) {
        try {
          bTime = DateTime.parse(bMessages.last.timestamp);
        } catch (e) {
          bTime = null;
        }
      }
      
      // Contacts with messages come first, sorted by most recent
      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime); // Most recent first
      } else if (aTime != null) {
        return -1; // a has messages, b doesn't
      } else if (bTime != null) {
        return 1; // b has messages, a doesn't
      } else {
        // Both have no messages, sort by name
        return a.name.compareTo(b.name);
      }
    });
    
    return filtered;
  }

  List<ChatGroup> get _filteredGroups {
    return _groups.values.where((group) {
      if (_searchQuery.isNotEmpty && !group.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      // Class filter - normalize comparison
      if (_selectedClassFilter != null) {
        final groupClass = (group.className ?? '').trim();
        final filterClass = _selectedClassFilter!.trim();
        final groupClassNum = groupClass.replaceAll(RegExp(r'[^0-9]'), '');
        final filterClassNum = filterClass.replaceAll(RegExp(r'[^0-9]'), '');
        if (groupClassNum.isNotEmpty && filterClassNum.isNotEmpty) {
          if (groupClassNum != filterClassNum) return false;
        } else if (groupClass.toLowerCase() != filterClass.toLowerCase()) {
          return false;
        }
      }
      // Grade filter - normalize comparison
      if (_selectedGradeFilter != null) {
        final groupGrade = (group.grade ?? '').trim().toUpperCase();
        final filterGrade = _selectedGradeFilter!.trim().toUpperCase();
        if (groupGrade != filterGrade) return false;
      }
      return true;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _selectContact(String contactId) async {
    // Navigate to separate chat screen
    final contact = _contacts[contactId];
    if (contact == null) return;
    
    // Reset unread count for the selected contact
    setState(() {
      _unreadCounts[contactId] = 0;
    });
    
    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatScreen(
          contact: contact,
          teacherUsername: _currentTeacherUsername ?? '',
          teacherName: _currentTeacherName ?? '',
          teacherUserId: _currentTeacherUserId ?? '',
          messages: _messages[contactId] ?? [],
          unreadCounts: _unreadCounts,
        ),
      ),
    ).then((_) {
      // Reload data when returning from chat screen to refresh unread counts
      setState(() {
        // Force UI update
      });
    });
  }

  // Initialize realtime chat - now handled in ChatScreen widget
  // Keeping this for reference but not called anymore
  @Deprecated('Use ChatScreen widget instead')
  Future<void> _initializeRealtimeChat() async {
    if (_selectedContactId == null || _currentTeacherName == null) {
      debugPrint('Cannot initialize chat: missing contact or teacher name');
      return;
    }
    
    final contact = _contacts[_selectedContactId];
    if (contact == null) {
      debugPrint('Contact not found: $_selectedContactId');
      return;
    }
    
    // Ensure contact has a name (not email/username)
    if (contact.name.isEmpty) {
      debugPrint('Cannot initialize chat: contact name is empty');
      return;
    }
    
    try {
      // Generate room ID using names only (no email fallback)
      final teacherName = normalizeNameForRoomId(_currentTeacherName!);
      final contactName = normalizeNameForRoomId(contact.name);
      
      if (teacherName.isEmpty || contactName.isEmpty) {
        debugPrint('Cannot initialize chat: normalized names are empty (teacher: $teacherName, contact: $contactName)');
        return;
      }
      
      final identifiers = [teacherName, contactName]..sort();
      final roomId = identifiers.join('_');
      
      final chatType = contact.type == ContactType.student 
          ? 'teacher-student' 
          : contact.type == ContactType.teacher 
              ? 'teacher-teacher' 
              : 'teacher-group';
      
      debugPrint('Initializing chat: roomId=$roomId, type=$chatType');
      debugPrint('  Teacher name: $_currentTeacherName -> $teacherName');
      debugPrint('  Contact name: ${contact.name} -> $contactName');
      
      _chatService = RealtimeChatService(baseWsUrl: 'ws://localhost:8000');
      await _chatService!.connect(roomId: roomId, chatType: chatType);
      
      _chatSubscription = _chatService!.stream?.listen((event) {
        try {
          final data = event is String ? jsonDecode(event) : event;
          if (data is Map) {
            final messageType = data['type']?.toString() ?? 'message';
            
            if (messageType == 'message') {
              final sender = data['sender']?.toString() ?? '';
              final senderUsername = data['sender_username']?.toString() ?? sender;
              final senderId = data['sender_id']?.toString() ?? '';
              final recipient = data['recipient']?.toString() ?? '';
              final recipientId = data['recipient_id']?.toString() ?? '';
              final messageText = data['message']?.toString() ?? '';
              final timestamp = data['timestamp']?.toString() ?? DateTime.now().toIso8601String();
              
              if (messageText.isEmpty) return;
              
              // IMPORTANT: Only process messages for the current conversation
              // Check if this message is between the current teacher and the selected contact
              final isFromCurrentContact = (
                senderUsername == contact.username ||
                senderId == contact.id ||
                sender == contact.name
              );
              
              final isToCurrentContact = (
                recipient == contact.username ||
                recipientId == contact.id ||
                recipient == contact.name
              );
              
              final isFromCurrentTeacher = (
                senderUsername == _currentTeacherUsername ||
                senderId == _currentTeacherUserId ||
                sender == _currentTeacherName
              );
              
              final isToCurrentTeacher = (
                recipient == _currentTeacherUsername ||
                recipientId == _currentTeacherUserId
              );
              
              // Message is for this conversation if:
              // 1. From contact to teacher, OR
              // 2. From teacher to contact
              final isForThisConversation = (
                (isFromCurrentContact && isToCurrentTeacher) ||
                (isFromCurrentTeacher && isToCurrentContact)
              );
              
              if (!isForThisConversation) {
                debugPrint('Ignoring message not for this conversation: sender=$senderUsername, recipient=$recipient, contact=${contact.name}');
                return;
              }
              
              // Check for duplicate messages using message_id (most reliable)
              final messageId = data['message_id']?.toString() ?? '';
              final existingMessages = _messages[_selectedContactId!] ?? [];
              final isDuplicate = messageId.isNotEmpty 
                ? existingMessages.any((msg) => msg.id == messageId)
                : existingMessages.any((msg) => 
                    msg.text == messageText && 
                    (isFromCurrentTeacher ? msg.isSent : !msg.isSent) &&
                    (timestamp == msg.timestamp || 
                     (DateTime.tryParse(timestamp) != null && DateTime.tryParse(msg.timestamp) != null &&
                      DateTime.tryParse(timestamp)!.difference(DateTime.tryParse(msg.timestamp)!).inSeconds.abs() < 2))
                  );
              
              // Only process if message is for currently selected contact
              // This ensures messages only appear in the correct conversation
              if (_selectedContactId != contact.id) {
                // Message is not for currently open conversation
                if (!isFromCurrentTeacher) {
                  // Increment unread count for messages from contact
                  setState(() {
                    _unreadCounts[contact.id] = (_unreadCounts[contact.id] ?? 0) + 1;
                  });
                  debugPrint('Unread count for ${contact.name}: ${_unreadCounts[contact.id]}');
                }
                return; // Don't add to UI if conversation is not open
              }
              
              if (!isDuplicate) {
                // Message is for currently open conversation
                setState(() {
                  _messages[_selectedContactId!] ??= [];
                  
                  if (isFromCurrentTeacher && messageId.isNotEmpty) {
                    // Teacher's message - try to update existing temporary message with real message_id
                    // Look for temp message with same text sent within last 5 seconds
                    final now = DateTime.now();
                    final existingIndex = _messages[_selectedContactId!]!.lastIndexWhere((msg) {
                      if (!msg.isSent || msg.text != messageText) return false;
                      if (msg.id.startsWith('temp_')) {
                        try {
                          final msgTime = DateTime.parse(msg.timestamp);
                          final diff = now.difference(msgTime).abs();
                          return diff.inSeconds < 5;
                        } catch (e) {
                          return false;
                        }
                      }
                      return false;
                    });
                    
                    if (existingIndex != -1) {
                      // Update existing temp message with real ID
                      _messages[_selectedContactId!]![existingIndex] = ChatMessage(
                        id: messageId,
                        text: messageText,
                        senderId: _currentTeacherUserId ?? '',
                        isSent: true,
                        timestamp: timestamp,
                      );
                      debugPrint('Updated temp message with real ID: $messageId');
                    } else {
                      // Check if message with this ID already exists
                      final alreadyExists = _messages[_selectedContactId!]!.any((msg) => msg.id == messageId);
                      if (!alreadyExists) {
                        // Add new message
                        _messages[_selectedContactId!]!.add(ChatMessage(
                          id: messageId,
                          text: messageText,
                          senderId: _currentTeacherUserId ?? '',
                          isSent: true,
                          timestamp: timestamp,
                        ));
                      }
                    }
                  } else {
                    // Message from contact - check if already exists
                    final finalMessageId = messageId.isNotEmpty ? messageId : DateTime.now().millisecondsSinceEpoch.toString();
                    final alreadyExists = _messages[_selectedContactId!]!.any((msg) => 
                      msg.id == finalMessageId || (msg.text == messageText && !msg.isSent)
                    );
                    if (!alreadyExists) {
                      _messages[_selectedContactId!]!.add(ChatMessage(
                        id: finalMessageId,
                        text: messageText,
                        senderId: contact.id,
                        isSent: false,
                        timestamp: timestamp,
                      ));
                    }
                  }
                  // Reset unread count for this contact since chat is open
                  setState(() {
                    _unreadCounts[contact.id] = 0;
                  });
                });
                _scrollToBottom();
                debugPrint('Received message for ${contact.name}: ${isFromCurrentTeacher ? "from teacher" : "from contact"} - $messageText');
              } else {
                debugPrint('Duplicate message ignored (ID: $messageId, text: $messageText)');
              }
            }
          }
        } catch (e) {
          debugPrint('Error processing message: $e');
        }
      });
      
      debugPrint('Chat initialized successfully');
    } catch (e) {
      debugPrint('Error initializing realtime chat: $e');
    }
  }

  // _sendMessage is now handled in ChatScreen widget - not needed in main screen

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        contacts: _contacts.values.where((c) => c.type == ContactType.student).toList(),
        onGroupCreated: (group) {
          setState(() {
            _groups[group.id] = group;
            _contacts[group.id] = ChatContact(
              id: group.id,
              name: group.name,
              username: group.id,
              type: ContactType.group,
              className: group.className,
              grade: group.grade,
              avatar: '👥',
            );
            _messages[group.id] = [];
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Group "${group.name}" created successfully')),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF667eea),
        title: const Text(
          'Teacher Communication',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.white),
            onPressed: _showCreateGroupDialog,
            tooltip: 'Create Group',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filters
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedClassFilter,
                                hint: const Text('All Classes', style: TextStyle(fontSize: 13)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('All Classes')),
                                  ..._availableClasses.map((c) => 
                                    DropdownMenuItem(value: c, child: Text('Class $c'))),
                                ],
                                onChanged: (v) => setState(() => _selectedClassFilter = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedGradeFilter,
                                hint: const Text('All Grades', style: TextStyle(fontSize: 13)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('All Grades')),
                                  ..._availableGrades.map((g) => 
                                    DropdownMenuItem(value: g, child: Text(g))),
                                ],
                                onChanged: (v) => setState(() => _selectedGradeFilter = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: const Text('Teachers', style: TextStyle(fontSize: 12)),
                              selected: _showTeachersOnly,
                              onSelected: (v) => setState(() {
                                _showTeachersOnly = v;
                                _showGroupsOnly = false;
                              }),
                              selectedColor: const Color(0xFF667eea),
                              checkmarkColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilterChip(
                              label: const Text('Groups', style: TextStyle(fontSize: 12)),
                              selected: _showGroupsOnly,
                              onSelected: (v) => setState(() {
                                _showGroupsOnly = v;
                                _showTeachersOnly = false;
                              }),
                              selectedColor: const Color(0xFF667eea),
                              checkmarkColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Contacts list
                Expanded(
                  child: _showGroupsOnly 
                      ? (_filteredGroups.isEmpty
                          ? const Center(child: Text('No groups found'))
                          : ListView.builder(
                              itemCount: _filteredGroups.length,
                              itemBuilder: (context, index) {
                                final group = _filteredGroups[index];
                                return _buildGroupTile(group);
                              },
                            ))
                      : (_filteredContacts.isEmpty
                          ? const Center(child: Text('No contacts found'))
                          : ListView.builder(
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                return _buildContactTile(contact);
                              },
                            )),
                ),
              ],
            ),
    );
  }

  Widget _buildContactTile(ChatContact contact) {
    final lastMessage = _messages[contact.id]?.lastOrNull;
    final unreadCount = _unreadCounts[contact.id] ?? 0;
    
    return InkWell(
      onTap: () => _selectContact(contact.id),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Text(
                contact.avatar,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.type == ContactType.student
                        ? '${contact.className ?? ''} ${contact.grade ?? ''}'.trim().isEmpty
                            ? 'Student'
                            : '${contact.className ?? ''} ${contact.grade ?? ''}'.trim()
                        : contact.subject ?? 'Teacher',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  // Show message preview if available
                  if (lastMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lastMessage.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lastMessage != null)
                  Text(
                    _formatTime(lastMessage.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF667eea),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(ChatGroup group) {
    return InkWell(
      onTap: () => _selectContact(group.id),
      child: Container(
        color: Colors.transparent,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF667eea),
            child: Text('👥', style: TextStyle(fontSize: 20)),
          ),
          title: Text(
            group.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            '${group.memberIds.length} members',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  // Build chat area - now using separate ChatScreen widget
  // Keeping this for reference but not called anymore
  @Deprecated('Use ChatScreen widget instead')
  Widget _buildChatArea() {
    final contact = _contacts[_selectedContactId];
    if (contact == null) return const SizedBox();
    
    final messages = _messages[_selectedContactId] ?? [];
    
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF667eea),
                child: Text(
                  contact.avatar,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.type == ContactType.student
                          ? '${contact.className ?? ''} ${contact.grade ?? ''}'.trim().isEmpty
                              ? 'Student'
                              : '${contact.className ?? ''} ${contact.grade ?? ''}'.trim()
                          : contact.subject ?? 'Teacher',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Three dots menu
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {
                  // Add menu functionality here
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Messages
        Expanded(
          child: messages.isEmpty
              ? Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[100],
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      // Send message - handled in ChatScreen widget (this method is deprecated)
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Microphone button
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white),
                  onPressed: () {
                    // Add voice message functionality
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    // Send message - handled in ChatScreen widget (this method is deprecated)
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final contact = _contacts[_selectedContactId];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile picture for received messages (left side)
          if (!message.isSent && contact != null) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                contact.avatar,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSent 
                    ? const Color(0xFF667eea) // Light blue for sent messages
                    : Colors.white, // White for received messages
                borderRadius: message.isSent
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(18),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSent ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isSent ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (message.isSent) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays == 0) {
        return DateFormat('hh:mm a').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday ${DateFormat('hh:mm a').format(dateTime)}';
      } else if (difference.inDays < 7) {
        return DateFormat('EEE hh:mm a').format(dateTime);
      } else {
        return DateFormat('MMM d, hh:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }
}

// Data Models
enum ContactType { student, teacher, group }

class ChatContact {
  final String id;
  final String name;
  final String username;
  final ContactType type;
  final String avatar;
  String? className;
  String? grade;
  String? subject;

  ChatContact({
    required this.id,
    required this.name,
    required this.username,
    required this.type,
    required this.avatar,
    this.className,
    this.grade,
    this.subject,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final bool isSent;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isSent,
    required this.timestamp,
  });
}

class ChatGroup {
  final String id;
  final String name;
  final List<String> memberIds;
  String? className;
  String? grade;

  ChatGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    this.className,
    this.grade,
  });
}

// Create Group Dialog
class CreateGroupDialog extends StatefulWidget {
  final List<ChatContact> contacts;
  final Function(ChatGroup) onGroupCreated;

  const CreateGroupDialog({
    super.key,
    required this.contacts,
    required this.onGroupCreated,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String? _selectedClass;
  String? _selectedGrade;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _createGroup() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    final group = ChatGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      memberIds: _selectedIds.toList(),
      className: _selectedClass,
      grade: _selectedGrade,
    );

    widget.onGroupCreated(group);
    Navigator.pop(context);
  }

  List<ChatContact> get _filteredContacts {
    if (_searchQuery.isEmpty) return widget.contacts;
    return widget.contacts.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Group',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g., Class 9 A Students',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedClass,
                      hint: const Text('Select Class'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _TeacherCommunicationScreenState._availableClasses.map((c) => 
                        DropdownMenuItem(value: c, child: Text('Class $c'))).toList(),
                      onChanged: (v) => setState(() => _selectedClass = v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedGrade,
                      hint: const Text('Select Grade'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _TeacherCommunicationScreenState._availableGrades.map((g) => 
                        DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _selectedGrade = v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select Members (${_selectedIds.length} selected)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredContacts.isEmpty
                  ? const Center(child: Text('No students found'))
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final isSelected = _selectedIds.contains(contact.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(contact.id);
                              } else {
                                _selectedIds.remove(contact.id);
                              }
                            });
                          },
                          title: Text(contact.name),
                          subtitle: Text(
                            '${contact.className ?? ''} ${contact.grade ?? ''}'.trim().isEmpty
                                ? 'Student'
                                : '${contact.className ?? ''} ${contact.grade ?? ''}'.trim(),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Separate Chat Screen Widget
class _ChatScreen extends StatefulWidget {
  final ChatContact contact;
  final String teacherUsername;
  final String teacherName;
  final String teacherUserId;
  final List<ChatMessage> messages;
  final Map<String, int> unreadCounts;

  const _ChatScreen({
    required this.contact,
    required this.teacherUsername,
    required this.teacherName,
    required this.teacherUserId,
    required this.messages,
    required this.unreadCounts,
  });

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  RealtimeChatService? _chatService;
  StreamSubscription? _chatSubscription;
  final Set<String> _messageIds = {}; // Track message IDs to prevent duplicates

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
    _loadChatHistory();
    _initializeRealtimeChat();
  }

  @override
  void dispose() {
    _chatService?.disconnect();
    _chatSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String normalizeNameForRoomId(String name) {
    if (name.isEmpty) return '';
    return name
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await api.ApiService.fetchChatMessages(widget.teacherUsername, widget.contact.username);
      
      if (messages.isNotEmpty) {
        setState(() {
          // Clear existing messages and message IDs to prevent duplicates
          _messages.clear();
          _messageIds.clear();
          
          _messages = messages.map((msg) {
            final sender = msg['sender'] is Map ? Map<String, dynamic>.from(msg['sender'] as Map) : null;
            final senderId = sender?['user_id']?.toString() ?? '';
            final senderUsername = sender?['username']?.toString() ?? '';
            
            final isSent = senderId == widget.teacherUserId || 
                          senderUsername == widget.teacherUsername;
            
            final messageText = msg['message_text']?.toString() ?? 
                               msg['message']?.toString() ?? '';
            
            final messageId = msg['message_id']?.toString() ?? 
                             msg['id']?.toString() ?? 
                             DateTime.now().millisecondsSinceEpoch.toString();
            
            _messageIds.add(messageId);
            
            return ChatMessage(
              id: messageId,
              text: messageText,
              senderId: senderId,
              isSent: isSent,
              timestamp: msg['created_at'] as String? ?? DateTime.now().toIso8601String(),
            );
          }).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _initializeRealtimeChat() async {
    if (widget.teacherName.isEmpty || widget.contact.name.isEmpty) {
      debugPrint('Cannot initialize chat: missing names');
      return;
    }
    
    try {
      final teacherName = normalizeNameForRoomId(widget.teacherName);
      final contactName = normalizeNameForRoomId(widget.contact.name);
      
      if (teacherName.isEmpty || contactName.isEmpty) {
        debugPrint('Cannot initialize chat: normalized names are empty');
        return;
      }
      
      final identifiers = [teacherName, contactName]..sort();
      final roomId = identifiers.join('_');
      
      final chatType = widget.contact.type == ContactType.student 
          ? 'teacher-student' 
          : 'teacher-teacher';
      
      _chatService = RealtimeChatService(baseWsUrl: 'ws://localhost:8000');
      await _chatService!.connect(roomId: roomId, chatType: chatType);
      
      _chatSubscription = _chatService!.stream?.listen((event) {
        try {
          final data = event is String ? jsonDecode(event) : event;
          if (data is Map) {
            final messageType = data['type']?.toString() ?? 'message';
            
            if (messageType == 'message') {
              final sender = data['sender']?.toString() ?? '';
              final senderUsername = data['sender_username']?.toString() ?? sender;
              final senderId = data['sender_id']?.toString() ?? '';
              final messageText = data['message']?.toString() ?? '';
              final timestamp = data['timestamp']?.toString() ?? DateTime.now().toIso8601String();
              final messageId = data['message_id']?.toString() ?? 
                               DateTime.now().millisecondsSinceEpoch.toString();
              
              if (messageText.isEmpty) return;
              
              // Only process messages for this conversation - strict check
              final normalizedContactName = normalizeNameForRoomId(widget.contact.name);
              final normalizedTeacherName = normalizeNameForRoomId(widget.teacherName);
              final normalizedSender = normalizeNameForRoomId(sender);
              
              // Check if sender is part of this conversation
              final isFromContact = (
                senderUsername == widget.contact.username ||
                senderId == widget.contact.id ||
                normalizedSender == normalizedContactName
              );
              
              final isFromTeacher = (
                senderUsername == widget.teacherUsername ||
                senderId == widget.teacherUserId ||
                normalizedSender == normalizedTeacherName
              );
              
              // Also check recipient to ensure message is for this conversation
              final recipient = data['recipient']?.toString() ?? '';
              final recipientId = data['recipient_id']?.toString() ?? '';
              final normalizedRecipient = normalizeNameForRoomId(recipient);
              
              final isToContact = (
                recipient == widget.contact.username ||
                recipientId == widget.contact.id ||
                normalizedRecipient == normalizedContactName
              );
              
              final isToTeacher = (
                recipient == widget.teacherUsername ||
                recipientId == widget.teacherUserId ||
                normalizedRecipient == normalizedTeacherName
              );
              
              // Message must be between teacher and this contact
              final isForThisConversation = (
                (isFromContact && isToTeacher) ||
                (isFromTeacher && isToContact)
              );
              
              if (!isForThisConversation) {
                debugPrint('Ignoring message not for this conversation: sender=$senderUsername, recipient=$recipient, contact=${widget.contact.name}');
                return;
              }
              
              // Prevent duplicate messages - check both messageId and content
              if (_messageIds.contains(messageId)) {
                debugPrint('Duplicate message ignored (ID): $messageId');
                return;
              }
              
              // Also check for duplicate by content and timestamp (within 2 seconds)
              final isDuplicateContent = _messages.any((msg) {
                if (msg.text == messageText) {
                  try {
                    final msgTime = DateTime.parse(msg.timestamp);
                    final newTime = DateTime.parse(timestamp);
                    final diff = newTime.difference(msgTime).abs();
                    if (diff.inSeconds < 2) {
                      return true;
                    }
                  } catch (e) {
                    // If timestamp parsing fails, just check text
                    return true;
                  }
                }
                return false;
              });
              
              if (isDuplicateContent) {
                debugPrint('Duplicate message ignored (content): $messageText');
                return;
              }
              
              final isSent = isFromTeacher;
              
              setState(() {
                _messageIds.add(messageId);
                _messages.add(ChatMessage(
                  id: messageId,
                  text: messageText,
                  senderId: senderId,
                  isSent: isSent,
                  timestamp: timestamp,
                ));
              });
              
              _scrollToBottom();
            }
          }
        } catch (e) {
          debugPrint('Error processing WebSocket message: $e');
        }
      });
    } catch (e) {
      debugPrint('Error initializing realtime chat: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    // Store the text before clearing
    final messageText = text;
    _messageController.clear();
    
    // Optimistically add message to UI with unique temp ID
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}';
    final tempTimestamp = DateTime.now().toIso8601String();
    
    setState(() {
      _messageIds.add(tempId);
      _messages.add(ChatMessage(
        id: tempId,
        text: messageText,
        senderId: widget.teacherUserId,
        isSent: true,
        timestamp: tempTimestamp,
      ));
    });
    
    _scrollToBottom();
    
    try {
      // Send via WebSocket
      if (_chatService != null) {
        _chatService!.sendMessage(
          sender: widget.teacherName.isNotEmpty ? widget.teacherName : widget.teacherUsername,
          recipient: widget.contact.name.isNotEmpty ? widget.contact.name : widget.contact.username,
          message: messageText,
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Remove optimistic message on error
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempId);
        _messageIds.remove(tempId);
      });
      _messageController.text = messageText; // Restore text
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays == 0) {
        return DateFormat('h:mm a').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('MMM d').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF667eea),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                widget.contact.avatar,
                style: const TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.contact.type == ContactType.student
                        ? '${widget.contact.className ?? ''} ${widget.contact.grade ?? ''}'.trim().isEmpty
                            ? 'Student'
                            : '${widget.contact.className ?? ''} ${widget.contact.grade ?? ''}'.trim()
                        : widget.contact.subject ?? 'Teacher',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Three dots menu
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Add menu functionality here
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start the conversation!',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[100],
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF667eea),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile picture for received messages (left side)
          if (!message.isSent) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                widget.contact.avatar,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isSent 
                    ? const Color(0xFF667eea)
                    : Colors.white,
                borderRadius: message.isSent
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(18),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isSent ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isSent ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (message.isSent) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
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
