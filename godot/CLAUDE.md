# CLAUDE.md — 프로젝트 작업 지침

## 프로젝트
"사랑을 측정합니다" — Godot 4 · 2D 스토리 게임 (비주얼노벨 + 포인트앤클릭 탐색 + 미니게임).
원작 시나리오는 웹 버전 `game-65percnt`(senario.md)에서 옮겨옴. 아트는 아직 greybox.

## ⚠️ 커밋 규칙 (반드시)
- **작업 단위로 커밋한다.** 기능 추가·수정 하나가 끝날 때마다 바로 커밋.
- 커밋 메시지는 한국어로 간결하게 (무엇을/왜).
- 커밋 메시지 끝에 Co-Authored-By 푸터 유지.

## 구조
- `scripts/Fonts.gd` (자동로드) — CJK 폰트가 있으면 전역 적용 (`assets/fonts/main.ttf`)
- `scripts/Loc.gd` (자동로드) — 번역(키→텍스트), 언어 교체, 미번역 키는 한국어 폴백
- `scripts/GameState.gd` (자동로드) — 플래그 + 저장/불러오기 (게이지 없음)
- `scripts/AudioManager.gd` (자동로드 Audio) — 절차적 효과음 + BGM
- `scripts/DialogueManager.gd` (자동로드 Dialogue) — 대사/선택지 · 타이핑 효과 · 초상화 · 소프트웨어 커서
- `scripts/Main.gd` — 스토리 엔진 (beat 처리 · 연출 · 탐색 · 미니게임 · 허브 · 저장 · 일시정지 · 배드엔딩)
- `scripts/Story.gd` — 스토리 "구조" (순서·위치·색·🎨그래픽 표기)
- `scripts/Interactable.gd` — 탐색 핫스팟 (문 goto / 줌인 detail 지원)
- `scripts/TrapCat.gd` — 미니게임: 검은 고양이 가두기 (헥사 전략)
- `scripts/ClawMachine.gd` — 미니게임: 인형뽑기 (실제 집게, 목표 인형)
- `scripts/PatternLock.gd` — 방탈출: 휴대폰 패턴 잠금
- `text/ko.gd` — 한국어 텍스트(키). 번역 = `text/en·zh·ja.gd` 값 채움(비면 ko 폴백)

## beat 타입 (Story.gd)
`title / bg / fade / shake / flash / line / choice / explore / minigame / hub / score / ending`
- explore.data: `objects` 또는 `rooms`(다중 방). object 에 `goto`(문)·`detail`(줌인)·`choices`·`hidden` 가능
- minigame.game: `timing` / `claw` / `trapcat` / `mash`(연타, `fail_bad`면 배드엔딩) / `keypad`(비번) / `pattern`(패턴잠금)
- **선택지·미니게임은 결과를 안 바꿈**(감정 몰입·연출용). 게이지 없음. 실패 가능한 건 `mash`의 `fail_bad`(배드엔딩)뿐.

## 엔딩
- **진엔딩 하나**(정떨어짐/헤어짐). 게이지 분기 없음. **배드엔딩**은 중간 실패 시(예: 몸싸움 연타 실패=사망).

## 저장
- 체크포인트 저장(장면 전환·선택·미니게임 끝·탐색 끝·일시정지). F5 수동, F9 불러오기. 저장엔 flags + beat + lang.

## 검증 (변경 후 항상)
```
godot4 --headless --import                # 파싱 오류 확인
godot4 --headless --quit-after 15         # 런타임 오류 확인
```
번역 키 누락은 Story/Main/미니게임 스크립트가 참조하는 키가 `text/ko.gd` 에 있는지 대조.

## 아트
- greybox → 실제 그림 목록은 `ASSETS.md`. Story.gd 의 `img`/`expr`/`cg` 가 어떤 그래픽인지 표기.
