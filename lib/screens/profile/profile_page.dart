import 'dart:io'; // WAJIB ADA
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../main/blog_page.dart';
import '../jilid/jilid_detail_page.dart';
import '../jilid/edit_jilid_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/post_service.dart';
import '../../data/services/series_service.dart';
import '../lembar/edit_lembar.dart';
import 'account_settings_page.dart';
import 'edit_profile_page.dart';

// Konstanta Warna Modern
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color _kSubTextColor = Color(0xFF757575);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Public';
  static const int _currentNavIndex = 3;
  
  Map<String, dynamic>? _userData;

  // Dynamic user data
  String _userName = '';
  String _userInitials = '';
  String _userBio = 'Belum ada bio';
  int? _userId; // Store User ID for fetching posts
  String _userEmail = '';
  String _currentUsername = '';

  // --- PATH ASSET DEFAULT ---
  final String _defaultBannerAsset = 'assets/images/banner_default.jpg';
  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';
  final String _defaultThumbAsset = 'assets/images/thumb_default.jpg';

  String? _bannerImagePath;
  String? _profileImagePath;

  int _followers = 0;
  int _following = 0;

  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _jilid = [];
  List<Map<String, dynamic>> _likedBlogs = [];
  final _authService = AuthService();
  bool _isLoadingProfile = true;

  final _postService = PostService();
  final _seriesService = SeriesService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _tabController.previousIndex) {
        setState(() {});
        _refreshData();
      }
    });
    // Init default path
    _bannerImagePath = _defaultBannerAsset;
    _profileImagePath = _defaultAvatarAsset;
    
    _loadProfile();
    // _loadStories(); // Moved to _loadProfile
    _loadJilid();
    _loadLikedPosts();
  }

  Future<void> _loadProfile() async {
    final result = await _authService.getProfile();
    if (result['success']) {
      final data = result['data'];
      if (mounted) {
        setState(() {
          _userData = data;
          _userName = data['name'] ?? '';
          if (_userName.isNotEmpty) {
            _userInitials = _userName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();
          }
          _currentUsername = '@${data['username']}';
          _userBio = data['bio'] ?? 'Belum ada bio';
          _profileImagePath = data['avatar_url'];
          _bannerImagePath = data['banner_url'];
          
          if (data['stats'] != null) {
            _followers = data['stats']['followers_count'] ?? data['stats']['followers'] ?? 0;
            _following = data['stats']['following_count'] ?? data['stats']['following'] ?? 0;
          }
          
          _userId = data['id']; // Set User ID
          _isLoadingProfile = false;
        });
        
        // Load stories after we have the User ID
        _loadStories();
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memuat profil')),
        );
      }
    }
  }

  void _refreshData() {
    _loadJilid();
    _loadStories();
    _loadLikedPosts();
  }

  Future<void> _loadStories() async {
    if (_userId == null) return;

    final posts = await _postService.getPosts(userId: _userId);
    
    final stories = posts.map((post) => {
      'id': post['id'],
      'title': post['title'] ?? 'Untitled',
      'snippet': post['snippet'] ?? '',
      'thumbnail': post['thumbnail_url'],
      'date': _formatDate(post['published_at']),
      'likes': post['stats']['likes']?.toString() ?? '0',
      'comments': post['stats']['comments']?.toString() ?? '0',
      'authorName': post['author']['name'] ?? 'Pengguna',
      'status': post['status'] ?? 'published', // 'draft' or 'published'
      'visibility': _mapVisibility(post['status'], post['visibility']), // Map to filter values
    }).toList();

    if (mounted) {
      setState(() {
        _stories = stories;
      });
    }
  }

  Future<void> _loadJilid() async {
    if (_userId == null) return;
    final jilid = await _seriesService.getSeries(userId: _userId);
    setState(() {
      _jilid = jilid;
    });
  }

  Future<void> _loadLikedPosts() async {
    final posts = await _postService.getLikedPosts();
    
    final likedPosts = posts.map((post) => {
      'id': post['id'],
      'title': post['title'] ?? 'Untitled',
      'snippet': post['snippet'] ?? '',
      'thumbnail': post['thumbnail_url'],
      'date': _formatDate(post['published_at']),
      'likes': post['stats']['likes']?.toString() ?? '0',
      'comments': post['stats']['comments']?.toString() ?? '0',
      'authorName': post['author']['name'] ?? 'Pengguna',
    }).toList();

    if (mounted) {
      setState(() {
        _likedBlogs = likedPosts;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Baru saja';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Baru saja';
          }
          return '${difference.inMinutes} mnt lalu';
        }
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks} minggu lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  String _mapVisibility(String? status, String? visibility) {
    if (status == 'draft') return 'Draft';
    if (visibility == 'private') return 'Private';
    return 'Public';
  }

  // === FUNGSI PINTAR: DETEKSI TIPE GAMBAR ===
  ImageProvider _getSmartImage(String? path, String defaultAsset) {
    if (path == null || path.isEmpty) {
      return AssetImage(defaultAsset);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  // --- LOGIC MENU & VISIBILITY (Sama seperti sebelumnya) ---
  void _showStoryOptionMenu(BuildContext context, Map<String, dynamic> story) {
    final currentVisibility = story['visibility'] ?? 'Public';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Dynamic menu based on visibility
                if (currentVisibility == 'Public' || currentVisibility == 'Private') ...[
                  _buildMenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Lembar',
                    color: _kTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to EditLembarPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditLembarPage(
                            postId: int.tryParse(story['id'].toString()) ?? 0,
                          ),
                        ),
                      ).then((_) => _refreshData());
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                if (currentVisibility == 'Public') ...[
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Ubah ke Private',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _changeVisibility(story, 'private');
                    },
                  ),
                ] else if (currentVisibility == 'Private') ...[
                  _buildMenuItem(
                    icon: Icons.public_rounded,
                    label: 'Ubah ke Public',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _changeVisibility(story, 'public');
                    },
                  ),
                ] else if (currentVisibility == 'Draft') ...[
                  _buildMenuItem(
                    icon: Icons.public_rounded,
                    label: 'Publish sebagai Public',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _publishDraft(story, 'public');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Publish sebagai Private',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _publishDraft(story, 'private');
                    },
                  ),
                ],
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus Cerita',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteStory(story);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLikedOptionMenu(BuildContext context, Map<String, dynamic> blog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.share_rounded,
                  label: 'Bagikan',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Hapus dari Disukai',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _likedBlogs.remove(blog);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Dihapus dari daftar suka"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeVisibility(Map<String, dynamic> story, String newVisibility) async {
    final postId = story['id'];
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengubah visibility...'), duration: Duration(seconds: 1)),
      );
    }

    // Only send visibility - backend validation allows partial updates
    final result = await _postService.updatePost(
      postId,
      '', // title not required for visibility change
      '', // content not required for visibility change  
      '', // status not required for visibility change
      visibility: newVisibility,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil ubah ke ${newVisibility == 'public' ? 'Public' : 'Private'}')),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mengubah visibility'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _publishDraft(Map<String, dynamic> story, String visibility) async {
    final postId = story['id'];
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mempublikasikan...'), duration: Duration(seconds: 1)),
      );
    }

    // Only send status and visibility - backend allows partial updates
    final result = await _postService.updatePost(
      postId,
      '', // title not required
      '', // content not required
      'published', // Change status to published
      visibility: visibility,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil publish sebagai ${visibility == 'public' ? 'Public' : 'Private'}')),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mempublikasikan'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDeleteStory(Map<String, dynamic> story) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cerita?'),
        content: const Text(
          'Cerita ini akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && story['id'] != null) {
      final success = await _postService.deletePost(story['id']);
      if (success) {
        _loadStories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cerita berhasil dihapus'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus cerita')),
          );
        }
      }
    }
  }

  Future<void> _editJilid(Map<String, dynamic> jilid) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditJilidPage(jilid: jilid)),
    );
    if (mounted) {
      _loadJilid();
    }
  }

  Future<void> _confirmDeleteJilid(Map<String, dynamic> jilid) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jilid?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus jilid "${jilid['title']}"?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && jilid['id'] != null) {
      final success = await _seriesService.deleteSeries(jilid['id']);
      if (success) {
        _loadJilid();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Jilid berhasil dihapus')));
        }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gagal menghapus jilid')));
        }
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    // Navigate to Account Settings Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountSettingsPage(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC NAVIGASI EDIT PROFILE ---
  void _onEditProfilePressed() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _userName,
          initialUsername: _currentUsername,
          initialBio: _userBio,
          initialEmail: _userEmail,
          initialAvatarUrl: _profileImagePath,
          initialBannerUrl: _bannerImagePath,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _currentUsername = result['username'] ?? _currentUsername;
        _userBio = result['bio'] ?? _userBio;
        _userId = result['id']; // Save ID
        if (result['profilePath'] != null) _profileImagePath = result['profilePath'];
        if (result['bannerPath'] != null) _bannerImagePath = result['bannerPath'];
      });
      _loadStories(); 
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: _isLoadingProfile 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [_buildModernProfileHeader(context, textTheme)],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: _kPurpleColor,
                    unselectedLabelColor: _kSubTextColor,
                    indicatorColor: _kPurpleColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3,
                    labelStyle: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: 'Lembar'),
                      Tab(text: 'Jilid'),
                      Tab(text: 'Disukai'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStoriesTab(textTheme),
              _buildJilidTab(textTheme),
              _buildLikesTab(textTheme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index != _currentNavIndex) {
            NavigationHelper.navigateToPage(context, index);
          }
        },
      ),
      floatingActionButton: ExpandableFAB(
        onAddLembarComplete: _loadStories,
        onCreateJilidComplete: (result) => _loadJilid(),
      ),
    );
  }

  Widget _buildModernProfileHeader(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
            // === HEADER BANNER ===
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                  bottom: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: _getSmartImage(_bannerImagePath, _defaultBannerAsset),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _onEditProfilePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kTextColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(Icons.edit_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showLogoutConfirmation(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: _kTextColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // === HEADER AVATAR ===
            Positioned(
              bottom: -25,
              left: 36,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: _kBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _getSmartImage(_profileImagePath, _defaultAvatarAsset),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName, 
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _kTextColor,
                ),
              ),
              Text(
                _currentUsername, 
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _kSubTextColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: _kTextColor,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _followers.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' Pengikut'),
                        const TextSpan(
                          text: '  •  ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: _following.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' Mengikuti'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 192, 118, 224),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_stories.length} Karya',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _userBio,
                style: textTheme.bodyMedium?.copyWith(
                  color: _kSubTextColor,
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStoriesTab(TextTheme textTheme) {
    // Filter stories based on selected filter
    final filteredStories = _stories.where((story) {
      final visibility = story['visibility'] ?? 'Public';
      return visibility == _selectedFilter;
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isDense: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _kPurpleColor,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: _kPurpleColor,
                    fontWeight: FontWeight.w600,
                  ),
                  items: ['Public', 'Private', 'Draft'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null)
                      setState(() => _selectedFilter = newValue);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredStories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Belum ada lembar $_selectedFilter',
                style: const TextStyle(color: _kSubTextColor),
              ),
            ),
          )
        else
          ...filteredStories
              .map(
                (story) => _buildModernContentCard(
                  story,
                  textTheme,
                  onMenuTap: () => _showStoryOptionMenu(context, story),
                  isLikedTab: false,
                ),
              )
              .toList(),
      ],
    );
  }

