# 매일타로 — 제작 체크리스트

> app-factory의 production_checklist.md를 매일타로에 맞게 적용.
> [A/B/C]는 주도자 유형.

---

## Gate 2: 개발 (현재 단계)

### 2-1. 환경 설정 (C)

- [x] Flutter 프로젝트 생성
- [x] template/ 코드 복사 → `lib/core/`, `lib/shared/`
- [ ] Supabase 프로젝트 설정 + DDL 실행
- [ ] `.env` 파일 설정
- [ ] AdMob 앱 등록 + 광고 단위 생성
- [ ] `admob_ids` 테이블에 테스트 광고 ID 등록
- [ ] Firebase 프로젝트 + Crashlytics 설정

### 2-2. 코드 구현 (A)

- [ ] dev prompt 기반 구현
  - [ ] 데이터 모델 + Hive (TarotCard, DailyCardCache, CardHistory, AppSettings)
  - [ ] Riverpod Provider 구성
  - [ ] 스플래시 + 홈 (카드 뽑기, 3D 뒤집기 애니메이션)
  - [ ] 도감 (78장 그리드, 탭 필터)
  - [ ] 카드 저장/공유 (RepaintBoundary + share_plus)
  - [ ] 설정 화면
  - [ ] Supabase 연동 (cards, app_config)
  - [ ] AdMob 광고 (전면 + 배너)
  - [ ] 이용약관·개인정보처리방침 페이지
  - [ ] 알림 설정 (flutter_local_notifications)

### 2-3. 코드 리뷰 (A)

- [ ] @reviewer RULES.md 위반 체크
- [ ] @reviewer 버그·크래시 탐지
- [ ] @reviewer PRD 기능 대조
- [ ] Critical 이슈 수정

### 2-4. 기능 검증 (B)

- [ ] 에뮬레이터/실기기 핵심 기능 동작 확인
- [ ] 광고 표시 확인 (테스트 ID)
- [ ] 오프라인 대응 확인
- [ ] 앱 재시작 후 데이터 유지 확인

---

## Gate 3: 스토어 준비

### 에이전트 작업 (A)

- [ ] @marketer 스토어 등록 정보 (KO/EN)
- [ ] @marketer 스크린샷 문구
- [ ] @marketer ASO 전략

### 사용자 작업 (C)

- [ ] 앱 아이콘 제작 (512x512, 라벤더 톤)
- [ ] 기능 그래픽 (1024x500)
- [ ] 스크린샷 5~8장 제작
- [ ] Play Console 앱 정보 입력
  - [ ] 카테고리: 라이프스타일 / 엔터테인먼트
  - [ ] 콘텐츠 등급 설문
  - [ ] 데이터 안전성
  - [ ] 개인정보처리방침 URL
  - [ ] 타겟 연령층
  - [ ] 광고 포함 선언

---

## Gate 4: 비공개 테스트

- [ ] 서명된 AAB 빌드
- [ ] 비공개 테스트 트랙 업로드
- [ ] 테스터 그룹 설정 + 테스트 링크
- [ ] 피드백 수집 (최소 3일)
- [ ] 피드백 기반 버그 수정
- [ ] 재테스트

---

## Gate 5: 프로덕션 출시

### 출시 전

- [ ] 프로덕션 광고 ID 전환 (.env + admob_ids use_production)
- [ ] 프로덕션 AAB 빌드
- [ ] 최종 테스트
- [ ] @marketer 릴리즈 노트 작성

### 출시

- [ ] 프로덕션 트랙 업로드
- [ ] Google 심사 대기
- [ ] Crashlytics 모니터링 시작

### 출시 후

- [ ] app-factory release_tracker.md 업데이트
- [ ] @marketer 포트폴리오 작성
- [ ] 파생 앱 (매일오라클) 제작 시작 여부 결정
- [ ] v1.1 기능 개선 목록 정리
