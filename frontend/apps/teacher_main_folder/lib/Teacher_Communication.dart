// main.dart
// Full Flutter app (mobile-first) with:
// - Real AppBar matching: ←  Teacher Communication      ⟳   👤
// - Sidebar contacts, chat UI, typing indicator, search/filter, online badges
// - Dark mode toggle, smooth animations
// - Mock backend stubs (Firebase/API left as TODO)
// - Mobile & desktop responsive and overflow-fixed

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TeacherCommunicationApp());
}

class TeacherCommunicationApp extends StatefulWidget {
  const TeacherCommunicationApp({super.key});

  @override
  State<TeacherCommunicationApp> createState() =>
      _TeacherCommunicationAppState();
}

class _TeacherCommunicationAppState extends State<TeacherCommunicationApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() => setState(() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Communication',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF667eea),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF667eea),
        useMaterial3: true,
      ),
      home: TeacherCommunicationScreen(
        onToggleTheme: toggleTheme,
        initialThemeMode: _themeMode,
      ),
    );
  }
}

// ----------------------------- Data models --------------------------------

class ChatMessage {
  final String id;
  final String text;
  final String time; // human-readable
  final bool sent; // true if teacher sent

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.sent,
  });
}

class Contact {
  final String id;
  String name;
  String role;
  final String avatar;
  String status; // "Online" / "Offline"
  bool isTyping;
  final List<ChatMessage> messages;

