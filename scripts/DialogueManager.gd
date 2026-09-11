extends CanvasLayer
## 대사 시스템 (Autoload)
## 월드의 오브젝트와 분리되어 있다. 오브젝트는 "말해줘"라고 요청만 하고,
## 실제 출력/선택지 UI는 여기서 처리한다.
##
##   Dialogue.say(화자, 대사, 끝나면_콜백)
##   Dialogue.say_choices(화자, 질문, [{text, lines, gauge}], 선택_콜백)

var is_active: bool = false

var _catcher: Control    # 대사 중 화면 전체 클릭을 받아 다음 줄로 (핫스팟이 클릭 가로채지 않게)
var _panel: Panel
var _name: Label
var _text: Label
var _choices: VBoxContainer
var _hint: Label

var _queue: Array = []
var _on_done: Callable = Callable()
var _on_choice: Callable = Callable()
var _mode: String = ""   # "lines" | "choice"

var _cursor_root: Node2D   # 소프트웨어 커서 (OS 커서가 안 그려지는 macOS 이슈 회피)

func _ready() -> void:
	# OS 커서를 숨기고, 게임이 직접 커서를 그린다 → 렌더러/OS 상관없이 항상 보임.
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_build_soft_cursor()
	layer = 20
	_build_ui()
	_panel.visible = false

func _build_soft_cursor() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 128   # 무조건 맨 위
	add_child(cl)
	_cursor_root = Node2D.new()
	cl.add_child(_cursor_root)
	# 화살표 모양 (팁이 0,0 = 실제 클릭 지점)
	var pts := PackedVector2Array([
		Vector2(0, 0), Vector2(0, 18), Vector2(5, 13.5),
		Vector2(8, 20), Vector2(11, 18.5), Vector2(8, 12.5), Vector2(13, 12.5)
	])
	var outline := Polygon2D.new()
	outline.polygon = pts
	outline.color = Color(0, 0, 0, 0.9)
	outline.scale = Vector2(1.3, 1.3)
	_cursor_root.add_child(outline)
	var fill := Polygon2D.new()
	fill.polygon = pts
	fill.color = Color(1, 1, 1, 1)
	_cursor_root.add_child(fill)

func _process(_delta: float) -> void:
	if _cursor_root:
		_cursor_root.position = get_viewport().get_mouse_position()

func _build_ui() -> void:
	# 클릭 캐처 (패널보다 먼저 추가 → 패널/선택지 버튼이 위에 옴)
	_catcher = Control.new()
	add_child(_catcher)
	_catcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	_catcher.gui_input.connect(_on_catcher_input)
	_catcher.visible = false

	_panel = Panel.new()
	add_child(_panel)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 클릭이 캐처로 통과 → 대사창 눌러도 넘어감
	_panel.anchor_left = 0.0
	_panel.anchor_top = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_top = -240.0
	_panel.offset_left = 0.0
	_panel.offset_right = 0.0
	_panel.offset_bottom = 0.0

	var margin := MarginContainer.new()
	_panel.add_child(margin)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 10)

	_name = Label.new()
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.add_theme_font_size_override("font_size", 18)
	_name.modulate = Color(1.0, 0.6, 0.7)
	vbox.add_child(_name)

	_text = Label.new()
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 20)
	_text.custom_minimum_size = Vector2(0, 96)
	vbox.add_child(_text)

	# 선택지 컨테이너는 통과시키되, 안에 들어갈 버튼들은 기본(STOP)이라 클릭됨
	_choices = VBoxContainer.new()
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_choices.add_theme_constant_override("separation", 8)
	vbox.add_child(_choices)

	_hint = Label.new()
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.text = String(Loc.t("dlg_hint"))
	_hint.modulate = Color(1, 1, 1, 0.4)
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_hint)

## 대사 출력. lines 는 String 또는 Array[String]. name_color 로 화자별 색.
func say(speaker: String, lines, on_done: Callable = Callable(), name_color := Color(1.0, 0.6, 0.7)) -> void:
	_queue = (lines.duplicate() if typeof(lines) == TYPE_ARRAY else [str(lines)])
	_on_done = on_done
	_mode = "lines"
	is_active = true
	_name.text = speaker
	_name.modulate = name_color
	_name.visible = speaker != ""
	_clear_choices()
	_choices.visible = false
	_hint.visible = true
	_panel.visible = true
	_catcher.visible = true
	_next_line()

func _next_line() -> void:
	if _queue.is_empty():
		_finish()
		return
	_text.text = str(_queue.pop_front())

## 선택지. options 예: [{ "text": "...", "lines": ["..."], "gauge": 4 }]
func say_choices(speaker: String, prompt: String, options: Array, on_choice: Callable, name_color := Color(1.0, 0.6, 0.7)) -> void:
	_mode = "choice"
	_on_choice = on_choice
	is_active = true
	_name.text = speaker
	_name.modulate = name_color
	_name.visible = speaker != ""
	_text.text = prompt
	_hint.visible = false
	_clear_choices()
	for i in options.size():
		var opt: Dictionary = options[i]
		var btn := Button.new()
		btn.text = str(opt.get("text", "..."))
		btn.pressed.connect(_on_choice_pressed.bind(i))
		_choices.add_child(btn)
	_choices.visible = true
	_panel.visible = true
	_catcher.visible = true   # 버튼 밖 클릭 흡수 (선택지 모드에선 넘어가지 않음)

func _on_choice_pressed(index: int) -> void:
	var cb := _on_choice
	_on_choice = Callable()
	_choices.visible = false
	if cb.is_valid():
		cb.call(index)   # 콜백이 이어서 say(...)를 부르거나 닫는다.

func _clear_choices() -> void:
	for c in _choices.get_children():
		c.queue_free()

func _finish() -> void:
	is_active = false
	_panel.visible = false
	_catcher.visible = false
	var cb := _on_done
	_on_done = Callable()
	if cb.is_valid():
		cb.call()

func _on_catcher_input(event: InputEvent) -> void:
	if _mode != "lines":
		return   # 선택지 모드에선 버튼으로만 진행
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_catcher.accept_event()
		_next_line()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or _mode != "lines":
		return
	var advance := event.is_action_pressed("ui_accept")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		advance = true
	if advance:
		get_viewport().set_input_as_handled()
		_next_line()
