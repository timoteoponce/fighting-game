class_name Effects
extends Node2D
## Short-lived visual effects. Sparks draw on an additive "glow" layer so
## overlapping light adds up to white-hot, MvC style. Comic words go on top.

const LIFE := {"hit": 12, "heavy": 18, "super": 22, "block": 12, "dust": 20, "text": 36, "sparkle": 24, "slash": 9, "ring": 18, "gag": 70, "bubble": 54, "confetti": 170}
## Impact words, graded by how hard the hit was. Keeping the silly ones on the
## small hits and the loud ones on the big hits means the screen still tells you
## something even while it is being daft.
const WORDS_LIGHT := ["POK!", "BONK!", "BIFF!", "OOF!", "BOP!", "THWIP!", "PLONK!"]
const WORDS_HEAVY := ["POW!", "WHAM!", "BAM!", "KAPOW!", "SMACK!", "CLONK!", "DOINK!"]
const WORDS_SUPER := ["KABOOM!", "MEGA POW!", "YOWZA!", "SPLAT!", "KERBLAM!", "BOOOM!"]
const WORDS := WORDS_HEAVY  # kept for older call sites
const GLOW_KINDS := ["hit", "heavy", "super", "block", "sparkle", "slash", "ring"]

## One impact word at a time, and never a new one sooner than this many frames
## after the last. A 12-hit hyper used to stack twelve words into a pile.
const WORD_GAP := 14

var parts: Array = []
var glow: Node2D
var top: Node2D  # world space, pixelated with the arena: gag props
## Screen space, sharp: impact words and speech bubbles. Text drawn inside the
## 320x180 buffer turns to mush, so `Fight` parents this to a CanvasLayer.
var ink: Node2D
## The arena camera, used to map world positions onto `ink`. Null in a bare
## Effects (identity mapping).
var cam: Camera2D


func _ready() -> void:
	glow = Node2D.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = mat
	glow.draw.connect(_draw_glow)
	add_child(glow)
	top = Node2D.new()
	top.draw.connect(_draw_top)
	add_child(top)
	ink = Node2D.new()
	ink.draw.connect(_draw_ink)


## Current on-screen zoom of the arena (screen pixels per world unit).
func _z() -> float:
	return cam.zoom.x / Fight.PIXEL if cam != null else 1.0


## Arena position -> screen position on the 640x360 overlay.
func _screen(p: Vector2) -> Vector2:
	if cam == null:
		return p
	return (p - cam.get_screen_center_position()) * _z() + Vector2(320, 180)


func spawn(kind: String, pos: Vector2, data := {}) -> void:
	data["seed"] = randi()
	parts.append({"k": kind, "p": pos, "t": 0, "life": LIFE.get(kind, 12), "d": data})


## A comic impact word, picked to match how hard the hit was.
func word(pos: Vector2, level := 1) -> void:
	var pool: Array = WORDS_LIGHT
	if level >= 3:
		pool = WORDS_SUPER
	elif level >= 1:
		pool = WORDS_HEAVY
	for e in parts:
		if e["k"] == "text" and e["t"] < WORD_GAP and int(e["d"]["level"]) >= level:
			return
	parts = parts.filter(func(e: Dictionary) -> bool: return e["k"] != "text")
	var at := pos + Vector2(randf_range(-10, 10), -24)
	# Never on top of a speech bubble: drop below it instead.
	for e in parts:
		if e["k"] == "bubble" and absf(e["p"].x - at.x) < 70.0 and absf(e["p"].y - at.y) < 34.0:
			at.y = e["p"].y + 36.0
	spawn("text", at, {"text": pool.pick_random(), "level": level})


## A speech bubble with a fighter's own line in it. `who` is the speaker's
## index: each speaker has one bubble at a time, and a bubble that would land on
## top of the other speaker's is lifted clear of it.
func say(pos: Vector2, text: String, dir := 1, who := -1) -> void:
	parts = parts.filter(func(e: Dictionary) -> bool: return not (e["k"] == "bubble" and e["d"]["who"] == who))
	var at := pos + Vector2(0, -34)
	for e in parts:
		if e["k"] == "bubble" and absf(e["p"].x - at.x) < 90.0 and absf(e["p"].y - at.y) < 26.0:
			at.y = e["p"].y - 30.0
	spawn("bubble", at, {"text": text, "dir": dir, "who": who})


