# CLAUDE.md — 프로젝트 작업 지침

## 프로젝트
"사랑을 측정합니다" — Godot 4 · 2D 스토리 게임 (비주얼노벨 + 포인트앤클릭 탐색 + 미니게임).
원작 시나리오는 웹 버전 `game-65percnt`(senario.md)에서 옮겨옴. 아트는 아직 greybox.

## ⚠️ 커밋 규칙 (반드시)
- **작업 단위로 커밋한다.** 기능 추가·수정 하나가 끝날 때마다 바로 커밋.
- 커밋 메시지는 한국어로 간결하게 (무엇을/왜).
- 커밋 메시지 끝에 Co-Authored-By 푸터 유지.

## 구조
- `scripts/Loc.gd` — 번역(키→텍스트), 언어 교체
- `scripts/GameState.gd` — 관계 게이지 · 플래그 · 엔딩 판정 · 저장/불러오기
- `scripts/AudioManager.gd` (자동로드 Audio) — 절차적 효과음 + BGM
- `scripts/DialogueManager.gd` — 대사/선택지 · 타이핑 효과 · 초상화 · 소프트웨어 커서
- `scripts/Main.gd` — 스토리 엔진 (beat 처리 · 연출 · 탐색 · 미니게임 · 허브 · 저장 · 일시정지)
- `scripts/Story.gd` — 스토리 "구조" (순서·위치·색·게이지·🎨그래픽 표기)
- `scripts/Interactable.gd` — 탐색 핫스팟 (문 goto / 줌인 detail 지원)
- `scripts/TrapCat.gd` — 미니게임: 검은 고양이 가두기 (헥사 전략)
- `scripts/ClawMachine.gd` — 미니게임: 인형뽑기 (실제 집게)
- `text/ko.gd` — 모든 텍스트(키). 언어 추가 = 이 파일 복사 → `text/<code>.gd` → 값만 번역

## beat 타입 (Story.gd)
`title / bg / fade / shake / flash / line / choice / explore / minigame / hub / score / ending`
- explore.data: `objects` 또는 `rooms`(다중 방). object 에 `goto`(문)·`detail`(줌인)·`choices`·`hidden` 가능
- minigame.game: `timing` / `claw` / `trapcat`  (허브 booth 도 각자 game 보유)

## 저장
- 체크포인트 저장(장면 전환·선택·미니게임 끝·탐색 끝·일시정지). F5 수동, F9 불러오기.

## 검증 (변경 후 항상)
```
godot4 --headless --import                # 파싱 오류 확인
godot4 --headless --quit-after 15         # 런타임 오류 확인
```
번역 키 누락은 Story/Main/TrapCat 이 참조하는 키가 `text/ko.gd` 에 있는지 대조.

## 아트
- greybox → 실제 그림 목록은 `ASSETS.md`. Story.gd 의 `img`/`expr`/`cg` 가 어떤 그래픽인지 표기.
