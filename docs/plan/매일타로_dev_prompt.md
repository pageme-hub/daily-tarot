# 매일타로 구현 지시 프롬프트

> 작성일: 2026-03-26 | 업데이트: 2026-04-10
> 작성자: Planner (Opus)
> 대상: developer 에이전트 (또는 Cursor AI에서 직접 실행)
> 참조 PRD: 매일타로_PRD.md (프로젝트 루트)

---

## 사전 준비 사항

이 프롬프트를 실행하기 전에 아래가 준비되어 있어야 합니다:

1. Flutter 프로젝트 리포지토리가 생성되어 있을 것 (daily-tarot)
2. ~~Supabase 프로젝트가 생성되어 있을 것~~ -> 아직 미생성. Step 7에서 Supabase 없이도 동작하는 로컬 fallback 구조를 우선 구현
3. AdMob 앱이 등록되어 있을 것 (앱 ID, 배너/전면 광고 단위 ID 확보)
   - 앱 ID: ca-app-pub-6228549617692783~2944714411
   - 배너 광고 ID: ca-app-pub-6228549617692783/4184473032
   - 전면 광고 ID: ca-app-pub-6228549617692783/9326387997
4. 78장 카드 이미지가 로컬 에셋으로 준비 완료
   - 기본 스킨: `assets/images/cards/default/` (78장 + 카드 뒷면)
   - 라이더 웨이트 원본: `assets/images/cards/rider-waite/` (78장 + 카드 뒷면)

**RULES.md 전문을 반드시 읽고 모든 코드에 반영하세요.**
RULES.md 위치: 프로젝트 루트의 `RULES.md`

---

## 기존 코드 현황

`lib/` 에 아래 파일들이 이미 존재합니다. mumchit-quote 템플릿 기반이며 TODO 마커가 있습니다.
**이 기존 파일들을 반드시 활용하고, 매일타로에 맞게 TODO 부분을 커스터마이징하세요.**
새로 만들지 말고, 기존 파일을 수정하세요.

```
lib/
  core/
    ads/
      ad_conditions_manager.dart   # 광고 표시 조건 관리 (카운트 기반)
      ad_manager.dart              # AdMob SDK 초기화, 광고 ID 관리 (Supabase 연동)
      banner_ad_widget.dart        # 배너 광고 위젯
      interstitial_ad_service.dart # 전면 광고 로드/표시
      rewarded_ad_service.dart     # 리워드 광고 (매일타로에서는 미사용)
    error/
      error_handler.dart           # 에러 핸들러
    firebase/
      firebase_initializer.dart    # Firebase 초기화
    hive/
      hive_boxes.dart              # Hive Box 중앙 관리 (TODO: 모델 등록)
    initialization/
      app_initializer.dart         # 앱 초기화 순서 관리
    review/
      in_app_review_service.dart   # 인앱 리뷰 서비스
    storage/
      local_storage_service.dart   # SharedPreferences 기반 로컬 저장
    supabase/
      supabase_client.dart         # Supabase 초기화/싱글톤 (TODO: .env 설정)
    utils/
      date_formatter.dart          # 날짜 포맷 유틸
      logger.dart                  # 로거
  shared/
    constants/
      app_constants.dart           # 앱 상수 (TODO: 브랜드 색상, 앱 이름 등)
    providers/
      settings_provider.dart       # 설정 Provider
      theme_provider.dart          # 테마 Provider
    theme/
      app_theme.dart               # 앱 테마 정의 (TODO: 색상 커스터마이징)
```

---

## 카드 이미지 파일 네이밍 규칙

실제 에셋 파일들의 네이밍 패턴입니다. 모든 이미지 경로 로직은 이 규칙을 따라야 합니다.

### 기본 스킨 (default)
경로: `assets/images/cards/default/{card_id}.png`

### 라이더 웨이트 (rider-waite)
경로: `assets/images/cards/rider-waite/RWSa-{card_id}.png`

### card_id 규칙
| 분류 | 패턴 | 예시 |
|------|------|------|
| 메이저 아르카나 | `T-{번호 2자리}` | T-00 (Fool), T-01 (Magician), ..., T-21 (World) |
| 완드 (Wands) | `W-{번호}` | W-0A (Ace), W-02~W-10, W-J1 (Page), W-J2 (Knight), W-QU (Queen), W-KI (King) |
| 컵 (Cups) | `C-{번호}` | C-0A, C-02~C-10, C-J1, C-J2, C-QU, C-KI |
| 소드 (Swords) | `S-{번호}` | S-0A, S-02~S-10, S-J1, S-J2, S-QU, S-KI |
| 펜타클 (Pentacles) | `P-{번호}` | P-0A, P-02~P-10, P-J1, P-J2, P-KI, P-QU |
| 카드 뒷면 | `X-BA` | 기본: X-BA.png / RW: RWSa-X-BA.png |

**참고**: T-13 (Death) 이미지는 기본 스킨에 누락 상태. 사용자에게 확인 필요.

---

## Step 1: 프로젝트 초기화

아래 프롬프트를 Cursor에 입력하세요.

