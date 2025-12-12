import 'dart:io'; // WAJIB ADA
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/post_service.dart';
import 'blog_page.dart';

// Konstanta Warna Modern
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Colors.white;
const Color _kSubTextColor = Color(0xFF757575);

class MarkahPage extends StatefulWidget {
  const MarkahPage({super.key});

  @override
  State<MarkahPage> createState() => _MarkahPageState();
}

class _MarkahPageState extends State<MarkahPage> {
  static const int _currentNavIndex = 2; // Markah page index

  List<Map<String, dynamic>> _bookmarkedBlogsList = [];
  bool _isLoading = true;
  final _postService = PostService();

  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';
  final String _defaultThumbAsset = 'assets/images/thumb_default.jpg';

  @override
  void initState() {
    super.initState();
    _loadBookmarkedBlogs();
  }

  Future<void> _loadBookmarkedBlogs() async {
    final postService = PostService();
    final posts = await postService.getBookmarks();

    final lembarBlogs = posts
        .map(
          (post) => {
            'id': post['id'],
            'authorName': post['author']?['name'] ?? 'Pengguna',
            'authorInitials': '', 
            'title': post['title'] ?? 'Untitled',
            'snippet': post['snippet'] ?? '',
            'thumbnail': post['thumbnail_url'],
            'date': _formatDate(post['published_at']),
            'likes': post['stats']?['likes']?.toString() ?? '0',
            'comments': post['stats']?['comments']?.toString() ?? '0',
            'documentJson': null, // Not needed for display
            'content': post['content'],
            'tags': [],
            'is_liked': post['is_liked'] ?? false,
          },
        )
        .toList();

    if (mounted) {
      setState(() {
        _bookmarkedBlogsList = lembarBlogs.reversed.toList();
        _isLoading = false;
      });
    }
  }

  // === FUNGSI PINTAR GAMBAR ===
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
    print('📅 _formatDate received: $dateString');
    if (dateString == null || dateString.isEmpty) {
      print('📅 dateString is null or empty');
      return 'Baru saja';
    }
    try {
      final date = DateTime.parse(dateString);
      final formatted = '${date.day}/${date.month}/${date.year}';
      print('📅 Formatted date: $formatted');
      return formatted;
    } catch (e) {
      print('❌ Error parsing date: $e');
      return 'Baru saja';
    }
  }

  void _onItemTapped(int index) {
    if (index != _currentNavIndex) {
      NavigationHelper.navigateToPage(context, index);
    }
  }

  void _showMarkahMenu(BuildContext context, Map<String, dynamic> blog) {
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
                  label: 'Bagikan Tulisan',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.bookmark_remove_rounded,
                  label: 'Hapus dari Markah',
                  color: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    final postService = PostService();
                    final success = await postService.removeBookmark(blog['id']);
                    
                    if (success) {
                      setState(() {
                        _bookmarkedBlogsList.remove(blog);
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Markah dihapus"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
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
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Markah',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _kTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPurpleColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: _kPurpleColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kPurpleColor),
                    )
                  : _bookmarkedBlogsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada markah',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _kSubTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      itemCount: _bookmarkedBlogsList.length,
                      itemBuilder: (context, index) {
                        final blog = _bookmarkedBlogsList[index];
                        return _buildModernBlogCard(blog, textTheme);
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
      floatingActionButton: const ExpandableFAB(),
    );
  }

  Widget _buildModernBlogCard(Map<String, dynamic> blog, TextTheme textTheme) {
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
              MaterialPageRoute(builder: (context) => BlogPage(postId: int.tryParse(blog['id'].toString()) ?? 0)),
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

                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _getSmartImage(null, _defaultAvatarAsset),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              blog['authorName']?.toString() ?? 'Pengguna',
                              style: textTheme.labelMedium?.copyWith(
                                color: _kTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      
                      Row(
                        children: [
                          // Like Button (Dynamic & Functional)
                          GestureDetector(
                            onTap: () async {
                              final isLiked = blog['is_liked'] ?? false;
                              
                              // Optimistic update
                              setState(() {
                                blog['is_liked'] = !isLiked;
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
                                  (blog['is_liked'] ?? false) 
                                      ? Icons.favorite 
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: (blog['is_liked'] ?? false) 
                                      ? Colors.red 
                                      : _kSubTextColor,
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
                          // Komentar
                          Icon(
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
                          const Spacer(),
                          
                          GestureDetector(
                            onTap: () async {
                              final postService = PostService();
                              final success = await postService.removeBookmark(blog['id']);
                              
                              if (success) {
                                setState(() {
                                  _bookmarkedBlogsList.remove(blog);
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Dihapus dari Markah"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Icon(
                              Icons.bookmark_rounded, 
                              size: 20,
                              color: _kPurpleColor, 
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _showMarkahMenu(context, blog),
                            child: const Icon(
                              Icons.more_horiz_rounded,
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
                      image: DecorationImage(
                        image: _getSmartImage(blog['thumbnail'], _defaultThumbAsset),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
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