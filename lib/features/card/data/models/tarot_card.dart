/// 타로 카드 데이터 모델
///
/// Supabase tarot_cards 테이블 및 로컬 JSON(assets/data/tarot_cards.json) 공용.
/// 이미지 경로는 CardImageHelper.getCardImagePath(cardId)로 동적 생성.
class TarotCard {
  final int id;

  /// 파일명 기반 ID: "T-00", "W-0A", "S-J2" 등
  final String cardId;

  /// 영문명: "The Fool"
  final String name;

  /// 한글명: "바보"
  final String nameKr;

  /// "major" / "minor"
  final String arcana;

  /// null(메이저) / "wands" / "cups" / "swords" / "pentacles"
  final String? suit;

  /// 메이저: 0~21, 마이너: 1(Ace)~14(King)
  final int number;

  final String uprightMeaning;
  final String reversedMeaning;

  /// 정방향 한 줄 메시지
  final String uprightMessage;

  /// 역방향 한 줄 메시지
  final String reversedMessage;

  /// 전통 해석 (롱프레스 모달용, 선택적)
  final String? traditionalMeaning;

  const TarotCard({
    required this.id,
    required this.cardId,
    required this.name,
    required this.nameKr,
    required this.arcana,
    this.suit,
    required this.number,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.uprightMessage,
    required this.reversedMessage,
    this.traditionalMeaning,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      id: json['id'] as int,
      cardId: json['card_id'] as String,
      name: json['name'] as String,
      nameKr: json['name_kr'] as String,
      arcana: json['arcana'] as String,
      suit: json['suit'] as String?,
      number: json['number'] as int,
      uprightMeaning: json['upright_meaning'] as String,
      reversedMeaning: json['reversed_meaning'] as String,
      uprightMessage: json['upright_message'] as String,
      reversedMessage: json['reversed_message'] as String,
      traditionalMeaning: json['traditional_meaning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'name': name,
      'name_kr': nameKr,
      'arcana': arcana,
      'suit': suit,
      'number': number,
      'upright_meaning': uprightMeaning,
      'reversed_meaning': reversedMeaning,
      'upright_message': uprightMessage,
      'reversed_message': reversedMessage,
      'traditional_meaning': traditionalMeaning,
    };
  }

  TarotCard copyWith({
    int? id,
    String? cardId,
    String? name,
    String? nameKr,
    String? arcana,
    String? suit,
    int? number,
    String? uprightMeaning,
    String? reversedMeaning,
    String? uprightMessage,
    String? reversedMessage,
    String? traditionalMeaning,
  }) {
    return TarotCard(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      nameKr: nameKr ?? this.nameKr,
      arcana: arcana ?? this.arcana,
      suit: suit ?? this.suit,
      number: number ?? this.number,
      uprightMeaning: uprightMeaning ?? this.uprightMeaning,
      reversedMeaning: reversedMeaning ?? this.reversedMeaning,
      uprightMessage: uprightMessage ?? this.uprightMessage,
      reversedMessage: reversedMessage ?? this.reversedMessage,
      traditionalMeaning: traditionalMeaning ?? this.traditionalMeaning,
    );
  }

  /// 메이저 아르카나 여부
  bool get isMajorArcana => arcana == 'major';

  @override
  String toString() => 'TarotCard(id: $id, cardId: $cardId, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarotCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
