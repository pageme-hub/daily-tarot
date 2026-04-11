import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';
import '../../data/models/tarot_card.dart';
import 'card_flip_widget.dart';

/// 화면용 카드 콘텐츠
class ScreenCardContent extends StatelessWidget {
  final TarotCard card;
  final bool isReversed;
  final String skinId;

  const ScreenCardContent({
    super.key,
    required this.card,
    required this.isReversed,
    required this.skinId,
  });

  @override
  Widget build(BuildContext context) {
    final message = isReversed ? card.reversedMessage : card.uprightMessage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFAFAF7),
      padding: const EdgeInsets.all(kCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 카드 이미지
          SizedBox(
            height: 280,
            child: CardFrontWidget(
              cardId: card.cardId,
              isReversed: isReversed,
              skinId: skinId,
            ),
          ),
          const SizedBox(height: 20),

          // 카드 이름 + 방향 뱃지
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.nameKr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(width: 8),
              DirectionBadge(isReversed: isReversed),
            ],
          ),
          const SizedBox(height: 12),

          // 한 줄 메시지
          Text(
            '"$message"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: kPrimaryDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DirectionBadge extends StatelessWidget {
  final bool isReversed;
  const DirectionBadge({super.key, required this.isReversed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isReversed
            ? const Color(0xFFE8D5A0).withOpacity(0.3)
            : const Color(0xFFB8A9E8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReversed ? const Color(0xFFE8D5A0) : kBrandColorPrimary,
          width: 1,
        ),
      ),
      child: Text(
        isReversed ? '역방향' : '정방향',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isReversed ? const Color(0xFFC4A84A) : kPrimaryDark,
        ),
      ),
    );
  }
}

/// 상세 해석 ExpansionTile — 올드스쿨 이미지 + 방향별 의미 (가로 2단)
class DetailExpansionTile extends StatelessWidget {
  final TarotCard card;
  final bool isReversed;

  const DetailExpansionTile({
    super.key,
    required this.card,
    required this.isReversed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          '상세 해석 보기',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: kPrimaryDark,
              ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 카드 이름 한글 + 영문 + 번호
          _CardInfoHeader(card: card),
          const SizedBox(height: 16),

          // 가로 2단: 왼쪽 올드스쿨 이미지, 오른쪽 방향별 의미
          _RiderWaiteWithMeaning(
            card: card,
            isReversed: isReversed,
          ),
        ],
      ),
    );
  }
}

class _CardInfoHeader extends StatelessWidget {
  final TarotCard card;
  const _CardInfoHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          card.nameKr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          card.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kTextSecondary,
              ),
        ),
        const Spacer(),
        Text(
          '#${card.number.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kTextSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _RiderWaiteWithMeaning extends StatelessWidget {
  final TarotCard card;
  final bool isReversed;

  const _RiderWaiteWithMeaning({
    required this.card,
    required this.isReversed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽: 올드스쿨(라이더 웨이트) 카드 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            CardImageHelper.getRiderWaitePath(card.cardId),
            width: 100,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(width: 100, height: 160),
          ),
        ),
        const SizedBox(width: 16),

        // 오른쪽: 정방향 + 역방향 의미
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MeaningSection(
                label: '정방향',
                meaning: card.uprightMeaning,
                isHighlighted: !isReversed,
              ),
              const SizedBox(height: 12),
              _MeaningSection(
                label: '역방향',
                meaning: card.reversedMeaning,
                isHighlighted: isReversed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeaningSection extends StatelessWidget {
  final String label;
  final String meaning;
  final bool isHighlighted;

  const _MeaningSection({
    required this.label,
    required this.meaning,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? kPrimaryDark.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHighlighted
                      ? kPrimaryDark.withOpacity(0.4)
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isHighlighted ? kPrimaryDark : kTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          meaning,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.7,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        ),
      ],
    );
  }
}
