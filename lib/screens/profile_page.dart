import 'package:flutter/material.dart';
import 'blog_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/navigation_helper.dart';

const Color _kTextColor = Color(0xFF333333);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFFFFFFF);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSettingsClicked = false;
  String _selectedFilter = 'Public'; // Public, Private, Draft
  static const int _currentNavIndex = 3; // Profile page index

  // Sample user data
  final String _userName = 'Angel Tobing';
  final String _userInitials = 'AT';
  final String? _profileImageUrl = null; // Can be set to an image URL
  final int _followers = 0;
  final int _following = 1;

  // Sample stories data (blogs published by user)
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'hai',
      'snippet': 'namaku angel',
      'thumbnail': null,
      'date': 'Just now',
    },
    {
      'title': 'hai',
      'snippet': 'namaku angel',
      'thumbnail': null,
      'date': 'Just now',
    },
  ];

  // Sample liked blogs data
  final List<Map<String, dynamic>> _likedBlogs = [
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

  // State untuk like dan bookmark per blog
  final Map<int, bool> _likedBlogsState = {};
  final Map<int, bool> _bookmarkedBlogsState = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
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
        child: Column(
          children: [
            // Header dengan Settings Button
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
                    // Back button atau empty space
                    const SizedBox(width: 24),
                    // Settings Icon - transparan, warna berubah saat diklik
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _isSettingsClicked = !_isSettingsClicked;
                          });
                          // TODO: Navigate to settings page
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.settings_outlined,
                            color: _isSettingsClicked
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
            // Profile Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Builder(
                    builder: (context) {
                      final imageUrl = _profileImageUrl;
                      if (imageUrl != null) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(imageUrl),
                        );
                      }
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _userInitials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _kTextColor,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Name and Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _kTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_followers followers · $_following following',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: _kTextColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: _kTextColor,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'Stories'),
                  Tab(text: 'Likes'),
                ],
              ),
            ),
            // Filter Dropdown (only show in Stories tab)
            if (_tabController.index == 0)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kTextColor,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Public',
                            child: Text('Public'),
                          ),
                          DropdownMenuItem(
                            value: 'Private',
                            child: Text('Private'),
                          ),
                          DropdownMenuItem(
                            value: 'Draft',
                            child: Text('Draft'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Stories Tab
                  _buildStoriesTab(textTheme),
                  // Likes Tab
                  _buildLikesTab(textTheme),
                ],
              ),
            ),
          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create blog page
        },
        backgroundColor: _kPurpleColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildStoriesTab(TextTheme textTheme) {
    // Filter stories based on selected filter
    final filteredStories = _stories.where((story) {
      // In a real app, you would filter based on story['visibility']
      return true; // For now, show all
    }).toList();

    if (filteredStories.isEmpty) {
      return Center(
        child: Text(
          'No $_selectedFilter.toLowerCase() stories yet',
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: filteredStories.length,
      itemBuilder: (context, index) {
        final story = filteredStories[index];
        return _buildStoryCard(story, textTheme, index);
      },
    );
  }

  Widget _buildStoryCard(
    Map<String, dynamic> story,
    TextTheme textTheme,
    int index,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to story detail or edit
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
                        // Title
                        Text(
                          story['title'] as String,
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
                          story['snippet'] as String,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Date and Actions
                        Row(
                          children: [
                            Text(
                              story['date'] as String,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            // Bookmark Button
                            GestureDetector(
                              onTap: () {
                                // TODO: Handle bookmark
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.bookmark_add_outlined,
                                  size: 20,
                                  color: Colors.grey[600],
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
                                onTap: () => _showStoryMenu(context, story),
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
                  ),
                  // Right Side - Thumbnail
                  if (story['thumbnail'] != null)
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.network(
                        story['thumbnail'] as String,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const SizedBox(),
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

  Widget _buildLikesTab(TextTheme textTheme) {
    if (_likedBlogs.isEmpty) {
      return Center(
        child: Text(
          'No liked blogs yet',
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _likedBlogs.length,
      itemBuilder: (context, index) {
        final blog = _likedBlogs[index];
        return _buildBlogCard(blog, textTheme, index);
      },
    );
  }

  Widget _buildBlogCard(
    Map<String, dynamic> blog,
    TextTheme textTheme,
    int index,
  ) {
    final isLiked =
        _likedBlogsState[index] ?? true; // Liked blogs are liked by default
    final isBookmarked = _bookmarkedBlogsState[index] ?? false;

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
                                        _likedBlogsState[index] = !isLiked;
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
                                      _bookmarkedBlogsState[index] =
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

  void _showStoryMenu(BuildContext context, Map<String, dynamic> story) {
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
                leading: const Icon(Icons.edit, color: Colors.grey, size: 20),
                title: const Text('Edit', style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle edit
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
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                title: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle hapus
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
