class_name CharSelect
extends Node2D
## Players join with their own controller, pick a fighter, then fight.
## Arcade: player 1 picks once and starts the run; the CPU fighter is the ladder.

var slots := [
	{"dev": Controls.NONE, "char": 0, "ready": false},
	{"dev": Controls.NONE, "char": 1, "ready": false},
]
var cpu_step := 0  # 0 = P1 picks, 1 = picks CPU fighter, 2 = difficulty
var start_timer := -1.0
var t := 0.0
## A column tap held for one poll, then released so it stays a press.
var _pulse := 0
var chibis: Array[FighterRenderer] = []


func _ready() -> void:
	for i in 2:
		var r := FighterRenderer.new()
		r.base_scale = 1.35
		r.facing = 1 if i == 0 else -1
		r.position = Vector2(245 if i == 0 else 395, 305)
		add_child(r)
		chibis.append(r)
	_refresh_chibis()
	# The phone is already holding a controller. Waiting for "press L to join"
	# made the arrows do nothing, which is the whole screen.
	_ensure_touch_player()


func _cpu() -> bool:
	return GameState.mode == "cpu"


func _arcade() -> bool:
	return GameState.mode == "arcade"


func _refresh_chibis() -> void:
	for i in 2:
		var id: String = GameState.CHARACTERS[slots[i]["char"]]
		chibis[i].setup(GameState.make_character(id), i == 1 and slots[0]["char"] == slots[1]["char"])
		chibis[i].base_scale = 1.35 * chibis[i].def.size
	# Arcade is a solo run: hide the opponent chibi, so the right side is the
	# ladder rather than a fighter the player never picked.
	chibis[1].visible = not _arcade()


func _process(delta: float) -> void:
	t += delta
	if start_timer >= 0.0:
		start_timer -= delta
		if start_timer < 0.0:
			_start_fight()
	else:
		_handle_input()
	if _pulse != 0:
		Controls.set_touch(Controls.touch_mask & ~_pulse)
		_pulse = 0
	for i in 2:
		var r := chibis[i]
		r.t = t * 60.0
		var ready: bool = slots[i]["ready"] or (_cpu() and i == 1 and cpu_step >= 2)
		r.prop = r.def.win_prop if ready else ""
		r.expr = "happy" if ready else "normal"
		r.update_pose(r.def.pose("intro" if ready else "idle", {"lean": 6 + sin(t * 3.0 + i) * 2.0}), 0.15)
	queue_redraw()


func _handle_input() -> void:
	# Join.
	for dev in Controls.devices():
		if _slot_of(dev) >= 0:
			continue
		if Controls.just_pressed(dev, Controls.LIGHT | Controls.START):
			for i in (1 if (_cpu() or _arcade()) else 2):
				if slots[i]["dev"] == Controls.NONE:
					slots[i]["dev"] = dev
					Sfx.play("confirm")
					return
		if Controls.just_pressed(dev, Controls.HEAVY) and slots[0]["dev"] == Controls.NONE and slots[1]["dev"] == Controls.NONE:
			GameState.goto("title")
			return
	if _arcade():
		_handle_arcade_mode()
		return
	if _cpu():
		_handle_cpu_mode()
		return
	for i in 2:
		var s: Dictionary = slots[i]
		var dev: int = s["dev"]
		if dev == Controls.NONE:
			continue
		if not s["ready"]:
			_change_char(i, dev)
			if Controls.just_pressed(dev, Controls.LIGHT | Controls.START):
				s["ready"] = true
				Sfx.play("confirm")
			elif Controls.just_pressed(dev, Controls.HEAVY):
				if dev == Controls.TOUCH:
					GameState.goto("title")
				else:
					s["dev"] = Controls.NONE
					Sfx.play("select")
		elif Controls.just_pressed(dev, Controls.HEAVY):
			s["ready"] = false
			Sfx.play("select")
	if slots[0]["ready"] and slots[1]["ready"]:
		start_timer = 0.8


## Arcade: one player, one pick. The rest of the roster becomes the ladder, so
## there is no CPU fighter to choose and no difficulty step.
func _handle_arcade_mode() -> void:
	var dev: int = slots[0]["dev"]
	if dev == Controls.NONE:
		return
	_change_char(0, dev)
	if Controls.just_pressed(dev, Controls.LIGHT | Controls.START):
		slots[0]["ready"] = true
		Sfx.play("confirm")
		start_timer = 0.8
	elif Controls.just_pressed(dev, Controls.HEAVY):
		slots[0]["dev"] = Controls.NONE
		Sfx.play("select")


