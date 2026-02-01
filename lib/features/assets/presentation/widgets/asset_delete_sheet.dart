import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';

class AssetDeleteSheet extends ConsumerStatefulWidget {
  final Asset asset;

  const AssetDeleteSheet({super.key, required this.asset});

  static void show(BuildContext context, Asset asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AssetDeleteSheet(asset: asset),
    );
  }

  @override
  ConsumerState<AssetDeleteSheet> createState() => _AssetDeleteSheetState();
}

class _AssetDeleteSheetState extends ConsumerState<AssetDeleteSheet> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.trash, color: Colors.red, size: 40),
          ),
          const Gap(24),
          const Text(
            'İşlemi Onayla',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Gap(12),
          Text(
            'Bu işlem geri alınamaz. "${widget.asset.currency!.isGold ? widget.asset.currency?.name : widget.asset.currency?.code}" kaydını silmek istediğinize emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Gap(32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Vazgeç'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final success = await ref
                              .read(assetProvider.notifier)
                              .deleteAsset(widget.asset.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (success) {
                              AppNotification.show(
                                context,
                                message: 'Kayıt silindi',
                                type: NotificationType.success,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Evet, Sil',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
          const Gap(16),
        ],
      ),
    );
  }
}
