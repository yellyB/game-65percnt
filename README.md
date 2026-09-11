# 사랑을 측정합니다 — Godot 2D (전체 게임)

축제에서 커플이 AI 궁합 테스트 VR을 체험하는 심리 드라마.
Godot 4 · 2D 포인트앤클릭 + 비주얼노벨. 아트는 아직 **greybox**(색 배경 + 색 핫스팟)이고,
화면 좌하단 **🎨 표기**로 "여기 어떤 그래픽/표정이 들어가야 하는지"가 보인다.

## 실행
1. [Godot 4.x](https://godotengine.org/) 설치 (4.4+)
2. Godot → **Import** → `project.godot`
3. **F5**

## 조작
- **클릭 / Space / Enter**: 대사 진행
- **핫스팟 클릭**: 탐색 조사 / 선택지 버튼 클릭
- **F5**: 빠른 저장 · **F9**: 빠른 불러오기
- 타이틀에서 **처음부터 / 이어하기**

## 전체 흐름 (7챕터)
타이틀 → 프롤로그(축제·천막) → 테스트1(성별) → 중간 → 테스트2(강아지)
→ 테스트3(부녀·감옥·공터·사망) → 65% 결과 → 엔딩 분기

탐색 7곳 · 선택지 다수 · 게이지 → **엔딩 A/B/C 분기**(65%는 미끼, 진짜 결말은 게이지).

## 구조
```
project.godot        자동로드(Loc, GameState, Dialogue) + 렌더러
scenes/Main.tscn     메인 씬 (Main.gd = 스토리 엔진)
scripts/
  Loc.gd             [Autoload] 번역: 키→텍스트, 언어 교체
  GameState.gd       [Autoload] 게이지·플래그·엔딩판정 + 저장/불러오기
  DialogueManager.gd [Autoload] 대사/선택지 UI + 소프트웨어 커서
  Main.gd            스토리 엔진 (beat 처리·연출·탐색·결과·엔딩·저장)
  Story.gd           스토리 "구조" (순서·위치·색·게이지·🎨그래픽 표기)
  Interactable.gd    탐색 핫스팟 (데이터만; 아트 교체 가능)
text/
  ko.gd              한국어 "텍스트" (키→문자열)
ASSETS.md            그려야 할 그래픽 목록
```

## 🌐 번역 (다국어)
- 모든 텍스트는 `text/ko.gd` 에 **키**로 분리돼 있음. 코드/스토리엔 키만 있음.
- **언어 추가**: `text/ko.gd` → `text/en.gd` 복사 → 값만 번역 → `scripts/Loc.gd` 의 `AVAILABLE` 에 `"en"` 추가.
- 실행 중 교체: `Loc.set_lang("en")`. 시작 시 OS 언어를 자동 감지(지원 시).

## 🎨 그래픽 표기
`Story.gd` 의 각 beat 에 어떤 그림이 들어갈지 적혀 있음:
- `img`: 배경/오브젝트 그림 (`bg_festival`, `obj_puppy_bowl` …)
- `expr`: 인물 표정 (`hero_normal_angry` …)
- `cg`: 큰 장면 일러스트 (`cg_death` …)

게임 중 좌하단에 `🎨 hero_normal_angry` 처럼 떠서, **그 순간 어떤 표정/배경을 그려야 하는지** 바로 보임.
실제 그림은 `ASSETS.md` 순서대로 그려서 넣으면 됨 (greybox 는 자동 폴백).

## 💾 저장
- 진행 중 **자동 저장**(챕터/beat 단위) · **F5** 수동 저장 · **F9** 불러오기
- 타이틀 **이어하기** 로 이어서 플레이. 저장 위치: `user://save.json`

## 다음 할 일
- [ ] `text/en.gd` 등 번역본 추가
- [ ] 선택/단서 게이지 밸런싱
- [ ] greybox → 실제 그림 (ASSETS.md 순서대로)
- [ ] (선택) 타이핑 효과·BGM·설정(언어 선택) 화면
