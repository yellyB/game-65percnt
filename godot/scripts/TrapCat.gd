extends Control
## 검은 고양이 가두기 (Trap the Cat) — 헥사곤 전략 미니게임.
## 원작 game-escape_room/TrapSister.js 를 Godot 로 이식.
## 중앙 고양이를 바리케이드로 가두면 승리, 고양이가 가장자리로 탈출하면 패배.
## 고양이는 BFS 로 '가장자리까지 최단 경로'가 짧아지는 칸으로 도망친다.

signal finished(win: bool)

var radius := 6          # 보드 크기 (처음 포팅했던 크기) — Main 이 beat 에서 덮어쓸 수 있음
var seed_count := 14     # 초기 바리케이드 (많을수록 쉬움; 승률은 이 값으로 조절)
const INF := 1000000

const DIRS := [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]

var _cells: Array = []
var _runner := Vector2i(0, 0)
var _seeds := {}        # key -> true
var _barricades := {}   # key -> true
var _state := "playing" # playing / win / lose
var _player_turn := true
var _lock := false
var _moves := 0

# 레이아웃 캐시
var _centers := {}      # key -> Vector2 (화면 좌표)
var _hexpx := 20.0

var _title: Label
var _status: Label
var _moves_label: Label
var _continue_btn: Button
var _retry_btn: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_cells = _gen_board(radius)
	_seeds = _random_seeds()
	_build_hud()
	queue_redraw()

# ── 헥사 헬퍼 ──
func _k(c: Vector2i) -> String: return "%d,%d" % [c.x, c.y]
func _add(a: Vector2i, b: Vector2i) -> Vector2i: return a + b
func _axial_dist(a: Vector2i, b: Vector2i) -> int:
	return maxi(maxi(abs(a.x - b.x), abs(a.y - b.y)), abs(-a.x - a.y - (-b.x - b.y)))
func _is_inside(c: Vector2i) -> bool: return _axial_dist(c, Vector2i.ZERO) <= radius
func _is_edge(c: Vector2i) -> bool: return _axial_dist(c, Vector2i.ZERO) == radius
func _neighbors(c: Vector2i) -> Array:
	var out: Array = []
	for d in DIRS: out.append(c + d)
	return out
func _blocked(k: String) -> bool: return _seeds.has(k) or _barricades.has(k)

func _gen_board(radius: int) -> Array:
	var cells: Array = []
	for q in range(-radius, radius + 1):
		var r1 := maxi(-radius, -q - radius)
		var r2 := mini(radius, -q + radius)
		for r in range(r1, r2 + 1):
			cells.append(Vector2i(q, r))
	return cells

func _random_seeds() -> Dictionary:
	var pool: Array = []
	for c in _cells:
		if _k(c) != _k(Vector2i.ZERO): pool.append(_k(c))
	pool.shuffle()
	var s := {}
	for i in range(mini(seed_count, pool.size())): s[pool[i]] = true
	return s

func _axial_unit(c: Vector2i) -> Vector2:
	return Vector2(sqrt(3.0) * c.x + sqrt(3.0) / 2.0 * c.y, 1.5 * c.y)

# ── 고양이 AI (BFS) ──
func _shortest_to_edge(start: Vector2i, blocked: Dictionary) -> int:
	if _is_edge(start): return 0
	var visited := {_k(start): true}
	var q: Array = [[start, 0]]
	var head := 0
	while head < q.size():
		var cur = q[head]; head += 1
		for nb in _neighbors(cur[0]):
			var nk := _k(nb)
			if visited.has(nk) or not _is_inside(nb) or blocked.has(nk): continue
			var d: int = cur[1] + 1
			if _is_edge(nb): return d
			visited[nk] = true
			q.append([nb, d])
	return INF

func _pick_ai_move(from: Vector2i, blocked: Dictionary) -> Dictionary:
	var options: Array = []
	for nb in _neighbors(from):
		if _is_inside(nb) and not blocked.has(_k(nb)):
			options.append({"pos": nb, "score": _shortest_to_edge(nb, blocked)})
	if options.is_empty(): return {"ok": false}
	var mn := INF
	for o in options: mn = mini(mn, o["score"])
	var best: Array = options.filter(func(o): return o["score"] == mn)
	if mn == INF:
		best.sort_custom(func(a, b): return _axial_dist(a["pos"], Vector2i.ZERO) > _axial_dist(b["pos"], Vector2i.ZERO))
		return {"ok": true, "pos": best[0]["pos"]}
	return {"ok": true, "pos": best[randi() % best.size()]["pos"]}

# ── 입력 ──
func _gui_input(event: InputEvent) -> void:
	if _state != "playing" or _lock or not _player_turn: return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed): return
	accept_event()
	var cell := _nearest_cell(get_local_mouse_position())
	if cell.x == 9999: return
	var k := _k(cell)
	if k == _k(_runner) or _blocked(k): return
	_barricades[k] = true
	_player_turn = false
	_lock = true
	queue_redraw()
	_update_hud()
	get_tree().create_timer(0.25).timeout.connect(_ai_turn)

func _ai_turn() -> void:
	_moves += 1
	# 탈출 경로가 완전히 막혔으면 (내부에서 아직 움직일 수 있어도) 즉시 승리
	if _shortest_to_edge(_runner, _blocked_set()) == INF:
		_win()
		return
	var res := _pick_ai_move(_runner, _blocked_set())
	if not res["ok"]:
		_win()
		return
	_runner = res["pos"]
	queue_redraw()
	if _is_edge(_runner):
		_lose()
		return
	_player_turn = true
	_lock = false
	_update_hud()

