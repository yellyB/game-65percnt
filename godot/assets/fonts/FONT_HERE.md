# 폰트 넣는 곳

중국어·일본어까지 화면에 제대로 표시하려면 **CJK 지원 폰트**를 여기에 넣으세요.

- 파일명: **`main.ttf`** (또는 .otf 를 .ttf 로) → 경로 `assets/fonts/main.ttf`
- 추천: **Noto Sans CJK** (한/중/일 통합) — https://fonts.google.com/noto
  - 용량이 크면 서브셋(자주 쓰는 글자만)으로 줄여도 됨.
- 넣으면 `Fonts.gd`(자동로드)가 자동으로 전역 폰트로 적용. 없으면 Godot 기본 폰트 사용.

> 한국어는 Godot 기본 폰트로도 표시되지만, 中/日 글자는 이 폰트가 있어야 안 깨집니다.
