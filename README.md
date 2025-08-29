# Interactive Media Test

Flutter 웹 애플리케이션으로 서버 기반 UI(Server-Driven UI)를 활용한 인터랙티브 미디어를 테스트할 수 있는 도구입니다. 가사 애니메이션, 오디오 동기화, 다양한 렌더링 효과를 지원합니다.

## 주요 변경사항

이 프로젝트는 `karaoke_text` 패키지에서 `interactive_media` 패키지로 마이그레이션되었습니다. 
- 기존 카라오케 기능이 "lyric" 템플릿으로 통합
- JSON 기반 서버 드리븐 UI 지원
- 내장 오디오 재생 및 동기화
- 다양한 렌더링 옵션 (fade in/out, transition)
- 배경 설정 기능 (gradient, color, image)

## 기능

### 핵심 기능
- **JSON 에디터**: 실시간 Interactive Media 메타데이터 편집
- **서버 드리븐 UI**: JSON 메타데이터 기반 동적 콘텐츠 렌더링
- **오디오 통합**: 네트워크 URL 또는 로컬 파일 지원
- **렌더링 옵션**: 
  - Fade In/Out 애니메이션 시간 설정
  - 콘텐츠 간 전환 지연 시간 설정
- **실시간 프리뷰**: 휴대폰 프레임 UI로 미리보기
- **미디어 컨트롤**: 재생/일시정지/재개/정지

### 지원 템플릿
- **Lyric**: 오디오와 동기화된 텍스트 애니메이션 (현재 구현)
- **Book**: 페이지 기반 콘텐츠 (예정)
- **Slideshow**: 이미지 슬라이드쇼 (예정)
- **Video**: 비디오 재생 (예정)

## JSON 구조

```json
{
  "template": "lyric",
  "renderingOptions": {
    "transitionDelay": 500,
    "fadeInDuration": 800,
    "fadeOutDuration": 600
  },
  "background": {
    "type": "gradient",
    "value": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    "opacity": 0.15
  },
  "styleOptions": {
    "padding": 20
  },
  "contents": [
    {
      "audioType": "network",
      "audioSource": "https://example.com/audio.mp3",
      "textAlign": "center",
      "lyrics": [
        {
          "type": "span",
          "spans": [
            {
              "text": "텍스트",
              "offset": 0.0,
              "dur": 2.0,
              "style": {
                "color": "#FF6B6B",
                "size": 56.0,
                "fontWeight": "w700"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

## 사용법

1. **JSON 편집**: 왼쪽 JSON 에디터에서 메타데이터 편집
2. **오디오 설정**: 
   - 파일 선택 버튼으로 로컬 오디오 파일 선택
   - URL 입력란에 네트워크 오디오 URL 입력
3. **렌더링 옵션 조정**: Fade In/Out, Transition 시간 설정
4. **미리보기**: 오른쪽 휴대폰 프레임에서 실시간 확인
5. **재생 컨트롤**: 하단 버튼으로 미디어 제어

## 로컬 개발

```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run -d chrome --web-port 8080

# 프로덕션 빌드
flutter build web --release
```

## 기술 스택

- Flutter 3.8.1+
- interactive_media 패키지 (이전 karaoke_text)
- file_picker 패키지
- json_annotation/json_serializable

## 마이그레이션 가이드

### 이전 (karaoke_text)
```dart
KaraokeLyricsWidget(
  jsonString: jsonData,
  controller: karaokeController,
)
```

### 현재 (interactive_media)
```dart
InteractiveMediaWidget(
  metadata: InteractiveMediaMetadata.fromJson(jsonData),
  controller: lyricController,
)
```

## 배포

GitHub Actions를 통한 자동 배포:
1. GitHub 저장소 Settings → Pages
2. Source를 "GitHub Actions"로 설정
3. main 브랜치 push 시 자동 배포

## 라이브 데모

[GitHub Pages에서 확인하기](https://your-username.github.io/your-repo-name/)