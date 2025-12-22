import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:main_login/main.dart' as main_login;
import 'main.dart' as app;
import 'dashboard.dart';

class PhotoEntry {
  final int id;
  final String title;
  final String category;
  final String description;
  final DateTime date;
  final String photographer;
  final String location;
  final String emoji;
  bool isFavorite;
  List<Uint8List> images;

  PhotoEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.date,
    required this.photographer,
    required this.location,
    required this.emoji,
    this.isFavorite = false,
    List<Uint8List>? images,
  }) : images = images ?? [];
}

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  final List<PhotoEntry> _allPhotos = [
    PhotoEntry(
      id: 1,
      title: 'Annual Sports Day',
      category: 'Sports',
      description:
          'Students participating in various sports events during annual sports day',
      date: DateTime(2024, 3, 15),
      photographer: 'Mr. Sharma',
      location: 'School Ground',
      emoji: '🏃‍♂️',
    ),
    PhotoEntry(
      id: 2,
      title: 'Science Fair Exhibition',
      category: 'Academic',
      description: 'Students showcasing their innovative science projects',
      date: DateTime(2024, 2, 20),
      photographer: 'Mrs. Patel',
      location: 'School Auditorium',
      emoji: '🔬',
    ),
    PhotoEntry(
      id: 3,
      title: 'Cultural Dance Performance',
      category: 'Cultural',
      description:
          'Traditional dance performance by students during cultural fest',
      date: DateTime(2024, 1, 25),
      photographer: 'Mr. Kumar',
      location: 'School Stage',
      emoji: '💃',
    ),
    PhotoEntry(
      id: 4,
      title: 'Award Ceremony',
      category: 'Awards',
      description: 'Annual award ceremony recognizing student achievements',
      date: DateTime(2024, 3, 10),
      photographer: 'Mrs. Reddy',
      location: 'School Hall',
      emoji: '🏆',
    ),
    PhotoEntry(
      id: 5,
      title: 'NCC Training Camp',
      category: 'Activities',
      description: 'NCC cadets during their training camp activities',
      date: DateTime(2024, 2, 28),
      photographer: 'Capt. Singh',
      location: 'NCC Ground',
      emoji: '🎖️',
    ),
    PhotoEntry(
      id: 6,
      title: 'Library Reading Session',
      category: 'Academic',
      description: 'Students engaged in reading and study activities',
      date: DateTime(2024, 3, 5),
      photographer: 'Ms. Iyer',
      location: 'School Library',
      emoji: '📚',
    ),
    PhotoEntry(
      id: 7,
      title: 'Art & Craft Exhibition',
      category: 'Cultural',
      description: 'Student artwork and craft projects on display',
      date: DateTime(2024, 2, 15),
      photographer: 'Mr. Verma',
      location: 'Art Room',
      emoji: '🎨',
    ),
    PhotoEntry(
      id: 8,
      title: 'Computer Lab Session',
      category: 'Academic',
      description: 'Students learning computer skills and programming',
      date: DateTime(2024, 3, 12),
      photographer: 'Mrs. Gupta',
      location: 'Computer Lab',
      emoji: '💻',
    ),
    PhotoEntry(
      id: 9,
      title: 'Basketball Tournament',
      category: 'Sports',
      description: 'Inter-school basketball tournament final match',
      date: DateTime(2024, 3, 8),
      photographer: 'Mr. Joshi',
      location: 'Basketball Court',
      emoji: '🏀',
    ),
    PhotoEntry(
      id: 10,
      title: 'Environmental Awareness Rally',
      category: 'Activities',
      description:
          'Students participating in environmental conservation rally',
      date: DateTime(2024, 2, 22),
      photographer: 'Ms. Kapoor',
      location: 'School Premises',
      emoji: '🌱',
    ),
  ];

  late List<PhotoEntry> _visiblePhotos;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photographerController = TextEditingController();
  final _locationController = TextEditingController();

  String? _newCategory;
  DateTime? _newDate;
  Uint8List? _selectedImageBytes;

  String _searchQuery = '';
  String? _categoryFilter;
  String? _dateFilter;

  @override
  void initState() {
    super.initState();
    _visiblePhotos = List<PhotoEntry>.from(_allPhotos);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _photographerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _filterPhotos() {
    setState(() {
      _visiblePhotos = _allPhotos.where((photo) {
        final matchesSearch = _searchQuery.isEmpty ||
            photo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            photo.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            photo.photographer.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory =
            _categoryFilter == null || photo.category == _categoryFilter;

        bool matchesDate = true;
        if (_dateFilter != null) {
          final now = DateTime.now();
          switch (_dateFilter) {
            case 'today':
              matchesDate = photo.date.year == now.year &&
                  photo.date.month == now.month &&
                  photo.date.day == now.day;
              break;
            case 'week':
              final weekAgo = now.subtract(const Duration(days: 7));
              matchesDate = photo.date.isAfter(weekAgo) || photo.date.isAtSameMomentAs(weekAgo);
              break;
            case 'month':
              matchesDate = photo.date.year == now.year &&
                  photo.date.month == now.month;
              break;
            case 'year':
              matchesDate = photo.date.year == now.year;
              break;
          }
        }

        return matchesSearch && matchesCategory && matchesDate;
      }).toList();
    });
  }

  Map<String, int> _stats() {
    final total = _allPhotos.length;
    final now = DateTime.now();
    final thisMonth = _allPhotos
        .where((photo) =>
            photo.date.year == now.year && photo.date.month == now.month)
        .length;
    final events = _allPhotos
        .where((photo) => photo.category == 'Events')
        .length;
    final activities = _allPhotos
        .where((photo) => photo.category == 'Activities')
        .length;

    return {
      'total': total,
      'month': thisMonth,
      'events': events,
      'activities': activities,
    };
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _newDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _newDate = date;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBytes = bytes;
    });
  }

  void _addPhoto() {
    if (!_formKey.currentState!.validate()) return;
    if (_newCategory == null || _newDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final images = _selectedImageBytes != null ? [_selectedImageBytes!] : <Uint8List>[];
    
    final photo = PhotoEntry(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: _titleController.text.trim(),
      category: _newCategory!,
      description: _descriptionController.text.trim(),
      date: _newDate!,
      photographer: _photographerController.text.trim(),
      location: _locationController.text.trim(),
      emoji: '📷',
      images: images,
    );

    setState(() {
      _allPhotos.insert(0, photo);
      _filterPhotos();
    });

    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _photographerController.clear();
    _locationController.clear();
    setState(() {
      _newCategory = null;
      _newDate = null;
      _selectedImageBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo added successfully!')),
    );
  }

  void _toggleFavorite(PhotoEntry photo) {
    setState(() {
      photo.isFavorite = !photo.isFavorite;
    });
  }

  void _deletePhoto(PhotoEntry photo) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Are you sure you want to delete "${photo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allPhotos.remove(photo);
                _filterPhotos();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, List<Uint8List> images, int initialIndex) {
    final pageController = PageController(initialPage: initialIndex);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    child: Image.memory(
                      images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewImages(PhotoEntry photo) {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${photo.images.length} image${photo.images.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked == null) return;
                          final bytes = await picked.readAsBytes();
                          if (!mounted) return;
                          setState(() {
                            photo.images.add(bytes);
                          });
                          setDialogState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image added successfully!')),
                          );
                        },
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('Upload Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                if (photo.images.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No images uploaded yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: photo.images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onDoubleTap: () {
                              _showFullImage(context, photo.images, index);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                photo.images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
                  color: const Color(0xFFF5F6FA),
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
                                    child: _AddPhotoSection(
                                      formKey: _formKey,
                                      titleController: _titleController,
                                      descriptionController:
                                          _descriptionController,
                                      photographerController:
                                          _photographerController,
                                      locationController: _locationController,
                                      category: _newCategory,
                                      onCategoryChanged: (value) =>
                                          setState(() => _newCategory = value),
                                      date: _newDate,
                                      onPickDate: _pickDate,
                                      selectedImageBytes: _selectedImageBytes,
                                      onPickPhoto: _pickPhoto,
                                      onSubmit: _addPhoto,
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
                                        _filterPhotos();
                                      },
                                      categoryFilter: _categoryFilter,
                                      onCategoryChanged: (value) {
                                        setState(() {
                                          _categoryFilter = value;
                                        });
                                        _filterPhotos();
                                      },
                                      dateFilter: _dateFilter,
                                      onDateChanged: (value) {
                                        setState(() {
                                          _dateFilter = value;
                                        });
                                        _filterPhotos();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _GalleryGrid(
                            photos: _visiblePhotos,
                            onToggleFavorite: _toggleFavorite,
                            onDelete: _deletePhoto,
                            onViewImages: (photo) => _viewImages(photo),
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

  // Safe navigation helper for sidebar
  void _navigateToRoute(BuildContext context, String route) {
    final navigator = app.SchoolManagementApp.navigatorKey.currentState;
    if (navigator != null) {
      if (navigator.canPop() || route != '/dashboard') {
        navigator.pushReplacementNamed(route);
      } else {
        navigator.pushNamed(route);
      }
    }
  }

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
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.24),
                  width: 1,
                ),
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
                    title: 'Overview',
                    isActive: false,
                    onTap: () => _navigateToRoute(context, '/dashboard'),
                  ),
                  _NavItem(
                    icon: '👨‍🏫',
                    title: 'Teachers',
                    onTap: () => _navigateToRoute(context, '/teachers'),
                  ),
                  _NavItem(
                    icon: '👥',
                    title: 'Students',
                    onTap: () => _navigateToRoute(context, '/students'),
                  ),
                  _NavItem(
                    icon: '🚌',
                    title: 'Buses',
                    onTap: () => _navigateToRoute(context, '/buses'),
                  ),
                  _NavItem(
                    icon: '🎯',
                    title: 'Activities',
                    onTap: () => _navigateToRoute(context, '/activities'),
                  ),
                  _NavItem(
                    icon: '📅',
                    title: 'Events',
                    onTap: () => _navigateToRoute(context, '/events'),
                  ),
                  _NavItem(
                    icon: '📆',
                    title: 'Calendar',
                    onTap: () => _navigateToRoute(context, '/calendar'),
                  ),
                  _NavItem(
                    icon: '🔔',
                    title: 'Notifications',
                    onTap: () => _navigateToRoute(context, '/notifications'),
                  ),
                  _NavItem(
                    icon: '🛣️',
                    title: 'Bus Routes',
                    onTap: () => _navigateToRoute(context, '/bus-routes'),
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

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

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
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
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
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📸 Photo Gallery',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage school photos, events, and memories',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final Map<String, int> stats;

  const _StatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _StatCard(number: stats['total']!, label: 'Total Photos'),
        _StatCard(number: stats['month']!, label: 'This Month'),
        _StatCard(number: stats['events']!, label: 'Events'),
        _StatCard(number: stats['activities']!, label: 'Activities'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddPhotoSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController photographerController;
  final TextEditingController locationController;
  final String? category;
  final ValueChanged<String?> onCategoryChanged;
  final DateTime? date;
  final VoidCallback onPickDate;
  final Uint8List? selectedImageBytes;
  final Future<void> Function() onPickPhoto;
  final VoidCallback onSubmit;

  const _AddPhotoSection({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.photographerController,
    required this.locationController,
    required this.category,
    required this.onCategoryChanged,
    required this.date,
    required this.onPickDate,
    required this.selectedImageBytes,
    required this.onPickPhoto,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
                  'Add New Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: onPickPhoto,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            selectedImageBytes!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          children: [
                            const Text(
                              '📷',
                              style: TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 10),
                            const Text('Click to upload photo'),
                            const SizedBox(height: 5),
                            Text(
                              'JPG, PNG, GIF up to 5MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Photo Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter title' : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Events', child: Text('School Events')),
                            DropdownMenuItem(
                                value: 'Activities',
                                child: Text('Extra Curricular')),
                            DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                            DropdownMenuItem(
                                value: 'Academic', child: Text('Academic')),
                            DropdownMenuItem(
                                value: 'Cultural', child: Text('Cultural')),
                            DropdownMenuItem(
                                value: 'Awards',
                                child: Text('Awards & Recognition')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: onCategoryChanged,
                          validator: (value) =>
                              value == null ? 'Please select category' : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: onPickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date Taken',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              date == null
                                  ? 'Select date'
                                  : DateFormat('yyyy-MM-dd').format(date!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the photo, event, or memory...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: photographerController,
                          decoration: InputDecoration(
                            labelText: 'Photographer',
                            hintText: 'Who took the photo?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            hintText: 'Where was it taken?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      child: const Text('Add Photo'),
                    ),
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

class _SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? categoryFilter;
  final ValueChanged<String?> onCategoryChanged;
  final String? dateFilter;
  final ValueChanged<String?> onDateChanged;

  const _SearchFilterSection({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.categoryFilter,
    required this.onCategoryChanged,
    required this.dateFilter,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
              hintText: 'Search photos...',
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
                  value: categoryFilter,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Categories')),
                    DropdownMenuItem(value: 'Events', child: Text('Events')),
                    DropdownMenuItem(value: 'Activities', child: Text('Activities')),
                    DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                    DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                    DropdownMenuItem(value: 'Cultural', child: Text('Cultural')),
                    DropdownMenuItem(value: 'Awards', child: Text('Awards')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: dateFilter,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Dates')),
                    DropdownMenuItem(value: 'today', child: Text('Today')),
                    DropdownMenuItem(value: 'week', child: Text('This Week')),
                    DropdownMenuItem(value: 'month', child: Text('This Month')),
                    DropdownMenuItem(value: 'year', child: Text('This Year')),
                  ],
                  onChanged: onDateChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<PhotoEntry> photos;
  final ValueChanged<PhotoEntry> onToggleFavorite;
  final ValueChanged<PhotoEntry> onDelete;
  final ValueChanged<PhotoEntry> onViewImages;

  const _GalleryGrid({
    required this.photos,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onViewImages,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Center(
          child: Column(
            children: [
              Text(
                'No photos found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'Add some photos to get started!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 700
                ? 3
                : constraints.maxWidth > 500
                    ? 2
                    : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.75,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) => _PhotoCard(
            photo: photos[index],
            onToggleFavorite: () => onToggleFavorite(photos[index]),
            onDelete: () => onDelete(photos[index]),
            onViewImages: () => onViewImages(photos[index]),
          ),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final PhotoEntry photo;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;
  final VoidCallback onViewImages;

  const _PhotoCard({
    required this.photo,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onViewImages,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');
    return GestureDetector(
      onDoubleTap: onViewImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: photo.images.isEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      )
                    : null,
                color: photo.images.isEmpty ? null : Colors.black,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  if (photo.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(
                        photo.images.first,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        photo.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      photo.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      photo.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: photo.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  photo.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📅 ${formatter.format(photo.date)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        photo.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📸 ${photo.photographer}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '📍 ${photo.location}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
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

