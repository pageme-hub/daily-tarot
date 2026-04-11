import 'package:flutter/material.dart';

/// InterstitialAdService 웹 스텁 — 웹에서는 전면 광고 미지원
class InterstitialAdService {
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();
  static InterstitialAdService get instance => _instance;
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  Future<void> loadAd() async {}

  Future<void> showAd({VoidCallback? onAdDismissed}) async {
    onAdDismissed?.call();
  }

  void dispose() {}
}
