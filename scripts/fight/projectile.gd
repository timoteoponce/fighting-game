class_name Projectile
extends Node2D
## Projectiles and hyper attacks: soccer ball, wand spark, and one hyper look per
## character — pixel beam (Ulises), doodle dragon (Emilia), tear flood (Charlie),
## spirit wolf (Silvan). `kind` only changes the drawing; the hitbox is `size`.

var owner_f: Fighter
var m: MoveData
var m_final: MoveData  # used for the last hit of a multi-hit hyper
var kind := ""
## This move's palette, from the projectile spec's `"tint"`. A hyper that shares
## a `kind` with another fighter still has to look like its own, so the colour
## lives in the move rather than in the renderer. See `default_tint`.
var tint := {}
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
	tint = spec.get("tint", {})
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

## The palette for one move. `"tint"` on the projectile spec wins key by key, so
## a move can recolour the shared shapes without a new `kind`; anything it leaves
## out falls back to the per-kind default here. Sixteen hypers share seven kinds,
## so this is the only thing telling Ulises' beam from Silvan's moonlight.
const TINTS := {
	"ball": {"core": Color(1, 0.9, 0.6), "mid": Color(1, 0.8, 0.4), "edge": Color(0.8, 0.5, 0.15)},
	"spark": {"core": Color(1, 0.97, 0.93), "mid": Color(1, 0.55, 0.85), "edge": Color(0.75, 0.25, 0.6)},
	"bball": {"core": Color(1, 0.85, 0.6), "mid": Color(1, 0.55, 0.2), "edge": Color(0.6, 0.28, 0.08)},
	# The default beam is Emilia's wand light: violet-white, so it reads as magic
	# and not as a generic laser.
	"beam": {"core": Color(0.98, 0.95, 1.0), "mid": Color(0.78, 0.5, 1.0), "edge": Color(0.42, 0.18, 0.75),
		"halo": Color(0.6, 0.35, 0.95), "label": Color(0.28, 0.1, 0.55), "label_ink": Color(1, 0.97, 1.0)},
	"dragon": {"core": Color(1, 0.98, 0.93), "mid": Color(1, 0.6, 0.82), "edge": Color(0.72, 0.3, 0.6)},
	"tears": {"core": Color(0.88, 0.97, 1.0), "mid": Color(0.42, 0.72, 1.0), "edge": Color(0.16, 0.42, 0.78)},
	"wolf": {"core": Color(0.95, 0.98, 1.0), "mid": Color(0.72, 0.85, 1.0), "edge": Color(0.36, 0.5, 0.88)},
	# Emilia's drawn tiger: ink-and-wash orange, deliberately flat and papery so
	# it reads as something she sketched rather than as a real animal.
	"tiger": {"core": Color("fff3d8"), "mid": Color("f0a03c"), "edge": Color("7a3a10"),
		"ink": Color("2a1408")},
}


## `core` is the hot centre, `mid` the body, `edge` the ink-side rim, `halo` the
## additive glow behind, and `label` / `label_ink` the pixel text on a beam.
func pal(key: String) -> Color:
	var base: Dictionary = TINTS.get(kind, {})
	var v: Variant = tint.get(key, base.get(key, Color.WHITE))
	return v


