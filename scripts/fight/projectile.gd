class_name Projectile
extends Node2D
## Projectiles and hyper attacks: soccer ball, wand spark, and one hyper look per
## character — pixel beam (Ulises), doodle dragon (Emilia), tear flood (Charlie),
## spirit wolf (Silvan). `kind` only changes the drawing; the hitbox is `size`.

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
## A ball instead of a shot: it keeps travelling after its life is up, slows
## down, and comes to rest on the floor where anyone can kick or pick it up.
var persistent := false
## A resting persistent projectile can be booted away by any attack that touches
## it. See `Fight._resolve_hits`.
var recoverable := false
var rested := false
## How much horizontal speed a rolling projectile sheds per frame. Friction is
## what stops it, so there is no frame cap to tune.
const BALL_FRICTION := 0.08


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
	persistent = spec.get("persistent", false)
	recoverable = spec.get("recoverable", false)
	vel = Vector2(float(spec.get("speed", 6.0)) * dir, 0.0)
	var hit := {
		"damage": spec.get("damage", 60), "hitstun": spec.get("hitstun", 18), "blockstun": spec.get("blockstun", 14),
		"kb": spec.get("kb", Vector2(3, 0)), "chip": spec.get("chip", 0.15), "hitstop": spec.get("hitstop", 5),
		"meter": spec.get("meter", 6.0), "level": spec.get("level", 2), "hit_interval": spec.get("interval", 0),
		"hit_sfx": spec.get("hit_sfx", "heavy"),
		# `_apply_hit` reads the flash and shake off the MoveData it is handed, and
		# for a projectile hit that is this one — so these have to be forwarded to
		# get here at all. They used to be missing, which meant every hyper that
		# authored `"flash": 5, "shake": 2.0` on its *move* was silently reading zero
		# on all ten to fourteen of its hits. A multi-hit super wants them here, on
		# the spec, not on the move: they are per hit.
		"flash": spec.get("flash", 0), "shake": spec.get("shake", 0.0),
	}
	m = MoveData.make(hit)
	if spec.get("final_knockdown", false):
		hit["knockdown"] = true
		hit["kb"] = Vector2(4.0, -8.0)
		hit["hitstop"] = 12
		# The finishing hit is the one that gets the full screen effect, so it is
		# the only one that flashes. The running hits just rumble.
		hit["flash"] = maxi(int(hit["flash"]), 3)
		hit["shake"] = maxf(float(hit["shake"]), 3.0)
		m_final = MoveData.make(hit)
	scale.x = dir
	_follow()
	var halo := Node2D.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = mat
	halo.show_behind_parent = true
	halo.draw.connect(_draw_halo.bind(halo))
	add_child(halo)


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
	elif persistent:
		_roll()
	else:
		position += vel
	if hit_timer > 0:
		hit_timer -= 1
	if not persistent and (life <= 0 or position.x < -150 or position.x > Fight.STAGE_W + 150):
		dead = true
	queue_redraw()


## A persistent projectile skims along the ground, shedding speed until it
## stops, then sits there. It is a hazard only while it is actually moving.
func _roll() -> void:
	if rested:
		return
	position.x = clampf(position.x + vel.x, _bounds().x, _bounds().y)
	# Resting height: a ball on the floor, not sunk into it. Plus a little bob
	# so a rolling ball reads as bouncing rather than sliding.
	position.y = Fighter.GROUND_Y - size.y * 0.5 - absf(sin(t * 0.4)) * 3.0
	vel.x = move_toward(vel.x, 0.0, BALL_FRICTION)
	if absf(vel.x) < 0.01:
		rest()


## A ball is played with, not scenery: it must never come to rest somewhere the
## camera has left behind, or it would be unreachable for the rest of the round.
func _bounds() -> Vector2:
	if owner_f != null and is_instance_valid(owner_f) and owner_f.fight != null:
		return owner_f.fight.view_bounds()
	return Vector2(Fight.WALL, Fight.STAGE_W - Fight.WALL)


## Stops the ball dead. It stays on the floor as a thing to kick or pick up, and
## it stops being dangerous: a static damage box on the ground is a trap, not a
## toy.
func rest() -> void:
	rested = true
	vel = Vector2.ZERO
	hits_left = 0
	hit_timer = 0
	position.x = clampf(position.x, _bounds().x, _bounds().y)
	position.y = Fighter.GROUND_Y - size.y * 0.5


