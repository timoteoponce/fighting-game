class_name TitleScreen
extends Node2D

const ITEMS := ["VS PLAYER", "VS CPU", "OPTIONS", "HOW TO PLAY", "CONTROLLER SETUP", "QUIT"]
const MENU_AT := Vector2(320, 150)
const MENU_SIZE := 17
const MENU_SPACING := 28

var idx := 0
var t := 0.0
var _left := false
var chibis: Array[FighterRenderer] = []


func _ready() -> void:
	# Live FighterRenderers, the same ones a match draws, so the title screen and
	# the fight are the same art. They animate, which a portrait cannot.
	for i in 2:
		var r := FighterRenderer.new()
		r.setup(GameState.make_character(GameState.CHARACTERS[i]))
		r.base_scale = 1.75 * r.def.size
		r.facing = 1 if i == 0 else -1
		r.position = Vector2(105 if i == 0 else 535, 318)
		add_child(r)
		chibis.append(r)
	# VS CPU is the match one person can finish. VS PLAYER stays in the list
	# for a second gamepad.
	if Controls.phone:
		idx = 1


## QUIT closes a desktop window. A page has nothing to close.
func _items() -> Array:
	if not Controls.phone:
		return ITEMS
	var items: Array = ITEMS.duplicate()
	items.erase("QUIT")
	return items


func _process(delta: float) -> void:
	t += delta
	for i in chibis.size():
		var r := chibis[i]
		r.t = t * 60.0
		var intro := int(t * 0.4 + i * 0.5) % 2 == 0
		r.prop = r.def.intro_prop if intro else ""
		r.update_pose(r.def.pose("intro" if intro else "idle", {"lean": 6 + sin(t * 3.0 + i) * 3.0}), 0.1)
	var items := _items()
	if not _left:
		if Controls.any_just_pressed(Controls.UP) != Controls.NONE:
			idx = posmod(idx - 1, items.size())
			Sfx.play("select")
		if Controls.any_just_pressed(Controls.DOWN) != Controls.NONE:
			idx = posmod(idx + 1, items.size())
			Sfx.play("select")
		if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
			_confirm(items)
	queue_redraw()


## A finger on the words. The pad still moves the highlight; this is for the
## tap on "VS CPU" itself, which is nowhere near the pad.
func _input(event: InputEvent) -> void:
	if _left:
		return
	var at := _press_at(event)
	if at.x < 0.0:
		return
	var items := _items()
	var hit := UI.menu_index_at(items, at, MENU_AT, MENU_SIZE, MENU_SPACING)
	if hit < 0:
		return
	idx = hit
	_confirm(items)
	get_viewport().set_input_as_handled()


func _press_at(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		var tap := event as InputEventScreenTouch
		if tap.pressed:
			return tap.position
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			return click.position
	return Vector2(-1, -1)


func _confirm(items: Array) -> void:
	_left = true
	Sfx.play("confirm")
	match items[idx]:
		"VS PLAYER":
			GameState.mode = "vs"
			GameState.goto("select")
		"VS CPU":
			GameState.mode = "cpu"
			GameState.goto("select")
		"OPTIONS":
			GameState.options_return = "title"
			GameState.goto("options")
		"HOW TO PLAY":
			GameState.goto("howto")
		"CONTROLLER SETUP":
			GameState.goto("setup")
		"QUIT":
			get_tree().quit()


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("2a1660"), Color("ff6fa8"))
	var c := Vector2(320, 150)
	for i in 24:
		var a := TAU * i / 24.0 + t * 0.15
		var p1 := c + Vector2(cos(a), sin(a)) * 60.0
		var p2 := c + Vector2(cos(a + 0.12), sin(a + 0.12)) * 500.0
		var p3 := c + Vector2(cos(a - 0.12), sin(a - 0.12)) * 500.0
		if i % 2 == 0:
			draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color(1, 1, 1, 0.06))
	var bob := sin(t * 2.5) * 3.0
	UI.text(self, Vector2(210, 64 + bob), "ULISES", 44, Color("5ab0ff"), HORIZONTAL_ALIGNMENT_CENTER, 10, Color("0b1a4a"))
	UI.text(self, Vector2(320, 70 - bob), "VS", 34, Color("ffd23f"), HORIZONTAL_ALIGNMENT_CENTER, 10, Color("7a1030"))
	UI.text(self, Vector2(430, 64 + bob), "EMILIA", 44, Color("d19bff"), HORIZONTAL_ALIGNMENT_CENTER, 10, Color("3a0d5a"))
	UI.text(self, Vector2(320, 96), "PJ's CLASH", 14, Color.WHITE)
	UI.menu(self, _items(), idx, MENU_AT, MENU_SIZE, MENU_SPACING)
	var hint := "P1: WASD + F / G     P2: Arrows + K / L     Gamepads: D-pad + buttons     F11: fullscreen"
	if Controls.phone:
		hint = "TAP A ROW     or PAD + L     A second player needs a gamepad"
	UI.text(self, Vector2(320, 350), hint, 10, Color(1, 1, 1, 0.8))
	UI.text(self, Vector2(10, 350), "v" + ProjectSettings.get_setting("application/config/version"), 10, Color(1, 1, 1, 0.5), HORIZONTAL_ALIGNMENT_LEFT, 2)
