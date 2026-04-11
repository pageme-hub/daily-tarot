import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tarot_card.dart';
import '../data/models/daily_card_cache.dart';
import '../../collection/data/models/card_history.dart';
import '../../collection/providers/collection_provider.dart';
import '../../../core/hive/hive_boxes.dart';
import '../../../core/utils/logger.dart';
import 'card_data_provider.dart';

// ==================== 상태 정의 ====================

/// 오늘의 카드 상태
sealed class DailyCardState {
  const DailyCardState();
}

/// 아직 카드를 뽑지 않은 상태
class DailyCardNotDrawn extends DailyCardState {
  const DailyCardNotDrawn();
}

/// 카드 뽑기 완료 상태
class DailyCardDrawn extends DailyCardState {
  final TarotCard card;
  final bool isReversed;
  final bool hasSeenResult;

  const DailyCardDrawn({
    required this.card,
    required this.isReversed,
    this.hasSeenResult = false,
  });
}

/// 카드 로딩 중
class DailyCardLoading extends DailyCardState {
  const DailyCardLoading();
}

/// 에러 상태
class DailyCardError extends DailyCardState {
  final String message;
  const DailyCardError(this.message);
}

// ==================== Notifier ====================

class DailyCardNotifier extends StateNotifier<DailyCardState> {
  final Ref _ref;

  DailyCardNotifier(this._ref) : super(const DailyCardLoading()) {
    _initialize();
  }

  /// 오늘 날짜 문자열 "2026-04-10" 형식
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 초기화: Hive에서 오늘의 캐시 확인
  Future<void> _initialize() async {
    try {
      final today = _todayString();
      final cache = HiveBoxes.dailyCardBox.get(today);

      if (cache != null) {
        // 오늘 이미 뽑은 카드가 있음 — FutureProvider 완료를 직접 await (M-04)
        final cards = await _ref.read(cardListProvider.future);

        try {
          final card = cards.firstWhere((c) => c.id == cache.cardId);
          state = DailyCardDrawn(
            card: card,
            isReversed: cache.isReversed,
            hasSeenResult: cache.hasSeenResult,
          );
          Logger.info('DailyCard: 오늘($today) 캐시 복원 — ${card.nameKr}');
          return;
        } catch (_) {
          Logger.error(
            'DailyCard: 캐시된 cardId(${cache.cardId})를 카드 목록에서 찾지 못함',
          );
        }
      }

      state = const DailyCardNotDrawn();
    } catch (e) {
      Logger.error('DailyCard: 초기화 실패: $e');
      state = const DailyCardNotDrawn();
    }
  }

  /// 카드 뽑기
  ///
  /// 날짜 기반 시드로 의사난수 생성 → 78장 중 1장 선택 → Hive 저장
  Future<void> drawCard() async {
    if (state is DailyCardDrawn) return; // 오늘 이미 뽑음

    state = const DailyCardLoading();

    try {
      // FutureProvider 완료를 직접 await (M-04: polling 패턴 제거)
      final cards = await _ref.read(cardListProvider.future);

      if (cards.isEmpty) {
        state = const DailyCardError('카드 데이터를 로드할 수 없어요');
        return;
      }

      // 날짜 + 설치 시각 기반 시드 (같은 날 재실행 시 동일 카드)
      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      final rng = Random(seed);

      final index = rng.nextInt(cards.length);
      final card = cards[index];
      final isReversed = rng.nextBool();

      final today = _todayString();

      // Hive에 일일 캐시 저장
      final cache = DailyCardCache(
        date: today,
        cardId: card.id,
        isReversed: isReversed,
        hasSeenResult: false,
      );
      await HiveBoxes.dailyCardBox.put(today, cache);

      // CardHistory 업데이트 (도감 기록)
      await _updateCardHistory(card.id, today);

      // 도감 Provider 갱신 트리거
      _ref.invalidate(cardHistoryProvider);

      state = DailyCardDrawn(
        card: card,
        isReversed: isReversed,
        hasSeenResult: false,
      );

      Logger.info(
        'DailyCard: 뽑기 완료 — ${card.nameKr} (${isReversed ? "역방향" : "정방향"})',
      );
    } catch (e) {
      Logger.error('DailyCard: 뽑기 실패: $e');
      state = const DailyCardError('카드 뽑기에 실패했어요');
    }
  }

  /// 다시 뽑기 — 오늘의 캐시 삭제 후 타임스탬프 기반 새 시드로 재뽑기
  ///
  /// 광고 시청 완료 후 호출. 기존 Hive 캐시를 삭제하고 새 카드를 뽑음.
  Future<void> redrawCard() async {
    state = const DailyCardLoading();

    try {
      final today = _todayString();
      // 오늘 캐시 삭제
      await HiveBoxes.dailyCardBox.delete(today);

      final cards = await _ref.read(cardListProvider.future);
      if (cards.isEmpty) {
        state = const DailyCardError('카드 데이터를 로드할 수 없어요');
        return;
      }

      // 타임스탬프 기반 시드 → 매번 다른 카드
      final seed = DateTime.now().millisecondsSinceEpoch;
      final rng = Random(seed);

      final index = rng.nextInt(cards.length);
      final card = cards[index];
      final isReversed = rng.nextBool();

      final cache = DailyCardCache(
        date: today,
        cardId: card.id,
        isReversed: isReversed,
        hasSeenResult: false,
      );
      await HiveBoxes.dailyCardBox.put(today, cache);

      await _updateCardHistory(card.id, today);
      _ref.invalidate(cardHistoryProvider);

      state = DailyCardDrawn(
        card: card,
        isReversed: isReversed,
        hasSeenResult: false,
      );

      Logger.info(
        'DailyCard: 다시 뽑기 완료 — ${card.nameKr} (${isReversed ? "역방향" : "정방향"})',
      );
    } catch (e) {
      Logger.error('DailyCard: 다시 뽑기 실패: $e');
      state = const DailyCardError('카드 뽑기에 실패했어요');
    }
  }

  /// 결과 확인 완료 표시 (애니메이션 스킵 판단용)
  Future<void> markResultSeen() async {
    if (state is! DailyCardDrawn) return;

    final drawn = state as DailyCardDrawn;
    final today = _todayString();

    final cache = HiveBoxes.dailyCardBox.get(today);
    if (cache != null) {
      await HiveBoxes.dailyCardBox.put(
        today,
        cache.copyWith(hasSeenResult: true),
      );
    }

    state = DailyCardDrawn(
      card: drawn.card,
      isReversed: drawn.isReversed,
      hasSeenResult: true,
    );
  }

  /// 카드 뽑기 이력 업데이트
  Future<void> _updateCardHistory(int cardId, String date) async {
    try {
      final box = HiveBoxes.cardHistoryBox;
      final key = cardId.toString();
      final existing = box.get(key);

      final updated = existing != null
          ? existing.copyWith(
              lastDrawnDate: date,
              drawCount: existing.drawCount + 1,
            )
          : CardHistory(
              cardId: cardId,
              lastDrawnDate: date,
              drawCount: 1,
            );

      await box.put(key, updated);
    } catch (e) {
      Logger.error('DailyCard: 이력 저장 실패: $e');
    }
  }
}

// ==================== Provider ====================

final dailyCardProvider =
    StateNotifierProvider<DailyCardNotifier, DailyCardState>(
  (ref) => DailyCardNotifier(ref),
);
