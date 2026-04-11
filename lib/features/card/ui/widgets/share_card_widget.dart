import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';
import '../../data/models/tarot_card.dart';

/// 공유용 카드 이미지 위젯 — 9:16 비율 (인스타 스토리 최적화)
///
/// RepaintBoundary 내부에 배치하여 toImage()로 캡처 후 공유/저장합니다.
/// - 배경: 라벤더 그라디언트
/// - 카드 이미지 + 카드 이름 + 방향 + 한 줄 메시지
/// - 날짜 텍스트 ("2026년 4월 10일")
/// - 하단 우측: "매일타로" 워터마크
class ShareCardWidget extends StatelessWidget {
  final TarotCard card;
  final bool isReversed;
  final String skinId;

  /// 캡처 시 고정 크기를 맞추기 위한 비율 기준 너비
  /// 실제 출력은 pixelRatio 3.0으로 3배 해상도 (1080x1920)
  static const double kShareWidth = 360.0;
  static const double kShareHeight = 640.0; // 9:16 = 360:640

  const ShareCardWidget({
    super.key,
    required this.card,
    required this.isReversed,
    this.skinId = AppConstants.kDefaultSkinId,
  });

  String get _message =>
      isReversed ? card.reversedMessage : card.uprightMessage;

  String get _dateLabel {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kShareWidth,
      height: kShareHeight,
      child: Stack(
        children: [
          // 배경: 라벤더 그라디언트
          _buildBackground(),

          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 56),

                // 날짜
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),

                // 제목
                const Text(
                  '오늘의 타로',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),

                // 카드 이미지
                _buildCardImage(),
                const SizedBox(height: 24),

                // 카드 이름 + 방향 뱃지
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.nameKr,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DirectionBadge(isReversed: isReversed),
                  ],
                ),
                const SizedBox(height: 20),

                // 한 줄 메시지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '"$_message"',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 하단 우측 워터마크
          Positioned(
            right: 20,
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '매일타로',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B8BC4), // 라벤더 딥
            Color(0xFFB8A9E8), // 소프트 라벤더
            Color(0xFFD4C5F0), // 라벤더 라이트
            Color(0xFFE8D5A0), // 소프트 골드 하단
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    final imagePath = CardImageHelper.getCardImagePathWithFallback(
      card.cardId,
      skinId: skinId,
    );
    return SizedBox(
      width: 180,
      height: 280,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: isReversed
              ? Transform.rotate(
                  angle: pi,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const _CardImagePlaceholder(),
                  ),
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const _CardImagePlaceholder(),
                ),
        ),
      ),
    );
  }
}

/// 정방향/역방향 뱃지 (공유 카드용)
class _DirectionBadge extends StatelessWidget {
  final bool isReversed;
  const _DirectionBadge({required this.isReversed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        isReversed ? '역방향' : '정방향',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 카드 이미지 플레이스홀더
class _CardImagePlaceholder extends StatelessWidget {
  const _CardImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Center(
        child: Icon(
          Icons.auto_awesome_outlined,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }
}