## Knocks a character's belongings loose: Charlie drops a tissue, Silvan loses
## his pacifier. `item` names a shape from `_draw_gag`; anything unknown falls
## back to a spinning star, so a character can never crash the effect layer.
func gag(pos: Vector2, item: String, dir := 1) -> void:
	spawn("gag", pos, {
		"item": item, "dir": dir,
		"v": Vector2(randf_range(1.6, 4.0) * dir, randf_range(-7.5, -4.5)),
		"spin": randf_range(-0.34, 0.34),
	})


## A burst of confetti in the winner's colours. One effect, many pieces: each
## piece is computed analytically from the frame count, so there is no
## per-piece state to integrate.
func confetti(pos: Vector2, cols: Array, n := 26) -> void:
	var d := {"n": n, "g": 0.16, "x0": [], "y0": [], "vx": [], "vy": [], "rot": [], "spin": [], "w": [], "h": [], "cols": []}
	for i in n:
		d["x0"].append(pos.x + randf_range(-30.0, 30.0))
		d["y0"].append(pos.y + randf_range(-20.0, 10.0))
		d["vx"].append(randf_range(-0.5, 0.5))
		d["vy"].append(randf_range(-2.4, -0.8))
		d["rot"].append(randf_range(0.0, TAU))
		d["spin"].append(randf_range(-0.12, 0.12))
		d["w"].append(randf_range(3.0, 6.0))
		d["h"].append(randf_range(2.0, 4.0))
		d["cols"].append(cols[i % cols.size()])
	spawn("confetti", pos, d)


func step() -> void:
	for p in parts:
		p["t"] += 1
		# Gag items are the only effect with physics: they arc away, bounce once
		# off the floor and roll to a stop, like a hat knocked off in a cartoon.
		if p["k"] == "gag":
			var d: Dictionary = p["d"]
			var v: Vector2 = d["v"]
			v.y += 0.42
			var np: Vector2 = p["p"] + v
			if np.y >= Fighter.GROUND_Y and v.y > 0.0:
				np.y = Fighter.GROUND_Y
				v = Vector2(v.x * 0.55, -v.y * 0.42)
				if absf(v.y) < 1.2:
					v = Vector2(v.x * 0.6, 0.0)
			d["v"] = v
			d["spin"] = float(d["spin"]) * 0.985
			p["p"] = np
	parts = parts.filter(func(p: Dictionary) -> bool: return p["t"] < p["life"])
	queue_redraw()
	glow.queue_redraw()
	top.queue_redraw()
	ink.queue_redraw()


func _draw() -> void:
	for e in parts:
		if e["k"] != "dust":
			continue
		var k := float(e["t"]) / float(e["life"])
		var p: Vector2 = e["p"]
		for i in 4:
			var off := Vector2((i - 1.5) * 12.0 * (0.5 + k), -5.0 - 8.0 * k - (i % 2) * 4.0)
			draw_circle(p + off, 6.0 + 8.0 * k, Color(0.9, 0.85, 0.8, 0.55 * (1.0 - k)), true, -1.0, true)


