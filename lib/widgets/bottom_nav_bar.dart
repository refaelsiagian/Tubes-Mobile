import 'package:flutter/material.dart';

const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kInactiveColor = Color(0xFF9E9E9E);

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,    
    
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // Sudut sangat bulat
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Bayangan halus
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Jarak antar item
          children: [
            _buildAnimatedItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildAnimatedItem(
              index: 1,
              icon: Icons.search_rounded,
              label: 'Cari',
            ),
            _buildAnimatedItem(
              index: 2,
              icon: Icons.bookmark_rounded,
              label: 'Simpan',
            ),
            _buildAnimatedItem(
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        // ANIMASI 1: Durasi perubahan bentuk container
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Background muncul hanya saat aktif
          color: isSelected
              ? _kPurpleColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Agar lebar menyesuaikan isi
          children: [
            // Icon
            Icon(
              icon,
              size: 24,
              color: isSelected ? _kPurpleColor : _kInactiveColor,
            ),

            // ANIMASI 2: Label Teks yang melebar/muncul
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected
                    ? null
                    : 0, // Jika tidak aktif, lebarnya 0 (hilang)
                child: Padding(
                  padding: const EdgeInsets.only(left: 8), // Jarak ikon ke teks
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _kPurpleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .clip, // Mencegah error overflow saat animasi
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
