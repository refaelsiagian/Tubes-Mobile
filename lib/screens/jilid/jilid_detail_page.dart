import 'package:flutter/material.dart';
import '../../data/services/lembar_storage.dart';
import '../main/blog_page.dart';
import 'edit_jilid_page.dart'; // Import halaman edit

// Konstanta Warna Modern
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kBackgroundColor = Color(0xFFF9F9F9);
const Color _kSubTextColor = Color(0xFF757575);

class JilidDetailPage extends StatefulWidget {
  final Map<String, dynamic> jilid;

  const JilidDetailPage({super.key, required this.jilid});

  @override
  State<JilidDetailPage> createState() => _JilidDetailPageState();
}

class _JilidDetailPageState extends State<JilidDetailPage> {
  // Data jilid lokal yang bisa diupdate (misal setelah edit judul)
  late Map<String, dynamic> _currentJilidData;
  List<Map<String, dynamic>> _lembarList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentJilidData = widget.jilid;
    _loadJilidContent();
  }

  Future<void> _loadJilidContent() async {
    // Kita ambil list lembar LANGSUNG dari data jilid
    // karena jilid menyimpan array 'lembar' di dalamnya.
    final List<dynamic> rawLembar = _currentJilidData['lembar'] ?? [];

    if (mounted) {
      setState(() {
        _lembarList = rawLembar
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoading = false;
      });
    }
  }

  // LOGIC: Edit Jilid
  Future<void> _handleEditJilid() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJilidPage(jilid: _currentJilidData),
      ),
    );

    // Refresh data setelah kembali dari Edit
    if (result == true) {
      // Ambil data terbaru dari storage
      final allJilid = await LembarStorage.getJilid();
      final updatedJilid = allJilid.firstWhere(
        (j) => j['id'].toString() == _currentJilidData['id'].toString(),
        orElse: () => _currentJilidData,
      );

      setState(() {
        _currentJilidData = updatedJilid;
        _isLoading = true; // Reload list konten
      });
      _loadJilidContent();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jilid berhasil diperbarui"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // LOGIC: Hapus Jilid
  Future<void> _handleDeleteJilid() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jilid?'),
        content: Text(
          'Jilid "${_currentJilidData['title']}" akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
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
      if (_currentJilidData['id'] != null) {
        await LembarStorage.deleteJilid(_currentJilidData['id'].toString());
      }

      if (mounted) {
        Navigator.pop(context); // Pop Detail Page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jilid berhasil dihapus"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Baru saja';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Modern
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: _kTextColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentJilidData['title'] ?? 'Jilid',
                            style: theme.headlineMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _kTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_lembarList.length} Artikel tersimpan',
                            style: theme.bodySmall?.copyWith(
                              color: _kSubTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu Titik Tiga
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: _kTextColor,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _handleEditJilid();
                        } else if (value == 'delete') {
                          _handleDeleteJilid();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: _kTextColor,
                              ),
                              SizedBox(width: 12),
                              Text('Edit Jilid'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Hapus Jilid',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Deskripsi Jilid
            if (_currentJilidData['description'] != null &&
                (_currentJilidData['description'] as String).isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  _currentJilidData['description'] as String,
                  style: theme.bodyMedium?.copyWith(
                    color: _kSubTextColor,
                    height: 1.4,
                  ),
                ),
              ),

            // List Lembar
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kPurpleColor),
                    )
                  : _lembarList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Jilid ini masih kosong',
                            style: theme.bodyMedium?.copyWith(
                              color: _kSubTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _lembarList.length,
                      itemBuilder: (context, index) {
                        final lembar = _lembarList[index];
                        return _buildModernLembarCard(lembar, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLembarCard(
    Map<String, dynamic> lembar,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogPage(
                  blog: {
                    'title': lembar['title'],
                    'documentJson': lembar['documentJson'],
                    'snippet': lembar['snippet'] ?? '',
                    'date':
                        lembar['date'] ?? _formatDate(lembar['publishedAt']),
                    'authorName': lembar['authorName'] ?? 'Pengguna',
                    // PERBAIKAN 1: Kosongkan inisial saat navigasi
                    'authorInitials': '', 
                    'thumbnail': lembar['thumbnail'],
                    'likes': lembar['likes'] ?? '0',
                    'comments': lembar['comments'] ?? '0',
                    'tags': lembar['tags'] ?? [],
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // PERBAIKAN 2: Ganti CircleAvatar Teks jadi Icon Person
                          CircleAvatar(
                            radius: 8, // Ukuran kecil
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              size: 10, // Icon disesuaikan dengan radius
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lembar['authorName'] ?? 'Pengguna',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _kTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatDate(
                              lembar['publishedAt'] ?? lembar['date'],
                            ),
                            style: textTheme.labelSmall?.copyWith(
                              color: _kSubTextColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lembar['title'] ?? 'Tanpa Judul',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _kTextColor,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lembar['snippet'] ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _kSubTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 14,
                            color: _kSubTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lembar['likes'] ?? '0',
                            style: TextStyle(
                              fontSize: 11,
                              color: _kSubTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.mode_comment_outlined,
                            size: 14,
                            color: _kSubTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lembar['comments'] ?? '0',
                            style: TextStyle(
                              fontSize: 11,
                              color: _kSubTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (lembar['thumbnail'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                        image: DecorationImage(
                          image: NetworkImage(lembar['thumbnail']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}