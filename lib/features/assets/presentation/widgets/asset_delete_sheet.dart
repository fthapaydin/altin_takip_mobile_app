import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

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
  bool _isCancelPressed = false;
  bool _isConfirmPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1116),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          // Warning Emblem
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF87171).withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF87171).withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Iconsax.trash,
              color: Color(0xFFF87171),
              size: 36,
            ),
          ),
          const Gap(20),
          const Text(
            'İşlemi Onayla',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const Gap(12),
          Text(
            'Bu işlem geri alınamaz. "${widget.asset.currency!.isGold ? widget.asset.currency?.name : widget.asset.currency?.code}" kaydını silmek istediğinize emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const Gap(32),
          Row(
            children: [
              // Vazgeç Button
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isCancelPressed = true),
                  onTapUp: (_) => setState(() => _isCancelPressed = false),
                  onTapCancel: () => setState(() => _isCancelPressed = false),
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedScale(
                    scale: _isCancelPressed ? 0.96 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedOpacity(
                      opacity: _isCancelPressed ? 0.8 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Vazgeç',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              // Evet, Sil Button
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isConfirmPressed = true),
                  onTapUp: (_) => setState(() => _isConfirmPressed = false),
                  onTapCancel: () => setState(() => _isConfirmPressed = false),
                  onTap: isLoading
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
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedScale(
                    scale: _isConfirmPressed ? 0.96 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedOpacity(
                      opacity: _isConfirmPressed ? 0.8 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF87171).withValues(alpha: 0.15),
                              const Color(0xFFF87171).withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF87171).withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFF87171),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Evet, Sil',
                                  style: TextStyle(
                                    color: Color(0xFFF87171),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
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
