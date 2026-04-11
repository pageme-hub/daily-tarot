import 'package:hive/hive.dart';

part 'card_history.g.dart';

/// 카드 뽑기 이력 — Hive 저장용
///
/// 도감에서 뽑은 적 있는 카드 표시에 사용.
/// typeId: 1
@HiveType(typeId: 1)
class CardHistory extends HiveObject {
  /// DB 기준 카드 id (1~78)
  @HiveField(0)
  final int cardId;

  /// 마지막으로 뽑은 날짜 "2026-04-10"
  @HiveField(1)
  final String lastDrawnDate;

  /// 총 뽑은 횟수
  @HiveField(2)
  final int drawCount;

  CardHistory({
    required this.cardId,
    required this.lastDrawnDate,
    required this.drawCount,
  });

  CardHistory copyWith({
    int? cardId,
    String? lastDrawnDate,
    int? drawCount,
  }) {
    return CardHistory(
      cardId: cardId ?? this.cardId,
      lastDrawnDate: lastDrawnDate ?? this.lastDrawnDate,
      drawCount: drawCount ?? this.drawCount,
    );
  }

  @override
  String toString() =>
      'CardHistory(cardId: $cardId, lastDrawnDate: $lastDrawnDate, drawCount: $drawCount)';
}
