# 사랑을 측정합니다 — Godot 2D

축제에서 커플이 AI 궁합 테스트 VR을 체험하는 심리 드라마.
Godot 4 · 2D 비주얼노벨 + 포인트앤클릭 탐색 + 미니게임.
아트는 아직 **greybox**(색 배경 + 색 핫스팟)이고, 좌상단 **🎨 표기**로 그 순간 필요한 그래픽/표정이 보인다.

> 설계 상세는 [`DESIGN.md`](DESIGN.md), 작업 지침은 [`CLAUDE.md`](CLAUDE.md), 그릴 목록은 [`ASSETS.md`](ASSETS.md).

## 실행
1. [Godot 4.x](https://godotengine.org/) 설치 (4.4+)
2. Godot → **Import** → `project.godot`
3. **F5**

## 조작
- **클릭 / Space / Enter**: 대사 진행 (타이핑 중이면 즉시 전체)
- **핫스팟 클릭**: 탐색 조사 · **문/줌인**: 방 이동 / 자세히 보기
- **ESC**: 일시정지 (계속하기 · 설정 · 종료)
- **F5** 빠른 저장 · **F9** 불러오기 · 타이틀 **이어하기**

## 전체 흐름 (7챕터)
타이틀 → 프롤로그(축제·부스 허브·천막) → 테스트1(성별) → 중간 → 테스트2(강아지)
→ 테스트3(부녀·감옥·공터·사망) → 65% 결과 → **진엔딩(미묘한 서먹함·여운)**

탐색·미니게임·퍼즐은 **몰입/연출용**(결과 안 바꿈). **엔딩은 하나**, 중간 실패 시에만 **배드엔딩**.

## 주요 시스템
- **스토리 엔진**: beat 배열 구동 — `title/bg/fade/shake/flash/line/choice/explore/minigame/hub/score/ending`
- **탐색**: 핫스팟 조사 + **다중 방 이동(goto)** + **줌인 상세(detail)** + 숨은 보너스
- **미니게임/퍼즐**: 타이밍·**인형뽑기(집게)**·**고양이 가두기**·**연타(실패=배드엔딩)**·간식·교감 / **방탈출(키패드·패턴)** / **부스 허브**
- **연출**: 대사 타이핑 효과, 페이드/흔들림/플래시, 65% 카운트업+색종이
- **사운드**: 코드 생성 효과음 + BGM 프레임워크(파일 있으면 재생)
- **초상화**: `expr` → 화면 초상화(그림 없으면 greybox)
- **엔딩**: 진엔딩 하나 + 배드엔딩(중간 실패). 게이지 없음
- **저장**: 체크포인트 자동 저장 + F5/F9 + 이어하기
- **번역**: 텍스트 전부 키(`text/ko.gd`). en/zh/ja 스텁·한국어 폴백·언어 전환·CJK 폰트

## 구조
```
project.godot        자동로드(Fonts, Loc, GameState, Audio, Dialogue) + 렌더러
scenes/Main.tscn     메인 씬 (Main.gd = 스토리 엔진)
scripts/
  Fonts.gd           [Autoload] CJK 폰트 있으면 전역 적용
  Loc.gd             [Autoload] 번역: 키→텍스트, 언어 교체, ko 폴백
  GameState.gd       [Autoload] 플래그 + 저장/불러오기 (게이지 없음)
  Audio.gd(AudioManager) [Autoload] 절차적 효과음 + BGM
  DialogueManager.gd [Autoload] 대사/선택지·타이핑·초상화·소프트웨어 커서
  Main.gd            스토리 엔진 (beat·연출·탐색·미니게임·허브·저장·일시정지·배드엔딩)
  Story.gd           스토리 "구조" (순서·위치·색·🎨그래픽 표기)
  TrapCat.gd·ClawMachine.gd·PatternLock.gd  미니게임/퍼즐
  Interactable.gd    탐색 핫스팟 (문 goto / 줌인 detail 지원)
  TrapCat.gd         미니게임: 검은 고양이 가두기
  ClawMachine.gd     미니게임: 인형뽑기(집게)
text/ko.gd           한국어 텍스트 (키→문자열)
DESIGN.md / CLAUDE.md / ASSETS.md / AI_PORTRAITS.md
```

## 🌐 번역
- 모든 텍스트는 `text/ko.gd` 에 **키**로. 코드/스토리엔 키만.
- en/zh/ja 스텁 존재 → `ko.gd` 의 `data(){...}`를 복사해 값만 번역. **미번역 키는 한국어로 폴백**.
- 설정(ESC)에서 언어 전환·저장(`user://lang.cfg`). 시작 시 저장값/OS 언어 자동.
- 中/日 표시는 `assets/fonts/main.ttf`(Noto Sans CJK 등) 필요.

## 🎨 아트 표기
`Story.gd` 각 beat 의 `img`(배경/오브젝트) · `expr`(표정) · `cg`(이벤트 CG) 가 필요한 그래픽.
넣는 법: `assets/bg|obj|char|cg/<이름>.png` (없으면 greybox 자동). 목록·프롬프트는 ASSETS.md / AI_PORTRAITS.md.

## 다음 할 일
- [ ] 전체 챕터 **상세 대사 수정 패스** (초안 완료)
- [ ] **아트 투입** (greybox → 실제 그림, ASSETS.md 순서)
- [ ] **번역 채우기**(en/zh/ja) + **CJK 폰트**
- [ ] **설정 볼륨** 연결 (언어는 연결됨)
- [ ] 전체 **플레이테스트**
- [ ] 추가 미니게임(공터 몸싸움 QTE, 강아지 교감) · BGM 파일
