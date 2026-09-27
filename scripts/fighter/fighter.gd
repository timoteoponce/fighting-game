class_name Fighter
extends Node2D
## One fighter: state machine, movement, attacks and getting hit.
## All logic advances once per physics frame (60 per second) via step().

enum S { INTRO, IDLE, WALK, CROUCH, JUMP, ATTACK, BLOCK, HITSTUN, LAUNCHED, KNOCKDOWN, GETUP, WIN, KO }

const GROUND_Y := 300.0
const GRAVITY := 0.6
const LAUNCH_GRAVITY := 0.45
const MAX_HEALTH := 1000
const MAX_METER := 100.0
const JUGGLE_LIMIT := 7
const BUFFER := 6
const SCALE := 1.25

var def: CharacterDef
var index := 0
var input_source
var buf := InputBuffer.new()
var fight: Fight
var opponent: Fighter
var renderer: FighterRenderer
var input_enabled := false

var vel := Vector2.ZERO
var facing := 1
var state := S.INTRO
var sf := 0  # frames spent in the current state
var health := MAX_HEALTH
var meter := 0.0
var stun := 0
var crouching := false
var move: MoveData
var move_connected := false
var hits_done := 0
var hit_timer := 0
var chain := 0
var combo := 0  # hits taken in the current combo
var juggle := 0
var invuln := 0
var launch_window := 0
var flash := 0
var projectile: Projectile
var super_jumping := false
var ghosts: Array[FighterRenderer] = []  # MvC-style afterimages
var _ghost_next := 0


func setup(d: CharacterDef, idx: int, src, alt: bool) -> void:
	def = d
	index = idx
	input_source = src
	renderer = FighterRenderer.new()
	renderer.setup(def, alt)
	renderer.base_scale = SCALE
	add_child(renderer)


func reset_for_round(x: float, face: int) -> void:
	position = Vector2(x, GROUND_Y)
	vel = Vector2.ZERO
	facing = face
	health = MAX_HEALTH
	set_state(S.INTRO, true)
	stun = 0
	crouching = false
	move = null
	combo = 0
	juggle = 0
	invuln = 0
	launch_window = 0
	flash = 0
	projectile = null
	super_jumping = false
	for g in ghosts:
		g.visible = false
	buf.clear()
	_update_visual()


func set_state(s: S, force := false) -> void:
	if s != state or force:
		state = s
		sf = 0


func on_ground() -> bool:
	return position.y >= GROUND_Y - 0.01 and vel.y >= 0.0


func is_actionable() -> bool:
	return state in [S.IDLE, S.WALK, S.CROUCH] or (state == S.BLOCK and stun == 0)


func is_human() -> bool:
	return input_source != null and input_source.is_human()


func is_hyper_active() -> bool:
	return state == S.ATTACK and move != null and move.level == 3


func poll_input() -> void:
	var mask := 0
	if input_enabled and input_source:
		mask = input_source.sample(self)
	buf.push(mask)


## After a pause: forget old presses and treat currently held buttons as
## already held, so the menu confirm press doesn't trigger an attack.
func resync_input() -> void:
	buf.clear()
	if input_source:
		buf.hist.fill(input_source.sample(self))


func step() -> void:
	sf += 1
	if invuln > 0:
		invuln -= 1
	if flash > 0:
		flash -= 1
	if launch_window > 0:
		launch_window -= 1
	match state:
		S.IDLE, S.WALK, S.CROUCH, S.BLOCK:
			_ground_step()
		S.JUMP:
			_jump_step()
		S.ATTACK:
			_attack_step()
		S.HITSTUN:
			_hitstun_step()
		S.LAUNCHED:
			_launched_step()
		S.KNOCKDOWN:
			_knockdown_step()
		S.GETUP:
			if sf >= 14:
				_to_neutral()
				invuln = 6
		S.KO:
			_ko_step()
		S.INTRO, S.WIN:
			_idle_physics()
	_update_visual()


# --- Direction helpers -----------------------------------------------------

func _fwd() -> int:
	return Controls.RIGHT if facing > 0 else Controls.LEFT