## Additive glow behind the projectile.
func _draw_halo(h: Node2D) -> void:
	if rested:
		# A ball lying on the grass is not a light source.
		return
	var col: Color = pal("mid")
	var pulse := 1.0 + 0.15 * sin(t * 0.5)
	if kind == "tears":
		h.draw_rect(Rect2(0, -size.y * 0.5, size.x * minf(1.0, t / 6.0), size.y), Color(col, 0.12))
		return
	if kind == "bball":
		# Keyed off the ball, not the hitbox: the ball is a 10px sprite inside a
		# 34x40 box, and the shared halo scaled to the box was three times its size
		# and read as a brown ellipse rather than a glow.
		var br := 12.0 * pulse
		for i in 3:
			h.draw_circle(Vector2.ZERO, br * (1.0 + float(i) * 0.42), Color(col, 0.12 - float(i) * 0.032), true, -1.0, true)
		return
	if kind == "tiger":
		# A drawing, not a light. The shared glow scaled to the hitbox made a flat
		# sketch look like a lit object, and the paper wash behind it read as a
		# slab of grey, so this kind gets no halo at all — the ink and the flat
		# fill are what make it read as something she drew.
		return
	if kind == "wolf":
		# A glow behind the head, not a disc the size of the hitbox. Tight and
		# faint, with the outermost ring barely there, so it fades out instead of
		# stamping a hard circle over the stage.
		var hx := _wolf_x()
		for i in 3:
			var rr := (30.0 + float(i) * 14.0) * pulse
			h.draw_circle(Vector2(hx, 0), rr, Color(col, 0.09 - float(i) * 0.026), true, -1.0, true)
		return
	if kind == "beam":
		# A glow hugging the beam on all four sides. It has to use the same
		# orientation logic as `_draw_beam`, or a tall pillar gets a wide slab
		# beside it instead of a halo around it.
		var bw := size.x * minf(1.0, t / 6.0)
		var bh := size.y * (1.0 if life > 10 else life / 10.0)
		var pillar := size.y > size.x * 1.2
		for i in 3:
			var pad := 2.0 + float(i) * 4.0
			var alpha := 0.15 - float(i) * 0.042
			# The bar starts at x = 0, so the glow is nudged in by the same 2px
			# the body's muzzle cap is, and a pillar is centred on x = 0 instead.
			var r := Rect2(-2.0 - pad, -bh * 0.5 - pad, bw + pad * 2.0, bh + pad * 2.0) if not pillar \
				else Rect2(-bw * 0.5 - pad, -bh * 0.5 - pad, bw + pad * 2.0, bh + pad * 2.0)
			h.draw_rect(r, Color(col, alpha))
		return
	# A glow around the body itself, not around the whole hitbox: the old code
	# scaled the largest dimension by 0.9 and then again by up to 2.35, which on
	# a 200px dragon painted an opaque disc over half the screen. Keyed off the
	# smaller dimension so a big slow projectile does not get a bigger halo.
	var r := minf(size.x, size.y) * 0.5 * pulse
	for i in 4:
		h.draw_circle(Vector2.ZERO, r * (1.0 + float(i) * 0.38), Color(col, 0.13 - float(i) * 0.028), true, -1.0, true)


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
			# A tight trail behind the ball, then the ball itself. The old trail was
			# four wide flat circles that merged into one long ellipse, which at this
			# size read as a brown smear rather than as a ball in flight.
			for i in 3:
				var f := float(i)
				draw_circle(Vector2(-9.0 - i * 6.0, sin(t * 0.4 + f) * 1.6), 4.5 - f * 1.1,
					Color(1, 0.82, 0.55, 0.26 - f * 0.07))
			CharlieDef._basketball(self, Vector2(0, sin(t * 0.22) * 1.6), 10.0, t * 1.6)
		"wolf":
			_draw_wolf()
		"tiger":
			_draw_tiger()


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


