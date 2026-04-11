import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/ad_conditions_manager.dart';
import '../../../core/ads/ad_manager.dart';
import '../../../core/ads/interstitial_ad_service.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/providers/settings_provider.dart';

// ==================== 광고 상태 모델 ====================

class AdDisplayState {
  const AdDisplayState();
}

// ==================== Notifier ====================

/// 광고 표시 상태 관리 Notifier
///
/// - 전면 광고 하루 최대 2회 제한 (SharedPreferences 영속 저장 — 앱 재시작 후에도 유지)
/// - 전면 광고 간 최소 60초 간격
/// - 첫 실행(isFirstLaunch)이면 스플래시 광고 스킵
class AdStateNotifier extends StateNotifier<AdDisplayState> {
  final Ref _ref;

  AdStateNotifier(this._ref) : super(const AdDisplayState());

  /// 스플래시 전면 광고 표시 여부
  ///
  /// isFirstLaunch == true이면 false (마케팅 브리핑: 첫 실행 시 광고 스킵)
  bool get shouldShowSplashAd {
    final settings = _ref.read(settingsProvider);
    if (settings.isFirstLaunch) {
      Logger.info('AdState: 첫 실행 → 스플래시 광고 스킵');
      return false;
    }
    return true;
  }

  /// 전면 광고 표시 (조건 만족 시)
  ///
  /// [onCompleted]: 광고 완료(닫힘) 후 실행할 콜백
  /// 광고가 없거나 조건 미충족 시 즉시 [onCompleted] 호출.
  Future<void> showInterstitialAd({
    required void Function() onCompleted,
    bool isSplash = false,
  }) async {
    // 스플래시 광고는 첫 실행 여부만 확인
    if (isSplash && !shouldShowSplashAd) {
      onCompleted();
      return;
    }

    // AdConditionsManager(SharedPreferences)로 하루 2회 / 60초 간격 확인
    final canShow = await AdConditionsManager.instance.canShowInterstitial();
    if (!canShow) {
      Logger.info('AdState: 광고 표시 조건 미충족 (일일 2회 제한 또는 60초 간격 미달)');
      onCompleted();
      return;
    }

    // 광고 로드되지 않은 경우 바로 이동
    if (!AdManager.instance.hasInterstitialAd) {
      onCompleted();
      return;
    }

    try {
      bool callbackFired = false;

      await InterstitialAdService.instance.showAd(
        onAdDismissed: () async {
          callbackFired = true;
          // SharedPreferences에 노출 기록 (앱 재시작 후에도 유지)
          await AdConditionsManager.instance.recordInterstitialShown();
          Logger.info('AdState: 전면광고 노출 기록 완료');
          onCompleted();
        },
      );

      // showAd가 광고 미로드 시 콜백 없이 반환하는 경우 안전 처리
      if (!callbackFired) {
        onCompleted();
      }
    } catch (e) {
      Logger.error('AdState: 전면 광고 표시 실패: $e');
      onCompleted();
    }
  }
}

// ==================== Provider ====================

final adStateProvider =
    StateNotifierProvider<AdStateNotifier, AdDisplayState>(
  (ref) => AdStateNotifier(ref),
);

/// 스플래시 전면 광고 표시 여부 Provider (편의용)
final shouldShowSplashAdProvider = Provider<bool>((ref) {
  return ref.watch(adStateProvider.notifier).shouldShowSplashAd;
});
