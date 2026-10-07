class_name Fight
extends Node2D
## A match: two fighters, rounds, timer, hit detection, camera and menus.

const STAGE_W := 1000.0
const ZOOM := 1.2
## The world renders into a low-res buffer (KOF-98 style pixels), shown at an
## exact integer scale. PIXEL = buffer size / logical 640x360 screen.
const PIXEL := 0.5
const BUFFER_SIZE := Vector2i(320, 180)
const HALF_VIEW := 320.0 / ZOOM
const BASE_CAM_Y := 342.0 - 180.0 / ZOOM  # ground sits near the bottom of the screen
const WALL := 24.0
const PUSH_W := 42.0
## How hard a loose ball is booted away when an attack touches it.
const BALL_KICK_SPEED := 6.0
## How close a fighter has to be to a resting ball for a boot to reach it. A ball
## on the floor is below almost every hitbox, so proximity is the real rule.
const BALL_TOUCH := 40.0
const ROUND_FRAMES := 99 * 60
## Match rules come from Settings (autoload/settings.gd), read in _ready().
var rounds_to_win := 2
var timer_enabled := true

var fighters: Array[Fighter] = []
var projectiles: Array[Projectile] = []
var stage: Stage
var effects: Effects
var foreground: Foreground
var camera: Camera2D
var hud: Hud
var debug_draw: Node2D
var world: SubViewport  # everything in the arena lives here
var cam_z := ZOOM  # logical camera zoom (before PIXEL)

var hitstop := 0
var freeze := 0
var freeze_owner: Fighter
var cutin_text := ""
var cutin_color := Color.WHITE
## How long the world stops for a hyper. The HUD reads this to work out how far
## through the cut-in animation it is.
const HYPER_FREEZE := 56
## Frames of half-speed on the last hit of a super. `slowmo` skips every other
## sim frame, so this is about a sixth of a second.
const HYPER_CATCH_SLOWMO := 20
## How far the camera leans in while a super is on screen. A super is the one
## moment the camera should not sit on the midpoint of the two fighters.
const HYPER_ZOOM := 1.34
## KO camera: how far it pushes in, and for how many (sim) frames of the KO phase.
const KO_ZOOM := 1.75
const KO_CAM_FRAMES := 80
var slowmo := 0
var shake := 0.0
var flash := 0  # full-screen white flash frames, drawn as a flat rect by the HUD

var round_num := 1
var wins := [0, 0]
var timer := ROUND_FRAMES
var phase := "intro"  # intro, fight, ko, over
var phase_t := 0
var winner := -1
var banner := ""
var banner_t := 0

var debug := false
var paused := false
var menu_stack: Array = []  # [{title, items, idx}, ...]; empty = no menu
var stats := {}  # "character move" -> damage dealt (for balance testing)


