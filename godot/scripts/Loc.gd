extends Node
## 번역(로컬라이제이션) 담당 (Autoload).
## 모든 화면 텍스트는 여기서 키(key)로 가져온다. 언어를 바꾸려면 lang 만 바꾸면 됨.
## 새 언어 추가 = text/<code>.gd 파일을 하나 복사해서 값만 번역.
##
##   Loc.t("pr_walk1")        → 현재 언어의 문자열 (또는 여러 줄이면 Array)
##   Loc.set_lang("en")       → 언어 교체

const AVAILABLE := ["ko"]   # 언어 추가 시 여기에 코드 넣기 (예: "en", "ja")
const DEFAULT := "ko"

var lang := DEFAULT
var _data: Dictionary = {}

func _ready() -> void:
	set_lang(_pick_initial_lang())

## OS 언어 → 지원하면 사용, 아니면 기본
func _pick_initial_lang() -> String:
	var os_lang := OS.get_locale_language()
	return os_lang if AVAILABLE.has(os_lang) else DEFAULT

func set_lang(code: String) -> void:
	if not AVAILABLE.has(code):
		code = DEFAULT
	lang = code
	_data = load("res://text/%s.gd" % code).data()

## 키로 텍스트를 가져온다. 없으면 키 자체를 반환(누락 발견 쉽게).
func t(key: String):
	return _data.get(key, "⟨%s⟩" % key)
