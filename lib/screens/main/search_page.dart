import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/utils/navigation_helper.dart';
import 'blog_page.dart';
import '../../data/services/post_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/search_service.dart';

// Konstanta Warna
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);
const Color _kBackgroundColor = Colors.white;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  static const int _currentNavIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late TabController _tabController;

  final _postService = PostService();
  final _authService = AuthService();
  final _searchService = SearchService();

  List<Map<String, dynamic>> _lembarResults = [];
  List<Map<String, dynamic>> _orangResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Assets defaults
  final String _defaultAvatarAsset = 'assets/images/ava_default.jpg';
  final String _defaultThumbAsset = 'assets/images/thumb_default.jpg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.removeListener(_onFocusChange);
    _searchFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentNavIndex) {
      NavigationHelper.navigateToPage(context, index);
    }
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _hasSearched = true;
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _searchService.searchPosts(query), // Tab Lembar
        _searchService.searchUsers(query), // Tab Orang
      ]);

      if (mounted) {
        setState(() {
          _lembarResults = results[0];
          _orangResults = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari: $e')),
        );
      }
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _searchFocus.requestFocus(); // Ensure focus stays to keep header collapsed
    setState(() {
      _hasSearched = false;
      _lembarResults = [];
      _orangResults = [];
    });
  }

  // Helper Image
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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Header collapses if focused or has text
    final bool isHeaderCollapsed =
        _searchFocus.hasFocus || _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER & SEARCH BAR
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Header Title
                  AnimatedCrossFade(
                    firstChild: Container(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          Text(
                            'Cari',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _kTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(width: double.infinity), 
                    crossFadeState: isHeaderCollapsed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.topCenter,
                  ),
                  if (isHeaderCollapsed)
                    const SizedBox(height: 16), // Spacer top when collapsed

                  // Search Box Row
                  Row(
                    children: [
                      // Back Button (Only when collapsed)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: isHeaderCollapsed ? 40 : 0,
                        child: isHeaderCollapsed
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: _kTextColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocus.unfocus();
                                  setState(() {
                                    _hasSearched = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      
                      // Search Field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            style: const TextStyle(
                              color: _kTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            cursorColor: _kPurpleColor,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _onSearchSubmitted,
                            decoration: InputDecoration(
                              hintText: 'Temukan cerita menarik...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.normal,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 20),
                                      color: Colors.grey,
                                      onPressed: _onClearSearch,
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. CONTENT AREA
            Expanded(
            child: _hasSearched
                ? (_isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSearchResults(textTheme))
                : _buildPlaceholder(),
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

  Widget _buildSearchResults(TextTheme textTheme) {
    return Column(
      children: [
        // Tab Bar styled like ProfilePage
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: TabBar(
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
              Tab(text: 'Orang'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLembarResult(textTheme),
              _buildOrangResult(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLembarResult(TextTheme textTheme) {
    if (_lembarResults.isEmpty) {
      return const Center(child: Text('Tidak ada lembar ditemukan', style: TextStyle(color: _kSubTextColor)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _lembarResults.length,
      itemBuilder: (context, index) {
        final blog = _lembarResults[index];
        return _buildModernBlogCard(blog, textTheme);
      },
    );
  }

  // === MODERN CARD STYLE (Ported from HomePage) ===
  Widget _buildModernBlogCard(
    Map<String, dynamic> blog,
    TextTheme textTheme,
  ) {
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
             // Navigate to detail
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => BlogPage(
                   postId: blog['id'] is int ? blog['id'] : int.parse(blog['id'].toString()),
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
                            backgroundImage:
                                _getSmartImage(blog['author']?['avatar_url'], _defaultAvatarAsset),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    blog['author']?['name'] ?? 'Pengguna',
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
                            _formatDate(blog['published_at']),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite_border_rounded,
                                size: 16,
                                color: _kSubTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                blog['stats']?['likes']?.toString() ?? '0',
                                style: textTheme.bodySmall?.copyWith(
                                  color: _kSubTextColor,
                                ),
                              ),
                            ],
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
                                blog['stats']?['comments']?.toString() ?? '0',
                                style: textTheme.bodySmall?.copyWith(
                                  color: _kSubTextColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.bookmark_border_rounded,
                            size: 20,
                            color: _kSubTextColor,
                          ),
                          const SizedBox(width: 12),
                          // TITIK TIGA
                          const Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: _kSubTextColor,
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
                        image: _getSmartImage(
                            blog['thumbnail_url'], _defaultThumbAsset),
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

Widget _buildOrangResult() {
    if (_orangResults.isEmpty) {
      return const Center(
          child: Text('Tidak ada pengguna ditemukan',
              style: TextStyle(color: _kSubTextColor)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orangResults.length,
      itemBuilder: (context, index) {
        final user = _orangResults[index];
        
        // Ambil data stats (Followers) dari backend
        // Ingat backend kirim: stats: { followers: 10, ... }
        final stats = user['stats'] ?? {};
        // Gunakan logika aman seperti di Profile Page
        final followersCount = stats['followers'] ?? stats['followers_count'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12), // Kasih jarak antar item
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  _getSmartImage(user['avatar_url'], _defaultAvatarAsset),
            ),
            title: Text(
              user['name'] ?? 'Pengguna',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${user['username'] ?? ''}',
                  style: const TextStyle(color: _kSubTextColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                // Tampilkan Stats Follower!
                Text(
                  '$followersCount Pengikut', 
                  style: const TextStyle(
                    color: _kPurpleColor, 
                    fontWeight: FontWeight.w600, 
                    fontSize: 12
                  ),
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () {
                // TODO: Navigasi ke Profil Orang Lain
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                side: const BorderSide(color: _kPurpleColor),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Lihat',
                  style: TextStyle(color: _kPurpleColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
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

  Widget _buildPlaceholder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tampilan saat user mengetik (Placeholder Hasil)
          if (_searchController.text.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 60,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tekan enter untuk mencari "${_searchController.text}"',
                      style: TextStyle(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            // Tampilan Kosong Default
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Icon(
                      Icons.explore_off_outlined,
                      size: 60,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ketik sesuatu untuk mencari',
                      style: TextStyle(color: _kSubTextColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
