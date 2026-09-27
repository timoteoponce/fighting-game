class_name Fighter
extends Node2D
## One fighter: state machine, movement, attacks and getting hit.
## All logic advances once per physics frame (60 per second) via step().

enum S { INTRO, IDLE, WALK, CROUCH, JUMP, ATTACK, BLOCK, HITSTUN, LAUNCHED, KNOCKDOWN, GETUP, WIN, KO,
	DASH, BACKDASH, THROW, THROWN }

const GROUND_Y := 300.0
const GRAVITY := 0.6
const LAUNCH_GRAVITY := 0.45
const MAX_HEALTH := 1000
const MAX_METER := 300.0  # three hyper levels, like MvC
const HYPER_COST := 100.0
const JUGGLE_LIMIT := 7
const BUFFER := 6
const SCALE := 1.25

## Forward dash doubles as a KOF-style roll: it passes through the opponent and
## is invulnerable through the middle, so it is both movement and an escape.
const DASH_FRAMES := 20
const DASH_SPEED := 8.0
const ROLL_INVULN_FROM := 4
const ROLL_INVULN_FRAMES := 10
const DASH_CANCEL_FROM := 5  # attacks and jumps become available here
## Backdash retreats with a short invulnerable startup: the panic button.
const BACKDASH_FRAMES := 22
const BACKDASH_SPEED := 8.5
const BACKDASH_INVULN := 6
## One air dash and one extra jump per trip into the air.
const AIR_DASH_SPEED := 8.5
const AIR_DASH_FRAMES := 12  # gravity is suspended for this long
const AIR_JUMP_VEL := -9.0
## Throws: L+H while touching a grounded opponent. Unblockable, but breakable
## by pressing L+H back within the break window, so it never feels unfair.
const THROW_RANGE := 66.0
const THROW_HOLD := 16
const THROW_BREAK_WINDOW := 10
## Earliest frame a knocked-down fighter may tap to rise early (of 36).
const QUICK_RISE_FROM := 10

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
var land_timer := 0  # frames of landing squash (visual only)
var hit_variant := 0
var contact := 0  # frames of impact emphasis after a hit lands (visual only)
var shook := 0  # frames of hit-reaction jitter (visual only)
var super_jumping := false
var air_jumps := 0  # extra jumps left before touching the ground
var air_dashes := 0  # air dashes left before touching the ground
var air_dash_timer := 0  # frames of suspended gravity during an air dash
var ghosts: Array[FighterRenderer] = []  # MvC-style afterimages
var _ghost_next := 0


func setup(d: CharacterDef, idx: int, src, alt: bool) -> void:
	def = d
	index = idx
	input_source = src
	renderer = FighterRenderer.new()
	renderer.setup(def, alt)
	renderer.base_scale = SCALE * def.size
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
	contact = 0
	shook = 0
	air_jumps = 0
	air_dashes = 0
	air_dash_timer = 0
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
	if contact > 0:
		contact -= 1
	if shook > 0:
		shook -= 1
	if launch_window > 0:
		launch_window -= 1
	match state:
		S.IDLE, S.WALK, S.CROUCH, S.BLOCK:
			_ground_step()
		S.JUMP:
			_jump_step()
		S.DASH, S.BACKDASH:
			_dash_step()
		S.THROW:
			_throw_step()
		S.THROWN:
			_thrown_step()
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


## Called by Fight during hitstop, when the simulation is deliberately frozen.
## Nothing about the fight advances — only the impact jitter, so a held frame
## still reads as a hard hit instead of a stutter.
func freeze_visual() -> void:
	if shook > 0:
		shook -= 1
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
		if position.y < GROUND_Y - 0.01:
			# Air block: keep falling while guarding instead of hovering.
			vel.x *= 0.9
			if _air_physics():
				_land()
			elif stun <= 0:
				set_state(S.JUMP, true)
			return
		vel.x *= 0.82
		position.x += vel.x
		return
	_face_opponent()
	var h := buf.current()
	if _try_throw():
		return
	if _try_special():
		return
	if _try_dash():
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
	air_jumps = 1
	air_dashes = 1
	air_dash_timer = 0
	# Crouch-then-spring: a hard stretch on the way up is half of what sells a
	# cartoon jump. The other half is the squash on landing.
	renderer.squish(-0.30)
	# Spend the press, or holding Up would immediately burn the double jump.
	buf.consume(Controls.UP)
	set_state(S.JUMP, true)


