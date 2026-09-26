// lib/screens/auth/profile_setup.dart
//
// Apple-style premium profile setup for Madhyamik Shokha.
// Saves name, school, district, subjects to Realtime Database.
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/app_config.dart';
import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  static const String routeName = '/profile-setup';
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  String? _selectedDistrict;
  final Set<String> _selectedSubjects = {};
  bool _isLoading = false;

  static const List<Map<String, dynamic>> _subjects = [
    {'name': 'Bengali', 'icon': FontAwesomeIcons.bookOpen},
    {'name': 'English', 'icon': FontAwesomeIcons.bookOpenReader},
    {'name': 'Mathematics', 'icon': FontAwesomeIcons.squareRootVariable},
    {'name': 'Physical Science', 'icon': FontAwesomeIcons.atom},
    {'name': 'Life Science', 'icon': FontAwesomeIcons.dna},
    {'name': 'History', 'icon': FontAwesomeIcons.landmark},
    {'name': 'Geography', 'icon': FontAwesomeIcons.earthAsia},
  ];

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
    _nameController.dispose();
    _schoolController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        _selectedSubjects.add(subject);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDistrict == null) {
      _showError('Please select your district.');
      return;
    }

    if (_selectedSubjects.isEmpty) {
      _showError('Please select at least one subject.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('You are not signed in.');

      final profile = UserModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: user.email,
        classLevel: 'Class 10',
        school: _schoolController.text.trim(),
        board: 'WBBSE',
        selectedSubjects: _selectedSubjects.toList(),
        isProfileComplete: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await FirebaseService.saveUserProfile(profile);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
      ),
      body: Stack(
        children: [
          const _ProfileSetupBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildBasicInfo(),
                        const SizedBox(height: 18),
                        _buildDistrict(),
                        const SizedBox(height: 18),
                        _buildSubjects(),
                        const SizedBox(height: 30),
                        _buildContinueButton(),
                        const SizedBox(height: 24),
                      ],
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

  // =====================================================================
  // HEADER
  // =====================================================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Set up your profile',
          style: TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'This helps us personalize your learning experience.',
          style: TextStyle(
            color: GlassTheme.textSecondaryLight,
            fontSize: 14.5,
            height: 1.45,
            letterSpacing: 0.05,
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // BASIC INFO
  // =====================================================================
  Widget _buildBasicInfo() {
    return _GlassSection(
      title: 'Basic Information',
      icon: FontAwesomeIcons.idCard,
      children: [
        _AppleInputField(
          controller: _nameController,
          hint: 'Full name',
          icon: FontAwesomeIcons.user,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) return 'Full name is required';
            if (t.length < 3) return 'Name is too short';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _AppleInputField(
          controller: _schoolController,
          hint: 'School name',
          icon: FontAwesomeIcons.school,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) return 'School name is required';
            return null;
          },
        ),
      ],
    );
  }

  // =====================================================================
  // DISTRICT
  // =====================================================================
  Widget _buildDistrict() {
    return _GlassSection(
      title: 'District',
      icon: FontAwesomeIcons.mapLocationDot,
      subtitle: 'Select your district in West Bengal.',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.035),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDistrict,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(20),
              icon: const FaIcon(
                FontAwesomeIcons.chevronDown,
                size: 12,
                color: GlassTheme.textTertiaryLight,
              ),
              hint: const Text(
                'Select district',
                style: TextStyle(
                  color: GlassTheme.textHintLight,
                  fontSize: 15,
                ),
              ),
              style: const TextStyle(
                color: GlassTheme.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              onChanged: _isLoading
                  ? null
                  : (v) => setState(() => _selectedDistrict = v),
              items: AppConfig.wbDistricts
                  .map(
                    (d) => DropdownMenuItem<String>(
                      value: d,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(d),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // SUBJECTS
  // =====================================================================
  Widget _buildSubjects() {
    final int count = _selectedSubjects.length;
    return _GlassSection(
      title: 'Subjects',
      icon: FontAwesomeIcons.book,
      subtitle:
          'Select the subjects you are studying in Class 10.  ($count selected)',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _subjects.map((s) {
            final String name = s['name'] as String;
            final IconData icon = s['icon'] as IconData;
            final bool selected = _selectedSubjects.contains(name);
            return _SubjectChip(
              label: name,
              icon: icon,
              selected: selected,
              onTap: _isLoading ? null : () => _toggleSubject(name),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =====================================================================
  // CONTINUE BUTTON
  // =====================================================================
  Widget _buildContinueButton() {
    return SizedBox(
      height: 56,
      child: Material(
        color: GlassTheme.accentRed,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: _isLoading ? null : _handleContinue,
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 10),
                      FaIcon(
                        FontAwesomeIcons.arrowRight,
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
// GLASS SECTION
// =====================================================================
class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;

  const _GlassSection({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.90),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: GlassTheme.accentRed.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(
                        icon,
                        size: 13,
                        color: GlassTheme.accentRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: GlassTheme.textPrimaryLight,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: GlassTheme.textTertiaryLight,
                    fontSize: 12.5,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// APPLE INPUT FIELD (pill)
// =====================================================================
class _AppleInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;

  const _AppleInputField({
    this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      enabled: enabled,
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
// SUBJECT CHIP
// =====================================================================
class _SubjectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _SubjectChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? GlassTheme.accentRed
              : Colors.black.withOpacity(0.035),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? GlassTheme.accentRed
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: GlassTheme.accentRed.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: selected
                  ? Colors.white
                  : GlassTheme.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : GlassTheme.textPrimaryLight,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const FaIcon(
                FontAwesomeIcons.circleCheck,
                size: 11,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _ProfileSetupBackground extends StatelessWidget {
  const _ProfileSetupBackground();

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