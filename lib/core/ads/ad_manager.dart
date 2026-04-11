import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../supabase/supabase_client.dart';
import '../utils/logger.dart';

/// AdMob SDK 초기화 및 광고 ID 관리 클래스
///
/// AdMob SDK를 초기화하고, 플랫폼별 광고 ID를 관리합니다.
/// Supabase의 admob_ids 테이블에서 use_production 설정을 확인하여
/// 테스트/프로덕션 광고 ID를 동적으로 선택합니다.
class AdManager {
  static final AdManager _instance = AdManager._internal();
  static AdManager get instance => _instance;
  factory AdManager() => _instance;
  AdManager._internal();

  String? _prodAppId;
  String? _prodBannerAdId;
  String? _prodInterstitialAdId;
  String? _prodRewardedAdId;
  bool? _useProduction;

  /// ads_status에서 읽어온 광고 활성화 플래그
  bool _hasBannerAd = false;
  bool _hasInterstitialAd = false;

  /// 배너 광고 활성화 여부
  bool get hasBannerAd => _hasBannerAd;

  /// 전면 광고 활성화 여부
  bool get hasInterstitialAd => _hasInterstitialAd;

  static const String _kAppsTable = 'apps';
  static const String _kAdmobIdsTable = 'admob_ids';
  static const String _kAppId = 'daily_tarot';

  // Google 공식 테스트 광고 ID (Android)
  static const String _kTestAdmobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String _kTestBannerAdIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _kTestInterstitialAdIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _kTestRewardedAdIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  // Google 공식 테스트 광고 ID (iOS)
  static const String _kTestAdmobAppIdIOS = 'ca-app-pub-3940256099942544~1458002511';
  static const String _kTestBannerAdIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _kTestInterstitialAdIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _kTestRewardedAdIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  /// Supabase apps 테이블에서 ads_status 로드
  ///
  /// Supabase 미연결(로컬 fallback) 시 광고를 기본 활성화.
  Future<void> _loadAdsStatus() async {
    if (!SupabaseClientManager.isInitialized) {
      // Supabase 미연결 — 광고 활성화 (로컬 운영 모드)
      _hasBannerAd = true;
      _hasInterstitialAd = true;
      Logger.info('AdsStatus: Supabase 미연결 — 광고 기본 활성화');
      return;
    }

    try {
      final response = await SupabaseClientManager.client
          .from(_kAppsTable)
          .select('ads_status')
          .eq('app_id', _kAppId)
          .maybeSingle();

      if (response != null && response['ads_status'] != null) {
        final adsStatus = response['ads_status'] as Map<String, dynamic>;
        _hasBannerAd = adsStatus['hasBannerAd'] == true;
        _hasInterstitialAd = adsStatus['hasInterstitialAd'] == true;
        Logger.info('AdsStatus 로드: banner=$_hasBannerAd, interstitial=$_hasInterstitialAd');
      } else {
        _hasBannerAd = true;
        _hasInterstitialAd = true;
        Logger.info('AdsStatus: 설정 없음 — 광고 기본 활성화');
      }
    } catch (e) {
      _hasBannerAd = true;
      _hasInterstitialAd = true;
      Logger.error('AdsStatus 로드 실패, 광고 기본 활성화: $e');
    }
  }

  Future<void> _loadAdmobConfig() async {
    if (!SupabaseClientManager.isInitialized) {
      _loadEnvFallback();
      return;
    }

    try {
      final response = await SupabaseClientManager.client
          .from(_kAdmobIdsTable)
          .select()
          .eq('app_id', _kAppId)
          .maybeSingle();

      if (response != null && response['use_production'] == true) {
        _useProduction = true;
        _prodAppId = response['app_id_admob'] as String?;
        _prodBannerAdId = response['banner_ad_id'] as String?;
        _prodInterstitialAdId = response['interstitial_ad_id'] as String?;
        _prodRewardedAdId = response['rewarded_ad_id'] as String?;
        Logger.info('AdMob: 프로덕션 모드 활성화 (DB에서 로드)');
      } else {
        // DB에 use_production=false — .env fallback 시도
        _loadEnvFallback();
        Logger.info('AdMob: .env fallback 모드 (use_production=false 또는 설정 없음)');
      }
    } catch (e) {
      // DB 조회 실패 — .env fallback 사용
      _loadEnvFallback();
      Logger.error('AdMob: DB 조회 실패, .env fallback 사용: $e');
    }
  }

  /// .env에서 프로덕션 광고 ID 로드 (Supabase 미연결 시 fallback)
  void _loadEnvFallback() {
    final bannerFromEnv = dotenv.env['ADMOB_BANNER_ID_ANDROID'];
    final interstitialFromEnv = dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'];
    if (bannerFromEnv != null && bannerFromEnv.isNotEmpty) {
      _prodBannerAdId = bannerFromEnv;
      _prodInterstitialAdId = interstitialFromEnv;
      _useProduction = true;
      Logger.info('AdMob: .env에서 프로덕션 ID 로드 완료');
    } else {
      _useProduction = false;
      Logger.info('AdMob: .env에 프로덕션 ID 없음 — 테스트 ID 사용');
    }
  }

  /// AdMob 앱 ID
  String get appId {
    if (_useProduction == true && _prodAppId != null) {
      return _prodAppId!;
    }
    if (Platform.isAndroid) {
      return _kTestAdmobAppIdAndroid;
    } else if (Platform.isIOS) {
      return _kTestAdmobAppIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 배너 광고 ID
  String get bannerAdUnitId {
    if (_useProduction == true && _prodBannerAdId != null) {
      return _prodBannerAdId!;
    }
    if (Platform.isAndroid) {
      return _kTestBannerAdIdAndroid;
    } else if (Platform.isIOS) {
      return _kTestBannerAdIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 전면 광고 ID
  String get interstitialAdUnitId {
    if (_useProduction == true && _prodInterstitialAdId != null) {
      return _prodInterstitialAdId!;
    }
    if (Platform.isAndroid) {
      return _kTestInterstitialAdIdAndroid;
    } else if (Platform.isIOS) {
      return _kTestInterstitialAdIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 리워드 광고 ID
  String get rewardedAdUnitId {
    if (_useProduction == true && _prodRewardedAdId != null) {
      return _prodRewardedAdId!;
    }
    if (Platform.isAndroid) {
      return _kTestRewardedAdIdAndroid;
    } else if (Platform.isIOS) {
      return _kTestRewardedAdIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// AdMob SDK 초기화
  ///
  /// 앱 시작 시 한 번 호출해야 합니다.
  static Future<void> initialize() async {
    try {
      await instance._loadAdsStatus();
      await instance._loadAdmobConfig();

      if (instance._hasBannerAd || instance._hasInterstitialAd) {
        await MobileAds.instance.initialize();
        Logger.info('AdMob initialized (모드: ${instance._useProduction == true ? "프로덕션" : "테스트"})');
      } else {
        Logger.info('AdMob: 모든 광고 비활성화 상태, SDK 초기화 생략');
      }
    } catch (e) {
      Logger.error('AdMob initialization failed: $e');
    }
  }
}