# --- Dashes, rolls and air movement ------------------------------------------

## Double-tap forward or back on the ground. Forward is also the roll.
func _try_dash() -> bool:
	for bit: int in [_fwd(), _back()]:
		if not buf.double_tapped(bit):
			continue
		buf.consume_tap(bit)
		var back := bit == _back()
		vel.x = 0.0
		set_state(S.BACKDASH if back else S.DASH, true)
		if back:
			invuln = BACKDASH_INVULN
		Sfx.play("whoosh", 1.15 if back else 0.95)
		fight.effects.spawn("dust", Vector2(position.x, GROUND_Y))
		return true
	return false


func _dash_step() -> void:
	var back := state == S.BACKDASH
	var total := BACKDASH_FRAMES if back else DASH_FRAMES
	if not back:
		# The roll is invulnerable through its middle, not its edges.
		if sf == ROLL_INVULN_FROM:
			invuln = ROLL_INVULN_FRAMES
		if sf >= DASH_CANCEL_FROM:
			if _try_throw() or _try_special() or _try_normal():
				return
			if buf.held(Controls.UP):
				_jump(buf.current())
				return
	# Ease out, so the dash starts snappy and settles instead of stopping dead.
	var k := 1.0 - float(sf) / float(total)
	vel.x = (-BACKDASH_SPEED if back else DASH_SPEED) * facing * (0.35 + 0.85 * k)
	position.x += vel.x
	if sf >= total:
		vel.x = 0.0
		_to_neutral()


## A rolling fighter slips through the opponent instead of pushing them.
func passes_through() -> bool:
	return state == S.DASH and sf >= ROLL_INVULN_FROM and sf <= DASH_FRAMES - 3


## Double jump and air dash, one of each per trip into the air.
func _try_air_moves() -> bool:
	if super_jumping:
		return false
	if air_jumps > 0 and buf.pressed_within(Controls.UP, 4):
		buf.consume(Controls.UP)
		air_jumps -= 1
		air_dash_timer = 0
		var h := buf.current()
		var dx := vel.x
		if h & _fwd():
			dx = def.jump_x * facing
		elif h & _back():
			dx = -def.jump_x * facing
		vel = Vector2(dx, AIR_JUMP_VEL)
		Sfx.play("whoosh", 1.2)
		fight.effects.spawn("ring", position + Vector2(0, -40))
		return true
	if air_dashes <= 0:
		return false
	for bit: int in [_fwd(), _back()]:
		if not buf.double_tapped(bit):
			continue
		buf.consume_tap(bit)
		air_dashes -= 1
		var sgn := -1.0 if bit == _back() else 1.0
		vel = Vector2(AIR_DASH_SPEED * facing * sgn, 0.0)
		air_dash_timer = AIR_DASH_FRAMES
		Sfx.play("whoosh", 1.05)
		return true
	return false


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
	if _try_air_moves():
		return
	if _try_normal():
		return
	if _air_physics():
		_land()


func _air_physics() -> bool:
	if air_dash_timer > 0:
		# Air dashes float: gravity resumes when the dash runs out.
		air_dash_timer -= 1
		vel.y *= 0.5
	else:
		vel.y += GRAVITY
	position += vel
	if position.y >= GROUND_Y:
		position.y = GROUND_Y
		vel.y = 0.0
		air_dash_timer = 0
		return true
	return false


func _land() -> void:
	# The faster you were falling, the harder you splat. Capped so a light hop
	# stays subtle and a super-jump landing really thumps.
	var impact := clampf(vel.y / 14.0, 0.12, 1.0)
	vel = Vector2.ZERO
	land_timer = 6
	air_jumps = 0
	air_dashes = 0
	Sfx.play("land")
	fight.effects.spawn("dust", position)
	renderer.squish(0.34 * impact)
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
		fight.effects.spawn("ring", position)
		fight.shake = maxf(fight.shake, 3.0)
		# Full pancake, then see stars. This is the pratfall.
		renderer.squish(0.40)
		renderer.emote("stars", 46)


