# Karaoke Audio Contents Test

Flutter 웹 애플리케이션으로 카라오케 텍스트 애니메이션과 오디오 재생을 테스트할 수 있는 도구입니다.

## 기능

- JSON 에디터를 통한 카라오케 데이터 편집
- 실시간 프리뷰 (휴대폰 프레임 형태)
- 오디오 파일 업로드 및 URL 입력 지원
- 카라오케 텍스트와 오디오 동기화 재생
- 웹 브라우저에서 바로 사용 가능

## 사용법

1. 왼쪽 JSON 에디터에서 카라오케 데이터를 편집
2. 오디오 파일을 선택하거나 URL을 입력
3. 컨트롤 버튼으로 재생/일시정지/정지
4. 실시간으로 카라오케 애니메이션 확인

## 배포

이 프로젝트는 GitHub Pages에 자동으로 배포됩니다.

### GitHub Pages 설정

1. GitHub 저장소 설정에서 "Pages" 섹션으로 이동
2. Source를 "GitHub Actions"로 설정
3. main 브랜치에 push하면 자동으로 배포됩니다

### 로컬 개발

```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run -d chrome --web-port 8080

# 프로덕션 빌드
flutter build web --release
```

## 기술 스택

- Flutter 3.24.0
- karaoke_text 패키지
- audioplayers 패키지
- file_picker 패키지

## 라이브 데모

[GitHub Pages에서 확인하기](https://your-username.github.io/your-repo-name/)
