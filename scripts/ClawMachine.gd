extends Control
## 인형뽑기 미니게임. 집게가 좌우로 움직이고, 클릭/Space 로 내려서 인형을 집는다.
## 집게가 인형과 tolerance 안에서 멈추면 성공. 로직은 타이밍과 같지만 연출이 실제 집게.

signal finished(win: bool)

var speed_frac := 0.8    # 레일 폭 대비 초당 이동 (클수록 빠름=어려움) — Main 이 덮어씀
var tolerance := 38.0    # 집게-인형 정렬 허용 px (작을수록 어려움)

var _state := "move"     # move / drop / rise / done
var _claw_x := 0.0
var _claw_y := 0.0
var _dir := 1.0
var _rail_left := 0.0
var _rail_right := 0.0
var _rail_y := 0.0
var _doll_x := 0.0
var _doll_y := 0.0
var _grabbed := false
var _win := false
const DROP_SPEED := 430.0

var _cable: ColorRect
var _doll: Label
var _claw: Label
var _status: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vp := get_viewport_rect().size
	var bw := 460.0
	var bh := 380.0
	var bx := (vp.x - bw) / 2.0
	var by := (vp.y - bh) / 2.0 + 10.0
	_rail_y = by + 46.0
	_rail_left = bx + 54.0
	_rail_right = bx + bw - 54.0
	_doll_y = by + bh - 74.0
	_doll_x = randf_range(_rail_left, _rail_right)
	_claw_x = _rail_left
	_claw_y = _rail_y

	var box := ColorRect.new()
	box.color = Color8(40, 44, 64)
	box.position = Vector2(bx, by); box.size = Vector2(bw, bh)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var glass := ColorRect.new()
	glass.color = Color(1, 1, 1, 0.05)
	glass.position = Vector2(bx + 10, by + 10); glass.size = Vector2(bw - 20, bh - 20)
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glass)
	var rail := ColorRect.new()
	rail.color = Color8(90, 90, 110)
	rail.position = Vector2(_rail_left, _rail_y - 6); rail.size = Vector2(_rail_right - _rail_left, 5)
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rail)

	_cable = ColorRect.new()
	_cable.color = Color8(180, 180, 190)
	_cable.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cable)
	_doll = _emoji("🧸", 46)
	_claw = _emoji("🧲", 40)

	var title := _center_text(String(Loc.t("claw_title")), 24, Color(1, 0.95, 0.95), by - 58)
	title.add_theme_font_size_override("font_size", 24)
	_status = _center_text(String(Loc.t("claw_hint")), 16, Color(1, 1, 0.8), by + bh + 18)
	_update_visual()

func _emoji(txt: String, fsize: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

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

func _gui_input(event: InputEvent) -> void:
	if _state != "move":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		_state = "drop"

func _unhandled_input(event: InputEvent) -> void:
	if _state != "move":
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_state = "drop"

func _process(delta: float) -> void:
	match _state:
		"move":
			_claw_x += _dir * speed_frac * (_rail_right - _rail_left) * delta
			if _claw_x >= _rail_right:
				_claw_x = _rail_right; _dir = -1.0
			elif _claw_x <= _rail_left:
				_claw_x = _rail_left; _dir = 1.0
		"drop":
			_claw_y += DROP_SPEED * delta
			if _claw_y >= _doll_y:
				_claw_y = _doll_y
				_win = absf(_claw_x - _doll_x) <= tolerance
				_grabbed = _win
				_state = "rise"
		"rise":
			_claw_y -= DROP_SPEED * delta
			if _claw_y <= _rail_y:
				_claw_y = _rail_y
				_state = "done"
				_status.text = String(Loc.t("claw_win")) if _win else String(Loc.t("claw_lose"))
				get_tree().create_timer(0.7).timeout.connect(func(): finished.emit(_win))
	_update_visual()

func _update_visual() -> void:
	_claw.position = Vector2(_claw_x - 20, _claw_y - 22)
	_cable.position = Vector2(_claw_x - 2, _rail_y - 40)
	_cable.size = Vector2(4, _claw_y - (_rail_y - 40))
	if _grabbed:
		_doll.position = Vector2(_claw_x - 23, _claw_y + 12)
	else:
		_doll.position = Vector2(_doll_x - 23, _doll_y - 23)
