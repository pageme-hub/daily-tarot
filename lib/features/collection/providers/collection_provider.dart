import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/card_history.dart';
import '../data/repositories/collection_repository.dart';
import '../../card/data/models/tarot_card.dart';
import '../../card/providers/card_data_provider.dart';

// ==================== 필터 Enum ====================

enum CollectionFilter { all, major, wands, cups, swords, pentacles }

extension CollectionFilterLabel on CollectionFilter {
  String get label {
    switch (this) {
      case CollectionFilter.all:
        return '전체';
      case CollectionFilter.major:
        return '메이저';
      case CollectionFilter.wands:
        return '완드';
      case CollectionFilter.cups:
        return '컵';
      case CollectionFilter.swords:
        return '소드';
      case CollectionFilter.pentacles:
        return '펜타클';
    }
  }
}

// ==================== Repository Provider ====================

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepository(),
);

// ==================== 카드 이력 Provider ====================

/// 뽑은 카드 ID Set Provider
///
/// 도감에서 컬러/흑백 표시에 사용.
/// 카드 뽑기 완료 후 ref.invalidate(cardHistoryProvider)로 갱신.
final cardHistoryProvider = Provider<Set<int>>((ref) {
  final repository = ref.read(collectionRepositoryProvider);
  return repository.getDrawnCardIds();
});

/// 전체 이력 맵 Provider (cardId → CardHistory)
final cardHistoryMapProvider = Provider<Map<int, CardHistory>>((ref) {
  final repository = ref.read(collectionRepositoryProvider);
  return repository.getAllHistory();
});

// ==================== 필터 Provider ====================

/// 현재 선택된 도감 필터
final collectionFilterProvider =
    StateProvider<CollectionFilter>((ref) => CollectionFilter.all);

// ==================== 필터링된 카드 목록 Provider ====================

/// 필터에 따라 카드 목록 반환
final filteredCardsProvider = Provider<AsyncValue<List<TarotCard>>>((ref) {
  final filter = ref.watch(collectionFilterProvider);
  final cardsAsync = ref.watch(cardListProvider);

  return cardsAsync.whenData((cards) {
    switch (filter) {
      case CollectionFilter.all:
        return cards;
      case CollectionFilter.major:
        return cards.where((c) => c.arcana == 'major').toList();
      case CollectionFilter.wands:
        return cards.where((c) => c.suit == 'wands').toList();
      case CollectionFilter.cups:
        return cards.where((c) => c.suit == 'cups').toList();
      case CollectionFilter.swords:
        return cards.where((c) => c.suit == 'swords').toList();
      case CollectionFilter.pentacles:
        return cards.where((c) => c.suit == 'pentacles').toList();
    }
  });
});

// ==================== 통계 Provider ====================

/// "78장 중 N장 수집" 통계
final collectionStatsProvider = Provider<String>((ref) {
  final cardsAsync = ref.watch(cardListProvider);
  final drawnIds = ref.watch(cardHistoryProvider);

  return cardsAsync.maybeWhen(
    data: (cards) => '${cards.length}장 중 ${drawnIds.length}장 수집',
    orElse: () => '수집 중...',
  );
});
