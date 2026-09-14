extends Node
## 번역(로컬라이제이션) 담당 (Autoload).
## 모든 화면 텍스트는 키로 가져온다. 언어를 바꾸려면 set_lang 만 호출.
## 번역 안 된(비어있는) 키는 한국어(DEFAULT)로 자동 폴백 → 번역은 점진적으로 채우면 됨.
##
##   Loc.t("pr_walk1")   → 현재 언어 문자열 (없으면 한국어)
##   Loc.set_lang("en")  → 언어 교체 + 저장

const AVAILABLE := ["ko", "en", "zh", "ja"]   # 언어 추가 시 여기 + text/<code>.gd
const DEFAULT := "ko"
const DISPLAY := {"ko": "한국어", "en": "English", "zh": "简体中文", "ja": "日本語"}
const PREF_PATH := "user://lang.cfg"

var lang := DEFAULT
var _data: Dictionary = {}
var _fallback: Dictionary = {}   # 항상 한국어 (미번역 폴백)

func _ready() -> void:
	_fallback = load("res://text/%s.gd" % DEFAULT).data()
	set_lang(_initial_lang())

func _initial_lang() -> String:
	# 저장된 선택 우선, 없으면 OS 언어, 없으면 기본
	if FileAccess.file_exists(PREF_PATH):
		var f := FileAccess.open(PREF_PATH, FileAccess.READ)
		if f:
			var c := f.get_as_text().strip_edges()
			f.close()
			if AVAILABLE.has(c):
				return c
	var os_lang := OS.get_locale_language()
	return os_lang if AVAILABLE.has(os_lang) else DEFAULT

func set_lang(code: String) -> void:
	if not AVAILABLE.has(code):
		code = DEFAULT
	lang = code
	_data = load("res://text/%s.gd" % code).data()
	_save_pref()

func _save_pref() -> void:
	var f := FileAccess.open(PREF_PATH, FileAccess.WRITE)
	if f:
		f.store_string(lang)
		f.close()

## 키로 텍스트. 현재 언어 → 없으면 한국어 → 없으면 키 표시.
func t(key: String):
	if _data.has(key):
		return _data[key]
	if _fallback.has(key):
		return _fallback[key]
	return "⟨%s⟩" % key
