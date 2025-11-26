import 'package:flutter/material.dart';
import 'blog_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/lembar_storage.dart';

const Color _kTextColor = Color(0xFF333333);
const Color _kPurpleColor = Color(0xFF8D07C6); // Warna aksen ungu baru
const Color _kBackgroundColor = Color(0xFFFFFFFF);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk like dan bookmark per blog
  final Map<int, bool> _likedBlogs = {};
  final Map<int, bool> _bookmarkedBlogs = {};
  bool _isNotificationClicked = false; // State untuk notifikasi
  static const int _currentNavIndex = 0; // Home page index

  List<Map<String, dynamic>> _blogs = [];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    // Load published lembar from storage
    final publishedLembar = await LembarStorage.getPublishedLembar();

    // Convert to blog format and combine with sample data
    final lembarBlogs = publishedLembar
        .map(
          (lembar) => {
            'authorName': lembar['authorName'] ?? 'Pengguna',
            'authorInitials': lembar['authorInitials'] ?? 'PG',
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

    // Sample blog data (fallback)
    final sampleBlogs = [
      {
        'authorName': 'John Doe',
        'authorInitials': 'JD',
        'title': 'Lorem ipsum',
        'snippet': 'Lorem ipsum dolor sit amet...',
        'thumbnail': null,
        'date': '6d ago',
        'likes': '1.5K',
        'comments': '14',
      },
      {
        'authorName': 'John Doe',
        'authorInitials': 'JD',
        'title': 'Lorem ipsum',
        'snippet': 'Lorem ipsum dolor sit amet...',
        'thumbnail': null,
        'date': 'Jul 28',
        'likes': '17K',
        'comments': '683',
        'verified': true,
      },
      {
        'authorName': 'John Doe',
        'authorInitials': 'JD',
        'title': 'Lorem ipsum',
        'snippet': 'Lorem ipsum dolor sit amet...',
        'thumbnail': null,
        'date': '3d ago',
        'likes': '892',
        'comments': '45',
      },
    ];

    setState(() {
      // Combine published lembar with sample blogs
      _blogs = [...lembarBlogs, ...sampleBlogs];
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Just now';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return '1d ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Just now';
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
            // Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0, // Dikurangi dari 16.0
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Lembar
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo1.png',
                          width: 24, // Dikurangi dari 32
                          height: 24, // Dikurangi dari 32
                        ),
                        const SizedBox(width: 6), // Dikurangi dari 8
                        Text(
                          'Lembar.',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 18, // Diperkecil
                          ),
                        ),
                      ],
                    ),
                    // Notification Icon - transparan, warna berubah saat diklik
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _isNotificationClicked = !_isNotificationClicked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: _isNotificationClicked
                                ? _kPurpleColor
                                : _kTextColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Blog Feed
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                itemCount: _blogs.length,
                itemBuilder: (context, index) {
                  final blog = _blogs[index];
                  return _buildBlogCard(blog, textTheme, primaryColor);
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

  void _showBlogMenu(BuildContext context, Map<String, dynamic> blog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12), // Tambah jarak di atas
              ListTile(
                dense: true,
                leading: const Icon(Icons.block, color: Colors.grey, size: 20),
                title: const Text(
                  'Tidak tertarik',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle tidak tertarik
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFDDDDDD),
                indent: 56,
                endIndent: 56,
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.bookmark_border,
                  color: Colors.grey,
                  size: 20,
                ),
                title: const Text(
                  'Tambahkan ke markah',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle tambah ke markah
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFDDDDDD),
                indent: 56,
                endIndent: 56,
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.share, color: Colors.grey, size: 20),
                title: const Text('Bagikan', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle bagikan
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFDDDDDD),
                indent: 56,
                endIndent: 56,
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.person_add_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                title: const Text(
                  'Ikuti penulis',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle ikuti penulis
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFDDDDDD),
                indent: 56,
                endIndent: 56,
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.volume_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                title: const Text(
                  'Bisukan penulis',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle bisukan penulis
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFDDDDDD),
                indent: 56,
                endIndent: 56,
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                title: const Text(
                  'Laporkan blog',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle laporkan blog
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlogCard(
    Map<String, dynamic> blog,
    TextTheme textTheme,
    Color primaryColor,
  ) {
    final blogIndex = _blogs.indexOf(blog);
    final isLiked = _likedBlogs[blogIndex] ?? false;
    final isBookmarked = _bookmarkedBlogs[blogIndex] ?? false;
    return Column(
      children: [
        Container(
          color: Colors.white, // Background card putih
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlogPage(blog: blog)),
              );
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Info
                        Row(
                          children: [
                            // Author Avatar
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                blog['authorInitials'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _kTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Author Name
                            Flexible(
                              child: Row(
                                children: [
                                  Text(
                                    blog['authorName'] as String,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (blog['verified'] == true) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: _kPurpleColor,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          blog['title'] as String,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _kTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Snippet
                        Text(
                          blog['snippet'] as String,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Engagement Stats - Sejajar dengan action buttons
                        Row(
                          children: [
                            // Left side: stats
                            Flexible(
                              child: Row(
                                children: [
                                  // Hilangkan icon bintang
                                  Text(
                                    blog['date'] as String,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Like icon - transparan, berubah warna saat diklik
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _likedBlogs[blogIndex] = !isLiked;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        isLiked
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_outlined,
                                        size: 16,
                                        color: isLiked
                                            ? _kPurpleColor
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    blog['likes'] as String,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    blog['comments'] as String,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right side: action buttons (always on the right)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Bookmark Button - transparan, berubah warna saat diklik
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _bookmarkedBlogs[blogIndex] =
                                          !isBookmarked;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 20,
                                      color: isBookmarked
                                          ? _kPurpleColor
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // More Options Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () => _showBlogMenu(context, blog),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right Side - Thumbnail with sample image
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          blog['thumbnail'] as String? ?? 'https://picsum.photos/200/300?random=${blog['id'] ?? blogIndex}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Divider antar card
        const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
      ],
    );
  }
}
