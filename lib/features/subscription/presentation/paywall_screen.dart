import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/subscription/presentation/subscription_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/object_wrappers.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);

    // Provide immediate feedback on purchase state changes if needed
    // e.g. Navigate back if premium became true
    ref.listen(subscriptionProvider, (previous, next) {
      if (next is SubscriptionLoaded && next.isPremium) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Premium'a hoşgeldiniz! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (next is SubscriptionLoaded && next.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${next.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black, // Oled black
      body: Stack(
        children: [
          // Background Effect
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.gold,
                    blurRadius: 150,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Gap(20),

                  // Header
                  const Icon(
                    Iconsax.crown, // Or any premium icon
                    size: 48,
                    color: AppTheme.gold,
                  ),
                  const Gap(16),
                  const Text(
                    'Altın Takip\nPREMIUM',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const Gap(32),

                  // Features List
                  Expanded(
                    child: Column(
                      children: [
                        _FeatureItem(
                          icon: Iconsax.chart_2,
                          title: 'Gelişmiş Grafikler',
                          description:
                              'Detaylı analizler ve sınırsız tarih aralığı.',
                        ),
                        const Gap(24),
                        _FeatureItem(
                          icon: Iconsax.unlimited,
                          title: 'Sınırsız Varlık',
                          description:
                              'Portföyüne dilediğin kadar varlık ekle.',
                        ),
                        const Gap(24),
                        _FeatureItem(
                          icon: Iconsax.shield_tick,
                          title: 'Reklamsız Deneyim',
                          description: 'Sadece verilerine odaklan, reklam yok.',
                        ),
                      ],
                    ),
                  ),

                  // Purchase Buttons
                  if (state is SubscriptionLoading)
                    const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    )
                  else if (state is SubscriptionLoaded) ...[
                    if (state.offerings.isEmpty)
                      Center(
                        child: Text(
                          'Şu an teklif bulunamadı.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    else
                      ...state.offerings.map((package) {
                        // Normally check package identifier context (monthly/yearly)
                        // For now just list them
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PurchaseButton(
                            package: package,
                            onTap: () => ref
                                .read(subscriptionProvider.notifier)
                                .purchasePackage(package),
                          ),
                        );
                      }),

                    const Gap(12),
                    Center(
                      child: Wrap(
                        spacing: 20,
                        children: [
                          TextButton(
                            onPressed: () => ref
                                .read(subscriptionProvider.notifier)
                                .restorePurchases(),
                            child: Text(
                              'Restore',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => ref
                                .read(subscriptionProvider.notifier)
                                .showNativePaywall(),
                            child: Text(
                              'Native Paywall',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.gold, size: 24),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Gap(4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final Package package;
  final VoidCallback onTap;

  const _PurchaseButton({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    // Format price, e.g. "₺199.99 / Yıllık"
    // Assuming product.priceString includes symbol

    // Determine title based on duration or explicit package id
    String period = '';
    if (package.packageType == PackageType.annual) period = '/ Yıllık';
    if (package.packageType == PackageType.monthly) period = '/ Aylık';
    if (package.packageType == PackageType.lifetime) period = '';

    String title = 'Abonelik';
    if (package.packageType == PackageType.annual) title = 'Yıllık Plan';
    if (package.packageType == PackageType.monthly) title = 'Aylık Plan';
    if (package.packageType == PackageType.lifetime) title = 'Ömür Boyu';

    // Fallback for custom identifiers if needed
    if (package.identifier == 'lifetime') {
      title = 'Ömür Boyu';
      period = '';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          // Gradient for Gold look
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFDE047),
              Color(0xFFEAB308),
            ], // Yellow-300 to Yellow-500
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (package.packageType == PackageType.annual)
                  const Text(
                    'En Popüler', // Tag
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            Text(
              '${product.priceString} $period',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