Widget _buildLikesTab(TextTheme textTheme) {
  if (_likedBlogs.isEmpty) {
    return const Center(
      child: Text('Belum ada yang disukai', style: TextStyle(color: Colors.grey)),
    );
  }
  
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
    itemCount: _likedBlogs.length,
    itemBuilder: (context, index) {
      final blog = _likedBlogs[index];
      
      return _buildModernContentCard(
        blog,
        textTheme,
        onMenuTap: () => _showLikedOptionMenu(context, blog),
        isLikedTab: true,

        // --- HAPUS BARIS YANG SALAH TADI, GANTI JADI INI: ---
        
        // 1. Kirim status (True karena di tab disukai)
        isLiked: true, 
        
        // 2. Kirim jumlah like
        likeCount: int.tryParse(blog['likes'].toString()) ?? 0,

        // 3. Kirim fungsi apa yang terjadi kalau dipencet
        onLikeTap: () async {
           // Pastikan fungsi _toggleLikeAndRemove sudah kamu buat di bawah ya
           await _toggleLikeAndRemove(blog['id'], index); 
        },
      );
    },
  );
}

  // Buat fungsi pembantu biar rapi
  Future<void> _toggleLikeAndRemove(int postId, int index) async {
    // 1. Panggil Service
    final result = await _postService.toggleLike(postId);

    if (result['success'] == true) {
      // 2. Jika sukses unlike, langsung hapus dari layar
      if (mounted) {
        setState(() {
          _likedBlogs.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dihapus dari daftar suka"), 
            duration: Duration(seconds: 1)
          ),
        );
      }
    } else {
       // Error handling
       print("Gagal unlike: ${result['message']}");
    }
  }

