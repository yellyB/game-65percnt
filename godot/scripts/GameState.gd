extends Node
## 전역 게임 상태 (Autoload)
## 관계 게이지 · 플래그 · 엔딩 판정을 담당한다.
## 씬(챕터)이 바뀌어도 유지되며, 탐색/선택의 결과가 여기로 모인다.

signal gauge_changed(value: int)

const GAUGE_START := 50

var gauge: int = GAUGE_START      # 관계 게이지 (0~100)
var flags: Dictionary = {}        # 임의 플래그 (히든/분기 조건)
var found_hidden: int = 0         # 발견한 숨은 단서 수 (엔딩 C 조건)

func add_gauge(delta: int) -> void:
	gauge = clampi(gauge + delta, 0, 100)
	gauge_changed.emit(gauge)

func set_flag(key: String, value := true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return flags.get(key, false)

## 엔딩 임계값 (밸런스 — DESIGN.md 참고)
const ENDING_B_MIN := 50    # 이상이면 B (여지)
const ENDING_C_MIN := 60    # C 는 게이지 이 이상 + 숨은 단서 전부
const HIDDEN_TOTAL := 2      # 숨은 고양이 총 2마리

## 마지막에 호출 — 게이지/플래그로 엔딩을 고른다.
## 숫자(65%)는 미끼이고, 진짜 결말은 여기서 갈린다.
func compute_ending() -> String:
	if found_hidden >= HIDDEN_TOTAL and gauge >= ENDING_C_MIN:
		return "C"          # 히든(완벽): 숨은 단서 전부 + 높은 게이지 = 관찰+다정
	if gauge >= ENDING_B_MIN:
		return "B"          # 씁쓸하지만 여지 있음
	return "A"              # 냉담 — 원작 배드

func reset() -> void:
	gauge = GAUGE_START
	flags.clear()
	found_hidden = 0
	gauge_changed.emit(gauge)

# ══════════ 저장 / 불러오기 ══════════
const SAVE_PATH := "user://save.json"

## beat_index = 다시 시작할 스토리 지점
func save_game(beat_index: int) -> void:
	var d := {
		"beat": beat_index, "gauge": gauge, "flags": flags,
		"found_hidden": found_hidden, "lang": Loc.lang,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))
		f.close()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## 저장된 상태를 복원하고 저장 데이터를 반환(없으면 {}). beat 지점은 호출측이 사용.
func load_game() -> Dictionary:
	if not has_save():
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return {}
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	gauge = int(parsed.get("gauge", GAUGE_START))
	flags = parsed.get("flags", {})
	found_hidden = int(parsed.get("found_hidden", 0))
	gauge_changed.emit(gauge)
	return parsed

func clear_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("save.json"):
		dir.remove("save.json")
