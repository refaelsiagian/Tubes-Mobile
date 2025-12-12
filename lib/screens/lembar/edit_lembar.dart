import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../data/services/post_service.dart';
import 'review_lembar.dart';

class EditLembarPage extends StatefulWidget {
  final int postId;
  
  const EditLembarPage({
    super.key,
    required this.postId,
  });

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
            const SnackBar(content: Text('Gagal memuat draft'), backgroundColor: Colors.red),
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
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF8D07C6))),
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
                    'Edit Draft',
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolbarButton(Icons.format_bold, () => _toggleAttribute(quill.Attribute.bold)),
              _buildToolbarButton(Icons.format_italic, () => _toggleAttribute(quill.Attribute.italic)),
              _buildToolbarButton(Icons.format_underline, () => _toggleAttribute(quill.Attribute.underline)),
              _buildToolbarButton(Icons.format_quote, () => _toggleAttribute(quill.Attribute.blockQuote)),
              _buildToolbarButton(Icons.format_list_bulleted, () => _toggleAttribute(quill.Attribute.ul)),
              _buildToolbarButton(Icons.format_list_numbered, () => _toggleAttribute(quill.Attribute.ol)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 22),
      color: const Color(0xFF8D07C6),
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
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
        ),
      ),
    );
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
}
