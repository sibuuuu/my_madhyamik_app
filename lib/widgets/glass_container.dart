// lib/widgets/glass_container.dart
//
// Reusable glass card widget for Madhyamik Shokha.
// Apple-style glassmorphism, low-end friendly.
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/glass_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final bool isDark;
  final bool showHighlight;
  final bool showShadow;
  final VoidCallback? onTap;
  final Gradient? customGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 24,
    this.color,
    this.borderColor,
    this.isDark = false,
    this.showHighlight = true,
    this.showShadow = true,
    this.onTap,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = color ?? GlassTheme.glassSurface(isDark: isDark);
    final borderClr = borderColor ?? GlassTheme.border(isDark: isDark);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderClr, width: 1),
          ),
          child: Stack(
            children: [
              if (showHighlight && customGradient == null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: GlassTheme.glassHighlight,
                      ),
                    ),
                  ),
                ),
              if (customGradient != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: customGradient,
                      ),
                    ),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );

    if (showShadow) {
      content = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: GlassTheme.cardShadow(isDark: isDark),
        ),
        child: content,
      );
    } else if (margin != null) {
      content = Container(margin: margin, child: content);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}