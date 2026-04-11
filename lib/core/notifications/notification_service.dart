import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';

/// 로컬 알림 서비스 — 매일 타로 알림 스케줄링
///
/// 알림 채널: "daily_tarot"
/// 알림 제목: "매일타로"
/// 알림 내용: "오늘의 카드가 당신을 기다리고 있어요"
/// 알림 탭 시 앱 실행
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _kDailyNotificationId = 1001;
  static const String _kChannelId = 'daily_tarot';
  static const String _kChannelName = '매일 타로 알림';
  static const String _kChannelDesc = '매일 오늘의 타로 카드 알림';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 초기화 — AppInitializer에서 호출
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // 한국 시간대 설정
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    Logger.info('NotificationService: 초기화 완료');
  }

  /// 알림 탭 처리 — 앱이 이미 실행 중이면 홈으로 이동
  void _onNotificationTap(NotificationResponse response) {
    Logger.info('NotificationService: 알림 탭 (payload: ${response.payload})');
    // 앱이 백그라운드/종료 상태에서 탭 시 자동으로 앱이 실행됨
    // 추가 딥링크 처리가 필요하면 GoRouter로 이동
  }

  /// Android 알림 권한 요청 (Android 13+)
  Future<bool> requestAndroidPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  /// iOS 알림 권한 요청
  Future<bool> requestIOSPermission() async {
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin == null) return true;
    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  /// 매일 반복 알림 등록
  ///
  /// [hour]: 시 (0~23)
  /// [minute]: 분 (0~59)
  /// 기존 알림을 취소하고 새 시간으로 재등록
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    // 기존 알림 취소
    await cancelDailyNotification();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 오늘 시간이 지났으면 내일로
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      _kDailyNotificationId,
      '매일타로',
      '오늘의 카드가 당신을 기다리고 있어요',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      payload: 'daily_card',
    );

    Logger.info(
      'NotificationService: 매일 ${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')} 알림 등록 완료',
    );
  }

  /// 매일 반복 알림 취소
  Future<void> cancelDailyNotification() async {
    if (!_initialized) await initialize();
    await _plugin.cancel(_kDailyNotificationId);
    Logger.info('NotificationService: 알림 취소 완료');
  }

  /// 알림 채널 생성 (Android 8+)
  Future<void> createNotificationChannel() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
    );
    await androidPlugin.createNotificationChannel(channel);
    Logger.info('NotificationService: 알림 채널 생성 완료');
  }
}
