extends Node2D
## 스토리 엔진 (GameFlow).
## Story.gd 의 beat(구조) + Loc(번역 텍스트)를 합쳐 진행한다.
## 대사/탐색/선택/연출/타이틀/결과/엔딩 + 저장 + 그래픽 표기(🎨).

const SPEAKERS := {
	"hero":     {"key": "spk_hero",    "color": Color8(116, 185, 255)},
	"heroine":  {"key": "spk_heroine", "color": Color8(255, 143, 163)},
	"system":   {"key": "spk_system",  "color": Color8(64, 224, 208)},
	"narrator": {"key": "",            "color": Color(1, 1, 1, 0.55)},
}

var _story: Array = []
var _i := 0
var _save_point := 0
var _started := false

# 노드
var _scene: CanvasLayer
var _bg: ColorRect
var _world: Control
var _fade: ColorRect
var _flash: ColorRect
var _desc: Label
var _goal: Label
var _artcue: Label
var _toast: Label
var _gauge_label: Label
var _clue_label: Label
var _title_layer: CanvasLayer
var _score_layer: CanvasLayer
var _score_label: Label
var _score_sub: Label
var _score_hint: Label
var _score_ready := false

# 일시정지 / 설정
var _paused := false
var _pause_layer: CanvasLayer
var _settings_layer: CanvasLayer

# 미니게임 상태 (타이밍/QTE)
var _mg_layer: CanvasLayer = null
var _mg_active := false
var _mg_done := false
var _mg_marker: ColorRect
var _mg_pos := 0.0
var _mg_dir := 1.0
var _mg_speed := 0.9
var _mg_target := 0.5
var _mg_halfwidth := 0.10
var _mg_track_left := 0.0
var _mg_track_right := 0.0
var _mg_beat := {}
var _mg_continuation: Callable = Callable()   # 미니게임 끝난 뒤 실행 (스토리 진행 or 허브 복귀)

# 연타(mash) 미니게임
var _mash_active := false
var _mash_val := 0.0
var _mash_time := 0.0
var _mash_beat := {}
var _mash_bar: ColorRect
var _mash_timer: Label

# 부스 허브 (도착 시 부스 선택)
var _hub_node: Control = null
var _hub_beat := {}
var _hub_played := {}
var _hub_play_total := 0
var _hub_exit_unlocked := false
var _hub_exit_rect: ColorRect
var _hub_exit_label: Label

# 탐색 상태 (다중 방 + 줌인)
var _ex_rooms := {}          # roomid -> room dict
var _ex_room_nodes := {}     # roomid -> Control 컨테이너
var _ex_cur_room := ""
var _ex_detail_node = null   # 열려있는 줌인 화면 (Control) 또는 null
var _ex_clue_total := 0
var _ex_found := {}          # exid -> true (조사한 단서)
var _ex_exits := []          # 출구 Interactable 들

func _ready() -> void:
	_build_scene()
	_build_effects()
	_build_hud()
	_build_title()
	_build_score_layer()
	_build_pause()
	GameState.reset()
	GameState.gauge_changed.connect(_on_gauge)
	_gauge_label.visible = false
	_story = load("res://scripts/Story.gd").beats()
	_advance()   # 첫 beat = 타이틀

# ══════════ 러너 ══════════
func _advance() -> void:
	if _i >= _story.size():
		return
	_save_point = _i   # 재개 지점 추적 (디스크 쓰기는 체크포인트에서만)
	var b: Dictionary = _story[_i]
	_i += 1
	match String(b.get("t", "")):
		"title":   _show_title()
		"bg":      _set_bg(b); _autosave(); _advance()
		"fade":    _do_fade(_advance)
		"shake":   _do_shake(_advance)
		"flash":   _do_flash(_advance)
		"line":    _do_line(b)
		"choice":  _do_choice(b)
		"explore": _start_explore(b["data"])
		"minigame":_show_minigame(b)
		"hub":     _show_hub(b)
		"score":   _show_score()
		"ending":  _do_ending()
		_:         _advance()

func _speaker_name(who: String) -> String:
	var key: String = SPEAKERS.get(who, SPEAKERS["narrator"])["key"]
	return "" if key == "" else String(Loc.t(key))

func _do_line(b: Dictionary) -> void:
	var who := String(b.get("who", "narrator"))
	var sp: Dictionary = SPEAKERS.get(who, SPEAKERS["narrator"])
	_set_artcue(b)
	Dialogue.say(_speaker_name(who), Loc.t(b["key"]), _advance, sp["color"], String(b.get("expr", "")))

func _do_choice(b: Dictionary) -> void:
	var who := String(b.get("who", "heroine"))
	var sp: Dictionary = SPEAKERS.get(who, SPEAKERS["heroine"])
	_set_artcue(b)
	var options: Array = b["options"]
	var display: Array = []
	for o in options:
		display.append({"text": Loc.t(o["key"])})
	Dialogue.say_choices(_speaker_name(who), Loc.t(b.get("prompt", "")), display,
		func(idx: int): _on_choice_picked(options, idx), sp["color"], String(b.get("expr", "")))