func _ready() -> void:
	world = SubViewport.new()
	world.size = BUFFER_SIZE
	world.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	# No MSAA: anti-aliasing softens the chunky pixels this look depends on.
	world.msaa_2d = Viewport.MSAA_DISABLED
	add_child(world)
	var screen := TextureRect.new()
	screen.texture = world.get_texture()
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	screen.size = Vector2(640, 360)
	screen.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(screen)
	stage = Stage.new()
	# Stage choice: Settings first (the options screen), then the --stage
	# debug flag, then random. An unknown saved stage falls through to random.
	var stage_id := Settings.stage if Settings.stage != "" and Stage.KINDS.has(Settings.stage) else ""
	if stage_id == "":
		stage_id = GameState.stage if GameState.stage != "" else Stage.KINDS.pick_random()
	stage.kind = stage_id
	rounds_to_win = Settings.rounds_to_win
	timer_enabled = Settings.timer_enabled
	world.add_child(stage)
	var ids: Array = GameState.chars
	for i in 2:
		var f := Fighter.new()
		var src
		if GameState.mode == "vs" or (i == 0 and GameState.mode == "cpu"):
			src = PlayerInput.new(GameState.devices[i])
		else:
			src = CpuInput.new(GameState.cpu_level)
		f.setup(GameState.make_character(ids[i]), i, src, i == 1 and ids[0] == ids[1])
		f.fight = self
		world.add_child(f)
		fighters.append(f)
	fighters[0].opponent = fighters[1]
	fighters[1].opponent = fighters[0]
	# Foreground occluders: above the fighters, below the effects, so hit
	# sparks still read on top. Parallax f > 1 makes them move faster than
	# the fighters and read as close to the camera.
	foreground = Foreground.new()
	foreground.stage = stage
	foreground.kind = stage.kind
	foreground.z_index = 4
	world.add_child(foreground)
	effects = Effects.new()
	effects.z_index = 5
	world.add_child(effects)
	debug_draw = Node2D.new()
	debug_draw.z_index = 10
	debug_draw.draw.connect(_draw_debug)
	world.add_child(debug_draw)
	camera = Camera2D.new()
	camera.position = Vector2(STAGE_W * 0.5, BASE_CAM_Y)
	camera.zoom = Vector2(ZOOM, ZOOM) * PIXEL
	world.add_child(camera)
	camera.make_current()
	effects.cam = camera
	# Comic words and speech bubbles: above the arena, below the HUD, and at
	# screen resolution so the lettering stays crisp. There is no post-FX pass:
	# a fullscreen bloom resamples the 320x180 buffer with linear filtering and
	# softens exactly the pixels this look is built on.
	var comic := CanvasLayer.new()
	comic.layer = 10
	add_child(comic)
	comic.add_child(effects.ink)
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	hud = Hud.new()
	hud.fight = self
	layer.add_child(hud)
	Controls.device_changed.connect(_on_device_changed)
	start_round()


## A controller pulled out mid-round should never cost someone the match.
func _on_device_changed(dev: int, connected: bool) -> void:
	if connected or paused or phase == "over" or menu_stack.size() > 0:
		return
	for f in fighters:
		if f.input_source is PlayerInput and (f.input_source as PlayerInput).device == dev:
			_open_menu("CONTROLLER UNPLUGGED", ["RESUME", "CHARACTER SELECT", "TITLE SCREEN"])
			paused = true
			return


func start_round() -> void:
	for p in projectiles:
		p.queue_free()
	projectiles.clear()
	fighters[0].reset_for_round(STAGE_W * 0.5 - 110.0, 1)
	fighters[1].reset_for_round(STAGE_W * 0.5 + 110.0, -1)
	for f in fighters:
		f.input_enabled = false
		if GameState.debug_full_meter:
			f.meter = Fighter.MAX_METER
	timer = ROUND_FRAMES
	phase = "intro"
	phase_t = 0
	winner = -1
	hitstop = 0
	freeze = 0
	freeze_owner = null
	slowmo = 0
	stage.dim = 0.0
	var final: bool = wins[0] == rounds_to_win - 1 and wins[1] == rounds_to_win - 1
	_banner("FINAL ROUND" if final else "ROUND %d" % round_num)
	_update_camera()


func _banner(s: String) -> void:
	banner = s
	banner_t = 0


