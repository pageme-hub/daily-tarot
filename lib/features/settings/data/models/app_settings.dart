import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// 앱 설정 모델 — Hive 저장용
///
/// typeId: 2
@HiveType(typeId: 2)
class AppSettingsModel extends HiveObject {
  /// 매일 알림 ON/OFF
  @HiveField(0)
  final bool notificationEnabled;

  /// 알림 시간 — 시 (기본: 9)
  @HiveField(1)
  final int notificationHour;

  /// 알림 시간 — 분 (기본: 0)
  @HiveField(2)
  final int notificationMinute;

  /// "system" / "light" / "dark"
  @HiveField(3)
  final String themeMode;

  /// 첫 실행 여부 (스플래시 광고 스킵 판단)
  @HiveField(4)
  final bool isFirstLaunch;

  /// 알림 권한 요청 여부
  @HiveField(5)
  final bool hasRequestedNotificationPermission;

  /// 현재 적용 스킨 ID (기본: "default")
  @HiveField(6)
  final String activeSkinId;

  // typeId 3: (예약) SkinPurchaseCache
  // typeId 4: (예약) ActiveSkinCache

  AppSettingsModel({
    required this.notificationEnabled,
    required this.notificationHour,
    required this.notificationMinute,
    required this.themeMode,
    required this.isFirstLaunch,
    required this.hasRequestedNotificationPermission,
    required this.activeSkinId,
  });

  factory AppSettingsModel.defaultSettings() {
    return AppSettingsModel(
      notificationEnabled: false,
      notificationHour: 9,
      notificationMinute: 0,
      themeMode: 'system',
      isFirstLaunch: true,
      hasRequestedNotificationPermission: false,
      activeSkinId: 'default',
    );
  }

  AppSettingsModel copyWith({
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
    String? themeMode,
    bool? isFirstLaunch,
    bool? hasRequestedNotificationPermission,
    String? activeSkinId,
  }) {
    return AppSettingsModel(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      themeMode: themeMode ?? this.themeMode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      hasRequestedNotificationPermission: hasRequestedNotificationPermission ??
          this.hasRequestedNotificationPermission,
      activeSkinId: activeSkinId ?? this.activeSkinId,
    );
  }

  @override
  String toString() =>
      'AppSettingsModel(themeMode: $themeMode, skinId: $activeSkinId)';
}
