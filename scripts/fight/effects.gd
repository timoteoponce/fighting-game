class_name Effects
extends Node2D
## Short-lived visual effects: hit sparks, block flashes, dust, comic words.

const LIFE := {"hit": 10, "heavy": 16, "block": 10, "dust": 18, "text": 34, "sparkle": 24}
const WORDS := ["POW!", "WHAM!", "BAM!", "BOOM!", "ZAP!", "KAPOW!"]

var parts: Array = []


func spawn(kind: String, pos: Vector2, data := {}) -> void:
	parts.append({"k": kind, "p": pos, "t": 0, "life": LIFE.get(kind, 12), "d": data})


func word(pos: Vector2) -> void:
	spawn("text", pos + Vector2(randf_range(-10, 10), -20), {"text": WORDS.pick_random()})


func step() -> void:
	for p in parts:
		p["t"] += 1
	parts = parts.filter(func(p: Dictionary) -> bool: return p["t"] < p["life"])
	queue_redraw()


func _draw() -> void:
	for e in parts:
		var k := float(e["t"]) / float(e["life"])
		var p: Vector2 = e["p"]
		match e["k"]:
			"hit", "heavy":
				var big := 1.6 if e["k"] == "heavy" else 1.0
				var col := Color(1, 1, 0.4).lerp(Color.WHITE, k)
				for i in 8:
					var a := TAU * i / 8.0 + 0.3
					var d := Vector2(cos(a), sin(a))
					draw_line(p + d * 4.0 * big, p + d * (8.0 + 24.0 * k) * big, col, 3.5 * (1.0 - k) + 0.5, true)
				draw_circle(p, 11.0 * (1.0 - k) * big, Color(1, 1, 1, 1.0 - k), true, -1.0, true)
				if e["k"] == "heavy":
					draw_arc(p, 10.0 + 30.0 * k, 0, TAU, 24, Color(1, 0.6, 0.2, 1.0 - k), 3.0, true)
			"block":
				var dir := float(e["d"].get("dir", 1))
				var a0 := 0.0 if dir < 0 else PI
				draw_arc(p, 8.0 + 16.0 * k, a0 - 1.1, a0 + 1.1, 12, Color(0.4, 0.8, 1.0, 1.0 - k), 4.0, true)
				draw_arc(p, 4.0 + 10.0 * k, a0 - 1.0, a0 + 1.0, 10, Color(1, 1, 1, 1.0 - k), 2.0, true)
			"dust":
				for i in 3:
					var off := Vector2((i - 1) * 12.0 * (0.5 + k), -4.0 - 6.0 * k)
					draw_circle(p + off, 5.0 + 6.0 * k, Color(0.85, 0.8, 0.75, 0.6 * (1.0 - k)), true, -1.0, true)
			"text":
				var pop := 1.0 + 0.6 * maxf(0.0, 1.0 - k * 5.0)
				var col := Color(1, 0.9, 0.2, minf(1.0, (1.0 - k) * 3.0))
				UI.text(self, p + Vector2(0, -12.0 * k), e["d"]["text"], int(18 * pop), col, HORIZONTAL_ALIGNMENT_CENTER, 6, Color(0.8, 0.1, 0.2, col.a))
			"sparkle":
				for i in 5:
					var a := TAU * i / 5.0 + float(e["t"]) * 0.1
					var q := p + Vector2(cos(a), sin(a)) * (6.0 + 20.0 * k)
					draw_colored_polygon(FighterRenderer.star_pts(q, 4.0 * (1.0 - k) + 1.0, 1.5, 4, a), Color(1, 0.7, 0.95, 1.0 - k))
