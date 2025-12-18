import 'dart:io'; // Tambahkan import dart:io untuk File
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/post_service.dart';
import 'review_lembar.dart';

class EditLembarPage extends StatefulWidget {
  final int postId;

  const EditLembarPage({super.key, required this.postId});

  @override
  State<EditLembarPage> createState() => _EditLembarPageState();
}

class _EditLembarPageState extends State<EditLembarPage> {
  late final quill.QuillController _controller;
  late final FocusNode _focusNode;
  final _postService = PostService();

  bool _isLoading = true;
  Map<String, dynamic>? _postData;

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _focusNode = FocusNode();
    _loadDraftContent();
  }

  Future<void> _loadDraftContent() async {
    try {
      final result = await _postService.getPost(widget.postId);

      if (result['success'] && mounted) {
        final post = result['data'];
        setState(() {
          _postData = post;
          _isLoading = false;
        });

        // Load content into Quill editor
        final contentString = post['content'];
        if (contentString != null && contentString.isNotEmpty) {
          try {
            final contentJson = jsonDecode(contentString);
            final doc = quill.Document.fromJson(contentJson);
            _controller.document = doc;
          } catch (e) {
            // If content is plain text, insert it
            _controller.document.insert(0, contentString);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memuat draft'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF8D07C6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Kembali',
                      style: theme.labelLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Edit Lembar',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _onSavePressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Simpan',
                      style: theme.labelLarge?.copyWith(
                        color: const Color(0xFF8D07C6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),

            // Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: quill.QuillEditor(
                  controller: _controller,
                  scrollController: ScrollController(),
                  focusNode: _focusNode,
                  config: quill.QuillEditorConfig(
                    placeholder: 'Mulai menulis draft Anda...',
                    autoFocus: false,
                    padding: EdgeInsets.zero,
                    // --- PERBAIKAN UTAMA DI SINI ---
                    // Menambahkan embedBuilders agar editor tahu cara render gambar
                    embedBuilders: [ImageEmbedBuilder()],
                    // -------------------------------
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _EditorToolbar(
            controller: _controller,
            onPickImage: _pickAndInsertImage,
            onToggleBold: () async => _toggleAttribute(quill.Attribute.bold),
            onToggleItalic: () async =>
                _toggleAttribute(quill.Attribute.italic),
            onToggleUnderline: () async =>
                _toggleAttribute(quill.Attribute.underline),
            onInsertQuote: () async =>
                _toggleAttribute(quill.Attribute.blockQuote),
            onInsertBullets: () async => _toggleAttribute(quill.Attribute.ul),
            onInsertNumbers: () async => _toggleAttribute(quill.Attribute.ol),
          ),
        ),
      ),
    );
  }

  // --- FUNGSI TAMBAHAN UNTUK TOOLBAR ---
  Future<void> _pickAndInsertImage() async {
    _focusNode.unfocus();

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null || !mounted) return;

    final savedPath = await _saveImage(File(picked.path));

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    int index = _controller.selection.baseOffset;
    int length = _controller.selection.extentOffset - index;

    if (index < 0) {
      index = 0; 
      length = 0;
    }

    final embed = quill.BlockEmbed.image(savedPath);
    
    // 1. Masukkan Gambar
    _controller.replaceText(index, length, embed, null);

    // 2. Masukkan Enter (\n) setelah gambar
    _controller.document.insert(index + 1, '\n');

    // 3. Pindah kursor
    final newCursorOffset = index + 2;
    setState(() {
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorOffset),
        quill.ChangeSource.local,
      );
    });

    await Future.delayed(const Duration(milliseconds: 50));

    // 4. LOGIKA FORMATTING KHUSUS GAMBAR:
    if (index == 0) {
      _controller.formatSelection(quill.Attribute.h2);
      _controller.formatSelection(quill.Attribute.bold);
    } else {
      _controller.formatSelection(quill.Attribute.clone(quill.Attribute.header, null));
      _controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
    }
    
    FocusScope.of(context).requestFocus(_focusNode);
  }

  Future<String> _saveImage(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = 'lembar_${DateTime.now().millisecondsSinceEpoch}.png';
    final path = '${directory.path}/$filename';
    final copied = await file.copy(path);
    return copied.path;
  }

  void _toggleAttribute(quill.Attribute attribute) {
    final selection = _controller.selection;
    if (!selection.isValid) return;

    final current = _controller.getSelectionStyle().attributes[attribute.key];

    if (current == attribute) {
      _controller.formatSelection(quill.Attribute.clone(attribute, null));
    } else {
      _controller.formatSelection(attribute);
    }
  }

  void _onSavePressed() {
    final docJson = _controller.document.toDelta().toJson();
    final document = _controller.document;

    String title = _postData?['title'] ?? 'Tanpa Judul';
    String content = 'Tidak ada konten tambahan.';

    if (document.length > 0) {
      final plainText = document.toPlainText();
      final lines = plainText.split('\n');

      String? foundTitle;
      int titleIndex = -1;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isNotEmpty && line.codeUnitAt(0) != 65532) {
          foundTitle = line;
          titleIndex = i;
          break;
        }
      }

      if (foundTitle != null) {
        title = foundTitle;
      }

      if (titleIndex != -1 && titleIndex + 1 < lines.length) {
        final rawContent = lines.skip(titleIndex + 1).join('\n').trim();
        if (rawContent.isNotEmpty) {
          content = rawContent;
        }
      } else if (titleIndex == -1 && plainText.trim().isNotEmpty) {
        content = "Konten Gambar";
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReviewLembarPage(
          title: title,
          content: content,
          documentJson: docJson,
          isEditingDraft: true,
          draftId: widget.postId,
          initialThumbnailUrl: _postData?['thumbnail_url'],
        ),
      ),
    );
  }
}

// --- WIDGET TOOLBAR CUSTOM ---
class _EditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final VoidCallback onPickImage;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;
  final VoidCallback onInsertQuote;
  final VoidCallback onInsertBullets;
  final VoidCallback onInsertNumbers;

  const _EditorToolbar({
    required this.controller,
    required this.onPickImage,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
    required this.onInsertQuote,
    required this.onInsertBullets,
    required this.onInsertNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarButton(icon: Icons.format_bold, onPressed: onToggleBold),
        _ToolbarButton(icon: Icons.format_italic, onPressed: onToggleItalic),
        _ToolbarButton(icon: Icons.format_underline, onPressed: onToggleUnderline),
        _ToolbarButton(icon: Icons.format_quote, onPressed: onInsertQuote),
        _ToolbarButton(icon: Icons.format_list_bulleted, onPressed: onInsertBullets),
        _ToolbarButton(icon: Icons.format_list_numbered, onPressed: onInsertNumbers),
        _ToolbarButton(icon: Icons.image_outlined, onPressed: onPickImage),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ToolbarButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      color: const Color(0xFF8D07C6),
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}

// --- KELAS PEMBANTU UNTUK MERENDER GAMBAR (WAJIB ADA) ---
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
              width: double.infinity,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Gambar tidak ditemukan",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return const SizedBox();
  }
}
