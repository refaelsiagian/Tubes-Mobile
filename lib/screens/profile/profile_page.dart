import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../main/blog_page.dart';
import '../jilid/jilid_detail_page.dart';
import '../jilid/edit_jilid_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/lembar_storage.dart';
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

  // Sample user data (FINAL STRUCTURE)
  String _userName = 'Dells';
  final String _userInitials = 'AT';
  String _userBio =
      'Penulis & Kreator yang fokus pada kesederhanaan & kegunaan.';
  String _userEmail = 'dells.adelia@example.com';
  String _currentUsername = '@dells';

  final String? _bannerImageUrl = 'assets/images/banner_default.jpg';

  final String? _profileImageUrl = null;
  final int _followers = 120;
  final int _following = 45;

  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _jilid = [];

  // Sample liked blogs
  final List<Map<String, dynamic>> _likedBlogs = [
    {
      'authorName': 'John Doe',
      'authorInitials': '',
      'title': 'Lorem ipsum dolor sit amet',
      'snippet': 'Consectetur adipiscing elit...',
      'thumbnail': null,
      'date': '6d ago',
      'likes': '1.5K',
      'comments': '14',
    },
  ];

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
    _loadStories();
    _loadJilid();
  }

  void _refreshData() {
    _loadJilid();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final stories = await LembarStorage.getStories();
    setState(() {
      _stories = stories;
    });
  }

  Future<void> _loadJilid() async {
    final jilid = await LembarStorage.getJilid();
    setState(() {
      _jilid = jilid;
    });
  }

  // --- LOGIC: STORY MENU (Untuk Tab Lembar) ---
  void _showStoryOptionMenu(BuildContext context, Map<String, dynamic> story) {
    final currentVisibility = story['visibility'] ?? 'Publik';

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
                  icon: currentVisibility == 'Publik'
                      ? Icons.lock_outline_rounded
                      : Icons.public_rounded,
                  label: currentVisibility == 'Publik'
                      ? 'Ubah ke Private'
                      : 'Ubah ke Publik',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _changeVisibility(story);
                  },
                ),
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

  // --- LOGIC: LIKED MENU (Untuk Tab Disukai) ---
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
                // Opsi 1: Bagikan
                _buildMenuItem(
                  icon: Icons.share_rounded,
                  label: 'Bagikan',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    // Implementasi share
                  },
                ),
                const SizedBox(height: 12),
                // Opsi 2: Hapus dari Disukai
                _buildMenuItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Hapus dari Disukai',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    // Implementasi unlike (Simulasi)
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

  Future<void> _changeVisibility(Map<String, dynamic> story) async {
    final currentVisibility = story['visibility'] ?? 'Publik';
    final newVisibility = currentVisibility == 'Publik' ? 'Private' : 'Publik';
    final newStoryData = Map<String, dynamic>.from(story);
    newStoryData['visibility'] = newVisibility;

    if (story['id'] != null) {
      await LembarStorage.updateStory(story['id'].toString(), newStoryData);
      _loadStories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visibilitas diubah menjadi $newVisibility'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
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
      await LembarStorage.deleteStory(story['id'].toString());
      _loadStories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cerita berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      await LembarStorage.deleteJilid(jilid['id'].toString());
      _loadJilid();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Jilid berhasil dihapus')));
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 40, color: _kTextColor),
                const SizedBox(height: 16),
                const Text(
                  'Keluar Akun?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah kamu yakin ingin keluar dari aplikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kSubTextColor),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: _kTextColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(
                                onRegisterTap: () {},
                                onForgotTap: () {},
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      body: SafeArea(
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

  // LOGIC NAVIGASI BARU
  void _onEditProfilePressed() async {
    // Navigasi ke EditProfilePage dan mengirim semua data profil
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _userName,
          initialUsername: _currentUsername, // Mengirim Username
          initialBio: _userBio,
          initialEmail: _userEmail, // Mengirim Email
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _currentUsername = result['username'] ?? _currentUsername;
        _userBio = result['bio'] ?? _userBio;
      });
      _loadStories(); 
    }
  }


  Widget _buildModernProfileHeader(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomLeft,
          children: [
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
                // Banner tetap default
                image: DecorationImage(
                  image: _bannerImageUrl != null
                      ? AssetImage(_bannerImageUrl!)
                      : const AssetImage('assets/images/banner_default.jpg'),
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
                          onPressed: _onEditProfilePressed, // Memanggil fungsi navigasi baru
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
                  backgroundColor: Colors.grey.shade300,
                  // Ava tetap default
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : const AssetImage('assets/images/ava_default.jpg')
                          as ImageProvider,
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
                          text: '$_followers',
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
                          text: '$_following',
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
    final filteredStories = _stories;
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
        child: Text(
          'Belum ada yang disukai',
          style: TextStyle(color: _kSubTextColor),
        ),
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
        );
      },
    );
  }

  Widget _buildModernContentCard(
    Map<String, dynamic> item,
    TextTheme textTheme, {
    required VoidCallback onMenuTap,
    bool isLikedTab = false,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogPage(
                  blog: {
                    'title': item['title'],
                    'documentJson': item['documentJson'],
                    'snippet': item['snippet'] ?? '',
                    'date': item['date'] ?? 'Baru saja',
                    'authorName': item['authorName'] ?? _userName,
                    'authorInitials': item['authorInitials'] ?? '',
                    'thumbnail': item['thumbnail'],
                    'likes': item['likes'] ?? '0',
                    'comments': item['comments'] ?? '0',
                    'tags': item['tags'] ?? [],
                  },
                ),
              ),
            );
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
                          // Ganti Icon Person -> ava_default
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: const AssetImage(
                              'assets/images/ava_default.jpg',
                            ),
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
                      Text(
                        item['title'] ?? 'Tanpa Judul',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kTextColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['snippet'] ?? '',
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
                          Icon(
                            isLikedTab
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: isLikedTab ? Colors.red : _kSubTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['likes'] ?? '0',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kSubTextColor,
                            ),
                          ),
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
                      // thumb_default tetap dipakai di sini (Tab Lembar)
                      image: DecorationImage(
                        image: item['thumbnail'] != null
                            ? NetworkImage(item['thumbnail'])
                            : const AssetImage(
                                    'assets/images/thumb_default.jpg',
                                  )
                                  as ImageProvider,
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
                // === REVERT: KEMBALI KE ICON FOLDER UNTUK JILID ===
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _kPurpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    // Logic: Kalau misal nanti ada fitur upload thumbnail Jilid, baru muncul. 
                    // Kalau null, tidak pakai default image.
                    image: jilid['thumbnail'] != null
                        ? DecorationImage(
                            image: NetworkImage(jilid['thumbnail']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: jilid['thumbnail'] == null
                      ? const Center(
                          child: Icon(
                            Icons.folder_open_rounded, // Icon Folder
                            color: _kPurpleColor,
                            size: 32,
                          ),
                        )
                      : null,
                ),
                // ================================================
                
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