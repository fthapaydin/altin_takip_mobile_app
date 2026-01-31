import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

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
      print('🎨 CurrencyIcon: Loading icon from URL: $iconUrl');

      // Check if it's an SVG (case-insensitive check)
      if (iconUrl!.toLowerCase().endsWith('.svg')) {
        print('🎨 CurrencyIcon: Detected SVG format');
        return ClipRRect(
          borderRadius: BorderRadius.circular(24), // Perfect circle
          child: SvgPicture.network(
            iconUrl!,
            width: size,
            height: size,
            // Don't apply color filter to SVGs - let them use their original colors
            fit: BoxFit.cover, // Fill the entire space
            placeholderBuilder: (context) {
              print('🎨 CurrencyIcon: SVG loading...');
              return SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: SizedBox(
                    width: size * 0.6,
                    height: size * 0.6,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: effectiveColor.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
      // Otherwise, treat it as a raster image (PNG, JPG, etc.)
      else {
        print('🎨 CurrencyIcon: Detected raster image format');
        return ClipRRect(
          borderRadius: BorderRadius.circular(24), // Perfect circle
          child: Image.network(
            iconUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover, // Fill the entire space
            cacheWidth: (size * 2).toInt(), // Cache at 2x for better quality
            cacheHeight: (size * 2).toInt(),
            // Don't apply color - let images use their original colors
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print('🎨 CurrencyIcon: Image loaded successfully');
                return child;
              }
              print('🎨 CurrencyIcon: Image loading progress...');
              return _buildFallbackIcon(effectiveColor);
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ CurrencyIcon: Error loading image from $iconUrl');
              print('❌ CurrencyIcon: Error details: $error');
              return _buildFallbackIcon(effectiveColor);
            },
          ),
        );
      }
    }

    print('🎨 CurrencyIcon: No icon URL provided, using fallback');
    // Fallback to Material icons
    return _buildFallbackIcon(effectiveColor);
  }

  Widget _buildFallbackIcon(Color color) {
    return Center(
      child: SizedBox(
        width: size * 0.6,
        height: size * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