## A beam, drawn as a solid bar of light rather than a field of coloured cells.
##
## It used to be a grid of 8px squares walked through an HSV hue ramp, which at
## 320x180 turned into a rainbow checkerboard: no single colour survived, the
## hitbox edge was unreadable, and the pixel text on top was illegible. A beam is
## one shape, so it is drawn as one shape — a dark ink rim, a body, a hot core
## and a few chunky energy bars — and `tint` decides the colour.
func _draw_beam() -> void:
	var w := size.x * minf(1.0, t / 6.0)
	var h := size.y * (1.0 if life > 10 else life / 10.0)
	var core: Color = pal("core")
	var mid: Color = pal("mid")
	var edge: Color = pal("edge")
	var out := FighterRenderer.OUT
	# A beam always leaves the fighter along +x (the node is mirrored by `dir`),
	# so it grows rightwards whether it is a long low bar or a tall pillar. The
	# only thing that differs is which axis is the length, and that decides
	# where the muzzle cap and the travelling bars go.
	var tall := size.y > size.x * 1.2
	var rect := Rect2(0.0, -h * 0.5, w, h) if not tall else Rect2(-w * 0.5, -h * 0.5, w, h)
	draw_rect(rect.grow(2.0), out)
	draw_rect(rect, edge)
	var inner := rect.grow(-4.0)
	draw_rect(inner, mid)
	# The hot core: a spine along the beam's length. On a narrow pillar it is a
	# vertical column, on a wide bar a horizontal one, so either orientation has
	# a bright line up the middle instead of a flat wash.
	var core_rect := Rect2(inner.position.x, -h * 0.5 + h * 0.30, inner.size.x, h * 0.40) if not tall \
		else Rect2(-w * 0.20, inner.position.y, w * 0.40, inner.size.y)
	draw_rect(core_rect, core)
	var glint := Rect2(core_rect.position.x, core_rect.position.y + core_rect.size.y * 0.24,
		core_rect.size.x, core_rect.size.y * 0.28) if not tall \
		else Rect2(core_rect.position.x + core_rect.size.x * 0.30, core_rect.position.y,
		core_rect.size.x * 0.22, core_rect.size.y)
	draw_rect(glint, Color(1, 1, 1, 0.75))
	# Chunky energy bars running outward from the muzzle. These are the only
	# motion in the shape, and at 8px they stay square. A beam thinner than a
	# couple of cells has no room for them.
	var cell := 8.0
	if inner.size.x >= cell * 2.0 and inner.size.y >= cell * 2.0:
		var along: int = maxi(1, int(w / cell)) if not tall else maxi(1, int(h / cell))
		var across: int = maxi(1, int(h / cell)) if not tall else maxi(1, int(w / cell))
		for i in along:
			var phase := fmod(t * 0.35 - float(i) * 0.22, 1.0)
			var band := int(phase * float(across))
			var fade := 0.30 * sin(phase * PI)
			if fade <= 0.01:
				continue
			var r := Rect2(i * cell, -h * 0.5 + float(band) * cell, cell - 2.0, cell - 2.0) if not tall \
				else Rect2(-w * 0.5 + float(band) * cell, -h * 0.5 + i * cell, cell - 2.0, cell - 2.0)
			if not inner.intersects(r):
				continue
			draw_rect(r, Color(core, fade))
	# A muzzle cap at the origin end, so the beam reads as leaving the fighter
	# rather than as a rectangle floating in the arena. On a tall pillar that is
	# the bottom of the shape, since the pillar rises off him.
	var cap := Rect2(-6.0, -h * 0.5 - 3.0, 10.0, h + 6.0) if not tall \
		else Rect2(-w * 0.5 - 3.0, -h * 0.5 - 5.0, w + 6.0, 10.0)
	draw_rect(cap, Color(edge, 0.9))
	var cap_in := Rect2(-4.0, -h * 0.5 - 1.0, 6.0, h + 2.0) if not tall \
		else Rect2(-w * 0.5 - 1.0, -h * 0.5 - 3.0, w + 2.0, 6.0)
	draw_rect(cap_in, core)
	# Pixel text, un-mirrored, on an ink plate so it survives any background.
	var label: String = str(tint.get("text", ""))
	if label != "" and w > 180.0:
		var tc: Color = pal("label")
		var ti: Color = tint.get("label_ink", pal("core"))
		var at := Vector2(w * 0.5, 4.0) if not tall else Vector2(0.0, -h * 0.5 - 22.0)
		draw_set_transform(at, 0.0, Vector2(dir, 1) if not tall else Vector2(1, 1))
		# `draw_string` puts `pos.y` on the *baseline* and the glyphs sit above
		# it, so the plate is sized to the cap height and centred above the
		# baseline — centring on the origin leaves it hanging below the letters.
		var box := ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
		var cap_h := box.y * 0.74
		var plate := Rect2(-box.x * 0.5 - 6.0, -cap_h - 5.0, box.x + 12.0, cap_h + 9.0)
		draw_rect(plate, Color(tc, 0.94))
		draw_rect(plate, Color(ti, 0.55), false, 1.5)
		UI.text(self, Vector2.ZERO, label, 20, ti, HORIZONTAL_ALIGNMENT_CENTER, 4, Color(0, 0, 0, 0.85))
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


