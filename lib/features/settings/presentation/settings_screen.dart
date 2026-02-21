import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/features/auth/presentation/auth_notifier.dart';
import 'package:altin_takip/features/auth/presentation/auth_state.dart';
import 'package:altin_takip/features/settings/presentation/settings_notifier.dart';
import 'package:altin_takip/features/settings/presentation/settings_state.dart';
import 'package:altin_takip/features/settings/presentation/preference_notifier.dart';
import 'package:altin_takip/features/assets/presentation/asset_notifier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:altin_takip/core/widgets/app_bar_widget.dart';
import 'package:altin_takip/features/settings/presentation/widgets/setting_card.dart';
import 'package:altin_takip/features/settings/presentation/widgets/section_header.dart';
import 'package:altin_takip/features/settings/presentation/widgets/encryption_sheet.dart';
import 'package:altin_takip/features/settings/presentation/widgets/change_password_sheet.dart';
import 'package:altin_takip/features/settings/presentation/widgets/logout_sheet.dart';
import 'package:altin_takip/features/settings/presentation/widgets/delete_account_sheet.dart';
import 'package:altin_takip/features/settings/presentation/widgets/reset_order_sheet.dart';
import 'package:altin_takip/features/calculator/presentation/calculator_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _encryptionEnabled = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      _encryptionEnabled = authState.user.isEncrypted;
    } else if (authState is AuthEncryptionRequired) {
      _encryptionEnabled = authState.user.isEncrypted;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SettingsState>(settingsProvider, (prev, next) {
      if (next is SettingsSuccess) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.success,
        );
        if (next.message == 'Çıkış yapıldı' ||
            next.message == 'Hesap silindi') {
          ref.read(authProvider.notifier).logout();
        }
        ref.read(settingsProvider.notifier).reset();
      } else if (next is SettingsError) {
        AppNotification.show(
          context,
          message: next.message,
          type: NotificationType.error,
        );
        ref.read(settingsProvider.notifier).reset();
      }
    });

    final state = ref.watch(settingsProvider);
    final isLoading = state is SettingsLoading;

    // Derive encryption state from auth provider without mutating during build
    final authState = ref.watch(authProvider);
    final encryptionEnabled = authState is AuthAuthenticated
        ? authState.user.isEncrypted
        : authState is AuthEncryptionRequired
        ? authState.user.isEncrypted
        : _encryptionEnabled;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AppBarWidget(
        title: 'Ayarlar',
        showBack: false,
        centerTitle: false,
        isLargeTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // ── Appearance ──
            const SectionHeader(title: 'Görünüm', icon: Iconsax.eye),
            const Gap(12),
            SettingCard(
              icon: Iconsax.eye_slash,
              title: 'Gizlilik Modu',
              subtitle: ref.watch(preferenceProvider).isPrivacyModeEnabled
                  ? 'Bakiyeler gizlendi'
                  : 'Bakiyeler görünür',
              trailing: Switch(
                value: ref.watch(preferenceProvider).isPrivacyModeEnabled,
                onChanged: (val) => ref
                    .read(preferenceProvider.notifier)
                    .togglePrivacyMode(val),
                activeColor: AppTheme.gold,
                activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
              ),
            ),
            const Gap(8),
            SettingCard(
              icon: Iconsax.calendar_1,
              title: 'Tarih Formatı',
              subtitle: ref.watch(preferenceProvider).useDynamicDate
                  ? 'Dinamik (5 dk önce)'
                  : 'Standart (12 Ocak, 14:30)',
              trailing: Switch(
                value: ref.watch(preferenceProvider).useDynamicDate,
                onChanged: (val) => ref
                    .read(preferenceProvider.notifier)
                    .toggleDynamicDate(val),
                activeColor: AppTheme.gold,
                activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
              ),
            ),
            const Gap(8),
            SettingCard(
              icon: Iconsax.setting_4,
              title: 'Sıralamayı Sıfırla',
              subtitle: 'Varlık sıralamasını varsayılana döndür',
              onTap: () => ResetOrderSheet.show(context),
            ),
            const Gap(24),

            // ── Security ──
            const SectionHeader(title: 'Güvenlik', icon: Iconsax.shield_tick),
            const Gap(12),
            SettingCard(
              icon: Iconsax.lock,
              title: 'Veri Şifreleme',
              subtitle: encryptionEnabled
                  ? 'Aktif - Verileriniz korunuyor'
                  : 'Kapalı - Verileri şifrele',
              trailing: Switch(
                value: encryptionEnabled,
                onChanged: isLoading
                    ? null
                    : (val) => EncryptionSheet.show(context, val, (enabled) {
                        setState(() => _encryptionEnabled = enabled);
                      }),
                activeColor: AppTheme.gold,
                activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
              ),
              statusColor: encryptionEnabled ? Colors.green : Colors.orange,
            ),
            const Gap(8),
            SettingCard(
              icon: Iconsax.key,
              title: 'Şifre Değiştir',
              subtitle: 'Hesap şifrenizi güncelleyin',
              onTap: isLoading ? null : () => ChangePasswordSheet.show(context),
            ),
            const Gap(24),

            // ── Maintenance ──
            const SectionHeader(
              title: 'Bakım & Destek',
              icon: Iconsax.setting_2,
            ),
            const Gap(12),
            SettingCard(
              icon: Iconsax.brush_1,
              title: 'Önbelleği Temizle',
              subtitle: 'Verileri yeniler, olası sorunları giderir',
              onTap: () {
                ref.invalidate(assetProvider);
                ref.read(assetProvider.notifier).loadDashboard(refresh: true);
                AppNotification.show(
                  context,
                  message: 'Önbellek temizlendi ve veriler yenileniyor.',
                  type: NotificationType.success,
                );
              },
            ),
            const Gap(8),
            SettingCard(
              icon: Iconsax.calculator,
              title: 'Hesaplama Araçları',
              subtitle: 'Dönüştürücü ve Kar/Zarar hesaplama',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculatorScreen()),
              ),
            ),
            const Gap(24),

            // ── Account ──
            const SectionHeader(title: 'Hesap Yönetimi', icon: Iconsax.user),
            const Gap(12),
            SettingCard(
              icon: Iconsax.logout,
              title: 'Çıkış Yap',
              subtitle: 'Güvenli bir şekilde oturumu kapatın',
              onTap: isLoading ? null : () => LogoutSheet.show(context),
            ),
            const Gap(8),
            SettingCard(
              icon: Iconsax.trash,
              title: 'Hesabı Sil',
              subtitle: 'Hesabınızı kalıcı olarak kaldırın',
              isDestructive: true,
              onTap: isLoading ? null : () => DeleteAccountSheet.show(context),
            ),
            const Gap(32),

            // ── App Info ──
            Center(
              child: Column(
                children: [
                  Text(
                    'altincuzdan.app',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
