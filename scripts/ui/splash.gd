class_name SplashScreen
extends Node2D
## Cold-boot logo slam. Plays once per launch, then the title menu.
## Beats come from Sfx.logo_cues(), which is also what the sting is built from,
## so a letter and its chord cannot drift apart.

const ANY := Controls.UP | Controls.DOWN | Controls.LEFT | Controls.RIGHT | Controls.LIGHT | Controls.HEAVY | Controls.START
const LETTER := 72
const ROW_Y: Array[float] = [158.0, 246.0]
const CENTRE := Vector2(320, 202)

var t := 0.0
var _left := false
var _cues: Array = []
var _places: Array[Vector2] = []


func _ready() -> void:
	_cues = Sfx.logo_cues()
	_layout()


func _process(delta: float) -> void:
	t += delta
	# A click on the web shell, or a key that was already down, can land on the
	# first frames. Hold the slam shut just long enough for the P to hit.
	if t > 0.2 and Controls.any_just_pressed(ANY) != Controls.NONE:
		_leave()
	queue_redraw()


func _leave() -> void:
	if _left:
		return
	_left = true
	GameState.goto("title")


func _layout() -> void:
	var font := UI.arcade_font()
	_places.resize(_cues.size())
	_place_row(0, 4, ROW_Y[0], font)
	_place_row(4, 9, ROW_Y[1], font)


func _place_row(from: int, to: int, y: float, font: Font) -> void:
	var gap := 10.0
	var widths: Array[float] = []
	var total := 0.0
	for i in range(from, to):
		var cue: Dictionary = _cues[i]
		var w := font.get_string_size(str(cue["ch"]), HORIZONTAL_ALIGNMENT_LEFT, -1, LETTER).x
		widths.append(w)
		total += w
	total += gap * float(to - from - 1)
	var x := 320.0 - total * 0.5
	for i in range(from, to):
		_places[i] = Vector2(x + widths[i - from] * 0.5, y)
		x += widths[i - from] + gap


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("120614"), Color("4a1878"))
	_speed_lines()
	var shake := _shake()
	var pts := UI.slant(Rect2(48, 100, 544, 172), 18.0)
	for i in pts.size():
		pts[i] += shake
	UI.gradient_quad(self, pts, Color(0.08, 0.02, 0.14, 0.72), Color(0.28, 0.04, 0.16, 0.55))
	var logo_scale := _logo_scale()
	for i in _cues.size():
		var cue: Dictionary = _cues[i]
		var age := t - float(cue["t"])
		if age < 0.0:
			continue
		var k := clampf(age / 0.12, 0.0, 1.0)
		var ease := 1.0 - pow(1.0 - k, 3.0)
		var side := 1.0 if i % 2 == 0 else -1.0
		var fall := Vector2(side * 110.0, -170.0) * (1.0 - ease)
		var rest: Vector2 = _places[i]
		var pos := CENTRE + (rest - CENTRE) * logo_scale + fall + shake
		var pop := lerpf(1.4, 1.0, ease) * logo_scale
		var col := Color("ffd23f") if i < 4 else Color("ff8ab8")
		_star(pos, age)
		UI.title(self, pos, str(cue["ch"]), maxi(1, int(LETTER * pop)), col)
	_flash()
	_caption()


func _speed_lines() -> void:
	var c := Vector2(320, 190)
	for i in 18:
		var a := TAU * i / 18.0 + t * 0.35
		var p1 := c + Vector2(cos(a), sin(a)) * 40.0
		var p2 := c + Vector2(cos(a + 0.08), sin(a + 0.08)) * 520.0
		var p3 := c + Vector2(cos(a - 0.08), sin(a - 0.08)) * 520.0
		draw_colored_polygon(PackedVector2Array([p1, p2, p3]), Color(1, 1, 1, 0.05))


func _shake() -> Vector2:
	var shake := Vector2.ZERO
	for i in _cues.size():
		var cue: Dictionary = _cues[i]
		var age := t - float(cue["t"])
		if age < 0.0 or age >= 0.16:
			continue
		var mag := (1.0 - age / 0.16) * (14.0 if i == _cues.size() - 1 else 7.0)
		shake = Vector2(sin(age * 95.0) * mag, cos(age * 73.0) * mag * 0.6)
	return shake


## The whole word punches in on the last letter, then settles.
func _logo_scale() -> float:
	var last: Dictionary = _cues[_cues.size() - 1]
	var age := t - float(last["t"])
	if age < 0.0:
		return 1.0
	var u := clampf(age / 0.3, 0.0, 1.0)
	return lerpf(1.2, 1.0, 1.0 - pow(1.0 - u, 2.0))


func _star(at: Vector2, age: float) -> void:
	if age < 0.0 or age > 0.22:
		return
	var a := 1.0 - age / 0.22
	var r := 8.0 + age * 78.0
	for n in 6:
		var ang := TAU * float(n) / 6.0 + age * 2.0
		var tip := at + Vector2(cos(ang), sin(ang)) * r
		var left := at + Vector2(cos(ang + 0.45), sin(ang + 0.45)) * 6.0
		var right := at + Vector2(cos(ang - 0.45), sin(ang - 0.45)) * 6.0
		draw_colored_polygon(PackedVector2Array([left, tip, right]), Color(1, 0.95, 0.8, 0.9 * a))


func _flash() -> void:
	var last: Dictionary = _cues[_cues.size() - 1]
	var age := t - float(last["t"])
	if age < 0.0 or age > 0.16:
		return
	draw_rect(Rect2(0, 0, 640, 360), Color(1, 1, 1, (1.0 - age / 0.16) * 0.8))


func _caption() -> void:
	var last: Dictionary = _cues[_cues.size() - 1]
	var age := t - float(last["t"])
	if age < 0.18:
		return
	var fade := clampf((age - 0.18) / 0.35, 0.0, 1.0)
	UI.text(self, Vector2(320, 308), "ULISES   ·   EMILIA   ·   CHARLIE   ·   SILVAN", 13, Color(1, 1, 1, fade))
	if age > 0.45 and sin(t * 6.0) > 0.0:
		UI.text(self, Vector2(320, 338), "PRESS ANY BUTTON", 16, Color("ffd23f"))
