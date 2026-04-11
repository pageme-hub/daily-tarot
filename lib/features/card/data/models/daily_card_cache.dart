import 'package:hive/hive.dart';

part 'daily_card_cache.g.dart';

/// 일일 카드 캐시 — Hive 저장용
///
/// 같은 날 재실행해도 동일한 카드를 표시하기 위해 날짜+카드ID+방향을 로컬에 저장.
/// typeId: 0
@HiveType(typeId: 0)
class DailyCardCache extends HiveObject {
  /// "2026-04-10" 형식
  @HiveField(0)
  final String date;

  /// DB 기준 id (1~78)
  @HiveField(1)
  final int cardId;

  /// 역방향 여부
  @HiveField(2)
  final bool isReversed;

  /// 결과를 본 적 있는지 (애니메이션 스킵 판단용)
  @HiveField(3)
  final bool hasSeenResult;

  DailyCardCache({
    required this.date,
    required this.cardId,
    required this.isReversed,
    required this.hasSeenResult,
  });

  DailyCardCache copyWith({
    String? date,
    int? cardId,
    bool? isReversed,
    bool? hasSeenResult,
  }) {
    return DailyCardCache(
      date: date ?? this.date,
      cardId: cardId ?? this.cardId,
      isReversed: isReversed ?? this.isReversed,
      hasSeenResult: hasSeenResult ?? this.hasSeenResult,
    );
  }

  @override
  String toString() =>
      'DailyCardCache(date: $date, cardId: $cardId, isReversed: $isReversed)';
}