func _back() -> int:
	return Controls.LEFT if facing > 0 else Controls.RIGHT


func _face_opponent() -> void:
	var dx := opponent.position.x - position.x
	if absf(dx) > 2.0:
		facing = 1 if dx > 0 else -1


func _threatened() -> bool:
	var dist := absf(opponent.position.x - position.x)
	if opponent.state == S.ATTACK and dist < 230:
		return true
	for p in fight.projectiles:
		if p.owner_f == opponent and absf(p.position.x - position.x) < 280:
			return true
	return false


# --- States ------------------------------------------------------------------

func _to_neutral() -> void:
	set_state(S.IDLE)
	super_jumping = false
	combo = 0
	juggle = 0
	chain = 0
	move = null
	stun = 0


func _ground_step() -> void:
	if state == S.BLOCK and stun > 0:
		stun -= 1
		vel.x *= 0.82
		position.x += vel.x
		return
	_face_opponent()
	var h := buf.current()
	if _try_special():
		return
	if launch_window > 0 and h & Controls.UP:
		_super_jump()
		return
	if h & Controls.UP:
		_jump(h)
		return
	crouching = h & Controls.DOWN != 0
	if _try_normal():
		return
	if crouching:
		vel.x = 0.0
		set_state(S.BLOCK if h & _back() and _threatened() else S.CROUCH)
	elif h & _back() and _threatened():
		vel.x = 0.0
		set_state(S.BLOCK)
	elif h & _fwd():
		vel.x = def.walk_speed * facing
		set_state(S.WALK)
	elif h & _back():
		vel.x = -def.back_speed * facing
		set_state(S.WALK)
	else:
		vel.x = 0.0
		set_state(S.IDLE)
	position.x += vel.x


func _jump(h: int) -> void:
	var dx := 0.0
	if h & _fwd():
		dx = def.jump_x * facing
	elif h & _back():
		dx = -def.jump_x * facing
	vel = Vector2(dx, def.jump_vel)
	position.y -= 1.0
	crouching = false
	set_state(S.JUMP, true)


func _super_jump() -> void:
	launch_window = 0
	chain = 0
	crouching = false
	vel = Vector2(clampf((opponent.position.x - position.x) * 0.08, -4.0, 4.0), -13.5)
	super_jumping = true
	position.y -= 1.0
	set_state(S.JUMP, true)
	Sfx.play("whoosh", 0.8)
	fight.effects.spawn("dust", position)


func _jump_step() -> void:
	if _try_normal():
		return
	if _air_physics():
		_land()


func _air_physics() -> bool:
	vel.y += GRAVITY
	position += vel
	if position.y >= GROUND_Y:
		position.y = GROUND_Y
		vel.y = 0.0
		return true
	return false


func _land() -> void:
	vel = Vector2.ZERO
	Sfx.play("land")
	fight.effects.spawn("dust", position)
	_to_neutral()


func _hitstun_step() -> void:
	stun -= 1
	vel.x *= 0.85
	position.x += vel.x
	if stun <= 0:
		_to_neutral()


func _launched_step() -> void:
	vel.y += LAUNCH_GRAVITY
	vel.x *= 0.99
	position += vel
	if position.y >= GROUND_Y:
		position.y = GROUND_Y
		vel = Vector2.ZERO
		set_state(S.KNOCKDOWN, true)
		Sfx.play("land", 0.7)
		fight.effects.spawn("dust", position)
		fight.shake = maxf(fight.shake, 3.0)


func _knockdown_step() -> void:
	vel.x *= 0.8
	position.x += vel.x
	if sf >= 36:
		set_state(S.GETUP, true)


func _ko_step() -> void:
	if position.y < GROUND_Y or vel.y < 0.0:
		vel.y += LAUNCH_GRAVITY
		position += vel
		if position.y >= GROUND_Y:
			position.y = GROUND_Y
			vel = Vector2(vel.x * 0.4, 0.0)
			fight.effects.spawn("dust", position)
			fight.shake = maxf(fight.shake, 5.0)
	else:
		vel.x *= 0.85
		position.x += vel.x


