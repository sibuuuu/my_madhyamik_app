// lib/screens/settings/settings_screen.dart
//
// Settings screen — only working features.
// Developer: Sibnath Bairagi

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Profile state
  String _studentName = 'Student';
  String _studentSubtitle = 'Class 10  |  WBBSE';
  String _studentSchool = '';
  String _studentPhotoUrl = '';
  bool _loadingProfile = true;

  // External links
  static const String _privacyUrl =
      'https://2wbky3-5wmzyk2z9-arcedawebapps1.vercel.app';
  static const String _instagramUrl =
      'https://www.instagram.com/madhyamik_sokha';
  static const String _whatsappUrl =
      'https://whatsapp.com/channel/0029VbDajBJDZ4LezgieUS41';
  static const String _youtubeUrl =
      'https://youtube.com/@madhyamik_sokha';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }

    try {
      final profile = await FirebaseService.getUserProfile(
        uid,
        forceRefresh: true,
      );

      if (!mounted) return;
      if (profile == null) {
        setState(() => _loadingProfile = false);
        return;
      }

      final cls = profile.classLevel.isNotEmpty
          ? profile.classLevel
          : 'Class 10';
      final board =
          profile.board.isNotEmpty ? profile.board : 'WBBSE';

      setState(() {
        _studentName = profile.displayName;
        _studentSubtitle = '$cls  |  $board';
        _studentSchool = profile.school;
        _studentPhotoUrl = profile.profileImageUrl;
        _loadingProfile = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showInfo('Could not open link.');
    } catch (_) {
      _showInfo('Could not open link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 15,
            color: GlassTheme.textPrimaryLight,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          const _SettingsBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 22),
                    _buildSection(
                      title: 'Account',
                      items: [
                        _SettingItem(
                          icon: FontAwesomeIcons.userPen,
                          label: 'Edit Profile',
                          subtitle: 'Name, school, district, photo',
                          onTap: () async {
                            final changed = await Navigator.of(context)
                                .pushNamed('/edit-profile');
                            if (changed == true && mounted) {
                              _loadProfile();
                            }
                          },
                        ),
                          _SettingItem(
                          icon: FontAwesomeIcons.lock,
                          label: 'Change Password',
                          subtitle: 'Update your account password',
                          onTap: () => Navigator.of(context).pushNamed(
                            '/change-password',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      title: 'Support',
                      items: [
                        _SettingItem(
                          icon: FontAwesomeIcons.circleQuestion,
                          label: 'Help Center',
                          onTap: () => _openUrl(_privacyUrl),
                        ),
                        _SettingItem(
                          icon: FontAwesomeIcons.shieldHalved,
                          label: 'Privacy Policy',
                          onTap: () => _openUrl(_privacyUrl),
                        ),
                        _SettingItem(
                          icon: FontAwesomeIcons.fileContract,
                          label: 'Terms of Use',
                          onTap: () => _openUrl(_privacyUrl),
                        ),
                        _SettingItem(
                          icon: FontAwesomeIcons.circleInfo,
                          label: 'About Madhyamik Shokha',
                          onTap: _showAbout,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      title: 'Connect With Us',
                      items: [
                        _SettingItem(
                          icon: FontAwesomeIcons.instagram,
                          label: 'Instagram',
                          subtitle: '@madhyamik_sokha',
                          onTap: () => _openUrl(_instagramUrl),
                        ),
                        _SettingItem(
                          icon: FontAwesomeIcons.whatsapp,
                          label: 'WhatsApp Channel',
                          subtitle: 'Join for notices',
                          onTap: () => _openUrl(_whatsappUrl),
                        ),
                        _SettingItem(
                          icon: FontAwesomeIcons.youtube,
                          label: 'YouTube',
                          subtitle: '@madhyamik_sokha',
                          onTap: () => _openUrl(_youtubeUrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _buildSignOutButton(),
                    const SizedBox(height: 28),
                    _buildDeveloperCredit(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // PROFILE CARD
  // =====================================================================
  Widget _buildProfileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile photo
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GlassTheme.accentRed.withOpacity(0.10),
                  border: Border.all(
                    color: GlassTheme.accentRed.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: _studentPhotoUrl.isNotEmpty
                      ? Image.network(
                          _studentPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _photoFallback(),
                        )
                      : _photoFallback(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadingProfile ? 'Loading...' : _studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _studentSubtitle,
                      style: const TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                    if (_studentSchool.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _studentSchool,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: GlassTheme.textHintLight,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PlusJakartaSans',
                          fontFamilyFallback: ['HindSiliguri'],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoFallback() {
    return Container(
      color: GlassTheme.accentRed.withOpacity(0.10),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          size: 22,
          color: GlassTheme.accentRed,
        ),
      ),
    );
  }

  // =====================================================================
  // SECTION + ROW
  // =====================================================================
  Widget _buildSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.95),
                  width: 1,
                ),
              ),
              child: Column(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final bool last = i == items.length - 1;
                  return Column(
                    children: [
                      _buildRow(item),
                      if (!last)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.black.withOpacity(0.05),
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(_SettingItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: GlassTheme.accentRed.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(
                  item.icon,
                  size: 12,
                  color: GlassTheme.accentRed,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: ['HindSiliguri'],
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        color: GlassTheme.textTertiaryLight,
                        fontSize: 11.5,
                        fontFamily: 'PlusJakartaSans',
                        fontFamilyFallback: ['HindSiliguri'],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 12,
              color: GlassTheme.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // SIGN OUT
  // =====================================================================
  Widget _buildSignOutButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: _confirmSignOut,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    size: 13,
                    color: GlassTheme.textPrimaryLight,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: GlassTheme.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // DEVELOPER CREDIT
  // =====================================================================
  Widget _buildDeveloperCredit() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FaIcon(
              FontAwesomeIcons.code,
              size: 10,
              color: GlassTheme.textTertiaryLight,
            ),
            SizedBox(width: 8),
            Text(
              'Developed by Sibnath Bairagi',
              style: TextStyle(
                color: GlassTheme.textTertiaryLight,
                fontSize: 11.5,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(
              FontAwesomeIcons.instagram,
              const Color(0xFFE4405F),
              () => _openUrl(_instagramUrl),
            ),
            const SizedBox(width: 10),
            _socialIcon(
              FontAwesomeIcons.whatsapp,
              const Color(0xFF25D366),
              () => _openUrl(_whatsappUrl),
            ),
            const SizedBox(width: 10),
            _socialIcon(
              FontAwesomeIcons.youtube,
              const Color(0xFFFF0000),
              () => _openUrl(_youtubeUrl),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Version 1.0.0',
          style: TextStyle(
            color: GlassTheme.textHintLight,
            fontSize: 10.5,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  // =====================================================================
  // DIALOGS
  // =====================================================================
  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('About Madhyamik Shokha'),
        content: const Text(
          'Version 1.0.0\n'
          'Developer: Sibnath Bairagi\n'
          'Class 10 Learning Companion\n\n'
          'A free educational app for WBBSE Class 10 students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      _showInfo('Not signed in.');
      return;
    }

    try {
      final profile = await FirebaseService.getUserProfile(uid);
      final email = profile?.email;

      if (email == null || email.isEmpty) {
        _showInfo('No email found on your account.');
        return;
      }

      await FirebaseService.sendPasswordResetEmail(email);
      _showInfo('Reset link sent to $email');
    } catch (e) {
      _showInfo('Could not send reset email.');
    }
  }

  void _confirmSignOut() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Sign Out?'),
        content: const Text(
          'You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.signOut();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (r) => false);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: GlassTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleInfo,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

// =====================================================================
// DATA CLASS
// =====================================================================
class _SettingItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: GlassTheme.backgroundGradientLight,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -110,
              child: _glow(GlassTheme.accentRed, 340),
            ),
            Positioned(
              bottom: -160,
              left: -110,
              child: _glow(GlassTheme.accentBlue, 360),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.10),
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}