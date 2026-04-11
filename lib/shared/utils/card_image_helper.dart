/// 카드 이미지 에셋 경로를 반환하는 유틸리티.
///
/// 폴더 구조:
///   assets/images/cards/{skinId}/original/{cardId}.webp  — 상세/공유용 (고해상도)
///   assets/images/cards/{skinId}/thumbnail/{cardId}.webp — 도감 그리드용 (저해상도)
///
/// v1.1 스킨 확장 시 이 헬퍼만 수정하면 전체 앱에 반영됨.
class CardImageHelper {
  CardImageHelper._();

  static const _kExt = 'webp';

  /// 카드 원본 이미지 경로 (상세 화면, 결과 화면, 공유용)
  ///
  /// [cardId] : "T-00", "W-0A", "S-J2" 등 파일명 기반 ID
  /// [skinId] : "default" | "rider_waite" | (v1.1에서 추가 스킨)
  static String getCardImagePath(String cardId, {String skinId = 'default'}) {
    return 'assets/images/cards/$skinId/original/$cardId.$_kExt';
  }

  /// 카드 썸네일 경로 (도감 그리드용)
  static String getCardThumbnailPath(String cardId, {String skinId = 'default'}) {
    return 'assets/images/cards/$skinId/thumbnail/$cardId.$_kExt';
  }

  /// 카드 뒷면 이미지 경로
  static String getCardBackPath({String skinId = 'default'}) {
    return getCardImagePath('X-BA', skinId: skinId);
  }

  /// 라이더 웨이트 원본 이미지 경로 (올드스쿨 참조 모달용)
  static String getRiderWaitePath(String cardId) {
    return getCardImagePath(cardId, skinId: 'rider_waite');
  }

  /// 라이더 웨이트 썸네일 경로
  static String getRiderWaiteThumbnailPath(String cardId) {
    return getCardThumbnailPath(cardId, skinId: 'rider_waite');
  }
}
