import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import '../../data/services/post_service.dart';
import '../../data/services/post_service.dart';

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

  const ReviewLembarPage({
    super.key,
    this.title,
    this.content,
    this.documentJson,
    this.isEditingDraft = false,
    this.draftId,
  });

  @override
  State<ReviewLembarPage> createState() => _ReviewLembarPageState();
}

class _ReviewLembarPageState extends State<ReviewLembarPage> {
  String _selectedVisibility = 'Publik';
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
        IOSUiSettings(
          title: 'Atur Thumbnail',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _coverImage = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pratinjau Lembar',
          style: theme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _kTextColor),
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
                crossAxisAlignment: CrossAxisAlignment.start, // Rata Kiri untuk teks
                children: [
                  
                  // 1. INSTRUKSI 
                  Center(
                    child: Text(
                      'Atur tampilan tulisanmu di Lembar.',
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium?.copyWith(color: _kSubTextColor),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // 2. THUMBNAIL
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
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: _coverImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      size: 28, color: Colors.grey.shade400),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cover',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500
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
                                  child: const Icon(Icons.edit,
                                      color: _kPurpleColor, size: 14),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. JUDUL 
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

                  // 4. SNIPPET 
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
                  const SizedBox(height: 10),

                  // Opsi Visibility 
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: _showVisibilityBottomSheet,
                    title: const Text('Siapa yang bisa melihat ini?',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kTextColor)),
                    subtitle: Text(
                      _selectedVisibility == 'Publik'
                          ? 'Semua orang di Lembar'
                          : 'Hanya kamu (Pribadi)',
                      style:
                          const TextStyle(fontSize: 12, color: _kSubTextColor),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedVisibility == 'Publik' 
                            ? _kPurpleColor.withOpacity(0.1) 
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedVisibility,
                            style: TextStyle(
                              color: _selectedVisibility == 'Publik' ? _kPurpleColor : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, 
                              color: _selectedVisibility == 'Publik' ? _kPurpleColor : Colors.grey[700]),
                        ],
                      ),
                    ),
                  ),
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
                  gradient: const LinearGradient(colors: [_kGradientStart, _kGradientStart]),
                  boxShadow: [
                    BoxShadow(color: _kPurpleColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _onPublishPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, 
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'Publikasi', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  void _showVisibilityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _kPurpleColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.public, color: _kPurpleColor)),
                title: const Text('Publik', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Semua orang bisa melihat tulisan ini'),
                onTap: () { setState(() => _selectedVisibility = 'Publik'); Navigator.pop(ctx); },
                trailing: _selectedVisibility == 'Publik' ? const Icon(Icons.check, color: _kPurpleColor) : null,
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_outline, color: Colors.grey)),
                title: const Text('Private', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Hanya kamu yang bisa melihat'),
                onTap: () { setState(() => _selectedVisibility = 'Private'); Navigator.pop(ctx); },
                trailing: _selectedVisibility == 'Private' ? const Icon(Icons.check, color: _kPurpleColor) : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onPublishPressed() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final postService = PostService();
    // Kirim documentJson sebagai string agar format Quill terjaga
    final contentToSend = jsonEncode(widget.documentJson); 
    
    // Map dropdown value to backend visibility
    final visibility = _selectedVisibility == 'Publik' ? 'public' : 'private';
    
    // Check if editing draft or creating new
    final result = widget.isEditingDraft && widget.draftId != null
        ? await postService.updatePost(
            widget.draftId!,
            _titleController.text.trim(),
            contentToSend,
            'published',
            snippet: _snippetController.text.trim(),
            visibility: visibility,
            thumbnail: _coverImage,
          )
        : await postService.createPost(
            _titleController.text.trim(),
            contentToSend,
            'published',
            snippet: _snippetController.text.trim(),
            visibility: visibility,
            thumbnail: _coverImage,
          );

    // Tutup loading
    if (mounted) Navigator.pop(context);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Lembar berhasil dipublikasikan!'), backgroundColor: _kPurpleColor),
        );
        // Kembali ke Home (pop sampai root atau halaman utama)
        Navigator.of(context).pop(); 
        Navigator.of(context).pop(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mempublikasikan'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _onDraftPressed() async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final postService = PostService();
    // Kirim documentJson sebagai string agar format Quill terjaga
    final contentToSend = jsonEncode(widget.documentJson); 
    
    // Check if editing draft or creating new
    final result = widget.isEditingDraft && widget.draftId != null
        ? await postService.updatePost(
            widget.draftId!,
            _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : widget.title ?? 'Untitled',
            contentToSend,
            'draft',
            snippet: _snippetController.text.trim(),
            visibility: 'public',
            thumbnail: _coverImage,
          )
        : await postService.createPost(
            _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : widget.title ?? 'Untitled',
            contentToSend,
            'draft',
            snippet: _snippetController.text.trim(),
            visibility: 'public',
            thumbnail: _coverImage,
          );

    // Tutup loading
    if (mounted) Navigator.pop(context);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disimpan ke Draft')));
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan draft'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

