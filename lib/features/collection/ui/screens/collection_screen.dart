import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';
import '../../providers/collection_provider.dart';
import '../../../card/data/models/tarot_card.dart';

/// 카드 도감 화면
///
/// TabBar: 전체/메이저/완드/컵/소드/펜타클
/// GridView 2열: 뽑은 카드는 컬러, 미뽑은 카드는 그레이스케일
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(collectionStatsProvider);

    return DefaultTabController(
      length: CollectionFilter.values.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? kBackgroundDark
            : kBackgroundLight,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('카드 도감'),
              Text(
                stats,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: kTextSecondary,
                    ),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: kPrimaryDark,
            unselectedLabelColor: kTextSecondary,
            indicatorColor: kPrimaryDark,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: CollectionFilter.values
                .map((f) => Tab(text: f.label))
                .toList(),
            onTap: (index) {
              ref.read(collectionFilterProvider.notifier).state =
                  CollectionFilter.values[index];
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: CollectionFilter.values
                    .map((_) => const _CollectionGrid())
                    .toList(),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

/// 카드 그리드 뷰
class _CollectionGrid extends ConsumerWidget {
  const _CollectionGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredCardsProvider);
    final drawnIds = ref.watch(cardHistoryProvider);

    return filteredAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: kPrimaryDark),
      ),
      error: (e, _) => Center(
        child: Text(
          '카드를 불러올 수 없어요',
          style: TextStyle(color: kTextSecondary),
        ),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return Center(
            child: Text(
              '카드가 없어요',
              style: TextStyle(color: kTextSecondary),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(kDefaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            final isDrawn = drawnIds.contains(card.id);
            return _CollectionCardItem(
              card: card,
              isDrawn: isDrawn,
            );
          },
        );
      },
    );
  }
}

/// 도감 카드 아이템
class _CollectionCardItem extends StatelessWidget {
  final TarotCard card;
  final bool isDrawn;

  const _CollectionCardItem({
    required this.card,
    required this.isDrawn,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = CardImageHelper.getCardImagePathWithFallback(card.cardId);

    return GestureDetector(
      onTap: () => context.push('/collection/${card.cardId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 카드 이미지
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kCardBorderRadius),
                child: ColorFiltered(
                  colorFilter: isDrawn
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 0.6, 0,
                        ]),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDrawn
                          ? const Color(0xFFB8A9E8).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          color: isDrawn ? kPrimaryDark : kTextSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 카드 이름
          Text(
            card.nameKr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDrawn ? kTextPrimary : kTextSecondary,
                  fontWeight:
                      isDrawn ? FontWeight.w600 : FontWeight.w400,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // 수집 완료 표시
          if (isDrawn) ...[
            const SizedBox(height: 2),
            Icon(Icons.star_rounded, size: 12, color: kBrandColorAccent),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