func _handle_cpu_mode() -> void:
	var dev: int = slots[0]["dev"]
	if dev == Controls.NONE:
		return
	var ok := Controls.just_pressed(dev, Controls.LIGHT | Controls.START)
	var back := Controls.just_pressed(dev, Controls.HEAVY)
	match cpu_step:
		0:
			_change_char(0, dev)
			if ok:
				slots[0]["ready"] = true
				cpu_step = 1
			elif back:
				if dev == Controls.TOUCH:
					GameState.goto("title")
				else:
					slots[0]["dev"] = Controls.NONE
		1:
			_change_char(1, dev)
			if ok:
				cpu_step = 2
			elif back:
				slots[0]["ready"] = false
				cpu_step = 0
		2:
			if Controls.just_pressed(dev, Controls.LEFT):
				GameState.cpu_level = posmod(GameState.cpu_level - 1, GameState.CPU_LEVELS.size())
				Sfx.play("select")
			if Controls.just_pressed(dev, Controls.RIGHT):
				GameState.cpu_level = posmod(GameState.cpu_level + 1, GameState.CPU_LEVELS.size())
				Sfx.play("select")
			if ok:
				start_timer = 0.8
			elif back:
				cpu_step = 1
	if ok or back:
		Sfx.play("confirm" if ok else "select")


func _change_char(i: int, dev: int) -> void:
	var n := GameState.CHARACTERS.size()
	var d := 0
	if Controls.just_pressed(dev, Controls.LEFT) or Controls.just_pressed(dev, Controls.UP):
		d = -1
	elif Controls.just_pressed(dev, Controls.RIGHT) or Controls.just_pressed(dev, Controls.DOWN):
		d = 1
	if d != 0:
		slots[i]["char"] = posmod(slots[i]["char"] + d, n)
		Sfx.play("select")
		_refresh_chibis()


## The phone player is slot 0. A gamepad can still take the empty seat.
func _ensure_touch_player() -> void:
	if Controls.phone and slots[0]["dev"] == Controls.NONE:
		slots[0]["dev"] = Controls.TOUCH


## Which side the buttons are choosing right now. -1 when nobody is picking.
func _active_column() -> int:
	if _cpu():
		return 0 if cpu_step == 0 else 1
	if slots[0]["dev"] == Controls.TOUCH and not slots[0]["ready"]:
		return 0
	return -1


## Bit a tap on the active name stands for. Left of the name is the previous
## fighter, right is the next, the name itself confirms. The pad and L sit
## below this band, so a thumb on a button is not also a tap on the picture.
func column_bit(point: Vector2) -> int:
	var col := _active_column()
	if col < 0:
		return 0
	var cx := 150.0 if col == 0 else 490.0
	var row := Rect2(cx - 140.0, 62.0, 280.0, 80.0)
	if not row.has_point(point):
		return 0
	var rel := point.x - cx
	if rel < -40.0:
		return Controls.LEFT
	if rel > 40.0:
		return Controls.RIGHT
	return Controls.LIGHT


## A tap on the name is the same press as the glass button, held for one poll.
func _input(event: InputEvent) -> void:
	if start_timer >= 0.0:
		return
	var at := _press_point(event)
	if at.x < 0.0:
		return
	_ensure_touch_player()
	var bit := column_bit(at)
	if bit == 0:
		return
	_pulse = bit
	Controls.set_touch(Controls.touch_mask | bit)
	get_viewport().set_input_as_handled()


func _press_point(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		var tap := event as InputEventScreenTouch
		if tap.pressed:
			Controls.adopt_touch()
			return tap.position
	elif Controls.phone and event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			return click.position
	return Vector2(-1, -1)


func _slot_of(dev: int) -> int:
	for i in 2:
		if slots[i]["dev"] == dev:
			return i
	return -1


func _start_fight() -> void:
	GameState.devices = [slots[0]["dev"], slots[1]["dev"]]
	if _arcade():
		GameState.start_arcade(GameState.CHARACTERS[slots[0]["char"]])
		GameState.goto("arcade")
		return
	GameState.chars = [GameState.CHARACTERS[slots[0]["char"]], GameState.CHARACTERS[slots[1]["char"]]]
	GameState.goto("fight")


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 320, 360), Color("12306e"), Color("3b7be0"))
	UI.gradient_rect(self, Rect2(320, 0, 320, 360), Color("3a1261"), Color("a45be0"))
	draw_colored_polygon(PackedVector2Array([Vector2(300, 0), Vector2(340, 0), Vector2(340, 360), Vector2(300, 360)]), Color(0, 0, 0, 0.25))
	UI.text(self, Vector2(320, 30), "SELECT YOUR FIGHTER", 24, Color(1, 0.9, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.5, 0.05, 0.2))
	if _arcade():
		UI.text(self, Vector2(320, 200), "ARCADE", 40, Color(1, 0.85, 0.2), HORIZONTAL_ALIGNMENT_CENTER, 10, Color(0.6, 0.05, 0.2))
	else:
		UI.text(self, Vector2(320, 200), "VS", 40, Color(1, 0.85, 0.2), HORIZONTAL_ALIGNMENT_CENTER, 10, Color(0.6, 0.05, 0.2))
	for i in 2:
		_draw_slot(i)
	if start_timer >= 0.0:
		UI.text(self, Vector2(320, 250), "GET READY!", 22, Color.WHITE)
	var hint := "LEFT / RIGHT: choose     L: confirm     H: back"
	if Controls.phone:
		hint = "ARROWS or tap the name     L: confirm     H: back"
	UI.text(self, Vector2(320, 352), hint, 11, Color(1, 1, 1, 0.8))


