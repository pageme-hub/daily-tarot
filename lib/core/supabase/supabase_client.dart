import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Supabase 클라이언트 초기화 및 싱글톤 제공
///
/// URL과 anonKey는 .env 파일에서 로드합니다.
/// Supabase 프로젝트가 미생성인 경우, URL/Key가 비어 있어도
/// 앱은 로컬 fallback 데이터로 정상 동작합니다.
class SupabaseClientManager {
  static SupabaseClientManager? _instance;
  static SupabaseClientManager get instance {
    _instance ??= SupabaseClientManager._();
    return _instance!;
  }

  SupabaseClientManager._();

  static bool _initialized = false;

  /// Supabase가 정상 초기화되었는지 여부
  static bool get isInitialized => _initialized;

  /// Supabase 초기화
  ///
  /// .env에 SUPABASE_URL, SUPABASE_ANON_KEY가 없으면 로컬 fallback으로 동작.
  static Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (url.isEmpty || anonKey.isEmpty) {
        if (kDebugMode) {
          debugPrint('[SupabaseClient] SUPABASE_URL or SUPABASE_ANON_KEY is empty — using local fallback');
        }
        _initialized = false;
        return;
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _initialized = true;
      Logger.info('Supabase initialized successfully');
    } catch (e) {
      _initialized = false;
      Logger.error('Supabase initialization failed: $e');
    }
  }

  /// Supabase 클라이언트 반환
  ///
  /// isInitialized가 false인 경우 사용 시 예외가 발생할 수 있습니다.
  static get client => Supabase.instance.client;
}

// 하위 호환성을 위한 alias
// ignore: non_constant_identifier_names
SupabaseClientManager get SupabaseClient => SupabaseClientManager.instance;