func _knockdown_step() -> void:
	vel.x *= 0.8
	position.x += vel.x
	# Quick-rise: tap anything once you've hit the floor to get up early.
	if sf >= QUICK_RISE_FROM and sf < 36 and buf.current() != 0:
		_quick_rise()
		return
	if sf >= 36:
		set_state(S.GETUP, true)


func _quick_rise() -> void:
	set_state(S.GETUP, true)
	invuln = 12
	Sfx.play("whoosh", 1.3)
	fight.effects.spawn("dust", Vector2(position.x, GROUND_Y))


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
	elif h & _back() and meter >= HYPER_COST:
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
	var line: String = ["light", "heavy", "special", "hyper"][m.level]
	if m.level > 0 or randf() < 0.5:
		Sfx.voice(def.id, line, index, def.voice_pitch)
	if m.level == 3:
		meter -= HYPER_COST
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
	_fire_events(sf)
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


## Fires the move's authored FX/sound events for this state frame.
func _fire_events(frame: int) -> void:
	if move == null or fight == null:
		return
	for e in move.events_at(frame):
		_fire_event(e[0], e[1])


## `data.offset` is in the fighter's own space, facing right, like a hitbox.
func _fire_event(kind: String, data: Dictionary) -> void:
	var off: Vector2 = data.get("offset", Vector2.ZERO)
	var at := position + Vector2(off.x * facing, off.y)
	match kind:
		"slash":
			# Swoosh sized to the hitbox, unless the character overrides it.
			var hb := to_world(move.hitbox)
			if not hb.has_area():
				return
			var c: Vector2 = at if data.has("offset") else hb.get_center()
			fight.effects.spawn("slash", c, {"dir": facing, "r": float(data.get("r", maxf(hb.size.x, hb.size.y) * 0.6))})
		"fx":
			fight.effects.spawn(String(data.get("kind", "dust")), at, data.duplicate())
		"dust":
			fight.effects.spawn("dust", Vector2(at.x, GROUND_Y))
		"sfx":
			Sfx.play(String(data.get("name", "whoosh")), float(data.get("pitch", 1.0)))
		"voice":
			Sfx.voice(def.id, String(data.get("line", "light")), index, def.voice_pitch)
		"shake":
			fight.shake = maxf(fight.shake, float(data.get("amount", 2.0)))


# --- Throws ------------------------------------------------------------------

## L+H while touching a grounded, actionable opponent throws instead of firing
## the projectile special. Point-blank only, which is the Marvel vs Capcom rule.
func _try_throw() -> bool:
	if not on_ground() or not buf.lh_combo():
		return false
	var o := opponent
	if absf(o.position.x - position.x) > THROW_RANGE * def.size or not o.on_ground():
		return false
	if o.state in [S.THROW, S.THROWN, S.KNOCKDOWN, S.GETUP, S.KO, S.INTRO, S.WIN, S.LAUNCHED]:
		return false
	buf.consume_combo()
	_face_opponent()
	vel.x = 0.0
	set_state(S.THROW, true)
	o.set_state(S.THROWN, true)
	o.move = null
	o.vel = Vector2.ZERO
	Sfx.play("whoosh", 0.7)
	Sfx.voice(def.id, "heavy", index, def.voice_pitch)
	return true


func _throw_step() -> void:
	var o := opponent
	if o.state != S.THROWN:
		_to_neutral()
		return
	# Hold them at arm's length, facing us.
	o.position = Vector2(position.x + facing * 34.0 * def.size, GROUND_Y)
	o.facing = -facing
	o.vel = Vector2.ZERO
	if sf <= THROW_BREAK_WINDOW and o.buf.lh_combo():
		o.buf.consume_combo()
		_throw_break()
		return
	if sf < THROW_HOLD:
		return
	var m := def.throw_data()
	var res := o.take_hit(m, position.x)
	on_hit_landed(m, false)
	fight.on_throw(self, o, m, res)
	_to_neutral()


func _throw_break() -> void:
	var o := opponent
	o._to_neutral()
	o.vel = Vector2(facing * 3.5, 0.0)
	vel = Vector2(-facing * 3.5, 0.0)
	_to_neutral()
	Sfx.play("block", 1.2)
	fight.effects.spawn("block", (position + o.position) * 0.5 + Vector2(0, -70), {"dir": facing})
	fight.hitstop = maxi(fight.hitstop, 8)


