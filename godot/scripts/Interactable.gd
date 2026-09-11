extends Control
## 2D 탐색 핫스팟. 데이터만 보유하고, 대사/게이지/아트는 바깥에 위임한다.
## 지금은 색 박스(greybox)이지만, 나중에 _rect(ColorRect)를 TextureRect(그림)로
## 바꾸기만 하면 로직은 그대로 재사용된다.

signal examined_changed(node)   # 조사 완료 시 (Main 이 단서 카운트)
signal exit_requested           # 출구를 (열린 상태로) 눌렀을 때
signal goto_requested(room_id)  # 문: 다른 방으로 이동
signal detail_requested(node)   # 줌인: 상세 화면 열기

var display_name: String = "오브젝트"
var lines: Array = []
var gauge_delta: int = 0
var is_clue: bool = false
var is_exit: bool = false
var is_hidden_bonus: bool = false
var choices: Array = []
var goto_room: String = ""       # 비어있지 않으면 '문'
var detail_data: Dictionary = {} # 비어있지 않으면 '줌인 상세'
var exid: String = ""            # 단서 진행 추적용 고유 id

var examined: bool = false
var unlocked: bool = false

var _rect: ColorRect
var _label: Label
var _base_color: Color

## data 로 핫스팟 구성 (Main 이 호출). pos 는 화면상의 '중심' 픽셀 좌표.
func configure(data: Dictionary) -> void:
	display_name = data.get("name", "오브젝트")
	lines = data.get("lines", [])
	gauge_delta = int(data.get("gauge", 0))
	is_clue = bool(data.get("clue", false))
	is_exit = bool(data.get("exit", false))
	is_hidden_bonus = bool(data.get("hidden", false))
	choices = data.get("choices", [])
	goto_room = String(data.get("goto", ""))
	detail_data = data.get("detail", {})
	exid = String(data.get("exid", ""))

	var wsize: Vector2 = data.get("wsize", Vector2(110, 110))
	var center: Vector2 = data.get("pos", Vector2(200, 200))
	_base_color = data.get("color", Color(0.8, 0.7, 0.5))

	size = wsize
	position = center - wsize / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP

	_rect = ColorRect.new()
	_rect.color = _base_color
	_rect.size = wsize
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_hidden_bonus:
		_rect.modulate.a = 0.12   # 숨은 보너스: 거의 안 보이다 hover 시 드러남
	add_child(_rect)

	_label = Label.new()
	_label.text = "?" if is_hidden_bonus else display_name
	_label.position = Vector2(0, wsize.y + 4)
	_label.size = Vector2(wsize.x, 20)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.modulate = Color(1, 1, 1, 0)   # 평소엔 숨김, hover 시 표시
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	mouse_entered.connect(func(): _set_hover(true))
	mouse_exited.connect(func(): _set_hover(false))

func _set_hover(on: bool) -> void:
	if examined:
		return
	if on:
		_rect.modulate.a = 1.0
		_rect.color = _base_color.lightened(0.25)
		_label.modulate = Color(1, 1, 1, 0.85)
	else:
		_rect.modulate.a = 0.12 if is_hidden_bonus else 1.0
		_rect.color = _base_color
		_label.modulate = Color(1, 1, 1, 0)

func _gui_input(event: InputEvent) -> void:
	if Dialogue.is_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		interact()

func interact() -> void:
	if Dialogue.is_active:
		return
	if goto_room != "":
		goto_requested.emit(goto_room)
		return
	if not detail_data.is_empty():
		detail_requested.emit(self)
		return
	if is_exit:
		if not unlocked:
			Dialogue.say(display_name, [Loc.t("ex_locked")])
			return
		exit_requested.emit()
		return
	if not choices.is_empty() and not examined:
		var prompt := str(lines[0]) if lines.size() > 0 else "..."
		Dialogue.say_choices(display_name, prompt, choices, _on_choice)
		return
	Dialogue.say(display_name, lines)
	_mark_examined()

func _on_choice(index: int) -> void:
	var c: Dictionary = choices[index]
	Dialogue.say(display_name, c.get("lines", []))
	if c.has("gauge"):
		GameState.add_gauge(int(c["gauge"]))
	_mark_examined()

func _mark_examined() -> void:
	if examined:
		return
	examined = true
	if gauge_delta != 0:
		GameState.add_gauge(gauge_delta)
	if is_hidden_bonus:
		GameState.found_hidden += 1
	_rect.modulate.a = 1.0
	_rect.color = Color(0.32, 0.32, 0.4)   # 조사 완료 → 어둡게
	_label.modulate = Color(1, 1, 1, 0.25)
	examined_changed.emit(self)

## 출구가 열렸음을 시각적으로 표시 (Main 이 호출)
func mark_unlocked(col := Color(0.3, 0.9, 0.5)) -> void:
	unlocked = true
	_base_color = col
	_rect.color = col

## 게이지/신호 없이 '이미 조사됨' 시각만 적용 (상세 화면 재구성 시 복원용)
func mark_done_visual() -> void:
	if examined:
		return
	examined = true
	_rect.modulate.a = 1.0
	_rect.color = Color(0.32, 0.32, 0.4)
	_label.modulate = Color(1, 1, 1, 0.25)
