import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/models/tarot_card.dart';
import 'card_action_button.dart';
import 'card_result_components.dart';
import 'card_save_helper.dart'
    if (dart.library.html) 'card_save_helper_web.dart';
import 'share_card_widget.dart';

/// 카드 결과 표시 위젯
///
/// 카드 이미지 + 이름 + 방향 뱃지 + 한 줄 메시지
/// + 상세 해석 ExpansionTile + 저장/공유 버튼 + 다시 뽑기 버튼
class CardResultWidget extends StatefulWidget {
  final TarotCard card;
  final bool isReversed;
  final String skinId;

  /// 다시 뽑기 콜백 — 광고 시청 후 새 카드 뽑기
  final VoidCallback? onRedraw;

  const CardResultWidget({
    super.key,
    required this.card,
    required this.isReversed,
    this.skinId = AppConstants.kDefaultSkinId,
    this.onRedraw,
  });

  @override
  State<CardResultWidget> createState() => _CardResultWidgetState();
}

class _CardResultWidgetState extends State<CardResultWidget> {
  /// 공유 이미지 캡처용 GlobalKey — StatefulWidget이 필요한 유일한 이유
  final GlobalKey _shareRepaintKey = GlobalKey();

  String get _shareText =>
      '오늘 나의 타로 카드는 \'${widget.card.nameKr}\'입니다. '
      '#매일타로 #오늘의타로';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 메인 스크롤 영역
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 화면에 표시되는 카드 결과 영역
              ScreenCardContent(
                card: widget.card,
                isReversed: widget.isReversed,
                skinId: widget.skinId,
              ),
              const SizedBox(height: 24),

              // 상세 해석 — ExpansionTile
              DetailExpansionTile(
                card: widget.card,
                isReversed: widget.isReversed,
              ),
              const SizedBox(height: 24),

              // 저장 / 공유 버튼
              Row(
                children: [
                  Expanded(
                    child: CardActionButton(
                      icon: Icons.download_outlined,
                      label: '저장하기',
                      onTap: () => _saveShareImage(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CardActionButton(
                      icon: Icons.share_outlined,
                      label: '공유하기',
                      isPrimary: true,
                      onTap: () => _shareShareImage(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 다시 뽑기 버튼 (광고 시청 후 새 카드)
              if (widget.onRedraw != null)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: widget.onRedraw,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('다시 뽑기 (광고 시청)'),
                    style: TextButton.styleFrom(
                      foregroundColor: kTextSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // [피드백 1-4] 오프스크린 공유 위젯 (캡처 전용)
        // Positioned + 음수 오프셋: 화면 밖에 배치하되 실제 렌더링은 수행
        // Offstage와 달리 toImage() 캡처가 안정적으로 동작함
        Positioned(
          left: -9999,
          top: 0,
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
    );
  }

  /// 공유 위젯을 고해상도 PNG로 캡처
  ///
  /// [피드백 1-4] addPostFrameCallback으로 렌더링 완료 후 캡처
  Future<Uint8List?> _captureShareImage() async {
    // 다음 프레임 렌더링 완료를 기다린 뒤 캡처
    final completer = Future<void>.delayed(Duration.zero);
    await completer;

    try {
      final boundary = _shareRepaintKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Logger.error('CardResult: RepaintBoundary를 찾을 수 없음');
        return null;
      }
      if (boundary.debugNeedsPaint) {
        // 아직 페인트 전이면 한 프레임 더 대기
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      // pixelRatio 3.0 → 360*3=1080, 640*3=1920 (9:16 HD)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Logger.error('CardResult: 이미지 캡처 실패: $e');
      return null;
    }
  }

  /// 갤러리에 저장
  Future<void> _saveShareImage(BuildContext context) async {
    await saveToGallery(context, _captureShareImage, _showSnackBar);
  }

  /// 공유하기
  Future<void> _shareShareImage(BuildContext context) async {
    await shareImage(context, _captureShareImage, _shareText, _showSnackBar);
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
