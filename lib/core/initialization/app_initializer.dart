import 'package:hive_flutter/hive_flutter.dart';
import '../error/error_handler.dart';
import '../hive/hive_boxes.dart';
import '../storage/local_storage_service.dart';
import '../supabase/supabase_client.dart';
import '../firebase/firebase_initializer.dart';
import '../ads/ad_manager.dart';
import '../ads/interstitial_ad_service.dart';
import '../notifications/notification_service.dart';
import '../utils/logger.dart';

/// 앱 초기화 순서 관리 클래스
///
/// main.dart에서 runApp() 이전에 호출합니다.
/// 각 단계는 독립적으로 실패를 처리하므로 일부 실패해도 앱은 계속 실행됩니다.
class AppInitializer {
  static Future<void> initialize() async {
    Logger.info('═══════════════════════════════════════');
    Logger.info('매일타로 App Initialization Started');
    Logger.info('═══════════════════════════════════════');

    // 1. ErrorHandler 설정
    try {
      ErrorHandler().setup();
      Logger.info('[1/7] ✓ ErrorHandler setup completed');
    } catch (e) {
      Logger.error('[1/7] ✗ ErrorHandler setup failed: $e');
    }

    // 2. Hive 초기화
    try {
      await Hive.initFlutter();
      Logger.info('[2/7] ✓ Hive initialized');
    } catch (e) {
      Logger.error('[2/7] ✗ Hive initialization failed: $e');
    }

    // 2-B. Hive Box 등록 및 오픈 (타로 모델 어댑터 포함)
    try {
      await HiveBoxes.init();
      Logger.info('[2B/7] ✓ HiveBoxes initialized');
    } catch (e) {
      Logger.error('[2B/7] ✗ HiveBoxes initialization failed: $e');
    }

    // 3. LocalStorageService 초기화
    try {
      await LocalStorageService.instance.init();
      Logger.info('[3/7] ✓ LocalStorageService initialized');
    } catch (e) {
      Logger.error('[3/7] ✗ LocalStorageService initialization failed: $e');
    }

    // 4. Supabase 초기화 (미생성 시 로컬 fallback으로 동작)
    try {
      await SupabaseClientManager.initialize();
      Logger.info('[4/7] ✓ Supabase initialized (connected: ${SupabaseClientManager.isInitialized})');
    } catch (e) {
      Logger.error('[4/7] ✗ Supabase initialization failed: $e');
    }

    // 5. Firebase 초기화
    // NOTE: flutterfire configure 실행 후 firebase_options.dart 생성 필요
    try {
      await FirebaseInitializer.initialize();
      Logger.info('[5/7] ✓ Firebase initialized');
    } catch (e) {
      Logger.error('[5/7] ✗ Firebase initialization failed (비필수): $e');
    }

    // 6. AdMob 초기화 (.env에서 광고 ID 로드)
    try {
      await AdManager.initialize();
      Logger.info('[6/7] ✓ AdMob initialized');
    } catch (e) {
      Logger.error('[6/7] ✗ AdMob initialization failed: $e');
    }

    // 7. 전면 광고 미리 로드
    try {
      await InterstitialAdService.instance.loadAd();
      Logger.info('[7/8] ✓ Interstitial ad loaded');
    } catch (e) {
      Logger.error('[7/8] ✗ Interstitial ad loading failed: $e');
    }

    // 8. 로컬 알림 서비스 초기화
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.createNotificationChannel();
      Logger.info('[8/8] ✓ NotificationService initialized');
    } catch (e) {
      Logger.error('[8/8] ✗ NotificationService initialization failed: $e');
    }

    Logger.info('═══════════════════════════════════════');
    Logger.info('매일타로 App Initialization Completed');
    Logger.info('═══════════════════════════════════════');
  }
}