```
Flutter 프로젝트 초기 설정을 해줘. RULES.md를 반드시 읽고 준수해.

이 프로젝트는 이미 lib/core/, lib/shared/ 에 템플릿 코드가 있어.
기존 파일들을 최대한 활용하고 TODO 마커를 매일타로에 맞게 채워줘.

### 1. pubspec.yaml 생성

name: daily_tarot
description: 매일타로 - 오늘의 카드 한 장

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  supabase_flutter: ^2.3.0
  google_mobile_ads: ^5.0.0
  go_router: ^14.0.0
  share_plus: ^7.2.0
  flutter_local_notifications: ^17.0.0
  path_provider: ^2.1.0
  flutter_dotenv: ^5.1.0
  intl: ^0.19.0
  permission_handler: ^11.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/cards/default/
    - assets/images/cards/rider-waite/
    - assets/data/
    - .env

**주의**: cached_network_image는 사용하지 않는다. 모든 카드 이미지는 로컬 에셋에서 로드.

### 2. RULES.md 폴더 구조에 맞게 features 디렉토리 생성

기존 core/, shared/ 는 이미 있음. 아래 features 디렉토리만 새로 생성:

lib/
├── main.dart
├── app/
│   ├── routes.dart
│   └── theme.dart        (shared/theme/app_theme.dart를 여기로 re-export하거나 참조)
├── features/
│   ├── card/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── providers/
│   │   └── ui/
│   │       ├── screens/
│   │       └── widgets/
│   ├── collection/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── providers/
│   │   └── ui/
│   │       ├── screens/
│   │       └── widgets/
│   └── settings/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── providers/
│       └── ui/
│           ├── screens/
│           └── widgets/

### 3. .env 파일 생성 (루트에)

SUPABASE_URL=
SUPABASE_ANON_KEY=
ADMOB_APP_ID_ANDROID=ca-app-pub-6228549617692783~2944714411
ADMOB_BANNER_ID_ANDROID=ca-app-pub-6228549617692783/4184473032
ADMOB_INTERSTITIAL_ID_ANDROID=ca-app-pub-6228549617692783/9326387997

(Supabase URL/Key는 비워둠 — 프로젝트 미생성 상태)

### 4. .gitignore에 .env 추가

### 5. 기존 core/initialization/app_initializer.dart 수정
- TODO 마커들을 매일타로에 맞게 채우기
- 앱 초기화 순서 유지

### 6. 기존 core/ads/ad_manager.dart 수정
- _kAppId를 'daily_tarot'로 변경
- 프로덕션 AdMob ID는 .env에서 로드하되, DB 조회 실패 시 .env 값을 fallback으로 사용

### 7. 기존 shared/constants/app_constants.dart 수정

브랜드 색상:
- kBrandColorPrimary: Color(0xFFB8A9E8) (소프트 라벤더)
- kBrandColorAccent: Color(0xFFE8D5A0) (소프트 골드)

앱 상수:
- appName: '매일타로'
- appVersion: '1.0.0'
- kAdShowThreshold: 1 (카드 뽑기 시마다 전면광고)

추가 상수:
- kPrimaryDark: Color(0xFF7C6BB5)
- kBackgroundLight: Color(0xFFFAFAF7)
- kBackgroundDark: Color(0xFF1A1A2E)
- kTextPrimary: Color(0xFF2D2D3A)
- kTextSecondary: Color(0xFF8E8E9A)
- kCardBorderRadius: 16.0
- kButtonBorderRadius: 12.0
- kDefaultPadding: 16.0
- kCardPadding: 24.0

### 8. main.dart 초기화 코드

main.dart에서:
- WidgetsFlutterBinding.ensureInitialized()
- dotenv 로드
- AppInitializer.initialize() 호출
- ProviderScope로 앱 감싸기
- MaterialApp.router 사용 (GoRouter)
- 테마: 라이트/다크 모두 적용, themeMode는 Riverpod으로 관리

### 9. AndroidManifest.xml에 AdMob 앱 ID 메타데이터 추가

<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-6228549617692783~2944714411"/>
```

---

## Step 2: 데이터 모델 + Hive 설정

