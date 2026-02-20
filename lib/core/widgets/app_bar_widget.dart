import 'package:flutter/material.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

/// Centralized AppBar widget used across all screens.
///
/// Provides a consistent look-and-feel for the entire app.
/// Supports back navigation, custom leading, actions, and bottom widgets.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showBack = true,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading ?? (showBack ? const BackButton() : null),
      automaticallyImplyLeading: showBack,
      actions: actions,
      bottom: bottom,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
