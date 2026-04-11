# Firebase 설정 매뉴얼 (daily-tarot)

> 대상: Firebase 처음 사용자 / Windows + WSL2 환경
> 목적: Firebase Crashlytics 연동 (인증·DB는 Supabase 사용)
> 패키지명: `com.appfactory.daily_tarot`

---

## 전체 흐름

1. Firebase 콘솔에서 프로젝트 생성
2. Android 앱 등록
3. FlutterFire CLI 설치
4. `flutterfire configure` 실행 → `firebase_options.dart` 자동 생성
5. `pubspec.yaml`에 패키지 추가
6. `google-services.json` 위치 확인
7. 동작 테스트

---

## Step 1. Firebase 프로젝트 생성

1. 브라우저에서 https://console.firebase.google.com 접속 (Google 계정 로그인)
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력: `daily-tarot` (내부 식별용이므로 자유롭게)
4. Google 애널리틱스 사용 여부 → "사용 설정" 선택 후 기본 계정 사용
5. "프로젝트 만들기" 클릭 → 완료될 때까지 대기 (약 30초)

---

## Step 2. Android 앱 등록

1. Firebase 콘솔 홈에서 Android 아이콘 클릭 ("앱 추가" → Android)
2. 패키지 이름 입력:
   ```
   com.appfactory.daily_tarot
   ```
3. 앱 닉네임: `매일타로` (선택사항)
4. SHA-1 인증서: **지금은 입력 생략** (Crashlytics는 SHA-1 불필요)
5. "앱 등록" 클릭
6. `google-services.json` 다운로드 버튼 클릭 → 파일 저장
   - 이 파일은 Step 6에서 올바른 위치에 배치함
7. "다음" → "다음" → "콘솔로 이동" (SDK 추가 단계는 FlutterFire CLI로 대체)

---

## Step 3. Crashlytics 활성화

1. Firebase 콘솔 좌측 메뉴 → "Crashlytics" 클릭
2. "시작하기" 버튼 클릭
3. Android 앱 선택 확인 후 완료
   - 실제 크래시 데이터는 앱 첫 실행 후 수분 내 표시됨

---

## Step 4. FlutterFire CLI 설치

> WSL2 터미널(Ubuntu)에서 실행합니다. PowerShell/CMD가 아닌 WSL 환경 사용.

### 4-1. Firebase CLI 설치 (Node.js 기반)

```bash
# Node.js가 없으면 먼저 설치
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Firebase CLI 설치
npm install -g firebase-tools

# 버전 확인
firebase --version
```

### 4-2. Firebase 로그인

```bash
firebase login
```

- 브라우저가 열리면 Firebase 콘솔에서 사용한 Google 계정으로 로그인
- WSL에서 브라우저가 열리지 않을 경우:
  ```bash
  firebase login --no-localhost
  ```
  → 출력된 URL을 Windows 브라우저에서 열고, 인증 코드를 터미널에 붙여넣기

### 4-3. FlutterFire CLI 설치

```bash
dart pub global activate flutterfire_cli

# PATH에 추가 (아직 안 되어 있다면)
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# 버전 확인
flutterfire --version
```

---

## Step 5. flutterfire configure 실행

프로젝트 루트 디렉토리에서 실행합니다.

```bash
cd /mnt/c/Users/user/dev/app-factory/daily-tarot

flutterfire configure
```

### 실행 중 선택 사항

1. Firebase 프로젝트 선택 → Step 1에서 만든 `daily-tarot` 선택
2. 플랫폼 선택:
   - `android` 선택 (스페이스바로 선택/해제, 엔터로 확인)
   - iOS는 현재 불필요하므로 선택 해제
3. Android 패키지명 확인 → `com.appfactory.daily_tarot` 인지 확인 후 엔터

### 완료 후 생성 파일

```
lib/firebase_options.dart          ← 자동 생성됨 (커밋에 포함해도 됨)
android/app/google-services.json  ← 자동 배치됨
```

