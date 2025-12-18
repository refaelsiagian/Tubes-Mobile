import 'package:flutter/material.dart';
import '../../data/services/post_service.dart';
import '../../data/services/auth_service.dart';

// Konstanta Warna (Konsisten)
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kGradientStart = Color(0xFF8D07C6);
const Color _kGradientEnd = Color(0xFFDD01BE);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);

class SelectLembarPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedLembar;

  const SelectLembarPage({super.key, required this.selectedLembar});

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

  // === LOGIC (TIDAK DIUBAH) ===
  Future<void> _loadLembar() async {
    final authService = AuthService();
    final profile = await authService.getProfile();
    int? userId;
    if (profile['success']) {
      userId = profile['data']['id'];
    }

    if (userId == null) {
      // Handle error or return empty
      return;
    }

    final postService = PostService();
    final posts = await postService.getPosts(userId: userId);

    _allLembar = posts
        .where((post) => post['status'] == 'published')
        .map(
          (post) => {
            'id': post['id'].toString(),
            'title': post['title'] ?? 'Untitled',
            'snippet': post['snippet'] ?? '',
            'date': post['published_at'] ?? 'Just now',
          },
        )
        .toList();

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
            .where(
              (lembar) =>
                  (lembar['title']?.toString().toLowerCase().contains(query) ??
                      false) ||
                  (lembar['snippet']?.toString().toLowerCase().contains(
                        query,
                      ) ??
                      false),
            )
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

  // === UI MODERN ===
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      // 1. App Bar Bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _kTextColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Pilih Lembar',
          style: theme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _kTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 2. Search Bar Modern
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tulisanmu...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // 3. List Lembar
          Expanded(
            child: _filteredLembar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada lembar ditemukan',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                    ), // Full width divider
                    itemCount: _filteredLembar.length,
                    itemBuilder: (context, index) {
                      final lembar = _filteredLembar[index];
                      final id = lembar['id']?.toString() ?? '';
                      final isSelected = _selectedIds.contains(id);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _toggleSelection(id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Custom Checkbox
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(
                                      top: 2,
                                    ), // Align with text title
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? _kPurpleColor
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? _kPurpleColor
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
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

                                  // Content Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lembar['title'] ?? 'Untitled',
                                          style: theme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? _kPurpleColor
                                                : _kTextColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lembar['snippet'] ?? '',
                                          style: theme.bodyMedium?.copyWith(
                                            color: _kSubTextColor,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          lembar['date'] ?? '',
                                          style: theme.labelSmall?.copyWith(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Divider Halus
                          if (index < _filteredLembar.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade100,
                              indent: 60, // Indent agar sejajar teks
                              endIndent: 20,
                            ),
                        ],
                      );
                    },
                  ),
          ),

          // 4. Floating Action Button Container
          Container(
            padding: const EdgeInsets.all(20),
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
                    gradient: LinearGradient(
                      colors: _selectedIds.isEmpty
                          ? [Colors.grey.shade400, Colors.grey.shade400]
                          : [_kGradientStart, _kGradientStart],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _selectedIds.isEmpty ? null : _addSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      // Matikan efek disable default agar gradient grey terlihat
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text(
                      'Tambahkan (${_selectedIds.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