func _draw_slot(i: int) -> void:
	if _arcade() and i == 1:
		_draw_arcade_panel()
		return
	var s: Dictionary = slots[i]
	var cx := 150.0 if i == 0 else 490.0
	var def := chibis[i].def
	var is_cpu := _cpu() and i == 1
	var label := "PLAYER %d" % (i + 1) if not is_cpu else "CPU"
	UI.text(self, Vector2(cx, 60), label, 16, Color(1, 1, 1, 0.9))
	var choosing: bool = (not s["ready"] and s["dev"] != Controls.NONE and not is_cpu) or (is_cpu and cpu_step == 1)
	var name_text: String = ("<  %s  >" % def.display) if choosing else def.display
	UI.text(self, Vector2(cx, 90), name_text, 26, Color(1, 0.95, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.1, 0.05, 0.2))
	UI.text(self, Vector2(cx, 108), "Likes: " + def.likes, 10, Color(1, 1, 1, 0.9))
	# With more than two fighters, say how far through the roster you are —
	# otherwise cycling through names feels endless.
	if GameState.CHARACTERS.size() > 2:
		UI.text(self, Vector2(cx, 120), "%d / %d" % [int(s["char"]) + 1, GameState.CHARACTERS.size()], 9, Color(1, 1, 1, 0.55))
	var status := ""
	var col := Color.WHITE
	if is_cpu:
		if cpu_step < 1:
			status = "waiting for player 1..."
		elif cpu_step == 1:
			status = "Player 1: pick the CPU fighter"
		else:
			status = "Difficulty:  <  %s  >" % GameState.CPU_LEVELS[GameState.cpu_level]
			col = Color(1, 0.85, 0.3)
	elif s["dev"] == Controls.NONE:
		if Controls.phone and i == 1:
			status = "PLUG IN A GAMEPAD"
		else:
			status = "PRESS  L  TO JOIN" if int(t * 2.0) % 2 == 0 else ""
		col = Color(1, 0.9, 0.3)
	elif s["ready"]:
		status = "READY!"
		col = Color(0.5, 1, 0.5)
	if status != "":
		UI.text(self, Vector2(cx, 128), status, 14, col)
	UI.text(self, Vector2(14.0 if i == 0 else 626.0, 252), "(HYPER needs a full meter)", 9, Color(1, 1, 1, 0.6), HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 3)
	if s["dev"] != Controls.NONE and not is_cpu:
		UI.text(self, Vector2(cx, 322), Controls.device_name(s["dev"]), 10, Color(1, 1, 1, 0.8))
	UI.text(self, Vector2(14.0 if i == 0 else 626.0, 136), "SPECIAL MOVES", 10, Color(1, 0.8, 0.95), HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 3)
	for j in def.specials_text.size():
		var row: Array = def.specials_text[j]
		var y := 152.0 + j * 15.0
		var x := 14.0 if i == 0 else 626.0
		UI.text(self, Vector2(x, y), "%s: %s" % [row[0], row[1]], 10, Color(1, 1, 1, 0.85), HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 3)


## The right side of the arcade select screen: the run's ladder, previewed from
## the fighter currently highlighted. The boss is a "???" — that is the point.
func _draw_arcade_panel() -> void:
	var cx := 490.0
	var pick: String = GameState.CHARACTERS[slots[0]["char"]]
	UI.text(self, Vector2(cx, 60), "ARCADE", 16, Color(1, 1, 1, 0.9))
	UI.text(self, Vector2(cx, 90), "THE LADDER", 26, Color(1, 0.95, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.1, 0.05, 0.2))
	UI.text(self, Vector2(cx, 112), "Beat the whole roster...", 10, Color(1, 1, 1, 0.9))
	UI.text(self, Vector2(cx, 128), "...then someone is waiting.", 10, Color(1, 0.8, 0.95))
	var names: Array[String] = []
	for id in GameState.CHARACTERS:
		if id != pick:
			names.append(GameState.make_character(id).display)
	UI.text(self, Vector2(cx, 158), "OPPONENTS", 10, Color(1, 0.8, 0.95), HORIZONTAL_ALIGNMENT_CENTER, 3)
	for j in names.size():
		UI.text(self, Vector2(cx, 176 + j * 16), names[j], 12, Color(1, 1, 1, 0.85))
	var last_y := 176 + names.size() * 16 + 6
	UI.text(self, Vector2(cx, last_y), "???", 16, Color(1, 0.4, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 4, Color(0.3, 0.0, 0.1))
