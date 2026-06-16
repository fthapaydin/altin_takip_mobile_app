import 'package:flutter_riverpod/legacy.dart';

/// Global scroll state provider shared between MainShell and AppBarWidget.
///
/// When the user scrolls down on any main tab screen, the shell sets this
/// to `true`, causing all visible liquid-glass elements (bottom nav + app bar)
/// to shrink in unison. Scrolling back up (or reaching the top) resets it.
final scrollShrinkProvider = StateProvider<bool>((ref) => false);
