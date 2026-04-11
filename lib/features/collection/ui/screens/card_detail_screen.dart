import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../card/data/models/tarot_card.dart';
import '../../../card/providers/card_data_provider.dart';
import '../widgets/oldschool_modal.dart';
import '../widgets/meaning_section.dart';

/// 카드 상세 화면
///
/// 카드 이미지(크게) + 정방향/역방향 의미
/// 롱프레스 → 라이더 웨이트 원본 참조 모달
class CardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardByCardIdProvider(cardId));
    final settings = ref.watch(settingsProvider);
    final isRiderWaite =
        settings.activeSkinId == AppConstants.kRiderWaiteSkinId;

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('카드 상세')),
        body: const Center(child: CircularProgressIndicator(color: kPrimaryDark)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundDark
          : kBackgroundLight,
      appBar: AppBar(
        title: Text(card.nameKr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카드 이미지 (크게) + 롱프레스 감지
                  _CardImageSection(
                    card: card,
                    skinId: settings.activeSkinId,
                    isRiderWaiteActive: isRiderWaite,
                  ),
                  const SizedBox(height: 24),

                  // 카드 번호 + 분류
                  _CardMetaInfo(card: card),
                  const SizedBox(height: 24),

                  // 정방향 의미
                  MeaningSection(
                    icon: Icons.keyboard_arrow_up_rounded,
                    title: '정방향',
                    message: card.uprightMessage,
                    meaning: card.uprightMeaning,
                    accentColor: kPrimaryDark,
                  ),
                  const SizedBox(height: 16),

                  // 역방향 의미
                  MeaningSection(
                    icon: Icons.keyboard_arrow_down_rounded,
                    title: '역방향',
                    message: card.reversedMessage,
                    meaning: card.reversedMeaning,
                    accentColor: const Color(0xFFC4A84A),
                  ),
                  const SizedBox(height: 16),

                  // 롱프레스 안내 문구 (기본 스킨일 때만)
                  if (!isRiderWaite) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '이미지를 길게 누르면 원본 타로 카드를 볼 수 있어요',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: kTextSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}

// ==================== 카드 이미지 섹션 ====================

/// 카드 이미지 섹션 (롱프레스 → 올드스쿨 모달)
class _CardImageSection extends StatelessWidget {
  final TarotCard card;
  final String skinId;
  final bool isRiderWaiteActive;

  const _CardImageSection({
    required this.card,
    required this.skinId,
    required this.isRiderWaiteActive,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = CardImageHelper.getCardImagePath(
      card.cardId,
      skinId: skinId,
    );

    return Center(
      child: GestureDetector(
        onLongPress: isRiderWaiteActive
            ? null
            : () => _showOldschoolModal(context),
        child: Container(
          width: 220,
          height: 370,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFB8A9E8).withOpacity(0.3),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: kPrimaryDark.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOldschoolModal(BuildContext context) {
    final rwPath = CardImageHelper.getCardImagePath(
      card.cardId,
      skinId: AppConstants.kRiderWaiteSkinId,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OldschoolModal(
        card: card,
        riderWaitePath: rwPath,
      ),
    );
  }
}

// ==================== 카드 메타 정보 ====================

/// 카드 메타 정보 (번호 + 분류)
class _CardMetaInfo extends StatelessWidget {
  final TarotCard card;
  const _CardMetaInfo({required this.card});

  String get _arcanaLabel {
    if (card.arcana == 'major') return '메이저 아르카나';
    return switch (card.suit) {
      'wands' => '완드',
      'cups' => '컵',
      'swords' => '소드',
      'pentacles' => '펜타클',
      _ => '마이너 아르카나',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaBadge(text: _arcanaLabel, color: kBrandColorPrimary),
        const SizedBox(width: 8),
        _MetaBadge(
          text: card.arcana == 'major'
              ? '${card.number}번'
              : _numberLabel(card.number),
          color: kBrandColorAccent,
        ),
      ],
    );
  }

  String _numberLabel(int n) {
    return switch (n) {
      1 => 'Ace',
      11 => 'Page',
      12 => 'Knight',
      13 => 'Queen',
      14 => 'King',
      _ => '$n',
    };
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _MetaBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color == kBrandColorPrimary
              ? kPrimaryDark
              : const Color(0xFFC4A84A),
        ),
      ),
    );
  }
}
