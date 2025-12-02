import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'review_lembar.dart';

class AddLembarPage extends StatefulWidget {
  const AddLembarPage({super.key});

  @override
  State<AddLembarPage> createState() => _AddLembarPageState();
}

class _AddLembarPageState extends State<AddLembarPage> {
  late final quill.QuillController _controller;
  late final FocusNode _focusNode;
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _focusNode = FocusNode();
    _setupAutoBoldForFirstLine();
  }

  void _setupAutoBoldForFirstLine() {
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (_isFormatting) return; // Prevent recursive formatting

    final selection = _controller.selection;
    if (!selection.isValid) return;

    // Only apply automatic formatting to the first line when the document is first created
    // or when the first line is empty and being typed into
    final document = _controller.document;
    final fullText = document.toPlainText();
    final firstNewlineIndex = fullText.indexOf('\n');
    final isFirstLine = firstNewlineIndex == -1 || selection.start <= firstNewlineIndex;

    if (isFirstLine && fullText.isNotEmpty) {
      final firstLineLength = firstNewlineIndex == -1 ? fullText.length : firstNewlineIndex;
      
      // Only apply formatting if the first line doesn't have any formatting yet
      final firstLineStyle = _controller.getSelectionStyle();
      final hasH2 = firstLineStyle.attributes.containsKey(quill.Attribute.h2.key);
      final hasBold = firstLineStyle.attributes.containsKey(quill.Attribute.bold.key);
      
      if (!hasH2 || !hasBold) {
        _isFormatting = true;
        // Apply formats only if they're not already applied
        if (!hasH2) {
          _controller.formatText(0, firstLineLength, quill.Attribute.h2);
        }
        if (!hasBold) {
          _controller.formatText(0, firstLineLength, quill.Attribute.bold);
        }
        _isFormatting = false;
      }
    }
    // Don't automatically remove formatting from other lines to allow manual formatting
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

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header atas
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

            // 🔹 Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: quill.QuillEditor(
                  controller: _controller,
                  scrollController: ScrollController(),
                  focusNode: _focusNode,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

  void _onSavePressed() {
    final docJson = _controller.document.toDelta().toJson();
    // Extract title and content from document
    final document = _controller.document;
    String title = 'Do it anyway'; // Default title
    String content =
        'Ini adalah isi dari lembar yang telah kamu buat'; // Default content

    // Try to extract title from first line if it's a heading
    if (document.length > 0) {
      final firstLine = document.toPlainText().split('\n').first;
      if (firstLine.isNotEmpty) {
        title = firstLine;
      }
      // Get full content
      final fullContent = document.toPlainText();
      if (fullContent.isNotEmpty) {
        final lines = fullContent.split('\n');
        if (lines.length > 1) {
          content = lines.skip(1).join('\n').trim();
          if (content.isEmpty) {
            content = 'Ini adalah isi dari lembar yang telah kamu buat';
          }
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewLembarPage(
          title: title,
          content: content,
          documentJson: docJson,
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

  Future<void> _pickAndInsertImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final savedPath = await _saveImage(File(picked.path));
    final selection = _controller.selection;
    final embed = quill.BlockEmbed.image(savedPath);
    _controller.replaceText(selection.baseOffset, 0, embed, selection);
  }

  Future<String> _saveImage(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename = 'lembar_${DateTime.now().millisecondsSinceEpoch}.png';
    final path = '${directory.path}/$filename';
    final copied = await file.copy(path);
    return copied.path;
  }
}

class _GradientPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GradientPillButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        minimumSize: const Size(88, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8D07C6), // Purple color matching your theme
        ),
      ),
    );
  }
}

class _ToggleAttributeButton extends StatelessWidget {
  final quill.QuillController controller;
  final IconData icon;
  final quill.Attribute attribute;

  const _ToggleAttributeButton({
    required this.controller,
    required this.icon,
    required this.attribute,
  });

  bool get _isToggled =>
      controller.getSelectionStyle().attributes.containsKey(attribute.key);

  void _toggleAttribute() {
    if (_isToggled) {
      controller.formatSelection(quill.Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isToggled = _isToggled;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _toggleAttribute,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                icon,
                size: 20,
                color: isToggled ? const Color(0xFF8D07C6) : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  final quill.QuillController controller;
  final Future<void> Function() onPickImage;
  final Future<void> Function() onInsertQuote;
  final Future<void> Function() onInsertBullets;
  final Future<void> Function() onInsertNumbers;
  final VoidCallback onToggleBold;
  final VoidCallback onToggleItalic;
  final VoidCallback onToggleUnderline;

  const _EditorToolbar({
    required this.controller,
    required this.onPickImage,
    required this.onInsertQuote,
    required this.onInsertBullets,
    required this.onInsertNumbers,
    required this.onToggleBold,
    required this.onToggleItalic,
    required this.onToggleUnderline,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToggleAttributeButton(
            controller: controller,
            icon: Icons.format_bold,
            attribute: quill.Attribute.bold,
          ),
          _ToggleAttributeButton(
            controller: controller,
            icon: Icons.format_italic,
            attribute: quill.Attribute.italic,
          ),
          _ToggleAttributeButton(
            controller: controller,
            icon: Icons.format_underline,
            attribute: quill.Attribute.underline,
          ),
          const SizedBox(width: 8),
          _ToolbarButton(icon: Icons.format_quote, onPressed: onInsertQuote),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            onPressed: onInsertBullets,
          ),
          _ToolbarButton(
            icon: Icons.format_list_numbered,
            onPressed: onInsertNumbers,
          ),
          _ToolbarButton(icon: Icons.image_outlined, onPressed: onPickImage),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Future<void> Function()? onPressed;

  const _ToolbarButton({this.icon, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (onPressed != null) {
            await onPressed!();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: icon != null
              ? Icon(icon, size: 20, color: Colors.black87)
              : Text(
                  label ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
