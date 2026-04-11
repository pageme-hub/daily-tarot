/// 카드 이미지 에셋 경로를 반환하는 유틸리티.
///
/// v1.1 스킨 확장 시 이 헬퍼만 수정하면 전체 앱에 반영됨.
/// 모든 카드 이미지는 로컬 에셋에서 로드 (네트워크 이미지 미사용).
class CardImageHelper {
  CardImageHelper._();

  /// 카드 이미지 에셋 경로 반환
  ///
  /// [cardId] : "T-00", "W-0A", "S-J2" 등 파일명 기반 ID
  /// [skinId] : "default" | "rider-waite" | (v1.1에서 추가 스킨)
  static String getCardImagePath(String cardId, {String skinId = 'default'}) {
    if (skinId == 'rider-waite') {
      return 'assets/images/cards/rider-waite/RWSa-$cardId.png';
    }
    // 기본 스킨 및 v1.1 로컬 에셋 스킨
    return 'assets/images/cards/$skinId/$cardId.png';
  }

  /// 카드 뒷면 이미지 경로
  static String getCardBackPath({String skinId = 'default'}) {
    return getCardImagePath('X-BA', skinId: skinId);
  }

  /// T-13 (Death) 기본 스킨 누락 여부 확인
  ///
  /// 기본 스킨에서 T-13이 누락된 상태이므로, 이 카드는 rider-waite로 fallback.
  static String getCardImagePathWithFallback(
    String cardId, {
    String skinId = 'default',
  }) {
    // T-13(Death)는 기본 스킨에 누락 → rider-waite로 fallback
    if (skinId == 'default' && cardId == 'T-13') {
      return getCardImagePath(cardId, skinId: 'rider-waite');
    }
    return getCardImagePath(cardId, skinId: skinId);
  }

  // TODO: v1.1 스킨 확장 시 활성화
  // static String getCardImageUrl(String cardId, String skinId, String baseUrl) {
  //   return '$baseUrl/card-images/daily_tarot/$skinId/$cardId.png';
  // }
}
