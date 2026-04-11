import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';
import '../utils/logger.dart';
import '../../shared/constants/app_constants.dart';

/// 전면 광고 로드 및 표시 서비스
///
/// 전면 광고를 미리 로드하고 표시하는 기능을 제공합니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용합니다.
class InterstitialAdService {
  static final InterstitialAdService _instance = InterstitialAdService._internal();
  static InterstitialAdService get instance => _instance;
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// 광고 미리 로드
  Future<void> loadAd() async {
    // 스크린샷 모드(디버그 전용)이면 로드 생략
    if (kDebugMode && AppConstants.kScreenshotMode) return;
    if (!AdManager.instance.hasInterstitialAd) return;
    if (_isLoading || _interstitialAd != null) {
      return;
    }

    _isLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: AdManager.instance.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                loadAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                Logger.error('InterstitialAd failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
                _isLoading = false;
                loadAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            Logger.error('InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      Logger.error('InterstitialAd load error: $e');
      _isLoading = false;
    }
  }

  /// 광고 표시
  ///
  /// [onAdDismissed]: 광고가 닫힌 후 실행할 콜백
  Future<void> showAd({VoidCallback? onAdDismissed}) async {
    // 스크린샷 모드(디버그 전용)이면 광고 표시 생략하고 콜백만 실행
    if (kDebugMode && AppConstants.kScreenshotMode) {
      onAdDismissed?.call();
      return;
    }
    if (!AdManager.instance.hasInterstitialAd) {
      onAdDismissed?.call();
      return;
    }
    if (_interstitialAd == null) {
      loadAd();
      onAdDismissed?.call();
      return;
    }

    try {
      final originalCallback = _interstitialAd!.fullScreenContentCallback;
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          originalCallback?.onAdDismissedFullScreenContent?.call(ad);
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: originalCallback?.onAdFailedToShowFullScreenContent,
      );

      await _interstitialAd!.show();
    } catch (e) {
      Logger.error('InterstitialAd show error: $e');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      loadAd();
    }
  }

  /// 리소스 해제
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoading = false;
  }
}