func _draw_glow() -> void:
	for e in parts:
		var kind: String = e["k"]
		if not GLOW_KINDS.has(kind):
			continue
		var k := float(e["t"]) / float(e["life"])
		var fade := 1.0 - k
		var p: Vector2 = e["p"]
		var rng := RandomNumberGenerator.new()
		rng.seed = e["d"]["seed"]
		# Combo scale: hits land harder the longer the chain, so the burst grows.
		var ck: float = float(e["d"].get("k", 1.0))
		match kind:
			"hit", "heavy", "super":
				var big: float = {"hit": 1.0, "heavy": 1.6, "super": 2.1}[kind] * ck
				var col: Color = {"hit": Color(1, 0.7, 0.25), "heavy": Color(1, 0.5, 0.15), "super": Color(1, 0.35, 0.8)}[kind]
				# White-hot core.
				glow.draw_circle(p, 16.0 * big * (1.0 - k * 0.7), Color(col, 0.35 * fade), true, -1.0, true)
				glow.draw_circle(p, 9.0 * big * fade, Color(1, 1, 1, 0.9 * fade), true, -1.0, true)
				# Tapered rays.
				# Most rays spray along the knockback angle when the hit supplies
				# one; a few stay random so it still reads as a burst.
				var kb = e["d"].get("kb")
				for i in 12:
					var a := rng.randf() * TAU
					if kb != null and i < 8:
						a = float(kb) + rng.randf_range(-0.8, 0.8)
					var len := (14.0 + rng.randf() * 34.0) * big * (0.4 + k)
					var w := (2.0 + rng.randf() * 3.0) * big * fade
					var d := Vector2.from_angle(a)
					var n := Vector2(-d.y, d.x)
					var b := p + d * (5.0 * big)
					glow.draw_colored_polygon(PackedVector2Array([b + n * w, p + d * len, b - n * w]), Color(col.lightened(0.3), 0.9 * fade))
				glow.draw_arc(p, (8.0 + 36.0 * k) * big, 0, TAU, 32, Color(col, 0.8 * fade), 3.0 * big * fade + 0.5, true)
				if kind != "hit":
					# Long flare streaks.
					var a2 := rng.randf() * PI
					for sgn in [-1.0, 1.0]:
						var d2: Vector2 = Vector2.from_angle(a2) * sgn
						glow.draw_line(p, p + d2 * 70.0 * big * (0.3 + k), Color(1, 1, 1, 0.6 * fade), 2.0 * fade + 0.5, true)
			"block":
				var dir := float(e["d"].get("dir", 1))
				var hex := PackedVector2Array()
				for i in 7:
					hex.append(p + Vector2.from_angle(TAU * i / 6.0 + 0.5) * Vector2(0.55, 1.0) * (14.0 + 16.0 * k))
				glow.draw_polyline(hex, Color(0.3, 0.7, 1.0, 0.9 * fade), 3.0, true)
				glow.draw_circle(p, 10.0 * fade, Color(0.5, 0.8, 1.0, 0.6 * fade), true, -1.0, true)
				for i in 6:
					var a := PI * (0.0 if dir < 0 else 1.0) + rng.randf_range(-1.2, 1.2)
					glow.draw_line(p, p + Vector2.from_angle(a) * (10.0 + 26.0 * k), Color(0.7, 0.9, 1.0, fade), 2.0, true)
			"slash":
				# Crescent swoosh along the attack, opening in the facing direction.
				var dir := float(e["d"].get("dir", 1))
				var r := float(e["d"].get("r", 30.0)) * (0.8 + 0.4 * k)
				var a0 := -1.3 if dir > 0 else PI - 1.3
				var outer := PackedVector2Array()
				var inner := PackedVector2Array()
				for i in 13:
					var a := a0 + 2.6 * i / 12.0
					outer.append(p + Vector2.from_angle(a) * Vector2(r, r * 0.8))
					inner.append(p + Vector2.from_angle(a) * Vector2(r * 0.72, r * 0.5) + Vector2(-dir * 4.0, 0))
				inner.reverse()
				outer.append_array(inner)
				glow.draw_colored_polygon(FighterRenderer.safe(outer), Color(0.75, 0.9, 1.0, 0.55 * fade))
			"ring":
				glow.draw_polyline(Stage._closed(FighterRenderer.ellipse_pts(p, 20.0 + 70.0 * k, 5.0 + 12.0 * k, 0.0, 32)), Color(1, 0.9, 0.7, 0.7 * fade), 3.0 * fade + 0.5, true)
			"sparkle":
				for i in 6:
					var a := TAU * i / 6.0 + float(e["t"]) * 0.1
					var q := p + Vector2(cos(a), sin(a)) * (8.0 + 28.0 * k)
					glow.draw_colored_polygon(FighterRenderer.star_pts(q, 5.0 * fade + 1.0, 1.8, 4, a), Color(1, 0.6, 0.9, fade))


func _draw_top() -> void:
	for e in parts:
		if e["k"] == "gag":
			_draw_gag(e)
		elif e["k"] == "confetti":
			_draw_confetti(e)


func _draw_ink() -> void:
	for e in parts:
		match e["k"]:
			"text": _draw_word(e)
			"bubble": _draw_bubble(e)