func _on_choice_picked(options: Array, idx: int) -> void:
	var o: Dictionary = options[idx]
	if o.has("gauge"):
		GameState.add_gauge(int(o["gauge"]))
	_autosave()   # 체크포인트: 선택 직후
	if o.has("reply"):
		Dialogue.say("", Loc.t(o["reply"]), _advance, SPEAKERS["narrator"]["color"])
	else:
		_advance()

# ══════════ 배경 / 연출 ══════════
func _set_bg(b: Dictionary) -> void:
	var col: Color = b.get("color", Color8(20, 20, 30))
	create_tween().tween_property(_bg, "color", col, 0.8)
	if b.has("bgm"):
		Audio.play_bgm(String(b["bgm"]))   # 파일 있으면 재생 (없으면 무시)
	var dk := String(b.get("desc", ""))
	_show_desc("" if dk == "" else String(Loc.t(dk)))
	_set_artcue(b)

func _show_desc(text: String) -> void:
	_desc.text = text
	if text == "":
		_desc.modulate.a = 0.0
		return
	_desc.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(_desc, "modulate:a", 0.0, 1.0)

## 🎨 이 beat 에 어떤 그래픽/표정이 들어가야 하는지 화면 좌하단에 표기
func _set_artcue(b: Dictionary) -> void:
	var parts: Array = []
	if b.has("img"):  parts.append(String(b["img"]))
	if b.has("expr"): parts.append(String(b["expr"]))
	if b.has("cg"):   parts.append("CG:" + String(b["cg"]))
	_artcue.text = ("🎨 " + ", ".join(parts)) if parts.size() > 0 else ""

func _do_fade(cb: Callable) -> void:
	_fade.color = Color(0, 0, 0, 0)
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.35)
	tw.tween_property(_fade, "color:a", 0.0, 0.35)
	tw.finished.connect(cb)

func _do_flash(cb: Callable) -> void:
	_flash.color = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property(_flash, "color:a", 0.85, 0.10)
	tw.tween_property(_flash, "color:a", 0.0, 0.35)
	tw.finished.connect(cb)

func _do_shake(cb: Callable) -> void:
	var tw := create_tween()
	for n in 6:
		tw.tween_property(_scene, "offset", Vector2(randf_range(-14, 14), randf_range(-14, 14)), 0.04)
	tw.tween_property(_scene, "offset", Vector2.ZERO, 0.04)
	tw.finished.connect(cb)

# ══════════ 탐색 (다중 방 + 줌인) ══════════
func _start_explore(data: Dictionary) -> void:
	_clear_explore()
	_goal.text = String(Loc.t(data.get("goal", "")))
	_goal.visible = true

	# 데이터 정규화: rooms 없으면 objects 를 단일 방으로 감쌈 (구버전 호환)
	if data.has("rooms"):
		_ex_rooms = data["rooms"]
		_ex_cur_room = String(data.get("start", _ex_rooms.keys()[0]))
	else:
		_ex_rooms = {"main": {"objects": data["objects"]}}
		_ex_cur_room = "main"

	# 사전 스캔: 모든 오브젝트(방+상세)에 고유 id 부여 + 단서 총계
	_ex_clue_total = 0
	_ex_found = {}
	var counter := [0]
	for rid in _ex_rooms:
		for o in _ex_rooms[rid]["objects"]:
			_assign_ids(o, counter)

	# 모든 방 미리 생성 (현재 방만 표시)
	var vp := get_viewport_rect().size
	for rid in _ex_rooms:
		var cont := Control.new()
		cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cont.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cont.visible = (rid == _ex_cur_room)
		_world.add_child(cont)
		_ex_room_nodes[rid] = cont
		for o in _ex_rooms[rid]["objects"]:
			cont.add_child(_make_interactable(o, vp))

	_clue_label.visible = true
	_update_clue_label()

func _assign_ids(o: Dictionary, counter: Array) -> void:
	o["exid"] = "c%d" % counter[0]
	counter[0] += 1
	if o.get("clue", false):
		_ex_clue_total += 1
	if o.has("detail"):
		for so in o["detail"]["objects"]:
			_assign_ids(so, counter)

