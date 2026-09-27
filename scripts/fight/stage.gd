class_name Stage
extends Node2D
## Backgrounds drawn in code, with simple parallax layers.
## "field": soccer field at dusk (Ulises). "library": magic library / art room (Emilia).

const CROWD := [Color("ff5a5a"), Color("ffd24a"), Color("5ac8ff"), Color("7dff8a"), Color("ff8ad8"), Color("ffffff")]
const BOOKS := [Color("c0392b"), Color("2980b9"), Color("27ae60"), Color("f1c40f"), Color("8e44ad"), Color("e67e22"), Color("ff7eb6")]

var kind := "field"
var cam_x := 500.0
var t := 0.0
var dim := 0.0


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


## Parallax: f = 1 moves with the fighters, f = 0 stays glued to the screen.
func px(x: float, f: float) -> float:
	return x + (cam_x - Fight.STAGE_W * 0.5) * (1.0 - f)


func _draw() -> void:
	if kind == "library":
		_draw_library()
	else:
		_draw_field()
	if dim > 0.0:
		draw_rect(Rect2(cam_x - 450, -250, 900, 700), Color(0.02, 0.0, 0.08, dim * 0.7))


func _draw_field() -> void:
	var left := cam_x - 420.0
	UI.gradient_rect(self, Rect2(left, -200, 840, 80), Color("120c2c"), Color("1d1640"))
	UI.gradient_rect(self, Rect2(left, -120, 840, 360), Color("1d1640"), Color("ff8a5c"))
	for i in 25:
		var sx := left + fmod(i * 97.3, 840.0)
		draw_circle(Vector2(sx, 10.0 + fmod(i * 23.7, 60.0)), 1.0, Color(1, 1, 1, 0.5 + 0.5 * sin(t * 2.0 + i)))
	var sun := Vector2(px(720, 0.15), 200)
	for i in 4:
		draw_circle(sun, 60.0 - i * 8.0, Color(1, 0.7, 0.3, 0.12), true, -1.0, true)
	draw_circle(sun, 34.0, Color("ffcf6b"), true, -1.0, true)
	# Stadium stands with a cheering crowd.
	var s0 := px(-200, 0.5)
	var s1 := px(1200, 0.5)
	draw_colored_polygon(PackedVector2Array([Vector2(s0, 150), Vector2(s1, 150), Vector2(s1, 240), Vector2(s0, 240)]), Color("2c2f4a"))
	for row in 5:
		draw_line(Vector2(s0, 160 + row * 16), Vector2(s1, 160 + row * 16), Color("3a3e5e"), 2.0)
	for i in 320:
		var x := px(-200.0 + fmod(i * 37.7, 1400.0), 0.5)
		var y := 158.0 + float((i * 13) % 72) + sin(t * 7.0 + i) * 1.2
		draw_circle(Vector2(x, y), 3.0, CROWD[i % CROWD.size()].darkened(0.25), true, -1.0, true)
	for lx in [60.0, 940.0]:
		var x := px(lx, 0.5)
		draw_line(Vector2(x, 60), Vector2(x, 150), Color("555a70"), 4.0)
		draw_rect(Rect2(x - 20, 48, 40, 16), Color("fff6c8"))
		draw_circle(Vector2(x, 56), 36.0, Color(1, 1, 0.8, 0.12), true, -1.0, true)
	# Pitch.
	draw_rect(Rect2(-200, 236, 1400, 200), Color("3f9b3a"))
	for i in 22:
		if i % 2 == 0:
			draw_rect(Rect2(-200 + i * 70, 236, 70, 200), Color("378a33"))
	draw_line(Vector2(-200, 246), Vector2(1200, 246), Color(1, 1, 1, 0.7), 3.0)
	draw_line(Vector2(500, 246), Vector2(500, 360), Color(1, 1, 1, 0.35), 3.0)
	draw_polyline(FighterRenderer.ellipse_pts(Vector2(500, 300), 90, 24, 0.0, 40) + PackedVector2Array([Vector2(590, 300)]), Color(1, 1, 1, 0.35), 3.0, true)
	for gx in [30.0, 970.0]:
		var x := px(gx, 0.85)
		var w := 60.0
		var x0 := x - w * 0.5
		for n in 7:
			draw_line(Vector2(x0 + n * 10, 200), Vector2(x0 + n * 10, 246), Color(1, 1, 1, 0.25), 1.0)
		for n in 5:
			draw_line(Vector2(x0, 200 + n * 11), Vector2(x0 + w, 200 + n * 11), Color(1, 1, 1, 0.25), 1.0)
		draw_polyline(PackedVector2Array([Vector2(x0, 246), Vector2(x0, 198), Vector2(x0 + w, 198), Vector2(x0 + w, 246)]), Color.WHITE, 4.0)


