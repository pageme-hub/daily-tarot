import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'supabase_client.dart';
import '../utils/logger.dart';

/// 공통 Supabase 테이블 조회 Repository
///
/// 조회 대상: apps, admob_ids, app_popups
/// 오프라인 대응:
/// - 최초 fetch 성공 시 Hive에 캐싱
/// - 이후 네트워크 실패 시 캐시 사용
/// - Supabase 미초기화 시 null 반환 (앱 크래시 방지)
class AppConfigRepository {
  static const String _kAppId = 'daily_tarot';
  static const String _kAppsTable = 'apps';
  static const String _kAppPopupsTable = 'app_popups';

  // Hive 캐시 Box 이름 (HiveBoxes에 등록하지 않고 별도 raw Box 사용)
  static const String _kCacheBoxName = 'app_config_cache';
  static const String _kPrivacyUrlKey = 'privacy_url';
  static const String _kTermsUrlKey = 'terms_url';
  static const String _kPopupsKey = 'active_popups';

  Box<String>? _cacheBox;

  /// 캐시 Box 초기화 (필요 시 자동)
  Future<Box<String>> _getBox() async {
    if (_cacheBox != null && _cacheBox!.isOpen) return _cacheBox!;
    try {
      _cacheBox = await Hive.openBox<String>(_kCacheBoxName);
    } catch (e) {
      Logger.error('AppConfigRepository: 캐시 Box 열기 실패: $e');
      rethrow;
    }
    return _cacheBox!;
  }

  // ==================== 팝업 ====================

  /// 활성 팝업 조회 (공지, 업데이트, 교차 홍보)
  ///
  /// Supabase 실패 시 Hive 캐시에서 반환.
  Future<List<Map<String, dynamic>>> fetchActivePopups() async {
    if (SupabaseClientManager.isInitialized) {
      try {
        final response = await SupabaseClientManager.client
            .from(_kAppPopupsTable)
            .select()
            .eq('app_id', _kAppId)
            .eq('is_active', true)
            .order('priority', ascending: false)
            .timeout(const Duration(seconds: 5));

        final popups = (response as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        // 캐싱
        final box = await _getBox();
        await box.put(_kPopupsKey, json.encode(popups));
        Logger.info('AppConfigRepository: 팝업 ${popups.length}건 로드 및 캐싱');
        return popups;
      } catch (e) {
        Logger.error('AppConfigRepository: 팝업 조회 실패: $e');
      }
    }

    // 캐시 fallback
    return await _getCachedPopups();
  }

  Future<List<Map<String, dynamic>>> _getCachedPopups() async {
    try {
      final box = await _getBox();
      final cached = box.get(_kPopupsKey);
      if (cached != null) {
        final list = json.decode(cached) as List<dynamic>;
        Logger.info('AppConfigRepository: 팝업 캐시에서 로드');
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      Logger.error('AppConfigRepository: 팝업 캐시 로드 실패: $e');
    }
    return [];
  }

  // ==================== 개인정보처리방침 ====================

  /// 개인정보처리방침 URL 조회
  ///
  /// Supabase apps 테이블의 app_privacy 컬럼에서 조회.
  /// 실패 시 Hive 캐시 또는 null 반환.
  Future<String?> fetchPrivacyUrl() async {
    if (SupabaseClientManager.isInitialized) {
      try {
        final response = await SupabaseClientManager.client
            .from(_kAppsTable)
            .select('app_privacy')
            .eq('app_id', _kAppId)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));

        final url = response?['app_privacy'] as String?;
        if (url != null && url.isNotEmpty) {
          final box = await _getBox();
          await box.put(_kPrivacyUrlKey, url);
          Logger.info('AppConfigRepository: 개인정보처리방침 URL 로드 및 캐싱');
          return url;
        }
      } catch (e) {
        Logger.error('AppConfigRepository: 개인정보처리방침 URL 조회 실패: $e');
      }
    }

    return await _getCachedUrl(_kPrivacyUrlKey);
  }

  // ==================== 이용약관 ====================

  /// 이용약관 URL 조회
  ///
  /// Supabase apps 테이블의 app_terms 컬럼에서 조회.
  /// 실패 시 Hive 캐시 또는 null 반환.
  Future<String?> fetchTermsUrl() async {
    if (SupabaseClientManager.isInitialized) {
      try {
        final response = await SupabaseClientManager.client
            .from(_kAppsTable)
            .select('app_terms')
            .eq('app_id', _kAppId)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));

        final url = response?['app_terms'] as String?;
        if (url != null && url.isNotEmpty) {
          final box = await _getBox();
          await box.put(_kTermsUrlKey, url);
          Logger.info('AppConfigRepository: 이용약관 URL 로드 및 캐싱');
          return url;
        }
      } catch (e) {
        Logger.error('AppConfigRepository: 이용약관 URL 조회 실패: $e');
      }
    }

    return await _getCachedUrl(_kTermsUrlKey);
  }

  Future<String?> _getCachedUrl(String key) async {
    try {
      final box = await _getBox();
      final cached = box.get(key);
      if (cached != null && cached.isNotEmpty) {
        Logger.info('AppConfigRepository: $key 캐시에서 로드');
        return cached;
      }
    } catch (e) {
      Logger.error('AppConfigRepository: $key 캐시 로드 실패: $e');
    }
    return null;
  }
}
