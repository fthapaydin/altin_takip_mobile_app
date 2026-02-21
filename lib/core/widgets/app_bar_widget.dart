import 'package:flutter/material.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

/// Centralized AppBar widget used across all screens.
///
/// Provides a consistent look-and-feel for the entire app.
/// Supports back navigation, custom leading, actions, bottom widgets,
/// and optionally a large title style.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool isLargeTitle;

  const AppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.bottom,
    this.isLargeTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (isLargeTitle ? 60.0 : kToolbarHeight) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      toolbarHeight: isLargeTitle ? 60.0 : kToolbarHeight,
      leading:
          leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(
                    Iconsax.arrow_left_2,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: showBack,
      actions: actions,
      bottom: bottom,
      title: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeTitle && !centerTitle ? 22 : 16,
              fontWeight: FontWeight.w500,
              letterSpacing: isLargeTitle ? -0.5 : -0.2,
            ),
          ),
          if (subtitle != null) const Gap(2),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
