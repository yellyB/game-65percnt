extends Control
## 2인용 자전거 중심잡기 미니게임.
##  자전거가 좌우로 기운다. ← / → (또는 화면 좌/우 클릭)으로 반대쪽에 힘을 줘 균형 유지.
##  제한 시간 동안 넘어지지 않으면 성공. |기울기| 가 한계를 넘으면 실패.

signal finished(win: bool)

var duration := 12.0        # 버텨야 하는 시간(초)

const INSTABILITY := 2.1    # 기울수록 더 빨리 넘어가는 계수(역진자)
const IMPULSE := 0.52       # 한 번 입력 시 반대로 주는 힘
const FALL := 1.0           # 넘어짐 한계

var _tilt := 0.0            # -1(왼쪽) ~ +1(오른쪽)
var _vel := 0.0
var _t := 0.0
var _done := false
var _nudge_t := 0.0

var _area: Rect2
var _bike: Label
var _meter_bg: ColorRect
var _meter: ColorRect
var _title: Label
var _hint: Label
var _hud: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vp := get_viewport_rect().size
	var bw := 520.0
	var bh := 360.0
	var bx := (vp.x - bw) / 2.0
	var by := (vp.y - bh) / 2.0 + 10.0
	_area = Rect2(bx, by, bw, bh)

	_rect_at(Color8(40, 52, 66), Vector2(bx, by), Vector2(bw, bh))
	_rect_at(Color8(90, 130, 160), Vector2(bx + 10, by + bh - 70), Vector2(bw - 20, 60))  # 강물 느낌

	_title = _center_text(String(Loc.t("bike_title")), 20, Color(1, 0.95, 0.95), by - 54)
	_hud = _center_text("", 18, Color(0.85, 1, 0.9), by - 84)
	_hint = _center_text(String(Loc.t("bike_hint")), 16, Color(1, 1, 0.8), by + bh + 16)

	_bike = Label.new()
	_bike.text = "🚲"
	_bike.add_theme_font_size_override("font_size", 72)
	_bike.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bike.pivot_offset = Vector2(44, 44)
	add_child(_bike)

	# 기울기 미터
	var mw := 320.0
	_meter_bg = _rect_at(Color8(30, 30, 40), Vector2(bx + (bw - mw) / 2.0, by + bh - 26), Vector2(mw, 12))
	_meter = ColorRect.new()
	_meter.color = Color8(120, 220, 140)
	_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_meter)
	_update_hud()

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

func _push(dir: float) -> void:
	# dir < 0 : 왼쪽으로 보정 / dir > 0 : 오른쪽으로 보정
	if _done: return
	_vel += dir * IMPULSE
	Audio.play("tick")

func _gui_input(event: InputEvent) -> void:
	if _done: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		_push(-1.0 if event.position.x < get_viewport_rect().size.x / 2.0 else 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if _done: return
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.keycode
		if kc == KEY_LEFT or kc == KEY_A:
			get_viewport().set_input_as_handled(); _push(-1.0)
		elif kc == KEY_RIGHT or kc == KEY_D:
			get_viewport().set_input_as_handled(); _push(1.0)

func _process(delta: float) -> void:
	if _done: return
	_t += delta
	if _t >= duration:
		_finish(true); return
	# 역진자: 기울수록 가속. 가끔 랜덤 흔들림.
	_vel += _tilt * INSTABILITY * delta
	_nudge_t -= delta
	if _nudge_t <= 0.0:
		_vel += randf_range(-0.55, 0.55)
		_nudge_t = randf_range(0.6, 1.2)
	_vel *= 0.99
	_tilt += _vel * delta
	if absf(_tilt) >= FALL:
		_tilt = clampf(_tilt, -FALL, FALL)
		_finish(false); return
	_update_visual()
	_update_hud()

func _update_visual() -> void:
	var cx := _area.position.x + _area.size.x / 2.0
	var cy := _area.position.y + _area.size.y - 96.0
	_bike.position = Vector2(cx - 44 + _tilt * 120.0, cy - 44)
	_bike.rotation = _tilt * 0.6
	var mw := 320.0
	var half := mw / 2.0
	var mx := _area.position.x + (_area.size.x - mw) / 2.0 + half
	_meter.size = Vector2(absf(_tilt) * half, 12)
	_meter.position = Vector2(mx if _tilt >= 0 else mx - _meter.size.x, _area.position.y + _area.size.y - 26)
	_meter.color = Color8(120, 220, 140) if absf(_tilt) < 0.6 else Color8(230, 150, 80)

func _update_hud() -> void:
	_hud.text = "%s  ⏱ %.0f" % [Loc.t("bike_hud"), ceil(duration - _t)]

func _finish(win: bool) -> void:
	if _done: return
	_done = true
	_hint.text = String(Loc.t("bike_win")) if win else String(Loc.t("bike_lose"))
	get_tree().create_timer(0.7).timeout.connect(func(): finished.emit(win))
