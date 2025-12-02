import 'package:flutter/material.dart';
import '../lembar/select_lembar_page.dart';
import '../../data/services/lembar_storage.dart';

class CreateJilidPage extends StatefulWidget {
  const CreateJilidPage({super.key});

  @override
  State<CreateJilidPage> createState() => _CreateJilidPageState();
}

class _CreateJilidPageState extends State<CreateJilidPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _selectedLembar = [];

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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(48, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Batal',
                      style: theme.labelLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Buat Jilid',
                    style: theme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacing
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Jilid
                    Text(
                      'Judul Jilid',
                      style: theme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul jilid',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF8D07C6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Deskripsi Jilid
                    Text(
                      'Deskripsi Jilid',
                      style: theme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Masukkan deskripsi jilid',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF8D07C6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Tambah Lembar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addLembar,
                        icon: const Icon(Icons.add, color: Color(0xFF8D07C6)),
                        label: const Text(
                          'Tambah Lembar',
                          style: TextStyle(color: Color(0xFF8D07C6)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF8D07C6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // List Lembar yang Dipilih
                    if (_selectedLembar.isNotEmpty) ...[
                      Text(
                        'Lembar dalam Jilid (${_selectedLembar.length})',
                        style: theme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: _selectedLembar.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          return _buildLembarItem(
                            _selectedLembar[index],
                            index,
                            theme,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tombol Simpan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25), // Half of button height (50/2) for pill shape
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8D07C6), Color(0xFFDD01BE)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveJilid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // Match outer container for pill shape
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Simpan Jilid',
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
    );
  }

  Widget _buildLembarItem(
    Map<String, dynamic> lembar,
    int index,
    TextTheme theme,
  ) {
    // Use id as key - should always be present after _addLembar ensures it
    final uniqueKey = lembar['id']?.toString() ?? 'lembar_$index';

    return Card(
      key: ValueKey(uniqueKey),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ReorderableDragStartListener(
        index: index,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.article, color: Colors.grey[600], size: 20),
          ),
          title: Text(
            lembar['title'] ?? 'Untitled',
            style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            lembar['snippet'] ?? '',
            style: theme.bodySmall?.copyWith(color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_handle, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: Colors.grey[600],
                onPressed: () {
                  setState(() {
                    _selectedLembar.removeAt(index);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        builder: (context) => SelectLembarPage(selectedLembar: _selectedLembar),
      ),
    );

    if (result != null && result is List) {
      setState(() {
        // Ensure each lembar has a unique id
        final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
        _selectedLembar = result.asMap().entries.map((entry) {
          final index = entry.key;
          final lembar = entry.value;
          final Map<String, dynamic> lembarMap = Map<String, dynamic>.from(
            lembar,
          );
          if (lembarMap['id'] == null || lembarMap['id'].toString().isEmpty) {
            // Use timestamp + index to ensure uniqueness
            lembarMap['id'] = '${baseTimestamp}_$index';
          }
          return lembarMap;
        }).toList();
      });
    }
  }

  Future<void> _saveJilid() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul jilid tidak boleh kosong'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final jilidData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'count': _selectedLembar.length,
      'thumbnail': null,
      'lembar': List<Map<String, dynamic>>.from(_selectedLembar),
    };

    // Save to storage
    await LembarStorage.saveJilid(jilidData);

    // Return the saved jilid data (with id from storage)
    final savedJilid = {
      ...jilidData,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    if (mounted) {
      Navigator.of(context).pop(savedJilid);
    }
  }
}