> `flutterfire configure`는 `google-services.json`을 올바른 위치에 자동으로 복사합니다.
> Step 2에서 다운로드한 파일과 내용이 동일합니다.

---

## Step 6. google-services.json 위치 확인

```bash
ls android/app/google-services.json
```

파일이 존재해야 합니다. 없으면 Step 2에서 다운로드한 파일을 수동으로 복사:

```bash
cp ~/Downloads/google-services.json android/app/google-services.json
```

> 주의: `google-services.json`은 절대 Git에 커밋하지 마세요.
> `.gitignore`에 이미 포함되어 있는지 확인:
> ```bash
> grep google-services .gitignore
> ```
> 출력이 없으면 아래 추가:
> ```bash
> echo "android/app/google-services.json" >> .gitignore
> ```

---

## Step 7. pubspec.yaml에 패키지 추가

`pubspec.yaml`의 `dependencies` 섹션에 아래 두 줄을 추가합니다.

```yaml
dependencies:
  # ... 기존 패키지들 ...
  firebase_core: ^3.6.0
  firebase_crashlytics: ^4.1.0
```

추가 후 패키지 설치:

```bash
flutter pub get
```

---

## Step 8. firebase_options.dart 생성 확인

```bash
cat lib/firebase_options.dart
```

`DefaultFirebaseOptions` 클래스가 정의되어 있으면 정상입니다.

이미 `lib/core/firebase/firebase_initializer.dart`가 이 파일을 임포트하고 있으므로
별도 코드 수정 없이 바로 사용 가능합니다.

---

## Step 9. 동작 테스트

### 빌드 확인

```bash
flutter build apk --debug
```

빌드 성공 시 Firebase 연동은 정상입니다.

### Crashlytics 테스트 크래시 발생

앱 실행 후 의도적 크래시를 발생시켜 Crashlytics에 데이터가 올라오는지 확인합니다.

임시로 버튼 하나에 아래 코드를 추가한 뒤 앱을 실행하고 버튼을 누릅니다:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// 버튼 onPressed:
FirebaseCrashlytics.instance.crash();
```

- 크래시 발생 → 앱 재실행 → Firebase 콘솔 Crashlytics 페이지에서 수분 내 확인 가능
- 테스트 완료 후 해당 코드는 반드시 제거

### 로그 확인

앱 실행 로그에서 아래 메시지 확인:

```
I/Firebase: Firebase initialized
```

---

## 자주 발생하는 오류

### `firebase_options.dart` not found

`flutterfire configure`를 프로젝트 루트에서 실행했는지 확인합니다.

```bash
pwd  # /mnt/c/Users/user/dev/app-factory/daily-tarot 이어야 함
```

### `google-services.json` not found (빌드 에러)

`android/app/` 디렉토리에 파일이 있는지 확인 후 없으면 수동 복사 (Step 6 참조).

### FlutterFire CLI 명령어를 찾을 수 없음

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire --version
```

위 export를 `~/.zshrc` 또는 `~/.bashrc`에 영구 추가했는지 확인합니다.

### firebase login이 안 됨 (WSL 브라우저 문제)

```bash
firebase login --no-localhost
```

로 로그인하면 브라우저 없이 코드 입력 방식으로 인증 가능합니다.

---

## 설정 완료 체크리스트

- [ ] Firebase 콘솔에 `daily-tarot` 프로젝트 생성됨
- [ ] Android 앱 `com.appfactory.daily_tarot` 등록됨
- [ ] Crashlytics 활성화됨
- [ ] `lib/firebase_options.dart` 파일 존재
- [ ] `android/app/google-services.json` 파일 존재
- [ ] `pubspec.yaml`에 `firebase_core`, `firebase_crashlytics` 추가됨
- [ ] `flutter pub get` 완료
- [ ] `flutter build apk --debug` 빌드 성공
- [ ] Firebase 콘솔에서 테스트 크래시 수신 확인
