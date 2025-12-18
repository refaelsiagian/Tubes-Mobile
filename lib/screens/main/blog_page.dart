import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../data/services/post_service.dart';
import '../../data/services/auth_service.dart';
import '../lembar/edit_lembar.dart';

const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Colors.white;
const Color _kSubTextColor = Color(0xFF757575);

class BlogPage extends StatefulWidget {
  final int postId;

  const BlogPage({
    super.key,
    required this.postId,
  });

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();

  Map<String, dynamic>? _post;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isFollowing = false;
  late quill.QuillController _quillController;

  final String _defaultAvatar = 'assets/images/ava_default.jpg';

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _loadPostDetails();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final result = await _authService.getProfile();
    if (result['success']) {
      setState(() {
        _currentUser = result['data'];
      });
    }
  }

  Future<void> _loadPostDetails() async {
    setState(() => _isLoading = true);
    final result = await _postService.getPost(widget.postId);

    if (result['success']) {
      setState(() {
        _post = result['data'];
        _isLiked = _post?['is_liked'] ?? false;
        _isBookmarked = _post?['is_bookmarked'] ?? false;
        _isLoading = false;
      });
      _setupQuillController();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _setupQuillController() {
    final content = _post?['content'];
    if (content != null) {
      try {
        // Content is already a JSON string from PostService
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(content),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (e) {
        debugPrint('Error parsing quill content: $e');
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _showBlogOptions(BuildContext context) {
    final currentVisibility = _post?['visibility'] ?? 'Public';
    
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
                // Edit Option
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: _kTextColor),
                  title: const Text('Edit Lembar', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to EditLembarPage
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLembarPage(
                          postId: widget.postId,
                        ),
                      ),
                    ).then((_) => _loadPostDetails());
                  },
                ),
                
                // Visibility Options
                if (currentVisibility == 'Public')
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: Colors.blueAccent),
                    title: const Text('Ubah ke Private', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _changeVisibility('private');
                    },
                  )
                else if (currentVisibility == 'Private')
                  ListTile(
                    leading: const Icon(Icons.public_rounded, color: Colors.blueAccent),
                    title: const Text('Ubah ke Public', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _changeVisibility('public');
                    },
                  ),

                // Delete Option
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Hapus Lembar', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeVisibility(String newVisibility) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengubah visibility...'), duration: Duration(seconds: 1)),
    );

    final result = await _postService.updatePost(
      widget.postId,
      '', '', '', // Not changing these
      visibility: newVisibility,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil ubah ke ${newVisibility == 'public' ? 'Public' : 'Private'}')),
        );
        _loadPostDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lembar?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _postService.deletePost(widget.postId);
              if (mounted) {
                if (result) {
                  Navigator.pop(context); // Close BlogPage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lembar berhasil dihapus')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus lembar')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return Scaffold(
        backgroundColor: _kBackgroundColor,
        appBar: AppBar(
          backgroundColor: _kBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _kTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Gagal memuat lembar')),
      );
    }

    String getAuthorName() => _post?['author']['name'] ?? 'Pengguna';
    String getLikes() => _post?['stats']['likes']?.toString() ?? '0';
    String getCommentsCount() => _post?['stats']['comments']?.toString() ?? '0';
    String getDate() => _post?['published_at'] ?? 'Baru saja';
    String? getAuthorAvatar() => _post?['author']['avatar_url'];

    final List tags = []; // Backend belum support tags

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _kBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _kTextColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
              color: _isBookmarked ? _kPurpleColor : _kTextColor,
              size: 22,
            ),
            onPressed: _toggleBookmark,
          ),
          if (_post != null && _currentUser != null && _post!['author']['id'] == _currentUser!['id'])
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: _kTextColor, size: 22),
              onPressed: () => _showBlogOptions(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18, 
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getSmartImage(getAuthorAvatar(), _defaultAvatar), 
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getAuthorName(),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        _formatDate(_post?['published_at']),
                        style: const TextStyle(color: _kSubTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Only show Follow button if not viewing own post
                  if (_post?['author']?['id'] != null)
                    FutureBuilder(
                      future: _authService.getProfile(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data?['success'] == true) {
                          final currentUserId = snapshot.data?['data']?['id'];
                          final authorId = _post?['author']?['id'];
                          
                          // Don't show Follow button if viewing own post
                          if (currentUserId == authorId) {
                            return const SizedBox.shrink();
                          }
                        }
                        
                        return GestureDetector(
                          onTap: () => setState(() => _isFollowing = !_isFollowing),
                          child: Text(
                            _isFollowing ? 'Mengikuti' : 'Ikuti',
                            style: const TextStyle(
                              color: _kPurpleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // --- 2. KONTEN RICH TEXT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: quill.QuillEditor(
                controller: _quillController,
                scrollController: ScrollController(),
                focusNode: FocusNode(),
                config: quill.QuillEditorConfig(
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.zero,
                  enableInteractiveSelection: true,
                  embedBuilders: [ImageEmbedBuilder()],
                ),
              ),
            ),

            // 4. Tags
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 6, runSpacing: 6,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100, 
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.toString(),
                      style: const TextStyle(color: _kSubTextColor, fontSize: 11),
                    ),
                  )).toList(),
                ),
              ),
            
            const SizedBox(height: 40),
            
            // --- 4. PROFIL PENULIS BAWAH (Minimalis Border) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24, 
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getSmartImage(getAuthorAvatar(), _defaultAvatar), // Smart Image
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 2),
                        Text(
                          getAuthorName(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- BAGIAN KOMENTAR MEDIUM STYLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tanggapan (${getCommentsCount()})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kTextColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // INPUT KOMENTAR (Style Box Shadow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _getSmartImage(_currentUser?['avatar_url'], _defaultAvatar), // Use current user avatar
                        ),
                        const SizedBox(width: 8),
                        Text(_currentUser?['name'] ?? "Pengguna", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), // Use current user name
                      ],
                    ),
                    TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Apa tanggapanmu?',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                      maxLines: null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _commentController.clear();
                          },
                          child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (_commentController.text.trim().isEmpty) return;
                            
                            final result = await _postService.postComment(widget.postId, _commentController.text.trim());
                            if (mounted) {
                              if (result['success']) {
                                _commentController.clear();
                                _loadPostDetails(); // Refresh to show new comment
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Komentar berhasil dikirim')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gagal mengirim komentar')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPurpleColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: const Text('Kirim', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // LIST KOMENTAR
            if (_post?['comments'] != null)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: (_post?['comments'] as List).length,
                separatorBuilder: (context, index) => const Divider(height: 32, color: Color(0xFFF0F0F0)),
                itemBuilder: (context, index) {
                  final comment = _post?['comments'][index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _getSmartImage(comment['user']['avatar_url'], _defaultAvatar),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment['user']['name'] ?? 'Pengguna',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(comment['created_at']),
                            style: const TextStyle(color: _kSubTextColor, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment['content'] ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  );
                },
              ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.red : _kSubTextColor,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getLikes(),
                      style: const TextStyle(color: _kSubTextColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Comment Button
              GestureDetector(
                onTap: _scrollToComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: _kSubTextColor, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      getCommentsCount(),
                      style: const TextStyle(color: _kSubTextColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Bookmark Button
              GestureDetector(
                onTap: _toggleBookmark,
                child: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
                  color: _isBookmarked ? _kPurpleColor : _kSubTextColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              // Share Button
              const Icon(Icons.share_outlined, color: _kSubTextColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // === HELPER METHODS ===

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
          if (difference.inMinutes == 0) return 'Baru saja';
          return '${difference.inMinutes}m lalu';
        }
        return '${difference.inHours}j lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}h lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  Future<void> _toggleLike() async {
    final originalIsLiked = _isLiked;
    final currentLikes = int.tryParse(_post?['stats']['likes']?.toString() ?? '0') ?? 0;

    setState(() {
      _isLiked = !_isLiked;
      _post?['stats']['likes'] = _isLiked ? currentLikes + 1 : currentLikes - 1;
    });

    final result = await _postService.toggleLike(widget.postId);
    if (!result['success']) {
      setState(() {
        _isLiked = originalIsLiked;
        _post?['stats']['likes'] = currentLikes;
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
          _post?['stats']['likes'] = result['data']['new_count'];
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final originalIsBookmarked = _isBookmarked;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    bool success;
    if (!originalIsBookmarked) {
      success = await _postService.addBookmark(widget.postId);
    } else {
      success = await _postService.removeBookmark(widget.postId);
    }

    if (!success) {
      setState(() {
        _isBookmarked = originalIsBookmarked;
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
            content: Text(!originalIsBookmarked ? 'Ditambahkan ke Markah' : 'Dihapus dari Markah'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }
}

class ImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    quill.EmbedContext embedContext,
  ) {
    final imageUrl = embedContext.node.value.data;
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl.toString(),
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}