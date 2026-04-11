# 웹 플랫폼 분기 처리 작업 내역

> 2026-04-11 매일타로에서 작업 완료. app-factory 템플릿에 반영 필요.

## 목적

Flutter 앱을 GitHub Pages 등 웹으로 배포할 때, 모바일 전용 패키지(`google_mobile_ads`, `firebase_crashlytics`, `flutter_local_notifications`, `gal` 등)가 웹 컴파일을 깨뜨리는 문제를 해결.

## 핵심 패턴: 조건부 임포트 barrel

`dart.library.html`을 사용한 조건부 export로, 웹 빌드 시 모바일 전용 코드가 컴파일 대상에서 완전히 제외됨.

```dart
// ad_manager.dart (barrel)
export 'ad_manager_mobile.dart'
    if (dart.library.html) 'ad_manager_web.dart';
```

- 모바일 빌드: `_mobile.dart` 사용 (기존 코드 그대로)
- 웹 빌드: `_web.dart` 사용 (no-op 스텁)
- 기존 import 경로 변경 없음 — 다른 파일에서 `import 'ad_manager.dart'` 그대로 유지

## 변환 대상 모듈 (7개)

| barrel 파일 | mobile | web stub | 웹 동작 |
|---|---|---|---|
| `core/ads/ad_manager.dart` | `ad_manager_mobile.dart` | `ad_manager_web.dart` | `hasBannerAd=false`, 모든 getter 빈 문자열, `initialize()` no-op |
| `core/ads/banner_ad_widget.dart` | `banner_ad_widget_mobile.dart` | `banner_ad_widget_web.dart` | `SizedBox.shrink()` 반환 |
| `core/ads/interstitial_ad_service.dart` | `interstitial_ad_service_mobile.dart` | `interstitial_ad_service_web.dart` | `showAd()` 즉시 `onAdDismissed` 콜백 실행 |
| `core/ads/rewarded_ad_service.dart` | `rewarded_ad_service_mobile.dart` | `rewarded_ad_service_web.dart` | `showAd()` 즉시 `onRewarded` 콜백 실행 (광고 없이 리워드 지급) |
| `core/notifications/notification_service.dart` | `notification_service_mobile.dart` | `notification_service_web.dart` | 모든 메서드 no-op |
| `core/firebase/firebase_initializer.dart` | `firebase_initializer_mobile.dart` | `firebase_initializer_web.dart` | `initialize()` no-op |
| `core/error/error_handler.dart` | `error_handler_mobile.dart` | `error_handler_web.dart` | Crashlytics 없이 `debugPrint`로 콘솔 출력만 |

## card_result_widget.dart 저장/공유 분리

`gal`, `dart:io`, `path_provider`, `share_plus`를 사용하는 저장/공유 로직을 별도 헬퍼로 추출하고 조건부 임포트 적용.

```
features/card/ui/widgets/
├── card_save_helper.dart          ← 조건부 임포트 (모바일: gal+share_plus)
├── card_save_helper_web.dart      ← 웹 스텁 ("웹에서는 지원하지 않아요" 스낵바)
└── card_result_widget.dart        ← import 'card_save_helper.dart' if (dart.library.html) '..._web.dart'
```

## 웹 스텁 작성 규칙

1. **같은 public API 유지** — 클래스명, 메서드 시그니처, 싱글톤 패턴 동일
2. **콜백은 즉시 실행** — `showAd(onAdDismissed: cb)` → 웹에서 `cb()` 즉시 호출 (UI 흐름 안 끊김)
3. **모바일 전용 import 금지** — 웹 스텁에는 `dart:io`, `google_mobile_ads` 등 절대 import하지 않음
4. **ErrorHandler 웹 버전** — `FlutterError.onError`와 `PlatformDispatcher.instance.onError`는 설정하되, Crashlytics 대신 `debugPrint` 사용

## 템플릿 반영 시 체크리스트

- [ ] 위 7개 모듈 각각 `_mobile.dart` + `_web.dart` + barrel 구조로 분리
- [ ] `card_save_helper.dart` / `card_save_helper_web.dart` 헬퍼 추가
- [ ] `card_result_widget.dart`에서 `gal`, `dart:io`, `path_provider`, `share_plus` 직접 import 제거 → 헬퍼 조건부 import로 대체
- [ ] 기존 import 경로 변경 없음 확인 (barrel이 동일 파일명이므로)
- [ ] `flutter build web --release --base-href "/<repo>/"` 빌드 테스트
- [ ] GitHub Pages 배포 가이드 (`docs/user/github_pages_배포_가이드.md`) 포함
