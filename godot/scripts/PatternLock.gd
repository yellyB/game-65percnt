extends Control
## 휴대폰 패턴 잠금 (방탈출).
## 3×3 점을 정답 순서대로 클릭해 이으면 해제. 화면 얼룩(정답 경로)이 희미한 힌트.

signal finished(win: bool)

var answer: Array = []        # 정답 점 순서 [0..8]  (Main 이 설정)
var show_hint := true         # 얼룩(정답 경로) 힌트 표시
var hint_text := ""

var _dots: Array = []         # 점 중심 좌표
var _path: Array = []         # 현재 그린 순서
var _done := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vp := get_viewport_rect().size
	var cx := vp.x / 2.0
	var cy := vp.y / 2.0 + 10.0
	var gap := 120.0
	for r in 3:
		for c in 3:
			_dots.append(Vector2(cx + (c - 1) * gap, cy + (r - 1) * gap))

	_center_text(String(Loc.t("pattern_title")), 24, Color(1, 0.95, 0.95), cy - 220.0)
	if hint_text != "":
		var h := _center_text(hint_text, 16, Color(1, 1, 0.8), cy - 185.0)
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var clear_btn := Button.new()
	clear_btn.text = String(Loc.t("kp_clear"))
	clear_btn.anchor_left = 0.5; clear_btn.anchor_right = 0.5; clear_btn.anchor_top = 0.5; clear_btn.anchor_bottom = 0.5
	clear_btn.offset_left = -140; clear_btn.offset_right = -20; clear_btn.offset_top = 210
	clear_btn.pressed.connect(func(): _path.clear(); queue_redraw())
	add_child(clear_btn)
	var give_btn := Button.new()
	give_btn.text = String(Loc.t("kp_giveup"))
	give_btn.anchor_left = 0.5; give_btn.anchor_right = 0.5; give_btn.anchor_top = 0.5; give_btn.anchor_bottom = 0.5
	give_btn.offset_left = 20; give_btn.offset_right = 140; give_btn.offset_top = 210
	give_btn.pressed.connect(func(): _finish(false))
	add_child(give_btn)
	queue_redraw()

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
	if _done:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var p := get_local_mouse_position()
		for i in 9:
			if p.distance_to(_dots[i]) <= 30.0 and not _path.has(i):
				accept_event()
				_path.append(i)
				queue_redraw()
				if _path.size() == answer.size():
					_check()
				return

func _check() -> void:
	if _path == answer:
		_done = true
		queue_redraw()
		get_tree().create_timer(0.3).timeout.connect(func(): _finish(true))
	else:
		_path.clear()
		queue_redraw()

func _finish(win: bool) -> void:
	_done = true
	finished.emit(win)

func _draw() -> void:
	# 힌트(얼룩): 정답 경로를 희미하게
	if show_hint and answer.size() >= 2:
		for i in answer.size() - 1:
			draw_line(_dots[answer[i]], _dots[answer[i + 1]], Color(1, 1, 1, 0.12), 8.0)
	# 현재 그린 경로
	for i in _path.size() - 1:
		draw_line(_dots[_path[i]], _dots[_path[i + 1]], Color(0.4, 0.8, 1.0, 0.9), 6.0)
	# 점
	for i in 9:
		var col: Color = Color(0.45, 0.75, 1.0) if _path.has(i) else Color(0.65, 0.65, 0.72)
		draw_circle(_dots[i], 16.0, col)
