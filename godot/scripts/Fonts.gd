extends Node
## CJK(한/중/일) 지원 폰트가 있으면 전역 기본 폰트로 적용.
## 없으면 Godot 기본 폰트 사용(한국어는 기본으로도 표시됨).
## 中/日 까지 확실히 표시하려면 assets/fonts/main.ttf 에 Noto Sans CJK 등을 넣으세요.

const FONT_PATH := "res://assets/fonts/main.ttf"

func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		var f = load(FONT_PATH)
		if f:
			ThemeDB.fallback_font = f
