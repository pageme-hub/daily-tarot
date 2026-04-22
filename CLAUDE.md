# 매일타로 — Claude Code 지침

## 프로젝트 개요

**매일타로** — MZ 감성 미니멀 1일 1타로 앱. 앱 공장(App Factory) 시스템으로 제작.

- 패키지명: `com.pageme.daily_tarot`
- 타겟: 20~35세 여성, MZ세대
- 핵심 컨셉: "타로계의 명언 앱" — 하루 1장 30초 경험

## 핵심 규칙

1. **RULES.md 준수** — 모든 코드는 RULES.md 기술 스택 및 규칙을 따를 것
2. **MVP 3기능** — 오늘의 카드 뽑기 / 카드 도감 / 카드 저장·공유
3. **production_checklist.md 참조** — Gate별 체크리스트를 따를 것
4. **PRD 참조** — `docs/plan/매일타로_PRD.md`가 기능 명세의 SSoT

## 참조 문서

| 문서 | 용도 |
|------|------|
| `docs/plan/매일타로_PRD.md` | 기능 명세, 화면 목록, 컬러 팔레트, 광고 배치 |
| `docs/plan/매일타로_dev_prompt.md` | 단계별 구현 지시 |
| `RULES.md` | Flutter 코딩 규칙 |
| `docs/TEAM_WORKFLOW.md` | 에이전트 워크플로우, Gate별 프로세스 |
| `docs/production_checklist.md` | Gate 0~5 제작 체크리스트 |
| `docs/marketing/스토어출시_브리핑.md` | 스토어 등록 정보 |

## Supabase 공통 스키마 (Cross-Repo)

- 공통 DB 스키마 문서: `../../app-factory/docs/supabase_공통_스키마.md` (`~/dev/app-factory/docs/supabase_공통_스키마.md`)
- **구현 시작 시**: 위 파일을 반드시 읽고, 기존 테이블 구조를 숙지한 뒤 작업할 것
- **DB 구조 변경 시** (컬럼 추가/수정/삭제, 새 공통 테이블 추가):
  - 위 스키마 문서를 해당 변경 사항에 맞게 직접 수정할 것
  - 앱 고유 테이블(이 앱에서만 쓰는 테이블)은 스키마 문서에 추가하지 않음 — PRD에서 관리

## 에이전트 모델

| 에이전트 | 모델 |
|---------|------|
| planner | **Opus** |
| reviewer | **Opus** |
| developer | Sonnet |
| marketer | Sonnet |
| researcher | Sonnet |

## 현재 상태

- **[비공개 테스트] D-13/14, 프로덕션 첫 출시 = v1.1** (2026-04-21 기준) — 오늘 AAB 업로드 예정, 내일 D14 프로덕션 트랙 전환
- **버전 체계 예외**: 위키 `release_gates.md` 원칙상 프로덕션 첫 출시는 v1.0이나, 기준 세우기 전에 이미 `1.0.0+1`로 비공개를 시작한 히스토리로 **v1.1로 명명** (pubspec `1.1.0+2`). 차후 앱은 v0.1~v0.14 → v1.0 엄수.
- 위키 v1.0 출시 기준 10개 전부 충족: Analytics 12개(위키 규격) / UMP+AdMob GDPR·CCPA / 법적 URL(legal-doc edge function) / PermissionManager(notification only, Android 단독) / 컨텍스트 권한 요청 / 공유 카드 날짜 / 빈 상태 / 저작권 표기 / 알림 카피 5개 순환
- 인프라 검증 완료(2026-04-21): Supabase `apps`/`app_legal`×2(privacy·terms/ko)/`admob_ids`/`required_permissions` 전부 등록, `legal-doc` edge function 치환 정상
- 남은 작업: 오늘 v0.x AAB 빌드·업로드 + 실기기 회귀(Analytics DebugView 12개 발화 + UMP 폼 + Crashlytics 0건 24h) → 내일 v0.14 프로덕션 트랙 업로드
- 파생 앱: 매일오라클(44장), 매일룬(24개) — 매일타로 D7 리텐션 게이트 통과 후 코딩 착수 (CLAUDE.md 규칙 9)
