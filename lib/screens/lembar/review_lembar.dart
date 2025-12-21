import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/permission_helper.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import '../../data/services/post_service.dart';
import '../main/blog_page.dart';

// Konstanta Warna Modern
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kGradientStart = Color(0xFF8D07C6);
const Color _kGradientEnd = Color(0xFFDD01BE);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);

class ReviewLembarPage extends StatefulWidget {
  final String? title;
  final String? content;
  final dynamic documentJson;
  final bool isEditingDraft;
  final int? draftId;
  // [TAMBAHAN BARU] Variable untuk menampung link dari database
  final String? initialThumbnailUrl;

  const ReviewLembarPage({
    super.key,
    this.title,
    this.content,
    this.documentJson,
    this.isEditingDraft = false,
    this.draftId,
    this.initialThumbnailUrl,
  });

  @override
  State<ReviewLembarPage> createState() => _ReviewLembarPageState();
}

class _ReviewLembarPageState extends State<ReviewLembarPage> {
  late TextEditingController _titleController;
  late TextEditingController _snippetController;

  File? _coverImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _snippetController = TextEditingController(
      text: _generateSnippet(widget.content),
    );
  }

  String _generateSnippet(String? content) {
    if (content == null || content.isEmpty) return '';
    List<String> words = content.trim().split(RegExp(r'\s+'));
    if (words.length > 25) {
      return '${words.take(25).join(' ')}...';
    }
    return content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _snippetController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final hasPermission = await PermissionHelper.checkGalleryPermission(context);
    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Thumbnail',
          toolbarColor: _kPurpleColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Atur Thumbnail', aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _coverImage = File(croppedFile.path);
      });
    }
  }

  // [LOGIKA BARU] Menentukan gambar mana yang ditampilkan
  ImageProvider? _getDisplayImage() {
    // 1. Jika user baru pilih gambar dari galeri, pakai itu (Prioritas Utama)
    if (_coverImage != null) {
      return FileImage(_coverImage!);
    }
    // 2. Jika tidak, cek apakah ada link dari database (Draft lama)
    if (widget.initialThumbnailUrl != null &&
        widget.initialThumbnailUrl!.isNotEmpty) {
      return NetworkImage(widget.initialThumbnailUrl!);
    }
    // 3. Jika tidak ada keduanya, kosong
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    // --- TAMBAHKAN BARIS INI ---
    final displayImage = _getDisplayImage(); 
    // ---------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pratinjau Lembar',
          style: theme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _kTextColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _kTextColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Atur tampilan tulisanmu di Lembar.',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium?.copyWith(color: _kSubTextColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // === BAGIAN THUMBNAIL DIPERBARUI ===
                  Center(
                    child: GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          image: displayImage != null
                              ? DecorationImage(
                                  image: displayImage, // Gunakan displayImage
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: displayImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 28,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cover',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: _kPurpleColor,
                                    size: 14,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    textAlign: TextAlign.start,
                    style: theme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _kTextColor,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul Tulisan...',
                      hintStyle: TextStyle(color: Colors.grey.shade300),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _snippetController,
                    textAlign: TextAlign.start,
                    style: theme.bodyMedium?.copyWith(
                      color: _kSubTextColor,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tulis ringkasan singkat...',
                      hintStyle: TextStyle(color: Colors.grey.shade300),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 4,
                    minLines: 1,
                  ),
                  const SizedBox(height: 40),
                  const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _onDraftPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: _kSubTextColor,
                ),
                child: const Text('Simpan ke Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [_kGradientStart, _kGradientStart],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kPurpleColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _onPublishPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Publikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPublishPressed() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final postService = PostService();
    final contentToSend = jsonEncode(widget.documentJson);

    // Proses Simpan
    final result = widget.isEditingDraft && widget.draftId != null
        ? await postService.updatePost(
            widget.draftId!,
            _titleController.text.trim(),
            contentToSend,
            'published',
            snippet: _snippetController.text.trim(),
            thumbnail: _coverImage,
          )
        : await postService.createPost(
            _titleController.text.trim(),
            contentToSend,
            'published',
            snippet: _snippetController.text.trim(),
            thumbnail: _coverImage,
          );

    // Tutup Loading
    try {
      if (navigator.canPop()) navigator.pop();
    } catch (_) {}

    if (result['success']) {
      // --- UPDATE LOGIKA NAVIGASI ---

      // 1. Ambil ID Postingan Baru dari Server
      // (Pastikan backend mengirim balik data post, termasuk ID)
      final newPostId = result['data']['id'];

      try {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Lembar berhasil dipublikasikan!'),
            backgroundColor: _kPurpleColor,
          ),
        );
      } catch (_) {}

      // 2. Buka Halaman BlogPage
      // pushAndRemoveUntil: Membuka BlogPage dan menghapus history (Review & Editor)
      // (route) => route.isFirst : Sisakan halaman paling dasar (Home/Profile) di belakang
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BlogPage(postId: newPostId)),
        (route) => route.isFirst,
      );
    } else {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mempublikasikan'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _onDraftPressed() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final postService = PostService();
    final contentToSend = jsonEncode(widget.documentJson);

    final result = widget.isEditingDraft && widget.draftId != null
        ? await postService.updatePost(
            widget.draftId!,
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : widget.title ?? 'Untitled',
            contentToSend,
            'draft',
            snippet: _snippetController.text.trim(),
            thumbnail: _coverImage,
          )
        : await postService.createPost(
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : widget.title ?? 'Untitled',
            contentToSend,
            'draft',
            snippet: _snippetController.text.trim(),
            thumbnail: _coverImage,
          );

    // Tutup Loading
    try {
      if (navigator.canPop()) navigator.pop();
    } catch (_) {}

    if (result['success']) {
      // Ambil ID Postingan
      final newPostId = result['data']['id'];

      try {
        messenger.showSnackBar(
          const SnackBar(content: Text('Disimpan ke Draft')),
        );
      } catch (_) {}

      // Masuk ke BlogPage (Mode Draft)
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BlogPage(postId: newPostId)),
        (route) => route.isFirst,
      );
    } else {
      try {
        messenger.showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menyimpan draft'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (_) {}
    }
  }
}