func _idle_physics() -> void:
	if position.y < GROUND_Y or vel.y < 0.0:
		if _air_physics():
			vel = Vector2.ZERO
	else:
		vel.x *= 0.8
		position.x += vel.x


# --- Attacks -----------------------------------------------------------------

func _try_normal() -> bool:
	var air := not on_ground()
	var key := ""
	var bit := 0
	if buf.pressed_within(Controls.HEAVY, BUFFER):
		bit = Controls.HEAVY
		key = "jH" if air else ("cH" if crouching else "H")
	elif buf.pressed_within(Controls.LIGHT, BUFFER):
		bit = Controls.LIGHT
		key = "jL" if air else ("cL" if crouching else "L")
	else:
		return false
	var m: MoveData = def.moves[key]
	if not _can_start(m):
		return false
	buf.consume(bit)
	_start_move(m)
	return true


func _try_special() -> bool:
	if not on_ground() or not buf.lh_combo():
		return false
	var h := buf.current()
	var key := "proj"
	if h & Controls.DOWN:
		key = "anti"
	elif h & _fwd():
		key = "rush"
	elif h & _back() and meter >= MAX_METER:
		key = "hyper"
	if key == "proj" and is_instance_valid(projectile) and not projectile.dead:
		return false
	var m: MoveData = def.moves[key]
	if not _can_start(m):
		return false
	buf.consume_combo()
	_start_move(m)
	return true


## Cancel rules: weaker attacks that connect can be cancelled into stronger
## ones (light > heavy > special > hyper). Lights chain into lights.
func _can_start(m: MoveData) -> bool:
	if state != S.ATTACK:
		return true
	var cur := move
	if not move_connected:
		# Pressing L then H a few frames apart turns the light into a special.
		return m.level >= 2 and cur.level < 2 and sf <= 3
	if sf > cur.startup + cur.active + 10:
		return false
	if m.level > cur.level:
		return true
	return m.level == 0 and cur.level == 0 and chain < 3


func _start_move(m: MoveData) -> void:
	chain = chain + 1 if state == S.ATTACK else 1
	move = m
	move_connected = false
	hits_done = 0
	hit_timer = 0
	set_state(S.ATTACK, true)
	if m.invuln > 0:
		invuln = m.invuln
	if not m.air:
		vel.x = 0.0
	z_index = 1
	opponent.z_index = 0
	Sfx.play(m.sfx)
	if m.level == 3:
		meter -= MAX_METER
		fight.on_hyper(self, m)


func _attack_step() -> void:
	var m := move
	if hit_timer > 0:
		hit_timer -= 1
	var want_up := buf.held(Controls.UP) or buf.pressed_within(Controls.UP, 10)
	if launch_window > 0 and move_connected and want_up and sf > m.startup:
		_super_jump()
		return
	if on_ground():
		crouching = buf.held(Controls.DOWN)
	if _try_special() or _try_normal():
		return
	if m.rise_vel != Vector2.ZERO and sf == m.rise_frame:
		vel = Vector2(m.rise_vel.x * facing, m.rise_vel.y)
		position.y -= 1.0
	var dashing := m.dash_speed != 0.0 and sf >= m.dash_from and sf <= m.dash_to
	if dashing:
		vel.x = m.dash_speed * facing
	if not m.projectile.is_empty() and sf == m.startup:
		fight.spawn_projectile(self, m.projectile)
	var airborne := position.y < GROUND_Y - 0.01 or vel.y < 0.0
	if airborne:
		if _air_physics() and (m.air or sf > m.startup):
			_land()
			return
	else:
		if not dashing:
			vel.x *= 0.7
		position.x += vel.x
	if sf >= m.total():
		if position.y < GROUND_Y - 0.01:
			set_state(S.JUMP, true)
			move = null
		else:
			_to_neutral()


