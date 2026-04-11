// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:flutter/foundation.dart';

/// 로깅 유틸리티 클래스
///
/// 앱 전역에서 사용할 수 있는 로깅 기능을 제공합니다.
/// 개발 환경에서는 상세 로그를, 프로덕션 환경에서는 에러만 로그합니다.
class Logger {
  Logger._();

  /// 디버그 로그 출력 (개발 환경에서만)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[DEBUG] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[DEBUG] StackTrace: $stackTrace');
      }
    }
  }

  /// 정보 로그 출력 (개발 환경에서만)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  /// 경고 로그 출력
  static void warning(String message, [Object? error]) {
    debugPrint('[WARNING] $message');
    if (error != null) {
      debugPrint('[WARNING] Error: $error');
    }
  }

  /// 에러 로그 출력 (프로덕션 환경에서도 출력)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR] Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('[ERROR] StackTrace: $stackTrace');
    }

    // TODO: Firebase Crashlytics 연동 시 아래 주석 해제
    // if (!kDebugMode && error != null) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }
}
