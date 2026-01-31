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

    // Update local state from auth provider
    final authState = ref.watch(authProvider);
    if (authState is AuthAuthenticated) {
      _encryptionEnabled = authState.user.isEncrypted;
    } else if (authState is AuthEncryptionRequired) {
      _encryptionEnabled = authState.user.isEncrypted;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // User Profile Section
          _buildUserProfile(),
          const Gap(32),

          // Appearance Section
          _buildSectionHeader('Görünüm', Icons.visibility_outlined),
          const Gap(16),
          _buildSettingCard(
            icon: Icons.calendar_today_outlined,
            title: 'Tarih Formatı',
            subtitle: ref.watch(preferenceProvider).useDynamicDate
                ? 'Dinamik (5 dk önce)'
                : 'Standart (12 Ocak, 14:30)',
            trailing: Switch(
              value: ref.watch(preferenceProvider).useDynamicDate,
              onChanged: (val) =>
                  ref.read(preferenceProvider.notifier).toggleDynamicDate(val),
              activeColor: AppTheme.gold,
              activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
            ),
          ),
          const Gap(32),

          // Security Section
          _buildSectionHeader('Güvenlik', Icons.shield_outlined),
          const Gap(16),
          _buildSettingCard(
            icon: Icons.enhanced_encryption_outlined,
            title: 'Veri Şifreleme',
            subtitle: _encryptionEnabled
                ? 'Aktif - Verileriniz korunuyor'
                : 'Kapalı - Verileri şifrele',
            trailing: Switch(
              value: _encryptionEnabled,
              onChanged: isLoading ? null : (val) => _showEncryptionSheet(val),
              activeColor: AppTheme.gold,
              activeTrackColor: AppTheme.gold.withValues(alpha: 0.3),
            ),
            statusColor: _encryptionEnabled ? Colors.green : Colors.orange,
          ),
          const Gap(12),
          _buildSettingCard(
            icon: Icons.key_outlined,
            title: 'Şifre Değiştir',
            subtitle: 'Hesap şifrenizi güncelleyin',
            onTap: isLoading ? null : _showChangePasswordSheet,
          ),
          const Gap(32),

          // Account Section
          _buildSectionHeader('Hesap Yönetimi', Icons.person_outline),
          const Gap(16),
          _buildSettingCard(
            icon: Icons.logout_outlined,
            title: 'Çıkış Yap',
            subtitle: 'Güvenli bir şekilde oturumu kapatın',
            onTap: isLoading ? null : _showLogoutSheet,
          ),
          const Gap(12),
          _buildSettingCard(
            icon: Icons.delete_forever_outlined,
            title: 'Hesabı Sil',
            subtitle: 'Hesabınızı kalıcı olarak kaldırın',
            isDestructive: true,
            onTap: isLoading ? null : _showDeleteAccountSheet,
          ),
          const Gap(40),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'biriktirerek.com',
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
    );
  }

  Widget _buildUserProfile() {
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    final user = authState.user;
    final initials =
        (user.name.isNotEmpty && user.surname.isNotEmpty
                ? '${user.name[0]}${user.surname[0]}'
                : '')
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.gold.withOpacity(0.1),
            AppTheme.gold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 18),
        const Gap(8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
    Color? statusColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppTheme.gold).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.gold,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDestructive ? Colors.red : Colors.white,
                        ),
                      ),
                      if (statusColor != null) ...[
                        const Gap(8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.25),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _showEncryptionSheet(bool enable) {
    final passwordController = TextEditingController();
    final previousState = _encryptionEnabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(settingsProvider);
          final isLoading =
              state is SettingsLoading && state.operation == 'encryption';

          // Listen for state changes to close sheet on success or revert on error
          ref.listen<SettingsState>(settingsProvider, (prev, next) {
            if (next is SettingsSuccess &&
                (next.message.contains('Şifreleme') ||
                    next.message.contains('şifreleme'))) {
              Navigator.of(ctx).pop();
              setState(() => _encryptionEnabled = enable);
            } else if (next is SettingsError &&
                prev is SettingsLoading &&
                prev.operation == 'encryption') {
              // Revert the toggle on error
              setState(() => _encryptionEnabled = previousState);
            }
          });

          return PopScope(
            canPop: !isLoading,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            enable ? Icons.lock : Icons.lock_open,
                            color: AppTheme.gold,
                            size: 24,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Text(
                            enable
                                ? 'Şifrelemeyi Etkinleştir'
                                : 'Şifrelemeyi Kapat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (!isLoading)
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                      ],
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              enable
                                  ? 'Verilerinizi korumak için bir şifre belirleyin. Bu şifre olmadan verilerinize erişilemez.'
                                  : 'Şifrelemeyi kapatmak için mevcut şifrenizi girin.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: enable
                            ? 'Şifre belirleyin'
                            : 'Mevcut şifrenizi girin',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      ),
                    ),
                    const Gap(24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('İptal'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (passwordController.text.isEmpty) {
                                      AppNotification.show(
                                        ctx,
                                        message: 'Şifre boş olamaz',
                                        type: NotificationType.error,
                                      );
                                      return;
                                    }
                                    ref
                                        .read(settingsProvider.notifier)
                                        .toggleEncryption(
                                          enable: enable,
                                          password: passwordController.text,
                                        );
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(enable ? 'Etkinleştir' : 'Kapat'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.key,
                      color: AppTheme.gold,
                      size: 24,
                    ),
                  ),
                  const Gap(16),
                  const Expanded(
                    child: Text(
                      'Şifre Değiştir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(20),
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Mevcut Şifre',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                ),
              ),
              const Gap(12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Yeni Şifre',
                  prefixIcon: Icon(Icons.lock, size: 20),
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentController.text.isEmpty) {
                      AppNotification.show(
                        ctx,
                        message: 'Mevcut şifre boş olamaz',
                        type: NotificationType.error,
                      );
                      return;
                    }
                    if (newController.text.isEmpty) {
                      AppNotification.show(
                        ctx,
                        message: 'Yeni şifre boş olamaz',
                        type: NotificationType.error,
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ref
                        .read(settingsProvider.notifier)
                        .changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                        );
                  },
                  child: const Text('Şifreyi Güncelle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: AppTheme.gold, size: 32),
            ),
            const Gap(20),
            const Text(
              'Çıkış Yap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Gap(8),
            Text(
              'Oturumunuzu sonlandırmak istediğinize emin misiniz?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(settingsProvider.notifier).logout();
                    },
                    child: const Text('Çıkış Yap'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountSheet() {
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const Gap(20),
              const Text(
                'Hesabı Kalıcı Olarak Sil',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        'Bu işlem geri alınamaz! Tüm verileriniz ve işlem geçmişiniz kalıcı olarak silinecek.',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Onaylamak için şifrenizi girin',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Vazgeç'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (passwordController.text.isEmpty) {
                          AppNotification.show(
                            ctx,
                            message: 'Şifre gerekli',
                            type: NotificationType.error,
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        ref
                            .read(settingsProvider.notifier)
                            .deleteAccount(password: passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Hesabı Sil'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
