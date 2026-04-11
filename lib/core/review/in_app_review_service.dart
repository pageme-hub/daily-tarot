// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 내 리뷰 요청 서비스
///
/// 조건: 5회 이상 실행 + 설치 후 3일 경과 + 미표시
///
/// TODO: 앱별 설정 — 임계값 조정 가능
///   _kMinLaunchCount: 최소 실행 횟수 (기본 5)
///   _kMinDaysSinceInstall: 설치 후 최소 경과 일수 (기본 3)
class InAppReviewService {
  InAppReviewService._();

  static const String _kLaunchCountKey = 'app_launch_count';
  static const String _kFirstLaunchKey = 'app_first_launch';
  static const String _kReviewShownKey = 'app_review_shown';

  // TODO: 앱별 설정 — 리뷰 요청 조건
  static const int _kMinLaunchCount = 5;
  static const int _kMinDaysSinceInstall = 3;

  /// 앱 실행 시 호출 — 카운터 증가 + 최초 설치일 기록
  static Future<void> recordLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_kFirstLaunchKey)) {
      await prefs.setString(_kFirstLaunchKey, DateTime.now().toIso8601String());
    }

    final count = (prefs.getInt(_kLaunchCountKey) ?? 0) + 1;
    await prefs.setInt(_kLaunchCountKey, count);
  }

  /// 조건 충족 시 리뷰 요청
  static Future<void> requestReviewIfEligible() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_kReviewShownKey) == true) return;

    final count = prefs.getInt(_kLaunchCountKey) ?? 0;
    if (count < _kMinLaunchCount) return;

    final firstLaunchStr = prefs.getString(_kFirstLaunchKey);
    if (firstLaunchStr == null) return;
    final firstLaunch = DateTime.tryParse(firstLaunchStr);
    if (firstLaunch == null) return;
    final daysSince = DateTime.now().difference(firstLaunch).inDays;
    if (daysSince < _kMinDaysSinceInstall) return;

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await prefs.setBool(_kReviewShownKey, true);
      debugPrint('InAppReview: review requested');
    }
  }

  /// 설정 화면에서 수동으로 스토어 열기
  static Future<void> openStoreListing() async {
    final inAppReview = InAppReview.instance;
    await inAppReview.openStoreListing();
  }
}
