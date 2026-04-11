// features/settings/providers/settings_provider.dart
//
// shared/providers/settings_provider.dart를 re-export하고
// features 전용 Provider를 여기서 추가 관리.
//
// 역할 분리:
// - shared/providers/settings_provider.dart : SettingsNotifier (상태관리 로직)
// - features/settings/providers/settings_provider.dart : re-export + 추가 편의 Provider

export '../../../shared/providers/settings_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/settings_provider.dart';

/// 테마 모드 문자열 Provider (설정 화면 표시용)
final themeModeStringProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeMode) {
    case 'light':
      return '라이트';
    case 'dark':
      return '다크';
    default:
      return '시스템';
  }
});

/// 알림 활성화 여부 Provider
final notificationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationEnabled;
});

/// 현재 스킨 ID Provider
final activeSkinIdProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).activeSkinId;
});
