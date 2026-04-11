# 매일타로 — Agent Team 워크플로우

> 이 문서는 앱 리포용 워크플로우. 기획 단계 프로세스는 app-factory 리포 참조.

## 팀 구성

| 에이전트 | 모델 | 역할 |
|---------|------|------|
| planner | **Opus** | dev prompt 작성, 기능 개선 기획 |
| developer | Sonnet | Flutter 코드 직접 구현 |
| reviewer | **Opus** | 코드 리뷰·QA·RULES.md 위반 체크 |
| marketer | Sonnet | ASO·스토어 등록·스크린샷 문구 |
| researcher | Sonnet | 추가 시장 분석 (필요시) |

---

## 앱 리포 워크플로우

```
PRD (app-factory에서 가져옴)
    │
    ▼
planner     →  docs/plan/{앱명}_dev_prompt.md
    │
    ├──────────────────────┐
    ▼                      ▼
developer               marketer
lib/ 코드 직접 구현      docs/marketing/ 산출물 작성
    │
    ▼
reviewer    →  docs/review/{앱명}_review_{날짜}.md
```

---

## 에이전트 호출

```
@planner 매일타로_PRD.md 참고하여 dev prompt 작성해줘

@developer docs/plan/매일타로_dev_prompt.md 기반으로 코드 구현해줘

@reviewer lib/ 전체 코드 리뷰해줘

@marketer 매일타로 스토어 등록 정보 작성해줘
```

---

## 폴더 권한

| 에이전트 | 쓰기 가능 폴더 |
|---------|--------------|
| planner | `docs/plan/` |
| developer | `lib/` |
| reviewer | `docs/review/` |
| marketer | `docs/marketing/`, `docs/store/` |
| researcher | `docs/research/` |

---

## Gate별 프로세스 (앱 리포 기준)

> 상세 체크리스트: `docs/production_checklist.md`

### Gate 2: 개발

| 단계 | 유형 | 담당 |
|------|------|------|
| dev prompt 작성 | A | planner |
| 코드 구현 | A | developer |
| 이용약관·개인정보 페이지 | A | developer |
| 코드 리뷰 | A | reviewer |
| Critical 수정 | A | developer |
| 기능 동작 확인 | B | 사용자 에뮬레이터 테스트 |

### Gate 3: 스토어 준비

| 단계 | 유형 | 담당 |
|------|------|------|
| 스토어 등록 정보 | A | marketer |
| 스크린샷 문구 | A | marketer |
| ASO 전략 | A | marketer |
| 앱 아이콘 제작 | C | 사용자 |
| 스크린샷 제작 | C | 사용자 |
| Play Console 정보 입력 | C | 사용자 |

### Gate 4: 비공개 테스트

| 단계 | 유형 | 담당 |
|------|------|------|
| 서명된 AAB 빌드 | C | 사용자 |
| 비공개 테스트 업로드 | C | 사용자 |
| 피드백 기반 버그 수정 | A | developer |

### Gate 5: 프로덕션 출시

| 단계 | 유형 | 담당 |
|------|------|------|
| 프로덕션 광고 ID 전환 | C | 사용자 |
| 릴리즈 노트 작성 | A | marketer |
| 프로덕션 출시 | C | 사용자 |
| 출시 후 모니터링 | C | 사용자 |

---

## 주도자 유형

| 유형 | 설명 |
|------|------|
| **A** (에이전트 주도) | 에이전트에게 맡기고 결과만 확인 |
| **B** (협업) | 에이전트 초안 → 사용자 의사결정 |
| **C** (사용자 주도) | 사용자 직접 수행 |

---

## 인수인계 프로토콜

모든 에이전트 산출물 끝에 "다음 단계" 포함:

```markdown
---
## 다음 단계

### A (에이전트 주도)
- [ ] @{에이전트}: {지시}

### B (협업)
- [ ] {의사결정 항목}

### C (사용자 주도)
- [ ] {사용자 작업}
```

---

## 파생 앱 제작 가이드

매일타로 출시 후 매일오라클·매일룬 파생:

1. 이 리포 복제
2. 패키지명·앱 이름 변경
3. Supabase 카드 데이터 교체 (타로 78장 → 오라클 44장 / 룬 24개)
4. 테마 컬러 변경
5. AdMob 새 앱/광고 단위 등록
6. marketer 스토어 등록 정보 재작성

예상 소요: 3~5일