## Charlie: CRYBABY FLOOD and ABSOLUTE DELUGE. He bawls so hard the tears become
## water. A wide, low hitbox is the flood that rolls over the ground; a tall one
## is the geyser, a column climbing off him. `tint` colours both.
func _draw_tears() -> void:
	if size.y > size.x * 1.2:
		_draw_geyser()
		return
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
	draw_colored_polygon(FighterRenderer.safe(body), Color(pal("mid"), 0.85 * fade))
	# Lighter band just under the surface, then the ink line and foam on top.
	var band := PackedVector2Array()
	for q in top:
		band.append(q)
	for i in range(top.size() - 1, -1, -1):
		band.append(top[i] + Vector2(0, 10.0))
	draw_colored_polygon(FighterRenderer.safe(band), Color(pal("core"), 0.55 * fade))
	draw_polyline(top, out, 2.5, true)
	for i in range(0, top.size(), 3):
		draw_circle(top[i] + Vector2(0, -1.5), 3.0 + fmod(i * 1.7 + t * 0.3, 2.0), Color(1, 1, 1, 0.9 * fade), true, -1.0, true)
	# Big cartoon teardrops splashing up off the crest.
	for i in 5:
		var k := fmod(t * 0.05 + i * 0.2, 1.0)
		var x0 := w * (0.2 + i * 0.16)
		var p := Vector2(x0 + k * 20.0, surface - 20.0 - sin(k * PI) * 34.0)
		var drop := PackedVector2Array([p + Vector2(0, -7), p + Vector2(4.5, 1), p + Vector2(0, 5), p + Vector2(-4.5, 1)])
		draw_colored_polygon(drop, Color(pal("core"), 0.9 * fade))
		draw_polyline(Stage._closed(drop), out, 1.4, true)
	# Basketballs bobbing in the surf.
	for i in 2:
		var bx := w * (0.35 + i * 0.35)
		CharlieDef._basketball(self, Vector2(bx, surface + 6.0 + sin(t * 0.3 + i * 2.0) * 4.0), 9.0, t * 0.15 + i)


## Charlie: the MAX floods, SOBBING FIT and ABSOLUTE DELUGE. The tall one is a
## column of water climbing straight off him rather than rolling along the floor,
## so it catches anything above him.
func _draw_geyser() -> void:
	var out := FighterRenderer.OUT
	var w := size.x * minf(1.0, t / 6.0)
	var h := size.y
	var fade := 1.0 if life > 10 else life / 10.0
	var rise := minf(1.0, t / 10.0) * fade
	var core: Color = pal("core")
	var mid: Color = pal("mid")
	var edge: Color = pal("edge")
	var left := -w * 0.5
	var floor_y := h * 0.5
	# Two ragged edges that wander in and out, so the column is not a rectangle.
	var steps := 14
	var lo := PackedVector2Array()
	var hi := PackedVector2Array()
	for i in steps + 1:
		var f := float(i) / float(steps)
		var y := lerpf(floor_y, floor_y - h * rise, f)
		var wob := sin(f * 7.0 - t * 0.5) * 5.0 * (0.4 + f)
		var squeeze := 1.0 - f * 0.35  # it narrows as it climbs
		lo.append(Vector2(left + w * 0.5 - w * 0.5 * squeeze + wob, y))
		hi.append(Vector2(left + w * 0.5 + w * 0.5 * squeeze + wob, y))
	var body := lo.duplicate()
	for i in range(hi.size() - 1, -1, -1):
		body.append(hi[i])
	draw_colored_polygon(FighterRenderer.safe(body), Color(mid, 0.85 * fade))
	# A bright core up the middle of the column.
	var spine := PackedVector2Array()
	for q in lo:
		spine.append(q.lerp(Vector2(left + w * 0.5, q.y), 0.28))
	for i in range(hi.size() - 1, -1, -1):
		spine.append(hi[i].lerp(Vector2(left + w * 0.5, hi[i].y), 0.28))
	draw_colored_polygon(FighterRenderer.safe(spine), Color(core, 0.5 * fade))
	# Ink down both edges, then foam where the water breaks.
	draw_polyline(lo, out, 2.5, true)
	draw_polyline(hi, out, 2.5, true)
	for i in range(0, steps, 2):
		var y := lerpf(floor_y, floor_y - h * rise, float(i) / float(steps))
		draw_circle(Vector2(left + w * 0.5 + sin(float(i) * 1.7 - t * 0.6) * 6.0, y),
			2.5 + fmod(float(i) * 0.9 + t * 0.4, 2.0), Color(core, 0.85 * fade), true, -1.0, true)
	# The plume bursting off the top.
	for i in 6:
		var k := fmod(t * 0.07 + float(i) * 0.17, 1.0)
		var p := Vector2(left + w * 0.5 + sin(float(i) * 2.3) * w * 0.45, floor_y - h * rise - 8.0 - k * 40.0)
		var drop := PackedVector2Array([p + Vector2(0, -7), p + Vector2(4.5, 1), p + Vector2(0, 5), p + Vector2(-4.5, 1)])
		draw_colored_polygon(drop, Color(core, (1.0 - k) * fade))
		draw_polyline(Stage._closed(drop), out, 1.4, true)
	# Basketballs thrown up it, spinning as they rise.
	for i in 2:
		var k := fmod(t * 0.05 + float(i) * 0.5, 1.0)
		var bx := left + w * 0.5 + sin(float(i) * 2.0 + t * 0.4) * w * 0.22
		var by := lerpf(floor_y, floor_y - h * rise - 24.0, k)
		CharlieDef._basketball(self, Vector2(bx, by), 8.0, t * 0.5 + float(i))
		draw_line(Vector2(bx, by + 8.0), Vector2(bx, by + 16.0), Color(edge, 0.5 * fade * (1.0 - k)), 2.0, true)


