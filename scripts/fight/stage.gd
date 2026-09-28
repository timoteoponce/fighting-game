class_name Stage
extends Node2D
## Layered backgrounds drawn in code.
## "field": soccer stadium at dusk (Ulises). "library": magic library hall (Emilia).
##
## Layers are authored as if the camera sits at (500, BASE_Y); layer(f) shifts
## each one so f = 1 moves with the fighters and f = 0 stays on screen.

const BASE_Y := 192.0
const CROWD := [Color("ff5a5a"), Color("ffd24a"), Color("5ac8ff"), Color("7dff8a"), Color("ff8ad8"), Color("ffffff"), Color("b28dff")]
const BOOKS := [Color("c0392b"), Color("2980b9"), Color("27ae60"), Color("f1c40f"), Color("8e44ad"), Color("e67e22"), Color("ff7eb6"), Color("16a085")]

var kind := "field"
var cam_x := 500.0
var cam_y := BASE_Y
var cam_zoom := 1.2
var t := 0.0
var dim := 0.0
var hyper_color := Color(1, 0.4, 0.8)


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func layer(f: float) -> void:
	draw_set_transform(Vector2((cam_x - Fight.STAGE_W * 0.5) * (1.0 - f), (cam_y - BASE_Y) * (1.0 - f)))


func _draw() -> void:
	if kind == "library":
		_draw_library()
	else:
		_draw_field()
	draw_set_transform(Vector2.ZERO)
	_draw_vignette()
	if dim > 0.0:
		_draw_hyper_backdrop()


# --- Soccer stadium ----------------------------------------------------------------

