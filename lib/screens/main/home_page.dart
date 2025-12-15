import 'dart:io';
import 'package:flutter/material.dart';
import 'blog_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/post_service.dart';

// Konstanta Warna Modern
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Colors.white;
const Color _kSubTextColor = Color(0xFF757575);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<int, bool> _likedBlogs = {};
  final Map<int, bool> _bookmarkedBlogs = {};
  bool _isNotificationClicked = false;
  static const int _currentNavIndex = 0;

  List<Map<String, dynamic>> _blogs = [];
  List<Map<String, dynamic>> _filteredBlogs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  final _postService = PostService();


  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';
  final String _defaultThumbAsset = 'assets/images/thumb_default.jpg';

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() => _isLoading = true);
    final posts = await _postService.getPosts();
    _processPosts(posts);
  }

  Future<void> _filterBlogs(String query) async {
    setState(() => _isLoading = true);
    final posts = await _postService.getPosts(search: query);
    _processPosts(posts);
  }

  void _processPosts(List<Map<String, dynamic>> posts) {
    final lembarBlogs = posts
        .map(
          (post) => {
            'id': post['id'],
            'authorName': post['author']['name'] ?? 'Pengguna',
            'authorInitials': '', 
            'title': post['title'] ?? 'Untitled',
            'snippet': post['snippet'] ?? '',
            'thumbnail': post['thumbnail_url'],
            'date': _formatDate(post['published_at']),
            'likes': post['stats']['likes']?.toString() ?? '0',
            'comments': post['stats']['comments']?.toString() ?? '0',
            'content': post['content'],
            'verified': false,
            'is_liked': post['is_liked'] ?? false,
            'is_bookmarked': post['is_bookmarked'] ?? false,
          },
        )
        .toList();

    if (mounted) {
      setState(() {
        _blogs = lembarBlogs;
        _filteredBlogs = lembarBlogs;
        _isLoading = false;
      });
    }
  }

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

  void _onItemTapped(int index) {
    if (index != _currentNavIndex) {
      NavigationHelper.navigateToPage(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER MODERN ===
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Lembar',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _kTextColor,
                                letterSpacing: -0.5,
                                fontFamily: 'Serif',
                              ),
                            ),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _kPurpleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _filterBlogs('');
                            }
                          });
                        },
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: _kTextColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  if (_isSearching) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _filterBlogs,
                      decoration: InputDecoration(
                        hintText: 'Cari tulisan atau penulis...',
                        prefixIcon: const Icon(Icons.search, color: _kSubTextColor),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // === BLOG FEED ===
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kPurpleColor))
                  : _filteredBlogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.feed_outlined,
                                size: 64,
                                color: Colors.grey[200],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Belum ada tulisan terbaru",
                                style: TextStyle(color: _kSubTextColor),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          itemCount: _filteredBlogs.length,
                          itemBuilder: (context, index) {
                            final blog = _filteredBlogs[index];
                            return _buildModernBlogCard(
                              blog,
                              textTheme,
                              primaryColor,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: ExpandableFAB(
        onAddLembarComplete: _loadBlogs,
      ),
    );
  }

  // === HELPER METHODS: MODERN MENU DESIGN ===

  void _showBlogMenu(BuildContext context, Map<String, dynamic> blog) {
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
                // Drag Handle
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

                // Item 1: Tidak Tertarik
                _buildMenuItem(
                  icon: Icons.remove_circle_outline_rounded,
                  label: 'Tidak tertarik',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),
                // Item 2: Bookmark
                _buildMenuItem(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Simpan ke Markah',
                  color: _kPurpleColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),

                // Item 3: Share
                _buildMenuItem(
                  icon: Icons.share_rounded,
                  label: 'Bagikan Tulisan',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Item Menu Modern
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

  Widget _buildModernBlogCard(
    Map<String, dynamic> blog,
    TextTheme textTheme,
    Color primaryColor,
  ) {
    final blogIndex = _blogs.indexOf(blog);
    final isLiked = blog['is_liked'] ?? false; // Read from API data
    final isBookmarked = blog['is_bookmarked'] ?? false; // Read from API data

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
                  postId: blog['id'],
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
                      // Author Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _getSmartImage(null, _defaultAvatarAsset),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    blog['authorName']?.toString() ??
                                        'Pengguna',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: _kTextColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (blog['verified'] == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: _kPurpleColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            blog['date']?.toString() ?? '',
                            style: textTheme.labelSmall?.copyWith(
                              color: _kSubTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        blog['title']?.toString() ?? 'Tanpa Judul',
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
                      // Snippet
                      Text(
                        blog['snippet']?.toString() ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kSubTextColor,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Stats Row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Optimistic update
                              setState(() {
                                blog['is_liked'] = !isLiked;
                                // Update likes count
                                final currentLikes = int.tryParse(blog['likes'].toString()) ?? 0;
                                blog['likes'] = (isLiked ? currentLikes - 1 : currentLikes + 1).toString();
                              });
                              
                              // Call API
                              final result = await _postService.toggleLike(blog['id']);
                              
                              if (!result['success']) {
                                // Revert on failure
                                setState(() {
                                  blog['is_liked'] = isLiked;
                                  final currentLikes = int.tryParse(blog['likes'].toString()) ?? 0;
                                  blog['likes'] = (isLiked ? currentLikes + 1 : currentLikes - 1).toString();
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'] ?? 'Gagal menyukai')),
                                  );
                                }
                              } else {
                                // Update with actual count from server
                                if (result['data'] != null && result['data']['new_count'] != null) {
                                  setState(() {
                                    blog['likes'] = result['data']['new_count'].toString();
                                  });
                                }
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isLiked ? Colors.red : _kSubTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  blog['likes']?.toString() ?? '0',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: _kSubTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                blog['comments']?.toString() ?? '0',
                                style: textTheme.bodySmall?.copyWith(
                                  color: _kSubTextColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              // Optimistic update
                              setState(() {
                                blog['is_bookmarked'] = !isBookmarked;
                              });
                              
                              // Call API
                              bool success;
                              if (!isBookmarked) {
                                success = await _postService.addBookmark(blog['id']);
                              } else {
                                success = await _postService.removeBookmark(blog['id']);
                              }
                              
                              if (!success) {
                                // Revert on failure
                                setState(() {
                                  blog['is_bookmarked'] = isBookmarked;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal mengubah markah')),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isBookmarked ? 'Dihapus dari Markah' : 'Ditambahkan ke Markah'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                              color: isBookmarked
                                  ? _kPurpleColor
                                  : _kSubTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // TITIK TIGA - MEMANGGIL MENU BARU
                          GestureDetector(
                            onTap: () => _showBlogMenu(context, blog),
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
                // Thumbnail
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      image: DecorationImage(
                        image: _getSmartImage(blog['thumbnail'], _defaultThumbAsset),
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
}