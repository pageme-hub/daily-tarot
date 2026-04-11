# GitHub Pages 웹 배포 가이드

매일타로를 GitHub Pages로 배포하여 웹에서 체험할 수 있도록 하는 가이드.

## 사전 준비

- Flutter SDK (웹 빌드 지원 확인: `flutter devices`에 Chrome 표시)
- GitHub 리포지토리: `pageme-hub/daily-tarot`

## 1. 웹 빌드

GitHub Pages는 `https://<username>.github.io/<repo>/` 경로로 서빙되므로 `--base-href`를 반드시 지정한다.

```bash
flutter build web --release --base-href "/daily-tarot/"
```

빌드 결과물은 `build/web/`에 생성된다.

## 2. 배포 방법

### 방법 A: GitHub Actions 자동 배포 (권장)

`.github/workflows/deploy-web.yml` 파일을 생성한다:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:  # 수동 실행 가능

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - run: flutter pub get
      - run: flutter build web --release --base-href "/daily-tarot/"

      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

설정 후 main에 push하면 자동으로 배포된다.

### 방법 B: 수동 배포 (gh-pages 브랜치)

```bash
# 1. 웹 빌드
flutter build web --release --base-href "/daily-tarot/"

# 2. gh-pages 브랜치에 배포
cd build/web
git init
git checkout -b gh-pages
git add .
git commit -m "Deploy to GitHub Pages"
git remote add origin gh-pageme:pageme-hub/daily-tarot.git
git push -f origin gh-pages
cd ../..
```

## 3. GitHub 리포지토리 설정

1. GitHub 리포지토리 → **Settings** → **Pages**
2. Source 설정:
   - 방법 A 사용 시: **GitHub Actions** 선택
   - 방법 B 사용 시: **Deploy from a branch** → `gh-pages` / `/ (root)` 선택
3. 저장 후 1~2분 뒤 배포 완료

## 4. 접속 URL

```
https://pageme-hub.github.io/daily-tarot/
```

## 주의사항

### 웹에서 동작하지 않는 기능

아래 기능은 모바일 전용이므로 웹에서는 비활성화하거나 대체 처리가 필요하다:

| 기능 | 이유 | 대응 |
|------|------|------|
| `google_mobile_ads` | 웹 미지원 | `kIsWeb`으로 분기하여 광고 숨김 |
| `flutter_local_notifications` | 웹 미지원 | 알림 기능 숨김 |
| `gal` (갤러리 저장) | 웹 미지원 | 다운로드 링크로 대체 |
| `firebase_crashlytics` | 웹 미지원 | 웹에서는 초기화 건너뛰기 |
| `permission_handler` | 웹 미지원 | 권한 요청 로직 건너뛰기 |

### 플랫폼 분기 예시

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (!kIsWeb) {
  // 모바일 전용 코드 (광고, 알림 등)
}
```

### Supabase / dotenv

- `.env` 파일의 값은 웹 빌드 시에도 번들에 포함된다. **민감 키(service_role 등)를 `.env`에 넣지 않도록 주의**.
- Supabase `anon` 키는 클라이언트용이므로 웹에 노출되어도 RLS로 보호된다.

### CORS

Supabase API 호출 시 CORS 문제가 없는지 확인한다. Supabase는 기본적으로 모든 origin을 허용하지만, 커스텀 Edge Function을 사용 중이라면 해당 함수의 CORS 헤더를 확인할 것.
