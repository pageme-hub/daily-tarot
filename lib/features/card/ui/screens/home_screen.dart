import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../providers/daily_card_provider.dart';
import '../../providers/ad_state_provider.dart';
import '../widgets/card_flip_widget.dart';
import '../widgets/card_result_widget.dart';

/// 이번 세션에서 카드 뒤집기 애니메이션이 진행 중인지 여부
///
/// RULES.md: setState 사용 금지 — StateProvider로 관리
final _isFlippingProvider = StateProvider<bool>((ref) => false);

/// 홈 화면 — 오늘의 카드 뽑기 (상태A: 미뽑기 / B: 애니메이션 / C: 결과)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// 카드 탭 처리 — 광고 없이 카드 뽑기 → 뒤집기 애니메이션
  ///
  /// 오늘 처음 뽑기는 광고 없이 제공. 다시 뽑기는 [_onRedrawTap] 참조.
  Future<void> _onCardTap(WidgetRef ref) async {
    final cardState = ref.read(dailyCardProvider);
    final isFlipping = ref.read(_isFlippingProvider);

    // 이미 뽑았거나 로딩 중이면 무시
    if (cardState is DailyCardDrawn ||
        cardState is DailyCardLoading ||
        isFlipping) {
      return;
    }

    ref.read(_isFlippingProvider.notifier).state = true;
    await ref.read(dailyCardProvider.notifier).drawCard();
  }

  /// 다시 뽑기 — 전면광고 시청 후 새 카드 뽑기
  Future<void> _onRedrawTap(WidgetRef ref) async {
    await ref.read(adStateProvider.notifier).showInterstitialAd(
      isSplash: false,
      onCompleted: () async {
        ref.read(_isFlippingProvider.notifier).state = true;
        await ref.read(dailyCardProvider.notifier).redrawCard();
      },
    );
  }

  Future<void> _onFlipComplete(WidgetRef ref, BuildContext context) async {
    await ref.read(dailyCardProvider.notifier).markResultSeen();
    ref.read(_isFlippingProvider.notifier).state = false;
    _maybeRequestNotificationPermission(ref, context);
  }

  Future<void> _maybeRequestNotificationPermission(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final settings = ref.read(settingsProvider);
    if (settings.hasRequestedNotificationPermission) return;

    await ref
        .read(settingsProvider.notifier)
        .markNotificationPermissionRequested();

    if (!context.mounted) return;

    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
        ),
        title: const Text('매일 타로 알림'),
        content: const Text(
          '매일 아침 오늘의 타로 카드를 알려드릴까요?\n알림은 설정에서 언제든 변경할 수 있어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('괜찮아요'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: kPrimaryDark),
            child: const Text('허용할게요'),
          ),
        ],
      ),
    );

    if (agreed == true && context.mounted) {
      // NotificationService를 통해 권한 요청 + 알림 자동 등록
      final granted =
          await NotificationService.instance.requestAndroidPermission();
      if (granted) {
        final currentSettings = ref.read(settingsProvider);
        // 알림이 아직 켜지지 않은 상태이면 기본 시간(09:00)으로 등록
        if (!currentSettings.notificationEnabled) {
          await ref.read(settingsProvider.notifier).toggleNotification();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(dailyCardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundDark
          : kBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(),
            Expanded(
              child: _buildBody(context, ref, cardState),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DailyCardState cardState,
  ) {
    return switch (cardState) {
      DailyCardLoading() => const Center(
          child: CircularProgressIndicator(color: kPrimaryDark),
        ),
      DailyCardError(:final message) => _ErrorView(message: message),
      DailyCardNotDrawn() => _NotDrawnView(onTap: () => _onCardTap(ref)),
      DailyCardDrawn(:final card, :final isReversed, :final hasSeenResult) =>
        !hasSeenResult
            ? _FlipAnimationView(
                cardId: card.cardId,
                isReversed: isReversed,
                autoFlip: true,
                onFlipComplete: () => _onFlipComplete(ref, context),
              )
            : CardResultWidget(
                card: card,
                isReversed: isReversed,
                onRedraw: () => _onRedrawTap(ref),
              ),
    };
  }
}

// ==================== 상단 헤더 ====================

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final dateLabel = '${now.month}월 ${now.day}일 ${weekday}요일';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kDefaultPadding,
        kDefaultPadding,
        kDefaultPadding,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // [피드백 1-5] 날짜 중앙정렬
          Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘 당신에게 필요한 메시지는?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: kPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ==================== 상태A: 미뽑기 뷰 ====================

class _NotDrawnView extends StatelessWidget {
  final VoidCallback onTap;
  const _NotDrawnView({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: const SizedBox(
            width: 200,
            height: 340,
            child: CardBackWidget(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app_outlined, size: 18, color: kTextSecondary),
            const SizedBox(width: 6),
            Text(
              '카드를 터치하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kTextSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== 뒤집기 애니메이션 뷰 ====================

class _FlipAnimationView extends StatelessWidget {
  final String cardId;
  final bool isReversed;
  final bool autoFlip;
  final VoidCallback onFlipComplete;

  const _FlipAnimationView({
    required this.cardId,
    required this.isReversed,
    required this.autoFlip,
    required this.onFlipComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 340,
        child: CardFlipWidget(
          cardId: cardId,
          isReversed: isReversed,
          autoFlip: autoFlip,
          onFlipComplete: onFlipComplete,
        ),
      ),
    );
  }
}

// ==================== 에러 뷰 ====================

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: kTextSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: kTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
