class_name TitleScreen
extends Node2D

const ITEMS := ["VS PLAYER", "VS CPU", "HOW TO PLAY", "CONTROLLER SETUP", "QUIT"]

var idx := 0
var t := 0.0
var chibis: Array[FighterRenderer] = []


func _ready() -> void:
	for i in 2:
		var r := FighterRenderer.new()
		r.setup(GameState.make_character(GameState.CHARACTERS[i]))
		r.base_scale = 1.75
		r.facing = 1 if i == 0 else -1
		r.position = Vector2(105 if i == 0 else 535, 318)
		add_child(r)
		chibis.append(r)


func _process(delta: float) -> void:
	t += delta
	for i in chibis.size():
		var r := chibis[i]
		r.t = t * 60.0
		var intro := int(t * 0.4 + i * 0.5) % 2 == 0
		r.prop = r.def.intro_prop if intro else ""
		r.update_pose(r.def.pose("intro" if intro else "idle", {"lean": 6 + sin(t * 3.0 + i) * 3.0}), 0.1)
	if Controls.any_just_pressed(Controls.UP) != Controls.NONE:
		idx = posmod(idx - 1, ITEMS.size())
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.DOWN) != Controls.NONE:
		idx = posmod(idx + 1, ITEMS.size())
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
		Sfx.play("confirm")
		match ITEMS[idx]:
			"VS PLAYER":
				GameState.mode = "vs"
				GameState.goto("select")
			"VS CPU":
				GameState.mode = "cpu"
				GameState.goto("select")
			"HOW TO PLAY":
				GameState.goto("howto")
			"CONTROLLER SETUP":
				GameState.goto("setup")
			"QUIT":
				get_tree().quit()
	queue_redraw()


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
	UI.text(self, Vector2(320, 96), "ULTIMATE FRIENDS SHOWDOWN", 14, Color.WHITE)
	UI.menu(self, ITEMS, idx, Vector2(320, 150), 17, 28)
	UI.text(self, Vector2(320, 350), "P1: WASD + F / G     P2: Arrows + K / L     Gamepads: D-pad + buttons     F11: fullscreen", 10, Color(1, 1, 1, 0.8))
