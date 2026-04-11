import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../card/data/models/tarot_card.dart';
import '../../../card/providers/card_data_provider.dart';

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
                  _MeaningSection(
                    icon: Icons.keyboard_arrow_up_rounded,
                    title: '정방향',
                    message: card.uprightMessage,
                    meaning: card.uprightMeaning,
                    accentColor: kPrimaryDark,
                  ),
                  const SizedBox(height: 16),

                  // 역방향 의미
                  _MeaningSection(
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
    final imagePath = CardImageHelper.getCardImagePathWithFallback(
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
      builder: (ctx) => _OldschoolModal(
        card: card,
        riderWaitePath: rwPath,
      ),
    );
  }
}

/// 라이더 웨이트 원본 참조 모달
class _OldschoolModal extends StatelessWidget {
  final TarotCard card;
  final String riderWaitePath;

  const _OldschoolModal({
    required this.card,
    required this.riderWaitePath,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.history_edu_outlined,
                        size: 18, color: kPrimaryDark),
                    const SizedBox(width: 8),
                    Text(
                      '라이더 웨이트 원본 — ${card.nameKr}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: kPrimaryDark,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      color: kTextSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    children: [
                      // 라이더 웨이트 이미지
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(kCardBorderRadius),
                        child: Image.asset(
                          riderWaitePath,
                          height: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(kCardBorderRadius),
                            ),
                            child: Center(
                              child: Text(
                                '원본 이미지를 준비 중이에요',
                                style: TextStyle(color: kTextSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 전통 해석 (있을 경우)
                      if (card.traditionalMeaning != null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '전통 해석',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryDark,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.traditionalMeaning!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.7,
                                    color: kTextSecondary,
                                  ),
                        ),
                      ] else ...[
                        Text(
                          '라이더 웨이트(1909)는 타로 카드의 표준이 된 원본 덱으로,\n'
                          '아서 에드워드 웨이트와 파멜라 콜먼 스미스가 제작했습니다.\n'
                          '퍼블릭 도메인으로 참조 목적으로 제공됩니다.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.6,
                                    color: kTextSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
          color: color == kBrandColorPrimary ? kPrimaryDark : const Color(0xFFC4A84A),
        ),
      ),
    );
  }
}

/// 의미 섹션 (정방향 / 역방향)
class _MeaningSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String meaning;
  final Color accentColor;

  const _MeaningSection({
    required this.icon,
    required this.title,
    required this.message,
    required this.meaning,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 방향 제목
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 한 줄 메시지
          Text(
            '"$message"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 상세 의미
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.7,
                  color: kTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
