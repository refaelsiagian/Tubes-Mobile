import 'package:flutter/material.dart';
import 'blog_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/lembar_storage.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    final publishedLembar = await LembarStorage.getPublishedLembar();

    final lembarBlogs = publishedLembar
        .map(
          (lembar) => {
            'authorName': lembar['authorName'] ?? 'Pengguna',
            'authorInitials': '', 
            'title': lembar['title'] ?? 'Untitled',
            'snippet': lembar['snippet'] ?? '',
            'thumbnail': lembar['thumbnail'],
            'date': _formatDate(lembar['publishedAt']),
            'likes': lembar['likes'] ?? '0',
            'comments': lembar['comments'] ?? '0',
            'documentJson': lembar['documentJson'],
            'content': lembar['content'],
          },
        )
        .toList();

    setState(() {
      _blogs = lembarBlogs.reversed.toList();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Baru saja';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Baru saja';
          }
          return '${difference.inMinutes}m lalu';
        }
        return '${difference.inHours}j lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}h lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w lalu';
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
              child: Row(
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
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isNotificationClicked = !_isNotificationClicked;
                          });
                        },
                        icon: Icon(
                          _isNotificationClicked
                              ? Icons.notifications_rounded
                              : Icons.notifications_none_rounded,
                          color: _isNotificationClicked
                              ? _kPurpleColor
                              : _kTextColor,
                          size: 28,
                        ),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (!_isNotificationClicked)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // === BLOG FEED ===
            Expanded(
              child: _blogs.isEmpty
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
                      itemCount: _blogs.length,
                      itemBuilder: (context, index) {
                        final blog = _blogs[index];
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
      floatingActionButton: const ExpandableFAB(),
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
    final isLiked = _likedBlogs[blogIndex] ?? false;
    final isBookmarked = _bookmarkedBlogs[blogIndex] ?? false;

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
                  blog: {
                    'title': blog['title'],
                    'documentJson': blog['documentJson'],
                    'snippet': blog['snippet'] ?? '',
                    'date': blog['date'],
                    'authorName': blog['authorName'],
                    'authorInitials': blog['authorInitials'],
                    'thumbnail': blog['thumbnail'],
                    'likes': blog['likes'],
                    'comments': blog['comments'],
                    'tags': blog['tags'] ?? [],
                    'commentsList': blog['commentsList'] ?? [],
                    'otherBlogs': blog['otherBlogs'] ?? [],
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
                      // Author Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: const AssetImage('assets/images/ava_default.jpg'),
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
                            onTap: () {
                              setState(() {
                                _likedBlogs[blogIndex] = !isLiked;
                              });
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
                            onTap: () {
                              setState(() {
                                _bookmarkedBlogs[blogIndex] = !isBookmarked;
                              });
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
                        image: blog['thumbnail'] != null
                            ? NetworkImage(blog['thumbnail'])
                            : const AssetImage('assets/images/thumb_default.jpg')
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
}