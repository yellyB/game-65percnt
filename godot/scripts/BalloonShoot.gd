extends Control
## 사격 부스 — 풍선 맞추기 미니게임.
##  떠오르는 풍선을 마우스로 조준하고 클릭해 터뜨린다.
##  제한 시간 안에 목표 개수만큼 맞히면 성공.

signal finished(win: bool)

var need := 5           # 성공에 필요한 명중 수
var time_limit := 16.0  # 제한 시간(초)

const RADIUS := 40.0    # 클릭 명중 허용 반경 px
const MAX_ON := 5       # 동시에 떠 있는 최대 풍선 수
const COLORS := [Color8(230, 90, 110), Color8(90, 150, 220), Color8(240, 190, 80),
	Color8(120, 200, 120), Color8(190, 120, 220)]

var _balloons: Array = []   # [{node, pos, vx, vy}]
var _hits := 0
var _time_left := 0.0
var _done := false
var _area: Rect2
var _spawn_t := 0.0

var _title: Label
var _hint: Label
var _hud: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_time_left = time_limit
	var vp := get_viewport_rect().size
	var bw := 520.0
	var bh := 420.0
	var bx := (vp.x - bw) / 2.0
	var by := (vp.y - bh) / 2.0 + 10.0
	_area = Rect2(bx, by, bw, bh)

	_rect_at(Color8(38, 48, 60), Vector2(bx, by), Vector2(bw, bh))
	_rect_at(Color(1, 1, 1, 0.05), Vector2(bx + 10, by + 10), Vector2(bw - 20, bh - 20))

	_center_text(String(Loc.t("shoot_title")), 20, Color(1, 0.95, 0.95), by - 54)
	_hint = _center_text(String(Loc.t("shoot_hint")), 16, Color(1, 1, 0.8), by + bh + 16)
	_hud = _center_text("", 18, Color(0.8, 1, 0.9), by - 84)
	_update_hud()
	for i in 3:
		_spawn()

func _rect_at(col: Color, pos: Vector2, sz: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = col; r.position = pos; r.size = sz
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r

func _center_text(txt: String, fsize: int, col: Color, top: float) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.modulate = col
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.anchor_left = 0.0; l.anchor_right = 1.0
	l.offset_top = top
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _spawn() -> void:
	if _balloons.size() >= MAX_ON:
		return
	var lab := Label.new()
	lab.text = "🎈"
	lab.add_theme_font_size_override("font_size", 46)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lab.modulate = COLORS[randi() % COLORS.size()]
	add_child(lab)
	var px := randf_range(_area.position.x + 40, _area.end.x - 40)
	var py := _area.end.y - 30.0
	var vx := randf_range(-60, 60)
	var vy := randf_range(-70, -45)
	_balloons.append({"node": lab, "pos": Vector2(px, py), "vx": vx, "vy": vy})

func _update_hud() -> void:
	_hud.text = "%s  %d / %d      ⏱ %.0f" % [Loc.t("shoot_hud"), _hits, need, ceil(_time_left)]

func _gui_input(event: InputEvent) -> void:
	if _done:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		_shoot(event.position)

func _shoot(at: Vector2) -> void:
	Audio.play("tick")
	var best := -1
	var best_d := RADIUS
	for i in _balloons.size():
		var d := at.distance_to(_balloons[i]["pos"])
		if d <= best_d:
			best_d = d
			best = i
	if best >= 0:
		var b: Dictionary = _balloons[best]
		b["node"].queue_free()
		_balloons.remove_at(best)
		_hits += 1
		Audio.play("select")
		_update_hud()
		if _hits >= need:
			_finish(true)

func _process(delta: float) -> void:
	if _done:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		_update_hud()
		_finish(_hits >= need)
		return
	_update_hud()
	_spawn_t -= delta
	if _spawn_t <= 0.0:
		_spawn()
		_spawn_t = randf_range(0.5, 1.1)
	var escaped: Array = []
	for b in _balloons:
		b["pos"].x += b["vx"] * delta
		b["pos"].y += b["vy"] * delta
		if b["pos"].x <= _area.position.x + 24:
			b["pos"].x = _area.position.x + 24; b["vx"] = absf(b["vx"])
		elif b["pos"].x >= _area.end.x - 24:
			b["pos"].x = _area.end.x - 24; b["vx"] = -absf(b["vx"])
		if b["pos"].y < _area.position.y + 20:
			escaped.append(b)
		else:
			b["node"].position = b["pos"] - Vector2(23, 28)
	for b in escaped:
		b["node"].queue_free()
		_balloons.erase(b)

func _finish(win: bool) -> void:
	if _done:
		return
	_done = true
	_hint.text = String(Loc.t("shoot_win")) if win else String(Loc.t("shoot_lose"))
	get_tree().create_timer(0.7).timeout.connect(func(): finished.emit(win))
