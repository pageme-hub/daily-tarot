// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Firebase 초기화 클래스
///
/// Firebase 서비스를 초기화합니다.
/// 주로 Crash 관리(Crashlytics)와 통계 관리(Analytics)에 사용됩니다.
///
/// Note: DB는 Supabase로 통일하며, Firebase는 Crash 관리와 통계 관리만 사용합니다.
///
/// TODO: 앱별 설정 — flutterfire configure 실행 후 firebase_options.dart 생성 필요
/// 명령어: flutterfire configure
class FirebaseInitializer {
  /// Firebase 초기화
  ///
  /// 앱 시작 시 한 번 호출해야 합니다.
  /// 초기화 실패 시에도 앱은 계속 실행됩니다.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.info('Firebase initialized');
    } catch (e) {
      Logger.error('Firebase initialization failed: $e');
    }
  }
}
