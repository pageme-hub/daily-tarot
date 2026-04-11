import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/utils/card_image_helper.dart';

/// 3D Y축 카드 뒤집기 위젯
///
/// [onFlipComplete]: 뒤집기 완료 후 호출될 콜백
/// [cardId]: 뒤집혀서 보여줄 카드 ID (예: "T-00")
/// [isReversed]: 역방향 여부 (true면 카드 이미지 180도 회전)
/// [skinId]: 사용할 스킨 ID (기본: "default")
class CardFlipWidget extends StatefulWidget {
  final String cardId;
  final bool isReversed;
  final String skinId;
  final VoidCallback? onFlipComplete;
  final bool autoFlip;

  const CardFlipWidget({
    super.key,
    required this.cardId,
    this.isReversed = false,
    this.skinId = AppConstants.kDefaultSkinId,
    this.onFlipComplete,
    this.autoFlip = false,
  });

  @override
  State<CardFlipWidget> createState() => CardFlipWidgetState();
}

class CardFlipWidgetState extends State<CardFlipWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipComplete?.call();
      }
    });

    if (widget.autoFlip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startFlip();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 외부에서 뒤집기 시작 (GlobalKey로 접근)
  void flip() {
    if (!_isFlipped) {
      _startFlip();
    }
  }

  void _startFlip() {
    _isFlipped = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final angle = _animation.value * pi;
        final showFront = angle > (pi / 2);

        // 카드 앞면이 보이는 구간(angle > 90도)에서 Y축 반전 보정
        final displayAngle = showFront ? angle - pi : angle;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 원근감
            ..rotateY(displayAngle),
          child: showFront ? _buildFrontCard() : _buildBackCard(),
        );
      },
    );
  }

  Widget _buildBackCard() {
    final backPath = CardImageHelper.getCardBackPath(skinId: widget.skinId);
    return _CardFrame(
      child: Image.asset(
        backPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CardBackPlaceholder(),
      ),
    );
  }

  Widget _buildFrontCard() {
    final imagePath = CardImageHelper.getCardImagePath(
      widget.cardId,
      skinId: widget.skinId,
    );
    return _CardFrame(
      child: widget.isReversed
          ? Transform.rotate(
              angle: pi,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _CardFrontPlaceholder(),
              ),
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _CardFrontPlaceholder(),
            ),
    );
  }
}

/// 카드 프레임 (공통 테두리/그림자)
class _CardFrame extends StatelessWidget {
  final Widget child;
  const _CardFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: child,
      ),
    );
  }
}

/// 카드 뒷면 플레이스홀더 (뒷면 에셋 없을 때)
class _CardBackPlaceholder extends StatelessWidget {
  const _CardBackPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB8A9E8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Text(
              '매일타로',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카드 앞면 플레이스홀더 (앞면 에셋 없을 때)
class _CardFrontPlaceholder extends StatelessWidget {
  const _CardFrontPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0FF),
      child: Center(
        child: Icon(
          Icons.auto_awesome_outlined,
          size: 64,
          color: const Color(0xFF7C6BB5).withOpacity(0.5),
        ),
      ),
    );
  }
}

/// 카드 뒤집기 없이 뒷면만 표시하는 정적 위젯
class CardBackWidget extends StatelessWidget {
  final String skinId;
  const CardBackWidget({
    super.key,
    this.skinId = AppConstants.kDefaultSkinId,
  });

  @override
  Widget build(BuildContext context) {
    final backPath = CardImageHelper.getCardBackPath(skinId: skinId);
    return _CardFrame(
      child: Image.asset(
        backPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CardBackPlaceholder(),
      ),
    );
  }
}

/// 카드 앞면만 표시하는 정적 위젯 (이미 뽑은 경우)
class CardFrontWidget extends StatelessWidget {
  final String cardId;
  final bool isReversed;
  final String skinId;

  const CardFrontWidget({
    super.key,
    required this.cardId,
    this.isReversed = false,
    this.skinId = AppConstants.kDefaultSkinId,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = CardImageHelper.getCardImagePath(
      cardId,
      skinId: skinId,
    );
    return _CardFrame(
      child: isReversed
          ? Transform.rotate(
              angle: pi,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _CardFrontPlaceholder(),
              ),
            )
          : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _CardFrontPlaceholder(),
            ),
    );
  }
}
