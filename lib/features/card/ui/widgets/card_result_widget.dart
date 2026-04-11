import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/tarot_card.dart';
import 'card_flip_widget.dart';
import 'share_card_widget.dart';

/// 카드 결과 표시 위젯
///
/// 카드 이미지 + 이름 + 방향 뱃지 + 한 줄 메시지
/// + 상세 해석 ExpansionTile + 저장/공유 버튼
class CardResultWidget extends StatefulWidget {
  final TarotCard card;
  final bool isReversed;
  final String skinId;

  const CardResultWidget({
    super.key,
    required this.card,
    required this.isReversed,
    this.skinId = AppConstants.kDefaultSkinId,
  });

  @override
  State<CardResultWidget> createState() => _CardResultWidgetState();
}

class _CardResultWidgetState extends State<CardResultWidget> {
  final GlobalKey _shareRepaintKey = GlobalKey();

  String get _meaning =>
      widget.isReversed
          ? widget.card.reversedMeaning
          : widget.card.uprightMeaning;

  String get _shareText =>
      '오늘 나의 타로 카드는 \'${widget.card.nameKr}\'입니다. '
      '#매일타로 #오늘의타로';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 화면에 표시되는 카드 결과 영역
          _ScreenCardContent(
            card: widget.card,
            isReversed: widget.isReversed,
            skinId: widget.skinId,
          ),
          const SizedBox(height: 24),

          // 상세 해석 — ExpansionTile
          _DetailExpansionTile(
            meaning: _meaning,
            isReversed: widget.isReversed,
          ),
          const SizedBox(height: 24),

          // 저장 / 공유 버튼
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.download_outlined,
                  label: '저장하기',
                  onTap: () => _saveShareImage(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_outlined,
                  label: '공유하기',
                  isPrimary: true,
                  onTap: () => _shareShareImage(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 오프스크린 공유 위젯 (캡처 전용 — 화면에는 보이지 않음)
          // Opacity 0으로 숨기되 레이아웃은 유지해야 캡처 가능
          Opacity(
            opacity: 0,
            child: RepaintBoundary(
              key: _shareRepaintKey,
              child: ShareCardWidget(
                card: widget.card,
                isReversed: widget.isReversed,
                skinId: widget.skinId,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공유 위젯을 고해상도 PNG로 캡처
  Future<Uint8List?> _captureShareImage() async {
    try {
      final boundary = _shareRepaintKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('CardResult: RepaintBoundary를 찾을 수 없음');
        return null;
      }
      // pixelRatio 3.0 → 360*3=1080, 640*3=1920 (9:16 HD)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('CardResult: 이미지 캡처 실패: $e');
      return null;
    }
  }

  /// 갤러리에 저장
  Future<void> _saveShareImage(BuildContext context) async {
    final bytes = await _captureShareImage();
    if (bytes == null) {
      if (context.mounted) _showSnackBar(context, '이미지 저장에 실패했어요');
      return;
    }
    try {
      // 임시 파일 생성 후 gal로 갤러리에 저장
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/maeil_tarot_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      await Gal.putImage(file.path, album: '매일타로');
      // 임시 파일 삭제
      await file.delete();
      if (context.mounted) _showSnackBar(context, '갤러리에 저장되었어요');
    } catch (e) {
      debugPrint('CardResult: 갤러리 저장 실패: $e');
      if (context.mounted) _showSnackBar(context, '저장에 실패했어요');
    }
  }

  /// 공유하기 (share_plus)
  Future<void> _shareShareImage(BuildContext context) async {
    final bytes = await _captureShareImage();
    if (bytes == null) {
      if (context.mounted) _showSnackBar(context, '공유 이미지 생성에 실패했어요');
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tarot_share.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: _shareText,
      );
    } catch (e) {
      debugPrint('CardResult: 공유 실패: $e');
      if (context.mounted) _showSnackBar(context, '공유에 실패했어요');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonBorderRadius),
        ),
      ),
    );
  }
}

/// 화면에 표시되는 카드 콘텐츠 (공유 이미지와 다른 레이아웃)
class _ScreenCardContent extends StatelessWidget {
  final TarotCard card;
  final bool isReversed;
  final String skinId;

  const _ScreenCardContent({
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
                      color: kTextPrimary,
                    ),
              ),
              const SizedBox(width: 8),
              _DirectionBadge(isReversed: isReversed),
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

/// 정방향/역방향 뱃지
class _DirectionBadge extends StatelessWidget {
  final bool isReversed;
  const _DirectionBadge({required this.isReversed});

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

/// 상세 해석 ExpansionTile
class _DetailExpansionTile extends StatelessWidget {
  final String meaning;
  final bool isReversed;

  const _DetailExpansionTile({
    required this.meaning,
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
        leading: Icon(
          isReversed
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_up_rounded,
          color: kPrimaryDark,
        ),
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
          const SizedBox(height: 12),
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: kTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼 (저장/공유)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: kPrimaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kButtonBorderRadius),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryDark,
        side: const BorderSide(color: kPrimaryDark),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonBorderRadius),
        ),
      ),
    );
  }
}