## A comic impact word sitting on a jagged starburst, like a 60s TV punch card.
## Drawn in screen space, so sizes are world sizes times the camera zoom.
func _draw_word(e: Dictionary) -> void:
	var k := float(e["t"]) / float(e["life"])
	var level := int(e["d"].get("level", 1))
	var z := _z()
	# Overshoot then settle: the word snaps out too big and springs back.
	var pop := 1.0 + 0.5 * maxf(0.0, 1.0 - k * 6.0)
	var a := minf(1.0, (1.0 - k) * 3.0)
	var txt: String = e["d"]["text"]
	var size := int((16 + level * 3) * pop * z)
	var font := UI.arcade_font()
	var rng := RandomNumberGenerator.new()
	rng.seed = e["d"]["seed"]
	var tilt := rng.randf_range(-0.12, 0.12)
	var at := _screen(e["p"] + Vector2(0, -10.0 * k))
	var c := at + Vector2(0, -size * 0.36)
	var half_w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * 0.5
	# Burst: a ragged star sized to the word, so long words never spill out.
	var rx := half_w + size * 0.55
	var ry := size * 0.95
	var pts := PackedVector2Array()
	var spikes := 14
	for i in spikes * 2:
		var ang := TAU * i / float(spikes * 2) + tilt
		var r := (1.0 if i % 2 == 0 else 0.74) * (0.94 + rng.randf() * 0.12)
		pts.append(c + Vector2(cos(ang) * rx, sin(ang) * ry) * r)
	var burst: Color = [Color(1, 0.95, 0.5), Color(1, 0.7, 0.25), Color(1, 0.45, 0.6), Color(0.6, 0.85, 1)][mini(level, 3)]
	ink.draw_colored_polygon(pts, Color(burst, 0.92 * a))
	ink.draw_polyline(Stage._closed(pts), Color(0.12, 0.08, 0.16, a), 2.5, true)
	UI.text(ink, at, txt, size, Color(1, 0.98, 0.9, a),
		HORIZONTAL_ALIGNMENT_CENTER, maxi(3, size / 5), Color(0.75, 0.08, 0.2, a), font)


## Speech bubble with a tail pointing down at whoever said it. Drawn as an ink
## silhouette with a paper fill on top, so the outline is one clean line all
## the way round the body and the tail.
func _draw_bubble(e: Dictionary) -> void:
	var k := float(e["t"]) / float(e["life"])
	var a := minf(1.0, (1.0 - k) * 4.0)
	var grow := _back_out(minf(1.0, e["t"] / 6.0))
	var z := _z()
	var dir := float(e["d"].get("dir", 1))
	var txt: String = e["d"]["text"]
	var size := int(12 * z)
	var font := UI.arcade_font()
	var c := _screen(e["p"] + Vector2(0, -6.0 * k))
	var rx := (font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * 0.5 + 9.0 * z) * grow
	var ry := size * 0.95 * grow
	if rx < 1.0:
		return
	var ink_col := Color(0.12, 0.08, 0.16, a)
	var paper := Color(1, 1, 0.97, a)
	var tail := PackedVector2Array([
		c + Vector2(dir * rx * 0.1 - 5.0 * z, ry * 0.6),
		c + Vector2(dir * rx * 0.5, ry + 11.0 * z * grow),
		c + Vector2(dir * rx * 0.1 + 5.0 * z, ry * 0.6),
	])
	ink.draw_colored_polygon(FighterRenderer.ellipse_pts(c, rx + 2.0, ry + 2.0, 0.0, 32), ink_col)
	ink.draw_polyline(Stage._closed(tail), ink_col, 4.0, true)
	ink.draw_colored_polygon(tail, ink_col)
	ink.draw_colored_polygon(FighterRenderer.ellipse_pts(c, rx, ry, 0.0, 32), paper)
	ink.draw_colored_polygon(tail, paper)
	if grow > 0.8:
		UI.text(ink, c + Vector2(0, size * 0.36), txt, size, ink_col, HORIZONTAL_ALIGNMENT_CENTER, 0, Color.TRANSPARENT, font)


## Confetti: small tumbling rectangles that settle on the floor. Drawn in world
## space so it pixelates with the arena, like the gag props.
func _draw_confetti(e: Dictionary) -> void:
	var d: Dictionary = e["d"]
	var n: int = d["n"]
	var t := float(e["t"])
	var g: float = d["g"]
	for i in n:
		var x: float = float(d["x0"][i]) + float(d["vx"][i]) * t
		var y: float = float(d["y0"][i]) + float(d["vy"][i]) * t + 0.5 * g * t * t
		if y > Fighter.GROUND_Y:
			y = Fighter.GROUND_Y
		top.draw_set_transform(Vector2(x, y), float(d["rot"][i]) + float(d["spin"][i]) * t, Vector2.ONE)
		var w: float = float(d["w"][i])
		var h: float = float(d["h"][i])
		var col: Color = d["cols"][i]
		top.draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h), col)
		top.draw_rect(Rect2(-w * 0.5, -h * 0.5, w, h * 0.4), col.lightened(0.25))
	top.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Ease-out with a little overshoot, for things that pop into place.
