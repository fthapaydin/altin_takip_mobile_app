import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altin_takip/features/auth/domain/user.dart';
import 'package:altin_takip/features/auth/data/user_dto.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _encryptionKey = 'encryption_key';
  static const _userKey = 'user_data';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveEncryptionKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_encryptionKey, key);
  }

  Future<String?> getEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_encryptionKey);
  }

  Future<void> clearEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_encryptionKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userDto = user is UserDto
        ? user
        : UserDto(
            id: user.id,
            name: user.name,
            surname: user.surname,
            email: user.email,
            isEncrypted: user.isEncrypted,
            oneSignalId: user.oneSignalId,
          );
    await prefs.setString(_userKey, jsonEncode(userDto.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserDto.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static const _assetOrderKey = 'asset_order';

  Future<void> saveAssetOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_assetOrderKey, order);
  }

  Future<List<String>?> getAssetOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_assetOrderKey);
  }

  static const _dashboardGoldOrderKey = 'dashboard_gold_order';
  static const _dashboardForexOrderKey = 'dashboard_forex_order';

  Future<void> saveDashboardGoldOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dashboardGoldOrderKey, order);
  }

  Future<List<String>?> getDashboardGoldOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dashboardGoldOrderKey);
  }

  Future<void> saveDashboardForexOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dashboardForexOrderKey, order);
  }

  Future<List<String>?> getDashboardForexOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dashboardForexOrderKey);
  }

  static const _useDynamicDateKey = 'use_dynamic_date';

  Future<void> saveUseDynamicDate(bool useDynamic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDynamicDateKey, useDynamic);
  }

  Future<bool> getUseDynamicDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useDynamicDateKey) ?? true;
  }

  static const _privacyModeKey = 'privacy_mode_enabled';

  Future<void> savePrivacyMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyModeKey, enabled);
  }

  Future<bool> getPrivacyMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyModeKey) ?? false;
  }

  Future<void> clearAssetOrdering() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assetOrderKey);
    await prefs.remove(_dashboardGoldOrderKey);
    await prefs.remove(_dashboardForexOrderKey);
  }
}
