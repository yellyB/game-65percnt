extends Control
## 인형뽑기 미니게임 (2단계).
##  ① 집게가 좌우로 움직임 → Space/클릭 으로 정지 (목표 인형 x 에 맞추기)
##  ② 집게가 내려갈 때 → 인형에 닿는 순간(잡기 구간) Space/클릭 으로 잡기 (타이밍, 자동 아님)
##  여러 인형이 쌓여있고, 표시된 '목표 인형'을 정확히 뽑아야 성공.

signal finished(win: bool)

var speed_frac := 0.85    # 좌우 이동 속도 (레일폭 대비/초) — 클수록 어려움
var tolerance := 34.0     # 목표 인형과의 x 허용 오차 px

const DROP_SPEED := 260.0 # 하강 속도 (느릴수록 잡기 타이밍 쉬움)
const DOLL_EMOJIS := ["🧸", "🐰", "🐻", "🐱", "⭐", "🎁", "🐧"]

var _state := "aim"       # aim / drop / rise / done
var _claw_x := 0.0
var _claw_y := 0.0
var _dir := 1.0
var _rail_left := 0.0
var _rail_right := 0.0
var _rail_y := 0.0
var _grab_top := 0.0
var _grab_bottom := 0.0
var _doll_y := 0.0
var _resolved := false
var _grabbed := false
var _win := false

var _dolls: Array = []    # [{x, emoji, node}]
var _target := 0

var _cable: ColorRect
var _claw: Label
var _hint: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vp := get_viewport_rect().size
	var bw := 480.0
	var bh := 400.0
	var bx := (vp.x - bw) / 2.0
	var by := (vp.y - bh) / 2.0 + 10.0
	_rail_y = by + 44.0
	_rail_left = bx + 54.0
	_rail_right = bx + bw - 54.0
	_doll_y = by + bh - 66.0
	_grab_top = _doll_y - 44.0
	_grab_bottom = _doll_y + 6.0
	_claw_x = _rail_left
	_claw_y = _rail_y

	_rect_at(Color8(40, 44, 64), Vector2(bx, by), Vector2(bw, bh))
	_rect_at(Color(1, 1, 1, 0.05), Vector2(bx + 10, by + 10), Vector2(bw - 20, bh - 20))
	_rect_at(Color8(90, 90, 110), Vector2(_rail_left, _rail_y - 6), Vector2(_rail_right - _rail_left, 5))
	# 잡기 구간(닿는 순간 표시)
	_rect_at(Color(0.3, 0.9, 0.5, 0.18), Vector2(bx + 20, _grab_top), Vector2(bw - 40, _grab_bottom - _grab_top))

	# 인형 여러 개 (서로 다른 이모지, 한 줄로 배치)
	var count := 5
	var pile_l := bx + 74.0
	var pile_r := bx + bw - 74.0
	for i in count:
		var t := float(i) / float(count - 1)
		var lab := Label.new()
		lab.add_theme_font_size_override("font_size", 40)
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.text = DOLL_EMOJIS[i % DOLL_EMOJIS.size()]
		add_child(lab)
		_dolls.append({"x": lerpf(pile_l, pile_r, t), "emoji": DOLL_EMOJIS[i % DOLL_EMOJIS.size()], "node": lab})
	_target = randi() % _dolls.size()

	_cable = _rect_at(Color8(180, 180, 190), Vector2.ZERO, Vector2(4, 4))
	_claw = Label.new(); _claw.text = "🧲"; _claw.add_theme_font_size_override("font_size", 40)
	_claw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_claw)

	_center_text("%s %s" % [Loc.t("claw_target"), _dolls[_target]["emoji"]], 22, Color(1, 0.95, 0.6), by - 84)
	_center_text(String(Loc.t("claw_title")), 20, Color(1, 0.95, 0.95), by - 54)
	_hint = _center_text(String(Loc.t("claw_hint_aim")), 16, Color(1, 1, 0.8), by + bh + 16)
	# 목표 인형 위 화살표
	var arrow := Label.new(); arrow.text = "▼"; arrow.add_theme_font_size_override("font_size", 22)
	arrow.modulate = Color(1, 0.9, 0.4)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.position = Vector2(_dolls[_target]["x"] - 8, _doll_y - 62)
	add_child(arrow)

	_update_visual()

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

func _press() -> void:
	if _state == "aim":
		_state = "drop"
		_hint.text = String(Loc.t("claw_hint_grab"))
	elif _state == "drop":
		_try_grab()

func _try_grab() -> void:
	if _resolved:
		return
	_resolved = true
	var in_zone := _claw_y >= _grab_top and _claw_y <= _grab_bottom
	_win = in_zone and absf(_claw_x - _dolls[_target]["x"]) <= tolerance
	_grabbed = _win
	_state = "rise"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		_press()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_press()

func _process(delta: float) -> void:
	match _state:
		"aim":
			_claw_x += _dir * speed_frac * (_rail_right - _rail_left) * delta
			if _claw_x >= _rail_right: _claw_x = _rail_right; _dir = -1.0
			elif _claw_x <= _rail_left: _claw_x = _rail_left; _dir = 1.0
		"drop":
			_claw_y += DROP_SPEED * delta
			if _claw_y >= _doll_y:
				_claw_y = _doll_y
				if not _resolved:
					_resolved = true
					_win = false
					_grabbed = false
					_state = "rise"
		"rise":
			_claw_y -= DROP_SPEED * delta
			if _claw_y <= _rail_y:
				_claw_y = _rail_y
				_state = "done"
				_hint.text = String(Loc.t("claw_win")) if _win else String(Loc.t("claw_lose"))
				get_tree().create_timer(0.7).timeout.connect(func(): finished.emit(_win))
	_update_visual()

func _update_visual() -> void:
	_claw.position = Vector2(_claw_x - 20, _claw_y - 22)
	_cable.position = Vector2(_claw_x - 2, _rail_y - 40)
	_cable.size = Vector2(4, _claw_y - (_rail_y - 40))
	for d in _dolls:
		if _grabbed and d == _dolls[_target]:
			d["node"].position = Vector2(_claw_x - 22, _claw_y + 12)
		else:
			d["node"].position = Vector2(d["x"] - 22, _doll_y - 22)
