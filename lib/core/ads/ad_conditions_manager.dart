import '../storage/local_storage_service.dart';

/// 광고 표시 조건 관리 클래스
///
/// 전면광고 하루 최대 2회 제한 및 60초 간격 조건을 SharedPreferences에 저장합니다.
/// AdStateNotifier(Riverpod)와 독립적으로 동작하며 앱 재시작 간 상태를 유지합니다.
class AdConditionsManager {
  static final AdConditionsManager _instance = AdConditionsManager._internal();
  static AdConditionsManager get instance => _instance;
  factory AdConditionsManager() => _instance;
  AdConditionsManager._internal();

  final LocalStorageService _storage = LocalStorageService.instance;

  // ==================== 키 상수 ====================

  static const String _keyAdCount = 'ad_count';
  static const String _keyInterstitialDate = 'interstitial_date';
  static const String _keyInterstitialCount = 'interstitial_count';
  static const String _keyLastInterstitialTime = 'last_interstitial_time';

  // ==================== 매일타로 전면광고 조건 ====================

  static const int _kMaxDailyInterstitial = 2;
  static const int _kMinIntervalSeconds = 60;

  /// 전면광고 표시 가능 여부 확인
  ///
  /// - 오늘 날짜 기준 최대 2회
  /// - 마지막 광고로부터 최소 60초 경과
  Future<bool> canShowInterstitial() async {
    final today = _todayString();

    // 날짜별 카운트 확인
    final savedDate = await _storage.getString(_keyInterstitialDate);
    int count = 0;
    if (savedDate == today) {
      count = await _storage.getInt(_keyInterstitialCount) ?? 0;
    }

    if (count >= _kMaxDailyInterstitial) return false;

    // 마지막 광고 시각 확인
    final lastTimeMs = await _storage.getInt(_keyLastInterstitialTime);
    if (lastTimeMs != null) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - lastTimeMs;
      if (elapsed < _kMinIntervalSeconds * 1000) return false;
    }

    return true;
  }

  /// 전면광고 노출 기록
  Future<void> recordInterstitialShown() async {
    final today = _todayString();

    final savedDate = await _storage.getString(_keyInterstitialDate);
    int count = 0;
    if (savedDate == today) {
      count = await _storage.getInt(_keyInterstitialCount) ?? 0;
    }

    await _storage.setString(_keyInterstitialDate, today);
    await _storage.setInt(_keyInterstitialCount, count + 1);
    await _storage.setInt(
      _keyLastInterstitialTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ==================== 범용 광고 카운트 (구 인터페이스 유지) ====================

  /// 광고 카운트 증가
  Future<bool> incrementAdCount() async {
    try {
      final currentCount = await getAdCount();
      return await _storage.setInt(_keyAdCount, currentCount + 1);
    } catch (e) {
      return false;
    }
  }

  /// 현재 광고 카운트 가져오기
  Future<int> getAdCount() async {
    try {
      return await _storage.getInt(_keyAdCount) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 광고 카운트 리셋
  Future<bool> resetAdCount() async {
    try {
      return await _storage.setInt(_keyAdCount, 0);
    } catch (e) {
      return false;
    }
  }

  /// 광고 표시 여부 확인 (카운트 기반)
  Future<bool> shouldShowAd(int threshold) async {
    try {
      final count = await getAdCount();
      return count >= threshold;
    } catch (e) {
      return false;
    }
  }

  // ==================== 내부 유틸 ====================

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
