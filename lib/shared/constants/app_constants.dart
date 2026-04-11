import 'package:flutter/material.dart';

// ==================== 브랜드 색상 상수 ====================

/// Primary 브랜드 색상 — 소프트 라벤더
const Color kBrandColorPrimary = Color(0xFFB8A9E8);

/// Accent 브랜드 색상 — 소프트 골드
const Color kBrandColorAccent = Color(0xFFE8D5A0);

/// Primary 다크 변형
const Color kPrimaryDark = Color(0xFF7C6BB5);

/// 라이트 배경색
const Color kBackgroundLight = Color(0xFFFAFAF7);

/// 다크 배경색
const Color kBackgroundDark = Color(0xFF1A1A2E);

/// 텍스트 Primary
const Color kTextPrimary = Color(0xFF2D2D3A);

/// 텍스트 Secondary
const Color kTextSecondary = Color(0xFF8E8E9A);

// ==================== 레이아웃 상수 ====================

/// 카드 테두리 반경
const double kCardBorderRadius = 16.0;

/// 버튼 테두리 반경
const double kButtonBorderRadius = 12.0;

/// 기본 패딩
const double kDefaultPadding = 16.0;

/// 카드 내부 패딩
const double kCardPadding = 24.0;

/// 기본 카드 수평 마진
const double kCardMarginH = 16.0;

/// 기본 카드 수직 마진
const double kCardMarginV = 8.0;

/// 기본 카드 elevation
const double kCardElevation = 2.0;

// ==================== 앱 전역 상수 ====================

/// 앱 전역 상수 정의 클래스
class AppConstants {
  AppConstants._();

  static const String appName = '매일타로';
  static const String appVersion = '1.0.0';

  // ==================== 광고 관련 ====================

  /// 카드 뽑기 시마다 전면 광고 표시 (임계값 1 = 매번)
  static const int kAdShowThreshold = 1;

  /// 스크린샷 모드 — 디버그 전용, 광고 전체 숨김
  ///
  /// 마케팅 자료 캡처 시 true로 설정.
  /// 프로덕션 빌드에서는 항상 false.
  // ignore: prefer_final_fields
  static bool kScreenshotMode = false;

  // ==================== 스플래시 ====================

  /// 스플래시 화면 최소 표시 시간 (ms)
  static const int kSplashDurationMs = 2000;

  // ==================== 페이지네이션 ====================

  static const int kPageSize = 20;

  // ==================== 법적 요건 URL ====================

  static const String kPrivacyPolicyUrl = 'https://your-app.com/privacy';
  static const String kTermsOfServiceUrl = 'https://your-app.com/terms';

  // ==================== Hive 박스 이름 ====================
  // (HiveBoxes 에도 동일하게 선언되어 있음 — 여기서 단일 소스로 관리)

  // ==================== 카드 스킨 ====================

  static const String kDefaultSkinId = 'default';
  static const String kRiderWaiteSkinId = 'rider_waite';

  // ==================== 타로 설정 ====================

  /// 전체 카드 수
  static const int kTotalCardCount = 78;

  /// 메이저 아르카나 수
  static const int kMajorArcanaCount = 22;
}
