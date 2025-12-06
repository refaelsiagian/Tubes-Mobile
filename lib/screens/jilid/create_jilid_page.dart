import 'package:flutter/material.dart';
import '../lembar/select_lembar_page.dart';
import '../../data/services/lembar_storage.dart';

// Konstanta Warna (Konsisten dengan Profile Page)
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kGradientStart = Color(0xFF8D07C6);
const Color _kGradientEnd = Color(0xFFDD01BE);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);

class CreateJilidPage extends StatefulWidget {
  const CreateJilidPage({super.key});

  @override
  State<CreateJilidPage> createState() => _CreateJilidPageState();
}

class _CreateJilidPageState extends State<CreateJilidPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _selectedLembar = [];

  final FocusNode _titleFocus = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    super.dispose();
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
          'Jilid Baru',
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
                  // 1. INPUT JUDUL
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
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

                  // 2. INPUT DESKRIPSI
                  TextField(
                    controller: _descriptionController,
                    style: theme.bodyLarge?.copyWith(
                      color: _kSubTextColor,
                      height: 1.5,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText:
                          'Tambahkan deskripsi singkat tentang koleksi ini...',
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

                  // 3. HEADER LIST LEMBAR
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
                            'Isi Jilid (${_selectedLembar.length})',
                            style: theme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _kTextColor,
                            ),
                          ),
                        ],
                      ),

                      // Tombol Tambah
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

                  // 4. LIST ITEM
                  if (_selectedLembar.isEmpty)
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
                            'Belum ada lembar',
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
                      itemCount: _selectedLembar.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        return _buildModernLembarItem(
                          _selectedLembar[index],
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

          // 5. TOMBOL SIMPAN
          _buildBottomButton(),
        ],
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
              color: const Color(0xFF8D07C6),
              boxShadow: [
                BoxShadow(
                  color: _kPurpleColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveJilid,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Simpan Jilid',
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
    // Kunci unik penting untuk ReorderableListView agar posisi track benar
    final uniqueKey = ValueKey(lembar['id'] ?? 'item_$index');

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
      child: ReorderableDragStartListener(
        index: index,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 32,
            height: 32,
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
          title: Text(
            lembar['title'] ?? 'Untitled',
            style: theme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _kTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              lembar['snippet'] ?? 'Tidak ada ringkasan',
              style: theme.bodySmall?.copyWith(color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Hapus Item
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedLembar.removeAt(index);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.drag_indicator_rounded, color: Colors.grey.shade300),
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
      final item = _selectedLembar.removeAt(oldIndex);
      _selectedLembar.insert(newIndex, item);
    });
  }

  Future<void> _addLembar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        // Kita kirim _selectedLembar agar SelectLembarPage tahu apa yang sudah dipilih
        builder: (context) => SelectLembarPage(selectedLembar: _selectedLembar),
      ),
    );

    if (result != null && result is List) {
      setState(() {
        // PERBAIKAN 1: Menghindari pengacakan urutan.
        // Kita gunakan hasil langsung dari SelectLembarPage yang diasumsikan
        // sudah terurut sesuai pilihan user.
        _selectedLembar = result
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    }
  }

  Future<void> _saveJilid() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul jilid tidak boleh kosong'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final jilidData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'count': _selectedLembar.length,
      'thumbnail': null,
      // PERBAIKAN 2: Pastikan yang disimpan adalah _selectedLembar
      // yang sudah mencakup perubahan drag & drop
      'lembar': List<Map<String, dynamic>>.from(_selectedLembar),
    };

    await LembarStorage.saveJilid(jilidData);

    final savedJilid = {
      ...jilidData,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jilid berhasil dibuat'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.of(context).pop(savedJilid);
    }
  }
}