# --- Main loop ---------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if paused:
		return
	for f in fighters:
		f.poll_input()
	# START pauses in every phase (intro, fight, ko) — not just mid-fight. Only
	# when no menu is already open, so it cannot stack on the over/win menu.
	if menu_stack.is_empty():
		for f in fighters:
			if f.is_human() and f.buf.pressed_now(Controls.START):
				_open_menu("PAUSE", ["RESUME", "OPTIONS", "REMATCH", "CHARACTER SELECT", "QUIT TO TITLE"])
				paused = true
				return
	effects.step()
	banner_t += 1
	shake = maxf(0.0, shake - 0.5)
	if flash > 0:
		flash -= 1
	camera.offset = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	debug_draw.queue_redraw()
	if freeze > 0:
		freeze -= 1
		stage.dim = 1.0
		# The fighter who fired keeps performing through the cut-in, so the
		# wind-up plays into the strike instead of standing still for 56 frames.
		if freeze_owner != null:
			freeze_owner.hyper_freeze_visual()
		return
	if hitstop > 0:
		hitstop -= 1
		for f in fighters:
			f.freeze_visual()
		return
	if slowmo > 0:
		slowmo -= 1
		if slowmo % 2 == 1:
			return
	phase_t += 1
	for f in fighters:
		f.step()
	for p in projectiles:
		p.step()
	_resolve_hits()
	_resolve_bounds()
	_cleanup_projectiles()
	_update_camera()
	# One source of truth for "is a super on screen": the same helper the camera
	# uses, so the dim and the framing can never disagree.
	stage.dim = move_toward(stage.dim, 1.0 if _hyper_focus() != null else 0.0, 0.05)
	stage.cam_y = camera.position.y
	stage.cam_zoom = cam_z
	_update_phase()


func _update_phase() -> void:
	match phase:
		"intro":
			if phase_t == 70:
				_banner("FIGHT!")
				Sfx.play("confirm")
			if phase_t >= 100:
				phase = "fight"
				for f in fighters:
					f.input_enabled = true
					f.set_state(Fighter.S.IDLE, true)
					f.buf.clear()
		"fight":
			if timer > 0:
				timer -= 1
			var down := fighters.filter(func(f: Fighter) -> bool: return f.health <= 0)
			if not down.is_empty():
				_end_round("K.O.!")
				winner = -1 if down.size() == 2 else 1 - down[0].index
				slowmo = 60
				Sfx.play("ko")
			elif timer_enabled and timer == 0:
				_end_round("TIME!")
				var h0 := fighters[0].health
				var h1 := fighters[1].health
				winner = -1 if h0 == h1 else (0 if h0 > h1 else 1)
		"ko":
			if phase_t >= 90 and winner >= 0:
				var w := fighters[winner]
				if w.state != Fighter.S.WIN and w.on_ground():
					w.move = null
					w.vel = Vector2.ZERO
					w.set_state(Fighter.S.WIN, true)
					# A little stretch and a sparkle pop as they strike the pose, so
					# the win reads as a pop rather than a slide into place.
					w.renderer.squish(-0.22)
					effects.spawn("sparkle", w.position + Vector2(0, -60.0 * w.def.size))
					Sfx.voice(w.def.id, "win", w.index, w.def.voice_pitch)
			if phase_t == 100:
				_banner("DRAW!" if winner < 0 else "%s!" % fighters[winner].def.display)
			if phase_t >= 210:
				if winner >= 0:
					wins[winner] += 1
				if winner >= 0 and wins[winner] >= rounds_to_win:
					phase = "over"
					phase_t = 0
					_banner("%s WINS!" % fighters[winner].def.display)
					Sfx.play_jingle()
					_celebrate()
				else:
					round_num += 1
					start_round()
		"over":
			if phase_t == 200:
				_open_menu("", ["REMATCH", "CHARACTER SELECT", "TITLE SCREEN"])


func _end_round(text: String) -> void:
	phase = "ko"
	phase_t = 0
	_banner(text)
	for f in fighters:
		f.input_enabled = false