static func _back_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0) - 1.0
	return 1.0 + x * x * (2.7 * x + 1.7)


## Belongings knocked loose. Each item is a few primitives — the point is that
## you recognise *whose* it is in the half second it is on screen.
func _draw_gag(e: Dictionary) -> void:
	var k := float(e["t"]) / float(e["life"])
	var a := minf(1.0, (1.0 - k) * 4.0)
	var p: Vector2 = e["p"]
	var ang := float(e["t"]) * float(e["d"].get("spin", 0.2))
	var item: String = e["d"].get("item", "star")
	top.draw_set_transform(p, ang, Vector2.ONE)
	var ink := Color(0.12, 0.08, 0.16, a)
	match item:
		"pacifier":
			top.draw_circle(Vector2(0, 2), 6.0, Color(1, 0.75, 0.85, a), true, -1.0, true)
			top.draw_arc(Vector2(0, 2), 6.0, 0, TAU, 16, ink, 1.5, true)
			top.draw_circle(Vector2(0, -4), 3.0, Color(1, 0.95, 0.85, a), true, -1.0, true)
			top.draw_arc(Vector2(0, 8), 4.0, PI, TAU, 10, ink, 1.5, true)
		"bone":
			top.draw_line(Vector2(-6, 0), Vector2(6, 0), Color(1, 0.98, 0.9, a), 4.0, true)
			for sx in [-6.0, 6.0]:
				top.draw_circle(Vector2(sx, -2.5), 3.0, Color(1, 0.98, 0.9, a), true, -1.0, true)
				top.draw_circle(Vector2(sx, 2.5), 3.0, Color(1, 0.98, 0.9, a), true, -1.0, true)
		"tissue":
			# A crumpled, used tissue. Gross, which is the point.
			var tis := PackedVector2Array([Vector2(-6, -3), Vector2(-2, -7), Vector2(3, -5), Vector2(7, -1),
				Vector2(4, 5), Vector2(-1, 6), Vector2(-6, 3)])
			top.draw_colored_polygon(tis, Color(0.98, 0.98, 1.0, a))
			top.draw_polyline(Stage._closed(tis), ink, 1.2, true)
			top.draw_line(Vector2(-3, -2), Vector2(2, 1), Color(0.7, 0.75, 0.85, a), 1.0, true)
		"ball":
			top.draw_circle(Vector2.ZERO, 6.0, Color(0.95, 0.45, 0.15, a), true, -1.0, true)
			top.draw_arc(Vector2.ZERO, 6.0, 0, TAU, 16, ink, 1.2, true)
			top.draw_line(Vector2(-6, 0), Vector2(6, 0), ink, 1.2, true)
			top.draw_line(Vector2(0, -6), Vector2(0, 6), ink, 1.2, true)
		"pencil":
			top.draw_colored_polygon(PackedVector2Array([Vector2(-9, -2), Vector2(5, -2), Vector2(5, 2), Vector2(-9, 2)]), Color(1, 0.8, 0.2, a))
			top.draw_colored_polygon(PackedVector2Array([Vector2(5, -2), Vector2(10, 0), Vector2(5, 2)]), Color(0.95, 0.85, 0.7, a))
			top.draw_colored_polygon(PackedVector2Array([Vector2(-11, -2), Vector2(-9, -2), Vector2(-9, 2), Vector2(-11, 2)]), Color(1, 0.5, 0.6, a))
		"tooth":
			top.draw_colored_polygon(PackedVector2Array([Vector2(-4, -5), Vector2(4, -5), Vector2(3, 3), Vector2(0, 0), Vector2(-3, 3)]), Color(1, 1, 0.95, a))
			top.draw_polyline(Stage._closed(PackedVector2Array([Vector2(-4, -5), Vector2(4, -5), Vector2(3, 3), Vector2(0, 0), Vector2(-3, 3)])), ink, 1.2, true)
		"note":
			top.draw_circle(Vector2(-3, 4), 3.5, Color(0.2, 0.15, 0.3, a), true, -1.0, true)
			top.draw_line(Vector2(0, 4), Vector2(0, -7), Color(0.2, 0.15, 0.3, a), 1.8, true)
			top.draw_line(Vector2(0, -7), Vector2(6, -9), Color(0.2, 0.15, 0.3, a), 1.8, true)
		_:
			top.draw_colored_polygon(FighterRenderer.star_pts(Vector2.ZERO, 7.0, 3.0, 5, 0.0), Color(1, 0.9, 0.3, a))
	top.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
