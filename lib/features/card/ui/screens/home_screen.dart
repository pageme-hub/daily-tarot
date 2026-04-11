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

/// 홈 화면 — 오늘의 카드 뽑기
///
/// 상태A: 아직 뽑지 않음 → 카드 뒷면 + "카드를 터치하세요"
/// 상태B: 방금 뽑음 → 뒤집기 애니메이션
/// 상태C: 이미 결과를 봄 → 결과 위젯 바로 표시
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// 카드를 뽑아서 애니메이션이 시작된 상태인지 (이번 세션)
  bool _isFlipping = false;

  /// 카드 탭 처리 — 광고 → 카드 뽑기 → 뒤집기 애니메이션
  Future<void> _onCardTap() async {
    final cardState = ref.read(dailyCardProvider);

    // 이미 뽑았거나 로딩 중이면 무시
    if (cardState is DailyCardDrawn ||
        cardState is DailyCardLoading ||
        _isFlipping) {
      return;
    }

    // 전면광고 표시 → 카드 뽑기
    await ref.read(adStateProvider.notifier).showInterstitialAd(
      isSplash: false,
      onCompleted: () async {
        if (!mounted) return;
        setState(() => _isFlipping = true);
        await ref.read(dailyCardProvider.notifier).drawCard();
      },
    );
  }

  /// 뒤집기 애니메이션 완료 후: 결과 확인 + 알림 권한 요청
  Future<void> _onFlipComplete() async {
    await ref.read(dailyCardProvider.notifier).markResultSeen();
    if (mounted) {
      setState(() => _isFlipping = false);
    }
    _maybeRequestNotificationPermission();
  }

  /// 첫 카드 결과 확인 직후 알림 권한 요청 (마케팅 브리핑 반영)
  Future<void> _maybeRequestNotificationPermission() async {
    final settings = ref.read(settingsProvider);
    if (settings.hasRequestedNotificationPermission) return;

    await ref
        .read(settingsProvider.notifier)
        .markNotificationPermissionRequested();

    if (!mounted) return;

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

    if (agreed == true && mounted) {
      // NotificationService를 통해 권한 요청 + 알림 자동 등록
      final granted =
          await NotificationService.instance.requestAndroidPermission();
      if (granted) {
        final settings = ref.read(settingsProvider);
        // 알림이 아직 켜지지 않은 상태이면 기본 시간(09:00)으로 등록
        if (!settings.notificationEnabled) {
          await ref.read(settingsProvider.notifier).toggleNotification();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _buildBody(cardState),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DailyCardState cardState) {
    return switch (cardState) {
      DailyCardLoading() => const Center(
          child: CircularProgressIndicator(color: kPrimaryDark),
        ),
      DailyCardError(:final message) => _ErrorView(message: message),
      DailyCardNotDrawn() => _NotDrawnView(onTap: _onCardTap),
      DailyCardDrawn(:final card, :final isReversed, :final hasSeenResult) =>
        // hasSeenResult=true이면 결과 바로 표시, false이면 애니메이션
        !hasSeenResult
            ? _FlipAnimationView(
                cardId: card.cardId,
                isReversed: isReversed,
                autoFlip: true,
                onFlipComplete: _onFlipComplete,
              )
            : CardResultWidget(card: card, isReversed: isReversed),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: kTextSecondary,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘 당신에게 필요한 메시지는?',
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
