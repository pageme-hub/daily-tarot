import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/ad_manager.dart';
import '../../../core/ads/interstitial_ad_service.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/providers/settings_provider.dart';

// ==================== 광고 상태 모델 ====================

class AdDisplayState {
  /// 오늘 전면 광고 표시 횟수
  final int todayInterstitialCount;

  /// 마지막 전면 광고 표시 시각
  final DateTime? lastInterstitialShownAt;

  const AdDisplayState({
    this.todayInterstitialCount = 0,
    this.lastInterstitialShownAt,
  });

  AdDisplayState copyWith({
    int? todayInterstitialCount,
    DateTime? lastInterstitialShownAt,
  }) {
    return AdDisplayState(
      todayInterstitialCount:
          todayInterstitialCount ?? this.todayInterstitialCount,
      lastInterstitialShownAt:
          lastInterstitialShownAt ?? this.lastInterstitialShownAt,
    );
  }
}

// ==================== Notifier ====================

/// 광고 표시 상태 관리 Notifier
///
/// - 전면 광고 하루 최대 2회 제한
/// - 전면 광고 간 최소 60초 간격
/// - 첫 실행(isFirstLaunch)이면 스플래시 광고 스킵
class AdStateNotifier extends StateNotifier<AdDisplayState> {
  static const int _kMaxDailyInterstitial = 2;
  static const int _kMinIntervalSeconds = 60;

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

  /// 카드 뽑기 전면 광고 표시 여부
  ///
  /// - 하루 최대 2회
  /// - 마지막 광고로부터 60초 이상 경과
  bool get shouldShowCardDrawAd {
    if (state.todayInterstitialCount >= _kMaxDailyInterstitial) {
      Logger.info('AdState: 오늘 최대 광고 횟수 초과 (${state.todayInterstitialCount}회)');
      return false;
    }

    final last = state.lastInterstitialShownAt;
    if (last != null) {
      final elapsed = DateTime.now().difference(last).inSeconds;
      if (elapsed < _kMinIntervalSeconds) {
        Logger.info('AdState: 광고 최소 간격 미달 ($elapsed초)');
        return false;
      }
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
    final canShow = isSplash ? shouldShowSplashAd : shouldShowCardDrawAd;

    if (!canShow) {
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
        onAdDismissed: () {
          callbackFired = true;
          _recordAdShown();
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

  /// 광고 표시 기록
  void _recordAdShown() {
    state = state.copyWith(
      todayInterstitialCount: state.todayInterstitialCount + 1,
      lastInterstitialShownAt: DateTime.now(),
    );
    Logger.info('AdState: 광고 표시 기록 (오늘 ${state.todayInterstitialCount}회)');
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