func _draw_library() -> void:
	var left := cam_x - 420.0
	UI.gradient_rect(self, Rect2(left, -200, 840, 500), Color("120a24"), Color("47307a"))
	# Big arched window with the moon.
	var wx := px(500, 0.3)
	var win := PackedVector2Array()
	win.append(Vector2(wx - 70, 210))
	for i in 17:
		var a := PI + PI * i / 16.0
		win.append(Vector2(wx + cos(a) * 70, 100 + sin(a) * 70))
	win.append(Vector2(wx + 70, 210))
	draw_colored_polygon(win, Color("16204a"))
	for i in 18:
		draw_circle(Vector2(wx - 60 + fmod(i * 41.3, 120.0), 50.0 + fmod(i * 29.1, 150.0)), 1.0, Color(1, 1, 1, 0.5 + 0.5 * sin(t * 3.0 + i)))
	draw_circle(Vector2(wx + 22, 80), 22.0, Color("fff3c4"), true, -1.0, true)
	draw_circle(Vector2(wx + 30, 74), 4.0, Color("eadba8"), true, -1.0, true)
	draw_circle(Vector2(wx + 14, 90), 3.0, Color("eadba8"), true, -1.0, true)
	draw_polyline(win + PackedVector2Array([win[0]]), Color("7a4b2a"), 6.0, true)
	draw_line(Vector2(wx, 32), Vector2(wx, 210), Color("7a4b2a"), 4.0)
	draw_line(Vector2(wx - 70, 130), Vector2(wx + 70, 130), Color("7a4b2a"), 4.0)
	# Bookshelves.
	for sx in [-120.0, 120.0, 780.0, 1000.0]:
		var x := px(sx, 0.6)
		draw_rect(Rect2(x, 40, 150, 250), Color("5a3620"))
		for row in 5:
			var y := 50.0 + row * 48.0
			var bx := x + 8.0
			var i := int(sx) + row * 11
			while bx < x + 140.0:
				var bw := 7.0 + float((i * 7) % 6)
				var bh := 30.0 + float((i * 13) % 12)
				draw_rect(Rect2(bx, y + 40.0 - bh, bw - 1.0, bh), BOOKS[i % BOOKS.size()])
				bx += bw
				i += 1
			draw_rect(Rect2(x, y + 40, 150, 6), Color("3e2414"))
	# Floating candles.
	for i in 9:
		var x := px(80.0 + i * 110.0, 0.7)
		var y := 70.0 + float((i * 37) % 70) + sin(t * 1.8 + i) * 5.0
		draw_circle(Vector2(x, y - 6), 12.0, Color(1, 0.8, 0.4, 0.15), true, -1.0, true)
		draw_rect(Rect2(x - 3, y, 6, 18), Color("f5ecd7"))
		var fl := sin(t * 12.0 + i) * 1.0
		draw_colored_polygon(PackedVector2Array([Vector2(x - 3, y - 2), Vector2(x + fl, y - 12), Vector2(x + 3, y - 2), Vector2(x, y + 1)]), Color("ffb347"))
	# Easels with drawings.
	for ex in [230.0, 770.0]:
		var x := px(ex, 0.85)
		draw_line(Vector2(x - 24, 290), Vector2(x, 180), Color("8b5a2b"), 4.0)
		draw_line(Vector2(x + 24, 290), Vector2(x, 180), Color("8b5a2b"), 4.0)
		draw_rect(Rect2(x - 32, 196, 64, 50), Color("fffaf0"))
		draw_rect(Rect2(x - 32, 196, 64, 50), Color("8b5a2b"), false, 2.0)
		if ex < 500.0:
			draw_colored_polygon(FighterRenderer.star_pts(Vector2(x - 10, 216), 12, 5), Color("ffd24a"))
			draw_circle(Vector2(x + 14, 230), 7.0, Color("ff7eb6"), true, -1.0, true)
		else:
			for k in 4:
				draw_arc(Vector2(x, 244), 26.0 - k * 5.0, PI, TAU, 16, [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN][k], 3.0, true)
		draw_rect(Rect2(x - 36, 246, 72, 5), Color("8b5a2b"))
	# Wooden floor and rug.
	draw_rect(Rect2(-200, 286, 1400, 150), Color("6b4226"))
	for i in 4:
		draw_line(Vector2(-200, 296 + i * 18), Vector2(1200, 296 + i * 18), Color("5a3620"), 2.0)
	for i in 30:
		var row := i % 4
		draw_line(Vector2(-200 + i * 53 + row * 20, 296 + row * 18), Vector2(-200 + i * 53 + row * 20, 314 + row * 18), Color("5a3620"), 2.0)
	draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(500, 318), 270, 26, 0.0, 40), Color("8e3f8f"))
	draw_polyline(FighterRenderer.ellipse_pts(Vector2(500, 318), 256, 21, 0.0, 40) + PackedVector2Array([Vector2(756, 318)]), Color("ff9ed6"), 2.0, true)
	for i in 14:
		var sx := px(fmod(i * 83.0 + t * 12.0, 1100.0) - 50.0, 0.9)
		var sy := 60.0 + fmod(i * 47.0, 200.0) + sin(t + i) * 8.0
		draw_colored_polygon(FighterRenderer.star_pts(Vector2(sx, sy), 3.0, 1.2, 4, t), Color(1, 0.85, 1, 0.4 + 0.3 * sin(t * 3.0 + i)))
