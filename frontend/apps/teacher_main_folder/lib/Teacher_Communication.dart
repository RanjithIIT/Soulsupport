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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _chatService?.disconnect();
    _chatSubscription?.cancel();
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

  Future<void> _loadChatHistory() async {
    if (_selectedContactId == null || _currentTeacherUserId == null) return;
    try {
      debugPrint('Loading chat history for: $_selectedContactId');
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
        debugPrint('Loaded ${_messages[_selectedContactId!]!.length} messages');
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  List<ChatContact> get _filteredContacts {
    return _contacts.values.where((contact) {
      // Search filter
      if (_searchQuery.isNotEmpty && !contact.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      
      // Type filters
      if (_showTeachersOnly && contact.type != ContactType.teacher) return false;
      if (_showGroupsOnly && contact.type != ContactType.group) return false;
      if (!_showTeachersOnly && !_showGroupsOnly && contact.type == ContactType.teacher) return false;
      
      // Class filter
      if (_selectedClassFilter != null && contact.className != _selectedClassFilter) return false;
      
      // Grade filter
      if (_selectedGradeFilter != null && contact.grade != _selectedGradeFilter) return false;
      
      return true;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  List<ChatGroup> get _filteredGroups {
    return _groups.values.where((group) {
      if (_searchQuery.isNotEmpty && !group.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_selectedClassFilter != null && group.className != _selectedClassFilter) return false;
      if (_selectedGradeFilter != null && group.grade != _selectedGradeFilter) return false;
      return true;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _selectContact(String contactId) async {
    if (_selectedContactId == contactId) return;
    
    // Disconnect previous chat
    _chatService?.disconnect();
    _chatSubscription?.cancel();
    
    setState(() {
      _selectedContactId = contactId;
    });
    
    await _loadChatHistory();
    await _initializeRealtimeChat();
  }

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
              // Compare with teacher name (normalized) instead of username
              final normalizedSender = normalizeNameForRoomId(sender);
              final normalizedTeacherName = normalizeNameForRoomId(_currentTeacherName ?? _currentTeacherUsername ?? '');
              if (normalizedSender != normalizedTeacherName) {
                setState(() {
                  _messages[_selectedContactId!] ??= [];
                  _messages[_selectedContactId!]!.add(ChatMessage(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: data['message']?.toString() ?? '',
                    senderId: contact.id,
                    isSent: false,
                    timestamp: DateTime.now().toIso8601String(),
                  ));
                });
                _scrollToBottom();
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedContactId == null || _currentTeacherUsername == null) return;
    
    final contact = _contacts[_selectedContactId];
    if (contact == null) return;
    
    // Add to UI immediately
    setState(() {
      _messages[_selectedContactId!] ??= [];
      _messages[_selectedContactId!]!.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: _currentTeacherUserId ?? '',
        isSent: true,
        timestamp: DateTime.now().toIso8601String(),
      ));
    });
    _messageController.clear();
    _scrollToBottom();
    
    // Send via WebSocket
    if (_chatService != null && _chatService!.isConnected) {
      _chatService!.sendMessage(
        sender: _currentTeacherUsername!,
        recipient: contact.username,
        message: text,
      );
      debugPrint('Message sent to ${contact.name}');
    } else {
      debugPrint('Chat service not connected, attempting to reconnect...');
      _initializeRealtimeChat();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
          : Row(
              children: [
                // Contacts sidebar
                Container(
                  width: 350,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Search and filters
                      Padding(
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
                                          DropdownMenuItem(value: g, child: Text('Grade $g'))),
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
                ),
                // Chat area
                Expanded(
                  child: _selectedContactId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Select a contact to start chatting',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : _buildChatArea(),
                ),
              ],
            ),
    );
  }

  Widget _buildContactTile(ChatContact contact) {
    final isSelected = _selectedContactId == contact.id;
    final lastMessage = _messages[contact.id]?.lastOrNull;
    
    return InkWell(
      onTap: () => _selectContact(contact.id),
      child: Container(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected ? const Color(0xFF667eea) : Colors.grey[300],
            child: Text(
              contact.avatar,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            contact.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF667eea) : Colors.black87,
            ),
          ),
          subtitle: Text(
            contact.type == ContactType.student
                ? '${contact.className ?? ''} ${contact.grade ?? ''}'.trim().isEmpty
                    ? 'Student'
                    : '${contact.className ?? ''} ${contact.grade ?? ''}'.trim()
                : contact.subject ?? 'Teacher',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: lastMessage != null
              ? Text(
                  _formatTime(lastMessage.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildGroupTile(ChatGroup group) {
    final isSelected = _selectedContactId == group.id;
    return InkWell(
      onTap: () => _selectContact(group.id),
      child: Container(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF667eea),
            child: Text('👥', style: TextStyle(fontSize: 20)),
          ),
          title: Text(
            group.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF667eea) : Colors.black87,
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
              CircleAvatar(
                backgroundColor: const Color(0xFF667eea),
                child: Text(
                  contact.avatar,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 4),
                    Text(
                      contact.type == ContactType.student
                          ? '${contact.className ?? ''} ${contact.grade ?? ''}'.trim().isEmpty
                              ? 'Student'
                              : '${contact.className ?? ''} ${contact.grade ?? ''}'.trim()
                          : contact.subject ?? 'Teacher',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Messages
        Expanded(
          child: messages.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
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
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isSent ? const Color(0xFF667eea) : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isSent ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isSent ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
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
                        DropdownMenuItem(value: g, child: Text('Grade $g'))).toList(),
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