func _make_interactable(o: Dictionary, vp: Vector2):
	var rd := {
		"name": Loc.t(o.get("name", "")),
		"lines": Loc.t(o["lines"]) if o.has("lines") else [],
		"pos": Vector2(o["frac"].x * vp.x, o["frac"].y * vp.y),
		"wsize": o.get("wsize", Vector2(110, 110)),
		"color": o.get("color", Color8(200, 180, 130)),
		"clue": o.get("clue", false),
		"exit": o.get("exit", false),
		"hidden": o.get("hidden", false),
		"gauge": o.get("gauge", 0),
		"exid": o.get("exid", ""),
		"goto": o.get("goto", ""),
	}
	if o.has("detail"):
		rd["detail"] = o["detail"]
	if o.has("choices"):
		var ch: Array = []
		for c in o["choices"]:
			ch.append({"text": Loc.t(c["key"]), "lines": Loc.t(c["lines"]), "gauge": c.get("gauge", 0)})
		rd["choices"] = ch
	var it = load("res://scripts/Interactable.gd").new()
	it.configure(rd)
	it.examined_changed.connect(_on_ex_examined)
	it.goto_requested.connect(_goto_room)
	it.detail_requested.connect(_open_detail)
	if it.is_exit:
		_ex_exits.append(it)
		it.exit_requested.connect(_on_ex_exit)
	# 상세 화면 재생성 시 이미 찾은 단서는 조사됨 표시
	if it.is_clue and _ex_found.has(it.exid):
		it.mark_done_visual()
	return it

func _goto_room(rid: String) -> void:
	if not _ex_room_nodes.has(rid):
		return
	if _ex_room_nodes.has(_ex_cur_room):
		_ex_room_nodes[_ex_cur_room].visible = false
	_ex_cur_room = rid
	_ex_room_nodes[rid].visible = true

func _open_detail(node) -> void:
	var d: Dictionary = node.detail_data
	if _ex_room_nodes.has(_ex_cur_room):
		_ex_room_nodes[_ex_cur_room].visible = false
	_ex_detail_node = Control.new()
	_ex_detail_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ex_detail_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_ex_detail_node)
	# 상세 배경
	var dbg := ColorRect.new()
	dbg.color = d.get("color", Color8(30, 28, 40))
	dbg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dbg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ex_detail_node.add_child(dbg)
	# 상세 오브젝트
	var vp := get_viewport_rect().size
	for so in d["objects"]:
		_ex_detail_node.add_child(_make_interactable(so, vp))
	# 뒤로 버튼
	var back := Button.new()
	back.text = String(Loc.t("ui_back"))
	back.position = Vector2(24, 20)
	back.pressed.connect(_close_detail)
	_ex_detail_node.add_child(back)

func _close_detail() -> void:
	if _ex_detail_node:
		_ex_detail_node.queue_free()
		_ex_detail_node = null
	if _ex_room_nodes.has(_ex_cur_room):
		_ex_room_nodes[_ex_cur_room].visible = true

func _on_ex_examined(node) -> void:
	if node.is_exit or not node.is_clue:
		return
	_ex_found[node.exid] = true
	_update_clue_label()
	if _ex_found.size() >= _ex_clue_total:
		for ex in _ex_exits:
			ex.mark_unlocked()
		_update_clue_label()

func _on_ex_exit() -> void:
	_clear_explore()
	_clue_label.visible = false
	_goal.visible = false
	_autosave()   # 체크포인트: 탐색 끝
	_advance()

func _clear_explore() -> void:
	if _ex_detail_node:
		_ex_detail_node.queue_free()
		_ex_detail_node = null
	for c in _world.get_children():
		c.queue_free()
	_ex_rooms = {}
	_ex_room_nodes = {}
	_ex_cur_room = ""
	_ex_exits = []
	_ex_found = {}
	_ex_clue_total = 0

func _update_clue_label() -> void:
	if _ex_clue_total > 0 and _ex_found.size() >= _ex_clue_total:
		_clue_label.text = String(Loc.t("ui_can_leave"))
		_clue_label.modulate = Color(0.4, 1, 0.6)
	else:
		_clue_label.text = "%s  %d / %d" % [Loc.t("ui_clue"), _ex_found.size(), _ex_clue_total]
		_clue_label.modulate = Color(1, 1, 1, 0.8)

# ══════════ 미니게임 ══════════
func _show_minigame(b: Dictionary) -> void:
	_launch_minigame(b, _advance)

func _launch_minigame(g: Dictionary, cont: Callable) -> void:
	_mg_continuation = cont
	match String(g.get("game", "timing")):
		"trapcat": _show_trapcat(g)
		"claw":    _show_claw(g)
		"mash":    _show_mash(g)
		_:         _show_timing(g)

# ── 검은 고양이 가두기 (헥사 전략) ──
func _show_trapcat(b: Dictionary) -> void:
	_mg_layer = CanvasLayer.new()
	_mg_layer.layer = 24
	add_child(_mg_layer)
	var dim := ColorRect.new()
	dim.color = Color8(30, 26, 38)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(dim)
	var game = load("res://scripts/TrapCat.gd").new()
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if b.has("radius"): game.radius = int(b["radius"])
	if b.has("seeds"): game.seed_count = int(b["seeds"])
	game.finished.connect(func(win: bool): _on_minigame_result(b, win))
	_mg_layer.add_child(game)

