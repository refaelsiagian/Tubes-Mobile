import 'dart:io';
import 'package:flutter/material.dart';
import '../main/blog_page.dart';
import '../jilid/jilid_detail_page.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/post_service.dart';
import '../../data/services/series_service.dart';

const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color _kSubTextColor = Color(0xFF757575);

class AuthorProfilePage extends StatefulWidget {
  final int userId; 
  final String? initialName;
  final String? initialUsername;
  final String? initialAvatarUrl;

  const AuthorProfilePage({
    super.key, 
    required this.userId,
    this.initialName,
    this.initialUsername,
    this.initialAvatarUrl,
  });

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data Author
  String _userName = '';
  String _currentUsername = '';
  String _rawUsername = '';
  String _userBio = '';
  String? _bannerImagePath;
  String? _profileImagePath;
  
  // Stats
  int _followers = 0;
  int _following = 0;
  int _publicWorksCount = 0;
  bool _isFollowing = false; 

  // Asset Default
  final String _defaultBannerAsset = 'assets/images/banner_default.jpg';
  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';
  final String _defaultThumbAsset = 'assets/images/thumb_default.jpg';

  // List Data
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _jilid = [];
  List<Map<String, dynamic>> _likedBlogs = []; 
  
  bool _isContentLoading = true; 

  final _postService = PostService();
  final _seriesService = SeriesService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
    
    _userName = widget.initialName ?? 'Penulis';
    _rawUsername = widget.initialUsername ?? '';
    _currentUsername = widget.initialUsername ?? '';
    _profileImagePath = widget.initialAvatarUrl;
    
