import 'package:flutter/material.dart';
import '../../data/services/lembar_storage.dart';

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
  String? _selectedVisibility;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? 'Do it anyway');
    _descriptionController = TextEditingController(
      text: widget.content ?? 'Ini adalah isi dari lembar yang telah kamu buat',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan icon X
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ),

            // Judul dan Deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lembar Preview',
                      style: theme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tinjau isi lembar ini sebelum kamu\nmempublikasikannya.',
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Kartu Preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Preview
                    InkWell(
                      onTap: () {
                        // Add navigation or action when the card is tapped
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile dan Nama
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pengguna',
                                style: theme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Judul - Editable
                          _isEditing
                              ? TextField(
                                  controller: _titleController,
                                  style: theme.headlineMedium?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF8D07C6),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                )
                              : Text(
                                  _titleController.text,
                                  style: theme.headlineMedium?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const SizedBox(height: 12),
                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          // Deskripsi - Editable
                          _isEditing
                              ? TextField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  style: theme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan deskripsi...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF8D07C6),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                )
                              : Text(
                                  _getShortDescription(_descriptionController.text),
                                  style: theme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(height: 8),
                          // Edit text di kanan bawah
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_isEditing) {
                                    // Save changes
                                    _isEditing = false;
                                  } else {
                                    // Enter edit mode
                                    _isEditing = true;
                                  }
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isEditing ? 'Simpan' : 'Edit',
                                style: TextStyle(
                                  color: const Color(0xFF8D07C6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),

                    const SizedBox(height: 24),

                    // Visibilitas Section
                    InkWell(
                      onTap: _showVisibilityBottomSheet,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Visibilitas',
                              style: theme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                if (_selectedVisibility != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      _selectedVisibility!,
                                      style: theme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Draft dan Publikasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
              ),
              child: Row(
                children: [
                  // Tombol Draft
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _onDraftPressed,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text(
                          'Draft',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Publikasi
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8D07C6), Color(0xFFDD01BE)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _onPublishPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Publikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
              ListTile(
                title: const Text('Publik'),
                onTap: () {
                  setState(() {
                    _selectedVisibility = 'Publik';
                  });
                  Navigator.pop(ctx);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Private'),
                onTap: () {
                  setState(() {
                    _selectedVisibility = 'Private';
                  });
                  Navigator.pop(ctx);
                },
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onPublishPressed() async {
    // Prepare lembar data with edited title and description
    final lembarData = {
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.title ?? 'Untitled',
      'snippet': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : widget.content ?? '',
      'content': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : widget.content ?? '',
      'documentJson': widget.documentJson,
      'visibility': _selectedVisibility ?? 'Publik',
      'thumbnail': null,
    };


    // Save to home feed
    await LembarStorage.savePublishedLembar(lembarData);

    // Save to user stories
    await LembarStorage.saveStory({
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.title ?? 'Untitled',
      'snippet': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : widget.content ?? '',
      'thumbnail': null,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembar berhasil dipublikasikan!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Pop twice: once from review page, once from add_lembar page
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  Future<void> _onDraftPressed() async {
    // Save as draft (save to stories but not to published feed)
    await LembarStorage.saveStory({
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : widget.title ?? 'Untitled',
      'snippet': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : widget.content ?? '',
      'thumbnail': null,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembar disimpan sebagai draft!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Pop twice: once from review page, once from add_lembar page
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  String _getShortDescription(String text) {
    // Batasi hanya 15 kata pertama
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 15) {
      return text;
    }
    return words.take(15).join(' ') + '...';
  }
}
