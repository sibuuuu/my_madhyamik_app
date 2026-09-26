// lib/widgets/glass_dialog.dart
//
// Reusable glass dialogs, bottom sheets and snackbars.
// - GlassDialog        : standard popup dialog
// - GlassConfirmDialog : yes/no confirmation
// - GlassBottomSheet   : slide-up sheet
// - GlassSnackbar      : floating snackbar
// Developer: Sibnath Bairagi

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/glass_theme.dart';
import 'glass_button.dart';

// =====================================================================
// STANDARD GLASS DIALOG
// =====================================================================
class GlassDialog extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final Widget? child;
  final String? message;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final bool isDark;
  final Color? primaryColor;

  const GlassDialog({
    super.key,
    this.title,
    this.titleIcon,
    this.child,
    this.message,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.isDark = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark
        ? const Color(0xE6101010)
        : const Color(0xF2FFFFFF);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);
    final subClr = GlassTheme.textSecondary(isDark: isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassTheme.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GlassTheme.radiusXLarge),
              border: Border.all(color: borderClr, width: 1),
              boxShadow: GlassTheme.strongShadow(isDark: isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Row(
                    children: [
                      if (titleIcon != null) ...[
                        FaIcon(
                          titleIcon,
                          size: 16,
                          color: textClr,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            color: textClr,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                if (message != null)
                  Text(
                    message!,
                    style: TextStyle(
                      color: subClr,
                      fontSize: 14,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                if (child != null) child!,
                if (primaryLabel != null || secondaryLabel != null) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      if (secondaryLabel != null)
                        Expanded(
                          child: GlassOutlineButton(
                            label: secondaryLabel!,
                            onPressed:
                                onSecondary ?? () => Navigator.pop(context),
                            isDark: isDark,
                            height: 46,
                          ),
                        ),
                      if (secondaryLabel != null && primaryLabel != null)
                        const SizedBox(width: 10),
                      if (primaryLabel != null)
                        Expanded(
                          child: GlassPrimaryButton(
                            label: primaryLabel!,
                            onPressed:
                                onPrimary ?? () => Navigator.pop(context),
                            gradient: primaryColor != null
                                ? LinearGradient(
                                    colors: [
                                      primaryColor!,
                                      primaryColor!.withOpacity(0.85),
                                    ],
                                  )
                                : null,
                            height: 46,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// CONFIRM DIALOG — Yes/No
// =====================================================================
class GlassConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDark;
  final bool isDanger;

  const GlassConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDark = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: title,
      titleIcon: isDanger
          ? FontAwesomeIcons.triangleExclamation
          : FontAwesomeIcons.circleQuestion,
      message: message,
      primaryLabel: confirmLabel,
      secondaryLabel: cancelLabel,
      primaryColor: isDanger ? GlassTheme.accentRed : null,
      onPrimary: () {
        Navigator.pop(context);
        onConfirm();
      },
      onSecondary: () => Navigator.pop(context),
      isDark: isDark,
    );
  }
}

// =====================================================================
// LOADING DIALOG — spinner
// =====================================================================
class GlassLoadingDialog extends StatelessWidget {
  final String message;
  final bool isDark;

  const GlassLoadingDialog({
    super.key,
    this.message = 'Please wait...',
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark
        ? const Color(0xE6101010)
        : const Color(0xF2FFFFFF);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
              border: Border.all(color: borderClr, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(GlassTheme.accentBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    color: textClr,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
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
// GLASS BOTTOM SHEET — slide-up helper
// =====================================================================
class GlassBottomSheet {
  GlassBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDark = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GlassTheme.radiusXLarge),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xE6101010)
                  : const Color(0xF2FFFFFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(GlassTheme.radiusXLarge),
              ),
              border: Border(
                top: BorderSide(
                  color: GlassTheme.border(isDark: isDark),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grab handle
                Container(
                  height: 4,
                  width: 44,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: GlassTheme.textHint(isDark: isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// GLASS SNACKBAR — floating
// =====================================================================
class GlassSnackbar {
  GlassSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = FontAwesomeIcons.circleInfo,
    bool isDark = false,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final surface = isDark
        ? const Color(0xE61A1A1A)
        : const Color(0xF2FFFFFF);
    final borderClr = GlassTheme.border(isDark: isDark);
    final textClr = GlassTheme.textPrimary(isDark: isDark);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: const EdgeInsets.all(16),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius:
                      BorderRadius.circular(GlassTheme.radiusMedium),
                  border: Border.all(color: borderClr, width: 1),
                  boxShadow: GlassTheme.mediumShadow(isDark: isDark),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      icon,
                      size: 15,
                      color: iconColor ?? GlassTheme.accentBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textClr,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
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

  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FontAwesomeIcons.circleCheck,
      iconColor: GlassTheme.accentGreen,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FontAwesomeIcons.circleExclamation,
      iconColor: GlassTheme.accentRed,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: FontAwesomeIcons.triangleExclamation,
      iconColor: GlassTheme.accentAmber,
    );
  }
}