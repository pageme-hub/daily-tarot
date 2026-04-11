import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hive/hive_boxes.dart';
import '../../core/notifications/notification_service.dart';
import '../../features/settings/data/models/app_settings.dart';
import '../../core/utils/logger.dart';

/// 앱 설정 Provider
///
/// AppSettingsModel(Hive)을 기반으로 앱 전역 설정을 관리.
/// UI에서는 ref.watch, 이벤트 핸들러에서는 ref.read 사용.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsModel>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  static const String _kSettingsKey = 'settings';

  SettingsNotifier() : super(AppSettingsModel.defaultSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final box = HiveBoxes.appSettingsBox;
      final saved = box.get(_kSettingsKey);
      if (saved != null) {
        state = saved;
        Logger.info('SettingsNotifier: 설정 로드 완료 (themeMode: ${saved.themeMode})');
      }
    } catch (e) {
      Logger.error('SettingsNotifier: 설정 로드 실패 — 기본값 사용: $e');
    }
  }

  Future<void> _save(AppSettingsModel settings) async {
    try {
      await HiveBoxes.appSettingsBox.put(_kSettingsKey, settings);
    } catch (e) {
      Logger.error('SettingsNotifier: 저장 실패: $e');
    }
  }

  /// 알림 ON/OFF 토글
  Future<void> toggleNotification() async {
    final newEnabled = !state.notificationEnabled;
    final updated = state.copyWith(notificationEnabled: newEnabled);
    state = updated;
    await _save(updated);

    // 알림 서비스 연동
    if (newEnabled) {
      await NotificationService.instance.scheduleDailyNotification(
        hour: updated.notificationHour,
        minute: updated.notificationMinute,
      );
    } else {
      await NotificationService.instance.cancelDailyNotification();
    }
  }

  /// 알림 시간 변경
  Future<void> setNotificationTime(int hour, int minute) async {
    final updated = state.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    state = updated;
    await _save(updated);

    // 알림이 켜져 있으면 새 시간으로 재등록
    if (updated.notificationEnabled) {
      await NotificationService.instance.scheduleDailyNotification(
        hour: hour,
        minute: minute,
      );
    }
  }

  /// 테마 모드 변경 ("system" / "light" / "dark")
  Future<void> setThemeMode(String mode) async {
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    await _save(updated);
  }

  /// 첫 실행 완료 처리
  Future<void> markFirstLaunchDone() async {
    final updated = state.copyWith(isFirstLaunch: false);
    state = updated;
    await _save(updated);
  }

  /// 알림 권한 요청 완료 처리
  Future<void> markNotificationPermissionRequested() async {
    final updated = state.copyWith(hasRequestedNotificationPermission: true);
    state = updated;
    await _save(updated);
  }

  /// 활성 스킨 변경
  Future<void> setActiveSkin(String skinId) async {
    final updated = state.copyWith(activeSkinId: skinId);
    state = updated;
    await _save(updated);
  }
}