```
데이터 모델과 Hive 설정을 구현해줘. RULES.md를 준수해.

### 1. 타로 카드 모델 (Supabase + 로컬 JSON 공용)
파일: lib/features/card/data/models/tarot_card.dart

class TarotCard {
  final int id;
  final String cardId;       // 파일명 기반 ID: "T-00", "W-0A", "S-J2" 등
  final String name;         // 영문명: "The Fool"
  final String nameKr;       // 한글명: "바보"
  final String arcana;       // "major" / "minor"
  final String? suit;        // null / "wands" / "cups" / "swords" / "pentacles"
  final int number;          // 메이저: 0~21, 마이너: 1(Ace)~14(King)
  final String uprightMeaning;
  final String reversedMeaning;
  final String uprightMessage;  // 정방향 한 줄 메시지
  final String reversedMessage; // 역방향 한 줄 메시지
  final String? traditionalMeaning; // 올드스쿨 전통 해석 (롱프레스 모달용)
}

- factory fromJson(Map<String, dynamic>) — Supabase JSON 및 로컬 JSON 모두 파싱 가능
- toJson() 메서드
- copyWith() 메서드
- **imageUrl 필드 없음** — 이미지 경로는 getCardImagePath() 헬퍼로 동적 생성

### 2. 일일 카드 캐시 모델 (Hive용)
파일: lib/features/card/data/models/daily_card_cache.dart

@HiveType(typeId: 0)
class DailyCardCache {
  @HiveField(0) final String date;       // "2026-04-10" 형식
  @HiveField(1) final int cardId;        // DB 기준 id (1~78)
  @HiveField(2) final bool isReversed;   // 역방향 여부
  @HiveField(3) final bool hasSeenResult; // 결과를 본 적 있는지 (애니메이션 스킵 판단용)
}

### 3. 카드 히스토리 모델 (Hive용 — 도감에서 뽑은 카드 표시용)
파일: lib/features/collection/data/models/card_history.dart

@HiveType(typeId: 1)
class CardHistory {
  @HiveField(0) final int cardId;
  @HiveField(1) final String lastDrawnDate;
  @HiveField(2) final int drawCount;      // 총 뽑은 횟수
}

### 4. 앱 설정 모델 (Hive용)
파일: lib/features/settings/data/models/app_settings.dart

@HiveType(typeId: 2)
class AppSettings {
  @HiveField(0) final bool notificationEnabled;
  @HiveField(1) final int notificationHour;    // 기본 9
  @HiveField(2) final int notificationMinute;  // 기본 0
  @HiveField(3) final String themeMode;        // "system" / "light" / "dark"
  @HiveField(4) final bool isFirstLaunch;      // 첫 실행 여부 (스플래시 광고 스킵 판단)
  @HiveField(5) final bool hasRequestedNotificationPermission; // 알림 권한 요청 여부
  @HiveField(6) final String activeSkinId;     // 현재 적용 스킨 ID (기본: "default")
}

### 5. Hive typeId 예약 (v1.1 스킨 확장 대비)
- typeId 0: DailyCardCache
- typeId 1: CardHistory
- typeId 2: AppSettings
- typeId 3: (예약) SkinPurchaseCache
- typeId 4: (예약) ActiveSkinCache

### 6. 기존 core/hive/hive_boxes.dart 수정

Box 이름 상수:
  static const String kDailyCardBox = 'daily_card_box';
  static const String kCardHistoryBox = 'card_history_box';
  static const String kAppSettingsBox = 'app_settings_box';

init() 메서드에서:
- 위 모델들의 TypeAdapter 등록
- 각 Box 열기
- Box 접근 getter 메서드 추가

### 7. 카드 이미지 경로 헬퍼
파일: lib/shared/utils/card_image_helper.dart

/// 카드 이미지 에셋 경로를 반환하는 유틸리티.
/// v1.1 스킨 확장 시 이 헬퍼만 수정하면 전체 앱에 반영됨.
class CardImageHelper {
  CardImageHelper._();

  /// 기본 스킨 카드 이미지 경로
  /// skinId: "default" | "rider-waite" | (v1.1에서 추가 스킨)
  /// cardId: "T-00", "W-0A", "S-J2" 등 (파일명 기반)
  static String getCardImagePath(String cardId, {String skinId = 'default'}) {
    if (skinId == 'rider-waite') {
      return 'assets/images/cards/rider-waite/RWSa-$cardId.png';
    }
    // 기본 스킨 및 v1.1 로컬 에셋 스킨
    return 'assets/images/cards/$skinId/$cardId.png';
  }

  /// 카드 뒷면 이미지 경로
  static String getCardBackPath({String skinId = 'default'}) {
    return getCardImagePath('X-BA', skinId: skinId);
  }

  /// v1.1 대비: Supabase Storage URL 생성 (유료 스킨 다운로드용)
  /// 현재는 미사용, 스킨 확장 시 활성화
  // static String getCardImageUrl(String cardId, String skinId, String baseUrl) {
  //   return '$baseUrl/card-images/daily_tarot/$skinId/$cardId.png';
  // }
}

### 8. 로컬 fallback JSON 데이터
파일: assets/data/tarot_cards.json

78장 카드의 텍스트 데이터를 JSON 배열로 준비.
(Supabase 미연결 시에도 앱이 동작하도록 앱 번들에 포함)

[
  {
    "id": 1,
    "card_id": "T-00",
    "name": "The Fool",
    "name_kr": "바보",
    "arcana": "major",
    "suit": null,
    "number": 0,
    "upright_meaning": "새로운 시작, 모험, 순수함...",
    "reversed_meaning": "무모함, 부주의...",
    "upright_message": "새로운 시작을 두려워하지 마세요",
    "reversed_message": "한 걸음 물러서서 생각해볼 때예요",
    "traditional_meaning": "라이더 웨이트 전통 해석: 절벽 끝에 선 젊은이가..."
  },
  ...
]

**중요**: 이 JSON 파일은 사용자가 78장 텍스트 데이터를 완성한 후 채워질 예정.
우선 구조만 만들어두고, 테스트용으로 메이저 아르카나 22장의 샘플 데이터를 넣어줘.

### 9. build_runner 실행하여 .g.dart 파일 생성

flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 3: Riverpod Provider 구성

```
Riverpod Provider들을 구현해줘. RULES.md를 준수해.
- UI에서는 ref.watch, 이벤트 핸들러에서는 ref.read
- Provider는 features/{feature}/providers/ 에 위치

### 1. 카드 데이터 Provider
파일: lib/features/card/providers/card_data_provider.dart

- cardListProvider: 카드 데이터를 로드하는 FutureProvider
  로드 순서:
  1. Supabase 연결 가능하면 -> Supabase에서 fetch (app_id = 'daily_tarot')
  2. Supabase 실패 시 -> 로컬 JSON fallback (assets/data/tarot_cards.json)
  3. 성공한 데이터를 메모리에 캐싱
- cardByIdProvider(int id): Family Provider로 특정 카드 조회
- cardByCardIdProvider(String cardId): cardId("T-00" 등)로 카드 조회

### 2. 일일 카드 Provider
파일: lib/features/card/providers/daily_card_provider.dart

- dailyCardStateProvider: 오늘의 카드 상태를 관리하는 StateNotifierProvider
  상태 타입:
  - notDrawn: 아직 뽑지 않음
  - drawn(TarotCard card, bool isReversed): 뽑기 완료

  로직:
  1. Hive에서 오늘 날짜의 DailyCardCache 확인
  2. 있으면 -> drawn 상태 반환
  3. 없으면 -> notDrawn 상태 반환

