class_name ControllerSetup
extends Node2D
## Remap any gamepad (especially generic PS2-to-USB adapters that the OS
## doesn't recognize). Shows raw buttons/axes, then asks for each action.

const STEPS := ["up", "down", "left", "right", "light", "heavy", "start"]
const STEP_NAMES := {
	"up": "UP", "down": "DOWN", "left": "LEFT", "right": "RIGHT",
	"light": "LIGHT ATTACK (e.g. Square)", "heavy": "HEAVY ATTACK (e.g. Triangle)", "start": "START",
}
const MAX_BUTTONS := 32
const MAX_AXES := 8

var mode := "list"  # list, map, test
var dev := -1
var step := 0
var mapping := {}
var baseline := {}
var waiting_release := true
var raw_prev := {}
var msg := ""
var t := 0.0


func _process(delta: float) -> void:
	t += delta
	match mode:
		"list":
			_list_input()
		"map":
			_map_input()
		"test":
			if Controls.just_pressed(dev, Controls.START):
				Sfx.play("confirm")
				mode = "list"
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match (event as InputEventKey).keycode:
		KEY_ESCAPE, KEY_BACKSPACE:
			if mode == "list":
				GameState.goto("title")
			else:
				mode = "list"
				msg = "Cancelled."
		KEY_R:
			if mode == "test":
				Controls.clear_custom(dev)
				msg = "Reset to the default mapping."
				mode = "list"


func _list_input() -> void:
	for pad in Input.get_connected_joypads():
		var pressed := _raw_buttons(pad)
		var prev: Array = raw_prev.get(pad, [])
		raw_prev[pad] = pressed
		var fresh := pressed.filter(func(b: int) -> bool: return not prev.has(b))
		if fresh.is_empty():
			continue
		if Controls.just_pressed(pad, Controls.START):
			GameState.goto("title")
			return
		_begin_mapping(pad)
		return


func _begin_mapping(pad: int) -> void:
	dev = pad
	mode = "map"
	step = 0
	mapping = {}
	msg = ""
	waiting_release = true
	baseline = {}
	for a in MAX_AXES:
		baseline[a] = Input.get_joy_axis(pad, a)
	Sfx.play("confirm")


func _map_input() -> void:
	if not Input.get_connected_joypads().has(dev):
		mode = "list"
		msg = "Controller disconnected."
		return
	if waiting_release:
		if _all_released():
			waiting_release = false
		return
	var b := _detect()
	if b.is_empty():
		return
	mapping[STEPS[step]] = [b]
	Sfx.play("select")
	step += 1
	waiting_release = true
	if step >= STEPS.size():
		Controls.set_custom(dev, mapping)
		Sfx.play("confirm")
		mode = "test"


func _raw_buttons(pad: int) -> Array:
	var out := []
	for b in MAX_BUTTONS:
		if Input.is_joy_button_pressed(pad, b):
			out.append(b)
	return out


func _detect() -> Dictionary:
	for b in MAX_BUTTONS:
		if Input.is_joy_button_pressed(dev, b):
			return Controls.btn(b)
	for a in MAX_AXES:
		var d := Input.get_joy_axis(dev, a) - float(baseline.get(a, 0.0))
		if absf(d) > 0.6:
			return Controls.axis(a, 1 if d > 0 else -1)
	return {}


func _all_released() -> bool:
	if not _raw_buttons(dev).is_empty():
		return false
	for a in MAX_AXES:
		if absf(Input.get_joy_axis(dev, a) - float(baseline.get(a, 0.0))) > 0.3:
			return false
	return true


func _raw_text(pad: int) -> String:
	var s := "Buttons:"
	var btns := _raw_buttons(pad)
	if btns.is_empty():
		s += " -"
	for b in btns:
		s += " %d" % b
	s += "    Axes:"
	for a in 6:
		s += "  %d:%+.1f" % [a, Input.get_joy_axis(pad, a)]
	return s


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("0f2a3a"), Color("1f5a6a"))
	UI.text(self, Vector2(320, 32), "CONTROLLER SETUP", 24, Color(1, 0.9, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.05, 0.1, 0.2))
	match mode:
		"list":
			_draw_list()
		"map":
			_draw_map()
		"test":
			_draw_test()
	if msg != "":
		UI.text(self, Vector2(320, 330), msg, 12, Color(0.6, 1, 0.6))