## Puts a resting ball back into play. Either fighter can do this, which is what
## makes it contested: boot it at your opponent or take it back yourself.
func launch(new_dir: int, speed := 6.5) -> void:
	dir = new_dir
	scale.x = dir
	vel = Vector2(float(speed) * dir, 0.0)
	rested = false
	hits_left = 1
	hit_timer = 0
	t = 0
	position.y = Fighter.GROUND_Y - size.y * 0.5


func can_hit() -> bool:
	if dead or rested or hit_timer != 0:
		return false
	return hits_left > 0


func current_hit() -> MoveData:
	return m_final if hits_left == 1 and m_final != null else m


func register_hit() -> void:
	hits_left -= 1
	hit_timer = m.hit_interval
	if hits_left <= 0 and not anchored and not persistent:
		dead = true


# --- Drawing (local space faces right; node scale mirrors it) -----------------

## Additive glow behind the projectile.
func _draw_halo(h: Node2D) -> void:
	if rested:
		# A ball lying on the grass is not a light source.
		return
	var col: Color = {"ball": Color(1, 0.8, 0.4), "spark": Color(1, 0.4, 0.85), "beam": Color(0.5, 0.8, 1.0),
		"dragon": Color(1, 0.5, 0.9), "tears": Color(0.4, 0.7, 1.0), "bball": Color(1, 0.55, 0.2), "wolf": Color(0.55, 0.75, 1.0)}.get(kind, Color.WHITE)
	var pulse := 1.0 + 0.15 * sin(t * 0.5)
	if kind == "tears":
		h.draw_rect(Rect2(0, -size.y * 0.5, size.x * minf(1.0, t / 6.0), size.y), Color(col, 0.12))
		return
	if kind == "wolf":
		h.draw_circle(Vector2(_wolf_x(), 0), 60.0 * pulse, Color(col, 0.28), true, -1.0, true)
		h.draw_circle(Vector2(_wolf_x(), 0), 100.0 * pulse, Color(col, 0.12), true, -1.0, true)
		return
	if kind == "beam":
		var w := size.x * minf(1.0, t / 6.0)
		for i in 3:
			h.draw_rect(Rect2(0, -size.y * (0.6 + i * 0.2), w, size.y * (1.2 + i * 0.4)), Color(col, 0.12))
		return
	var r := maxf(size.x, size.y) * 0.9 * pulse
	for i in 4:
		h.draw_circle(Vector2.ZERO, r * (1.0 + i * 0.45), Color(col, 0.22 - i * 0.045), true, -1.0, true)


