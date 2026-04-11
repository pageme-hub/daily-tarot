// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 전역 에러 처리 및 로깅을 담당하는 싱글톤 클래스
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 에러 핸들러 초기화
  ///
  /// Flutter 에러와 플랫폼 에러를 모두 처리하도록 설정합니다.
  /// 앱 시작 시 main() 함수에서 호출해야 합니다.
  void setup() {
    try {
      FlutterError.onError = (FlutterErrorDetails details) {
        _handleError(
          error: details.exception,
          stackTrace: details.stack,
          context: details.context?.toString(),
          information: details.informationCollector?.call().join('\n'),
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        _handleError(error: error, stackTrace: stackTrace);
        return true;
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ErrorHandler setup failed: $e');
      }
    }
  }

  void _handleError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    String? information,
  }) {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('ERROR OCCURRED');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('Error: $error');
        if (context != null) {
          debugPrint('Context: $context');
        }
        if (information != null) {
          debugPrint('Information: $information');
        }
        if (stackTrace != null) {
          debugPrint('Stack Trace:');
          debugPrint('$stackTrace');
        }
        debugPrint('═══════════════════════════════════════════════════════════');
      } else {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: context ?? 'Unknown error',
          information: information != null ? [information] : [],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ErrorHandler failed to handle error: $e');
        debugPrint('Original error: $error');
      }
    }
  }

  /// 수동으로 에러를 기록하는 메서드
  void recordError(Object error, {StackTrace? stackTrace, String? reason}) {
    _handleError(error: error, stackTrace: stackTrace, context: reason);
  }
}
