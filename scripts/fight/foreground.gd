class_name Foreground
extends Node2D
## Foreground occluders: dark, out-of-focus silhouettes drawn in front of the
## fighters to sell depth. Parallax f > 1 so they move faster than the fighters
## and read as close to the camera. Sits at z_index 4 — above the fighters,
## below the effects — so hit sparks still read on top of everything.

var stage: Stage
var kind := "field"
var t := 0.0

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func layer(f: float) -> void:
	var sx := 0.0
	var sy := 0.0
	if stage != null:
		sx = (stage.cam_x - Fight.STAGE_W * 0.5) * (1.0 - f)
		sy = (stage.cam_y - Stage.BASE_Y) * (1.0 - f)
	draw_set_transform(Vector2(sx, sy))

func _draw() -> void:
	match kind:
		"library":
			_draw_library()
		"rooftop":
			_draw_rooftop()
		"dojo":
			_draw_dojo()
		"beach":
			_draw_beach()
		"snow":
			_draw_snow()
		_:
			_draw_field()
	draw_set_transform(Vector2.ZERO)

# --- Soccer stadium ----------------------------------------------------------------

func _draw_field() -> void:
	# Near crowd: dark heads and shoulders along the bottom, in front of the pitch.
	layer(1.3)
	var col := Color(0.02, 0.02, 0.05, 0.88)
	for i in 11:
		var x := -120.0 + i * 125.0 + sin(t * 0.5 + i * 2.3) * 5.0
		var y := 350.0 + sin(i * 1.9) * 6.0
		draw_circle(Vector2(x, y - 16.0), 19.0, col)
		draw_circle(Vector2(x, y + 10.0), 29.0, col)

# --- Magic library -----------------------------------------------------------------

func _draw_library() -> void:
	# A near bookshelf on the left edge, and a candle hanging in from the top.
	layer(1.25)
	var col := Color(0.03, 0.02, 0.05, 0.9)
	draw_rect(Rect2(-40, -60, 70, 460), col)
	for i in 6:
		draw_line(Vector2(-40, 20.0 + i * 62.0), Vector2(30, 20.0 + i * 62.0), Color(0.1, 0.07, 0.14, 0.8), 3.0)
	# Candle.
	var cx := 620.0
	var cy := sin(t * 0.8) * 4.0
	draw_line(Vector2(cx, -40), Vector2(cx, 40.0 + cy), Color(0.05, 0.04, 0.08, 0.9), 3.0)
	draw_circle(Vector2(cx, 52.0 + cy), 7.0, Color(0.1, 0.08, 0.12, 0.9))
	draw_circle(Vector2(cx, 50.0 + cy), 3.0, Color(1, 0.85, 0.5, 0.7))

# --- Rooftop -----------------------------------------------------------------------

func _draw_rooftop() -> void:
	# A near railing along the bottom and an antenna on the right.
	layer(1.3)
	var col := Color(0.02, 0.02, 0.06, 0.9)
	draw_rect(Rect2(-100, 330, 1300, 40), col)
	for i in 12:
		draw_rect(Rect2(-80.0 + i * 110.0, 300, 8, 60), col)
	# Antenna.
	draw_line(Vector2(920, 340), Vector2(920, 180), col, 5.0)
	draw_line(Vector2(890, 200), Vector2(950, 200), col, 4.0)
	draw_line(Vector2(900, 240), Vector2(940, 240), col, 4.0)

# --- Dojo --------------------------------------------------------------------------

func _draw_dojo() -> void:
	# A near wooden pillar on the left and a lantern hanging in from the top.
	layer(1.25)
	var col := Color(0.04, 0.02, 0.03, 0.92)
	draw_rect(Rect2(-30, -60, 60, 460), col)
	draw_line(Vector2(-30, -60), Vector2(-30, 400), Color(0.12, 0.07, 0.08, 0.7), 3.0)
	# Lantern.
	var lx := 560.0
	var ly := sin(t * 0.6) * 5.0
	draw_line(Vector2(lx, -40), Vector2(lx, 30.0 + ly), Color(0.06, 0.04, 0.05, 0.9), 3.0)
	draw_circle(Vector2(lx, 48.0 + ly), 16.0, Color(0.14, 0.09, 0.08, 0.9))
	draw_circle(Vector2(lx, 48.0 + ly), 9.0, Color(1, 0.7, 0.35, 0.55))

# --- Beach ------------------------------------------------------------------------

func _draw_beach() -> void:
	# A palm frond hanging in from the top-left, and a rock on the bottom-right.
	layer(1.25)
	var col := Color(0.03, 0.05, 0.04, 0.9)
	for i in 5:
		var a := -0.5 + i * 0.28
		var pts := PackedVector2Array()
		for k in 8:
			var d := k * 22.0
			pts.append(Vector2(40.0 + cos(a) * d, -20.0 + sin(a) * d + k * k * 1.5))
		draw_polyline(pts, col, 7.0 - i * 0.8, true)
	draw_circle(Vector2(560, 350), 46.0, Color(0.05, 0.05, 0.07, 0.85))
	draw_circle(Vector2(520, 356), 30.0, Color(0.05, 0.05, 0.07, 0.8))

# --- Snowy park --------------------------------------------------------------------

func _draw_snow() -> void:
	# A snowdrift along the bottom and a bare branch in from the top-right.
	layer(1.3)
	draw_colored_polygon(PackedVector2Array([Vector2(-100, 360), Vector2(-100, 330),
		Vector2(200, 318), Vector2(500, 332), Vector2(800, 320), Vector2(1100, 335),
		Vector2(1100, 360)]), Color(0.75, 0.8, 0.9, 0.9))
	var col := Color(0.04, 0.03, 0.05, 0.9)
	for i in 4:
		var a := 2.6 + i * 0.22
		var pts := PackedVector2Array()
		for k in 7:
			var d := k * 24.0
			pts.append(Vector2(620.0 - cos(a) * d, -10.0 + sin(a) * d + k * k * 1.2))
		draw_polyline(pts, col, 6.0 - i * 0.9, true)
