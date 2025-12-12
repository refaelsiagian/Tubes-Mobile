import 'package:flutter/material.dart';
import '../lembar/select_lembar_page.dart';
import '../main/blog_page.dart';
import '../../data/services/series_service.dart';

// Konstanta Warna
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kGradientStart = Color(0xFF8D07C6);
const Color _kGradientEnd = Color(0xFFDD01BE);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);

class EditJilidPage extends StatefulWidget {
  final Map<String, dynamic> jilid;

  const EditJilidPage({super.key, required this.jilid});

  @override
  State<EditJilidPage> createState() => _EditJilidPageState();
}

class _EditJilidPageState extends State<EditJilidPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<Map<String, dynamic>> _lembarList;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.jilid['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.jilid['description'] ?? '',
    );
    // Deep copy list lembar agar perubahan tidak langsung ref ke object asal
    // sebelum disave
    _lembarList = List<Map<String, dynamic>>.from(
      (widget.jilid['posts'] as List? ?? []).map(
        (x) => Map<String, dynamic>.from(x),
      ),
    );

    _titleController.addListener(_markChanged);
    _descriptionController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: _kTextColor),
            onPressed: _handleBackPress,
          ),
          centerTitle: true,
          title: Text(
            'Edit Jilid',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _kTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saveAndReturn,
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: _kPurpleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INPUT JUDUL
                    TextField(
                      controller: _titleController,
                      style: theme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _kTextColor,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Judul Jilid...',
                        hintStyle: theme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 12),

                    // INPUT DESKRIPSI
                    TextField(
                      controller: _descriptionController,
                      style: theme.bodyLarge?.copyWith(
                        color: _kSubTextColor,
                        height: 1.5,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan deskripsi singkat...',
                        hintStyle: theme.bodyLarge?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12, bottom: 4),
                          child: Icon(
                            Icons.short_text_rounded,
                            color: Colors.grey,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 24),

                    // HEADER LIST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _kPurpleColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.layers_outlined,
                                size: 16,
                                color: _kPurpleColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Isi Jilid (${_lembarList.length})',
                              style: theme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _kTextColor,
                              ),
                            ),
                          ],
                        ),

                        InkWell(
                          onTap: _addLembar,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _kPurpleColor.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: _kPurpleColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tambah',
                                  style: theme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _kPurpleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // LIST ITEMS
                    if (_lembarList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.library_add_outlined,
                              size: 40,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jilid ini kosong',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: _lembarList.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          return _buildModernLembarItem(
                            _lembarList[index],
                            index,
                            theme,
                          );
                        },
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [_kGradientStart, _kGradientStart],
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
              onPressed: _saveAndReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLembarItem(
    Map<String, dynamic> lembar,
    int index,
    TextTheme theme,
  ) {
    // Gunakan Key yang unik
    final uniqueKey = ValueKey(lembar['id'] ?? 'item_edit_$index');

    return Container(
      key: uniqueKey,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogPage(
                postId: int.tryParse(lembar['id'].toString()) ?? 0,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drag Handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: Colors.transparent,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Nomor Urut (TETAP DIPERTAHANKAN untuk urutan Jilid)
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lembar['title'] ?? 'Untitled',
                      style: theme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _kTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lembar['snippet'] ?? 'Tidak ada ringkasan',
                      style: theme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tombol Hapus dengan Konfirmasi
              IconButton(
                icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _removeLembarWithConfirmation(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === LOGIC FUNCTIONS ===

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _lembarList.removeAt(oldIndex);
      _lembarList.insert(newIndex, item);
      _hasChanges = true; // Tandai perubahan
    });
  }

  // Logic Konfirmasi Hapus Item
  Future<void> _removeLembarWithConfirmation(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: const Text(
          'Artikel ini akan dihapus dari Jilid, tetapi tidak terhapus dari koleksi Cerita Anda.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _lembarList.removeAt(index);
        _hasChanges = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Artikel dihapus dari jilid"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleBackPress() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Batal Edit?'),
          content: const Text('Perubahan yang belum disimpan akan hilang.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Lanjut Edit',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Close Page
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _addLembar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectLembarPage(selectedLembar: _lembarList),
      ),
    );

    if (result != null && result is List) {
      setState(() {
        _lembarList = result
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveAndReturn() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul jilid tidak boleh kosong')),
      );
      return;
    }

    // Extract Post IDs
    final List<int> postIds = _lembarList
        .map((item) => int.tryParse(item['id'].toString()) ?? 0)
        .where((id) => id != 0)
        .toList();

    // Update via API
    final seriesService = SeriesService();
    final result = await seriesService.updateSeries(
      int.tryParse(widget.jilid['id'].toString()) ?? 0,
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      postIds,
    );

    if (result['success']) {
      if (mounted) {
        // Return true menandakan ada perubahan
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memperbarui jilid')),
        );
      }
    }
  }
}