import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import '../../data/services/lembar_storage.dart';

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

  const ReviewLembarPage({
    super.key,
    this.title,
    this.content,
    this.documentJson,
  });

  @override
  State<ReviewLembarPage> createState() => _ReviewLembarPageState();
}

class _ReviewLembarPageState extends State<ReviewLembarPage> {
  String _selectedVisibility = 'Publik';
  late TextEditingController _titleController;
  late TextEditingController _snippetController;
  File? _coverImage;

  // Controller untuk Preview Konten
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _snippetController = TextEditingController(
      text: _generateSnippet(widget.content),
    );
    _loadContentPreview();
  }

  void _loadContentPreview() {
    try {
      if (widget.documentJson != null) {
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(widget.documentJson),
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

  String _generateSnippet(String? content) {
    if (content == null || content.isEmpty) return '';
    List<String> words = content.trim().split(RegExp(r'\s+'));
    if (words.length > 20) {
      return '${words.take(20).join(' ')}...';
    }
    return content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _snippetController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _kTextColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          'Tinjau Tulisan',
          style: theme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _kTextColor,
          ),
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
                  // INFO PENULIS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: const AssetImage('assets/images/ava_default.jpg'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pengguna',
                        style: theme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  Akan datang',
                        style: theme.labelSmall?.copyWith(
                          color: _kSubTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // INPUT JUDUL
                  TextField(
                    controller: _titleController,
                    style: theme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _kTextColor,
                      fontSize: 28,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul Tulisan...',
                      hintStyle: theme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade300,
                        fontSize: 28,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 12),

                  // INPUT SNIPPET (RINGKASAN)
                  TextField(
                    controller: _snippetController,
                    style: theme.bodyLarge?.copyWith(
                      color: _kSubTextColor,
                      fontSize: 16,
                      height: 1.6,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText:
                          'Tulis ringkasan singkat agar menarik pembaca...',
                      hintStyle: theme.bodyLarge?.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  const SizedBox(height: 24),

                  // --- PREVIEW KONTEN LENGKAP ---
                  Text(
                    'Pratinjau Isi:',
                    style: theme.labelLarge?.copyWith(color: _kSubTextColor),
                  ),
                  const SizedBox(height: 8),

                  // Quill Editor (Read Only)
                  quill.QuillEditor(
                    controller: _quillController,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    config: quill.QuillEditorConfig(
                      autoFocus: false,
                      expands: false,
                      padding: EdgeInsets.zero,
                      enableInteractiveSelection: false, 
                      embedBuilders: [ImageEmbedBuilder()],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  const SizedBox(height: 24),

                  // PENGATURAN VISIBILITAS
                  Text(
                    'Pengaturan Publikasi',
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _kTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      onTap: _showVisibilityBottomSheet,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(
                          _selectedVisibility == 'Publik'
                              ? Icons.public_rounded
                              : Icons.lock_outline_rounded,
                          color: _kPurpleColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Visibilitas',
                        style: theme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _selectedVisibility,
                        style: theme.bodySmall?.copyWith(color: _kSubTextColor),
                      ),
                      trailing: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: _pickCoverImage,
                    child: Container(
                      width: double.infinity,
                      height: _coverImage != null ? 200 : null,
                      padding: _coverImage != null
                          ? EdgeInsets.zero
                          : const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        image: _coverImage != null
                            ? DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverImage == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tambahkan Sampul (Opsional)',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _coverImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _onDraftPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    foregroundColor: _kTextColor,
                  ),
                  child: const Text(
                    'Draft',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [_kGradientStart, _kGradientEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
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
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Publikasikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      ],
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

  void _showVisibilityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.public, color: Colors.blue),
                ),
                title: const Text(
                  'Publik',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Semua orang bisa melihat tulisan ini'),
                onTap: () {
                  setState(() => _selectedVisibility = 'Publik');
                  Navigator.pop(ctx);
                },
                trailing: _selectedVisibility == 'Publik'
                    ? const Icon(Icons.check, color: _kPurpleColor)
                    : null,
              ),
              const Divider(height: 1, indent: 60),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.grey),
                ),
                title: const Text(
                  'Private',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Hanya kamu yang bisa melihat'),
                onTap: () {
                  setState(() => _selectedVisibility = 'Private');
                  Navigator.pop(ctx);
                },
                trailing: _selectedVisibility == 'Private'
                    ? const Icon(Icons.check, color: _kPurpleColor)
                    : null,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }

    final String commonId = DateTime.now().millisecondsSinceEpoch.toString();
    final String timestamp = DateTime.now().toIso8601String();

    final lembarData = {
      'id': commonId,
      'title': _titleController.text.trim(),
      'snippet': _snippetController.text.trim(),
      'content': widget.content ?? '',
      'documentJson': widget.documentJson,
      'visibility': _selectedVisibility,
      'thumbnail': _coverImage?.path,
      'date': DateTime.now().toString(),
      'publishedAt': timestamp,
      'authorName': 'Pengguna',
      'authorInitials': '',
      'likes': '0',
      'comments': '0',
    };

    await LembarStorage.savePublishedLembar(lembarData);
    await LembarStorage.saveStory(lembarData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lembar berhasil dipublikasikan!'),
          backgroundColor: _kPurpleColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  Future<void> _onDraftPressed() async {
    final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

    final draftData = {
      'id': commonId,
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.title ?? 'Untitled',
      'snippet': _snippetController.text.trim(),
      'content': widget.content ?? '',
      'documentJson': widget.documentJson,
      'thumbnail': _coverImage?.path,
      'visibility': 'Draft',
      'date': DateTime.now().toString(),
      'publishedAt': DateTime.now().toIso8601String(),
      'authorName': 'Pengguna',
      'authorInitials': '',
    };

    await LembarStorage.saveStory(draftData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disimpan ke Draft'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }
}

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
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox();
  }
}