# ── 인형뽑기 (실제 집게) ──
func _show_claw(b: Dictionary) -> void:
	_mg_layer = CanvasLayer.new()
	_mg_layer.layer = 24
	add_child(_mg_layer)
	var dim := ColorRect.new()
	dim.color = Color8(28, 24, 36)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(dim)
	var game = load("res://scripts/ClawMachine.gd").new()
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if b.has("speed"): game.speed_frac = float(b["speed"])
	if b.has("tolerance"): game.tolerance = float(b["tolerance"])
	game.finished.connect(func(win: bool): _on_minigame_result(b, win))
	_mg_layer.add_child(game)

func _on_minigame_result(b: Dictionary, win: bool) -> void:
	if _mg_layer:
		_mg_layer.queue_free()
		_mg_layer = null
	var g := int(b.get("success_gauge", 0)) if win else int(b.get("fail_gauge", 0))
	if g != 0:
		GameState.add_gauge(g)
	if b.has("flag"):
		GameState.set_flag(String(b["flag"]), win)
	Audio.play("win" if win else "lose")
	_autosave()   # 체크포인트: 미니게임(고양이) 끝
	var lk := String(b.get("success", "")) if win else String(b.get("fail", ""))
	if lk != "":
		Dialogue.say("", Loc.t(lk), _mg_continuation, SPEAKERS["narrator"]["color"])
	else:
		_mg_continuation.call()

