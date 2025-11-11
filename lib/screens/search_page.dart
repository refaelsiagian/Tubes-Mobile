import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/navigation_helper.dart';

const Color _kBackgroundColor = Color(0xFFFFFFFF);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const int _currentNavIndex = 1; // Search page index
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Content
            Expanded(
              child: Center(
                child: Text(
                  'Search functionality coming soon...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
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
    );
  }
}
