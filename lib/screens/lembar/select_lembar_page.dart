import 'package:flutter/material.dart';
import '../../data/services/lembar_storage.dart';

class SelectLembarPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedLembar;

  const SelectLembarPage({
    super.key,
    required this.selectedLembar,
  });

  @override
  State<SelectLembarPage> createState() => _SelectLembarPageState();
}

class _SelectLembarPageState extends State<SelectLembarPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allLembar = [];
  List<Map<String, dynamic>> _filteredLembar = [];
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadLembar();
    _searchController.addListener(_filterLembar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLembar() async {
    // Load lembar from storage
    final stories = await LembarStorage.getAllLembar();
    
    // Convert to lembar format
    _allLembar = stories.map((story) => {
      'id': story['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': story['title'] ?? 'Untitled',
      'snippet': story['snippet'] ?? '',
      'date': story['date'] ?? 'Just now',
    }).toList();

    // Initialize selected IDs from widget.selectedLembar
    _selectedIds = widget.selectedLembar
        .map((lembar) => lembar['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    _filteredLembar = List.from(_allLembar);
    setState(() {});
  }

  void _filterLembar() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLembar = List.from(_allLembar);
      } else {
        _filteredLembar = _allLembar
            .where((lembar) =>
                (lembar['title']?.toString().toLowerCase().contains(query) ??
                    false) ||
                (lembar['snippet']
                        ?.toString()
                        .toLowerCase()
                        .contains(query) ??
                    false))
            .toList();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _addSelected() {
    final selected = _allLembar
        .where((lembar) => _selectedIds.contains(lembar['id']?.toString()))
        .toList();

    // Merge with existing selected lembar (avoid duplicates)
    final existingIds = widget.selectedLembar
        .map((l) => l['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final newLembar = selected
        .where((l) => !existingIds.contains(l['id']?.toString()))
        .toList();

    final result = [...widget.selectedLembar, ...newLembar];
    Navigator.of(context).pop(result);
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
                    'Pilih Lembar',
                    style: theme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacing
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE6E6E6)),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari lembar...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
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
            ),

            // List Lembar
            Expanded(
              child: _filteredLembar.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada lembar ditemukan',
                        style: theme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredLembar.length,
                      itemBuilder: (context, index) {
                        final lembar = _filteredLembar[index];
                        final id = lembar['id']?.toString() ?? '';
                        final isSelected = _selectedIds.contains(id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF8D07C6)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _toggleSelection(id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Checkbox
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF8D07C6)
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? const Color(0xFF8D07C6)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lembar['title'] ?? 'Untitled',
                                          style: theme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF8D07C6)
                                                : Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lembar['snippet'] ?? '',
                                          style: theme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lembar['date'] ?? '',
                                          style: theme.bodySmall?.copyWith(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Tombol Tambahkan
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
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8D07C6), Color(0xFFDD01BE)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _selectedIds.isEmpty ? null : _addSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      'Tambahkan (${_selectedIds.length})',
                      style: const TextStyle(
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
}