# ── 연타(mash): 게이지 채우기, 실패 시 배드엔딩 가능 ──
func _show_mash(b: Dictionary) -> void:
	_mash_beat = b
	_mash_val = 0.0
	_mash_time = float(b.get("time", 4.0))
	_mg_layer = CanvasLayer.new()
	_mg_layer.layer = 24
	add_child(_mg_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(dim)
	var vp := get_viewport_rect().size
	var cx := vp.x / 2.0
	var cy := vp.y / 2.0
	var pr := _mk_label(_mg_layer, String(Loc.t(b.get("prompt", ""))), 22, Color(1, 0.9, 0.7))
	pr.anchor_left = 0.5; pr.anchor_right = 0.5
	pr.offset_left = -340; pr.offset_right = 340; pr.offset_top = cy - 90
	pr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var track := ColorRect.new()
	track.color = Color(0.15, 0.15, 0.2)
	track.size = Vector2(420, 34); track.position = Vector2(cx - 210, cy)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(track)
	_mash_bar = ColorRect.new()
	_mash_bar.color = Color(0.9, 0.3, 0.35)
	_mash_bar.size = Vector2(0, 34); _mash_bar.position = Vector2(cx - 210, cy)
	_mash_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(_mash_bar)
	_mash_timer = _mk_label(_mg_layer, "", 18, Color(1, 1, 1, 0.8))
	_mash_timer.anchor_left = 0.5; _mash_timer.anchor_right = 0.5
	_mash_timer.offset_left = -100; _mash_timer.offset_right = 100; _mash_timer.offset_top = cy + 44
	_mash_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mash_active = true

func _process_mash(delta: float) -> void:
	_mash_time -= delta
	_mash_val = maxf(0.0, _mash_val - 16.0 * delta)   # 가만히 있으면 감소 → 연타 필요
	if _mash_bar:
		_mash_bar.size.x = 420.0 * (_mash_val / 100.0)
	if _mash_timer:
		_mash_timer.text = "%.1f" % maxf(0.0, _mash_time)
	if _mash_val >= 100.0:
		_mash_active = false
		_mash_finish(true)
	elif _mash_time <= 0.0:
		_mash_active = false
		_mash_finish(false)

func _mash_finish(success: bool) -> void:
	if _mg_layer:
		_mg_layer.queue_free()
		_mg_layer = null
	Audio.play("win" if success else "lose")
	var b := _mash_beat
	_autosave()
	if success:
		var lk := String(b.get("success", ""))
		if lk != "":
			Dialogue.say("", Loc.t(lk), _mg_continuation, SPEAKERS["narrator"]["color"])
		else:
			_mg_continuation.call()
	else:
		if bool(b.get("fail_bad", false)):
			_bad_ending(String(b.get("fail", "")))
		else:
			var lk := String(b.get("fail", ""))
			if lk != "":
				Dialogue.say("", Loc.t(lk), _mg_continuation, SPEAKERS["narrator"]["color"])
			else:
				_mg_continuation.call()

# 배드엔딩 (주인공 사망 등) — 스토리 중단, 재시작 제공
func _bad_ending(fail_key: String) -> void:
	GameState.clear_save()
	if fail_key != "":
		Dialogue.say("", Loc.t(fail_key), _show_bad_end, SPEAKERS["narrator"]["color"])
	else:
		_show_bad_end()

func _show_bad_end() -> void:
	var lay := CanvasLayer.new()
	lay.layer = 26
	add_child(lay)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.0, 0.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	lay.add_child(bg)
	var t := _mk_label(lay, String(Loc.t("end_bad_title")), 40, Color8(200, 60, 60))
	_center_label(t, -60)
	var s := _mk_label(lay, String(Loc.t("end_bad_sub")), 18, Color(1, 1, 1, 0.7))
	_center_label(s, 4)
	var btn := Button.new()
	btn.text = String(Loc.t("btn_restart"))
	btn.anchor_left = 0.5; btn.anchor_right = 0.5; btn.anchor_top = 0.5; btn.anchor_bottom = 0.5
	btn.offset_left = -90; btn.offset_right = 90; btn.offset_top = 70
	btn.pressed.connect(func(): get_tree().reload_current_scene())
	lay.add_child(btn)

# ── 타이밍 / QTE ──
func _show_timing(b: Dictionary) -> void:
	_mg_beat = b
	_mg_target = float(b.get("target", 0.5))
	_mg_halfwidth = float(b.get("halfwidth", 0.10))
	_mg_speed = float(b.get("speed", 0.9))
	_mg_pos = 0.0
	_mg_dir = 1.0
	_mg_done = false

	_mg_layer = CanvasLayer.new()
	_mg_layer.layer = 24
	add_child(_mg_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(dim)

	var vp := get_viewport_rect().size
	var cx := vp.x / 2.0
	var cy := vp.y / 2.0
	var half_w := 280.0
	_mg_track_left = cx - half_w
	_mg_track_right = cx + half_w

	var prompt := _mk_label(_mg_layer, String(Loc.t(b.get("prompt", ""))), 20, Color(1, 1, 0.85))
	prompt.anchor_left = 0.5; prompt.anchor_right = 0.5
	prompt.offset_left = -340; prompt.offset_right = 340
	prompt.offset_top = cy - 90
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 트랙
	var track := ColorRect.new()
	track.color = Color(0.15, 0.15, 0.2)
	track.size = Vector2(half_w * 2, 22)
	track.position = Vector2(_mg_track_left, cy)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(track)

	# 타겟 존 (초록)
	var zone_w := _mg_halfwidth * 2.0 * (half_w * 2)
	var zone_cx := lerpf(_mg_track_left, _mg_track_right, _mg_target)
	var zone := ColorRect.new()
	zone.color = Color(0.3, 0.9, 0.5, 0.85)
	zone.size = Vector2(zone_w, 22)
	zone.position = Vector2(zone_cx - zone_w / 2.0, cy)
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(zone)

	# 마커
	_mg_marker = ColorRect.new()
	_mg_marker.color = Color(1, 1, 1)
	_mg_marker.size = Vector2(10, 44)
	_mg_marker.position = Vector2(_mg_track_left, cy - 11)
	_mg_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mg_layer.add_child(_mg_marker)

	_mg_active = true

func _process(delta: float) -> void:
	if _paused:
		return
	if _mash_active:
		_process_mash(delta)
		return
	if not _mg_active:
		return
	_mg_pos += _mg_dir * _mg_speed * delta
	if _mg_pos >= 1.0:
		_mg_pos = 1.0; _mg_dir = -1.0
	elif _mg_pos <= 0.0:
		_mg_pos = 0.0; _mg_dir = 1.0
	if _mg_marker:
		_mg_marker.position.x = lerpf(_mg_track_left, _mg_track_right, _mg_pos) - _mg_marker.size.x / 2.0

func _mg_lock() -> void:
	if _mg_done:
		return
	_mg_done = true
	_mg_active = false
	var success := absf(_mg_pos - _mg_target) <= _mg_halfwidth
	var b := _mg_beat
	if _mg_layer:
		_mg_layer.queue_free()
		_mg_layer = null
	var g := int(b.get("success_gauge", 0)) if success else int(b.get("fail_gauge", 0))
	if g != 0:
		GameState.add_gauge(g)
	if b.has("flag"):
		GameState.set_flag(String(b["flag"]), success)
	Audio.play("win" if success else "lose")
	_autosave()   # 체크포인트: 미니게임(타이밍) 끝
	var lk := String(b.get("success", "")) if success else String(b.get("fail", ""))
	if lk != "":
		Dialogue.say("", Loc.t(lk), _mg_continuation, SPEAKERS["narrator"]["color"])
	else:
		_mg_continuation.call()

# ══════════ 부스 허브 ══════════
func _show_hub(b: Dictionary) -> void:
	_hub_beat = b
	_hub_played = {}
	_hub_node = Control.new()
	_hub_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hub_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_hub_node)

	var pl := Label.new()
	pl.text = String(Loc.t(b.get("prompt", "")))
	pl.add_theme_font_size_override("font_size", 20)
	pl.modulate = Color(1, 0.95, 0.8)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pl.anchor_left = 0.0; pl.anchor_right = 1.0
	pl.offset_top = 44
	pl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hub_node.add_child(pl)

	var booths: Array = b["booths"]
	_hub_play_total = 0
	for bb in booths:
		if not bb.get("exit", false):
			_hub_play_total += 1

	var vp := get_viewport_rect().size
	for i in booths.size():
		_make_booth(booths[i], i, vp)

	if _hub_play_total == 0:   # 놀거리 없으면 바로 진행 가능
		_unlock_hub_exit()

func _make_booth(booth: Dictionary, idx: int, vp: Vector2) -> void:
	var is_exit := bool(booth.get("exit", false))
	var wsize: Vector2 = Vector2(240, 150) if is_exit else Vector2(200, 140)
	var f: Vector2 = booth["frac"]
	var panel := Control.new()
	panel.size = wsize
	panel.position = Vector2(f.x * vp.x, f.y * vp.y) - wsize / 2.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var rect := ColorRect.new()
	rect.size = wsize
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rect)
	var nm := Label.new()
	nm.text = String(Loc.t(booth["name"]))
	nm.size = wsize
	nm.add_theme_font_size_override("font_size", 20)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(nm)

	if is_exit:
		# 사랑 측정 부스 = 진행. 다른 부스를 다 둘러봐야 열린다 (처음엔 잠금)
		_hub_exit_rect = rect
		_hub_exit_label = nm
		rect.color = Color(0.28, 0.28, 0.34)
		nm.modulate = Color(1, 1, 1, 0.45)
		panel.gui_input.connect(func(e: InputEvent):
			if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
				if _hub_exit_unlocked:
					_exit_hub()
				else:
					Dialogue.say("", Loc.t("hub_locked")))
	else:
		rect.color = booth.get("color", Color8(120, 90, 150))
		panel.gui_input.connect(func(e: InputEvent):
			if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
				if _hub_played.has(idx):
					return
				_hub_played[idx] = true
				rect.color = Color(0.3, 0.3, 0.36)
				nm.modulate = Color(1, 1, 1, 0.5)
				if _hub_played.size() >= _hub_play_total:
					_unlock_hub_exit()
				_launch_minigame(booth["game"], _reopen_hub))
	_hub_node.add_child(panel)