func on_hyper(f: Fighter, m: MoveData) -> void:
	freeze = HYPER_FREEZE
	freeze_owner = f
	cutin_text = m.display
	cutin_color = f.renderer.colors["shirt"]
	Sfx.play("hyper")
	effects.spawn("sparkle", f.position + Vector2(0, -80))
	effects.spawn("ring", f.position)
	# A three-frame punch, not a full white-out. This used to be 8, which is the
	# same value a KO gets, and it meant the cut-in artwork was hidden behind a
	# solid white screen for eight frames of the 56 it is supposed to be showing.
	flash = 3
	shake = maxf(shake, 4.0)
	stage.hyper_color = f.renderer.colors["accent"]
	# The user stretches up on the spot as the screen stops for them, and the
	# poor soul on the other side gets to look worried about it.
	f.renderer.squish(-0.26)
	f.renderer.emote("vein", 40)
	var o := f.opponent
	if o != null and o.state != Fighter.S.KO:
		o.renderer.emote("sweat", 50)
		o.renderer.eye_pop = 9
		if not o.def.hurt_lines.is_empty():
			effects.say(o.position + Vector2(0, -74.0 * o.def.size), o.def.hurt_lines[0], -o.facing, o.index)


## The finishing beat for a *melee* super. A projectile super reaches the payoff
## when its `hits_left` reaches zero; a melee super has no projectile to run
## out, so its Fighter calls this on the last frame of the active window. Only
## one thing is meant to punch the screen, and for a melee super this is it.
func hyper_finisher() -> void:
	slowmo = maxi(slowmo, HYPER_CATCH_SLOWMO)
	flash = maxi(flash, 3)
	shake = maxf(shake, 6.0)


## A throw completed: same feedback a heavy hit gets, plus a stats entry.
func on_throw(a: Fighter, d: Fighter, m: MoveData, res: String) -> void:
	var key := "%s throw" % a.def.id
	stats[key] = int(stats.get(key, 0)) + m.damage
	var point := (a.position + d.position) * 0.5 + Vector2(0, -60)
	effects.spawn("heavy", point)
	effects.word(point)
	Sfx.play(m.hit_sfx)
	hitstop = maxi(hitstop, m.hitstop)
	shake = maxf(shake, 5.0)
	if res == "ko":
		hitstop = 24
		shake = 9.0
		flash = 8


## Does this move boot a ball lying on the floor? Either it says so, or its
## hitbox reaches down to the ground. A punch at chest height leaves the ball
## where it is, so combos are never interrupted by losing it.
func _kicks(m: MoveData) -> bool:
	if m.kicks:
		return true
	return m.hitbox.size.y > 0.0 and m.hitbox.end.y >= -22.0


func spawn_projectile(f: Fighter, spec: Dictionary) -> Projectile:
	var p := Projectile.new()
	p.setup(f, spec)
	p.z_index = int(spec.get("z", 2))
	world.add_child(p)
	projectiles.append(p)
	# `slot` is the "one projectile at a time" reference, so L+H cannot be spammed.
	# An object that lives in the arena opts out.
	if spec.get("slot", true) and int(spec.get("level", 2)) < 3:
		f.projectile = p
	# An explicit "" opts out, for objects that are placed rather than fired.
	var s := String(spec.get("sfx", "special"))
	if s != "":
		Sfx.play(s)
	return p


# --- Collisions ----------------------------------------------------------------

