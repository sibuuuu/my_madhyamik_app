// lib/screens/settings/change_password_screen.dart
//
// Change password with re-authentication.
// Developer: Sibnath Bairagi

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/change-password';
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  Future<void> _changePassword() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      _showInfo('Enter your current password.');
      return;
    }
    if (newPass.length < 6) {
      _showInfo('New password must be at least 6 characters.');
      return;
    }
    if (newPass != confirm) {
      _showInfo('New passwords do not match.');
      return;
    }
    if (newPass == current) {
      _showInfo('New password must be different.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      _showInfo('Not signed in.');
      return;
    }

    setState(() => _saving = true);

    try {
      // Step 1: Re-authenticate with current password
      final cred = EmailAuthProvider.credential(
        email: email,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      // Step 2: Update to new password
      await user.updatePassword(newPass);

      if (!mounted) return;
      setState(() => _saving = false);
      _showSuccess('Password changed successfully!');
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showInfo(_authError(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showInfo('Could not change password.');
    }
  }

  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Current password is incorrect.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleExclamation,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleCheck,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
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
        title: const Text('Change Password'),
      ),
      body: Stack(
        children: [
          const _PasswordBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: GlassTheme.accentRed
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.lock,
                                size: 14,
                                color: GlassTheme.accentRed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Your new password must be at least 6 characters.',
                              style: TextStyle(
                                color: GlassTheme.textSecondaryLight,
                                fontSize: 12.5,
                                height: 1.4,
                                fontFamily: 'PlusJakartaSans',
                                fontFamilyFallback: ['HindSiliguri'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _PasswordField(
                      controller: _currentController,
                      hint: 'Current password',
                      obscure: _obscureCurrent,
                      onToggle: () => setState(
                          () => _obscureCurrent = !_obscureCurrent),
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 14),
                    _PasswordField(
                      controller: _newController,
                      hint: 'New password',
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 14),
                    _PasswordField(
                      controller: _confirmController,
                      hint: 'Confirm new password',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                      enabled: !_saving,
                    ),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: GlassTheme.accentRed,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: _saving ? null : _changePassword,
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                      SizedBox(width: 10),
                      FaIcon(
                        FontAwesomeIcons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PASSWORD FIELD
// =====================================================================
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: const TextStyle(
        color: GlassTheme.textPrimaryLight,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: 'PlusJakartaSans',
      ),
      cursorColor: GlassTheme.accentRed,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: GlassTheme.textHintLight,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: 'PlusJakartaSans',
          fontFamilyFallback: ['HindSiliguri'],
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 18, right: 10),
          child: FaIcon(
            FontAwesomeIcons.lock,
            size: 14,
            color: GlassTheme.textTertiaryLight,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 18, left: 10),
            child: Center(
              widthFactor: 1,
              child: FaIcon(
                obscure
                    ? FontAwesomeIcons.eyeSlash
                    : FontAwesomeIcons.eye,
                size: 14,
                color: GlassTheme.textTertiaryLight,
              ),
            ),
          ),
        ),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: GlassTheme.accentRed,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _PasswordBackground extends StatelessWidget {
  const _PasswordBackground();

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