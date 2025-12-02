import 'package:flutter/material.dart';
import '../lembar/select_lembar_page.dart';
import '../../data/services/lembar_storage.dart';

class EditJilidPage extends StatefulWidget {
  final Map<String, dynamic> jilid;

  const EditJilidPage({
    super.key,
    required this.jilid,
  });

  @override
  State<EditJilidPage> createState() => _EditJilidPageState();
}

class _EditJilidPageState extends State<EditJilidPage> {
  late List<Map<String, dynamic>> _lembarList;
  late Map<String, dynamic> _updatedJilid;

  @override
  void initState() {
    super.initState();
    // Initialize lembar list from jilid data
    _lembarList = List<Map<String, dynamic>>.from(
      widget.jilid['lembar'] ?? [],
    );
    // Create a copy of jilid for updates
    _updatedJilid = Map<String, dynamic>.from(widget.jilid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _showExitConfirmation,
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Jilid',
                              style: theme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_lembarList.length} artikel',
                              style: theme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _saveAndReturn,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8D07C6),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Description
              if (widget.jilid['description'] != null &&
                  (widget.jilid['description'] as String).isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.jilid['description'] as String,
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

              const Divider(height: 1, color: Color(0xFFE6E6E6)),

              // List Lembar
              Expanded(
                child: _lembarList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada lembar dalam jilid ini',
                              style: theme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan lembar untuk memulai',
                              style: theme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        buildDefaultDragHandles: false,
                        itemCount: _lembarList.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final lembar = _lembarList[index];
                          return _buildLembarCard(lembar, theme, index);
                        },
                      ),
              ),

              // Tombol Tambah Lembar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _addLembar,
                    icon: const Icon(Icons.add, color: Color(0xFF8D07C6)),
                    label: const Text(
                      'Tambah Lembar',
                      style: TextStyle(
                        color: Color(0xFF8D07C6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8D07C6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLembarCard(
    Map<String, dynamic> lembar,
    TextTheme theme,
    int index,
  ) {
    // Use id as key - should always be present
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
        child: Container(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to lembar detail or blog page
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          lembar['title'] ?? 'Untitled',
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Snippet
                        Text(
                          lembar['snippet'] ?? '',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lembar['date'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            lembar['date'] as String,
                            style: theme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Drag handle and Remove Button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drag_handle, color: Colors.grey[400], size: 20),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: Colors.grey[600],
                        onPressed: () => _showDeleteConfirmation(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      final item = _lembarList.removeAt(oldIndex);
      _lembarList.insert(newIndex, item);
      // Update the jilid data
      _updatedJilid['lembar'] = _lembarList;
    });
  }

  void _showDeleteConfirmation(int index) {
    final lembar = _lembarList[index];
    final lembarTitle = lembar['title'] ?? 'lembar ini';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Lembar'),
          content: Text('Apakah anda yakin untuk menghapus lembar "$lembarTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _lembarList.removeAt(index);
                  _updatedJilid['lembar'] = _lembarList;
                  _updatedJilid['count'] = _lembarList.length;
                });
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batal Edit'),
          content: const Text('Perubahan yang belum disimpan akan hilang. Apakah anda yakin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Lanjutkan Edit',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addLembar() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectLembarPage(
          selectedLembar: _lembarList,
        ),
      ),
    );

    if (result != null && result is List) {
      setState(() {
        _lembarList = List<Map<String, dynamic>>.from(result);
        _updatedJilid['lembar'] = _lembarList;
        _updatedJilid['count'] = _lembarList.length;
      });
    }
  }

  Future<void> _saveAndReturn() async {
    _updatedJilid['lembar'] = _lembarList;
    _updatedJilid['count'] = _lembarList.length;

    // Update jilid in storage
    final jilidId = _updatedJilid['id']?.toString();
    if (jilidId != null && jilidId.isNotEmpty) {
      await LembarStorage.updateJilid(jilidId, _updatedJilid);
    }

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate save was successful
    }
  }
}

