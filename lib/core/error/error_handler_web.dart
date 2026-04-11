import 'package:flutter/foundation.dart';

/// ErrorHandler 웹 스텁 — Crashlytics 없이 콘솔 출력만
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  void setup() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        debugPrint('ERROR: ${details.exception}');
        if (details.stack != null) debugPrint('${details.stack}');
      }
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('PLATFORM ERROR: $error');
      }
      return true;
    };
  }

  void recordError(Object error, {StackTrace? stackTrace, String? reason}) {
    if (kDebugMode) {
      debugPrint('ERROR: $error (reason: $reason)');
    }
  }
}