func _resolve_hits() -> void:
	var events := []
	for i in 2:
		var a := fighters[i]
		var d := fighters[1 - i]
		var hb := a.hitbox_world()
		var hu := d.hurtbox_world()
		if hb.has_area() and hu.has_area() and hb.intersects(hu):
			events.append([a, d, a.move, hb.intersection(hu).get_center(), null])
	# A loose ball is not a hitbox, it is a thing on the floor, and it is booted
	# by a boot rather than punched. A move qualifies if it says so, or if its
	# hitbox reaches the ground — which makes every character's sweep the natural
	# way to take the ball off them. Whoever owns it, so it stays contested.
	for p in projectiles:
		if not p.rested or not p.recoverable:
			continue
		for i in 2:
			var a := fighters[i]
			if a.state != Fighter.S.ATTACK or a.move == null or not _kicks(a.move):
				continue
			if absf(a.position.x - p.position.x) > BALL_TOUCH and not a.hitbox_world().intersects(p.rect()):
				continue
			p.launch(a.facing, BALL_KICK_SPEED)
			effects.spawn("dust", p.position)
			Sfx.play("kick", 1.15)
	for p in projectiles:
		if not p.can_hit():
			continue
		var d := p.owner_f.opponent
		var hu := d.hurtbox_world()
		var r := p.rect()
		if hu.has_area() and r.has_area() and r.intersects(hu):
			events.append([p.owner_f, d, p.current_hit(), r.intersection(hu).get_center(), p])
	# Projectiles from different players cancel each other; hypers win. A
	# resting ball is scenery here, so it never cancels a fireball.
	for i in projectiles.size():
		for j in range(i + 1, projectiles.size()):
			var a := projectiles[i]
			var b := projectiles[j]
			if a.dead or b.dead or a.owner_f == b.owner_f or a.persistent or b.persistent \
					or not a.rect().intersects(b.rect()):
				continue
			if a.strength <= b.strength:
				a.dead = true
			if b.strength <= a.strength:
				b.dead = true
			effects.spawn("heavy", (a.position + b.position) * 0.5)
			Sfx.play("block", 0.7)
	for e in events:
		_apply_hit(e[0], e[1], e[2], e[3], e[4])


func _apply_hit(a: Fighter, d: Fighter, m: MoveData, point: Vector2, p: Projectile) -> void:
	var from_x := a.position.x if p == null or p.anchored else p.position.x
	var hp := d.health
	var res := d.take_hit(m, from_x)
	var key := "%s %s" % [a.def.id, m.id if p == null else p.kind]
	stats[key] = int(stats.get(key, 0)) + hp - d.health
	var blocked := res == "block"
	if p != null:
		p.register_hit()
	# `register_hit` has already decremented, so nothing left means this was the
	# last hit of the move. A hyper lands a dozen hits in a row and only the last
	# one should be treated as the event; every one of them used to slam the screen.
	var last_hit := p != null and p.hits_left <= 0
	a.on_hit_landed(m, blocked)
	if blocked:
		effects.spawn("block", point, {"dir": signf(a.position.x - d.position.x)})
		Sfx.play("block")
		hitstop = maxi(hitstop, 4)
		return
	var heavy := m.level >= 1
	# Sparks spray the way the victim is flying, so a launcher bursts upward
	# and a sweep skids along the floor. The burst grows with the combo, so a
	# long chain builds to a bigger and bigger explosion.
	var away := signf(d.position.x - a.position.x)
	var kb := Vector2(m.kb.x * (away if away != 0.0 else 1.0), m.kb.y)
	var combo_k := 1.0 + 0.12 * float(d.combo)
	effects.spawn("super" if m.level == 3 else ("heavy" if heavy else "hit"), point, {"kb": kb.angle(), "k": combo_k})
	Sfx.play(m.hit_sfx, 1.0 + 0.06 * float(d.combo))
	hitstop = maxi(hitstop, m.hitstop)
	if heavy:
		shake = maxf(shake, 3.0 + m.level + m.shake)
	# The payoff beat: the last hit of a super slows the world down for a moment,
	# so a dozen small hits resolve into one heavy landing.
	if m.level == 3 and last_hit:
		slowmo = maxi(slowmo, HYPER_CATCH_SLOWMO)
	if m.flash > 0:
		flash = maxi(flash, m.flash)
	# Big hits shake your belongings loose. One item per hit, so a long combo
	# leaves a little trail of dropped junk rather than a single explosion.
	if m.level >= 2 or (m.launch or m.knockdown) and randf() < 0.7:
		var items: Array = d.def.gag_items
		if not items.is_empty():
			effects.gag(point, items.pick_random(), away)
	# A multi-hit hyper is its own show: words only on the finishing hit, so
	# they never paper over the character's hyper art.
	var mid_hyper := p != null and m.level == 3 and p.hits_left > 0
	if mid_hyper:
		pass
	elif (m.launch or m.knockdown) and randf() < 0.6:
		effects.word(point, m.level)
	elif m.level >= 2:
		effects.word(point, m.level)
	elif randf() < 0.18:
		effects.word(point, 0)
	# The victim yelps. Rare enough that it stays funny instead of nagging.
	if m.level >= 1 and randf() < 0.3 and not d.def.hurt_lines.is_empty():
		effects.say(d.position + Vector2(0, -74.0 * d.def.size), d.def.hurt_lines.pick_random(), -d.facing, d.index)
	# Characters react to each other: a long combo gets a gloat from whoever
	# is dishing it out. Once per combo, on the 5th hit exactly.
	elif d.combo == 5 and res != "ko":
		_taunt(a)
	if res == "ko":
		hitstop = 24
		shake = 9.0
		flash = 8
		effects.word(point, 3)
		# The full yard sale: everything they own goes flying.
		for item in d.def.gag_items:
			effects.gag(point + Vector2(randf_range(-8, 8), randf_range(-14, 4)), item, away)
		_taunt(a)


