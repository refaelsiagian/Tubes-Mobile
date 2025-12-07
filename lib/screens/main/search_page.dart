import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/expandable_fab.dart';
import '../../core/utils/navigation_helper.dart';

// Konstanta Warna
const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kTextColor = Color(0xFF1A1A1A);
const Color _kSubTextColor = Color(0xFF757575);
const Color _kBackgroundColor = Colors.white;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const int _currentNavIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentNavIndex) {
      NavigationHelper.navigateToPage(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER & SEARCH BAR
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cari',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _kTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Box Modern
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50, // Latar sangat terang
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ), // Border halus
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(
                        color: _kTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: _kPurpleColor,
                      decoration: InputDecoration(
                        hintText: 'Temukan cerita menarik...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                color: Colors.grey,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),

            // 2. CONTENT AREA (HASIL PENCARIAN / EMPTY)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchController.text.isNotEmpty) ...[
                      // Tampilan saat user mengetik (Placeholder Hasil)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey.shade200,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Mencari "${_searchController.text}"...',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Tampilan Kosong (Fitur Tren sudah dihapus)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(
                                Icons.explore_off_outlined,
                                size: 60,
                                color: Colors.grey.shade200,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Ketik sesuatu untuk mencari',
                                style: TextStyle(color: _kSubTextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: const ExpandableFAB(),
    );
  }
}