func hitbox_world() -> Rect2:
	if state != S.ATTACK or move == null or move.hitbox.size == Vector2.ZERO:
		return Rect2()
	if sf <= move.startup or sf > move.startup + move.active:
		return Rect2()
	if hits_done >= move.hits or hit_timer > 0:
		return Rect2()
	return to_world(move.hitbox)


func hurtbox_world() -> Rect2:
	if invuln > 0:
		return Rect2()
	var r := Rect2(-24, -125, 48, 125)
	match state:
		S.KNOCKDOWN, S.GETUP, S.KO, S.INTRO, S.WIN:
			return Rect2()
		S.LAUNCHED:
			if juggle > JUGGLE_LIMIT:
				return Rect2()
			r = Rect2(-32, -108, 64, 94)
		S.ATTACK:
			if move.crouch:
				r = Rect2(-26, -88, 52, 88)
		_:
			if crouching and on_ground():
				r = Rect2(-26, -88, 52, 88)
	return to_world(r)


func to_world(r: Rect2) -> Rect2:
	var x := r.position.x if facing > 0 else -r.end.x
	return Rect2(position + Vector2(x, r.position.y), r.size)


## Called on the attacker when its attack (or projectile) connects.
func on_hit_landed(m: MoveData, blocked: bool) -> void:
	meter = minf(MAX_METER, meter + m.meter * (0.5 if blocked else 1.0))
	if state == S.ATTACK and move == m:
		move_connected = true
		hits_done += 1
		hit_timer = m.hit_interval
		if m.launch and not blocked:
			launch_window = 30


func _can_block(dir: int) -> bool:
	if not on_ground():
		return false
	if state == S.BLOCK and stun > 0:
		return true
	if not is_actionable():
		return false
	return buf.held(Controls.RIGHT if dir > 0 else Controls.LEFT)


## Called on the defender. Returns "hit", "block" or "ko".
func take_hit(m: MoveData, from_x: float) -> String:
	var dir := 1 if position.x > from_x else -1
	if is_equal_approx(position.x, from_x):
		dir = -facing
	if _can_block(dir):
		set_state(S.BLOCK)
		stun = m.blockstun
		vel.x = dir * (2.5 + m.kb.x * 0.4)
		var chip := int(m.damage * m.chip)
		health = maxi(1, health - chip)  # chip damage never KOs
		meter = minf(MAX_METER, meter + 2.0)
		return "block"
	combo = combo + 1 if state in [S.HITSTUN, S.LAUNCHED] else 1
	var scale := maxf(0.5 if m.level == 3 else 0.3, 1.0 - 0.1 * (combo - 1))
	var dmg := maxi(1, roundi(m.damage * scale))
	health = maxi(0, health - dmg)
	meter = minf(MAX_METER, meter + dmg / 18.0)
	flash = 4
	crouching = false
	move = null
	launch_window = 0
	if health == 0:
		set_state(S.KO, true)
		vel = Vector2(dir * 4.0, -9.0)
		position.y -= 1.0
		return "ko"
	var airborne := not on_ground() or state == S.LAUNCHED
	if airborne:
		juggle += 1
		if m.spike:
			vel = Vector2(dir * 2.0, 7.0)
		elif m.knockdown or m.launch:
			vel = Vector2(dir * m.kb.x, minf(m.kb.y, -3.0))
		else:
			vel = Vector2(dir * maxf(1.0, m.kb.x * 0.6), -4.5)
		set_state(S.LAUNCHED, true)
	elif m.launch or m.knockdown:
		juggle = 1
		vel = Vector2(dir * m.kb.x, m.kb.y if m.kb.y < 0.0 else -4.0)
		position.y -= 1.0
		set_state(S.LAUNCHED, true)
	else:
		stun = m.hitstun
		vel = Vector2(dir * m.kb.x, 0.0)
		set_state(S.HITSTUN, true)
	return "hit"


# --- Visuals -----------------------------------------------------------------