func _draw_list() -> void:
	var pads := Input.get_connected_joypads()
	UI.text(self, Vector2(320, 58), "Press any button on a controller to set it up.", 13, Color.WHITE)
	UI.text(self, Vector2(320, 74), "START on a working controller, or ESC on the keyboard, goes back.", 11, Color(1, 1, 1, 0.8))
	if pads.is_empty():
		UI.text(self, Vector2(320, 150), "No controllers found. Plug in your USB adapter!", 15, Color(1, 0.7, 0.5))
	var y := 104.0
	for pad in pads:
		var status := "recognized" if Input.is_joy_known(pad) else "unknown - please set it up"
		if Controls.has_custom(pad):
			status = "custom mapping saved"
		UI.text(self, Vector2(30, y), "%s   (%s)" % [Controls.device_name(pad), status], 12, Color(1, 0.95, 0.6), HORIZONTAL_ALIGNMENT_LEFT, 3)
		UI.text(self, Vector2(46, y + 15), _raw_text(pad), 10, Color(0.8, 0.95, 1), HORIZONTAL_ALIGNMENT_LEFT, 3)
		y += 38.0
	UI.text(self, Vector2(320, 296), "Keyboards always work:  P1 = W A S D + F / G (Esc = start)", 11, Color(1, 1, 1, 0.75))
	UI.text(self, Vector2(320, 311), "P2 = Arrows + K / L (Enter = start)", 11, Color(1, 1, 1, 0.75))


func _draw_map() -> void:
	UI.text(self, Vector2(320, 62), Controls.device_name(dev), 12, Color(1, 1, 1, 0.8))
	if step < STEPS.size():
		var prompt := "Let go of everything..." if waiting_release else "Press  %s" % STEP_NAMES[STEPS[step]]
		UI.text(self, Vector2(320, 110), prompt, 24, Color(1, 0.9, 0.3) if int(t * 3.0) % 2 == 0 or waiting_release else Color.WHITE)
	for i in STEPS.size():
		var action: String = STEPS[i]
		var done := mapping.has(action)
		var txt := "%s:  %s" % [action.to_upper(), Controls.binding_text(mapping[action][0]) if done else ("..." if i == step else "")]
		UI.text(self, Vector2(250, 150 + i * 18), txt, 12, Color(0.6, 1, 0.6) if done else Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 3)
	UI.text(self, Vector2(320, 300), _raw_text(dev), 10, Color(0.8, 0.95, 1))
	UI.text(self, Vector2(320, 316), "ESC = cancel", 10, Color(1, 1, 1, 0.7))


func _draw_test() -> void:
	UI.text(self, Vector2(320, 70), "Saved! Try your buttons:", 16, Color(0.6, 1, 0.6))
	var m := Controls.read(dev)
	var boxes := [
		["UP", Controls.UP, Vector2(150, 130)], ["DOWN", Controls.DOWN, Vector2(150, 200)],
		["LEFT", Controls.LEFT, Vector2(95, 165)], ["RIGHT", Controls.RIGHT, Vector2(205, 165)],
		["L", Controls.LIGHT, Vector2(420, 165)], ["H", Controls.HEAVY, Vector2(490, 145)], ["START", Controls.START, Vector2(320, 220)],
	]
	for b in boxes:
		var on: bool = m & int(b[1]) != 0
		var c: Vector2 = b[2]
		draw_rect(Rect2(c - Vector2(26, 16), Vector2(52, 32)), Color(1, 0.8, 0.2) if on else Color(0.1, 0.15, 0.2))
		draw_rect(Rect2(c - Vector2(26, 16), Vector2(52, 32)), Color.WHITE, false, 2.0)
		UI.text(self, c + Vector2(0, 5), b[0], 12, Color.BLACK if on else Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 0)
	UI.text(self, Vector2(320, 270), "START = done     R = reset to default     ESC = back", 12, Color.WHITE)
