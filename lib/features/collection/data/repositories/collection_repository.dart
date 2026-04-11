import '../../../../core/hive/hive_boxes.dart';
import '../../../../core/utils/logger.dart';
import '../models/card_history.dart';

/// 카드 뽑기 이력 저장소
class CollectionRepository {
  /// 뽑은 카드 ID 집합 반환
  Set<int> getDrawnCardIds() {
    try {
      final box = HiveBoxes.cardHistoryBox;
      return box.values.map((h) => h.cardId).toSet();
    } catch (e) {
      Logger.error('CollectionRepository: 이력 로드 실패: $e');
      return {};
    }
  }

  /// 전체 이력 맵 반환 (cardId → CardHistory)
  Map<int, CardHistory> getAllHistory() {
    try {
      final box = HiveBoxes.cardHistoryBox;
      return {for (final h in box.values) h.cardId: h};
    } catch (e) {
      Logger.error('CollectionRepository: 전체 이력 로드 실패: $e');
      return {};
    }
  }
}
