# App Factory — Flutter 프로젝트 규칙 (RULES.md)

> 모든 코드 생성·수정 시 이 규칙을 반드시 준수한다.

---

## 1. 프로젝트 스택

| 레이어 | 기술 |
|--------|------|
| UI | Flutter (Material 3) |
| 상태관리 | Riverpod (StateNotifierProvider / AsyncNotifierProvider) |
| 로컬 저장 | Hive (TypeAdapter 자동 생성, @HiveType 어노테이션) |
| 백엔드 | Supabase (auth, database, storage) |
| 광고 | Google Mobile Ads (배너 + 전면광고 필수) |
| 분석 | Firebase Crashlytics |

---

## 2. 폴더 구조

```
lib/
├── main.dart
├── app/
│   ├── routes.dart          # GoRouter
│   └── theme.dart           # ThemeData
├── features/
│   └── {feature}/
│       ├── data/
│       │   ├── models/      # Hive TypeAdapter 포함
│       │   └── repositories/
│       ├── providers/       # Riverpod providers
│       └── ui/
│           ├── screens/
│           └── widgets/
├── shared/
│   ├── widgets/             # 공통 위젯
│   ├── constants/
│   └── utils/
└── core/
    ├── supabase/            # Supabase 초기화, 클라이언트
    ├── ads/                 # Admob 공통 모듈
    ├── cache/               # Hive 기반 오프라인 캐시
    └── notification/        # FCM 푸시 알림
```

---

## 3. 코드 규칙

### 3-1. 상태관리
- Provider는 반드시 `features/{feature}/providers/` 에 위치
- `ref.watch` / `ref.read` 혼용 금지 — UI에서는 `watch`, 이벤트 핸들러에서는 `read`
- StateNotifier 상태는 immutable (copyWith 사용)
- 비동기 작업은 `AsyncNotifierProvider` 사용

### 3-2. Hive
- 모델 파일에 `@HiveType(typeId: N)` 명시 (typeId 중복 금지)
- `build_runner`로 어댑터 자동 생성 (`*.g.dart`)
- Box는 `core/hive/` 에서 중앙 관리

### 3-3. Supabase
- 클라이언트는 `core/supabase/supabase_client.dart` 에서 싱글톤
- Row Level Security (RLS) 반드시 활성화
- 민감 정보는 `.env` — 코드에 하드코딩 금지

### 3-4. 광고 (필수)
- 스플래시 화면 종료 후 전면광고 1회
- 모든 주요 화면 하단 배너 광고
- 테스트 빌드: 테스트 광고 ID 사용
- 프로덕션 빌드: 실제 광고 ID (환경변수로 분리)

### 3-5. 네이밍
- 파일: `snake_case.dart`
- 클래스: `PascalCase`
- 변수·함수: `camelCase`
- 상수: `kCamelCase` (k 접두사)
- Provider: `{name}Provider` 또는 `{name}NotifierProvider`

### 3-6. 외부 서비스 호출
- Supabase DB 조회, FCM, AdMob 등 **외부 서비스 호출에 반드시 타임아웃 적용** (DB: 5초, AdMob: 10초)
- **초기화 실패 시 앱 크래시 금지** — try-catch + graceful fallback 필수
- 광고 DB 조회 실패 시: 테스트 모드 광고 활성화 (수익 보호)
- 비핵심 비동기 작업(전면광고 프리로드 등)은 `.then()` fire-and-forget 패턴 사용

### 3-7. 금지 사항
- `setState` 사용 금지 (Riverpod으로 대체)
- `BuildContext`를 Provider나 Repository에 전달 금지
- magic number 직접 사용 금지 — **UI 수치(마진·패딩·높이 등)는 반드시 `app_constants.dart` 상수로 정의**
- `print()` 사용 금지 — `debugPrint()` 또는 logger 사용

---

## 4. MVP 범위 제한

- 핵심 기능 **3개 이하** 로 제한
- "있으면 좋겠다" 기능은 TODO 주석으로 남기고 미구현
- 첫 출시 시 다국어(l10n) 미적용 가능 (한국어 우선)

---

## 5. 산출물 기준

### 개발 완료 기준
- [ ] 핵심 기능 정상 동작
- [ ] 광고 연동 완료 (테스트 ID)
- [ ] 크래시 없음 (Crashlytics 확인)
- [ ] RULES.md 위반 없음 (reviewer 검수)

### 코드 품질
- [ ] 불필요한 import 없음
- [ ] dead code 없음
- [ ] 파일당 300줄 이하 권장
