// lib/screens/settings/edit_profile_screen.dart
//
// Apple-style edit profile — name, school, district, photo.
// Developer: Sibnath Bairagi

import 'dart:io';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_config.dart';
import '../../config/glass_theme.dart';
import '../../services/firebase_service.dart';
import '../../services/imgbb_service.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();

  String _district = '';
  String _classLevel = 'Class 10';
  String _board = 'WBBSE';
  String _photoUrl = '';
  Uint8List? _pickedBytes;

  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;

  static const List<String> _classes = ['Class 9', 'Class 10'];
  static const List<String> _boards = ['WBBSE', 'ICSE', 'CBSE'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseService.currentUid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snap =
          await FirebaseDatabase.instance.ref('users/$uid').get();
      if (!snap.exists || snap.value == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final data = Map<String, dynamic>.from(snap.value as Map);
      if (!mounted) return;
      setState(() {
        _nameController.text = (data['name'] ?? '').toString();
        _schoolController.text = (data['school'] ?? '').toString();
        _district = (data['district'] ?? '').toString();
        _classLevel = (data['classLevel'] ?? 'Class 10').toString();
        _board = (data['board'] ?? 'WBBSE').toString();
        _photoUrl = (data['profileImageUrl'] ?? '').toString();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 75,
      );
      if (picked == null) return;

      setState(() => _uploading = true);

      String? url;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        _pickedBytes = bytes;
        url = await ImgbbService.uploadBytes(
          bytes,
          name: 'profile_${FirebaseService.currentUid}',
        );
      } else {
        url = await ImgbbService.uploadFile(
          File(picked.path),
          name: 'profile_${FirebaseService.currentUid}',
        );
      }

      if (!mounted) return;
      setState(() => _uploading = false);

      if (url == null || url.isEmpty) {
        _showInfo('Photo upload failed. Try again.');
        return;
      }

      setState(() => _photoUrl = url!);
      _showInfo('Photo uploaded. Tap Save to apply.');
    } catch (e) {
      if (mounted) setState(() => _uploading = false);
      _showInfo('Could not pick image.');
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final school = _schoolController.text.trim();

    if (name.length < 3) {
      _showInfo('Name is too short.');
      return;
    }
    if (school.isEmpty) {
      _showInfo('School name is required.');
      return;
    }
    if (_district.isEmpty) {
      _showInfo('Please select a district.');
      return;
    }

    final uid = FirebaseService.currentUid;
    if (uid == null) {
      _showInfo('Not signed in.');
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseDatabase.instance.ref('users/$uid').update({
        'name': name,
        'school': school,
        'district': _district,
        'classLevel': _classLevel,
        'board': _board,
        'profileImageUrl': _photoUrl,
      });

      await FirebaseService.getUserProfile(uid, forceRefresh: true);

      if (!mounted) return;
      setState(() => _saving = false);
      _showInfo('Profile saved!');
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showInfo('Could not save profile.');
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

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
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
        title: const Text('Edit Profile'),
      ),
      body: Stack(
        children: [
          const _EditBackground(),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GlassTheme.accentRed,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPhotoSection(),
                          const SizedBox(height: 30),
                          _buildNameField(),
                          const SizedBox(height: 14),
                          _buildSchoolField(),
                          const SizedBox(height: 14),
                          _buildDistrictField(),
                          const SizedBox(height: 14),
                          _buildClassBoardRow(),
                          const SizedBox(height: 34),
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

  // =====================================================================
  // PHOTO — Apple style circle with edit badge
  // =====================================================================
  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _uploading ? null : _pickImage,
            child: Stack(
              children: [
                Container(
                  height: 112,
                  width: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: GlassTheme.accentRed.withOpacity(0.20),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildPhotoWidget(),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GlassTheme.accentRed,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              GlassTheme.accentRed.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _uploading
                        ? const Center(
                            child: SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: FaIcon(
                              FontAwesomeIcons.camera,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _uploading ? 'Uploading...' : 'Tap to change photo',
            style: const TextStyle(
              color: GlassTheme.textTertiaryLight,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              fontFamily: 'PlusJakartaSans',
              fontFamilyFallback: ['HindSiliguri'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget() {
    if (_pickedBytes != null && kIsWeb) {
      return Image.memory(_pickedBytes!, fit: BoxFit.cover);
    }
    if (_photoUrl.isNotEmpty) {
      return Image.network(
        _photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoFallback(),
      );
    }
    return _photoFallback();
  }

  Widget _photoFallback() {
    return Container(
      color: GlassTheme.accentRed.withOpacity(0.08),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          size: 36,
          color: GlassTheme.accentRed,
        ),
      ),
    );
  }

  // =====================================================================
  // FIELDS — Apple iOS style
  // =====================================================================
  Widget _buildNameField() {
    return _AppleField(
      controller: _nameController,
      hint: 'Full name',
      icon: FontAwesomeIcons.user,
      enabled: !_saving,
    );
  }

  Widget _buildSchoolField() {
    return _AppleField(
      controller: _schoolController,
      hint: 'School name',
      icon: FontAwesomeIcons.school,
      enabled: !_saving,
    );
  }

  Widget _buildDistrictField() {
    return _AppleDropdown(
      value: _district.isEmpty ? null : _district,
      hint: 'Select district',
      icon: FontAwesomeIcons.mapLocationDot,
      items: AppConfig.wbDistricts,
      enabled: !_saving,
      onChanged: (v) {
        if (v != null) setState(() => _district = v);
      },
    );
  }

  Widget _buildClassBoardRow() {
    return Row(
      children: [
        Expanded(
          child: _AppleDropdown(
            value: _classLevel,
            hint: 'Class',
            icon: FontAwesomeIcons.graduationCap,
            items: _classes,
            enabled: !_saving,
            onChanged: (v) {
              if (v != null) setState(() => _classLevel = v);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AppleDropdown(
            value: _board,
            hint: 'Board',
            icon: FontAwesomeIcons.book,
            items: _boards,
            enabled: !_saving,
            onChanged: (v) {
              if (v != null) setState(() => _board = v);
            },
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // SAVE
  // =====================================================================
  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: Material(
        color: GlassTheme.accentRed,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: _saving ? null : _save,
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
                        'Save Changes',
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
// APPLE FIELD — pill shape, clean
// =====================================================================
class _AppleField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;

  const _AppleField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(
        color: GlassTheme.textPrimaryLight,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: 'PlusJakartaSans',
        fontFamilyFallback: ['HindSiliguri'],
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.04),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// APPLE DROPDOWN — pill shape
// =====================================================================
class _AppleDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _AppleDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          icon: const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 11,
            color: GlassTheme.textTertiaryLight,
          ),
          hint: Row(
            children: [
              FaIcon(
                icon,
                size: 14,
                color: GlassTheme.textTertiaryLight,
              ),
              const SizedBox(width: 10),
              Text(
                hint,
                style: const TextStyle(
                  color: GlassTheme.textHintLight,
                  fontSize: 15,
                  fontFamily: 'PlusJakartaSans',
                  fontFamilyFallback: ['HindSiliguri'],
                ),
              ),
            ],
          ),
          style: const TextStyle(
            color: GlassTheme.textPrimaryLight,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            fontFamily: 'PlusJakartaSans',
            fontFamilyFallback: ['HindSiliguri'],
          ),
          onChanged: enabled ? onChanged : null,
          items: items
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
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================
class _EditBackground extends StatelessWidget {
  const _EditBackground();

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