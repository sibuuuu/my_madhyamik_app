// lib/screens/auth/login_screen.dart
//
// Apple-style premium login screen for Madhyamik Shokha.
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isResetting = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await FirebaseService.signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/profile-setup');
      } else {
        await FirebaseService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Enter your email first, then tap Recovery.');
      return;
    }

    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    if (!regex.hasMatch(email)) {
      _showError('Enter a valid email address.');
      return;
    }

    setState(() => _isResetting = true);

    try {
      await FirebaseService.sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() => _isResetting = false);
      _showSuccess('Password reset email sent to $email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResetting = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundLight,
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildGlassCard(),
                          const SizedBox(height: 26),
                          _buildFooter(),
                        ],
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

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isSignUp ? 'Create Account' : 'Hello Again!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isSignUp
              ? 'Start your Madhyamik preparation today.'
              : "Welcome back, you've been missed!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 15,
            height: 1.45,
            letterSpacing: 0.05,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.90),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AppleInputField(
                controller: _emailController,
                hint: 'Email',
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final val = (v ?? '').trim();
                  if (val.isEmpty) return 'Email is required';
                  final regex =
                      RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                  if (!regex.hasMatch(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                enabled: !_isLoading && !_isResetting,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 14),

              _AppleInputField(
                controller: _passwordController,
                hint: 'Password',
                icon: FontAwesomeIcons.lock,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                focusNode: _passwordFocus,
                validator: (v) {
                  final val = v ?? '';
                  if (val.isEmpty) return 'Password is required';
                  if (_isSignUp && val.length < 6) {
                    return 'Minimum 6 characters';
                  }
                  return null;
                },
                enabled: !_isLoading && !_isResetting,
                onSubmitted: (_) => _submit(),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      widthFactor: 1,
                      child: FaIcon(
                        _obscure
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        size: 14,
                        color: GlassTheme.textTertiaryLight,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (_isLoading || _isResetting)
                      ? null
                      : _sendPasswordReset,
                  style: TextButton.styleFrom(
                    foregroundColor: GlassTheme.textSecondaryLight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: _isResetting
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              GlassTheme.accentRed,
                            ),
                          ),
                        )
                      : const Text(
                          'Recovery Password',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              _buildPrimaryButton(),

              const SizedBox(height: 24),

              _buildToggleMode(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: GlassTheme.accentRed,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: (_isLoading || _isResetting) ? null : _submit,
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.white.withOpacity(0.20),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      FaIcon(
                        _isSignUp
                            ? FontAwesomeIcons.userPlus
                            : FontAwesomeIcons.rightToBracket,
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

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : 'Not a member?',
          style: const TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 13.5,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: (_isLoading || _isResetting) ? null : _toggleMode,
          child: Text(
            _isSignUp ? 'Sign In' : 'Register now',
            style: const TextStyle(
              color: GlassTheme.accentRed,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.code,
              size: 10,
              color: GlassTheme.textTertiaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Developed by Sibnath Bairagi',
              style: TextStyle(
                color: GlassTheme.textTertiaryLight,
                fontSize: 11.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Version 1.0.0',
          style: TextStyle(
            color: GlassTheme.textHintLight,
            fontSize: 10.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// APPLE INPUT FIELD
// =====================================================================
class _AppleInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const _AppleInputField({
    this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.enabled = true,
    this.suffix,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      enabled: enabled,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(
        color: GlassTheme.textPrimaryLight,
        fontSize: 15,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: GlassTheme.accentRed,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: GlassTheme.textHintLight,
          fontSize: 15,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: FaIcon(
            icon,
            size: 14,
            color: GlassTheme.textTertiaryLight,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 20),
        suffixIcon: suffix,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.035),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.05),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: GlassTheme.accentRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: GlassTheme.accentRed,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          color: GlassTheme.accentRed,
          fontSize: 11.5,
          letterSpacing: 0.1,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

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
            Positioned(
              top: 200,
              left: -80,
              child: _glow(GlassTheme.accentPurple, 240),
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