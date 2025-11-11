import 'package:flutter/material.dart';

const Color _kTextColor = Color(0xFF333333);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFFCFCFC);

class BlogPage extends StatefulWidget {
  final Map<String, dynamic> blog;

  const BlogPage({super.key, required this.blog});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  bool _isHeaderVisible = true;
  bool _isFollowing = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  final Map<String, bool> _commentLiked = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 50) {
      if (_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = false;
        });
      }
    } else {
      if (!_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }
  }

  void _showBlogMenu(BuildContext context) {
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

  void _showCommentMenu(BuildContext context, Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.grey),
                title: const Text('Blokir penulis'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle blokir penulis
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text(
                  'Laporkan komentar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Handle laporkan komentar
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Sample data - in real app, this would come from widget.blog
    final blogData = {
      'title': 'Lorem ipsum',
      'subtitle': '',
      'date': 'Oct 22, 2025',
      'authorName': 'John Doe',
      'authorInitials': 'JD',
      'authorFollowers': '228K',
      'authorFollowing': '6',
      'authorBio':
          'Lorem ipsum dolor sit amet\n@lettersfromrosie_ @lynrosee_ on ig',
      'content':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'tags': ['Lorem ipsum', 'dolor sit amet'],
      'likes': '2.3K',
      'comments': '66',
      'commentsList': [
        {
          'authorName': 'Aaa',
          'authorInitials': 'A',
          'date': 'Aug 8, 2025',
          'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          'likes': '12',
          'replies': 3,
        },
        {
          'authorName': 'John Doe',
          'authorInitials': 'JD',
          'date': 'Aug 7, 2025',
          'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          'likes': '5',
          'replies': 0,
        },
        {
          'authorName': 'Jane Smith',
          'authorInitials': 'JS',
          'date': 'Aug 6, 2025',
          'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          'likes': '8',
          'replies': 1,
        },
      ],
      'otherBlogs': [
        {
          'authorName': 'John Doe',
          'authorInitials': 'JD',
          'title': 'Lorem ipsum',
          'snippet': 'Lorem ipsum dolor sit amet...',
          'thumbnail': null,
          'date': 'Sep 15, 2025',
          'likes': '1.2K',
          'comments': '45',
        },
        {
          'authorName': 'John Doe',
          'authorInitials': 'JD',
          'title': 'Lorem ipsum',
          'snippet': 'Lorem ipsum dolor sit amet...',
          'thumbnail': null,
          'date': 'Sep 1, 2025',
          'likes': '890',
          'comments': '32',
        },
        {
          'authorName': 'John Doe',
          'authorInitials': 'JD',
          'title': 'Lorem ipsum',
          'snippet': 'Lorem ipsum dolor sit amet...',
          'thumbnail': null,
          'date': 'Aug 20, 2025',
          'likes': '1.5K',
          'comments': '58',
        },
      ],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Hide on scroll
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isHeaderVisible ? 56 : 0,
              child: _isHeaderVisible
                  ? Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: _kTextColor,
                                  ),
                                ),
                              ),
                            ),
                            // Search and Menu
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // TODO: Handle search
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.search,
                                        color: _kTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _showBlogMenu(context),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: _kTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blogData['title'] as String,
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _kTextColor,
                            ),
                          ),
                          if (blogData['subtitle'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              blogData['subtitle'] as String,
                              style: textTheme.bodyLarge?.copyWith(
                                color: _kTextColor,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Date
                          Text(
                            blogData['date'] as String,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Author Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: Text(
                              blogData['authorInitials'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _kTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              blogData['authorName'] as String,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _kTextColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing
                                  ? Colors.grey[200]
                                  : _kPurpleColor,
                              foregroundColor: _isFollowing
                                  ? _kTextColor
                                  : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              _isFollowing ? 'Mengikuti' : 'Ikuti',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Main Image
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[200],
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        blogData['content'] as String,
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kTextColor,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tags
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (blogData['tags'] as List<String>)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _kTextColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Author Profile Section
                    Container(
                      color: _kBackgroundColor,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  blogData['authorInitials'] as String,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _kTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Written by ${blogData['authorName']}',
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _kTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${blogData['authorFollowers']} followers · ${blogData['authorFollowing']} following',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isFollowing = !_isFollowing;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFollowing
                                      ? Colors.grey[200]
                                      : _kPurpleColor,
                                  foregroundColor: _isFollowing
                                      ? _kTextColor
                                      : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _isFollowing ? 'Mengikuti' : 'Ikuti',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            blogData['authorBio'] as String,
                            style: textTheme.bodyMedium?.copyWith(
                              color: _kTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Comments Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Responses (${blogData['comments']})',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _kTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Comment Input
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _kTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Apa pendapatmu?',
                                    hintStyle: textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _kTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Comments List
                          ...(blogData['commentsList'] as List).take(3).map((
                            comment,
                          ) {
                            final commentId = comment['authorName'] as String;
                            final isLiked = _commentLiked[commentId] ?? false;
                            final hasReplies =
                                (comment['replies'] as int? ?? 0) > 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      comment['authorInitials'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _kTextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              comment['authorName'] as String,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: _kTextColor,
                                                  ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _showCommentMenu(
                                                context,
                                                comment,
                                              ),
                                              child: const Icon(
                                                Icons.more_vert,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment['date'] as String,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          comment['content'] as String,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: _kTextColor,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Action buttons for comment
                                        Row(
                                          children: [
                                            // Like button
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _commentLiked[commentId] =
                                                      !isLiked;
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isLiked
                                                        ? Icons.thumb_up
                                                        : Icons
                                                              .thumb_up_outlined,
                                                    size: 16,
                                                    color: isLiked
                                                        ? _kPurpleColor
                                                        : Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    comment['likes']
                                                            as String? ??
                                                        '0',
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // View replies button (if has replies)
                                            if (hasReplies)
                                              GestureDetector(
                                                onTap: () {
                                                  // TODO: Show replies
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.comment_outlined,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${comment['replies']} balasan',
                                                      style: textTheme.bodySmall
                                                          ?.copyWith(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(width: 16),
                                            // Reply button
                                            GestureDetector(
                                              onTap: () {
                                                // TODO: Handle reply
                                              },
                                              child: Text(
                                                'Balas',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          // View All Comments Button
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to all comments page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kPurpleColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Lihat semua komentar',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Other Blogs from Author
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blog lain dari ${blogData['authorName']}',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _kTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...(blogData['otherBlogs'] as List)
                              .take(3)
                              .map(
                                (blog) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Main Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Author Info
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  child: Text(
                                                    blog['authorInitials']
                                                        as String,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _kTextColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    blog['authorName']
                                                        as String,
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Title
                                            Text(
                                              blog['title'] as String,
                                              style: textTheme.headlineMedium
                                                  ?.copyWith(
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
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            // Engagement Stats
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber[700],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  blog['date'] as String,
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
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
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
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
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                              )
                              .toList(),
                          // View All Blogs Button
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Navigate to all blogs from author
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kPurpleColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Lihat semua blog',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom navbar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navbar - Hide on scroll
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _isHeaderVisible ? 60 : 0,
        child: _isHeaderVisible
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Like
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: _isLiked
                                  ? _kPurpleColor
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              blogData['likes'] as String,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Comment
                      Row(
                        children: [
                          Icon(Icons.comment_outlined, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            blogData['comments'] as String,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Bookmark
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isBookmarked = !_isBookmarked;
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isBookmarked
                                  ? _kPurpleColor
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      // Share
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Handle share
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.share, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