func _unlock_hub_exit() -> void:
	_hub_exit_unlocked = true
	if _hub_exit_rect:
		_hub_exit_rect.color = Color8(200, 80, 120)
	if _hub_exit_label:
		_hub_exit_label.modulate = Color(1, 1, 1, 1)
		_hub_exit_label.text = String(Loc.t("booth_lovetest")) + "\n▶"

func _reopen_hub() -> void:
	if _hub_node:
		_hub_node.visible = true

func _exit_hub() -> void:
	if _hub_node:
		_hub_node.queue_free()
		_hub_node = null
	_advance()

# ══════════ 타이틀 / 저장 ══════════
func _show_title() -> void:
	_title_layer.visible = true

func _start_from(index: int) -> void:
	_title_layer.visible = false
	_started = true
	_gauge_label.visible = true
	_i = index
	_advance()

func _on_new_game() -> void:
	GameState.clear_save()
	GameState.reset()
	_start_from(1)   # 0 = 타이틀, 1 부터 시작

func _on_continue() -> void:
	var d := GameState.load_game()
	if d.is_empty():
		return
	if d.has("lang"):
		Loc.set_lang(String(d["lang"]))
	var beat := int(d.get("beat", 1))
	_restore_bg_before(beat)
	_start_from(beat)

## 저장 지점 앞의 마지막 bg 를 즉시 적용 (배경 복원)
func _restore_bg_before(beat: int) -> void:
	var idx := mini(beat, _story.size()) - 1
	while idx >= 0:
		var b: Dictionary = _story[idx]
		if String(b.get("t", "")) == "bg":
			_bg.color = b.get("color", Color8(20, 20, 30))
			return
		idx -= 1

func _unhandled_input(event: InputEvent) -> void:
	if not _started:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_toggle_pause()
		return
	if _paused:
		return
	if _mash_active:
		var hit := false
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hit = true
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
			hit = true
		if hit:
			get_viewport().set_input_as_handled()
			_mash_val = minf(100.0, _mash_val + 10.0)
		return
	if _mg_active:
		var lock := false
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			lock = true
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
			lock = true
		if lock:
			get_viewport().set_input_as_handled()
			_mg_lock()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			GameState.save_game(_save_point)
			_show_toast(String(Loc.t("ui_saved")))
		elif event.keycode == KEY_F9:
			if GameState.has_save():
				_on_continue()

func _autosave() -> void:
	if _started:
		GameState.save_game(_save_point)

func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(_toast, "modulate:a", 0.0, 0.8)

# ══════════ 일시정지 / 설정 ══════════
func _toggle_pause() -> void:
	if _settings_layer.visible:
		_close_settings()
		return
	if _paused:
		_resume_game()
	else:
		_open_pause()

func _open_pause() -> void:
	_paused = true
	_pause_layer.visible = true
	_autosave()   # 체크포인트: 일시정지 열 때 (종료 대비)

func _resume_game() -> void:
	_paused = false
	_pause_layer.visible = false
	_settings_layer.visible = false