func _thrown_step() -> void:
	# The thrower drives our position; if they somehow stop, we recover.
	if opponent.state != S.THROW:
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
		S.KNOCKDOWN, S.GETUP, S.KO, S.INTRO, S.WIN, S.THROW, S.THROWN:
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
	return to_world(Rect2(r.position * def.size, r.size * def.size))


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
		contact = m.hitstop + 2
		if m.launch and not blocked:
			launch_window = 30


func _can_block(dir: int) -> bool:
	if state == S.BLOCK and stun > 0:
		return true
	# Air blocking: a safety net for a player who jumped in at the wrong moment.
	if not on_ground():
		return state == S.JUMP and buf.held(Controls.RIGHT if dir > 0 else Controls.LEFT)
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
		renderer.squish(0.07 + 0.03 * m.level)
		# Blocking a special is a close shave, and the fighter knows it.
		if m.level >= 2:
			renderer.emote("sweat", 34)
		return "block"
	combo = combo + 1 if state in [S.HITSTUN, S.LAUNCHED] else 1
	var scale := maxf(0.5 if m.level == 3 else 0.3, 1.0 - 0.1 * (combo - 1))
	var dmg := maxi(1, roundi(m.damage * scale))
	health = maxi(0, health - dmg)
	meter = minf(MAX_METER, meter + dmg / 18.0)
	flash = 4
	shook = m.hitstop + 3
	crouching = false
	move = null
	launch_window = 0
	# Cartoon impact: the body concertinas and the eyes bug out, scaled to how
	# hard the hit was. A jab barely ripples; a hyper nearly folds you in half.
	renderer.squish(0.13 + 0.10 * m.level)
	if m.level >= 1:
		renderer.eye_pop = 6 + m.level * 2
	if m.level >= 2:
		renderer.emote("shock", 26)
	if health == 0:
		set_state(S.KO, true)
		Sfx.voice(def.id, "ko", index, def.voice_pitch)
		vel = Vector2(dir * 4.0, -9.0)
		position.y -= 1.0
		return "ko"
	if combo <= 1 or m.level >= 1 and randf() < 0.5:
		Sfx.voice(def.id, "hurt", index, def.voice_pitch)
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
		hit_variant = 1 - hit_variant
		set_state(S.HITSTUN, true)
	return "hit"


# --- Visuals -----------------------------------------------------------------

func _update_visual() -> void:
	renderer.facing = facing
	renderer.flash = flash
	renderer.t = buf.frame
	# Visual-only impact jitter. Never touch `position` here: that is simulation.
	renderer.position = Vector2(randf_range(-1.6, 1.6), randf_range(-1.2, 1.2)) if shook > 0 else Vector2.ZERO
	var tgt := _pose_target()
	renderer.update_pose(tgt[0], tgt[1])
	renderer.expr = _expression()
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


## Which cartoon face to wear. Ordered most-specific first: being knocked out
## beats being dizzy, which beats simply being hit.
func _expression() -> String:
	match state:
		S.KO:
			return "ko"
		S.KNOCKDOWN, S.GETUP:
			return "dizzy"
		S.HITSTUN, S.LAUNCHED, S.THROWN:
			return "hurt"
		S.WIN:
			return "happy"
		S.BLOCK:
			return "shock" if stun > 0 and opponent != null and opponent.combo >= 2 else "attack"
		S.ATTACK:
			# Landing a big combo earns the smug face. Kids love the smug face.
			if opponent != null and opponent.combo >= 4:
				return "smug"
			return "attack"
		S.DASH, S.BACKDASH, S.THROW:
			return "attack"
	# On the ropes: below a quarter health you sweat it out.
	if health <= MAX_HEALTH / 4:
		return "shock" if int(buf.frame / 22) % 4 == 0 else "normal"
	return "normal"