- drawCard 메서드:
  - DateTime.now()의 year+month+day+사용자 고유 시드(설치시각)를 시드로 Random 생성
  - 0~77 범위에서 카드 인덱스 선택
  - 50% 확률로 isReversed 결정
  - Hive에 DailyCardCache 저장
  - CardHistory에도 기록 추가/업데이트 (drawCount 증가)

### 3. 도감 Provider
파일: lib/features/collection/providers/collection_provider.dart

- cardHistoryProvider: Hive에서 뽑기 이력을 읽는 Provider (Set<int>로 뽑은 카드 ID 집합)
- collectionFilterProvider: 현재 선택된 필터 StateProvider
  enum CollectionFilter { all, major, wands, cups, swords, pentacles }
- filteredCardsProvider: 필터에 따라 카드 목록을 반환하는 Provider
- collectionStatsProvider: "78장 중 N장 수집" 통계 Provider

### 4. 설정 Provider
파일: lib/features/settings/providers/settings_provider.dart

기존 shared/providers/settings_provider.dart 를 확인하고:
- 기존 파일이 범용 설정이면 그대로 두고, 매일타로 전용 설정은 features/settings/providers/에 생성
- appSettingsProvider: Hive에서 AppSettings를 읽고 쓰는 StateNotifierProvider
  - toggleNotification()
  - setNotificationTime(hour, minute)
  - setThemeMode(mode)
  - markFirstLaunchDone() -> isFirstLaunch = false
  - markNotificationPermissionRequested()

### 5. 광고 Provider (기존 core/ads/ 활용)

기존 core/ads/ 파일들을 활용하되, 아래 로직을 추가:
파일: lib/features/card/providers/ad_state_provider.dart

- splashAdProvider: 스플래시 전면광고 표시 여부 판단
  - isFirstLaunch == true이면 -> 광고 스킵 (마케팅 브리핑 반영)
  - isFirstLaunch == false이면 -> 전면광고 표시
- cardDrawAdProvider: 카드 뽑기 시 전면광고 표시 판단
  - 전면광고 하루 최대 2회 제한
  - 전면광고 간 최소 60초 간격

### 6. 기존 shared/providers/ 정리
- theme_provider.dart: 기존 것을 매일타로 AppSettings.themeMode와 연동
- settings_provider.dart: 기존 것 확인 후 features/settings/providers/와 역할 분리
```

---

## Step 4: 테마 + 라우팅 설정

```
앱 테마와 GoRouter 라우팅을 설정해줘.

### 1. 테마 (기존 shared/theme/app_theme.dart 수정)

기존 파일의 TODO를 채워서 매일타로 디자인 가이드라인에 맞게 수정해줘.

Material 3 기반 테마:

컬러 팔레트:
- Primary: #B8A9E8 (소프트 라벤더)
- Primary Dark: #7C6BB5 (딥 퍼플)
- Secondary: #E8D5A0 (소프트 골드)
- Background (라이트): #FAFAF7 (크림 화이트)
- Background (다크): #1A1A2E (미드나잇 블루)
- Surface: #FFFFFF
- Text Primary: #2D2D3A (차콜)
- Text Secondary: #8E8E9A

타이포그래피 (fontFamily: 'Pretendard', 폴백 'NotoSansKR'):
- headlineMedium: 24sp Bold (카드 이름)
- titleLarge: 20sp Medium (한 줄 메시지)
- bodyLarge: 16sp Regular (상세 해석)
- bodyMedium: 14sp Regular (보조 텍스트)

디자인 토큰:
- Card border radius: 16
- Button border radius: 12
- 기본 padding: 16
- 카드 주변 padding: 24

라이트 테마:
- scaffoldBackgroundColor: #FAFAF7
- appBarTheme: 배경 투명, elevation 0, 텍스트 #2D2D3A
- cardTheme: radius 16, elevation 2, color #FFFFFF

다크 테마:
- scaffoldBackgroundColor: #1A1A2E
- surface: #252540 정도의 약간 밝은 미드나잇
- 카드 이름/메시지 텍스트: 크림 화이트

### 2. GoRouter 라우팅
파일: lib/app/routes.dart

경로:
- /splash -> SplashScreen
- / -> HomeScreen (ShellRoute에 BottomNavigationBar 포함)
- /collection -> CollectionScreen
- /collection/:cardId -> CardDetailScreen
- /settings -> SettingsScreen

ShellRoute로 홈/도감/설정에 공통 BottomNavigationBar 적용:
- 아이콘: 홈(Icons.auto_awesome / 별 아이콘), 도감(Icons.grid_view_rounded), 설정(Icons.settings_outlined)
- 라벨: "오늘의 카드", "도감", "설정"
- 선택 상태 색상: 소프트 라벤더, 비선택: 그레이

초기 경로: /splash
```

---

## Step 5: UI 구현 -- 스플래시 + 홈

```
스플래시 화면과 홈 화면을 구현해줘. RULES.md를 준수해 (setState 금지, Riverpod 사용).

### 1. 스플래시 화면
파일: lib/features/card/ui/screens/splash_screen.dart

