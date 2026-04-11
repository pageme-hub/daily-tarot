import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/logger.dart';

/// 갤러리에 저장 (모바일 전용)
Future<void> saveToGallery(
  BuildContext context,
  Future<Uint8List?> Function() captureImage,
  void Function(BuildContext, String) showSnackBar,
) async {
  try {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        if (context.mounted) showSnackBar(context, '갤러리 접근 권한이 필요해요');
        return;
      }
    }

    final bytes = await captureImage();
    if (bytes == null) {
      if (context.mounted) showSnackBar(context, '이미지 생성에 실패했어요');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/maeil_tarot_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    await Gal.putImage(file.path, album: '매일타로');
    await file.delete();
    if (context.mounted) showSnackBar(context, '갤러리에 저장되었어요');
  } catch (e) {
    Logger.error('CardResult: 갤러리 저장 실패: $e');
    if (context.mounted) showSnackBar(context, '저장에 실패했어요');
  }
}

/// 공유하기 (모바일 전용)
Future<void> shareImage(
  BuildContext context,
  Future<Uint8List?> Function() captureImage,
  String shareText,
  void Function(BuildContext, String) showSnackBar,
) async {
  final bytes = await captureImage();
  if (bytes == null) {
    if (context.mounted) showSnackBar(context, '공유 이미지 생성에 실패했어요');
    return;
  }
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tarot_share.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
    );
  } catch (e) {
    Logger.error('CardResult: 공유 실패: $e');
    if (context.mounted) showSnackBar(context, '공유에 실패했어요');
  }
}
