import 'package:flutter/material.dart';

const Color _kTextColor = Color(0xFF333333);
const Color _kPurpleColor = Color(0xFF673AB7);
const Color _kBackgroundColor = Color(0xFFFCFCFC);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Sample blog data
  final List<Map<String, dynamic>> _blogs = [
    {
      'authorName': 'Franco Amati',
      'authorInitials': 'SB',
      'publication': 'Scuzzbucket',
      'title': 'the more you pay attention',
      'snippet': '...',
      'thumbnail': null,
      'date': '6d ago',
      'likes': '1.5K',
      'comments': '14',
    },
    {
      'authorName': 'Jason McBride',
      'authorInitials': 'JM',
      'publication': null,
      'title': 'How to Create a Life You Love',
      'snippet': 'No magical thinking required',
      'thumbnail': null,
      'date': 'Jul 28',
      'likes': '17K',
      'comments': '683',
      'verified': true,
    },
    {
      'authorName': 'Kartscrut',
      'authorInitials': 'BC',
      'publication': 'Bootcamp',
      'title': 'Why nobody can read anymore',
      'snippet': 'In a world filled with distractions...',
      'thumbnail': null,
      'date': '3d ago',
      'likes': '892',
      'comments': '45',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Lembar
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo1.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(width: 8),
                        Text('Lembar.', style: textTheme.headlineLarge),
                      ],
                    ),
                    // Notification Icon
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: _kTextColor,
                      onPressed: () {},
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: _kPurpleColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pencarian'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Markah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create blog page
        },
        backgroundColor: _kPurpleColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _showBlogMenu(BuildContext context, Map<String, dynamic> blog) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.grey),
                title: const Text('Tidak tertarik'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle tidak tertarik
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.grey),
                title: const Text('Tambahkan ke markah'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle tambah ke markah
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.grey),
                title: const Text('Bagikan'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle bagikan
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_add_outlined,
                  color: Colors.grey,
                ),
                title: const Text('Ikuti penulis'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle ikuti penulis
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.volume_off_outlined,
                  color: Colors.grey,
                ),
                title: const Text('Bisukan penulis'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle bisukan penulis
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text(
                  'Laporkan blog',
                  style: TextStyle(color: Colors.red),
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
    return Column(
      children: [
        Padding(
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
                                  color: Colors.blue,
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
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                blog['date'] as String,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.thumb_up_outlined,
                                size: 16,
                                color: Colors.grey[600],
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
                            // Bookmark Button
                            IconButton(
                              icon: const Icon(Icons.bookmark_border),
                              iconSize: 20,
                              color: Colors.grey[600],
                              onPressed: () {
                                // TODO: Handle tambah ke markah
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            // More Options Button
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              iconSize: 20,
                              color: Colors.grey[600],
                              onPressed: () => _showBlogMenu(context, blog),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
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
        // Divider antar card
        const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
      ],
    );
  }
}
