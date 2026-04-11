import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 갤러리에 저장 — 웹 스텁 (미지원)
Future<void> saveToGallery(
  BuildContext context,
  Future<Uint8List?> Function() captureImage,
  void Function(BuildContext, String) showSnackBar,
) async {
  showSnackBar(context, '웹에서는 저장 기능을 지원하지 않아요');
}

/// 공유하기 — 웹 스텁 (미지원)
Future<void> shareImage(
  BuildContext context,
  Future<Uint8List?> Function() captureImage,
  String shareText,
  void Function(BuildContext, String) showSnackBar,
) async {
  showSnackBar(context, '웹에서는 공유 기능을 지원하지 않아요');
}