## The fighter gloats in a speech bubble and puts on the smug face.
func _taunt(f: Fighter) -> void:
	if f.def.taunt_lines.is_empty():
		return
	effects.say(f.position + Vector2(0, -74.0 * f.def.size), f.def.taunt_lines.pick_random(), f.facing, f.index)
	f.renderer.emote("note", 50)


## The horizontal window the camera keeps the fighters in. Anything that has to
## stay reachable and on screen — including a ball lying on the floor — is kept
## inside it.
func view_bounds() -> Vector2:
	var cam := clampf((fighters[0].position.x + fighters[1].position.x) * 0.5, HALF_VIEW, STAGE_W - HALF_VIEW)
	return Vector2(maxf(WALL, cam - HALF_VIEW + WALL), minf(STAGE_W - WALL, cam + HALF_VIEW - WALL))


func _resolve_bounds() -> void:
	var a := fighters[0]
	var b := fighters[1]
	for pass_i in 2:
		var dx := b.position.x - a.position.x
		# A rolling fighter slips through; a throw drives both positions itself.
		var solid := a.state != Fighter.S.KO and b.state != Fighter.S.KO \
			and not a.passes_through() and not b.passes_through() \
			and a.state != Fighter.S.THROW and a.state != Fighter.S.THROWN \
			and b.state != Fighter.S.THROW and b.state != Fighter.S.THROWN
		if solid and absf(dx) < PUSH_W and absf(b.position.y - a.position.y) < 70.0:
			var s := signf(dx) if dx != 0.0 else float(a.facing)
			var push := (PUSH_W - absf(dx)) * (0.5 if pass_i == 0 else 1.0)
			if pass_i == 0:
				a.position.x -= push * s
				b.position.x += push * s
			else:
				# Someone is cornered: move whoever is further from the wall.
				var mover := b if absf(b.position.x - STAGE_W * 0.5) < absf(a.position.x - STAGE_W * 0.5) else a
				mover.position.x += push * (s if mover == b else -s)
		# Recomputed each pass, because a push can change where the camera sits.
		var vb := view_bounds()
		for f in fighters:
			f.position.x = clampf(f.position.x, vb.x, vb.y)


func _cleanup_projectiles() -> void:
	for p in projectiles:
		if p.dead:
			p.queue_free()
	projectiles = projectiles.filter(func(p: Projectile) -> bool: return not p.dead)


