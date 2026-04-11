import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Firebase 초기화 클래스
///
/// Crashlytics 크래시 모니터링 전용.
/// DB는 Supabase, 광고는 AdMob을 사용하므로 Firebase는 Crashlytics만 활성화.
class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Crashlytics 설정
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      Logger.info('Firebase + Crashlytics initialized');
    } catch (e) {
      Logger.info('Firebase 초기화 실패 — 스킵: $e');
    }
  }
}