func _update_ghosts() -> void:
	if fight == null:
		return
	if ghosts.is_empty():
		for i in 4:
			var g := FighterRenderer.new()
			g.visible = false
			g.z_index = -1
			fight.world.add_child(g)
			ghosts.append(g)
	var active := (state == S.ATTACK and move != null and move.level >= 2) \
		or (state == S.JUMP and (super_jumping or air_dash_timer > 0)) \
		or state == S.DASH or state == S.BACKDASH
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
	if land_timer > 0:
		land_timer -= 1
		if state == S.IDLE or state == S.WALK:
			return [def.pose("crouch", {"lean": 14, "head": 4, "arm_f": 50, "arm_b": 70}), 0.8]
	match state:
		S.IDLE:
			# Bouncy fighting stance: knees pump, guard breathes.
			var b := sin(t * 0.13)
			return [def.pose("idle", {"lean": 9 + b * 2.0, "knee_f": 24 + b * 9.0, "knee_b": 22 + b * 9.0, "leg_f": 24 + b * 4.0,
				"elb_f": 80 + b * 6.0, "elb_b": 95 - b * 6.0, "head": -2 - b * 2.0}), 0.35]
		S.WALK:
			var ph := t * 0.28 * signf(vel.x * facing)
			var s := sin(ph)
			var c := cos(ph)
			var fwd := signf(vel.x * facing) > 0.0
			return [def.pose("idle", {
				"lean": (12 if fwd else 2) + absf(c) * 3.0, "head": -3 - absf(c) * 2.0,
				"leg_f": 8 + s * 30, "knee_f": 16 + maxf(0.0, c) * 40,
				"leg_b": -8 - s * 30, "knee_b": 16 + maxf(0.0, -c) * 40,
				"arm_f": 40 - s * 14, "elb_f": 85 + s * 10, "arm_b": 50 + s * 22, "elb_b": 90 - s * 10,
			}), 0.6]
		S.CROUCH:
			return [def.pose("crouch"), 0.4]
		S.DASH:
			# The roll tucks and spins forward, then lands back on its feet.
			var k := clampf(float(sf) / float(DASH_FRAMES), 0.0, 1.0)
			var p := def.pose("dash")
			p["rot"] = -360.0 * smoothstep(0.1, 0.92, k)
			p["lean"] = 34.0 + sin(k * PI) * 18.0
			return [p, 1.0]
		S.BACKDASH:
			var kb := clampf(float(sf) / float(BACKDASH_FRAMES), 0.0, 1.0)
			return [def.pose("backdash", {"hip": -40.0 - sin(kb * PI) * 14.0, "lean": -18.0 + kb * 16.0}), 0.6]
		S.THROW:
			var kt := clampf(float(sf) / float(THROW_HOLD), 0.0, 1.0)
			return [def.pose("throw", {"lean": 16.0 - kt * 26.0, "arm_f": 95.0 + kt * 35.0, "arm_b": 90.0 + kt * 35.0}), 0.7]
		S.THROWN:
			return [def.pose("thrown", {"rot": -10.0 - sin(t * 0.4) * 8.0}), 0.5]
		S.BLOCK:
			return [def.pose("crouch_block" if crouching else "block"), 0.5]
		S.JUMP:
			if vel.y < -3.0:
				return [def.pose("jump", {"leg_f": 75, "knee_f": 110, "leg_b": 30, "knee_b": 100, "lean": 10}), 0.5]
			if vel.y < 2.0:
				return [def.pose("jump", {"leg_f": 85, "knee_f": 125, "leg_b": 45, "knee_b": 120, "lean": 14, "head": 6}), 0.5]
			return [def.pose("jump", {"leg_f": 30, "knee_f": 40, "leg_b": -10, "knee_b": 30, "lean": 0, "arm_f": 110, "arm_b": 10}), 0.45]
		S.ATTACK:
			var base := "crouch" if move.crouch else ("jump" if move.air else "idle")
			var key := move.pose_at(sf)
			var p := def.pose(base, key[0])
			if move.spin != 0.0 and sf > move.startup:
				var k := clampf(float(sf - move.startup) / (move.active + move.recovery * 0.6), 0.0, 1.0)
				p["rot"] = move.spin * k
				return [p, 1.0]
			if contact > 0 and move.contact_pose:
				# Impact frame: exaggerate the pose while the world is frozen.
				p.merge(move.contact_pose, true)
				return [p, 1.0]
			return [p, float(key[1])]
		S.HITSTUN:
			if hit_variant == 1:
				# Gut hit: fold forward instead of snapping back.
				return [def.pose("hit", {"lean": 28, "head": 20, "arm_f": 20, "elb_f": 80, "arm_b": 10, "elb_b": 70, "knee_f": 30, "knee_b": 25}), 0.8]
			return [def.pose("hit"), 0.8]
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
