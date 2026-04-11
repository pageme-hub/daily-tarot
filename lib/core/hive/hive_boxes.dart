import 'package:hive_flutter/hive_flutter.dart';
import '../../features/card/data/models/daily_card_cache.dart';
import '../../features/collection/data/models/card_history.dart';
import '../../features/settings/data/models/app_settings.dart';

/// Hive Box 초기화 및 접근 클래스
///
/// 앱에서 사용하는 모든 Hive Box를 중앙에서 관리합니다.
/// AppInitializer에서 Hive.initFlutter() 호출 후 init()을 실행합니다.
class HiveBoxes {
  HiveBoxes._();

  // ==================== Box 이름 상수 ====================

  static const String kDailyCardBox = 'daily_card_box';
  static const String kCardHistoryBox = 'card_history_box';
  static const String kAppSettingsBox = 'app_settings_box';

  // typeId 예약:
  // 0 — DailyCardCache
  // 1 — CardHistory
  // 2 — AppSettings
  // 3 — (예약) SkinPurchaseCache
  // 4 — (예약) ActiveSkinCache

  /// Hive 어댑터 등록 및 Box 열기
  static Future<void> init() async {
    // 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DailyCardCacheAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CardHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AppSettingsModelAdapter());
    }

    // Box 열기
    await Hive.openBox<DailyCardCache>(kDailyCardBox);
    await Hive.openBox<CardHistory>(kCardHistoryBox);
    await Hive.openBox<AppSettingsModel>(kAppSettingsBox);
  }

  // ==================== Box 접근 getter ====================

  /// 일일 카드 캐시 Box
  static Box<DailyCardCache> get dailyCardBox =>
      Hive.box<DailyCardCache>(kDailyCardBox);

  /// 카드 뽑기 이력 Box
  static Box<CardHistory> get cardHistoryBox =>
      Hive.box<CardHistory>(kCardHistoryBox);

  /// 앱 설정 Box
  static Box<AppSettingsModel> get appSettingsBox =>
      Hive.box<AppSettingsModel>(kAppSettingsBox);
}