func _update_visual() -> void:
	renderer.facing = facing
	renderer.flash = flash
	renderer.t = buf.frame
	var tgt := _pose_target()
	renderer.update_pose(tgt[0], tgt[1])
	match state:
		S.HITSTUN, S.LAUNCHED, S.KNOCKDOWN, S.KO:
			renderer.expr = "hurt"
		S.ATTACK, S.BLOCK:
			renderer.expr = "attack"
		S.WIN:
			renderer.expr = "happy"
		_:
			renderer.expr = "normal"
	match state:
		S.ATTACK:
			renderer.prop = move.prop
			renderer.prop_t = sf
		S.WIN:
			renderer.prop = def.win_prop
		S.INTRO:
			renderer.prop = def.intro_prop
		_:
			renderer.prop = ""
	_update_ghosts()
	queue_redraw()


func _update_ghosts() -> void:
	if fight == null:
		return
	if ghosts.is_empty():
		for i in 4:
			var g := FighterRenderer.new()
			g.visible = false
			g.z_index = -1
			fight.add_child(g)
			ghosts.append(g)
	var active := (state == S.ATTACK and move != null and move.level >= 2) or (state == S.JUMP and super_jumping)
	for g in ghosts:
		if g.visible:
			g.modulate.a -= 0.06
			g.visible = g.modulate.a > 0.0
	if active and buf.frame % 3 == 0:
		var g := ghosts[_ghost_next]
		_ghost_next = (_ghost_next + 1) % ghosts.size()
		g.copy_from(renderer)
		var c: Color = renderer.colors.get("accent", Color.WHITE)
		g.modulate = Color(c.r * 0.8 + 0.3, c.g * 0.8 + 0.3, c.b * 0.8 + 0.5, 0.5)
		g.visible = true


func _pose_target() -> Array:
	var t := float(buf.frame)
	match state:
		S.IDLE:
			var b := sin(t * 0.08)
			return [def.pose("idle", {"lean": 6 + b * 2.0, "elb_f": 75 + b * 5.0, "elb_b": 95 - b * 5.0}), 0.25]
		S.WALK:
			var ph := t * 0.28 * signf(vel.x * facing)
			var s := sin(ph)
			var c := cos(ph)
			return [def.pose("idle", {
				"lean": 10, "leg_f": 8 + s * 26, "knee_f": 12 + maxf(0.0, c) * 34,
				"leg_b": -8 - s * 26, "knee_b": 12 + maxf(0.0, -c) * 34,
				"arm_f": 35 - s * 18, "arm_b": 45 + s * 18,
			}), 0.5]
		S.CROUCH:
			return [def.pose("crouch"), 0.4]
		S.BLOCK:
			return [def.pose("crouch_block" if crouching else "block"), 0.5]
		S.JUMP:
			return [def.pose("jump"), 0.3]
		S.ATTACK:
			var base := "crouch" if move.crouch else ("jump" if move.air else "idle")
			if sf <= move.startup:
				return [def.pose(base, move.pose_s), 0.55]
			var p := def.pose(base, move.pose_a)
			if move.spin != 0.0:
				var k := clampf(float(sf - move.startup) / (move.active + move.recovery * 0.6), 0.0, 1.0)
				p["rot"] = move.spin * k
				return [p, 1.0]
			return [p, 0.6]
		S.HITSTUN:
			return [def.pose("hit"), 0.6]
		S.LAUNCHED:
			return [def.pose("launched"), 0.3]
		S.KNOCKDOWN:
			return [def.pose("down"), 0.35]
		S.GETUP:
			return [def.pose("crouch"), 0.3]
		S.KO:
			return [def.pose("down" if on_ground() else "launched"), 0.3]
		S.WIN:
			var b2 := sin(t * 0.1)
			return [def.pose("win", {"lean": def.pose("win")["lean"] + b2 * 2.0}), 0.2]
		S.INTRO:
			return [def.pose("intro"), 0.2]
	return [def.pose("idle"), 0.3]


func _draw() -> void:
	# Shadow on the ground, shrinking as the fighter goes up.
	var h := GROUND_Y - position.y
	var k := clampf(1.0 - h / 300.0, 0.4, 1.0)
	draw_set_transform(Vector2(0, h + 1), 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, 26.0 * k, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
