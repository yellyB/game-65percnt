# AI 초상화 생성 프롬프트 (표정 시트 방식)

일관성을 위해 **한 캐릭터의 여러 표정을 "한 장의 표정 시트(expression sheet)"로 생성** → 그다음 각 표정을 잘라 개별 PNG로 저장.
게임이 실제로 쓰는 파일명에 맞춰야 함 (아래 매핑 참고). 넣는 위치: `assets/char/<파일명>.png`

---

## 0. 공통 스타일 (모든 시트에 동일하게 — 일관성 핵심)

> 프롬프트 앞/뒤에 항상 이 블록을 붙여 스타일·구도·배경을 고정한다.

```
STYLE: Korean webtoon / semi-realistic anime visual-novel character art,
soft cell shading, clean lineart, muted moody color palette, cinematic soft lighting.
FRAMING: waist-up bust portrait, front-facing, centered, identical camera distance for every panel.
CONSISTENCY: exact same character — same face, same hairstyle, same outfit, same colors and lighting in every expression. only the facial expression changes.
BACKGROUND: flat solid pale-grey background (#dddddd), no scenery, no props  (배경은 나중에 지움).
LAYOUT: single image, expression sheet, a clean grid, each expression clearly separated with even spacing and same pose.
QUALITY: high detail face, consistent proportions, no text, no watermark.
```

부정 프롬프트(Negative):
```
inconsistent face, different hairstyle, different outfit, changing angle, extra fingers,
deformed, blurry, text, watermark, multiple characters per panel, busy background
```

---

## 1. 먼저: 캐릭터 기준 이미지 (identity 고정용)

여러 시트가 같은 인물이 되려면, **기준 이미지 1장을 먼저 만들고** 그걸 레퍼런스(img2img / reference / character reference)로 물려서 표정 시트를 뽑는 걸 추천.

**남주(남자친구) 기준:**
```
A 25-year-old Korean man, [머리: 짧은 검은 단정한 머리], [체형: 보통, 살짝 마른],
wearing [옷: 어두운 네이비 셔츠], calm neutral expression, gentle but slightly tired eyes.
+ (0번 STYLE 블록)
```
> `[...]` 부분을 원하는 디자인으로 바꿔. 이 기준 얼굴을 레퍼런스로 아래 시트들을 생성.

---

## 2. 표정 시트 프롬프트 (게임에 바로 필요한 것)

### ① 남주 · 원래 모습 (5표정) — 최우선
```
Expression sheet of THE SAME character (reference: 남주 기준 이미지):
a 25-year-old Korean man, short black hair, dark navy shirt.
2x3 grid (use 5 cells), same bust pose in every cell, ONLY the facial expression differs:
1) calm / neutral
2) warm gentle smile
3) surprised, eyes wide, mouth slightly open
4) anguished, pained, brows furrowed, holding back tears
5) angry, intense glare, jaw tight
+ (0번 STYLE 블록 + Negative)
```
→ 잘라서 저장:
`hero_normal_calm.png`, `hero_normal_smile.png`, `hero_normal_surprise.png`, `hero_normal_pain.png`, `hero_normal_angry.png`

### ② 남주 · 여자화 (3표정) — 테스트1
같은 인물이 여자가 된 모습. **얼굴 정체성은 유지, 성별 특징만 여성화** (머리 길이는 그대로).
```
Expression sheet of THE SAME character but genderswapped to female:
same facial identity as 남주, feminine features, same short hairstyle, same navy shirt style.
1x3 row, same bust pose, only expression differs:
1) calm / neutral
2) surprised, startled
3) pained, uncomfortable, looking away
+ (0번 STYLE 블록 + Negative)
```
→ `hero_female_calm.png`, `hero_female_surprise.png`, `hero_female_pain.png`

### ③ (선택) 남주 · 중년 — 테스트3 부녀
지금 대사에 표정 연동은 없지만 배경/CG용으로 필요하면:
```
Expression sheet of THE SAME man aged ~30 years older (mid-50s),
same facial bone structure, greying hair, weathered face. 1x2 row:
1) calm  2) awkward / uncomfortable
```
→ `hero_old_calm.png`, `hero_old_awkward.png`

### ④ (선택) 여주 — 1인칭이라 거울/CG만
```
① 남자화된 얼굴 1장  → heroine_male_face.png
② 강아지 모습 1장     → heroine_puppy.png
(기준: 여주 캐릭터를 먼저 정한 뒤 동일 스타일 블록으로)
```

---

## 3. 파일명 매핑 (게임이 찾는 이름 — 정확히 지켜야 함)

| 시트에서 자른 표정 | 저장 파일명 (`assets/char/`) |
|---|---|
| 남주 원래 · 평상 | `hero_normal_calm.png` |
| 남주 원래 · 미소 | `hero_normal_smile.png` |
| 남주 원래 · 놀람 | `hero_normal_surprise.png` |
| 남주 원래 · 괴로움 | `hero_normal_pain.png` |
| 남주 원래 · 분노 | `hero_normal_angry.png` |
| 남주 여자화 · 평상 | `hero_female_calm.png` |
| 남주 여자화 · 놀람 | `hero_female_surprise.png` |
| 남주 여자화 · 괴로움 | `hero_female_pain.png` |

> 이 8장만 넣어도 현재 스토리의 모든 표정 연동이 채워진다. (없으면 자동 greybox 유지)

---

## 4. 실전 팁

- **정체성 고정**: 기준 이미지 1장 → 레퍼런스로 물려 시트 생성. 한 번에 여러 표정을 "한 이미지"로 뽑아야 얼굴이 안 흔들림.
- **배경 제거**: 플랫 회색 배경으로 생성 → 배경 제거 도구(remove.bg 등)로 투명 PNG. Godot는 투명 PNG면 바로 초상화로 표시.
- **크기**: 자른 뒤 세로 ~600px 이상, 세로형(예 500×620) 권장.
- **일관성 안 맞으면**: 표정별로 따로 생성하지 말고 **꼭 시트 한 장으로**. 그래도 흔들리면 seed 고정 + 같은 프롬프트로 재생성.
- **넣는 법**: `assets/char/` 폴더에 위 파일명대로 저장 → 실행하면 greybox 자리에 그림이 뜬다.
