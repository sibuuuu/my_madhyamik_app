// lib/widgets/glass_input.dart
//
// Reusable glass input widgets for Madhyamik Shokha.
// - GlassTextField     : standard text input
// - GlassPasswordField : password with eye toggle
// - GlassSearchField   : search bar
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/glass_theme.dart';

// =====================================================================
// TEXT FIELD — standard input
// =====================================================================
class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool isDark;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextAlign textAlign;

  const GlassTextField({
    super.key,
    this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.isDark = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final surface = GlassTheme.glassInput(isDark: isDark);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);
    final hintClr = GlassTheme.textHint(isDark: isDark);
    final iconClr = GlassTheme.textTertiary(isDark: isDark);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(
        color: textClr,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
      cursorColor: GlassTheme.accentBlue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintClr,
          fontSize: 15,
          letterSpacing: 0.2,
        ),
        counterText: '',
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: FaIcon(prefixIcon, size: 14, color: iconClr),
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 20),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 10),
                  child: FaIcon(suffixIcon, size: 14, color: iconClr),
                ),
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 20),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: BorderSide(color: borderClr, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: const BorderSide(
            color: GlassTheme.accentBlue,
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: BorderSide(
            color: borderClr.withOpacity(0.5),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: const BorderSide(
            color: GlassTheme.accentRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          borderSide: const BorderSide(
            color: GlassTheme.accentRed,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          color: GlassTheme.accentRed,
          fontSize: 11.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// =====================================================================
// PASSWORD FIELD — with eye toggle
// =====================================================================
class GlassPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final bool enabled;
  final bool isDark;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const GlassPasswordField({
    super.key,
    this.controller,
    this.hint = 'Password',
    this.enabled = true,
    this.isDark = false,
    this.validator,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<GlassPasswordField> createState() => _GlassPasswordFieldState();
}

class _GlassPasswordFieldState extends State<GlassPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: widget.controller,
      hint: widget.hint,
      prefixIcon: FontAwesomeIcons.lock,
      suffixIcon: _obscure
          ? FontAwesomeIcons.eyeSlash
          : FontAwesomeIcons.eye,
      onSuffixTap: () => setState(() => _obscure = !_obscure),
      obscureText: _obscure,
      enabled: widget.enabled,
      isDark: widget.isDark,
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.done,
    );
  }
}

// =====================================================================
// SEARCH FIELD — pill shaped
// =====================================================================
class GlassSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool isDark;
  final VoidCallback? onTap;

  const GlassSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = GlassTheme.glassInput(isDark: isDark);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);
    final hintClr = GlassTheme.textHint(isDark: isDark);

    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(GlassTheme.radiusFull),
            border: Border.all(color: borderClr, width: 1),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: onTap != null,
            style: TextStyle(
              color: textClr,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
            cursorColor: GlassTheme.accentBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: hintClr, fontSize: 15),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 10),
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 14,
                  color: hintClr,
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 20),
              suffixIcon: (controller?.text.isNotEmpty ?? false)
                  ? GestureDetector(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18, left: 10),
                        child: FaIcon(
                          FontAwesomeIcons.circleXmark,
                          size: 15,
                          color: hintClr,
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// DROPDOWN — glass styled dropdown
// =====================================================================
class GlassDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isDark;
  final bool enabled;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.isDark = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final surface = GlassTheme.glassInput(isDark: isDark);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);
    final hintClr = GlassTheme.textHint(isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
        border: Border.all(color: borderClr, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
          hint: Row(
            children: [
              if (prefixIcon != null) ...[
                FaIcon(prefixIcon, size: 14, color: hintClr),
                const SizedBox(width: 10),
              ],
              Text(
                hint,
                style: TextStyle(color: hintClr, fontSize: 14),
              ),
            ],
          ),
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 12,
            color: hintClr,
          ),
          style: TextStyle(color: textClr, fontSize: 14.5),
          onChanged: enabled ? onChanged : null,
          items: items,
        ),
      ),
    );
  }
}