    _loadAuthorData();
  }

  Future<void> _loadAuthorData() async {
    setState(() => _isContentLoading = true);

    try {
      // 1. Ambil Data Profil Dasar (Selalu ada, meskipun post kosong)
      // Kita jalankan secara paralel agar lebih cepat
      final results = await Future.wait([
        _authService.getUserProfileById(widget.userId),
        _postService.getPosts(userId: widget.userId),
        _seriesService.getSeries(userId: widget.userId),
      ]);

      final profileResult = results[0] as Map<String, dynamic>;
      final posts = results[1] as List<Map<String, dynamic>>;
      final jilid = results[2] as List<Map<String, dynamic>>;
      final liked = []; 

      if (mounted) {
        setState(() {
          // Update Profil dari API User (Prioritas Utama)
          if (profileResult['success']) {
            final author = profileResult['data'];
            _userName = author['name'] ?? _userName;
            _rawUsername = author['username'] ?? _rawUsername;
            _currentUsername = _rawUsername;
            _profileImagePath = author['avatar_url'] ?? _profileImagePath;
            _bannerImagePath = author['banner_url'];
            _userBio = author['bio'] ?? 'Penulis di Lembar';
            
            _followers = author['stats']?['followers'] ?? 0;
            _following = author['stats']?['following'] ?? 0;
            _isFollowing = author['is_following'] ?? false;
          } 
          // Fallback ke data dari Post jika profile fetch gagal
          else if (posts.isNotEmpty) {
            final author = posts[0]['author'];
            _userName = author['name'] ?? _userName;
            _rawUsername = author['username'] ?? _rawUsername;
            _currentUsername = _rawUsername;
            _profileImagePath = author['avatar_url'] ?? _profileImagePath;
            _bannerImagePath = author['banner_url'];
            _userBio = author['bio'] ?? 'Penulis di Lembar';
            
            _followers = author['stats']?['followers'] ?? 0;
            _following = author['stats']?['following'] ?? 0;
            _isFollowing = author['is_following'] ?? false;
          }

          if (posts.isEmpty && _userBio.isEmpty) {
            _userBio = 'Belum ada postingan publik.';
          }

          final publicPosts = posts.where((p) {
             final status = p['status'] ?? 'published';
             final visibility = p['visibility'] ?? 'public';
             return status == 'published' && visibility == 'public';
          }).toList();

          _publicWorksCount = publicPosts.length;

          _stories = publicPosts.map((post) => {
            'id': post['id'],
            'title': post['title'] ?? 'Untitled',
            'snippet': post['snippet'] ?? '',
            'thumbnail': post['thumbnail_url'],
            'date': _formatDate(post['published_at']),
            'likes': post['stats']['likes']?.toString() ?? '0',
            'comments': post['stats']['comments']?.toString() ?? '0',
            'authorName': post['author']['name'] ?? 'Pengguna',
            'visibility': 'Public',
          }).toList();

          _jilid = jilid;
          _likedBlogs = liked.map((post) => {
            'id': post['id'], 
          }).toList();

          _isContentLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isContentLoading = false);
        debugPrint("Error loading profile: $e");
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_rawUsername.isEmpty) return;
    
    // Optimistic UI update
    setState(() => _isFollowing = !_isFollowing);

    final result = await _authService.toggleFollow(_rawUsername);

    if (mounted) {
      if (!result['success']) {
        // Revert if failed
        setState(() => _isFollowing = !_isFollowing);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        // Refresh data to get latest stats
        _loadAuthorData();
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Baru saja';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  ImageProvider _getSmartImage(String? path, String defaultAsset) {
    if (path == null || path.isEmpty) return AssetImage(defaultAsset);
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path); 
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: NestedScrollView(
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
          body: _isContentLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildStoriesTab(textTheme),
                  _buildJilidTab(textTheme),
                  _buildLikesTab(textTheme), 
                ],
              ),
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
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                image: DecorationImage(
                  image: _getSmartImage(_bannerImagePath, _defaultBannerAsset),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 5)]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            
            // === HEADER AVATAR ===
            Positioned(
              bottom: -25,
              left: 24,
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
                  onBackgroundImageError: (exception, stackTrace) {},
                ),
              ),
            ),

            // TOMBOL FOLLOW
            Positioned(
              bottom: -17,
              right: 24,
              child: SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.white : _kPurpleColor,
                    foregroundColor: _isFollowing ? _kTextColor : Colors.white,
                    elevation: _isFollowing ? 1 : 3,
                    shadowColor: _kPurpleColor.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: _isFollowing ? BorderSide(color: Colors.grey.shade300, width: 1) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFollowing ? Icons.check : Icons.add,
                        size: 16,
                        color: _isFollowing ? Colors.green : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isFollowing ? 'Mengikuti' : 'Ikuti',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _isFollowing ? _kTextColor : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        // INFO USER
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
                '@$_currentUsername', 
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _kSubTextColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildStatItem(_followers.toString(), 'Pengikut'),
                  const Text('  •  ', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
                  _buildStatItem(_following.toString(), 'Mengikuti'),
                  const SizedBox(width: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 192, 118, 224),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_publicWorksCount Karya',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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

  Widget _buildStatItem(String count, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: _kTextColor, fontSize: 14),
        children: [
          TextSpan(text: count, style: const TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: ' $label'),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(TextTheme textTheme) {
    if (_stories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('Belum ada lembar publik', style: TextStyle(color: _kSubTextColor)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: _stories.length,
      itemBuilder: (context, index) {
        return _buildModernContentCard(
          _stories[index],
          textTheme,
        );
      },
    );
  }

  Widget _buildJilidTab(TextTheme textTheme) {
    if (_jilid.isEmpty) {
      return const Center(child: Text('Belum ada Jilid', style: TextStyle(color: _kSubTextColor)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: _jilid.length,
      itemBuilder: (context, index) {
        return _buildModernJilidCard(_jilid[index], textTheme);
      },
    );
  }

  Widget _buildLikesTab(TextTheme textTheme) {
    if (_likedBlogs.isEmpty) {
      return const Center(
        child: Text('Belum ada yang disukai', style: TextStyle(color: _kSubTextColor)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: _likedBlogs.length,
      itemBuilder: (context, index) {
        return _buildModernContentCard(
          _likedBlogs[index],
          textTheme,
        );
      },
    );
  }

  Widget _buildModernContentCard(Map<String, dynamic> item, TextTheme textTheme) {
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
                  postId: int.tryParse(item['id'].toString()) ?? 0,
                ),
              ),
            ).then((result) {
              if (result == true) {
                _loadAuthorData();
              }
            });
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
                            style: textTheme.labelSmall?.copyWith(color: _kSubTextColor, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
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
                      const SizedBox(height: 6),
                      Text(
                        item['snippet'] ?? '',
                        style: const TextStyle(fontSize: 13, color: _kSubTextColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 16, color: _kSubTextColor),
                          const SizedBox(width: 4),
                          Text(
                            item['likes'] ?? '0',
                            style: const TextStyle(fontSize: 12, color: _kSubTextColor),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.mode_comment_outlined, size: 16, color: _kSubTextColor),
                          const SizedBox(width: 4),
                          Text(
                            item['comments'] ?? '0',
                            style: const TextStyle(fontSize: 12, color: _kSubTextColor),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              _showSimpleMenu(context);
                            },
                            child: const Icon(Icons.more_horiz, size: 20, color: _kSubTextColor),
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
                      image: DecorationImage(
                        image: _getSmartImage(item['thumbnail'], _defaultThumbAsset),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {}, 
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

  Widget _buildModernJilidCard(Map<String, dynamic> jilid, TextTheme textTheme) {
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
              MaterialPageRoute(builder: (context) => JilidDetailPage(jilid: jilid)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _kPurpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    image: jilid['thumbnail'] != null
                        ? DecorationImage(
                            image: _getSmartImage(jilid['thumbnail'], ''),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: jilid['thumbnail'] == null
                      ? const Center(child: Icon(Icons.folder_open_rounded, color: _kPurpleColor, size: 32))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jilid['title'] ?? 'Tanpa Nama',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jilid['description'] ?? 'Tidak ada deskripsi',
                        style: const TextStyle(fontSize: 13, color: _kSubTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${jilid['count'] ?? 0} Artikel',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kSubTextColor),
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

  void _showSimpleMenu(BuildContext context) {
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
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: _kTextColor),
                  title: const Text('Bagikan'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                  title: const Text('Laporkan', style: TextStyle(color: Colors.redAccent)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: _kBackgroundColor, child: _tabBar);
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}