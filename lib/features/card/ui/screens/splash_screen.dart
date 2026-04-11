import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../features/card/providers/card_data_provider.dart';
import '../../../../features/card/providers/ad_state_provider.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/tarot_card.dart';

/// 스플래시 화면
///
/// 동작:
/// 1. 카드 데이터 로드 (Supabase → 로컬 JSON fallback)
/// 2. 전면광고 사전 로드
/// 3. isFirstLaunch 체크 → 첫 실행 시 광고 스킵, 이후 전면광고 표시
/// 4. 최대 3초 타임아웃
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _startSplash();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _startSplash() async {
    final minSplashFuture = Future.delayed(
      const Duration(milliseconds: AppConstants.kSplashDurationMs),
    );

    // 카드 데이터 로드 트리거 (3초 타임아웃)
    final cardLoadFuture = ref
        .read(cardListProvider.future)
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            Logger.error('SplashScreen: 카드 로드 타임아웃');
            return [];
          },
        )
        .catchError((e) {
      Logger.error('SplashScreen: 카드 로드 오류: $e');
      return <TarotCard>[];
    });

    await Future.wait([minSplashFuture, cardLoadFuture]);

    if (!mounted) return;

    // 첫 실행 완료 처리
    final settings = ref.read(settingsProvider);
    if (settings.isFirstLaunch) {
      await ref.read(settingsProvider.notifier).markFirstLaunchDone();
      _navigateToHome();
      return;
    }

    // 전면 광고 표시 (첫 실행이 아닌 경우)
    ref.read(adStateProvider.notifier).showInterstitialAd(
      isSplash: true,
      onCompleted: () {
        if (mounted) _navigateToHome();
      },
    );
  }

  void _navigateToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFFAFAF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // 로고 아이콘
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFB8A9E8).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 52,
                color: Color(0xFF7C6BB5),
              ),
            ),
            const SizedBox(height: 24),
            // 앱 이름
            Text(
              '매일타로',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF7C6BB5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘의 카드 한 장',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(flex: 2),
            // 로딩 인디케이터
            _DotLoadingIndicator(controller: _dotController),
            const SizedBox(height: 12),
            Text(
              '오늘의 카드를 불러오는 중...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8E8E9A),
                  ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

/// 점 3개 로딩 애니메이션 위젯
class _DotLoadingIndicator extends StatelessWidget {
  final AnimationController controller;

  const _DotLoadingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index / 3;
            final progress = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (progress < 0.5
                    ? progress * 2
                    : (1.0 - progress) * 2)
                .clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C6BB5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
