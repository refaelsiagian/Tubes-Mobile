import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../main/blog_page.dart';
import '../jilid/jilid_detail_page.dart';
import '../jilid/edit_jilid_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';
import '../../data/services/lembar_storage.dart';

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

  // Stories data (blogs published by user)
  List<Map<String, dynamic>> _stories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _tabController.previousIndex) {
        setState(() {}); // Rebuild when tab changes
        // Refresh data when switching tabs
        _refreshData();
      }
    });
    _loadStories();
    _loadJilid();
  }

  // Refresh data when tab changes or when returning to this page
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

  // Jilid data (collections/bookmarks) - loaded from storage
  List<Map<String, dynamic>> _jilid = [];

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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: _kTextColor)),
            ),
            TextButton(
              onPressed: () {
Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(
                      onRegisterTap: () {
                      },
                      onForgotTap: () {
                      },
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
                    // Settings Menu with Logout
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: _isSettingsClicked ? _kPurpleColor : _kTextColor,
                        size: 22,
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutConfirmation(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.black54, size: 20),
                              SizedBox(width: 8),
                              Text('Logout', style: TextStyle(color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                      onCanceled: () {
                        setState(() {
                          _isSettingsClicked = false;
                        });
                      },
                      onOpened: () {
                        setState(() {
                          _isSettingsClicked = true;
                        });
                      },
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
                  Tab(text: 'Jilid'),
                ],
              ),
            ),
            // Filter Dropdown (only show in Stories tab)
            if (_tabController.index == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Container(
                  height: 35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFDDDDDD)),
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
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
                  ),
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
                  // Jilid Tab
                  _buildJilidTab(textTheme),
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
      floatingActionButton: ExpandableFAB(
        onAddLembarComplete: () {
          // Reload stories after returning from add lembar
          _loadStories();
        },
        onCreateJilidComplete: (result) {
          // Reload jilid from storage after creating new one
          _loadJilid();
        },
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

  Widget _buildJilidTab(TextTheme textTheme) {
    if (_jilid.isEmpty) {
      return Center(
        child: Text(
          'No collections yet',
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _jilid.length,
      itemBuilder: (context, index) {
        final jilid = _jilid[index];
        return _buildJilidCard(jilid, textTheme, index);
      },
    );
  }

  Widget _buildJilidCard(
    Map<String, dynamic> jilid,
    TextTheme textTheme,
    int index,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JilidDetailPage(jilid: jilid),
                ),
              );
              // Reload jilid from storage after editing
              if (mounted) {
                _loadJilid();
              }
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail or Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: jilid['thumbnail'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              jilid['thumbnail'] as String,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.bookmark,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          jilid['title'] as String,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _kTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(
                          jilid['description'] as String,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Count
                        Text(
                          '${jilid['count']} artikel',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More Options Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => _showJilidMenu(context, jilid),
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
            ),
          ),
        ),
        // Divider antar card
        const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
      ],
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

  void _showJilidMenu(BuildContext context, Map<String, dynamic> jilid) {
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
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to edit jilid page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditJilidPage(jilid: jilid),
                    ),
                  );
                  // Reload jilid from storage after editing
                  if (result == true && mounted) {
                    _loadJilid();
                  }
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
                  // TODO: Handle bagikan jilid
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
                onTap: () async {
                  Navigator.pop(context);
                  // Delete jilid from storage
                  final jilidId = jilid['id']?.toString();
                  if (jilidId != null && jilidId.isNotEmpty) {
                    await LembarStorage.deleteJilid(jilidId);
                    // Reload jilid list
                    _loadJilid();
                  }
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