func _draw_field() -> void:
	# Sky.
	layer(0.0)
	UI.gradient_rect(self, Rect2(-300, -400, 1600, 260), Color("0b0822"), Color("2a1650"))
	UI.gradient_rect(self, Rect2(-300, -140, 1600, 200), Color("2a1650"), Color("a3366e"))
	UI.gradient_rect(self, Rect2(-300, 60, 1600, 140), Color("a3366e"), Color("ff9a5a"))
	for i in 40:
		var p := Vector2(fmod(i * 97.3, 1600.0) - 300.0, -380.0 + fmod(i * 53.7, 400.0))
		draw_circle(p, 1.0 + (i % 3) * 0.3, Color(1, 1, 1, 0.35 + 0.35 * sin(t * 2.0 + i)))
	layer(0.08)
	var sun := Vector2(640, 178)
	for i in 6:
		draw_circle(sun, 90.0 - i * 12.0, Color(1, 0.65, 0.3, 0.07), true, -1.0, true)
	draw_circle(sun, 30.0, Color("ffd88a"), true, -1.0, true)
	draw_circle(sun, 24.0, Color("fff2c4"), true, -1.0, true)
	for c in [[Vector2(260, 70), 1.0], [Vector2(520, 30), 1.3], [Vector2(820, 90), 0.9], [Vector2(1050, 40), 1.1]]:
		_cloud(c[0] + Vector2(fmod(t * 4.0, 60.0), 0), c[1])
	# Distant city.
	layer(0.2)
	for i in 34:
		var x := -250.0 + i * 46.0
		var h := 30.0 + float((i * 37) % 55)
		var w := 30.0 + float((i * 13) % 18)
		draw_rect(Rect2(x, 205 - h, w, h + 20), Color("2b1d4a"))
		for wy in range(int(h / 9)):
			for wx in 3:
				if (i + wy * 3 + wx) % 4 != 0:
					draw_rect(Rect2(x + 5 + wx * 8, 210 - h + wy * 9, 3, 4), Color(1, 0.85, 0.5, 0.55))
	# Stadium upper tier.
	layer(0.45)
	_stands(Rect2(-350, 146, 1700, 64), 0.55, 20)
	draw_colored_polygon(PackedVector2Array([Vector2(-350, 124), Vector2(1350, 124), Vector2(1350, 138), Vector2(-350, 148)]), Color("1c1830"))
	for i in 24:
		var x := -340.0 + i * 72.0
		draw_line(Vector2(x, 126), Vector2(x + 36, 146), Color("3a3456"), 2.0)
		draw_line(Vector2(x + 72, 126), Vector2(x + 36, 146), Color("3a3456"), 2.0)
	# Giant screen on the roof.
	var sc := Rect2(700, 70, 120, 50)
	draw_line(Vector2(sc.position.x + 20, sc.end.y), Vector2(sc.position.x + 20, 126), Color("3a3456"), 3.0)
	draw_line(Vector2(sc.end.x - 20, sc.end.y), Vector2(sc.end.x - 20, 126), Color("3a3456"), 3.0)
	draw_rect(sc, Color("141222"))
	draw_rect(sc.grow(-4), Color("1b2a6a"))
	UI.text(self, sc.get_center() + Vector2(0, -2), "FRIENDS CUP", 11, Color(1, 0.9, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 3, Color.BLACK, UI.arcade_font())
	UI.text(self, sc.get_center() + Vector2(0, 14), "ULISES VS EMILIA", 8, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 2, Color.BLACK)
	draw_rect(sc, Color("5a5a7a"), false, 2.0)
	# Floodlights with light cones.
	for lx in [60.0, 940.0]:
		draw_line(Vector2(lx, -60), Vector2(lx, 140), Color("4a4a66"), 5.0)
		draw_rect(Rect2(lx - 28, -90, 56, 34), Color("30304a"))
		for gy in 3:
			for gx in 5:
				draw_circle(Vector2(lx - 20 + gx * 10, -82 + gy * 9), 3.5, Color("fffbe0"), true, -1.0, true)
		draw_colored_polygon(PackedVector2Array([Vector2(lx - 28, -60), Vector2(lx + 28, -60), Vector2(lx + 240, 330), Vector2(lx - 240, 330)]), Color(1, 1, 0.85, 0.05))
		draw_circle(Vector2(lx, -73), 60.0, Color(1, 1, 0.8, 0.1), true, -1.0, true)
	# Lower tier and LED boards.
	layer(0.7)
	_stands(Rect2(-350, 196, 1700, 36), 0.75, 24)
	draw_rect(Rect2(-350, 226, 1700, 18), Color("101020"))
	var msgs := ["GOAL!", "SUPER", "FIGHT!", "FRIENDS CUP", "LEVEL UP", "MAGIC!"]
	for i in 14:
		var x := -330.0 + i * 120.0
		var c := Color.from_hsv(fmod(i * 0.17 + t * 0.1, 1.0), 0.7, 1.0)
		draw_rect(Rect2(x, 228, 112, 14), c.darkened(0.6))
		UI.text(self, Vector2(x + 56, 240), msgs[i % msgs.size()], 10, c, HORIZONTAL_ALIGNMENT_CENTER, 0, Color.BLACK, UI.arcade_font())
	# Pitch.
	layer(1.0)
	UI.gradient_rect(self, Rect2(-300, 244, 1600, 200), Color("2f7a2c"), Color("4caf45"))
	for i in 26:
		if i % 2 == 0:
			draw_colored_polygon(PackedVector2Array([Vector2(-300 + i * 64, 244), Vector2(-236 + i * 64, 244),
				Vector2(-236 + i * 64 + (i - 13) * 8, 444), Vector2(-300 + i * 64 + (i - 13) * 8, 444)]), Color(0, 0, 0, 0.07))
	draw_line(Vector2(-300, 252), Vector2(1300, 252), Color(1, 1, 1, 0.8), 2.0)
	draw_line(Vector2(500, 252), Vector2(500, 444), Color(1, 1, 1, 0.45), 2.0)
	draw_polyline(_closed(FighterRenderer.ellipse_pts(Vector2(500, 306), 110, 26, 0.0, 48)), Color(1, 1, 1, 0.45), 2.0, true)
	draw_circle(Vector2(500, 306), 3.0, Color(1, 1, 1, 0.6))
	for gx in [70.0, 930.0]:
		_goal(Vector2(gx, 252), -1.0 if gx < 500.0 else 1.0)
	for i in 60:
		var p := Vector2(fmod(i * 131.7, 1600.0) - 300.0, 256.0 + fmod(i * 71.3, 120.0))
		draw_line(p, p + Vector2(1, -3), Color(0.2, 0.45, 0.15, 0.6), 0.8)
	# Ground fog/haze.
	for i in 8:
		var fx := -200.0 + i * 200.0 + sin(t * 0.3 + i) * 30.0
		var fy := 280.0 + sin(t * 0.5 + i * 1.3) * 8.0
		draw_circle(Vector2(fx, fy), 60.0 + sin(t * 0.4 + i) * 15.0, Color(1, 1, 1, 0.03))


func _cloud(c: Vector2, s: float) -> void:
	for b in [[Vector2(0, 0), 22.0], [Vector2(24, -8), 18.0], [Vector2(-22, 2), 16.0], [Vector2(44, 2), 14.0]]:
		draw_circle(c + b[0] * s, b[1] * s, Color("7a3a78"), true, -1.0, true)
	for b in [[Vector2(0, 6), 18.0], [Vector2(24, 2), 14.0], [Vector2(-22, 7), 12.0]]:
		draw_circle(c + b[0] * s, b[1] * s * 0.7, Color(1, 0.6, 0.45, 0.35), true, -1.0, true)


func _stands(r: Rect2, depth: float, rows: int) -> void:
	UI.gradient_rect(self, r, Color("1e1a36"), Color("2f2a50"))
	var head := 2.2 + depth * 1.5
	for row in rows / 6:
		var y := r.position.y + 8.0 + row * (head * 3.2)
		if y > r.end.y - 4:
			break
		draw_line(Vector2(r.position.x, y + head + 2), Vector2(r.end.x, y + head + 2), Color("3a3460"), 1.0)
		var n := int(r.size.x / (head * 2.6))
		for i in n:
			var x := r.position.x + i * head * 2.6 + fmod(row * 3.7, head * 2.0)
			var col: Color = CROWD[(i * 7 + row * 3) % CROWD.size()].darkened(0.55 - depth * 0.3)
			var jump := maxf(0.0, sin(t * 6.0 + i * 0.7 + row)) * 1.5
			draw_rect(Rect2(x - head * 0.8, y + head * 0.8 - jump, head * 1.6, head * 1.6), col)
			draw_circle(Vector2(x, y - jump), head * 0.75, Color(0.95, 0.8, 0.65).darkened(0.55 - depth * 0.3), true, -1.0, true)
	# Camera flashes and flags.
	for i in 10:
		if int(t * 7.0 + i * 13) % 17 == 0:
			var p := Vector2(r.position.x + fmod(i * 173.0 + floor(t * 7.0) * 61.0, r.size.x), r.position.y + fmod(i * 37.0, r.size.y))
			draw_circle(p, 3.0, Color(1, 1, 1, 0.9))
			draw_circle(p, 8.0, Color(1, 1, 1, 0.2))
	for i in 8:
		var base := Vector2(r.position.x + 90.0 + i * 210.0, r.position.y + 10.0)
		var wave := sin(t * 5.0 + i) * 4.0
		draw_line(base, base + Vector2(0, -22), Color("dddddd"), 1.5)
		draw_colored_polygon(PackedVector2Array([base + Vector2(0, -22), base + Vector2(22, -18 + wave), base + Vector2(0, -10)]), CROWD[i % CROWD.size()])


func _goal(base: Vector2, side: float) -> void:
	var w := 64.0
	var x0 := base.x - w * 0.5
	for n in 9:
		draw_line(Vector2(x0 + n * 8, base.y - 50), Vector2(x0 + n * 8 + side * 10, base.y), Color(1, 1, 1, 0.25), 1.0)
	for n in 6:
		draw_line(Vector2(x0, base.y - 50 + n * 10), Vector2(x0 + w, base.y - 50 + n * 10), Color(1, 1, 1, 0.25), 1.0)
	draw_polyline(PackedVector2Array([Vector2(x0, base.y), Vector2(x0, base.y - 52), Vector2(x0 + w, base.y - 52), Vector2(x0 + w, base.y)]), Color.WHITE, 4.0)


# --- Magic library -------------------------------------------------------------------

func _draw_library() -> void:
	layer(0.0)
	UI.gradient_rect(self, Rect2(-300, -400, 1600, 800), Color("0c0620"), Color("3a2566"))
	# Rose window with moonlight.
	layer(0.1)
	var rc := Vector2(500, 60)
	for i in 5:
		draw_circle(rc, 150.0 - i * 18.0, Color(0.55, 0.6, 1.0, 0.05), true, -1.0, true)
	draw_circle(rc, 92.0, Color("2a1e48"), true, -1.0, true)
	for i in 12:
		var a0 := TAU * i / 12.0 + t * 0.02
		var a1 := TAU * (i + 1) / 12.0 + t * 0.02
		var col: Color = [Color("5a7bff"), Color("c05aff"), Color("ff6fb0"), Color("ffd24a")][i % 4]
		draw_colored_polygon(PackedVector2Array([rc + Vector2.from_angle(a0) * 30.0, rc + Vector2.from_angle(a0) * 84.0,
			rc + Vector2.from_angle(a1) * 84.0, rc + Vector2.from_angle(a1) * 30.0]), Color(col, 0.75))
	draw_circle(rc, 28.0, Color("fff3c4"), true, -1.0, true)
	for i in 12:
		var d := Vector2.from_angle(TAU * i / 12.0 + t * 0.02)
		draw_line(rc + d * 28.0, rc + d * 90.0, Color("1a1030"), 3.0)
	draw_arc(rc, 90.0, 0, TAU, 64, Color("6a4a2a"), 7.0, true)
	draw_arc(rc, 30.0, 0, TAU, 32, Color("6a4a2a"), 4.0, true)
	draw_colored_polygon(PackedVector2Array([rc + Vector2(-60, 40), rc + Vector2(60, 40), Vector2(640, 330), Vector2(360, 330)]), Color(0.7, 0.75, 1.0, 0.06))
	# Gothic arches and pillars.
	layer(0.3)
	for i in 9:
		var x := -200.0 + i * 180.0
		if absf(x - 500.0) < 120.0:
			continue
		UI.gradient_rect(self, Rect2(x - 14, -200, 28, 460), Color("2a1c4a"), Color("3e2a66"))
		draw_arc(Vector2(x + 90, 20), 76.0, PI, TAU, 24, Color("2a1c4a"), 10.0, true)
	# Floating candles and orbiting books.
	layer(0.5)
	for i in 14:
		var x := -150.0 + i * 95.0
		var y := 40.0 + float((i * 37) % 90) + sin(t * 1.6 + i) * 6.0
		draw_circle(Vector2(x, y - 8), 18.0, Color(1, 0.75, 0.35, 0.1), true, -1.0, true)
		draw_rect(Rect2(x - 3, y, 6, 20), Color("f5ecd7"))
		var fl := sin(t * 12.0 + i) * 1.2
		draw_colored_polygon(PackedVector2Array([Vector2(x - 3, y - 2), Vector2(x + fl, y - 14), Vector2(x + 3, y - 2), Vector2(x, y + 1)]), Color("ffb347"))
		draw_circle(Vector2(x, y - 4), 1.8, Color("fff6d0"))
	for i in 6:
		var a := t * 0.4 + TAU * i / 6.0
		var p := Vector2(500 + cos(a) * 200.0, 120 + sin(a) * 30.0)
		var w := 14.0 + sin(t * 4.0 + i) * 4.0
		var col: Color = BOOKS[i % BOOKS.size()]
		draw_colored_polygon(PackedVector2Array([p, p + Vector2(-w, -5), p + Vector2(-w, 7), p + Vector2(0, 11)]), col)
		draw_colored_polygon(PackedVector2Array([p, p + Vector2(w, -5), p + Vector2(w, 7), p + Vector2(0, 11)]), col.darkened(0.25))
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, 1), p + Vector2(-w + 2, -3), p + Vector2(-w + 2, 6), p + Vector2(0, 9)]), Color("f5ecd7"))
	# Bookshelves with banners.
	layer(0.72)
	for sx in [-260.0, -40.0, 180.0, 640.0, 860.0, 1080.0]:
		_bookshelf(Vector2(sx, 20), int(sx))
	for bx in [300.0, 700.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(bx - 26, -40), Vector2(bx + 26, -40), Vector2(bx + 26, 110), Vector2(bx, 96), Vector2(bx - 26, 110)]), Color("4b1f7a"))
		draw_line(Vector2(bx - 26, -38), Vector2(bx + 26, -38), Color("ffd24a"), 4.0)
		draw_colored_polygon(FighterRenderer.star_pts(Vector2(bx, 40), 14, 6), Color("ffd24a"))
	# Easels (the art corner).
	layer(0.86)
	for ex in [150.0, 860.0]:
		draw_line(Vector2(ex - 26, 290), Vector2(ex, 176), Color("8b5a2b"), 4.0)
		draw_line(Vector2(ex + 26, 290), Vector2(ex, 176), Color("8b5a2b"), 4.0)
		draw_rect(Rect2(ex - 34, 192, 68, 54), Color("fffaf0"))
		draw_rect(Rect2(ex - 34, 192, 68, 54), Color("8b5a2b"), false, 2.0)
		if ex < 500.0:
			draw_colored_polygon(FighterRenderer.star_pts(Vector2(ex - 10, 214), 13, 5), Color("ffd24a"))
			draw_circle(Vector2(ex + 14, 230), 8.0, Color("ff7eb6"), true, -1.0, true)
		else:
			for k in 4:
				draw_arc(Vector2(ex, 244), 27.0 - k * 5.0, PI, TAU, 16, [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN][k], 3.0, true)
		draw_rect(Rect2(ex - 38, 246, 76, 5), Color("8b5a2b"))
	# Marble floor with a glowing magic circle.
	layer(1.0)
	UI.gradient_rect(self, Rect2(-300, 282, 1600, 170), Color("2a1f44"), Color("4a3a70"))
	for row in 5:
		var y0 := 282.0 + row * row * 5.0 + row * 8.0
		var y1 := 282.0 + (row + 1) * (row + 1) * 5.0 + (row + 1) * 8.0
		for col in 30:
			if (row + col) % 2 == 0:
				var x0 := -300.0 + col * 56.0
				var k0 := (x0 - 500.0) * (0.02 * row)
				var k1 := (x0 - 500.0) * (0.02 * (row + 1))
				draw_colored_polygon(PackedVector2Array([Vector2(x0 + k0, y0), Vector2(x0 + 56 + k0, y0), Vector2(x0 + 56 + k1, y1), Vector2(x0 + k1, y1)]), Color(1, 1, 1, 0.05))
	draw_rect(Rect2(-300, 282, 1600, 3), Color(1, 1, 1, 0.12))
	var mc := Vector2(500, 318)
	for i in 3:
		draw_polyline(_closed(FighterRenderer.ellipse_pts(mc, 240.0 - i * 40.0, 28.0 - i * 5.0, 0.0, 64)), Color(1, 0.45, 0.85, 0.35 - i * 0.08), 1.5, true)
	for i in 16:
		var a := TAU * i / 16.0 + t * 0.3
		var p := mc + Vector2(cos(a) * 220.0, sin(a) * 25.0)
		draw_colored_polygon(FighterRenderer.star_pts(p, 3.5, 1.4, 4, a), Color(1, 0.7, 0.95, 0.5))
	for i in 18:
		var sx := fmod(i * 83.0 + t * 10.0, 1400.0) - 200.0
		var sy := 60.0 + fmod(i * 47.0, 220.0) + sin(t + i) * 8.0
		draw_colored_polygon(FighterRenderer.star_pts(Vector2(sx, sy), 3.0, 1.2, 4, t), Color(1, 0.85, 1, 0.3 + 0.3 * sin(t * 3.0 + i)))
	# Dust motes in light beams.
	for i in 12:
		var dx := 350.0 + fmod(i * 173.0 + t * 8.0, 300.0)
		var dy := 100.0 + fmod(i * 97.0, 180.0) + sin(t * 0.8 + i) * 10.0
		draw_circle(Vector2(dx, dy), 1.2, Color(1, 0.95, 0.8, 0.4 + 0.3 * sin(t * 2.0 + i)))
	# Ground fog/haze.
	for i in 6:
		var fx := -100.0 + i * 250.0 + sin(t * 0.25 + i) * 40.0
		var fy := 300.0 + sin(t * 0.4 + i * 1.5) * 6.0
		draw_circle(Vector2(fx, fy), 50.0 + sin(t * 0.3 + i) * 12.0, Color(0.6, 0.5, 1, 0.04))


