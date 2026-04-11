import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

/// 테마 모드 Provider
///
/// SettingsNotifier의 themeMode 문자열에서 ThemeMode를 파생합니다.
/// ThemeModeNotifier를 별도로 두지 않아 이중 관리를 방지합니다.
///
/// 사용 예시:
/// ```dart
/// final themeMode = ref.watch(themeModeProvider);
/// MaterialApp(themeMode: themeMode, ...)
/// ```
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(settingsProvider).themeMode;
  return switch (themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});
