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
## On-screen pad. Only present while `phone` is true, so a computer's device
## list stays the two keyboards plus whatever gamepads are plugged in.
const TOUCH := -3
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
## Extra SDL mappings, if the player drops the community controller database
## next to the game. Lines are standard `gamecontrollerdb.txt` entries.
const SDL_DB_PATHS := ["user://gamecontrollerdb.txt", "res://gamecontrollerdb.txt"]
const AXIS_THRESHOLD := 0.5
const MAX_AXES := 10

## Emitted when a gamepad is plugged in or pulled out mid-game.
signal device_changed(dev: int, connected: bool)

var _custom := {}  # guid -> mapping
var _rest := {}  # guid -> {axis index: resting value}
var _prev := {}  # device -> mask (for menu edge detection)
var _just := {}  # device -> mask pressed this frame

## True on a phone or tablet browser: a coarse pointer and no hover. A desktop,
## including a laptop that also has a touchscreen, stays false and shows no pad.
var phone := false
## Bits the on-screen pad is holding this frame. `read(TOUCH)` is what menus
## and the fight actually see, after opposite directions cancel.
var touch_mask := 0
## Bits that went down since the last poll. A tap often presses and releases
## before `_process` samples the mask, and that press would otherwise vanish.
var _touch_edge := 0


func _ready() -> void:
	_load_sdl_db()
	_load()
	phone = _detect_phone()
	Input.joy_connection_changed.connect(_on_joy_changed)
	for dev in Input.get_connected_joypads():
		_ensure_rest(dev)


## The web export is the same build for a computer and a phone, so the engine's
## "mobile" feature is never set. The browser's primary pointer is the signal.
func _detect_phone() -> bool:
	if not OS.has_feature("web"):
		return false
	# A phone is a coarse pointer, or a touch screen whose short side is a phone
	# or a small tablet. `screen.width` ignores the browser window, so a laptop
	# with a touchscreen stays a computer. Numbers come back as floats.
	var hit: Variant = JavaScriptBridge.eval("(function(){var coarse=window.matchMedia('(pointer: coarse)').matches;var noHover=window.matchMedia('(hover: none)').matches;var touch=navigator.maxTouchPoints>0;var shortSide=Math.min(screen.width,screen.height);return (coarse&&noHover)||(touch&&shortSide<=820);})()")
	return hit == true or hit == 1 or hit == 1.0


## Cheap adapters often rest with a stick or an unused axis off centre, which
## without this reads as a direction held down forever. Sample each new pad
## once and treat that reading as its zero.
func _on_joy_changed(dev: int, connected: bool) -> void:
	if connected:
		_ensure_rest(dev)
	else:
		_prev.erase(dev)
		_just.erase(dev)
	device_changed.emit(dev, connected)


func _ensure_rest(dev: int) -> void:
	var guid := Input.get_joy_guid(dev)
	if _rest.has(guid):
		return
	var rest := {}
	for a in MAX_AXES:
		var v := Input.get_joy_axis(dev, a)
		if absf(v) > 0.15:
			rest[a] = v
	_rest[guid] = rest


## Replaces a pad's resting values, e.g. after Controller Setup measured them
## while the player was told to let go of everything.
func set_rest(dev: int, rest: Dictionary) -> void:
	_rest[Input.get_joy_guid(dev)] = rest.duplicate()
	_save()


func rest_of(dev: int) -> Dictionary:
	return _rest.get(Input.get_joy_guid(dev), {})


## Replace the held touch bits. A bit that was not held before is remembered
## until the next poll, so a same-frame tap still counts as a press.
func set_touch(mask: int) -> void:
	_touch_edge |= mask & ~touch_mask
	touch_mask = mask


func _process(_delta: float) -> void:
	for dev in devices():
		var cur := read(dev)
		var prev: int = _prev.get(dev, 0)
		_just[dev] = cur & ~prev
		_prev[dev] = cur
	_touch_edge = 0


func devices() -> Array:
	var list: Array = [KB1, KB2]
	if phone:
		list.append(TOUCH)
	list.append_array(Input.get_connected_joypads())
	return list