func _bookshelf(pos: Vector2, seed: int) -> void:
	var w := 170.0
	var h := 270.0
	UI.gradient_rect(self, Rect2(pos.x - 6, pos.y - 14, w + 12, 14), Color("7a4b2a"), Color("4a2a14"))
	UI.gradient_rect(self, Rect2(pos, Vector2(w, h)), Color("5a3620"), Color("3a2010"))
	for row in 5:
		var y := pos.y + 10.0 + row * 52.0
		var bx := pos.x + 8.0
		var i := seed + row * 11
		draw_rect(Rect2(pos.x + 6, y, w - 12, 44), Color("24140a"))
		while bx < pos.x + w - 16.0:
			var bw := 7.0 + float(absi(i * 7) % 6)
			var bh := 30.0 + float(absi(i * 13) % 12)
			var col: Color = BOOKS[absi(i) % BOOKS.size()]
			if absi(i) % 9 == 0:
				draw_colored_polygon(PackedVector2Array([Vector2(bx, y + 44), Vector2(bx + bw, y + 44), Vector2(bx + bw + 8, y + 44 - bh), Vector2(bx + 8, y + 44 - bh)]), col)
				bx += bw + 8.0
			else:
				draw_rect(Rect2(bx, y + 44 - bh, bw - 1.0, bh), col)
				draw_rect(Rect2(bx, y + 44 - bh + 5, bw - 1.0, 2), col.lightened(0.4))
				draw_rect(Rect2(bx + bw - 3.0, y + 44 - bh, 2.0, bh), col.darkened(0.3))
				bx += bw
			i += 1
		draw_rect(Rect2(pos.x, y + 44, w, 8), Color("6a3e20"))
	draw_rect(Rect2(pos.x, pos.y, 6, h), Color("6a3e20"))
	draw_rect(Rect2(pos.x + w - 6, pos.y, 6, h), Color("4a2a14"))


