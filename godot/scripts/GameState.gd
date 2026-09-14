extends Node
## 전역 게임 상태 (Autoload) — 플래그 + 저장.
## (관계 게이지/엔딩 분기는 제거됨: 진엔딩 하나, 배드엔딩은 중간 실패 시만.)

var flags: Dictionary = {}        # 임의 플래그 (truth, control_seen 등)

func set_flag(key: String, value := true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return flags.get(key, false)

func reset() -> void:
	flags.clear()

# ══════════ 저장 / 불러오기 ══════════
const SAVE_PATH := "user://save.json"

## beat_index = 다시 시작할 스토리 지점
func save_game(beat_index: int) -> void:
	var d := {"beat": beat_index, "flags": flags, "lang": Loc.lang}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))
		f.close()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

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
	flags = parsed.get("flags", {})
	return parsed

func clear_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("save.json"):
		dir.remove("save.json")