func _open_settings() -> void:
	_pause_layer.visible = false
	_settings_layer.visible = true

func _close_settings() -> void:
	_settings_layer.visible = false
	_pause_layer.visible = true

func _quit_game() -> void:
	get_tree().quit()

func _build_pause() -> void:
	# 일시정지 메뉴
	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 30
	add_child(_pause_layer)
	var pbg := ColorRect.new()
	pbg.color = Color(0, 0, 0, 0.62)
	pbg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pbg.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_layer.add_child(pbg)
	var pt := _mk_label(_pause_layer, String(Loc.t("pause_title")), 34, Color(1, 0.95, 0.95))
	_center_label(pt, -140)
	var pv := VBoxContainer.new()
	pv.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pv.offset_left = -120; pv.offset_right = 120; pv.offset_top = -40
	pv.add_theme_constant_override("separation", 12)
	_pause_layer.add_child(pv)
	_menu_button(pv, "btn_resume", _resume_game)
	_menu_button(pv, "btn_settings", _open_settings)
	_menu_button(pv, "btn_quit", _quit_game)
	_pause_layer.visible = false

	# 설정 (지금은 UI 만)
	_settings_layer = CanvasLayer.new()
	_settings_layer.layer = 31
	add_child(_settings_layer)
	var sbg := ColorRect.new()
	sbg.color = Color(0.05, 0.05, 0.09, 0.97)
	sbg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sbg.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_layer.add_child(sbg)
	var st := _mk_label(_settings_layer, String(Loc.t("set_title")), 30, Color(1, 0.95, 0.95))
	_center_label(st, -170)
	var sv := VBoxContainer.new()
	sv.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	sv.offset_left = -190; sv.offset_right = 190; sv.offset_top = -90
	sv.add_theme_constant_override("separation", 18)
	_settings_layer.add_child(sv)
	# 언어 (장식)
	var langrow := HBoxContainer.new()
	langrow.add_theme_constant_override("separation", 14)
	sv.add_child(langrow)
	var ll := Label.new(); ll.text = String(Loc.t("set_lang")); ll.custom_minimum_size = Vector2(130, 0)
	langrow.add_child(ll)
	var opt := OptionButton.new()
	opt.add_item("한국어"); opt.add_item("English"); opt.add_item("日本語")
	opt.custom_minimum_size = Vector2(200, 0)
	langrow.add_child(opt)
	# 볼륨 (장식)
	_settings_slider(sv, "set_music")
	_settings_slider(sv, "set_sfx")
	# 뒤로
	var back := Button.new(); back.text = String(Loc.t("btn_back"))
	back.pressed.connect(_close_settings)
	sv.add_child(back)
	_settings_layer.visible = false

