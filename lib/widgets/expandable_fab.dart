import 'package:flutter/material.dart';
import '../screens/lembar/add_lembar.dart';
import '../screens/jilid/create_jilid_page.dart';

const Color _kPurpleColor = Color(0xFF8D07C6);

class ExpandableFAB extends StatefulWidget {
  final VoidCallback? onAddLembarComplete;
  final Function(dynamic)? onCreateJilidComplete;

  const ExpandableFAB({
    super.key,
    this.onAddLembarComplete,
    this.onCreateJilidComplete,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.addListener(_handleAnimationUpdate);
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.removeListener(_handleAnimationUpdate);
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnimationUpdate() {
    if (_isExpanded && _expandAnimation.value > 0.1) {
      _updateOverlay();
    } else if (!_isExpanded || _expandAnimation.value < 0.1) {
      _removeOverlay();
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _removeOverlay();
      }
    });
  }

  void _updateOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final overlay = Overlay.of(context);
      final renderBox =
          _fabKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        if (_overlayEntry != null) {
          _removeOverlay();
        }
        return;
      }

      if (_overlayEntry == null) {
        _overlayEntry = OverlayEntry(
          builder: (context) {
            // Recalculate position on each build to ensure accuracy
            final renderBox =
                _fabKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null) {
              return const SizedBox.shrink();
            }

            final fabSize = renderBox.size;
            final fabPosition = renderBox.localToGlobal(Offset.zero);
            final screenSize = MediaQuery.of(context).size;

            final bottomOffset =
                screenSize.height - fabPosition.dy - fabSize.height;
            final rightOffset =
                screenSize.width - fabPosition.dx - fabSize.width;

            return Positioned(
              bottom: bottomOffset + 80,
              right: rightOffset,
              child: IgnorePointer(
                ignoring: !_isExpanded || _expandAnimation.value < 0.3,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _expandAnimation.value,
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Tambah Jilid button (farther from FAB)
                            _ActionButton(
                              icon: Icons.library_add,
                              label: 'Jilid Baru',
                              onPressed: _navigateToCreateJilid,
                            ),
                            const SizedBox(height: 12),
                            // Tambah Lembar button (closer to FAB)
                            _ActionButton(
                              icon: Icons.edit,
                              label: 'Lembar Baru',
                              onPressed: _navigateToAddLembar,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
        overlay.insert(_overlayEntry!);
      } else {
        // Update existing overlay to recalculate position
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _navigateToAddLembar() async {
    if (!mounted) return;

    // Collapse FAB first and remove overlay
    if (_isExpanded) {
      _removeOverlay();
      setState(() {
        _isExpanded = false;
        _animationController.reverse();
      });
      // Wait a bit for collapse animation to start
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // Navigate to AddLembarPage
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddLembarPage()));

    // Call callback after navigation completes
    if (mounted && widget.onAddLembarComplete != null) {
      widget.onAddLembarComplete!();
    }
  }

  Future<void> _navigateToCreateJilid() async {
    if (!mounted) return;

    // Collapse FAB first and remove overlay
    if (_isExpanded) {
      _removeOverlay();
      setState(() {
        _isExpanded = false;
        _animationController.reverse();
      });
      // Wait a bit for collapse animation to start
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    // Navigate to CreateJilidPage
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateJilidPage()));

    // Call callback after navigation completes
    if (mounted && widget.onCreateJilidComplete != null) {
      widget.onCreateJilidComplete!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: _fabKey,
      onPressed: _toggleExpansion,
      backgroundColor: _kPurpleColor,
      shape: const CircleBorder(),
      child: AnimatedRotation(
        turns: _isExpanded ? 0.125 : 0.0, // 45 degrees when expanded
        duration: const Duration(milliseconds: 300),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          splashColor: _kPurpleColor.withOpacity(0.2),
          highlightColor: _kPurpleColor.withOpacity(0.1),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPurpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: _kPurpleColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
