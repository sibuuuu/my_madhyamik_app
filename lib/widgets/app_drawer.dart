// lib/widgets/app_drawer.dart
//
// Side navigation drawer for Madhyamik Shokha.
// Developer: Sibnath Bairagi
//
// UI Rule: Zero emojis. Only font_awesome_flutter icons.
// Theme: Glassmorphism - translucent white border, BackdropFilter blur.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';

class AppDrawer extends StatelessWidget {
  final String studentName;
  final String studentSubtitle;

  const AppDrawer({
    super.key,
    this.studentName = 'Student',
    this.studentSubtitle = 'Class 10  |  WBBSE',
  });

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop(); // drawer বন্ধ করবে
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: 290,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: MadhyamikShokhaApp.kBackground.withOpacity(0.92),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.18),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 6),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.house,
                          label: 'Home',
                          route: '/home',
                        ),
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.bookOpen,
                          label: 'Subjects',
                          route: '/subjects',
                        ),
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.circleQuestion,
                          label: 'Quiz',
                          route: '/quiz',
                        ),
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.trophy,
                          label: 'Leaderboard',
                          route: '/leaderboard',
                        ),
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.bullhorn,
                          label: 'Notices',
                          route: '/notice',
                        ),
                        _buildMenuItem(
                          context,
                          icon: FontAwesomeIcons.gear,
                          label: 'Settings',
                          route: '/settings',
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // Profile header
  // =====================================================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: MadhyamikShokhaApp.kAccent.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.user,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  studentSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // Menu item
  // =====================================================================
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isActive = ModalRoute.of(context)?.settings.name == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigate(context, route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? MadhyamikShokhaApp.kAccent.withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? MadhyamikShokhaApp.kAccent.withOpacity(0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 14,
                      color: isActive ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isActive)
                  const FaIcon(
                    FontAwesomeIcons.circle,
                    size: 6,
                    color: MadhyamikShokhaApp.kAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // Footer - developer credit + version
  // =====================================================================
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.code,
                size: 10,
                color: Colors.white.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  MadhyamikShokhaApp.kDeveloperName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${MadhyamikShokhaApp.kVersion}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
