class_name Projectile
extends Node2D
## Projectiles and hyper attacks: soccer ball, wand spark, pixel beam, doodle dragon.

var owner_f: Fighter
var m: MoveData
var m_final: MoveData  # used for the last hit of a multi-hit hyper
var kind := ""
var vel := Vector2.ZERO
var size := Vector2(16, 16)
var offset := Vector2.ZERO
var life := 120
var hits_left := 1
var hit_timer := 0
var anchored := false
var strength := 1
var dir := 1
var t := 0
var dead := false


func setup(owner: Fighter, spec: Dictionary) -> void:
	owner_f = owner
	dir = owner.facing
	kind = spec["kind"]
	size = spec["size"]
	offset = spec.get("offset", Vector2.ZERO)
	life = spec.get("life", 120)
	hits_left = spec.get("hits", 1)
	anchored = spec.get("anchored", false)
	strength = spec.get("strength", 1)
	vel = Vector2(float(spec.get("speed", 6.0)) * dir, 0.0)
	var hit := {
		"damage": spec.get("damage", 60), "hitstun": spec.get("hitstun", 18), "blockstun": spec.get("blockstun", 14),
		"kb": spec.get("kb", Vector2(3, 0)), "chip": spec.get("chip", 0.15), "hitstop": spec.get("hitstop", 5),
		"meter": spec.get("meter", 6.0), "level": spec.get("level", 2), "hit_interval": spec.get("interval", 0),
		"hit_sfx": spec.get("hit_sfx", "heavy"),
	}
	m = MoveData.make(hit)
	if spec.get("final_knockdown", false):
		hit["knockdown"] = true
		hit["kb"] = Vector2(4.0, -8.0)
		hit["hitstop"] = 12
		m_final = MoveData.make(hit)
	scale.x = dir
	_follow()


func _follow() -> void:
	position = owner_f.position + Vector2(offset.x * dir, offset.y)


func rect() -> Rect2:
	if anchored:
		var w := size.x * minf(1.0, t / 6.0)
		var x0 := position.x if dir > 0 else position.x - w
		return Rect2(x0, position.y - size.y * 0.5, w, size.y)
	return Rect2(position - size * 0.5, size)


func step() -> void:
	t += 1
	life -= 1
	if anchored:
		_follow()
	else:
		position += vel
	if hit_timer > 0:
		hit_timer -= 1
	if life <= 0 or position.x < -150 or position.x > Fight.STAGE_W + 150:
		dead = true
	queue_redraw()


func can_hit() -> bool:
	return not dead and hit_timer == 0 and hits_left > 0


func current_hit() -> MoveData:
	return m_final if hits_left == 1 and m_final != null else m


func register_hit() -> void:
	hits_left -= 1
	hit_timer = m.hit_interval
	if hits_left <= 0 and not anchored:
		dead = true


# --- Drawing (local space faces right; node scale mirrors it) -----------------

func _draw() -> void:
	match kind:
		"ball":
			for i in 4:
				draw_circle(Vector2(-10.0 - i * 7.0, 0), 7.0 - i * 1.5, Color(1, 1, 1, 0.25 - i * 0.05))
			draw_soccer_ball(self, Vector2.ZERO, 9.0, t * 0.35)
		"spark":
			_draw_spark()
		"beam":
			_draw_beam()
		"dragon":
			_draw_dragon()


static func draw_soccer_ball(ci: CanvasItem, c: Vector2, r: float, rot: float) -> void:
	var out := FighterRenderer.OUT
	ci.draw_circle(c, r + 1.5, out, true, -1.0, true)
	ci.draw_circle(c, r, Color.WHITE, true, -1.0, true)
	var pent := PackedVector2Array()
	for i in 5:
		var a := rot + TAU * i / 5.0
		pent.append(c + Vector2(cos(a), sin(a)) * r * 0.38)
	ci.draw_colored_polygon(pent, out)
	for i in 5:
		var a := rot + TAU * (i + 0.5) / 5.0
		var p := c + Vector2(cos(a), sin(a)) * r * 0.82
		ci.draw_circle(p, r * 0.2, out, true, -1.0, true)
		ci.draw_line(c + Vector2(cos(a), sin(a)) * r * 0.38, p, out, 1.0, true)


