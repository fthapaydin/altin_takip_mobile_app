import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:iconsax/iconsax.dart';

/// A widget that displays currency icons from either a URL (SVG) or falls back to Material icons
class CurrencyIcon extends StatelessWidget {
  final String? iconUrl;
  final bool isGold;
  final double size;
  final Color? color;

  const CurrencyIcon({
    super.key,
    this.iconUrl,
    required this.isGold,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.gold;

    // If we have a valid icon URL, try to load the image
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      Widget wrapWithContainer(Widget child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: ClipOval(clipBehavior: Clip.antiAlias, child: child),
        );
      }

      if (iconUrl!.toLowerCase().endsWith('.svg')) {
        return wrapWithContainer(
          SvgPicture.network(
            iconUrl!,
            fit: BoxFit.cover,
            placeholderBuilder: (context) => _buildLoadingState(effectiveColor),
          ),
        );
      } else {
        return wrapWithContainer(
          Image.network(
            iconUrl!,
            fit: BoxFit.cover,
            cacheWidth: (size * 3).toInt(),
            cacheHeight: (size * 3).toInt(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingState(effectiveColor);
            },
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackIcon(effectiveColor),
          ),
        );
      }
    }

    // Fallback to Material icons
    return _buildFallbackIcon(effectiveColor);
  }

  Widget _buildLoadingState(Color color) {
    return Center(
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: color.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Center(
        child: Icon(
          isGold ? Iconsax.magic_star : Iconsax.dollar_circle,
          size: size * 0.5,
          color: color,
        ),
      ),
    );
  }
}