func _blocked_set() -> Dictionary:
	var s := {}
	for k in _seeds: s[k] = true
	for k in _barricades: s[k] = true
	return s

func _win() -> void:
	_state = "win"; _lock = true; _player_turn = false
	queue_redraw(); _update_hud(); _show_end()

func _lose() -> void:
	_state = "lose"; _lock = true; _player_turn = false
	queue_redraw(); _update_hud(); _show_end()

func _reset() -> void:
	_barricades = {}
	_runner = Vector2i.ZERO
	_moves = 0
	_lock = false
	_player_turn = true
	_state = "playing"
	_seeds = _random_seeds()
	if _continue_btn: _continue_btn.queue_free(); _continue_btn = null
	if _retry_btn: _retry_btn.queue_free(); _retry_btn = null
	_update_hud()
	queue_redraw()

# ── 레이아웃 & 그리기 ──
func _ensure_layout() -> void:
	var rs := size
	var avail := Vector2(rs.x * 0.92, rs.y * 0.66)
	var top_pad := rs.y * 0.20
	var mn := Vector2(INF, INF)
	var mx := Vector2(-INF, -INF)
	var units := {}
	for c in _cells:
		var u := _axial_unit(c)
		units[_k(c)] = u
		mn.x = minf(mn.x, u.x); mn.y = minf(mn.y, u.y)
		mx.x = maxf(mx.x, u.x); mx.y = maxf(mx.y, u.y)
	var bw = (mx.x - mn.x) + 2.0
	var bh = (mx.y - mn.y) + 2.0
	_hexpx = minf(avail.x / bw, avail.y / bh)
	var board_w = bw * _hexpx
	var board_h = bh * _hexpx
	var origin := Vector2((rs.x - board_w) / 2.0 - mn.x * _hexpx + _hexpx,
						  top_pad + (avail.y - board_h) / 2.0 - mn.y * _hexpx + _hexpx)
	_centers = {}
	for c in _cells:
		_centers[_k(c)] = units[_k(c)] * _hexpx + origin

func _nearest_cell(p: Vector2) -> Vector2i:
	_ensure_layout()
	var bestk := ""
	var bestd := _hexpx
	for c in _cells:
		var d := p.distance_to(_centers[_k(c)])
		if d < bestd: bestd = d; bestk = _k(c)
	if bestk == "": return Vector2i(9999, 9999)
	var parts := bestk.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

func _draw() -> void:
	_ensure_layout()
	var r := _hexpx * 0.94
	for c in _cells:
		var ctr: Vector2 = _centers[_k(c)]
		var k := _k(c)
		var col: Color
		if _seeds.has(k): col = Color8(148, 163, 184)
		elif _barricades.has(k): col = Color8(90, 98, 112)
		elif k == _k(Vector2i.ZERO): col = Color8(229, 231, 235)
		elif _is_edge(c): col = Color8(243, 244, 246)
		else: col = Color8(255, 255, 255)
		var pts := _hex_points(ctr, r)
		draw_colored_polygon(pts, col)
		var outline := pts.duplicate(); outline.append(pts[0])
		draw_polyline(outline, Color8(203, 213, 225), 1.5)
	# 고양이
	var rc: Vector2 = _centers[_k(_runner)]
	draw_circle(rc, r * 0.55, Color8(20, 20, 24))
	draw_circle(rc + Vector2(-r * 0.22, -r * 0.4), r * 0.16, Color8(20, 20, 24)) # 귀
	draw_circle(rc + Vector2(r * 0.22, -r * 0.4), r * 0.16, Color8(20, 20, 24))

func _hex_points(ctr: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var ang := deg_to_rad(60.0 * i - 30.0)
		pts.append(ctr + Vector2(cos(ang), sin(ang)) * r)
	return pts

# ── HUD ──
func _build_hud() -> void:
	_title = _lbl(String(Loc.t("tc_title")), 24, Color(1, 0.95, 0.95), 0.04)
	_title.add_theme_font_size_override("font_size", 24)
	_status = _lbl("", 18, Color(1, 1, 0.8), 0.10)
	_moves_label = _lbl("", 15, Color(1, 1, 1, 0.6), 0.145)
	_update_hud()

func _lbl(text: String, fsize: int, col: Color, top_frac: float) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fsize)
	l.modulate = col
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.anchor_left = 0.0; l.anchor_right = 1.0
	l.anchor_top = top_frac; l.anchor_bottom = top_frac
	add_child(l)
	return l

func _update_hud() -> void:
	if _state == "win": _status.text = String(Loc.t("tc_win"))
	elif _state == "lose": _status.text = String(Loc.t("tc_lose"))
	elif not _player_turn or _lock: _status.text = String(Loc.t("tc_status_cat"))
	else: _status.text = String(Loc.t("tc_status_your"))
	_moves_label.text = "%s: %d" % [Loc.t("tc_moves"), _moves]

func _show_end() -> void:
	if _state == "win":
		# 승리 → 계속
		_continue_btn = _end_button(String(Loc.t("tc_continue")), 0.0)
		_continue_btn.pressed.connect(func(): finished.emit(true))
	else:
		# 실패 → 재시도 / 그냥 넘어가기
		_retry_btn = _end_button(String(Loc.t("tc_retry")), -95.0)
		_retry_btn.pressed.connect(_reset)
		_continue_btn = _end_button(String(Loc.t("tc_giveup")), 95.0)
		_continue_btn.pressed.connect(func(): finished.emit(false))

func _end_button(text: String, dx: float) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.anchor_left = 0.5; btn.anchor_right = 0.5
	btn.anchor_top = 0.88; btn.anchor_bottom = 0.88
	btn.offset_left = dx - 80; btn.offset_right = dx + 80
	add_child(btn)
	return btn