## Emilia: FELINE ATTACK. A tiger she drew, so it is ink and wash on paper: a
## flat orange body, hard black stripes and a scribbled outline, with a few
## frames of the sketch appearing before the ink settles.
func _draw_tiger() -> void:
	var out := FighterRenderer.OUT
	var ink: Color = pal("ink")
	var fur: Color = pal("mid")
	var paper: Color = pal("core")
	var edge: Color = pal("edge")
	# The drawing pushes in: `t` past 6 is the ink settling, before that the cat
	# is still a rough pencil shape.
	var inked := clampf((t - 3.0) / 6.0, 0.0, 1.0)
	var lung := 8.0 * (1.0 - inked)
	# Tail first, whipping behind.
	var tail := PackedVector2Array()
	for i in 9:
		var f := float(i) / 8.0
		tail.append(Vector2(-34.0 - f * 30.0, -6.0 + sin(t * 1.1 - f * 2.4) * (7.0 + f * 9.0)))
	draw_polyline(tail, edge, 7.0 - inked * 2.0, true)
	draw_polyline(tail, fur, 4.0, true)
	# Body: a stretched cat, mid-pounce.
	var body := PackedVector2Array([
		Vector2(-30, -12), Vector2(-6, -20), Vector2(18, -16), Vector2(34, -8),
		Vector2(36, 6), Vector2(16, 14), Vector2(-10, 16), Vector2(-32, 8),
	])
	draw_colored_polygon(body, fur)
	draw_polyline(body + PackedVector2Array([body[0]]), ink, 2.6, true)
	# Legs, tucked then extending.
	for lx: float in [-18.0, -2.0, 12.0]:
		var swing := sin(t * 1.6 + lx) * 5.0
		draw_line(Vector2(lx, 12), Vector2(lx + 8.0, 24.0 + swing), ink, 4.0, true)
		draw_line(Vector2(lx + 8.0, 24.0 + swing), Vector2(lx + 18.0, 22.0 + swing), fur, 3.0, true)
	# Head and muzzle.
	var head := PackedVector2Array([
		Vector2(30, -14), Vector2(44, -18), Vector2(54, -10), Vector2(52, 0),
		Vector2(38, 2), Vector2(30, -2),
	])
	draw_colored_polygon(head, paper)
	draw_polyline(head + PackedVector2Array([head[0]]), ink, 2.4, true)
	# Ears.
	for ex: float in [36.0, 46.0]:
		var ear := PackedVector2Array([Vector2(ex, -16), Vector2(ex - 3, -26), Vector2(ex + 5, -17)])
		draw_colored_polygon(ear, fur)
		draw_polyline(ear + PackedVector2Array([ear[0]]), ink, 2.0, true)
	# Stripes, and they only appear as the ink settles.
	var stripes := maxi(0, int(inked * 5.0))
	for i in stripes:
		var sx := -22.0 + float(i) * 12.0
		draw_line(Vector2(sx, -17.0), Vector2(sx - 4.0, -4.0), ink, 3.0, true)
	# Eye and a fang.
	draw_circle(Vector2(44, -8), 2.6, ink, true, -1.0, true)
	draw_circle(Vector2(45, -9), 1.0, paper, true, -1.0, true)
	if inked > 0.5:
		var fang := PackedVector2Array([Vector2(48, 0), Vector2(51, 0), Vector2(49.5, 5)])
		draw_colored_polygon(fang, paper)
		draw_polyline(fang + PackedVector2Array([fang[0]]), ink, 1.4, true)
	# Claw swipes off the front paws, and the paper it is drawn on.
	for i in 3:
		var y := -6.0 + float(i) * 8.0
		draw_line(Vector2(20, y), Vector2(52 + inked * 8.0, y - 4.0), Color(ink, 0.55), 2.0, true)


## Where Silvan's spirit wolf's head is: it races the length of the hitbox in
## 16 frames, then stays at the far end snapping.
func _wolf_x() -> float:
	return lerpf(20.0, size.x - 55.0, minf(1.0, t / 16.0))


## Silvan: a ghostly giant wolf-dog charges out of him, leaving
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
