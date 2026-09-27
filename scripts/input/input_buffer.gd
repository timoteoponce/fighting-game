class_name InputBuffer
extends RefCounted
## Per-fighter input history. Remembers when each button was last pressed so
## moves can be buffered and "L+H together" can be detected leniently.

const SIZE := 32
const COMBO_WINDOW := 4  # max frames between L and H to count as "together"

var hist := PackedInt32Array()
var frame := 0
var _press := {}  # bit -> frame of last press
var _consumed := {}  # bit -> press frame already used
var _combo_used := -1


func _init() -> void:
	hist.resize(SIZE)


func push(mask: int) -> void:
	var prev := current()
	frame += 1
	hist[frame % SIZE] = mask
	var edges := mask & ~prev
	for bit in [Controls.UP, Controls.DOWN, Controls.LEFT, Controls.RIGHT, Controls.LIGHT, Controls.HEAVY, Controls.START]:
		if edges & bit:
			_press[bit] = frame


func current() -> int:
	return hist[frame % SIZE]


func held(bit: int) -> bool:
	return current() & bit != 0


func pressed_now(bit: int) -> bool:
	return int(_press.get(bit, -1000)) == frame


## True if `bit` was pressed in the last `window` frames and not used yet.
func pressed_within(bit: int, window: int) -> bool:
	var f: int = _press.get(bit, -1000)
	return frame - f < window and int(_consumed.get(bit, -1)) < f


func consume(bit: int) -> void:
	_consumed[bit] = _press.get(bit, frame)


## Light and Heavy pressed (almost) together, recently, and not used yet.
func lh_combo() -> bool:
	var fl: int = _press.get(Controls.LIGHT, -1000)
	var fh: int = _press.get(Controls.HEAVY, -1000)
	if absi(fl - fh) > COMBO_WINDOW:
		return false
	var latest := maxi(fl, fh)
	return frame - latest <= 5 and _combo_used < latest


func consume_combo() -> void:
	_combo_used = frame
	consume(Controls.LIGHT)
	consume(Controls.HEAVY)


func clear() -> void:
	hist.fill(0)
	_press.clear()
	_consumed.clear()
	_combo_used = frame