func _update_camera() -> void:
	var mid := (fighters[0].position.x + fighters[1].position.x) * 0.5
	camera.position.x = clampf(mid, HALF_VIEW, STAGE_W - HALF_VIEW)
	# MvC-style: zoom out and rise to keep both fighters on screen during super jumps.
	var top := minf(fighters[0].position.y, fighters[1].position.y) - 175.0
	var bottom := maxf(fighters[0].position.y, fighters[1].position.y) + 30.0
	var z := clampf(360.0 / (bottom - top), 0.85, ZOOM)
	var focus_y := (top + bottom) * 0.5
	# Hyper: lean in on whoever just fired, led slightly toward the opponent so the
	# beam has somewhere to go. A super is the one moment the camera should not be
	# parked on the midpoint of two people.
	var hf := _hyper_focus()
	if hf != null:
		mid = hf.position.x
		if hf.opponent != null:
			mid += signf(hf.opponent.position.x - mid) * 34.0
		z = maxf(z, HYPER_ZOOM)
		focus_y = hf.position.y - 46.0
	# KO punch-in: during the slow-motion the camera leans in on the loser, then
	# eases back out in time for the winner's victory pose. This one outranks the
	# hyper framing, so a super that ends the round still gets the KO camera.
	var loser := _ko_focus()
	if loser != null:
		mid = loser.position.x
		z = KO_ZOOM
		focus_y = loser.position.y - 60.0
	else:
		# Victory: the camera pushes in on the champion instead.
		var champ := _win_focus()
		if champ != null:
			mid = champ.position.x
			z = KO_ZOOM
			focus_y = champ.position.y - 70.0
	cam_z = lerpf(cam_z, z, 0.12)
	camera.zoom = Vector2(cam_z, cam_z) * PIXEL
	var base_y := 342.0 - 180.0 / cam_z
	camera.position.y = minf(base_y, focus_y)
	var x := clampf(mid, 320.0 / cam_z, STAGE_W - 320.0 / cam_z)
	# Pan rather than cut while the KO, victory or hyper camera is doing its thing.
	var easing := phase == "ko" or phase == "over" or hf != null
	camera.position.x = lerpf(camera.position.x, x, 0.18) if easing else x
	stage.cam_x = camera.position.x


## The fighter currently performing a hyper, or null. Their cut-in is the
## loudest thing on screen and the camera should follow it. Checks the move and
## then the projectile, because the two cover different halves of a super: the
## body is in its recovery while the beam is still chewing on the opponent.
func _hyper_focus() -> Fighter:
	for f in fighters:
		if f.is_hyper_active():
			return f
	for p in projectiles:
		if p.m != null and p.m.level == 3 and not p.dead:
			return p.owner_f
	return null


## The fighter the KO camera should push in on, or null. Only a clean KO
## counts: a double KO or a time-out has nobody to single out.
func _ko_focus() -> Fighter:
	if phase != "ko" or phase_t >= KO_CAM_FRAMES or winner < 0:
		return null
	var loser := fighters[1 - winner]
	return loser if loser.health <= 0 else null


## The fighter the victory camera should push in on, or null. Mirrors
## _ko_focus: only a clean win has someone to celebrate.
func _win_focus() -> Fighter:
	if phase != "over" or winner < 0:
		return null
	return fighters[winner]


## The payoff: confetti in the winner's colours, their own line in a bubble,
## and the camera pushing in on them while the loser stays down.
func _celebrate() -> void:
	if winner < 0:
		return
	var w := fighters[winner]
	var acc: Color = w.renderer.colors["accent"]
	effects.confetti(w.position + Vector2(0, -70.0 * w.def.size), [acc, acc.lightened(0.35), Color(1, 1, 1, 0.9)])
	if not w.def.win_quote.is_empty():
		effects.say(w.position, w.def.win_quote, w.facing, w.index)


# --- Menus -------------------------------------------------------------------

func _open_menu(title: String, items: Array) -> void:
	menu_stack.append({"title": title, "items": items, "idx": 0})


func _close_menu() -> void:
	if not menu_stack.is_empty():
		menu_stack.pop_back()


func _current_menu() -> Dictionary:
	if menu_stack.is_empty():
		return {}
	return menu_stack[menu_stack.size() - 1]


