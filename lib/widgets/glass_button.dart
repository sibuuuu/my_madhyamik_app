// lib/widgets/glass_button.dart
//
// Reusable button widgets for Madhyamik Shokha.
// - GlassPrimaryButton  : solid colored button (like the red Sign In)
// - GlassOutlineButton  : transparent glass button with border
// - GlassIconButton     : circular glass icon button
// - GlassChipButton     : small rounded chip
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/glass_theme.dart';

// =====================================================================
// PRIMARY BUTTON — solid color (Sign In, Next, Get Started)
// =====================================================================
class GlassPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double height;
  final double? width;
  final double borderRadius;
  final bool fullWidth;

  const GlassPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.backgroundColor,
    this.height = 54,
    this.width,
    this.borderRadius = 14,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Widget inner = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          Text(
            label,
            style: const TextStyle(
              color: GlassTheme.textOnAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 10),
            FaIcon(icon, size: 13, color: GlassTheme.textOnAccent),
          ],
        ],
      ],
    );

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? GlassTheme.buttonRedGradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: GlassTheme.accentRed.withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Opacity(opacity: isDisabled ? 0.6 : 1.0, child: inner),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// OUTLINE BUTTON — glass transparent with border
// =====================================================================
class GlassOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDark;
  final double height;
  final double? width;
  final double borderRadius;
  final bool fullWidth;
  final Color? textColor;

  const GlassOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDark = false,
    this.height = 52,
    this.width,
    this.borderRadius = 14,
    this.fullWidth = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final borderClr = GlassTheme.border(isDark: isDark);
    final surface = GlassTheme.glassSurface(isDark: isDark);
    final txtColor =
        textColor ?? GlassTheme.textPrimary(isDark: isDark);

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDisabled ? [] : GlassTheme.softShadow(isDark: isDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderClr, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Center(
                  child: Opacity(
                    opacity: isDisabled ? 0.5 : 1.0,
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                txtColor,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  color: txtColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (icon != null) ...[
                                const SizedBox(width: 10),
                                FaIcon(icon, size: 13, color: txtColor),
                              ],
                            ],
                          ),
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

// =====================================================================
// ICON BUTTON — circular glass (hamburger, bell, profile)
// =====================================================================
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool isDark;
  final Color? iconColor;
  final Color? backgroundColor;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 42,
    this.iconSize = 15,
    this.isDark = false,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderClr = GlassTheme.border(isDark: isDark);
    final surface =
        backgroundColor ?? GlassTheme.glassSurface(isDark: isDark);
    final clr = iconColor ?? GlassTheme.textPrimary(isDark: isDark);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(size * 0.30),
            border: Border.all(color: borderClr, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(size * 0.30),
              child: Center(
                child: FaIcon(icon, size: iconSize, color: clr),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// CHIP BUTTON — small rounded chip (filters, tags)
// =====================================================================
class GlassChipButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool selected;
  final bool isDark;

  const GlassChipButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.selected = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color surface = selected
        ? GlassTheme.accentBlue.withOpacity(0.18)
        : GlassTheme.glassSurface(isDark: isDark);

    final Color borderClr = selected
        ? GlassTheme.accentBlue.withOpacity(0.65)
        : GlassTheme.border(isDark: isDark);

    final Color textClr = selected
        ? GlassTheme.accentBlue
        : GlassTheme.textSecondary(isDark: isDark);

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: GlassTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: borderClr, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              FaIcon(icon, size: 11, color: textClr),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textClr,
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}