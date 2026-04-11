import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tarot_card.dart';
import '../data/repositories/card_repository.dart';

// ==================== Repository Provider ====================

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => CardRepository(),
);

// ==================== 카드 목록 Provider ====================

/// 78장 전체 카드 데이터 Provider
///
/// Supabase → 로컬 JSON fallback 순서로 로드.
/// 메모리에 캐싱되어 앱 실행 중 재로드 없음.
final cardListProvider = FutureProvider<List<TarotCard>>((ref) async {
  final repository = ref.read(cardRepositoryProvider);
  return repository.fetchAllCards();
});

// ==================== 카드 조회 Provider ====================

/// 특정 id(1~78)로 카드 조회 (DB 기준 id)
final cardByIdProvider = Provider.family<TarotCard?, int>((ref, id) {
  final cardsAsync = ref.watch(cardListProvider);
  return cardsAsync.maybeWhen(
    data: (cards) {
      try {
        return cards.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

/// cardId 문자열("T-00" 등)로 카드 조회
final cardByCardIdProvider = Provider.family<TarotCard?, String>((ref, cardId) {
  final cardsAsync = ref.watch(cardListProvider);
  return cardsAsync.maybeWhen(
    data: (cards) {
      try {
        return cards.firstWhere((c) => c.cardId == cardId);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