func _draw() -> void:
	get_child(0).queue_redraw()
	match kind:
		"ball":
			if not rested:
				for i in 4:
					draw_circle(Vector2(-10.0 - i * 7.0, 0), 7.0 - i * 1.5, Color(1, 1, 1, 0.25 - i * 0.05))
			else:
				# Contact shadow first, so the ball sits on the ground rather than
				# on top of its own shadow.
				draw_set_transform(Vector2(0, size.y * 0.5), 0.0, Vector2(1.0, 0.3))
				draw_circle(Vector2.ZERO, 9.0, Color(0, 0, 0, 0.28), true, -1.0, true)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			draw_soccer_ball(self, Vector2.ZERO, 9.0, t * 0.35 if not rested else 0.0)
		"spark":
			_draw_spark()
		"beam":
			_draw_beam()
		"dragon":
			_draw_dragon()
		"tears":
			_draw_tears()
		"bball":
			for i in 4:
				draw_circle(Vector2(-11.0 - i * 7.0, sin(t * 0.4 + i) * 2.0), 7.0 - i * 1.5, Color(1, 0.8, 0.6, 0.3 - i * 0.06))
			CharlieDef._basketball(self, Vector2(0, absf(sin(t * 0.25)) * -6.0), 10.0, t * 0.3)
		"wolf":
			_draw_wolf()


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
	# Ulises' own touch: 8-bit soccer balls riding the beam like a retro
	# sports game, bobbing on a sine as they go.
	for i in 3:
		var bx := fmod(t * 11.0 + i * size.x / 3.0, maxf(w, 1.0))
		_pixel_ball(Vector2(bx, sin(t * 0.35 + i * 2.1) * h * 0.22), 5.0)
	# Pixel text, un-mirrored.
	if w > 200:
		draw_set_transform(Vector2(w * 0.5, 7), 0.0, Vector2(dir, 1))
		UI.text(self, Vector2.ZERO, "GAME OVER", 20, Color(0.2, 0.1, 0.5), HORIZONTAL_ALIGNMENT_CENTER, 4, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## A soccer ball as chunky pixels: a 7x7 cell disc with a black pentagon patch.
func _pixel_ball(c: Vector2, cell: float) -> void:
	for gx in range(-3, 4):
		for gy in range(-3, 4):
			if gx * gx + gy * gy > 10:
				continue
			var edge := gx * gx + gy * gy > 6
			var patch := absi(gx) + absi(gy) <= 1 or (absi(gx) == 2 and absi(gy) == 2)
			var col := FighterRenderer.OUT if edge or patch else Color.WHITE
			draw_rect(Rect2(c + Vector2(gx, gy) * cell - Vector2.ONE * cell * 0.5, Vector2.ONE * cell), col)


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


## Charlie: CRYBABY FLOOD. He bawls so hard the tears become a tidal wave that
## rolls over the hitbox, basketballs bobbing in the surf.
func _draw_tears() -> void:
	var out := FighterRenderer.OUT
	var w := size.x * minf(1.0, t / 6.0)
	var h := size.y
	var fade := 1.0 if life > 10 else life / 10.0
	var rise := minf(1.0, t / 10.0) * fade
	var bottom := h * 0.5
	var surface := bottom - h * 0.85 * rise
	# Wave body: a wobbly surface curling higher at the leading edge.
	var top := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var x := w * i / float(steps)
		var curl := 18.0 * rise * smoothstep(0.6, 1.0, x / maxf(w, 1.0))
		# Near Charlie the water gushes up from the floor rather than starting
		# as a wall.
		var ramp := smoothstep(0.0, 50.0, x)
		top.append(Vector2(x, lerpf(bottom, surface - curl + sin(x * 0.06 - t * 0.4) * 5.0, ramp)))
	var body := top.duplicate()
	body.append(Vector2(w, bottom))
	body.append(Vector2(0, bottom))
	draw_colored_polygon(FighterRenderer.safe(body), Color(0.35, 0.62, 1.0, 0.85 * fade))
	# Lighter band just under the surface, then the ink line and foam on top.
	var band := PackedVector2Array()
	for q in top:
		band.append(q)
	for i in range(top.size() - 1, -1, -1):
		band.append(top[i] + Vector2(0, 10.0))
	draw_colored_polygon(FighterRenderer.safe(band), Color(0.6, 0.85, 1.0, 0.9 * fade))
	draw_polyline(top, out, 2.5, true)
	for i in range(0, top.size(), 3):
		draw_circle(top[i] + Vector2(0, -1.5), 3.0 + fmod(i * 1.7 + t * 0.3, 2.0), Color(1, 1, 1, 0.9 * fade), true, -1.0, true)
	# Big cartoon teardrops splashing up off the crest.
	for i in 5:
		var k := fmod(t * 0.05 + i * 0.2, 1.0)
		var x0 := w * (0.2 + i * 0.16)
		var p := Vector2(x0 + k * 20.0, surface - 20.0 - sin(k * PI) * 34.0)
		var drop := PackedVector2Array([p + Vector2(0, -7), p + Vector2(4.5, 1), p + Vector2(0, 5), p + Vector2(-4.5, 1)])
		draw_colored_polygon(drop, Color(0.6, 0.85, 1.0, fade))
		draw_polyline(Stage._closed(drop), out, 1.4, true)
	# Basketballs bobbing in the surf.
	for i in 2:
		var bx := w * (0.35 + i * 0.35)
		CharlieDef._basketball(self, Vector2(bx, surface + 6.0 + sin(t * 0.3 + i * 2.0) * 4.0), 9.0, t * 0.15 + i)


## Where Silvan's spirit wolf's head is: it races the length of the hitbox in
## 16 frames, then stays at the far end snapping.
func _wolf_x() -> float:
	return lerpf(20.0, size.x - 55.0, minf(1.0, t / 16.0))


## Silvan: MOON HOWL. A ghostly giant wolf-dog charges out of him, leaving
## afterimages and paw prints, howling as it goes.
func _draw_wolf() -> void:
	var fade := 1.0 if life > 10 else life / 10.0
	var hx := _wolf_x()
	var floor_y := size.y * 0.42
	# Paw prints stamped along the floor behind the charge.
	var px := 30.0
	var n := 0
	while px < hx - 30.0:
		var pp := Vector2(px, floor_y + (5.0 if n % 2 == 0 else -5.0))
		var col := Color(0.85, 0.92, 1.0, 0.55 * fade)
		draw_circle(pp, 4.0, col, true, -1.0, true)
		for tx in [-4.0, 0.0, 4.0]:
			draw_circle(pp + Vector2(tx + 4.0, -5.0 + absf(tx) * 0.3), 1.8, col, true, -1.0, true)
		px += 34.0
		n += 1
	# Afterimages, oldest first.
	for i in range(4, 0, -1):
		_wolf_head(Vector2(hx - i * 30.0, sin(t * 0.5 - i) * 3.0), 1.0 - i * 0.08, 0.14 * (5 - i) * fade)
	_wolf_head(Vector2(hx, sin(t * 0.5) * 3.0), 1.0, 0.95 * fade)


func _wolf_head(c: Vector2, sc: float, a: float) -> void:
	var fur := Color(0.78, 0.88, 1.0, a)
	var ink := Color(0.12, 0.16, 0.4, a)
	var jaw := 0.2 + 0.22 * (0.5 + 0.5 * sin(t * 0.7))
	var up := PackedVector2Array()
	for q in [Vector2(-36, 8), Vector2(-40, -6), Vector2(-50, -12), Vector2(-38, -18), Vector2(-26, -26),
			Vector2(-30, -52), Vector2(-12, -32), Vector2(-4, -50), Vector2(6, -28), Vector2(26, -20),
			Vector2(46, -12), Vector2(52, -5), Vector2(46, 2), Vector2(8, 4)]:
		up.append(c + q * sc)
	var pivot := c + Vector2(8, 4) * sc
	var low := PackedVector2Array()
	for q in [Vector2(8, 4), Vector2(42, 6), Vector2(38, 12), Vector2(10, 16), Vector2(-22, 12)]:
		low.append(pivot + (q - Vector2(8, 4)).rotated(jaw) * sc)
	# Mouth: dark red wedge between the jaws, then the teeth.
	draw_colored_polygon(PackedVector2Array([pivot, up[12], low[1]]), Color(0.5, 0.08, 0.15, a))
	for i in 3:
		var tp := c + Vector2(20 + i * 9, 2) * sc
		draw_colored_polygon(PackedVector2Array([tp, tp + Vector2(4, 0) * sc, tp + Vector2(2, 5) * sc]), Color(1, 1, 1, a))
	draw_colored_polygon(FighterRenderer.safe(low), fur)
	draw_polyline(Stage._closed(low), ink, 2.0, true)
	draw_colored_polygon(FighterRenderer.safe(up), fur)
	draw_polyline(Stage._closed(up), ink, 2.2, true)
	# Inner ears and a glowing eye.
	draw_colored_polygon(PackedVector2Array([c + Vector2(-26, -30) * sc, c + Vector2(-28, -46) * sc, c + Vector2(-16, -32) * sc]), Color(1, 0.7, 0.8, a))
	draw_circle(c + Vector2(16, -14) * sc, 4.2 * sc, Color(1, 0.9, 0.3, a), true, -1.0, true)
	draw_line(c + Vector2(16, -17) * sc, c + Vector2(16, -11) * sc, ink, 1.6, true)
	draw_circle(c + Vector2(51, -6) * sc, 2.6 * sc, ink, true, -1.0, true)
	# Howl: sound arcs pouring out of the open mouth.
	for i in 3:
		var r := (10.0 + i * 9.0 + fmod(t * 2.0, 9.0)) * sc
		draw_arc(c + Vector2(50, 4) * sc, r, -0.55, 0.55, 8, Color(1, 1, 1, a * (0.8 - i * 0.22)), 2.0, true)