func _menu_button(parent: Node, key: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = String(Loc.t(key))
	b.custom_minimum_size = Vector2(240, 46)
	b.pressed.connect(cb)
	parent.add_child(b)

func _settings_slider(parent: Node, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	parent.add_child(row)
	var l := Label.new(); l.text = String(Loc.t(key)); l.custom_minimum_size = Vector2(130, 0)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0; s.max_value = 100; s.value = 70
	s.custom_minimum_size = Vector2(220, 0)
	row.add_child(s)

# ══════════ 65% 결과 ══════════
func _show_score() -> void:
	_score_layer.visible = true
	_score_ready = false
	_score_hint.visible = false
	_score_sub.text = ""
	_score_label.text = "0 %"
	_spawn_confetti()
	var tw := create_tween()
	tw.tween_method(_set_score_num, 0.0, 65.0, 2.0)
	tw.finished.connect(func():
		_score_label.text = "65 %"
		_score_sub.text = String(Loc.t("score_sub"))
		_score_hint.text = String(Loc.t("score_hint"))
		_score_hint.visible = true
		_score_ready = true)

func _set_score_num(x: float) -> void:
	_score_label.text = "%d %%" % int(x)

func _on_score_click() -> void:
	if not _score_ready:
		return
	_score_layer.visible = false
	_advance()

func _spawn_confetti() -> void:
	var cols := [Color8(255, 107, 107), Color8(254, 202, 87), Color8(72, 219, 251),
				 Color8(255, 159, 243), Color8(84, 160, 255)]
	var vp := get_viewport_rect().size
	for n in 40:
		var c := ColorRect.new()
		c.color = cols[n % cols.size()]
		c.size = Vector2(8, 8)
		c.position = Vector2(randf_range(0, vp.x), -20)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_score_layer.add_child(c)
		var tw := create_tween()
		tw.tween_property(c, "position:y", vp.y + 40, randf_range(2.0, 3.5))
		tw.parallel().tween_property(c, "position:x", c.position.x + randf_range(-60, 60), 3.0)
		tw.tween_callback(c.queue_free)

# ══════════ 엔딩 ══════════
func _do_ending() -> void:
	var e: String = GameState.compute_ending()
	GameState.clear_save()   # 완주 → 세이브 정리
	Dialogue.say("", Loc.t("end_" + e), func(): _the_end(e), SPEAKERS["narrator"]["color"])

func _the_end(_e: String) -> void:
	_artcue.text = ""
	_desc.text = String(Loc.t("ui_the_end"))
	_desc.modulate.a = 1.0
	_gauge_label.visible = false

# ══════════ 빌드 ══════════
func _build_scene() -> void:
	_scene = CanvasLayer.new()
	_scene.layer = 0
	add_child(_scene)
	_bg = ColorRect.new()
	_bg.color = Color8(20, 20, 30)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene.add_child(_bg)
	_world = Control.new()
	_world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scene.add_child(_world)

func _build_effects() -> void:
	var fxl := CanvasLayer.new()
	fxl.layer = 15
	add_child(fxl)
	_fade = _full_rect_color(fxl, Color(0, 0, 0, 0))
	_flash = _full_rect_color(fxl, Color(1, 1, 1, 0))

func _full_rect_color(parent: Node, col: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = col
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 5
	add_child(hud)

	_desc = _mk_label(hud, "", 22, Color(1, 1, 1, 0.85))
	_anchor_top_center(_desc, 20)
	_desc.modulate.a = 0.0

	_goal = _mk_label(hud, "", 16, Color(1, 0.9, 0.7))
	_anchor_top_center(_goal, 54)
	_goal.visible = false

	_gauge_label = _mk_label(hud, "", 18, Color(1, 0.7, 0.8))
	_gauge_label.position = Vector2(18, 14)

	_clue_label = _mk_label(hud, "", 16, Color(1, 1, 1, 0.8))
	_clue_label.anchor_left = 1.0; _clue_label.anchor_right = 1.0
	_clue_label.offset_left = -240; _clue_label.offset_right = -18
	_clue_label.offset_top = 14
	_clue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_clue_label.visible = false

	# 🎨 그래픽/표정 표기 (좌상단; 초상화 greybox 와 겹치지 않게)
	_artcue = _mk_label(hud, "", 14, Color(0.6, 1, 0.8, 0.85))
	_artcue.position = Vector2(18, 44)

	_toast = _mk_label(hud, "", 18, Color(1, 1, 0.7))
	_anchor_top_center(_toast, 90)
	_toast.modulate.a = 0.0

func _anchor_top_center(l: Label, top: float) -> void:
	l.anchor_left = 0.5; l.anchor_right = 0.5
	l.offset_left = -320; l.offset_right = 320
	l.offset_top = top
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_title() -> void:
	_title_layer = CanvasLayer.new()
	_title_layer.layer = 25
	add_child(_title_layer)
	_full_rect_color(_title_layer, Color8(24, 20, 34))
	var t := _mk_label(_title_layer, String(Loc.t("title_name")), 44, Color(1, 0.95, 0.95))
	_center_label(t, -90)
	var s := _mk_label(_title_layer, String(Loc.t("title_sub")), 18, Color(1, 1, 1, 0.7))
	_center_label(s, -30)

	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vb.offset_left = -140; vb.offset_right = 140; vb.offset_top = 30
	vb.add_theme_constant_override("separation", 12)
	_title_layer.add_child(vb)

	var b_new := Button.new()
	b_new.text = String(Loc.t("title_start"))
	b_new.pressed.connect(_on_new_game)
	vb.add_child(b_new)

	if GameState.has_save():
		var b_cont := Button.new()
		b_cont.text = String(Loc.t("title_continue"))
		b_cont.pressed.connect(_on_continue)
		vb.add_child(b_cont)

	_title_layer.visible = false

func _center_label(l: Label, top: float) -> void:
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	l.offset_left = -320; l.offset_right = 320; l.offset_top = top
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_score_layer() -> void:
	_score_layer = CanvasLayer.new()
	_score_layer.layer = 25
	add_child(_score_layer)
	_full_rect_color(_score_layer, Color8(255, 236, 210))
	_score_label = _mk_label(_score_layer, "0 %", 72, Color8(200, 60, 90))
	_center_label(_score_label, -70)
	_score_sub = _mk_label(_score_layer, "", 18, Color8(120, 80, 80))
	_center_label(_score_sub, 20)
	_score_hint = _mk_label(_score_layer, "", 16, Color8(120, 80, 80))
	_center_label(_score_hint, 80)
	_score_hint.visible = false
	var click := Control.new()
	click.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click.mouse_filter = Control.MOUSE_FILTER_STOP
	click.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			_on_score_click())
	_score_layer.add_child(click)
	_score_layer.visible = false

func _mk_label(parent: Node, text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.modulate = col
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func _on_gauge(value: int) -> void:
	var mood_key := "mood_cold" if value < 40 else ("mood_normal" if value < 60 else "mood_warm")
	_gauge_label.text = "♥ %s %d  (%s)" % [Loc.t("ui_relation"), value, Loc.t(mood_key)]
