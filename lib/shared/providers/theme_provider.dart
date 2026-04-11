import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hive/hive_boxes.dart';
import '../../features/settings/data/models/app_settings.dart';

/// 테마 모드 Provider
///
/// AppSettingsModel(Hive)에서 테마 설정을 로드하여 관리.
/// 사용 예시:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// MaterialApp(themeMode: themeMode, ...)
/// ```
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadFromHive();
  }

  void _loadFromHive() {
    try {
      final box = HiveBoxes.appSettingsBox;
      final settings = box.get('settings') ?? AppSettingsModel.defaultSettings();
      state = _parseThemeMode(settings.themeMode);
    } catch (e) {
      // Hive 미초기화 시 system으로 fallback
      state = ThemeMode.system;
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> _saveToHive(ThemeMode mode) async {
    try {
      final box = HiveBoxes.appSettingsBox;
      final current = box.get('settings') ?? AppSettingsModel.defaultSettings();
      await box.put(
        'settings',
        current.copyWith(themeMode: _themeModeToString(mode)),
      );
    } catch (e) {
      debugPrint('[ThemeModeNotifier] Hive save failed: $e');
    }
  }

  /// 라이트 모드로 설정
  Future<void> setLight() async {
    state = ThemeMode.light;
    await _saveToHive(ThemeMode.light);
  }

  /// 다크 모드로 설정
  Future<void> setDark() async {
    state = ThemeMode.dark;
    await _saveToHive(ThemeMode.dark);
  }

  /// 시스템 설정 따르기
  Future<void> setSystem() async {
    state = ThemeMode.system;
    await _saveToHive(ThemeMode.system);
  }

  /// 테마 모드를 문자열로 설정 ("system" / "light" / "dark")
  Future<void> setThemeMode(String mode) async {
    final parsed = _parseThemeMode(mode);
    state = parsed;
    await _saveToHive(parsed);
  }
}
