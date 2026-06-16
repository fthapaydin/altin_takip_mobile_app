import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/providers/scroll_state_provider.dart';


/// WhatsApp-style full-width liquid glass AppBar.
///
/// Renders a transparent header when scrolled to top on main screens.
/// For sub-screens (or when forced), it renders a permanent frosted glass panel
/// to prevent overlapping content.
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final bool isLargeTitle;
  final bool forceGlass;

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
    this.forceGlass = false,
  });

  // ── Heights ──
  static const double _expandedLargeH = 76.0;
  static const double _collapsedLargeH = 52.0;
  static const double _expandedNormalH = 60.0;
  static const double _collapsedNormalH = 48.0;

  double get _expandedH => isLargeTitle ? _expandedLargeH : _expandedNormalH;

  /// Helper to get the expanded height (excluding status bar) for content layout offsets.
  static double getExpandedHeight({bool isLargeTitle = false}) {
    return isLargeTitle ? _expandedLargeH : _expandedNormalH;
  }

  @override
  Size get preferredSize {
    final double bottomH = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(_expandedH + bottomH);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShrunk = ref.watch(scrollShrinkProvider);
    final double statusBarH = MediaQuery.of(context).padding.top;

    final double barH = isShrunk
        ? (isLargeTitle ? _collapsedLargeH : _collapsedNormalH)
        : _expandedH;
    final double bottomH = bottom?.preferredSize.height ?? 0;
    final double totalH = statusBarH + barH + bottomH;

    // Sub-screens (having a back button or leading icon) should always have a solid background
    // to prevent overlap and transparent background issues.
    final bool isSubScreen = showBack || leading != null;
    final bool showGlass = isShrunk || forceGlass || isSubScreen;
    final double blurSigma = showGlass ? 20.0 : 8.0;

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: totalH,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: blurSigma),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return value > 0.1
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                    child: child!,
                  )
                : child!;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: showGlass
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.12),
              border: Border(
                bottom: BorderSide(
                  color: showGlass
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.04),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                // ── Status bar zone ──
                SizedBox(height: statusBarH),

                // ── Main bar content ──
                Expanded(
                  child: _BarContent(
                    title: title,
                    subtitle: subtitle,
                    showBack: showBack,
                    leading: leading,
                    actions: actions,
                    centerTitle: centerTitle,
                    isLargeTitle: isLargeTitle,
                    isShrunk: isShrunk,
                  ),
                ),

                // ── Optional bottom widget (e.g. TabBar) ──
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Main bar content row — leading · title · actions
// ══════════════════════════════════════════════════════════════════════
class _BarContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool isLargeTitle;
  final bool isShrunk;

  const _BarContent({
    required this.title,
    this.subtitle,
    required this.showBack,
    this.leading,
    this.actions,
    required this.centerTitle,
    required this.isLargeTitle,
    required this.isShrunk,
  });

  @override
  Widget build(BuildContext context) {
    // ── Responsive sizes ──
    final double titleSize = isShrunk
        ? (isLargeTitle ? 18.0 : 16.0)
        : (isLargeTitle ? 26.0 : 18.0);
    final double subtitleSize = isShrunk ? 11.0 : 12.0;
    final double iconSize = isShrunk ? 18.0 : 20.0;
    final double hPadding = isShrunk ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Centered title block ──
          if (centerTitle)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: isShrunk ? -0.4 : -0.8,
                      height: 1.2,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null)
                    AnimatedCrossFade(
                      firstChild: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                      crossFadeState: isShrunk
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                ],
              ),
            ),

          // ── Leading + Title (left-aligned) + Actions row ──
          Row(
            children: [
              // Leading
              if (leading != null)
                leading!
              else if (showBack)
                AppBarBackButton(
                  size: iconSize,
                  onTap: () => Navigator.pop(context),
                ),

              if (!centerTitle) ...[
                if (showBack || leading != null) Gap(isShrunk ? 8 : 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: isShrunk ? -0.4 : -0.8,
                          height: 1.2,
                        ),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle != null)
                        AnimatedCrossFade(
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: isShrunk
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),

              // Actions
              if (actions != null) ...actions!,
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Clean borderless action button
// ══════════════════════════════════════════════════════════════════════
// Clean borderless action button with touch animations & glass backing
// ══════════════════════════════════════════════════════════════════════
class AppBarActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool hasBadge;
  final Color? badgeColor;

  const AppBarActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.hasBadge = false,
    this.badgeColor,
  });

  @override
  State<AppBarActionButton> createState() => _AppBarActionButtonState();
}

class _AppBarActionButtonState extends State<AppBarActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? Colors.white.withValues(alpha: 0.9);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.75 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  widget.icon,
                  color: color,
                  size: 19,
                ),
                if (widget.hasBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.badgeColor ?? const Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.badgeColor ?? const Color(0xFFFBBF24))
                                .withValues(alpha: 0.4),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
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

// ══════════════════════════════════════════════════════════════════════
// Clean borderless back button with touch animations & glass backing
// ══════════════════════════════════════════════════════════════════════
class AppBarBackButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const AppBarBackButton({super.key, required this.size, required this.onTap});

  @override
  State<AppBarBackButton> createState() => _AppBarBackButtonState();
}

class _AppBarBackButtonState extends State<AppBarBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.75 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