  Contact({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.status = 'Offline',
    this.isTyping = false,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

// --------------------------- Mock / Backend service ------------------------

class BackendService {
  static const bool useBackend = false;
}

class LocalBackend {
  static Future<void> delay([int ms = 500]) =>
      Future.delayed(Duration(milliseconds: ms));

  static Future<void> sendMessage(Contact contact, ChatMessage message) async {
    await delay(300);
    contact.messages.add(message);
  }

  static Future<void> simulateRemoteTypingAndReply(
    Contact contact,
    String replyText,
  ) async {
    contact.isTyping = true;
    await delay(1200);
    contact.isTyping = false;
    final reply = ChatMessage(
      id: UniqueKey().toString(),
      text: replyText,
      time: _nowTimeString(),
      sent: false,
    );
    contact.messages.add(reply);
  }

  static String _nowTimeString() {
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hour12 = (h % 12 == 0) ? 12 : h % 12;
    return '$hour12:$m $ampm';
  }

  static Future<void> setPresence(Contact contact, bool online) async {
    await delay(100);
    contact.status = online ? 'Online' : 'Offline';
  }
}

// Firebase stub
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();
  Future<void> sendMessage(
    String contactId,
    Map<String, dynamic> message,
  ) async {
    throw UnimplementedError('Integrate Firebase here');
  }
}

// Api stub
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
  Future<void> fetchContacts() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> sendMessageToServer(
    String contactId,
    Map<String, dynamic> payload,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// ---------------------------- Main Screen ---------------------------------

class TeacherCommunicationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode initialThemeMode;

  const TeacherCommunicationScreen({
    super.key,
    required this.onToggleTheme,
    required this.initialThemeMode,
  });

  @override
  State<TeacherCommunicationScreen> createState() =>
      _TeacherCommunicationScreenState();
}

enum ContactFilter { all, students, parents, teachers }

class _TeacherCommunicationScreenState extends State<TeacherCommunicationScreen>
    with TickerProviderStateMixin {
  final Map<String, Contact> _contacts = {};
  late List<String> students;
  late List<String> parents;
  late List<String> teachers;

  String? _currentContactId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScroll = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  ContactFilter _activeFilter = ContactFilter.all;

  final Random _random = Random();

  late AnimationController _fadeController;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    _setupMockContacts();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    // Demo presence changes
    _presenceTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) return;
      setState(() {
        for (final c in _contacts.values) {
          if (_random.nextBool()) {
            c.status = _random.nextBool() ? 'Online' : 'Offline';
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScroll.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    _presenceTimer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _setupMockContacts() {
    _contacts.clear();

    void add(Contact c) => _contacts[c.id] = c;

    add(
      Contact(
        id: 'student1',
        name: 'Alex Johnson',
        role: 'Class 10A',
        avatar: '👨‍🎓',
        status: 'Online',
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Hello sir, I have a question about the math assignment',
            time: '10:30 AM',
            sent: false,
          ),
          ChatMessage(
            id: 'm2',
            text: "Sure Alex, what's your question?",
            time: '10:32 AM',
            sent: true,
          ),
          ChatMessage(
            id: 'm3',
            text: "I'm having trouble with question 5 in the calculus section",
            time: '10:33 AM',
            sent: false,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'student2',
        name: 'Sarah Williams',
        role: 'Class 11B',
        avatar: '👩‍🎓',
        status: 'Online',
        messages: [
          ChatMessage(
            id: 'm4',
            text: 'Good morning sir!',
            time: '9:15 AM',
            sent: false,
          ),
          ChatMessage(
            id: 'm5',
            text: 'Good morning Sarah! How can I help you today?',
            time: '9:16 AM',
            sent: true,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'student3',
        name: 'Michael Brown',
        role: 'Class 12A',
        avatar: '👨‍🎓',
        status: 'Offline',
        messages: [
          ChatMessage(
            id: 'm6',
            text: 'Sir, when will the exam results be announced?',
            time: 'Yesterday',
            sent: false,
          ),
          ChatMessage(
            id: 'm7',
            text: 'The results will be announced by Friday',
            time: 'Yesterday',
            sent: true,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'parent1',
        name: "Mr. & Mrs. Johnson",
        role: "Alex's Parents",
        avatar: '👨‍👩‍👧‍👦',
        status: 'Online',
        messages: [
          ChatMessage(
            id: 'm8',
            text: "Hello, we wanted to discuss Alex's progress",
            time: '2:30 PM',
            sent: false,
          ),
          ChatMessage(
            id: 'm9',
            text: "Of course, I'd be happy to discuss Alex's progress",
            time: '2:32 PM',
            sent: true,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'parent2',
        name: "Mr. & Mrs. Williams",
        role: "Sarah's Parents",
        avatar: '👨‍👩‍👧‍👦',
        status: 'Offline',
        messages: [
          ChatMessage(
            id: 'm10',
            text: "Thank you for the detailed feedback on Sarah's performance",
            time: 'Yesterday',
            sent: false,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'teacher1',
        name: 'Ms. Davis',
        role: 'English Teacher',
        avatar: '👩‍🏫',
        status: 'Online',
        messages: [
          ChatMessage(
            id: 'm11',
            text: 'Hi, can we coordinate on the upcoming project?',
            time: '11:45 AM',
            sent: false,
          ),
          ChatMessage(
            id: 'm12',
            text: 'Absolutely! When would be a good time to meet?',
            time: '11:47 AM',
            sent: true,
          ),
        ],
      ),
    );

    add(
      Contact(
        id: 'teacher2',
        name: 'Mr. Wilson',
        role: 'Science Teacher',
        avatar: '👨‍🏫',
        status: 'Online',
        messages: [
          ChatMessage(
            id: 'm13',
            text: 'Great collaboration on the science fair!',
            time: 'Today',
            sent: false,
          ),
          ChatMessage(
            id: 'm14',
            text: 'Thank you! The students really enjoyed it',
            time: 'Today',
            sent: true,
          ),
        ],
      ),
    );

    students = ['student1', 'student2', 'student3'];
    parents = ['parent1', 'parent2'];
    teachers = ['teacher1', 'teacher2'];
  }

  String _nowTimeString() {
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hour12 = (h % 12 == 0) ? 12 : h % 12;
    return '$hour12:$m $ampm';
  }

  List<Contact> get _filteredContacts {
    final q = _searchController.text.toLowerCase().trim();
    Iterable<Contact> all;
    switch (_activeFilter) {
      case ContactFilter.students:
        all = students.map((id) => _contacts[id]!);
        break;
      case ContactFilter.parents:
        all = parents.map((id) => _contacts[id]!);
        break;
      case ContactFilter.teachers:
        all = teachers.map((id) => _contacts[id]!);
        break;
      default:
        all = _contacts.values;
    }
    if (q.isEmpty) return all.toList();
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.role.toLowerCase().contains(q),
        )
        .toList();
  }

  void _selectContact(String id) {
    setState(() {
      _currentContactId = id;
    });

    _fadeController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (_messagesScroll.hasClients) {
        _messagesScroll.jumpTo(_messagesScroll.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentContactId == null) return;
    final contact = _contacts[_currentContactId!]!;
    final outgoing = ChatMessage(
      id: UniqueKey().toString(),
      text: text,
      time: _nowTimeString(),
      sent: true,
    );
    setState(() {
      contact.messages.add(outgoing);
      _messageController.clear();
    });
    _scrollToBottom();

    if (BackendService.useBackend) {
      // TODO: send to backend
    } else {
      final replies = [
        'Thanks, I will check that shortly.',
        "I'll get back to you on that.",
        'Sounds good!',
        'Thanks for the update.',
        'Understood — I will follow up.',
      ];
      final reply = (replies..shuffle()).first;
      setState(() {
        contact.isTyping = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          contact.isTyping = false;
          contact.messages.add(
            ChatMessage(
              id: UniqueKey().toString(),
              text: reply,
              time: _nowTimeString(),
              sent: false,
            ),
          );
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messagesScroll.hasClients) {
        _messagesScroll.animateTo(
          _messagesScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onCompose() {
    showDialog(
      context: context,
      builder: (ctx) {
        String? selected;
        final list = _contacts.values.toList();
        return AlertDialog(
          title: const Text('Compose Message'),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search contact to message',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final c = list[index];
                      return RadioListTile<String>(
                        value: c.id,
                        groupValue: selected,
                        onChanged: (val) => setState(() => selected = val),
                        title: Text(c.name),
                        subtitle: Text(c.role),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final contactName = selected != null ? _contacts[selected]?.name : null;
                Navigator.of(context).pop();
                _showSnackBar('Opening chat with ${contactName ?? "contact"}');
              },
              child: const Text('Open Chat'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------- AppBar (Real AppBar widget) -----------------------
  // Matches the requested header:
  // ←   Teacher Communication      ⟳   👤
  PreferredSizeWidget _buildAppBar(BuildContext ctx) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        // Transparent background so flexibleSpace gradient is visible
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        automaticallyImplyLeading: false, // we'll put our own leading
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Teacher Communication',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // Refresh communication data
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                // profile action sheet
                showModalBottomSheet(
                  context: ctx,
                  builder: (ctx2) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Teacher User',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('teacher@example.com'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: null,
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
  // -------------------------------------------------------------------------

  Widget _buildContactCard(Contact c, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              )
            : null,
        color: active ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectContact(c.id),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                c.avatar,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : null,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.role,
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? Colors.white70 : Colors.black54,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey<String>(c.status),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.status == 'Online'
                      ? const Color(0xFF51cf66)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar adapted for mobile: scrollable and shrinkWrapped
  Widget _buildSidebarMobile(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(ctx).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showSnackBar('Compose message (simulated)');
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Compose'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search & filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search contacts',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<ContactFilter>(
                onSelected: (f) => setState(() => _activeFilter = f),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: ContactFilter.all, child: Text('All')),
                  PopupMenuItem(
                    value: ContactFilter.students,
                    child: Text('Students'),
                  ),
                  PopupMenuItem(
                    value: ContactFilter.parents,
                    child: Text('Parents'),
                  ),
                  PopupMenuItem(
                    value: ContactFilter.teachers,
                    child: Text('Teachers'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(Icons.filter_list),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contact list (shrinkWrap to avoid nested scrolling overflow)
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts',
                      style: TextStyle(
                        color: Theme.of(ctx).textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = _filteredContacts[index];
                      final active = c.id == _currentContactId;
                      return _buildContactCard(c, active);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Sidebar for larger screens
  Widget _buildSidebar(BuildContext ctx) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 380),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(ctx).brightness == Brightness.light
                  ? Colors.black12
                  : Colors.black26,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _showSnackBar('Compose message (simulated)');
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Compose Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search contacts',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<ContactFilter>(
                  onSelected: (f) => setState(() => _activeFilter = f),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: ContactFilter.all, child: Text('All')),
                    PopupMenuItem(
                      value: ContactFilter.students,
                      child: Text('Students'),
                    ),
                    PopupMenuItem(
                      value: ContactFilter.parents,
                      child: Text('Parents'),
                    ),
                    PopupMenuItem(
                      value: ContactFilter.teachers,
                      child: Text('Teachers'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView.separated(
                  key: ValueKey<String>(
                    _searchController.text + _activeFilter.toString(),
                  ),
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _filteredContacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = _filteredContacts[index];
                    final active = c.id == _currentContactId;
                    return _buildContactCard(c, active);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('💬', style: TextStyle(fontSize: 48, color: Colors.black26)),
          SizedBox(height: 16),
          Text(
            'Select a contact to start messaging',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Choose from the list below to begin a conversation',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(BuildContext ctx) {
    if (_currentContactId == null) return _buildEmptyChat();
    final contact = _contacts[_currentContactId]!;
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE9ECEF))),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  contact.avatar,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.status,
                      style: TextStyle(
                        color: contact.status == 'Online'
                            ? const Color(0xFF51cf66)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _showSnackBar('More options (simulated)');
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),

        // Message list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListView.builder(
              controller: _messagesScroll,
              itemCount: contact.messages.length + (contact.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (contact.isTyping && index == contact.messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(contact.avatar),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFF8F9FA)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 6, height: 6, child: DotTyping()),
                              SizedBox(width: 6),
                              SizedBox(width: 6, height: 6, child: DotTyping()),
                              SizedBox(width: 6),
                              SizedBox(width: 6, height: 6, child: DotTyping()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final msg = contact.messages[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: 0.0,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _buildMessageBubble(msg),
                );
              },
            ),
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE9ECEF))),
          ),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 130),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Theme.of(ctx).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _sendMessage(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage m) {
    final sent = m.sent;
    final bubbleGradient = sent
        ? const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
        : null;
    final bubbleColor = sent
        ? null
        : (Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FA)
              : Colors.grey[800]);
    return Row(
      mainAxisAlignment: sent ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!sent)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text('👨‍🎓'),
          ),
        Flexible(
          child: Container(
            key: ValueKey<String>(m.id),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: bubbleGradient,
              color: bubbleColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    m.text,
                    style: TextStyle(
                      color: sent ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    m.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: sent ? Colors.white70 : Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sent)
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text('👨‍🏫'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mobile-focused (stacked), but still responsive for wider screens
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  // Desktop-like: sidebar left, chat right
                  return Row(
                    children: [
                      // Sidebar (constrained)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 260,
                          maxWidth: 360,
                        ),
                        child: _buildSidebar(context),
                      ),
                      const SizedBox(width: 12),
                      // Chat (expanded)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildChatArea(context),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile stacked: chat on top, then contacts below (both flex)
                  return Column(
                    children: [
                      // Chat area - takes roughly 60% of vertical space
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildChatArea(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sidebar (mobile) - takes remaining vertical space, scrollable
                      Expanded(
                        flex: 4,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: _buildSidebarMobile(context),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Simple animated dots for typing indicator
class DotTyping extends StatefulWidget {
  const DotTyping({super.key});

  @override
  State<DotTyping> createState() => _DotTypingState();
}

class _DotTypingState extends State<DotTyping>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