- 앱 로고(별 아이콘 또는 카드 모티프) + "매일타로" 텍스트 + 점 애니메이션 인디케이터
- 배경: 크림 화이트 (#FAFAF7), 다크 모드: 미드나잇 블루
- 하단: "오늘의 카드를 불러오는 중..." (그레이, 14sp)
- 로딩 시 작업:
  1. 카드 데이터 로드 (Supabase 시도 -> 실패 시 로컬 JSON fallback)
  2. 전면광고 사전 로드
- 로딩 완료 후:
  1. **isFirstLaunch 체크**: 첫 실행이면 전면광고 스킵 (마케팅 브리핑)
  2. 첫 실행이 아니면 전면광고 표시 (로드 성공 시)
  3. 광고 종료 (또는 실패/스킵) 후 홈 화면으로 GoRouter replace
- 최대 대기 시간 3초 (타임아웃 시 바로 홈으로)

### 2. 홈 화면
파일: lib/features/card/ui/screens/home_screen.dart

#### 상태 A: 카드 미뽑기 상태
- 상단: 날짜 ("4월 10일 목요일") -- intl DateFormat 사용, 한국어 로케일
- 중단: 인사 메시지 "오늘 하루, 어떤 카드가 기다리고 있을까요?" (브랜딩 브리핑 톤앤매너)
- 중앙: 카드 뒷면 이미지 (CardFlipWidget)
  - Image.asset(CardImageHelper.getCardBackPath()) 사용
  - 아래에 "카드를 살짝 터치해보세요" 텍스트 (페이드 애니메이션으로 깜빡임)
- 카드 탭 시:
  1. 전면광고 표시 (isFirstLaunch가 아니고, 오늘 광고 노출 2회 미만일 때)
  2. 카드 뽑기 로직 실행 (drawCard)
  3. 뒤집기 애니메이션 재생
  4. 결과 표시
  5. **첫 뽑기 직후**: hasRequestedNotificationPermission이 false이면 알림 권한 요청 다이얼로그 표시
     "내일도 오늘 같은 메시지를 받아보시겠어요?" -> 확인 시 permission_handler로 알림 권한 요청

#### 상태 B: 카드 이미 뽑은 상태
- 바로 CardResultWidget 표시 (뒤집기 없이)

### 3. 카드 뒤집기 위젯
파일: lib/features/card/ui/widgets/card_flip_widget.dart

- AnimationController (duration: 800ms)
- 앞/뒤 두 개의 위젯을 Transform으로 3D Y축 회전
- 0~90도: 뒷면 보임 (뒤집히는 중)
- 90~180도: 앞면 보임
- 애니메이션 커브: easeInOutCubic
- 뒷면: Image.asset(CardImageHelper.getCardBackPath())
- 앞면: Image.asset(CardImageHelper.getCardImagePath(card.cardId))
  - 역방향이면 이미지를 Transform으로 180도 회전

**주의**: setState를 AnimationController에 사용해야 하는 경우,
ConsumerStatefulWidget + TickerProviderStateMixin을 사용.
애니메이션 상태만 로컬, 카드 데이터는 Riverpod으로 관리.

### 4. 카드 결과 위젯
파일: lib/features/card/ui/widgets/card_result_widget.dart

- 카드 이미지 (큰 사이즈, Image.asset)
- 카드 이름 (한글) + "정방향 -- 에너지가 흐릅니다" 또는 "역방향 -- 내면을 들여다볼 시간" 뱃지
- 한 줄 메시지 (큰 폰트, 볼드, 최소 20sp 이상)
- 상세 해석 (ExpansionTile -- 탭하면 펼쳐짐, "더 보기" 화살표 명시적 표시)
- "저장하기" / "공유하기" 버튼 (Row, 아이콘 + 텍스트)
- 하단 배너 광고 (기존 core/ads/banner_ad_widget.dart 사용)
```

---

## Step 6: UI 구현 -- 도감 + 카드 상세 + 설정

```
카드 도감 화면, 카드 상세 화면, 설정 화면을 구현해줘. RULES.md를 준수해.

### 1. 도감 화면
파일: lib/features/collection/ui/screens/collection_screen.dart

- 상단: "78장 중 N장 수집" 배지 (collectionStatsProvider 사용)
- TabBar: 전체 / 메이저 / 완드 / 컵 / 소드 / 펜타클
- GridView.builder (crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12)
- 각 아이템:
  - Image.asset(CardImageHelper.getCardImagePath(card.cardId)) + 이름
  - 뽑은 적 있는 카드: 풀 컬러
  - 뽑은 적 없는 카드: ColorFiltered로 그레이스케일 + opacity 0.5
  - 뽑은 적 없는 카드 아래: "아직 만나지 못한 카드예요" (브랜딩 브리핑)
- 8번째 아이템마다 네이티브 배너 광고 삽입 (광고 로드 실패 시 다음 카드로 채움)
- 카드 탭 -> CardDetailScreen으로 이동 (뽑은 적 없는 카드도 탭 가능)

### 2. 카드 상세 화면
파일: lib/features/collection/ui/screens/card_detail_screen.dart

- 카드 이미지 (화면 너비 60% 크기, Image.asset)
- 카드 이름 + 번호 (예: "0. 바보 (The Fool)")
- 구분선
- "정방향 의미" 섹션
  - 한 줄 메시지 (강조, 소프트 라벤더 배경 카드)
  - 상세 의미
- "역방향 의미" 섹션
  - 한 줄 메시지 (강조)
  - 상세 의미

#### 올드스쿨 참조 모달 (롱프레스)
- 카드 이미지 또는 해석 영역을 GestureDetector로 감싸서 onLongPress 감지
- 롱프레스 시 showModalBottomSheet 또는 showDialog로 모달 표시:
  - 라이더 웨이트 원본 이미지: Image.asset(CardImageHelper.getCardImagePath(card.cardId, skinId: 'rider-waite'))
  - "전통 해석" 타이틀
  - card.traditionalMeaning 텍스트
  - 닫기 버튼
- **조건**: 현재 activeSkinId가 'rider-waite'이면 이미 원본이므로 롱프레스 비활성화
  (향후 스킨 기능 추가 시 의미 있음, v1.0에서는 기본 스킨만이므로 항상 활성)

- 하단 배너 광고

### 3. 설정 화면
파일: lib/features/settings/ui/screens/settings_screen.dart

ListView 기반, 섹션별 구분:

- 섹션 1: 알림
  - SwitchListTile: 매일 알림 ON/OFF (소프트 라벤더 색상 스위치)
  - ListTile: 알림 시간 설정 (TimePicker 다이얼로그)
  
- 섹션 2: 디스플레이
  - ListTile: 테마 모드 (시스템/라이트/다크 -- SegmentedButton)
  
- 섹션 3: 다른 앱
  - ListTile: 매일오라클 (아이콘 + "감성 오라클 카드" + "준비 중")
  - ListTile: 매일룬 (아이콘 + "바이킹 룬 문자" + "준비 중")

- 섹션 4: 정보
  - ListTile: 앱 버전 (v1.0.0)
  - ListTile: 개인정보처리방침 (Supabase app_privacy에서 URL 로드 or 기본 URL)
  - ListTile: 이용약관 (Supabase app_terms에서 URL 로드 or 기본 URL)
  - Padding: "본 앱은 엔터테인먼트 목적으로 제공됩니다" 면책 문구 (그레이, 12sp)

- 디버그 모드 전용 (kDebugMode 체크):
  - "스크린샷 모드" 토글 (광고 숨김 플래그 -- 마케팅 브리핑 권장)
```

---

## Step 7: Supabase 연동 + 로컬 Fallback

```
Supabase 클라이언트 설정과 카드 데이터 Repository를 구현해줘.
**현재 Supabase 프로젝트 미생성 상태이므로, 로컬 fallback이 반드시 동작해야 함.**

### 1. 기존 core/supabase/supabase_client.dart 수정

TODO 마커를 채워서:
- .env에서 SUPABASE_URL, SUPABASE_ANON_KEY 읽기 (flutter_dotenv 사용)
- URL이 비어있으면 초기화 스킵 (에러 없이)
- 싱글톤 접근: SupabaseClient.client
- isInitialized getter 추가 (URL 비어있으면 false)

### 2. 카드 데이터 Repository
파일: lib/features/card/data/repositories/card_repository.dart

class CardRepository {
  /// 카드 데이터 로드 (Supabase 우선, 실패 시 로컬 fallback)
  Future<List<TarotCard>> fetchAllCards() async {
    // 1차: Supabase 시도 (초기화 되어 있을 때만)
    if (SupabaseClient.isInitialized) {
      try {
        final response = await SupabaseClient.client
            .from('tarot_cards')
            .select()
            .eq('app_id', 'daily_tarot')
            .order('id');
        return response.map((json) => TarotCard.fromJson(json)).toList();
      } catch (e) {
        Logger.error('Supabase fetch failed, falling back to local: $e');
      }
    }

    // 2차: 로컬 JSON fallback
    return _loadFromLocalJson();
  }

  /// assets/data/tarot_cards.json 에서 로드
  Future<List<TarotCard>> _loadFromLocalJson() async {
    final jsonStr = await rootBundle.loadString('assets/data/tarot_cards.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((j) => TarotCard.fromJson(j)).toList();
  }
}

### 3. 앱 설정 Repository
파일: lib/core/supabase/app_config_repository.dart

class AppConfigRepository {
  /// 앱 팝업 조회 (공지, 업데이트, 교차 홍보)
  Future<List<Map<String, dynamic>>> fetchActivePopups() async { ... }

  /// 개인정보처리방침 URL 조회
  Future<String?> fetchPrivacyUrl() async { ... }

  /// 이용약관 URL 조회
  Future<String?> fetchTermsUrl() async { ... }
}

모든 메서드는 Supabase 미초기화/실패 시 null 반환 (앱 크래시 방지).

### 4. 오프라인 대응 정리
- 카드 이미지: 로컬 에셋 -> 항상 동작 (네트워크 불필요)
- 카드 텍스트 데이터: Supabase -> 실패 시 로컬 JSON fallback
- 광고: 네트워크 필요하지만 실패 시 스킵 (UX 중단 없음)
- 앱 팝업/공지: 네트워크 필요, 실패 시 표시 안 함
```

---

## Step 8: 광고 연동

```
Google Mobile Ads (AdMob) 광고를 연동해줘. 기존 core/ads/ 파일들을 활용.

### 1. 기존 core/ads/ad_manager.dart 수정

- _kAppId: 'daily_tarot' (Supabase apps 테이블의 app_id)
- _kAppsTable, _kAdmobIdsTable: 기존 공통 스키마 테이블명 유지
- Supabase 미연결 시 fallback:
  - .env에서 직접 광고 ID 로드
  - 또는 테스트 ID 사용

### 2. 기존 core/ads/banner_ad_widget.dart 확인 및 수정

- 기존 위젯이 AdManager.instance.hasBannerAd 체크하는지 확인
- Supabase 미연결 상태에서도 배너 광고가 표시되도록 fallback 처리
  (hasBannerAd 기본값을 true로 설정하거나, .env 기반 fallback)

### 3. 전면광고 조건 관리 추가
파일: lib/core/ads/ad_conditions_manager.dart 수정

매일타로 전용 조건 추가:
- 하루 최대 전면광고 2회 제한 (Hive에 날짜별 노출 횟수 저장)
- 전면광고 간 최소 60초 간격 (마지막 노출 시각 저장)
- isFirstLaunch이면 스플래시 전면광고 스킵

메서드:
- canShowInterstitial(): bool -- 위 조건 모두 충족하는지 체크
- recordInterstitialShown(): void -- 노출 기록
- isFirstLaunch(): bool -- 첫 실행 여부

### 4. 광고 배치 위치 요약
| 위치 | 유형 | 조건 |
|------|------|------|
| 스플래시 후 | 전면광고 | isFirstLaunch가 아닐 때만 |
| 카드 뽑기 탭 시 | 전면광고 | 하루 2회 이내, 60초 간격 |
| 카드 결과 화면 하단 | 배너 광고 | 항상 (로드 실패 시 빈 공간) |
| 도감 그리드 | 네이티브 배너 | 8아이템마다 (로드 실패 시 다음 카드로) |
| 카드 상세 화면 하단 | 배너 광고 | 항상 |

### 5. 스크린샷 모드 (디버그 전용)
lib/shared/constants/app_constants.dart 에 추가:
- static bool kScreenshotMode = false; (디버그 전용, 광고 전체 숨김)
- BannerAdWidget, InterstitialAdService에서 이 플래그 체크
```

---

## Step 9: 카드 저장/공유 기능

```
카드 결과를 이미지로 저장하고 SNS 공유하는 기능을 구현해줘.
마케팅 브리핑의 공유 이미지 가이드라인을 반영.

### 1. 공유용 이미지 생성
파일: lib/features/card/ui/widgets/share_card_widget.dart

RepaintBoundary로 감싼 공유용 카드 위젯 (화면에 직접 보이지 않는 오프스크린 위젯):
- 크기: 1080x1920 (9:16 비율, 인스타그램 스토리 최적)
- 레이아웃 (마케팅 브리핑 준수):

  ┌──────────────────────────┐
  │  [소프트 라벤더 그라디언트 배경]  │
  │                          │
  │      ┌──────────┐        │
  │      │ 카드 이미지 │        │  <- 전체 높이의 50~55%
  │      └──────────┘        │
  │                          │
  │   "카드 이름"              │  <- 딥 퍼플, Bold, 24sp
  │   "정방향 / 역방향"         │  <- 소프트 라벤더, 14sp
  │                          │
  │  "한 줄 메시지 텍스트"       │  <- 차콜 또는 딥 퍼플, Bold, 22~24sp
  │                          │
  │   2026년 4월 10일          │  <- 그레이, 12sp (날짜 포함!)
  │                          │
  │               ✦ 매일타로   │  <- 하단 우측 코너, 소프트 골드, 12sp
  └──────────────────────────┘

워터마크 규칙:
- 위치: 하단 우측, 여백 12dp
- 구성: 별 아이콘 + "매일타로" 텍스트
- 컬러: 소프트 골드 (#E8D5A0)
- 크기: 이미지 폭의 약 12%

### 2. 저장 기능
파일: lib/features/card/data/repositories/share_repository.dart

- RepaintBoundary의 GlobalKey로 RenderRepaintBoundary 접근
- toImage(pixelRatio: 3.0) -> ByteData -> Uint8List
- path_provider로 임시 디렉토리에 PNG 저장
- 갤러리 저장 (gal 패키지 또는 image_gallery_saver 활용)
  -> pubspec.yaml에 해당 패키지 추가 필요
- 저장 완료 시 SnackBar 알림: "카드가 갤러리에 저장되었어요"

### 3. 공유 기능
- 저장된 이미지 파일을 share_plus의 Share.shareXFiles()로 공유
- 공유 텍스트: "오늘 나의 타로 카드는 '{카드이름(한글)}'이에요 ✦ #매일타로 #오늘의타로"
- 공유 실패 시 SnackBar 에러 메시지
```

---

## Step 10: 알림 설정

```
매일 알림 기능을 구현해줘.

### 파일: lib/features/settings/data/repositories/notification_repository.dart

- flutter_local_notifications 패키지 사용
- 알림 채널 ID: "daily_tarot_channel"
- 알림 채널명: "매일타로 알림"
- 알림 내용:
  - 제목: "매일타로"
  - 본문: "오늘의 카드가 기다리고 있어요" (브랜딩 브리핑 톤앤매너)
- 매일 반복 알림 (설정된 시간, 기본 09:00)
- 알림 탭 시 앱 실행

### 알림 권한 요청 타이밍 (마케팅 브리핑 핵심!)

알림 권한은 설정 화면에서만 요청하지 않는다.
**첫 카드 뽑기 결과 확인 직후** 맥락 기반으로 요청:

1. dailyCardStateProvider가 drawn 상태로 전환될 때
2. hasRequestedNotificationPermission이 false이면
3. 1~2초 딜레이 후 다이얼로그 표시:
   - 타이틀: "내일도 카드를 받아볼까요?"
   - 본문: "매일 아침 알림으로 오늘의 카드를 알려드릴게요"
   - 확인 버튼: "좋아요" -> permission_handler로 알림 권한 요청 + 알림 등록
   - 취소 버튼: "나중에" -> markNotificationPermissionRequested()
4. 한 번만 요청 (hasRequestedNotificationPermission으로 추적)

### 설정과 연동:
- AppSettings의 notificationEnabled 변경 시 알림 ON/OFF
- 시간 변경 시 기존 알림 취소 -> 새 시간으로 재등록

### Android 설정:
- AndroidManifest.xml에 RECEIVE_BOOT_COMPLETED 퍼미션
- POST_NOTIFICATIONS 퍼미션 (Android 13+)
- 알림 아이콘 리소스: @mipmap/ic_launcher 사용 (별도 아이콘 없을 때)
```

---

## Step 11: 테스트 체크리스트

개발 완료 후 아래 항목을 모두 확인하세요.

### 기능 테스트
- [ ] 앱 최초 실행 시 스플래시 -> (전면광고 스킵) -> 홈 화면 정상 전환
- [ ] 두 번째 실행부터 스플래시 -> 전면광고 -> 홈 화면 정상 전환
- [ ] 카드 뒷면 탭 시 전면광고 표시 후 뒤집기 애니메이션 재생
- [ ] 뒤집기 후 카드 이름, 방향, 한 줄 메시지 정상 표시
- [ ] 같은 날 재실행 시 동일한 카드 결과 표시 (일일 고정, 뒤집기 애니메이션 스킵)
- [ ] 날짜가 바뀌면 새 카드 뽑기 가능
- [ ] 카드 결과 확인 직후 알림 권한 요청 다이얼로그 표시 (첫 뽑기 시 1회만)
- [ ] 카드 도감에서 78장 전체 표시 + "78장 중 N장 수집" 배지
- [ ] 도감 필터 (메이저/수트별) 정상 동작
- [ ] 뽑은 적 있는 카드 컬러, 없는 카드 그레이스케일 구분
- [ ] 카드 상세 화면에서 정방향/역방향 의미 표시
- [ ] 카드 상세 화면에서 롱프레스 -> 라이더 웨이트 원본 + 전통 해석 모달 표시
- [ ] 카드 결과 이미지 저장 정상 동작 (9:16 비율, 날짜 포함, 워터마크 우하단)
- [ ] 카드 결과 SNS 공유 정상 동작 (카카오톡, 인스타그램)
- [ ] 알림 ON/OFF 정상 동작
- [ ] 알림 시간 변경 정상 동작
- [ ] 다크모드 전환 정상 동작
- [ ] 설정 화면 모든 항목 정상 표시
- [ ] Supabase 미연결 상태에서 로컬 JSON fallback으로 정상 동작

### 카드 이미지 테스트
- [ ] 78장 기본 스킨 이미지 모두 정상 로드 (Image.asset)
- [ ] 라이더 웨이트 원본 78장 모두 정상 로드 (롱프레스 모달)
- [ ] 카드 뒷면 이미지 정상 표시
- [ ] 역방향 카드 180도 회전 정상 표시
- [ ] T-13 (Death) 이미지 존재 확인 (현재 누락 의심 -> 사용자에게 확인)

### 광고 테스트
- [ ] 스플래시 후 전면광고 -- 첫 실행 시 스킵, 이후 표시 (테스트 ID)
- [ ] 카드 뽑기 시 전면광고 표시 (테스트 ID)
- [ ] 전면광고 하루 2회 제한 정상 동작
- [ ] 전면광고 간 60초 간격 제한 정상 동작
- [ ] 카드 결과 화면 배너 광고 표시
- [ ] 카드 상세 화면 배너 광고 표시
- [ ] 도감 그리드 네이티브 배너 표시 (8아이템마다)
- [ ] 광고 로드 실패 시 UX 중단 없음 (빈 공간 또는 다음 카드로 채움)
- [ ] 스크린샷 모드(디버그) 활성화 시 모든 광고 숨김

### RULES.md 준수 확인
- [ ] setState 사용 없음 (AnimationController 관련만 예외)
- [ ] 모든 Provider가 features/{feature}/providers/ 에 위치
- [ ] Hive TypeAdapter에 @HiveType 어노테이션 + 고유 typeId (0~2 사용, 3~4 예약)
- [ ] Supabase 클라이언트가 core/supabase/에서 싱글톤
- [ ] .env에 민감 정보 (Supabase key, AdMob ID) 격리
- [ ] magic number 없음 (상수로 추출)
- [ ] print() 없음 (debugPrint 또는 Logger 사용)
- [ ] 파일 300줄 이하
- [ ] 파일명 snake_case, 클래스명 PascalCase

### 빌드 확인
- [ ] flutter analyze 경고/에러 없음
- [ ] flutter build apk --release 정상 빌드
- [ ] 실기기/에뮬레이터에서 크래시 없음

---

## 다음 단계

### A (에이전트 주도)
- [ ] @reviewer: `lib/` 전체 코드 리뷰 (RULES.md 위반 체크)
- [ ] @marketer: 스토어 등록 정보 최종 준비 (스크린샷 가이드, 설명 문구)

### B (협업)
- [ ] 사용자 + @developer: 카드 뒷면 디자인 최종 선정 -> 현재 X-BA.png 확인
- [ ] 사용자: 78장 카드 텍스트 데이터 완성 -> assets/data/tarot_cards.json 에 반영

### C (사용자 주도)
- [ ] 사용자: Supabase 프로젝트 생성 + PRD의 DDL 실행 + .env에 URL/Key 입력
- [ ] 사용자: Supabase에 78장 카드 텍스트 데이터 INSERT (SQL 또는 CSV)
- [ ] 사용자: T-13 (Death) 카드 이미지 확인 및 보충
- [ ] 사용자: 앱 아이콘 제작 (마케팅 브리핑의 디자인 방향 참조)
- [ ] 사용자: 스크린샷 촬영 (에뮬레이터 또는 실기기, 스크린샷 모드 활용)
- [ ] 사용자: Play Console 앱 등록 + 정보 입력
- [ ] 사용자: 서명된 AAB 빌드 + Play Console 업로드
