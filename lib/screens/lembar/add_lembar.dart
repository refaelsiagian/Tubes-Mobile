import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/permission_helper.dart';
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

  // === LOGIKA AUTO BOLD JUDUL & RESET SNIPPET ===
  void _handleTextChange() {
    if (_isFormatting) return;

    final selection = _controller.selection;
    if (!selection.isValid) return;

    final document = _controller.document;
    final fullText = document.toPlainText();
    
    // Cek apakah ada gambar di karakter pertama
    final bool startsWithImage = fullText.isNotEmpty && fullText.codeUnitAt(0) == 65532;

    // Tentukan baris mana yang dianggap "Judul"
    final lines = fullText.split('\n');
    int titleLineIndex = startsWithImage ? 1 : 0; 

    // Cari posisi kursor ada di baris ke berapa
    int currentLineIndex = 0;
    int charCount = 0;
    for (int i = 0; i < lines.length; i++) {
      if (selection.start <= charCount + lines[i].length) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1; 
    }

    _isFormatting = true;

    // 1. Jika kursor di Baris Judul -> Paksa H2 & Bold
    if (currentLineIndex == titleLineIndex) {
      final lineText = lines[titleLineIndex].trim();
      if (lineText.isNotEmpty) {
        final currentStyle = _controller.getSelectionStyle();
        final hasH2 = currentStyle.attributes.containsKey(quill.Attribute.h2.key);
        final hasBold = currentStyle.attributes.containsKey(quill.Attribute.bold.key);

        if (!hasH2 || !hasBold) {
          final lineStart = charCount;
          final lineLength = lines[titleLineIndex].length;
          if (lineLength > 0) {
             _controller.formatText(lineStart, lineLength, quill.Attribute.h2);
             _controller.formatText(lineStart, lineLength, quill.Attribute.bold);
          }
        }
      }
    } 
    // 2. Jika kursor di Baris SETELAH Judul (Snippet/Isi) -> Paksa Hapus Bold & H2
    else if (currentLineIndex > titleLineIndex) {
      final currentStyle = _controller.getSelectionStyle();
      
      if (currentStyle.attributes.containsKey(quill.Attribute.header.key) ||
          currentStyle.attributes.containsKey(quill.Attribute.bold.key)) {
        
        _controller.formatSelection(quill.Attribute.clone(quill.Attribute.header, null));
        _controller.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
      }
    }

    _isFormatting = false;
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

    // Style dasar
    final baseTextStyle = theme.bodyMedium ?? const TextStyle(fontSize: 16);
    final titleTextStyle = theme.headlineSmall ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

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

            // 🔹 Editor dengan Styling Jarak
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
                  config: quill.QuillEditorConfig(
                    placeholder: 'Mulai menulis...',
                    autoFocus: true,
                    padding: EdgeInsets.zero,
                    embedBuilders: [
                      ImageEmbedBuilder(),
                    ],
                    // === PERBAIKAN STYLING: JARAK LEBIH RAPAT ===
                    customStyles: quill.DefaultStyles(
                      // Style Judul (H2)
                      h2: quill.DefaultTextBlockStyle(
                        titleTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2, 
                        ),
                        const quill.HorizontalSpacing(0, 0), 
                        const quill.VerticalSpacing(8, 4), // Jarak Atas 8, Bawah 4 (Lebih Rapat)
                        const quill.VerticalSpacing(0, 0),
                        null, 
                      ),
                      // Style Isi (Paragraph)
                      paragraph: quill.DefaultTextBlockStyle(
                        baseTextStyle.copyWith(
                          height: 1.5,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(4, 4), // Jarak antar paragraf 4 (Lebih Rapat)
                        const quill.VerticalSpacing(0, 0),   
                        null,                                
                      ),
                    ),
                    // ============================================
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Padding horizontal ditambah
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
    final document = _controller.document;
    
    String title = 'Tanpa Judul';
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
    _focusNode.unfocus();

    final hasPermission = await PermissionHelper.checkGalleryPermission(context);
    if (!hasPermission) return;

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
                  child: Icon(Icons.broken_image, color: Colors.grey)),
            );
          },
        ),
      );
    }
    return const SizedBox();
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

// === UPDATED EDITOR TOOLBAR ===
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
    // Kita gunakan Row untuk layouting
    return Row(
      children: [
        // Bagian Kiri: Toolbar Text (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
              ],
            ),
          ),
        ),
        
        // Pemisah Tipis (Opsional, agar terlihat ada batas)
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        // Bagian Kanan: Tombol Gambar (Fixed di pojok kanan)
        _ToolbarButton(icon: Icons.image_outlined, onPressed: onPickImage),
      ],
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