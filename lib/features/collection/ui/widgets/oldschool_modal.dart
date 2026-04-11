import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../card/data/models/tarot_card.dart';

/// 라이더 웨이트 원본 참조 모달 (DraggableScrollableSheet)
class OldschoolModal extends StatelessWidget {
  final TarotCard card;
  final String riderWaitePath;

  const OldschoolModal({
    super.key,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                height: 1.7,
                                color: kTextSecondary,
                              ),
                        ),
                      ] else ...[
                        Text(
                          '라이더 웨이트(1909)는 타로 카드의 표준이 된 원본 덱으로,\n'
                          '아서 에드워드 웨이트와 파멜라 콜먼 스미스가 제작했습니다.\n'
                          '퍼블릭 도메인으로 참조 목적으로 제공됩니다.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
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