func device_name(dev: int) -> String:
	if dev == KB1:
		return "Keyboard (WASD + F/G)"
	if dev == KB2:
		return "Keyboard (Arrows + K/L)"
	if dev == TOUCH:
		return "Touch"
	if dev == NONE:
		return "-"
	return "Pad %d: %s" % [dev + 1, Input.get_joy_name(dev)]


## Current held mask for a device.
func read(dev: int) -> int:
	var m := 0
	if dev == TOUCH:
		m = touch_mask | _touch_edge
	elif dev < 0:
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


## SDL "standard" layout. On a PlayStation pad: Square/Cross = LIGHT,
## Triangle/Circle = HEAVY. Unrecognized adapters also get the axis 6/7
## fallback, which is where most of them report their D-pad — but only those,
## because on a recognized pad those axis numbers can mean something else.
func default_mapping(dev := -1) -> Dictionary:
	var m := {
		"up": [btn(JOY_BUTTON_DPAD_UP), axis(JOY_AXIS_LEFT_Y, -1)],
		"down": [btn(JOY_BUTTON_DPAD_DOWN), axis(JOY_AXIS_LEFT_Y, 1)],
		"left": [btn(JOY_BUTTON_DPAD_LEFT), axis(JOY_AXIS_LEFT_X, -1)],
		"right": [btn(JOY_BUTTON_DPAD_RIGHT), axis(JOY_AXIS_LEFT_X, 1)],
		"light": [btn(JOY_BUTTON_X), btn(JOY_BUTTON_A)],
		"heavy": [btn(JOY_BUTTON_Y), btn(JOY_BUTTON_B)],
		"start": [btn(JOY_BUTTON_START)],
	}
	if dev >= 0 and not Input.is_joy_known(dev):
		m["up"].append(axis(7, -1))
		m["down"].append(axis(7, 1))
		m["left"].append(axis(6, -1))
		m["right"].append(axis(6, 1))
	return m


func get_mapping(dev: int) -> Dictionary:
	var guid := Input.get_joy_guid(dev)
	if _custom.has(guid):
		return _custom[guid]
	return default_mapping(dev)


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
	var i := int(b["i"])
	# Measure against this pad's resting value, not against zero.
	var v := Input.get_joy_axis(dev, i) - float(rest_of(dev).get(i, 0.0))
	return v * float(b["s"]) > AXIS_THRESHOLD


static func binding_text(b: Dictionary) -> String:
	if b.get("t") == "b":
		return "Button %d" % int(b["i"])
	return "Axis %d %s" % [int(b["i"]), "+" if int(b["s"]) > 0 else "-"]


func _save() -> void:
	var cfg := ConfigFile.new()
	for guid in _custom:
		cfg.set_value("pads", guid, _custom[guid])
	for guid in _rest:
		if not (_rest[guid] as Dictionary).is_empty():
			cfg.set_value("rest", guid, _rest[guid])
	cfg.save(SAVE_PATH)


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if cfg.has_section("pads"):
		for guid in cfg.get_section_keys("pads"):
			var mapping = cfg.get_value("pads", guid)
			if mapping is Dictionary:
				_custom[guid] = mapping
	if cfg.has_section("rest"):
		for guid in cfg.get_section_keys("rest"):
			var rest = cfg.get_value("rest", guid)
			if rest is Dictionary:
				_rest[guid] = rest


## Lets players fix an unrecognized adapter without touching the game, by
## dropping the community `gamecontrollerdb.txt` next to the executable.
func _load_sdl_db() -> void:
	var paths := SDL_DB_PATHS.duplicate()
	paths.append(OS.get_executable_path().get_base_dir().path_join("gamecontrollerdb.txt"))
	for path in paths:
		if not FileAccess.file_exists(path):
			continue
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			continue
		var added := 0
		while not f.eof_reached():
			var line := f.get_line().strip_edges()
			if line.is_empty() or line.begins_with("#"):
				continue
			Input.add_joy_mapping(line, true)
			added += 1
		print("Controls: loaded %d controller mappings from %s" % [added, path])
		return
