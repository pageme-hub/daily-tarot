/// NotificationService 웹 스텁 — 웹에서는 로컬 알림 미지원
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {}
  Future<bool> requestAndroidPermission() async => false;
  Future<bool> requestIOSPermission() async => false;

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {}

  Future<void> cancelDailyNotification() async {}
  Future<void> createNotificationChannel() async {}
}
