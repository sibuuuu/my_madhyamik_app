// lib/widgets/bottom_nav_bar.dart
//
// Real Apple-style glass bottom navigation for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/glass_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home', icon: FontAwesomeIcons.house),
    _NavItem(label: 'Subjects', icon: FontAwesomeIcons.bookOpen),
    _NavItem(label: 'Quiz', icon: FontAwesomeIcons.circleQuestion),
    _NavItem(label: 'Notice', icon: FontAwesomeIcons.bullhorn),
    _NavItem(label: 'Settings', icon: FontAwesomeIcons.gear),
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.only(
              top: 8,
              bottom: 8 + (bottomInset > 0 ? bottomInset * 0.3 : 0),
              left: 6,
              right: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1,
              ),
            ),
            child: Row(
              children: List.generate(
                _items.length,
                (i) => Expanded(
                  child: _NavTab(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: 30,
              width: 42,
              decoration: BoxDecoration(
                color: selected
                    ? GlassTheme.accentRed.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: FaIcon(
                  item.icon,
                  size: 15,
                  color: selected
                      ? GlassTheme.accentRed
                      : GlassTheme.textTertiaryLight,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: TextStyle(
                color: selected
                    ? GlassTheme.accentRed
                    : GlassTheme.textTertiaryLight,
                fontSize: 9.5,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
                fontFamily: 'PlusJakartaSans',
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}