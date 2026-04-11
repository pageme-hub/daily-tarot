/// AdManager 웹 스텁 — 웹에서는 AdMob 미지원
class AdManager {
  static final AdManager _instance = AdManager._internal();
  static AdManager get instance => _instance;
  factory AdManager() => _instance;
  AdManager._internal();

  bool get hasBannerAd => false;
  bool get hasInterstitialAd => false;

  String get appId => '';
  String get bannerAdUnitId => '';
  String get interstitialAdUnitId => '';
  String get rewardedAdUnitId => '';

  static Future<void> initialize() async {}
}