# --- Overlays -------------------------------------------------------------------------

func _draw_vignette() -> void:
	var hw := 320.0 / cam_zoom + 20.0
	var hh := 180.0 / cam_zoom + 20.0
	var c := Vector2(cam_x, cam_y)
	var edge := Color(0.02, 0.0, 0.06, 0.45)
	var clear := Color(0.02, 0.0, 0.06, 0.0)
	UI.gradient_rect(self, Rect2(c.x - hw, c.y - hh, hw * 2.0, hh * 0.35), edge, clear)
	UI.gradient_rect(self, Rect2(c.x - hw, c.y + hh * 0.75, hw * 2.0, hh * 0.25), clear, Color(0.02, 0.0, 0.06, 0.3))
	draw_polygon(PackedVector2Array([Vector2(c.x - hw, c.y - hh), Vector2(c.x - hw * 0.7, c.y - hh), Vector2(c.x - hw * 0.7, c.y + hh), Vector2(c.x - hw, c.y + hh)]),
		PackedColorArray([edge, clear, clear, edge]))
	draw_polygon(PackedVector2Array([Vector2(c.x + hw * 0.7, c.y - hh), Vector2(c.x + hw, c.y - hh), Vector2(c.x + hw, c.y + hh), Vector2(c.x + hw * 0.7, c.y + hh)]),
		PackedColorArray([clear, edge, edge, clear]))


## MvC hyper backdrop: darken the stage and spin colored light beams behind the fighters.
func _draw_hyper_backdrop() -> void:
	var c := Vector2(cam_x, cam_y)
	draw_rect(Rect2(c.x - 500, c.y - 400, 1000, 800), Color(0.02, 0.0, 0.08, dim * 0.75))
	for i in 18:
		var a := TAU * i / 18.0 + t * 0.6
		var p1 := c + Vector2.from_angle(a - 0.07) * 700.0
		var p2 := c + Vector2.from_angle(a + 0.07) * 700.0
		draw_colored_polygon(PackedVector2Array([c, p1, p2]), Color(hyper_color, 0.16 * dim))
	for i in 30:
		var a := float(i) * 2.39996
		var r := fmod(i * 37.0 + t * 400.0, 500.0)
		var p := c + Vector2.from_angle(a) * r
		draw_line(p, p + Vector2.from_angle(a) * 30.0, Color(1, 1, 1, 0.25 * dim), 2.0)


static func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := pts.duplicate()
	out.append(pts[0])
	return out
