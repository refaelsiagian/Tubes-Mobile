import 'dart:io'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../data/services/post_service.dart';
import '../../data/services/auth_service.dart';
import '../lembar/edit_lembar.dart';

// --- IMPORT NAVIGASI PROFILE ---
import '../profile/profile_page.dart';       // Halaman Profil Saya
import '../profile/author_profile_page.dart'; // Halaman Profil Orang Lain

// Warna-warna konstanta
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFFFFFFF);
const Color _kSubTextColor = Color(0xFF757575);
const Color _kLikeColor = Color(0xFFFF4081);

class BlogPage extends StatefulWidget {
  final int postId;

  const BlogPage({super.key, required this.postId});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late quill.QuillController _quillController;
  final ScrollController _scrollController = ScrollController(); 

  bool _isFollowing = false;
  bool _isLiked = false;
  bool _isBookmarked = false;

  final _postService = PostService();
  final _authService = AuthService();
  
  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  final String _defaultAvatar = 'assets/images/ava_default.jpg';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadPostDetails(),
      _loadComments(),
      _loadCurrentUser(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadPostDetails() async {
    final result = await _postService.getPost(widget.postId);
    if (result['success'] && mounted) {
      setState(() {
        _post = result['data'];
        _isLiked = _post?['is_liked'] ?? false;
        _isBookmarked = _post?['is_bookmarked'] ?? false;
        _isFollowing = _post?['author']?['is_following'] ?? false;
        _loadContent(_post?['content']);
      });
    }
  }

  Future<void> _loadComments() async {
    final result = await _postService.getComments(widget.postId);
    if (result['success'] && mounted) {
      setState(() {
        _comments = List<Map<String, dynamic>>.from(result['data']);
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    final result = await _authService.getProfile();
    if (result['success'] && mounted) {
      setState(() {
        _currentUser = result['data'];
      });
    }
  }

  // --- LOGIC NAVIGASI PROFIL ---
  void _navigateToAuthorProfile() {
    final authorId = _post?['author']['id'];
    final currentUserId = _currentUser?['id'];

    if (authorId == null) return;

    // Jika ID Author sama dengan ID User yang login -> Buka ProfilePage (Edit mode)
    // Jika Beda -> Buka AuthorProfilePage (View Only)
    if (currentUserId != null && authorId == currentUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthorProfilePage(userId: authorId),
        ),
      );
    }
  }
  // -----------------------------

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    _commentController.clear();
    FocusScope.of(context).unfocus();

    final result = await _postService.postComment(widget.postId, content);
    
    if (mounted) {
      if (result['success']) {
        _loadComments();
        _loadPostDetails(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _isLiked = !_isLiked); 
    
    final result = await _postService.toggleLike(widget.postId);
    
    if (!result['success'] && mounted) {
      setState(() => _isLiked = !_isLiked); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } else {
      _loadPostDetails(); 
    }
  }

  Future<void> _toggleFollow() async {
    final username = _post?['author']?['username'];
    if (username == null) return;

    setState(() => _isFollowing = !_isFollowing);

    final result = await _authService.toggleFollow(username);

    if (mounted) {
      if (!result['success']) {
        setState(() => _isFollowing = !_isFollowing);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        _loadPostDetails();
      }
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isBookmarked = !_isBookmarked); 
    
    bool success;
    if (_isBookmarked) {
      success = await _postService.addBookmark(widget.postId);
    } else {
      success = await _postService.removeBookmark(widget.postId);
    }
    
    if (!success && mounted) {
      setState(() => _isBookmarked = !_isBookmarked); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah markah')),
      );
    }
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

  void _loadContent(dynamic content) {
    try {
      var contentData = content;

      if (contentData == null) {
        _quillController = quill.QuillController.basic();
        return;
      }

      if (contentData is String) {
        try {
          final json = jsonDecode(contentData);
          _quillController = quill.QuillController(
            document: quill.Document.fromJson(json),
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          );
        } catch (e) {
          final doc = quill.Document()..insert(0, contentData);
          _quillController = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
            readOnly: true,
          );
        }
      } else if (contentData is List) {
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(contentData.cast<dynamic>()),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } else {
        _quillController = quill.QuillController.basic();
      }
    } catch (e) {
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

  // --- UPDATED: Menu Opsi (Hapus Visibility, Ganti Status) ---
  void _showBlogOptions(BuildContext context) {
    final currentStatus = _post?['status'] ?? 'published'; // Pakai status
    
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
                // 1. Opsi Edit
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: _kTextColor),
                  title: const Text('Edit Lembar', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
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
                
                // 2. Opsi Status (Toggle Draft/Published)
                if (currentStatus == 'draft')
                  ListTile(
                    leading: const Icon(Icons.send_rounded, color: Colors.green),
                    title: const Text('Publikasi Sekarang', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _updateStatus('published'); // Ubah status
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.archive_outlined, color: Colors.orange),
                    title: const Text('Kembalikan ke Draft', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _updateStatus('draft'); // Ubah status
                    },
                  ),

                // 3. Opsi Hapus
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

  // --- UPDATED: Fungsi Ubah Status (Pengganti _changeVisibility) ---
// Di blog_page.dart, ganti fungsi _updateStatus lama dengan ini:
Future<void> _updateStatus(String newStatus) async {
  // Gunakan fungsi updateStatus yang baru dibuat, bukan updatePost
  final result = await _postService.updateStatus(
    widget.postId,
    newStatus,
  );

  if (mounted) {
    if (result['success']) {
      setState(() {
        _post = result['data']; // Update data lokal dengan respon terbaru
      });
      _loadPostDetails(); // Refresh detail untuk memastikan sinkronisasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil diubah ke $newStatus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengubah status')),
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
              Navigator.pop(context); // Tutup dialog
              final success = await _postService.deletePost(widget.postId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lembar berhasil dihapus')),
                  );
                  Navigator.pop(context, true); // Kembali dengan hasil true untuk refresh
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
    String getStatus() => _post?['status'] ?? 'published';
    String? getAuthorAvatar() => _post?['author']['avatar_url'];

    final List tags = []; 

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
                  // --- CLICKABLE AUTHOR INFO (TOP) ---
                  GestureDetector(
                    onTap: _navigateToAuthorProfile, // Panggil Fungsi Navigasi
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Agar klik area tidak melebar
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
                      ],
                    ),
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
                          
                          if (currentUserId == authorId) {
                            return const SizedBox.shrink();
                          }
                        }
                        
                        return GestureDetector(
                          onTap: _toggleFollow,
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
            
            // --- 4. PROFIL PENULIS BAWAH (Minimalis Border + Clickable) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _navigateToAuthorProfile, // Panggil Fungsi Navigasi
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                              const SizedBox(height: 2),
                              const Text(
                                'Lihat profil penulis',
                                style: TextStyle(color: _kPurpleColor, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _kSubTextColor),
                      ],
                    ),
                  ),
                ),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _submitComment,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Kirim", style: TextStyle(fontSize: 11, color: _kPurpleColor)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // LIST KOMENTAR
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _getSmartImage(comment['author']['avatar_url'], _defaultAvatar), // Smart Image
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment['author']['name'] ?? 'Anonim',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            comment['created_at'] ?? '',
                            style: const TextStyle(fontSize: 11, color: _kSubTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment['content'] ?? '',
                        style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 12),
                      if (index != _comments.length - 1)
                        Divider(height: 1, color: Colors.grey.shade100),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),

      // === BOTTOM NAVIGATION BAR (FIXED) ===
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Tombol Like
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? _kLikeColor : _kSubTextColor,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getLikes(),
                      style: TextStyle(
                        color: _isLiked ? _kLikeColor : _kSubTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Tombol Komentar
              GestureDetector(
                onTap: _scrollToComments,
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: _kSubTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getCommentsCount(),
                      style: const TextStyle(
                        color: _kSubTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- KELAS PEMBANTU UNTUK MERENDER GAMBAR ---
class ImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data;
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Image.file(
          File(imageUrl),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            );
          },
        ),
      );
    }
    return const SizedBox();
  }
}