func _process(_delta: float) -> void:
	if menu_stack.is_empty():
		return
	var menu := _current_menu()
	var items: Array = menu["items"]
	if Controls.any_just_pressed(Controls.UP) != Controls.NONE:
		menu["idx"] = posmod(menu["idx"] - 1, items.size())
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.DOWN) != Controls.NONE:
		menu["idx"] = posmod(menu["idx"] + 1, items.size())
		Sfx.play("select")
	# Options sub-menu: LEFT/RIGHT changes values, H/BACK pops.
	if menu["title"] == "OPTIONS":
		if Controls.any_just_pressed(Controls.LEFT) != Controls.NONE:
			_options_change(-1)
		if Controls.any_just_pressed(Controls.RIGHT) != Controls.NONE:
			_options_change(1)
		if Controls.any_just_pressed(Controls.HEAVY) != Controls.NONE:
			Sfx.play("select")
			_close_menu()
			return
		if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
			if items[menu["idx"]] == "BACK":
				Sfx.play("select")
				_close_menu()
		return
	if paused and Controls.any_just_pressed(Controls.HEAVY) != Controls.NONE:
		_menu_action("RESUME")
		return
	if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
		Sfx.play("confirm")
		_menu_action(items[menu["idx"]])


## In-fight options sub-menu. LEFT/RIGHT changes the highlighted row; every
## change saves immediately (autoload/settings.gd).
func _options_change(d: int) -> void:
	var menu := _current_menu()
	var row: int = menu["idx"]
	match row:
		0:  # SFX VOLUME
			Settings.sfx_volume = clampf(Settings.sfx_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		1:  # VOICE VOLUME
			Settings.voice_volume = clampf(Settings.voice_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		2:  # MUSIC VOLUME
			Settings.music_volume = clampf(Settings.music_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		3:  # ROUNDS TO WIN
			Settings.rounds_to_win = clampi(Settings.rounds_to_win + d, 1, 3)
			Sfx.play("select")
		4:  # TIMER
			Settings.timer_enabled = not Settings.timer_enabled
			Sfx.play("select")
		5:  # STAGE
			var stages := ["", "field", "library", "rooftop", "dojo", "beach", "snow"]
			var i := stages.find(Settings.stage)
			if i < 0:
				i = 0
			i = posmod(i + d, stages.size())
			Settings.stage = stages[i]
			Sfx.play("select")
	Settings.save_settings()


func _menu_action(item: String) -> void:
	match item:
		"RESUME":
			menu_stack.clear()
			paused = false
			for f in fighters:
				f.resync_input()
		"OPTIONS":
			_open_menu("OPTIONS", ["SFX VOLUME", "VOICE VOLUME", "MUSIC VOLUME", "ROUNDS TO WIN", "TIMER", "STAGE", "BACK"])
		"REMATCH":
			menu_stack.clear()
			wins = [0, 0]
			round_num = 1
			for f in fighters:
				f.meter = 0.0
			start_round()
		"CHARACTER SELECT":
			menu_stack.clear()
			paused = false
			GameState.goto("select")
		"QUIT TO TITLE":
			menu_stack.clear()
			paused = false
			GameState.goto("title")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_F1:
		debug = not debug


func _draw_debug() -> void:
	if not debug:
		return
	for f in fighters:
		var hu := f.hurtbox_world()
		if hu.has_area():
			debug_draw.draw_rect(hu, Color(0.2, 1, 0.3, 0.9), false, 1.5)
		var hb := f.hitbox_world()
		if hb.has_area():
			debug_draw.draw_rect(hb, Color(1, 0.1, 0.1, 0.45))
		var label := "%s f%d" % [Fighter.S.keys()[f.state], f.sf]
		if f.move:
			label += " " + f.move.id
		UI.text(debug_draw, f.position + Vector2(0, -150), label, 10)
	for p in projectiles:
		debug_draw.draw_rect(p.rect(), Color(1, 0.5, 0.1, 0.4))
