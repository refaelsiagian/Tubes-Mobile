import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/navigation_helper.dart';
import 'blog_page.dart';

const Color _kTextColor = Color(0xFF333333);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFFFFFFF);

class MarkahPage extends StatefulWidget {
  const MarkahPage({super.key});

  @override
  State<MarkahPage> createState() => _MarkahPageState();
}

class _MarkahPageState extends State<MarkahPage> {
  static const int _currentNavIndex = 2; // Markah page index

  // State untuk like dan bookmark per blog
  final Map<int, bool> _likedBlogs = {};
  final Map<int, bool> _bookmarkedBlogs = {};

  // Sample bookmarked blogs data
  final List<Map<String, dynamic>> _bookmarkedBlogsList = [
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
      'authorName': 'Jane Smith',
      'authorInitials': 'JS',
      'title': 'Dolor sit amet',
      'snippet': 'Consectetur adipiscing elit...',
      'thumbnail': null,
      'date': '3d ago',
      'likes': '892',
      'comments': '45',
    },
  ];

  void _onItemTapped(int index) {
    if (index != _currentNavIndex) {
      NavigationHelper.navigateToPage(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

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
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Markah',
                      style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            // Bookmarked Blogs
            Expanded(
              child: _bookmarkedBlogsList.isEmpty
                  ? Center(
                      child: Text(
                        'No bookmarked blogs yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                        return _buildBlogCard(
                          blog,
                          textTheme,
                          primaryColor,
                          index,
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
    );
  }

  Widget _buildBlogCard(
    Map<String, dynamic> blog,
    TextTheme textTheme,
    Color primaryColor,
    int index,
  ) {
    final isLiked = _likedBlogs[index] ?? false;
    final isBookmarked =
        _bookmarkedBlogs[index] ?? true; // Bookmarked by default

    return Column(
      children: [
        Container(
          color: Colors.white,
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
                              child: Text(
                                blog['authorName'] as String,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
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
                        // Engagement Stats
                        Row(
                          children: [
                            // Left side: stats
                            Flexible(
                              child: Row(
                                children: [
                                  Text(
                                    blog['date'] as String,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Like icon
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _likedBlogs[index] = !isLiked;
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
                            // Right side: action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Bookmark Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _bookmarkedBlogs[index] = !isBookmarked;
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
                  // Right Side - Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: blog['thumbnail'] != null
                        ? Image.network(
                            blog['thumbnail'] as String,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(),
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

  void _showBlogMenu(BuildContext context, Map<String, dynamic> blog) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
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
}
