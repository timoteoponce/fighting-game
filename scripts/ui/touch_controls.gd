class_name TouchControls
extends Node2D
## On-screen pad for a phone. Holds the same bits a keyboard holds, so every
## screen keeps reading Controls and never learns about fingers.
##
## Sits in the bottom corners of the 640x360 screen, under the move lists on
## the select screen and over the edges of a stage. One finger on the pad can
## drag a quarter-circle; the diagonals set two bits, which is what a special
## already expects from a D-pad.

const PAD := Vector2(72, 302)
const PAD_R := 58.0
const PAD_DEAD := 16.0
const LIGHT_AT := Vector2(516, 292)
const HEAVY_AT := Vector2(596, 316)
const BTN_R := 32.0
const START_AT := Vector2(608, 18)
const START_R := 14.0

var _fingers := {}  # index -> bits that finger is holding


func _process(_delta: float) -> void:
	if not Controls.phone:
		visible = false
		_release_all()
		return
	visible = true
	# The logical screen is always 16:9. The window is what rotates.
	if _portrait():
		_release_all()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not Controls.phone or _portrait():
		return
	if event is InputEventScreenTouch:
		var tap := event as InputEventScreenTouch
		if tap.pressed:
			_fingers[tap.index] = bits_at(tap.position)
		else:
			_fingers.erase(tap.index)
		_apply()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_fingers[drag.index] = bits_at(drag.position)
		_apply()


## Bits a finger at `p` is holding. Buttons win over the pad so a thumb on L
## is never also a direction.
func bits_at(p: Vector2) -> int:
	if p.distance_to(START_AT) <= START_R:
		return Controls.START
	if p.distance_to(LIGHT_AT) <= BTN_R:
		return Controls.LIGHT
	if p.distance_to(HEAVY_AT) <= BTN_R:
		return Controls.HEAVY
	var d := p - PAD
	var dist := d.length()
	if dist < PAD_DEAD or dist > PAD_R:
		return 0
	# Sector 0 is centred on the right. Diagonals are their own sectors.
	var sector := posmod(int(floor((rad_to_deg(atan2(d.y, d.x)) + 22.5) / 45.0)), 8)
	match sector:
		0:
			return Controls.RIGHT
		1:
			return Controls.RIGHT | Controls.DOWN
		2:
			return Controls.DOWN
		3:
			return Controls.LEFT | Controls.DOWN
		4:
			return Controls.LEFT
		5:
			return Controls.LEFT | Controls.UP
		6:
			return Controls.UP
		_:
			return Controls.RIGHT | Controls.UP


func _portrait() -> bool:
	var s := DisplayServer.window_get_size()
	return s.y > s.x


func _apply() -> void:
	var m := 0
	for bits in _fingers.values():
		m |= int(bits)
	Controls.touch_mask = m
	queue_redraw()


func _release_all() -> void:
	if _fingers.is_empty() and Controls.touch_mask == 0:
		return
	_fingers.clear()
	Controls.touch_mask = 0


func _draw() -> void:
	if _portrait():
		draw_rect(Rect2(0, 0, 640, 360), Color(0.05, 0.02, 0.12, 0.92))
		UI.title(self, Vector2(320, 160), "TURN SIDEWAYS", 28)
		UI.text(self, Vector2(320, 206), "The fight needs the wide screen", 14, Color.WHITE)
		return
	_draw_pad()
	_draw_button(LIGHT_AT, BTN_R, "L", Controls.LIGHT)
	_draw_button(HEAVY_AT, BTN_R, "H", Controls.HEAVY)
	_draw_button(START_AT, START_R, "II", Controls.START)


func _draw_pad() -> void:
	draw_circle(PAD, PAD_R, Color(0, 0, 0, 0.38))
	var sector := _sector_of(Controls.touch_mask)
	if sector >= 0:
		_wedge(sector, Color(1, 0.82, 0.25, 0.9))
	draw_arc(PAD, PAD_R - 2.0, 0, TAU, 32, Color(1, 1, 1, 0.45), 2.0)
	draw_circle(PAD, PAD_DEAD, Color(1, 1, 1, 0.18))
	for dir: Vector2 in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		var tip := PAD + dir * (PAD_R * 0.72)
		draw_colored_polygon(PackedVector2Array([
			tip + dir * 8.0,
			tip + Vector2(-dir.y, dir.x) * 6.0,
			tip + Vector2(dir.y, -dir.x) * 6.0,
		]), Color(1, 1, 1, 0.8))


func _sector_of(mask: int) -> int:
	var dir := mask & (Controls.UP | Controls.DOWN | Controls.LEFT | Controls.RIGHT)
	match dir:
		Controls.RIGHT:
			return 0
		Controls.RIGHT | Controls.DOWN:
			return 1
		Controls.DOWN:
			return 2
		Controls.LEFT | Controls.DOWN:
			return 3
		Controls.LEFT:
			return 4
		Controls.LEFT | Controls.UP:
			return 5
		Controls.UP:
			return 6
		Controls.RIGHT | Controls.UP:
			return 7
		_:
			return -1


func _wedge(sector: int, col: Color) -> void:
	var pts := PackedVector2Array()
	pts.append(PAD)
	var a0 := deg_to_rad(float(sector) * 45.0 - 22.5)
	var a1 := a0 + deg_to_rad(45.0)
	for i in 5:
		var a := lerpf(a0, a1, float(i) / 4.0)
		pts.append(PAD + Vector2(cos(a), sin(a)) * (PAD_R - 3.0))
	draw_colored_polygon(pts, col)


func _draw_button(at: Vector2, radius: float, label: String, bit: int) -> void:
	var down := Controls.touch_mask & bit != 0
	draw_circle(at, radius, Color(1, 0.82, 0.25, 0.95) if down else Color(0, 0, 0, 0.45))
	draw_arc(at, radius - 1.5, 0, TAU, 24, Color(1, 1, 1, 0.7), 2.0)
	UI.text(self, at + Vector2(0, radius * 0.28), label, int(radius * 0.7), Color(0.08, 0.04, 0.1) if down else Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 3)
