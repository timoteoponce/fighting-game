class_name Effects
extends Node2D
## Short-lived visual effects. Sparks draw on an additive "glow" layer so
## overlapping light adds up to white-hot, MvC style. Comic words go on top.

const LIFE := {"hit": 12, "heavy": 18, "super": 22, "block": 12, "dust": 20, "text": 36, "sparkle": 24}
const WORDS := ["POW!", "WHAM!", "BAM!", "BOOM!", "ZAP!", "KAPOW!"]
const GLOW_KINDS := ["hit", "heavy", "super", "block", "sparkle"]

var parts: Array = []
var glow: Node2D
var top: Node2D


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


func spawn(kind: String, pos: Vector2, data := {}) -> void:
	data["seed"] = randi()
	parts.append({"k": kind, "p": pos, "t": 0, "life": LIFE.get(kind, 12), "d": data})


func word(pos: Vector2) -> void:
	spawn("text", pos + Vector2(randf_range(-10, 10), -24), {"text": WORDS.pick_random()})


func step() -> void:
	for p in parts:
		p["t"] += 1
	parts = parts.filter(func(p: Dictionary) -> bool: return p["t"] < p["life"])
	queue_redraw()
	glow.queue_redraw()
	top.queue_redraw()


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
		match kind:
			"hit", "heavy", "super":
				var big: float = {"hit": 1.0, "heavy": 1.6, "super": 2.1}[kind]
				var col: Color = {"hit": Color(1, 0.7, 0.25), "heavy": Color(1, 0.5, 0.15), "super": Color(1, 0.35, 0.8)}[kind]
				# White-hot core.
				glow.draw_circle(p, 16.0 * big * (1.0 - k * 0.7), Color(col, 0.35 * fade), true, -1.0, true)
				glow.draw_circle(p, 9.0 * big * fade, Color(1, 1, 1, 0.9 * fade), true, -1.0, true)
				# Tapered rays.
				for i in 12:
					var a := rng.randf() * TAU
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
			"sparkle":
				for i in 6:
					var a := TAU * i / 6.0 + float(e["t"]) * 0.1
					var q := p + Vector2(cos(a), sin(a)) * (8.0 + 28.0 * k)
					glow.draw_colored_polygon(FighterRenderer.star_pts(q, 5.0 * fade + 1.0, 1.8, 4, a), Color(1, 0.6, 0.9, fade))


func _draw_top() -> void:
	for e in parts:
		if e["k"] != "text":
			continue
		var k := float(e["t"]) / float(e["life"])
		var p: Vector2 = e["p"]
		var pop := 1.0 + 0.7 * maxf(0.0, 1.0 - k * 5.0)
		var a := minf(1.0, (1.0 - k) * 3.0)
		UI.text(top, p + Vector2(0, -14.0 * k), e["d"]["text"], int(20 * pop), Color(1, 0.92, 0.25, a),
			HORIZONTAL_ALIGNMENT_CENTER, 7, Color(0.75, 0.08, 0.2, a), UI.arcade_font())
