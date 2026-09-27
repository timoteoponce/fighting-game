extends Node
## Reads every input device as a small bitmask, one device at a time.
##
## Device ids: KB1 (-1) and KB2 (-2) are the two keyboard layouts, joypads use
## their Godot device id (0, 1, 2...). Joypad button mappings are stored per
## controller GUID so generic PS2 USB adapters can be remapped once and remembered.

const UP := 1
const DOWN := 2
const LEFT := 4
const RIGHT := 8
const LIGHT := 16
const HEAVY := 32
const START := 64

const KB1 := -1
const KB2 := -2
const NONE := -99

const ACTIONS := ["up", "down", "left", "right", "light", "heavy", "start"]
const ACTION_BITS := {
	"up": UP, "down": DOWN, "left": LEFT, "right": RIGHT,
	"light": LIGHT, "heavy": HEAVY, "start": START,
}

const KEYS := {
	KB1: {
		"up": [KEY_W], "down": [KEY_S], "left": [KEY_A], "right": [KEY_D],
		"light": [KEY_F], "heavy": [KEY_G], "start": [KEY_ESCAPE, KEY_1],
	},
	KB2: {
		"up": [KEY_UP], "down": [KEY_DOWN], "left": [KEY_LEFT], "right": [KEY_RIGHT],
		"light": [KEY_K], "heavy": [KEY_L], "start": [KEY_ENTER, KEY_BACKSPACE],
	},
}

const SAVE_PATH := "user://controls.cfg"
const AXIS_THRESHOLD := 0.5

var _custom := {}  # guid -> mapping
var _prev := {}  # device -> mask (for menu edge detection)
var _just := {}  # device -> mask pressed this frame


func _ready() -> void:
	_load()


func _process(_delta: float) -> void:
	for dev in devices():
		var cur := read(dev)
		var prev: int = _prev.get(dev, 0)
		_just[dev] = cur & ~prev
		_prev[dev] = cur


func devices() -> Array:
	var list: Array = [KB1, KB2]
	list.append_array(Input.get_connected_joypads())
	return list


func device_name(dev: int) -> String:
	if dev == KB1:
		return "Keyboard (WASD + F/G)"
	if dev == KB2:
		return "Keyboard (Arrows + K/L)"
	if dev == NONE:
		return "-"
	return "Pad %d: %s" % [dev + 1, Input.get_joy_name(dev)]


## Current held mask for a device.
func read(dev: int) -> int:
	var m := 0
	if dev < 0:
		if not KEYS.has(dev):
			return 0
		var keys: Dictionary = KEYS[dev]
		for action in ACTIONS:
			for k in keys[action]:
				if Input.is_physical_key_pressed(k):
					m |= ACTION_BITS[action]
					break
	else:
		var mapping := get_mapping(dev)
		for action in ACTIONS:
			for b in mapping.get(action, []):
				if binding_active(dev, b):
					m |= ACTION_BITS[action]
					break
	if m & LEFT and m & RIGHT:
		m &= ~(LEFT | RIGHT)
	if m & UP and m & DOWN:
		m &= ~(UP | DOWN)
	return m


func just_pressed(dev: int, bit: int) -> bool:
	return int(_just.get(dev, 0)) & bit != 0


## Returns the first device that pressed `bit` this frame, or NONE.
func any_just_pressed(bit: int) -> int:
	for dev in devices():
		if just_pressed(dev, bit):
			return dev
	return NONE


# --- Joypad mappings -------------------------------------------------------

static func btn(i: int) -> Dictionary:
	return {"t": "b", "i": i}


static func axis(i: int, s: int) -> Dictionary:
	return {"t": "a", "i": i, "s": s}


func default_mapping() -> Dictionary:
	# SDL "standard" layout. On a PlayStation pad: Square/Cross = LIGHT,
	# Triangle/Circle = HEAVY. Unknown adapters get fixed in Controller Setup.
	return {
		"up": [btn(JOY_BUTTON_DPAD_UP), axis(JOY_AXIS_LEFT_Y, -1)],
		"down": [btn(JOY_BUTTON_DPAD_DOWN), axis(JOY_AXIS_LEFT_Y, 1)],
		"left": [btn(JOY_BUTTON_DPAD_LEFT), axis(JOY_AXIS_LEFT_X, -1)],
		"right": [btn(JOY_BUTTON_DPAD_RIGHT), axis(JOY_AXIS_LEFT_X, 1)],
		"light": [btn(JOY_BUTTON_X), btn(JOY_BUTTON_A)],
		"heavy": [btn(JOY_BUTTON_Y), btn(JOY_BUTTON_B)],
		"start": [btn(JOY_BUTTON_START)],
	}


func get_mapping(dev: int) -> Dictionary:
	var guid := Input.get_joy_guid(dev)
	if _custom.has(guid):
		return _custom[guid]
	return default_mapping()


func has_custom(dev: int) -> bool:
	return _custom.has(Input.get_joy_guid(dev))


func set_custom(dev: int, mapping: Dictionary) -> void:
	_custom[Input.get_joy_guid(dev)] = mapping
	_save()


func clear_custom(dev: int) -> void:
	_custom.erase(Input.get_joy_guid(dev))
	_save()


func binding_active(dev: int, b: Dictionary) -> bool:
	if b.get("t") == "b":
		return Input.is_joy_button_pressed(dev, int(b["i"]))
	var v := Input.get_joy_axis(dev, int(b["i"]))
	return v * float(b["s"]) > AXIS_THRESHOLD


static func binding_text(b: Dictionary) -> String:
	if b.get("t") == "b":
		return "Button %d" % int(b["i"])
	return "Axis %d %s" % [int(b["i"]), "+" if int(b["s"]) > 0 else "-"]


func _save() -> void:
	var cfg := ConfigFile.new()
	for guid in _custom:
		cfg.set_value("pads", guid, _custom[guid])
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK or not cfg.has_section("pads"):
		return
	for guid in cfg.get_section_keys("pads"):
		var mapping = cfg.get_value("pads", guid)
		if mapping is Dictionary:
			_custom[guid] = mapping