Widget _buildModernContentCard(
  Map<String, dynamic> item,
  TextTheme textTheme, {
  required VoidCallback onMenuTap,
  bool isLikedTab = false,
  
  // --- [BARU] Tambahan Parameter ---
  bool isLiked = false,
  int likeCount = 0,
  VoidCallback? onLikeTap,
  // --------------------------------
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Check if post is draft - redirect to editor instead of BlogPage
          final isDraft = item['visibility'] == 'Draft';
          
          if (isDraft) {
            // Navigate to edit page for draft posts
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLembarPage(
                  postId: int.tryParse(item['id'].toString()) ?? 0,
                ),
              ),
            ).then((_) => _refreshData()); // Refresh after editing
          } else {
            // Navigate to BlogPage for published posts
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogPage(
                  postId: int.tryParse(item['id'].toString()) ?? 0,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // AVATAR KECIL DI CARD
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _getSmartImage(null, _defaultAvatarAsset),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['authorName'] ?? 'Pengguna',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _kTextColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item['date'] ?? '',
                          style: textTheme.labelSmall?.copyWith(
                            color: _kSubTextColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title with Visibility Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title']?.toString() ?? 'Tanpa Judul',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _kTextColor,
                              fontSize: 16,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item['visibility'] != null && !isLikedTab) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item['visibility'] == 'Draft' 
                                  ? Colors.orange.withOpacity(0.1)
                                  : _kPurpleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item['visibility'] == 'Draft' 
                                    ? Colors.orange
                                    : _kPurpleColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              item['visibility'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item['visibility'] == 'Draft' 
                                    ? Colors.orange
                                    : _kPurpleColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['snippet'] ?. toString()?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kSubTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // --- [BARU] Logic Tombol Like ---
                        InkWell(
                          onTap: onLikeTap, // Fungsi yang dikirim dari ListView
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0), // Padding biar enak dipencet
                            child: Row(
                              children: [
                                Icon(
                                  // Gunakan variabel isLiked, bukan isLikedTab lagi
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  // Warna merah kalau dilike
                                  color: isLiked ? Colors.red : _kSubTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  // Gunakan variabel likeCount agar update realtime
                                  likeCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // --------------------------------

                        const SizedBox(width: 16),
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 16,
                          color: _kSubTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['comments'] ?? '0',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kSubTextColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onMenuTap,
                          child: const Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: _kSubTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                    // THUMBNAIL (Pakai _getSmartImage)
                    image: DecorationImage(
                      image: _getSmartImage(item['thumbnail'], _defaultThumbAsset),
                      fit: BoxFit.cover,
                    ),
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

  Widget _buildJilidTab(TextTheme textTheme) {
    if (_jilid.isEmpty) {
      return const Center(
        child: Text('Belum ada Jilid', style: TextStyle(color: _kSubTextColor)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: _jilid.length,
      itemBuilder: (context, index) {
        return _buildModernJilidCard(_jilid[index], textTheme);
      },
    );
  }

  // === CARD JILID (REVERTED TO ICON IF NULL) ===
  Widget _buildModernJilidCard(
    Map<String, dynamic> jilid,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JilidDetailPage(jilid: jilid),
              ),
            );
            if (mounted) _loadJilid();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // === THUMBNAIL JILID (Pake Icon kalau null) ===
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _kPurpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    // Hanya pakai gambar jika datanya ADA
                    image: jilid['thumbnail'] != null
                        ? DecorationImage(
                            image: _getSmartImage(jilid['thumbnail'], ''), // Default string kosong karena dihandle di bawah
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  // Kalau data null, TAMPILKAN ICON
                  child: jilid['thumbnail'] == null
                      ? const Center(
                          child: Icon(
                            Icons.folder_open_rounded,
                            color: _kPurpleColor,
                            size: 32,
                          ),
                        )
                      : null,
                ),
                // ==============================================
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jilid['title'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jilid['description'] ?? 'Tidak ada deskripsi',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kSubTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${jilid['count'] ?? 0} Artikel',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _kSubTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: _kBackgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}