func _draw_spark() -> void:
	for i in 5:
		var p := Vector2(-12.0 - i * 9.0, sin(t * 0.5 + i) * 4.0)
		draw_colored_polygon(FighterRenderer.star_pts(p, 5.0 - i * 0.8, 2.0 - i * 0.3, 4, t * 0.2), Color(1, 0.6, 0.9, 0.7 - i * 0.12))
	draw_circle(Vector2.ZERO, 14.0, Color(1, 0.5, 0.9, 0.3), true, -1.0, true)
	draw_colored_polygon(FighterRenderer.star_pts(Vector2.ZERO, 11.0, 4.5, 5, t * 0.3), Color(1, 0.55, 0.85))
	draw_colored_polygon(FighterRenderer.star_pts(Vector2.ZERO, 6.0, 2.5, 5, t * 0.3), Color.WHITE)


func _draw_beam() -> void:
	var w := size.x * minf(1.0, t / 6.0)
	var h := size.y * (1.0 if life > 10 else life / 10.0)
	var cell := 8.0
	var cols := int(w / cell)
	var rows := int(h / cell)
	for cx in cols:
		for cy in rows:
			var hue := fmod((cx + cy) * 0.07 + t * 0.05, 1.0)
			var edge := absf(cy - rows * 0.5 + 0.5) / (rows * 0.5)
			var a := 0.95 - edge * 0.5
			if (cx * 7 + cy * 3 + t) % 5 == 0:
				a *= 0.4
			draw_rect(Rect2(cx * cell, -h * 0.5 + cy * cell, cell - 1.0, cell - 1.0), Color.from_hsv(hue, 0.7, 1.0, a))
	draw_rect(Rect2(0, -h * 0.18, w, h * 0.36), Color(1, 1, 1, 0.85))
	# Pixel text, un-mirrored.
	if w > 200:
		draw_set_transform(Vector2(w * 0.5, 7), 0.0, Vector2(dir, 1))
		UI.text(self, Vector2.ZERO, "LEVEL UP!", 20, Color(0.2, 0.1, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 4, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dragon() -> void:
	var out := FighterRenderer.OUT
	var paper := Color(1, 0.98, 0.93)
	# Wavy body trailing behind the head.
	for i in range(9, 0, -1):
		var p := Vector2(-i * 11.0, sin(t * 0.25 - i * 0.7) * 10.0)
		var r := 20.0 - i * 1.5
		draw_circle(p, r + 2.0, out, true, -1.0, true)
		draw_circle(p, r, paper, true, -1.0, true)
		draw_arc(p, r * 0.6, -0.5, 0.8, 6, Color(1, 0.5, 0.75), 2.0, true)
		if i % 2 == 0:
			var spike := PackedVector2Array([p + Vector2(-5, -r + 1), p + Vector2(0, -r - 10), p + Vector2(5, -r + 1)])
			draw_colored_polygon(spike, Color(1, 0.55, 0.8))
			draw_polyline(spike, out, 1.5, true)
	# Wing.
	var flap := sin(t * 0.3) * 14.0
	var wing := PackedVector2Array([Vector2(-20, -10), Vector2(-50, -52 - flap), Vector2(-30, -40 - flap), Vector2(-14, -52 - flap), Vector2(-6, -14)])
	draw_colored_polygon(wing, Color(0.85, 0.75, 1.0))
	draw_polyline(wing + PackedVector2Array([wing[0]]), out, 2.0, true)
	# Head.
	var head := PackedVector2Array([Vector2(-10, -22), Vector2(22, -24), Vector2(46, -8), Vector2(48, 6), Vector2(20, 10), Vector2(30, 22), Vector2(4, 20), Vector2(-12, 12)])
	draw_colored_polygon(head, paper)
	draw_polyline(head + PackedVector2Array([head[0]]), out, 2.5, true)
	for hx in [0.0, 12.0]:
		var horn := PackedVector2Array([Vector2(hx, -22), Vector2(hx - 10, -40), Vector2(hx + 6, -23)])
		draw_colored_polygon(horn, Color(1, 0.85, 0.3))
		draw_polyline(horn, out, 1.8, true)
	draw_circle(Vector2(22, -10), 6.0, out, true, -1.0, true)
	draw_circle(Vector2(22, -10), 4.5, Color.WHITE, true, -1.0, true)
	draw_circle(Vector2(23.5, -9), 2.4, Color(0.5, 0.2, 0.8), true, -1.0, true)
	draw_circle(Vector2(22, -11.5), 1.0, Color.WHITE, true, -1.0, true)
	draw_line(Vector2(26, 8), Vector2(44, 4), out, 2.0, true)
	# Pencil scribbles, like a fresh sketch.
	for i in 4:
		var y := -16.0 + i * 7.0
		draw_line(Vector2(-60.0 - i * 8.0, y + sin(t * 0.4 + i) * 3.0), Vector2(-90.0 - i * 8.0, y), Color(0.3, 0.3, 0.4, 0.5), 1.5, true)
