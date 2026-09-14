extends RefCounted
## 게임 전체 스크립트 (구조). 텍스트는 text/ko.gd 에 키로 있다.
## GameFlow(Main.gd)가 순서대로 처리. 진행 대사·독백은 원작 senario.md 에 충실.
##
## beat: title / bg / fade / shake / flash / line / choice / explore / score / ending
##   line:   {"t":"line","who":..,"key":..,"expr":<표정stem>,"cg":<CG stem>}
##   choice: {"t":"choice","who":..,"prompt":..,"options":[{"key":..,"gauge":n,"reply":..}]}
##   explore:{"t":"explore","data":{"goal":..,"objects":[{name,lines,frac,wsize,color,clue,exit,hidden,gauge,img,choices}]}}

static func beats() -> Array:
	return [
		{"t": "title"},

		# ═══ 프롤로그 · 축제 ═══
		{"t": "bg", "color": Color8(232, 168, 124), "desc": "desc_festival", "img": "bg_festival"},
		{"t": "line", "who": "narrator", "key": "pr_walk1"},
		# 케미 + 외모 씨앗 (조건부 사랑 복선)
		{"t": "line", "who": "hero", "key": "pr_hero_cotton", "expr": "hero_normal_smile"},
		{"t": "line", "who": "heroine", "key": "pr_heroine_cotton"},
		{"t": "line", "who": "hero", "key": "pr_hero_stay", "expr": "hero_normal_smile"},
		{"t": "line", "who": "narrator", "key": "pr_mono_looks"},
		# 집착 장면 (여주는 로맨틱하게 느끼고, 플레이어는 위험신호로 읽게)
		{"t": "line", "who": "narrator", "key": "pr_narr_wave"},
		{"t": "line", "who": "hero", "key": "pr_hero_who", "expr": "hero_normal_calm"},
		{"t": "line", "who": "heroine", "key": "pr_heroine_who"},
		{"t": "line", "who": "hero", "key": "pr_hero_mine", "expr": "hero_normal_calm"},
		{"t": "line", "who": "narrator", "key": "pr_mono_romantic"},
		# 축제 둘러보기 (거리↔골목 + 줌인 + 숨은 고양이) → 부스 골목으로
		# ▼ 다중 방(거리↔골목) + 줌인(포장마차) 쇼케이스
		{"t": "explore", "data": {"goal": "ex_fest_goal", "start": "street", "rooms": {
			"street": {"objects": [
				# 포장마차: 클릭 시 줌인 → 상세 화면에서 단서
				{"name": "ex_fest_stall_name", "img": "obj_festival_stall",
				 "frac": Vector2(0.20, 0.42), "wsize": Vector2(120, 90), "color": Color8(179, 128, 77),
				 "detail": {"color": Color8(58, 44, 34), "objects": [
					{"name": "ex_fest_pot_name", "lines": "ex_fest_pot_lines", "img": "obj_festival_pot",
					 "frac": Vector2(0.40, 0.48), "wsize": Vector2(150, 130), "color": Color8(180, 160, 120), "clue": true},
					{"name": "ex_fest_menu_name", "lines": "ex_fest_menu_lines", "img": "obj_festival_menu",
					 "frac": Vector2(0.72, 0.40), "wsize": Vector2(110, 150), "color": Color8(220, 220, 200)}]}},
				{"name": "ex_fest_bench_name", "lines": "ex_fest_bench_lines", "img": "obj_festival_bench",
				 "frac": Vector2(0.30, 0.70), "wsize": Vector2(110, 70), "color": Color8(150, 120, 90), "clue": true},
				{"name": "ex_fest_door_alley", "goto": "alley",
				 "frac": Vector2(0.92, 0.62), "wsize": Vector2(80, 130), "color": Color8(45, 45, 65)},
				{"name": "ex_fest_booths_name", "lines": "ex_fest_booths_lines", "img": "obj_festival_tent",
				 "frac": Vector2(0.52, 0.56), "wsize": Vector2(150, 110), "color": Color8(90, 70, 120), "exit": true}]},
			"alley": {"objects": [
				{"name": "ex_fest_poster_name", "lines": "ex_fest_poster_lines", "img": "obj_festival_poster",
				 "frac": Vector2(0.38, 0.45), "wsize": Vector2(110, 150), "color": Color8(120, 110, 100), "clue": true},
				{"name": "ex_fest_cat_name", "lines": "ex_fest_cat_lines", "img": "obj_festival_cat",
				 "frac": Vector2(0.74, 0.55), "wsize": Vector2(70, 70), "color": Color8(230, 216, 128), "hidden": true, "gauge": 2},
				{"name": "ex_fest_door_street", "goto": "street",
				 "frac": Vector2(0.10, 0.62), "wsize": Vector2(80, 130), "color": Color8(70, 65, 50)}]},
		}}},
		# 오락 부스 허브 → 사랑 측정 부스(진행). 다른 부스 다 봐야 열림.
		{"t": "hub", "prompt": "hub_prompt", "booths": [
			{"name": "booth_cat", "frac": Vector2(0.27, 0.42), "color": Color8(70, 62, 110),
			 "game": {"game": "trapcat", "radius": 6, "seeds": 14,
				"success_gauge": 3, "fail_gauge": 0, "success": "mg_cat_win", "fail": "mg_cat_lose"}},
			{"name": "booth_claw", "frac": Vector2(0.73, 0.42), "color": Color8(180, 90, 110),
			 "game": {"game": "claw", "speed": 0.8, "tolerance": 40,
				"success_gauge": 4, "fail_gauge": -1, "success": "mg_claw_win", "fail": "mg_claw_lose"}},
			{"name": "booth_lovetest", "frac": Vector2(0.50, 0.72), "color": Color8(200, 80, 120), "exit": true}]},
		{"t": "line", "who": "hero", "key": "pr_hero_wanna", "expr": "hero_normal_smile"},
		{"t": "line", "who": "heroine", "key": "pr_heroine_ok"},
		{"t": "line", "who": "narrator", "key": "pr_walk2"},

		{"t": "bg", "color": Color8(45, 36, 56), "desc": "desc_tent", "img": "bg_tent"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "pr_narr_inside"},
		{"t": "explore", "data": {"goal": "ex_tent_goal", "objects": [
			{"name": "ex_tent_vr_name", "lines": "ex_tent_vr_lines", "img": "obj_tent_machine",
			 "frac": Vector2(0.65, 0.35), "wsize": Vector2(120, 100), "color": Color8(90, 110, 160), "clue": true},
			{"name": "ex_tent_manual_name", "lines": "ex_tent_manual_lines", "img": "obj_tent_manual",
			 "frac": Vector2(0.25, 0.45), "wsize": Vector2(100, 80), "color": Color8(200, 200, 180), "clue": true},
			{"name": "ex_tent_chair_name", "lines": "ex_tent_chair_lines", "img": "obj_tent_chair",
			 "frac": Vector2(0.50, 0.74), "wsize": Vector2(130, 70), "color": Color8(120, 110, 100), "exit": true}]}},
		{"t": "line", "who": "system", "key": "pr_sys_welcome"},
		{"t": "line", "who": "heroine", "key": "pr_heroine_startled"},
		{"t": "line", "who": "narrator", "key": "pr_narr_menu"},
		{"t": "line", "who": "system", "key": "pr_sys_desc1"},
		{"t": "line", "who": "system", "key": "pr_sys_desc2"},
		{"t": "line", "who": "system", "key": "pr_sys_desc3"},
		{"t": "line", "who": "narrator", "key": "pr_mono_sure"},
		{"t": "line", "who": "hero", "key": "pr_hero_justgame", "expr": "hero_normal_smile"},
		{"t": "line", "who": "narrator", "key": "pr_narr_dark"},

		# ═══ 테스트 1 · 성별 반전 ═══
		{"t": "bg", "color": Color8(168, 85, 247), "desc": "desc_test1", "img": "bg_gender_room"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "t1_dots"},
		{"t": "line", "who": "narrator", "key": "t1_wake"},
		{"t": "line", "who": "heroine", "key": "t1_uh"},
		{"t": "line", "who": "narrator", "key": "t1_startle"},
		{"t": "line", "who": "narrator", "key": "t1_lookslike"},
		{"t": "line", "who": "heroine", "key": "t1_vr"},
		{"t": "line", "who": "hero", "key": "t1_hero_startled", "expr": "hero_female_surprise"},
		{"t": "line", "who": "heroine", "key": "t1_cheatstory"},
		{"t": "line", "who": "hero", "key": "t1_youtoo", "expr": "hero_female_calm"},
		{"t": "line", "who": "narrator", "key": "t1_voice"},
		{"t": "line", "who": "heroine", "key": "t1_male"},
		{"t": "explore", "data": {"goal": "ex_gender_goal", "objects": [
			{"name": "ex_gender_mirror_name", "lines": "ex_gender_mirror_lines", "img": "obj_gender_mirror",
			 "frac": Vector2(0.50, 0.30), "wsize": Vector2(120, 150), "color": Color8(180, 200, 220), "clue": true},
			{"name": "ex_gender_hand_name", "lines": "ex_gender_hand_lines", "img": "obj_gender_hand",
			 "frac": Vector2(0.22, 0.58), "wsize": Vector2(100, 80), "color": Color8(210, 180, 160), "clue": true},
			{"name": "ex_gender_clothes_name", "lines": "ex_gender_clothes_lines", "img": "obj_gender_clothes",
			 "frac": Vector2(0.78, 0.52), "wsize": Vector2(100, 110), "color": Color8(150, 150, 170), "clue": true},
			{"name": "ex_gender_adapt_name", "lines": "ex_gender_adapt_lines", "img": "obj_gender_adapt",
			 "frac": Vector2(0.50, 0.82), "wsize": Vector2(130, 60), "color": Color8(120, 120, 140), "exit": true}]}},
		{"t": "line", "who": "narrator", "key": "t1_bodycheck"},
		{"t": "line", "who": "narrator", "key": "t1_ponder"},
		{"t": "line", "who": "hero", "key": "t1_keepstyle", "expr": "hero_female_calm"},
		{"t": "choice", "who": "heroine", "prompt": "t1_choice_prompt", "options": [
			{"key": "t1_c1", "gauge": 3, "reply": "t1_c1r"},
			{"key": "t1_c2", "gauge": -1, "reply": "t1_c2r"}]},
		{"t": "line", "who": "narrator", "key": "t1_adapted"},
		{"t": "bg", "color": Color8(255, 180, 120), "desc": "desc_date", "img": "bg_date"},
		{"t": "explore", "data": {"goal": "ex_date_goal", "objects": [
			{"name": "ex_date_cafe_name", "lines": "ex_date_cafe_lines", "img": "obj_date_cafe",
			 "frac": Vector2(0.22, 0.40), "wsize": Vector2(110, 90), "color": Color8(160, 110, 80), "clue": true, "gauge": 1},
			{"name": "ex_date_park_name", "lines": "ex_date_park_lines", "img": "obj_date_park",
			 "frac": Vector2(0.50, 0.32), "wsize": Vector2(110, 90), "color": Color8(90, 160, 90), "clue": true, "gauge": 1},
			{"name": "ex_date_movie_name", "lines": "ex_date_movie_lines", "img": "obj_date_movie",
			 "frac": Vector2(0.78, 0.42), "wsize": Vector2(110, 90), "color": Color8(80, 80, 120), "clue": true, "gauge": 1},
			{"name": "ex_date_home_name", "lines": "ex_date_home_lines", "img": "obj_date_home",
			 "frac": Vector2(0.50, 0.76), "wsize": Vector2(120, 60), "color": Color8(60, 60, 90), "exit": true}]}},
		{"t": "line", "who": "narrator", "key": "t1_night"},
		{"t": "line", "who": "narrator", "key": "t1_confused"},
		{"t": "line", "who": "heroine", "key": "t1_why"},
		{"t": "line", "who": "hero", "key": "t1_cant", "expr": "hero_female_pain"},
		{"t": "choice", "who": "heroine", "prompt": "t1_night_prompt", "options": [
			{"key": "t1_n1", "gauge": 4, "reply": "t1_n1r"},
			{"key": "t1_n2", "gauge": -3, "reply": "t1_n2r"},
			{"key": "t1_n3", "gauge": -5, "reply": "t1_n3r"}]},

		# ═══ 테스트 1 종료 ═══
		{"t": "bg", "color": Color8(26, 26, 46), "desc": ""},
		{"t": "fade"},
		{"t": "line", "who": "system", "key": "mid_sys_end"},
		{"t": "line", "who": "hero", "key": "mid_hero_real", "expr": "hero_normal_smile"},
		{"t": "line", "who": "heroine", "key": "mid_heroine_ok"},

		# ═══ 테스트 2 · 강아지 ═══
		{"t": "bg", "color": Color8(86, 130, 60), "desc": "desc_test2", "img": "bg_puppy_room"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "t2_wake", "cg": "cg_dog_pov"},
		{"t": "line", "who": "hero", "key": "t2_isit", "expr": "hero_normal_surprise"},
		{"t": "line", "who": "narrator", "key": "t2_dog"},
		{"t": "line", "who": "narrator", "key": "t2_monolog1"},
		{"t": "explore", "data": {"goal": "ex_puppy_goal", "objects": [
			{"name": "ex_puppy_bowl_name", "lines": "ex_puppy_bowl_lines", "img": "obj_puppy_bowl",
			 "frac": Vector2(0.20, 0.60), "wsize": Vector2(120, 80), "color": Color8(179, 128, 77), "clue": true},
			{"name": "ex_puppy_sofa_name", "lines": "ex_puppy_sofa_lines", "img": "obj_puppy_sofa",
			 "frac": Vector2(0.16, 0.40), "wsize": Vector2(150, 90), "color": Color8(77, 77, 97), "clue": true},
			{"name": "ex_puppy_door_name", "lines": "ex_puppy_door_lines", "img": "obj_puppy_door",
			 "frac": Vector2(0.83, 0.42), "wsize": Vector2(90, 180), "color": Color8(140, 102, 77), "clue": true},
			{"name": "ex_puppy_toy_name", "lines": "ex_puppy_toy_lines", "img": "obj_puppy_toy",
			 "frac": Vector2(0.72, 0.64), "wsize": Vector2(90, 80), "color": Color8(217, 90, 102), "clue": true},
			{"name": "ex_puppy_touch_name", "lines": "ex_puppy_touch_lines", "img": "hero_normal_calm",
			 "frac": Vector2(0.48, 0.48), "wsize": Vector2(110, 140), "color": Color8(128, 153, 217), "clue": true,
			 "choices": [
				{"key": "ex_puppy_touch_c1", "gauge": 5, "lines": "ex_puppy_touch_c1r"},
				{"key": "ex_puppy_touch_c2", "gauge": -3, "lines": "ex_puppy_touch_c2r"}]},
			{"name": "ex_puppy_cat_name", "lines": "ex_puppy_cat_lines", "img": "obj_puppy_cat",
			 "frac": Vector2(0.88, 0.18), "wsize": Vector2(70, 70), "color": Color8(230, 216, 128), "hidden": true, "gauge": 2},
			{"name": "ex_puppy_exit_name", "lines": "ex_puppy_exit_lines", "img": "obj_puppy_exit",
			 "frac": Vector2(0.50, 0.82), "wsize": Vector2(150, 60), "color": Color8(128, 128, 140), "exit": true}]}},
		{"t": "line", "who": "narrator", "key": "t2_bond"},
		{"t": "line", "who": "system", "key": "t2_sys_end"},
		{"t": "line", "who": "hero", "key": "t2_invalid", "expr": "hero_normal_pain"},
		{"t": "line", "who": "hero", "key": "t2_hero_love", "expr": "hero_normal_pain"},
		{"t": "choice", "who": "heroine", "prompt": "t2_choice_prompt", "options": [
			{"key": "t2_c1", "gauge": 3, "reply": "t2_c1r"},
			{"key": "t2_c2", "gauge": -2, "reply": "t2_c2r"}]},
		{"t": "line", "who": "heroine", "key": "t2_human"},

		# ═══ 테스트 3 · 부녀 ═══
		{"t": "bg", "color": Color8(110, 110, 110), "desc": "desc_test3", "img": "bg_family_home"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "t3_human"},
		{"t": "line", "who": "system", "key": "t3_confirm"},
		{"t": "line", "who": "narrator", "key": "t3_cert"},
		{"t": "line", "who": "heroine", "key": "t3_father"},
		{"t": "line", "who": "narrator", "key": "t3_shock"},
		{"t": "line", "who": "narrator", "key": "t3_disgust"},
		{"t": "line", "who": "narrator", "key": "t3_moment"},
		{"t": "shake"},
		{"t": "bg", "color": Color8(45, 27, 27), "desc": ""},
		{"t": "line", "who": "narrator", "key": "t3_arrest"},
		{"t": "line", "who": "narrator", "key": "t3_trap"},

		{"t": "bg", "color": Color8(26, 26, 26), "desc": "desc_prison", "img": "bg_prison"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "t3_visit"},
		{"t": "explore", "data": {"goal": "ex_prison_goal", "objects": [
			{"name": "ex_prison_window_name", "lines": "ex_prison_window_lines", "img": "obj_prison_window",
			 "frac": Vector2(0.50, 0.28), "wsize": Vector2(140, 100), "color": Color8(120, 140, 160), "clue": true},
			{"name": "ex_prison_phone_name", "lines": "ex_prison_phone_lines", "img": "obj_prison_phone",
			 "frac": Vector2(0.24, 0.55), "wsize": Vector2(100, 90), "color": Color8(80, 80, 90), "clue": true},
			{"name": "ex_prison_wall_name", "lines": "ex_prison_wall_lines", "img": "obj_prison_wall",
			 "frac": Vector2(0.80, 0.42), "wsize": Vector2(100, 80), "color": Color8(120, 120, 110), "clue": true},
			{"name": "ex_prison_exit_name", "lines": "ex_prison_exit_lines", "img": "obj_prison_exit",
			 "frac": Vector2(0.50, 0.80), "wsize": Vector2(120, 60), "color": Color8(90, 90, 100), "exit": true}]}},
		{"t": "line", "who": "narrator", "key": "t3_try"},
		{"t": "line", "who": "narrator", "key": "t3_tired"},
		{"t": "bg", "color": Color8(10, 10, 10), "desc": "desc_3years", "img": "bg_prison"},
		{"t": "line", "who": "narrator", "key": "t3_3years"},
		{"t": "line", "who": "narrator", "key": "t3_blame_narr"},
		{"t": "line", "who": "hero", "key": "t3_blame", "expr": "hero_normal_angry"},
		{"t": "choice", "who": "heroine", "prompt": "t3_blame_prompt", "options": [
			{"key": "t3_b1", "gauge": 2, "reply": "t3_b1r"},
			{"key": "t3_b2", "gauge": -1, "reply": "t3_b2r"},
			{"key": "t3_b3", "gauge": -4, "reply": "t3_b3r"}]},
		{"t": "line", "who": "heroine", "key": "t3_5months"},
		{"t": "line", "who": "heroine", "key": "t3_5months2"},
		{"t": "line", "who": "narrator", "key": "t3_left"},

		{"t": "bg", "color": Color8(99, 110, 114), "desc": "desc_release"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "t3_release"},
		{"t": "line", "who": "narrator", "key": "t3_relief"},
		{"t": "line", "who": "narrator", "key": "t3_dating"},
		{"t": "line", "who": "narrator", "key": "t3_debauch"},
		{"t": "line", "who": "narrator", "key": "t3_meet"},
		{"t": "line", "who": "hero", "key": "t3_cheat", "expr": "hero_normal_angry"},
		{"t": "line", "who": "heroine", "key": "t3_youtoo2"},
		{"t": "line", "who": "hero", "key": "t3_hero_diff", "expr": "hero_normal_angry"},
		{"t": "bg", "color": Color8(74, 0, 0), "desc": "desc_lot", "img": "bg_empty_lot"},
		{"t": "shake"},
		{"t": "line", "who": "narrator", "key": "t3_lot"},
		{"t": "explore", "data": {"goal": "ex_lot_goal", "objects": [
			{"name": "ex_lot_equip_name", "lines": "ex_lot_equip_lines", "img": "obj_lot_equipment",
			 "frac": Vector2(0.24, 0.42), "wsize": Vector2(110, 100), "color": Color8(120, 90, 60), "clue": true},
			{"name": "ex_lot_alley_name", "lines": "ex_lot_alley_lines", "img": "obj_lot_alley",
			 "frac": Vector2(0.78, 0.36), "wsize": Vector2(110, 100), "color": Color8(40, 40, 50), "clue": true},
			{"name": "ex_lot_talk_name", "lines": "ex_lot_talk_lines", "img": "obj_lot_talk",
			 "frac": Vector2(0.50, 0.74), "wsize": Vector2(120, 60), "color": Color8(90, 60, 60), "exit": true}]}},
		{"t": "line", "who": "hero", "key": "t3_restart", "expr": "hero_normal_calm"},
		{"t": "line", "who": "narrator", "key": "t3_waver"},
		{"t": "line", "who": "hero", "key": "t3_burst", "expr": "hero_normal_angry"},
		{"t": "shake"},
		{"t": "line", "who": "narrator", "key": "t3_flee"},
		{"t": "flash"},
		{"t": "bg", "color": Color8(0, 0, 0), "desc": ""},
		{"t": "line", "who": "narrator", "key": "t3_hit", "cg": "cg_death"},
		{"t": "line", "who": "narrator", "key": "t3_die"},

		# ═══ 결과 ═══
		{"t": "line", "who": "system", "key": "res_sys_end"},
		{"t": "bg", "color": Color8(255, 236, 210), "desc": "", "img": "bg_result"},
		{"t": "fade"},
		{"t": "line", "who": "narrator", "key": "res_wake"},
		{"t": "score"},

		# ═══ 에필로그 (게이지로 분기) ═══
		{"t": "ending"},
	]
