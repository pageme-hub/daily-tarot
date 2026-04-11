// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';
import '../utils/logger.dart';

/// 리워드 광고 로드 및 표시 서비스
///
/// 리워드 광고를 미리 로드하고 표시하는 기능을 제공합니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용합니다.
class RewardedAdService {
  RewardedAdService._();
  static final RewardedAdService instance = RewardedAdService._();

  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  /// 광고 미리 로드
  Future<void> loadAd() async {
    await RewardedAd.load(
      adUnitId: AdManager.instance.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
          Logger.info('RewardedAd loaded');
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          Logger.error('RewardedAd failed to load: ${error.message}');
        },
      ),
    );
  }

  /// 광고 표시
  ///
  /// [onRewarded]: 리워드 지급 시 호출되는 콜백
  /// [onAdDismissed]: 광고가 닫힌 후 실행할 콜백 (선택)
  /// 반환값: 실제 광고가 표시되었으면 true, 폴백으로 리워드 지급 시 false
  Future<bool> showAd({
    required void Function() onRewarded,
    void Function()? onAdDismissed,
  }) async {
    if (!_isLoaded || _rewardedAd == null) {
      Logger.info('RewardedAd not ready, granting reward anyway (fallback)');
      onRewarded();
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        loadAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isLoaded = false;
        loadAd();
        Logger.error('RewardedAd failed to show: ${error.message}');
        onRewarded(); // 광고 실패 시 관대하게 리워드 지급
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onRewarded(),
    );
    return true;
  }

  /// 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
  }
}
