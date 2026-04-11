# 매일타로 — Claude Code 지침

## 프로젝트 개요

**매일타로** — MZ 감성 미니멀 1일 1타로 앱. 앱 공장(App Factory) 시스템으로 제작.

- 패키지명: `com.appfactory.maeil_tarot`
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

- 공통 DB 스키마 문서: `/mnt/c/Users/user/dev/app-factory/app-factory/docs/supabase_공통_스키마.md`
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

- Gate 2 (개발) 진행 중
- 파생 앱: 매일오라클(44장), 매일룬(24개) — 매일타로 출시 후 3~5일 제작
