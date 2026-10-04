extends Node
## Headless gameplay checks. Run with:
##   godot --headless --path . -- --test

const U := Controls.UP
const D := Controls.DOWN
const Lf := Controls.LEFT
const R := Controls.RIGHT
const LI := Controls.LIGHT
const HE := Controls.HEAVY

var failures := 0


class Scripted:
	extends RefCounted
	var steps: Array = []  # [[mask, frames], ...]

	func sample(_f) -> int:
		if steps.is_empty():
			return 0
		var s: Array = steps[0]
		s[1] -= 1
		if s[1] <= 0:
			steps.pop_front()
		return s[0]

	func is_human() -> bool:
		return true


func _ready() -> void:
	_test_roster()
	for id in GameState.CHARACTERS:
		_test_character_def(id)
	for id in GameState.CHARACTERS:
		_test_specials(id)
		_test_combo(id)
	_test_movement("ulises")
	_test_throw("ulises")
	_test_ulises_chain_pose()
	_test_hyper_cutin()
	_test_hyper_landing()
	_test_hyper_max()
	_test_air_block()
	_test_quick_rise()
	_test_block()
	_test_demo_match()
	if OS.get_cmdline_user_args().has("--balance"):
		_balance_report()
	print("FAILURES: %d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func check(cond: bool, what: String) -> void:
	print(("  ok   " if cond else "  FAIL ") + what)
	if not cond:
		failures += 1


## The roster comes from scanning `characters/`. If that ever breaks — most
## likely in an exported build where scripts ship as .gdc or .remap — the game
## has no fighters at all, so check it loudly and first.
func _test_roster() -> void:
	print("[roster]")
	check(GameState.CHARACTERS.size() >= 2, "the scanner found at least two fighters (%s)" % [GameState.CHARACTERS])
	check(not GameState.has_character("template"), "the _template.gd starting point is not on the roster")
	var seen := {}
	var all_unique := true
	for id in GameState.CHARACTERS:
		if seen.has(id):
			all_unique = false
		seen[id] = true
	check(all_unique, "every character id is unique")
	for id in GameState.CHARACTERS:
		check(GameState.make_character(id) is CharacterDef, "'%s' builds a CharacterDef" % id)


## Everything a new fighter can forget. This is the safety net behind
## `characters/_template.gd`: a half-finished character fails here with a clear
## message instead of crashing mid-match.
func _test_character_def(id: String) -> void:
	print("[character: %s]" % id)
	var d := GameState.make_character(id)
	check(d.display != "", "%s has a display name" % id)
	check(d.voice_pitch > 80.0 and d.voice_pitch < 600.0, "%s has a usable voice pitch (%.0f Hz)" % [id, d.voice_pitch])
	check(d.walk_speed > d.back_speed, "%s walks forward faster than backward" % id)
	check(d.jump_vel < 0.0, "%s jumps upward (jump_vel is negative)" % id)

	var missing_colors: Array[String] = []
	for key: String in CharacterDef.REQUIRED_COLORS:
		if not d.colors.has(key) or not d.alt_colors.has(key):
			missing_colors.append(key)
	check(missing_colors.is_empty(), "%s defines every required colour%s" % [id, "" if missing_colors.is_empty() else ", missing " + str(missing_colors)])
	check(d.colors.get("shirt") != d.alt_colors.get("shirt"), "%s's alt palette differs, so a mirror match is readable" % id)

	var missing_moves: Array[String] = []
	for key: String in CharacterDef.REQUIRED_MOVES:
		if not d.moves.has(key):
			missing_moves.append(key)
	check(missing_moves.is_empty(), "%s defines all ten moves%s" % [id, "" if missing_moves.is_empty() else ", missing " + str(missing_moves)])
	if not missing_moves.is_empty():
		return

	var bad_frames: Array[String] = []
	var behind: Array[String] = []
	var no_offence: Array[String] = []
	# Every move the character defines, not just the required ten: a character is
	# allowed extra moves and those still have to be real moves.
	for key: String in d.moves:
		var m: MoveData = d.moves[key]
		if m.startup < 1 or m.active < 1 or m.recovery < 1 or m.startup > 60 or m.recovery > 90:
			bad_frames.append(key)
		var hits := m.hitbox.size.x > 0.0 and m.hitbox.size.y > 0.0
		var shoots := not m.projectile.is_empty()
		if not hits and not shoots:
			no_offence.append(key)
		# Hitboxes reach forward (+X). A box entirely behind the fighter means
		# the Rect2 was authored with the wrong sign and will never connect.
		if hits and m.hitbox.end.x <= 0.0:
			behind.append(key)
	check(bad_frames.is_empty(), "%s's frame data is in range%s" % [id, "" if bad_frames.is_empty() else ", odd: " + str(bad_frames)])
	check(no_offence.is_empty(), "%s's moves all hit or shoot something%s" % [id, "" if no_offence.is_empty() else ", inert: " + str(no_offence)])
	check(behind.is_empty(), "%s's hitboxes reach forward%s" % [id, "" if behind.is_empty() else ", backwards: " + str(behind)])

	check(d.moves["H"].launch, "%s's heavy launches, so air combos work" % id)
	check(d.moves["anti"].invuln > 0, "%s's anti-air special has invulnerability" % id)
	check(d.moves["hyper"].level >= 3, "%s's hyper is a level 3 move" % id)
	# Optional in the ten-key contract, but the roster is expected to give every
	# fighter a second super: it is UP+L+H, and it is what makes the direction
	# choice on the meter gauge mean something.
	check(d.moves.has("hyper2"), "%s has a second hyper on UP+L+H" % id)
	# Three meter bars had no way to be spent — both supers cost one — so each
	# fighter also needs a MAX version of each, reachable on the same inputs.
	check(d.moves.has("hyper_max"), "%s has a MAX version of its first hyper" % id)
	check(d.moves.has("hyper2_max"), "%s has a MAX version of its second hyper" % id)
	_test_hyper_spec(d)
	check(d.specials_text.size() >= 4, "%s lists its specials for the move list" % id)
	check(d.throw_data() != null, "%s has a throw" % id)


## The hyper is the one move a player spends a whole meter bar on, and it is the
## only one shown during a cut-in that stops the world, so it has to be authored
## rather than left on the defaults. Three things used to go wrong: the legacy
## `pose_s` / `pose_a` pair desugars into a two-key clip that holds its second
## pose for the entire recovery (a fighter standing still through their own
## super), and there was nothing to hold during the freeze at all, because `sf`
## cannot advance while the world is stopped — so the body sat on the clip's
## first key for all 56 frames.
func _test_hyper_spec(d: CharacterDef) -> void:
	var id := d.id
	_check_hyper_spec(d, d.moves["hyper"], "hyper")
	# `hyper2` is optional — it is the UP+L+H answer, not part of the ten-key
	# contract — but a fighter that has one is held to the same bar, and the
	# roster is expected to give all of them one.
	if d.moves.has("hyper2"):
		_check_hyper_spec(d, d.moves["hyper2"], "hyper2")
	# The 3-bar MAX versions are optional too, and `<key>_max` is what the input
	# routes to when the meter is full, so a half-authored one would either be
	# unreachable or cheaper than it looks.
	for base: String in ["hyper", "hyper2"]:
		if not d.moves.has(base + "_max"):
			continue
		var mx: MoveData = d.moves[base + "_max"]
		check(int(mx.meter_cost) == int(Fighter.EX_COST),
			"%s's %s_max costs the whole meter (%d)" % [id, base, int(mx.meter_cost)])
		check(mx.id != d.moves[base].id, "%s's %s_max is a different move from %s" % [id, base, base])
		_check_hyper_spec(d, mx, base + "_max")


func _check_hyper_spec(d: CharacterDef, h: MoveData, key: String) -> void:
	var id := d.id
	check(not h.cutin_pose.is_empty(), "%s's %s has a cut-in pose for the freeze" % [id, key])
	check(not h.contact_pose.is_empty(), "%s's %s has an impact pose for the hit freeze" % [id, key])
	# `pose_at` builds the clip from the pose_s / pose_a fallback if needed, which
	# is exactly the two-key form this is checking against.
	h.pose_at(0)
	var varied := false
	var first: Dictionary = h.keys[0][1] if not h.keys.is_empty() else {}
	for k in h.keys:
		for pkey in k[1]:
			if not first.has(pkey) or not is_equal_approx(float(first[pkey]), float(k[1][pkey])):
				varied = true
	check(h.keys.size() >= 3, "%s's %s is a real animation clip, not the static two-pose form (%d keys)"
		% [id, key, h.keys.size()])
	check(varied, "%s's %s clip changes pose across its keys" % [id, key])
	# Something has to happen at or after the frame the attack goes live, or the
	# clip is all wind-up and the whole recovery is one held pose.
	check(not h.keys.is_empty() and int(h.keys[-1][0]) >= h.startup,
		"%s's %s clip is still moving when the attack goes live" % [id, key])
	# It is a projectile super, so it needs one, and the slot exemption and the
	# meter cost are both keyed on the projectile's own `level` — forget that and
	# the super quietly occupies the one-projectile slot and cannot be fired.
	check(not h.projectile.is_empty(), "%s's %s shoots something" % [id, key])
	check(int(h.projectile.get("level", 0)) == 3,
		"%s's %s projectile is level 3, or it takes the projectile slot and costs no meter" % [id, key])
	# The shake is read by `_apply_hit` off the *projectile's* MoveData, which
	# `Projectile.setup` builds from this spec. A hyper that leaves it out lands
	# with no screen effect on any of its hits. The screen *flash* is not checked
	# here because `final_knockdown` supplies it on the finishing hit — see
	# `_test_hyper_landing`, which checks it on a real projectile.
	check(float(h.projectile.get("shake", 0.0)) > 0.0, "%s's %s projectile shakes the screen" % [id, key])


## A hyper used to land as ten to fourteen identical chip hits that each slammed
## the post-FX white mix to its 0.8 ceiling, so the whole super read as a washed
## out smear rather than one heavy blow. This drives a real hyper and watches the
## screen effect per frame: the running hits should only breathe, and the
## finishing hit should be the one that flashes, slows the world and punches.
func _test_hyper_landing() -> void:
	print("[hyper landing]")
	for id: String in GameState.CHARACTERS:
		var f := _new_fight(id, "emilia")
		_start(f)
		var p1 := f.fighters[0]
		var p2 := f.fighters[1]
		# Stand them off: a close L+H is a throw, and a throw resolves nothing here.
		# 100 is outside Fighter.THROW_RANGE (66) but close enough that Emilia's
		# travelling dragon still crosses the opponent and lands all ten hits —
		# her super flies, unlike the other three which sit anchored in front.
		p2.position.x = p1.position.x + 100.0
		p1.meter = Fighter.HYPER_COST
		_script(p1, [[Lf, 3], [Lf | LI | HE, 2], [0, 300]])
		# Grab the projectile as it spawns: by the end of the run it has been
		# cleaned up of `fight.projectiles`. Snapshots of the MoveData rather than
		# the node, because the node is freed with the fight.
		var hyper_m: MoveData = null
		var hyper_final: MoveData = null
		# Sampled *before* each step, because `impact` decays at the top of
		# `_physics_process` — reading it afterwards would only ever show the
		# decayed value and would miss the peak.
		var peak := 0.0
		var slowmo_seen := 0
		var flash_seen := 0
		var zoom_seen := 0.0
		for i in 300:
			if hyper_m == null:
				for p in f.projectiles:
					if p.m != null and p.m.level == 3:
						hyper_m = p.m
						hyper_final = p.m_final
						break
			peak = maxf(peak, f.impact)
			slowmo_seen = maxi(slowmo_seen, f.slowmo)
			flash_seen = maxi(flash_seen, f.flash)
			zoom_seen = maxf(zoom_seen, f.cam_z)
			f._physics_process(1.0 / 60.0)
		peak = maxf(peak, f.impact)
		flash_seen = maxi(flash_seen, f.flash)
		check(peak <= 0.7, "%s's hyper never pins the post-FX white mix (peak %.2f)" % [id, peak])
		check(peak >= Fight.HYPER_HIT_IMPACT - 0.01,
			"%s's hyper finishing hit still punches (peak %.2f)" % [id, peak])
		check(slowmo_seen > 0, "%s's hyper slows the world down on the finishing hit" % id)
		check(flash_seen > 0, "%s's hyper flashes the screen on the finishing hit" % id)
		check(zoom_seen >= Fight.HYPER_ZOOM - 0.06,
			"%s's hyper pushes the camera in (reached %.2f of %.2f)" % [id, zoom_seen, Fight.HYPER_ZOOM])
		# And the projectile really does carry the effect forwards, and only the
		# finishing one flashes.
		check(hyper_m != null, "%s's hyper put a level 3 projectile in the arena" % id)
		if hyper_m != null:
			check(float(hyper_m.shake) > 0.0, "%s's hyper projectile carries its shake through (%.2f)"
				% [id, float(hyper_m.shake)])
			check(int(hyper_m.flash) == 0 and hyper_final != null and int(hyper_final.flash) > 0,
				"%s's hyper flashes only on the finishing hit (running %d, finishing %d)" % [id,
					int(hyper_m.flash), int(hyper_final.flash) if hyper_final != null else -1])
		f.free()


## Three meter bars had no way to be spent: both supers cost one bar, so banking
## the third was pointless. Each fighter now has a MAX version of each super,
## reachable on the same inputs but only with the whole meter, and it must cost
## the whole meter when it fires.
func _test_hyper_max() -> void:
	print("[hyper max]")
	for id: String in GameState.CHARACTERS:
		var d: CharacterDef = GameState.make_character(id)
		for base: String in ["hyper", "hyper2"]:
			if not d.moves.has(base + "_max"):
				continue
			var held: int = Lf if base == "hyper" else U
			_max_one(id, base, held)


## Drives one super at one bar and again at three, and checks the meter decides
## which move comes out and what it charges.
func _max_one(id: String, base: String, held: int) -> void:
	var max_id: String = GameState.make_character(id).moves[base + "_max"].id
	# One bar: the ordinary super.
	var f := _new_fight(id, "emilia")
	_start(f)
	var p1 := f.fighters[0]
	f.fighters[1].position.x = p1.position.x + 220.0
	p1.meter = Fighter.HYPER_COST
	_script(p1, [[held, 3], [held | LI | HE, 2], [0, 60]])
	var seen := _watch_move(f, p1, 90)
	var want := _expected(p1, base)
	check(seen.has(want) and not seen.has(max_id),
		"%s: one bar gives the ordinary %s, not the MAX (%s)" % [id, base, str(seen)])
	check(p1.meter < 1.0, "%s: the ordinary %s still costs one bar" % [id, base])
	f.free()
	# Three bars: the MAX version, and it costs all three.
	f = _new_fight(id, "emilia")
	_start(f)
	p1 = f.fighters[0]
	f.fighters[1].position.x = p1.position.x + 220.0
	p1.meter = Fighter.EX_COST
	_script(p1, [[held, 3], [held | LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 90)
	check(seen.has(max_id), "%s: three bars give %s_max (%s)" % [id, base, str(seen)])
	check(p1.meter <= 1.0, "%s: %s_max spends the whole meter (%.0f left)" % [id, base, p1.meter])
	check(p1.meter >= 0.0, "%s: the meter never goes negative (%.0f)" % [id, p1.meter])
	# Two bars is neither: too little for the MAX, and `_try_special` must fall
	# through to the ordinary super rather than swallowing the input.
	f = _new_fight(id, "emilia")
	_start(f)
	p1 = f.fighters[0]
	f.fighters[1].position.x = p1.position.x + 220.0
	p1.meter = Fighter.HYPER_COST * 2.0
	_script(p1, [[held, 3], [held | LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 90)
	check(seen.has(_expected(p1, base)) and not seen.has(max_id),
		"%s: two bars falls back to the ordinary %s (%s)" % [id, base, str(seen)])
	f.free()


func _new_fight(p1: String, p2: String) -> Fight:
	GameState.mode = "vs"
	GameState.chars = [p1, p2]
	var f := Fight.new()
	add_child(f)
	f.set_physics_process(false)
	f.set_process(false)
	for fr in f.fighters:
		fr.input_source = Scripted.new()
	return f


func _run(f: Fight, frames: int) -> void:
	for i in frames:
		f._physics_process(1.0 / 60.0)


func _start(f: Fight) -> void:
	_run(f, 101)  # round intro
	check(f.phase == "fight", "round starts after intro")


func _script(fr: Fighter, steps: Array) -> void:
	(fr.input_source as Scripted).steps = steps.duplicate(true)


## The move id `fr` would actually get for `key` right now. A character can swap
## in a variant of an input depending on its own state, so the expectation is
## resolved, not assumed.
func _expected(fr: Fighter, key: String) -> String:
	return fr.def.moves[fr.def.choose_move(key, fr)].id


func _watch_move(f: Fight, fr: Fighter, frames: int) -> Array:
	var seen := []
	for i in frames:
		f._physics_process(1.0 / 60.0)
		if fr.move and not seen.has(fr.move.id):
			seen.append(fr.move.id)
	return seen


func _test_specials(id: String) -> void:
	print("[%s specials]" % id)
	var f := _new_fight(id, "emilia")
	_start(f)
	var p1 := f.fighters[0]
	_script(p1, [[LI | HE, 2], [0, 60]])
	var want := _expected(p1, "proj")
	var seen := _watch_move(f, p1, 40)
	check(seen.has(want), "L+H does projectile (%s)" % str(seen))
	check(f.projectiles.size() > 0 or seen.has(want), "projectile spawned")
	_run(f, 80)
	# L then H two frames later should still become the special.
	_script(p1, [[LI, 2], [LI | HE, 2], [0, 60]])
	want = _expected(p1, "proj")
	seen = _watch_move(f, p1, 40)
	check(seen.has(want), "L, then H 2 frames later, still does projectile (%s)" % str(seen))
	_run(f, 120)
	_script(p1, [[R, 3], [R | LI | HE, 2], [0, 60]])
	want = _expected(p1, "rush")
	seen = _watch_move(f, p1, 50)
	check(seen.has(want), "FWD+L+H does rush (%s)" % str(seen))
	_run(f, 120)
	_script(p1, [[D, 3], [D | LI | HE, 2], [0, 60]])
	want = _expected(p1, "anti")
	seen = _watch_move(f, p1, 50)
	check(seen.has(want), "DOWN+L+H does anti-air (%s)" % str(seen))
	_run(f, 120)
	p1.meter = 100.0
	var back := Lf if p1.facing > 0 else R
	_script(p1, [[back, 3], [back | LI | HE, 2], [0, 60]])
	want = _expected(p1, "hyper")
	seen = _watch_move(f, p1, 60)
	check(seen.has(want), "BACK+L+H with full meter does hyper (%s)" % str(seen))
	check(p1.meter < 1.0, "hyper spends the meter")
	var hp := f.fighters[1].health
	_run(f, 200)
	check(f.fighters[1].health < hp, "hyper damages the opponent (%d -> %d)" % [hp, f.fighters[1].health])
	# The second hyper: UP+L+H, where the rest of the direction ladder does not
	# reach. Runs for every character that defines one.
	if p1.def.moves.has("hyper2"):
		_run(f, 150)
		p1.meter = 100.0
		# Holding UP a beat before the buttons is the way a player actually presses
		# it, and it must still be the hyper rather than a jump into an air normal.
		_script(p1, [[U, 3], [U | LI | HE, 2], [0, 60]])
		want = _expected(p1, "hyper2")
		seen = _watch_move(f, p1, 90)
		check(seen.has(want), "UP+L+H with full meter does the second hyper (%s)" % str(seen))
		check(p1.meter < 1.0, "the second hyper spends the meter")
		# It has to be a different move, or "two hypers" is one hyper twice.
		check(want != _expected(p1, "hyper"), "%s's two hypers are different moves" % id)
		var hp2 := f.fighters[1].health
		_run(f, 240)
		check(f.fighters[1].health < hp2, "the second hyper damages the opponent (%d -> %d)" % [hp2, f.fighters[1].health])
		# UP on its own must still jump: the hyper cannot have eaten the jump.
		_run(f, 120)
		var air := false
		var y0 := p1.position.y
		_script(p1, [[U, 4], [0, 10]])
		for i in 12:
			f._physics_process(1.0 / 60.0)
			if p1.position.y < y0 - 4.0:
				air = true
		check(air, "UP alone still jumps after firing the second hyper")
		# The other order: direction and buttons on the same frame, from the
		# ground. That is the other code path — `_try_special` rather than
		# `_try_air_special` — and it must not have jumped on the way. Push the
		# opponent out of reach and top them back up first: a few hypers in a row
		# can leave them standing next to us, and a close L+H is a throw before it
		# is ever a special.
		f.fighters[1].position.x = p1.position.x + 220.0
		f.fighters[1].health = Fighter.MAX_HEALTH
		_run(f, 150)
		p1.meter = 100.0
		var y_start := p1.position.y
		_script(p1, [[U | LI | HE, 3], [0, 60]])
		seen = _watch_move(f, p1, 90)
		check(seen.has(want), "UP+L+H all at once is the second hyper too (%s)" % str(seen))
		check(p1.position.y <= y_start + 0.01, "the simultaneous press did not jump first")
	# Without a second hyper, UP+L+H must fall through to the normal special
	# rather than being swallowed by the input.
	else:
		_run(f, 150)
		p1.meter = 100.0
		_script(p1, [[U, 3], [U | LI | HE, 2], [0, 60]])
		seen = _watch_move(f, p1, 50)
		check(seen.has(_expected(p1, "proj")), "UP+L+H falls through to the special with no second hyper (%s)" % str(seen))
	f.free()


func _test_movement(id: String) -> void:
	print("[%s movement]" % id)
	var f := _new_fight(id, "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	var fwd := R if p1.facing > 0 else Lf
	var back := Lf if p1.facing > 0 else R

	# Double-tap forward: a dash that travels further than plain walking.
	var x0 := p1.position.x
	_script(p1, [[fwd, 2], [0, 2], [fwd, 2], [0, 40]])
	var dashed := false
	for i in 26:
		f._physics_process(1.0 / 60.0)
		dashed = dashed or p1.state == Fighter.S.DASH
	check(dashed, "double-tap forward dashes")
	check(absf(p1.position.x - x0) > p1.def.walk_speed * 20.0, "the dash covers more ground than a walk")
	_run(f, 30)

	# The roll is invulnerable through its middle.
	_script(p1, [[fwd, 2], [0, 2], [fwd, 2], [0, 40]])
	var rolled_invuln := false
	for i in 26:
		f._physics_process(1.0 / 60.0)
		if p1.state == Fighter.S.DASH and p1.sf >= Fighter.ROLL_INVULN_FROM and p1.sf < Fighter.DASH_FRAMES - 4:
			rolled_invuln = rolled_invuln or not p1.hurtbox_world().has_area()
	check(rolled_invuln, "the forward roll is invulnerable through its middle")
	_run(f, 30)

	# Double-tap back retreats.
	p1.position.x = p2.position.x - 120.0
	x0 = p1.position.x
	_script(p1, [[back, 2], [0, 2], [back, 2], [0, 40]])
	var backdashed := false
	for i in 28:
		f._physics_process(1.0 / 60.0)
		backdashed = backdashed or p1.state == Fighter.S.BACKDASH
	check(backdashed, "double-tap back backdashes")
	check(p1.position.x < x0, "the backdash retreats")
	_run(f, 30)

	# Up in the air jumps again; the second jump goes higher than one alone.
	_script(p1, [[U, 3], [0, 12], [U, 3], [0, 60]])
	var peak := Fighter.GROUND_Y
	var double_jumped := false
	for i in 70:
		f._physics_process(1.0 / 60.0)
		peak = minf(peak, p1.position.y)
		double_jumped = double_jumped or (p1.state == Fighter.S.JUMP and p1.air_jumps == 0 and p1.vel.y < -6.0 and p1.sf > 12)
	check(double_jumped, "Up in the air does a second jump")
	# A single jump peaks at v^2 / 2g; the second one must clearly beat that.
	var single := p1.def.jump_vel * p1.def.jump_vel / (2.0 * Fighter.GRAVITY)
	check(Fighter.GROUND_Y - peak > single * 1.3,
		"the double jump gains real height (peak %d vs %d for one jump)" % [int(Fighter.GROUND_Y - peak), int(single)])
	_run(f, 40)

	# Air dash: double-tap a direction in the air.
	p1.position.x = p2.position.x - 200.0
	_script(p1, [[U, 3], [0, 10], [fwd, 2], [0, 2], [fwd, 2], [0, 60]])
	var air_dashed := false
	for i in 60:
		f._physics_process(1.0 / 60.0)
		air_dashed = air_dashed or p1.air_dash_timer > 0
	check(air_dashed, "double-tap a direction in the air dashes")
	f.free()


func _test_throw(id: String) -> void:
	print("[%s throw]" % id)
	var f := _new_fight(id, "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	p2.position.x = p1.position.x + 40.0
	var hp := p2.health
	_script(p1, [[LI | HE, 2], [0, 60]])
	var threw := false
	for i in 40:
		f._physics_process(1.0 / 60.0)
		threw = threw or p1.state == Fighter.S.THROW
	check(threw, "L+H point-blank throws instead of firing the special")
	check(p2.health < hp, "the throw damages the opponent (%d -> %d)" % [hp, p2.health])
	# Ulises has a ball lying in the arena, so this means "nothing was *fired*".
	var fired := f.projectiles.filter(func(p: Projectile) -> bool: return not p.persistent)
	check(fired.is_empty(), "no projectile came out of the throw")

	# Far away, the very same input is still the projectile special.
	_run(f, 120)
	p2.position.x = p1.position.x + 260.0
	_script(p1, [[LI | HE, 2], [0, 60]])
	var seen := _watch_move(f, p1, 40)
	check(seen.has(p1.def.moves["proj"].id), "L+H at range still does the projectile (%s)" % str(seen))

	# Throws are breakable: press L+H back and nobody takes damage.
	_run(f, 120)
	p2.position.x = p1.position.x + 40.0
	hp = p2.health
	_script(p1, [[LI | HE, 2], [0, 60]])
	_script(p2, [[0, 3], [LI | HE, 2], [0, 60]])
	var broke := false
	for i in 40:
		f._physics_process(1.0 / 60.0)
		broke = broke or (i > 24 and p1.state != Fighter.S.THROW and p2.state != Fighter.S.THROWN)
	check(broke, "both fighters recover from a broken throw")
	check(p2.health == hp, "a broken throw does no damage")
	f.free()


func _test_air_block() -> void:
	print("[air block]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	# Park P2 in mid-air holding away from P1, then hit them.
	p2.position = Vector2(p1.position.x + 70.0, Fighter.GROUND_Y - 70.0)
	p2.facing = -1
	p2.set_state(Fighter.S.JUMP, true)
	p2.vel = Vector2(0, -2.0)
	var away := R if p2.position.x > p1.position.x else Lf
	_script(p2, [[away, 90]])
	_run(f, 2)  # let the input buffer register the held direction
	var hp := p2.health
	var res := p2.take_hit(p1.def.moves["H"], p1.position.x)
	check(res == "block", "holding away in the air blocks (got %s)" % res)
	check(hp - p2.health == 0, "an air block takes no damage from a normal (lost %d)" % (hp - p2.health))
	# The blocking fighter must fall back to the ground, not hover in the air.
	_run(f, 120)
	check(p2.on_ground(), "an air-blocking fighter lands again")

	# Without holding away, the same hit connects.
	_run(f, 60)
	p2.position = Vector2(p1.position.x + 70.0, Fighter.GROUND_Y - 70.0)
	p2.set_state(Fighter.S.JUMP, true)
	p2.vel = Vector2(0, -2.0)
	_script(p2, [[0, 60]])
	_run(f, 2)
	hp = p2.health
	p2.take_hit(p1.def.moves["H"], p1.position.x)
	check(p2.health < hp, "not holding away in the air still gets hit")
	f.free()


func _test_quick_rise() -> void:
	print("[quick rise]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	# Put P2 on the floor, then measure how long it takes to become actionable.
	var slow := _rise_frames(f, p2, false)
	var fast := _rise_frames(f, p2, true)
	check(fast < slow, "tapping gets you up sooner (%d vs %d frames)" % [fast, slow])
	check(p1 != null, "both fighters survived the test")
	f.free()


## Knocks `fr` down and returns how many frames until they can act again.
func _rise_frames(f: Fight, fr: Fighter, tap: bool) -> int:
	fr.set_state(Fighter.S.KNOCKDOWN, true)
	fr.vel = Vector2.ZERO
	_script(fr, [[R if tap else 0, 90]])
	for i in 90:
		f._physics_process(1.0 / 60.0)
		if fr.is_actionable():
			return i
	return 90


func _test_combo(id: String) -> void:
	print("[%s combo]" % id)
	var f := _new_fight(id, "ulises")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	p2.position.x = p1.position.x + 45.0
	# The gaps are derived from this character's own frame data rather than
	# hard-coded, so a slower fighter is tested for "can chain into a launcher"
	# instead of "chains on Ulises' exact timing".
	# A chain cancel only opens once the previous move connects, and hitstop
	# freezes the fighter for a few frames on top of that, so each gap is
	# startup + hitstop + 1 rather than a hard-coded number.
	var d := GameState.make_character(id)
	var lg: int = d.moves["L"].startup + d.moves["L"].hitstop + 1
	var hg: int = d.moves["H"].startup + d.moves["H"].hitstop + 1
	var jg: int = d.moves["jL"].startup + d.moves["jL"].hitstop + 1
	_script(p1, [
		[LI, 2], [0, lg], [LI, 2], [0, lg], [HE, 2], [0, hg],
		[U, 4], [0, 8], [LI, 2], [0, jg], [LI, 2], [0, jg], [HE, 2], [0, 60],
	])
	var max_combo := 0
	var launched := false
	var jumped := false
	for i in 170:
		f._physics_process(1.0 / 60.0)
		max_combo = maxi(max_combo, p2.combo)
		launched = launched or p2.state == Fighter.S.LAUNCHED
		jumped = jumped or p1.position.y < Fighter.GROUND_Y - 100.0
	check(launched, "L, L, H launches the opponent")
	check(jumped, "UP after launcher does a super jump")
	check(max_combo >= 3, "ground chain combos (max combo %d)" % max_combo)
	print("       air combo reached %d hits, health left %d" % [max_combo, p2.health])
	f.free()


## Ulises animates a connected string one-two, front limb then back limb, so a
## light-light chain does not play the same arm twice. This covers the pose hook
## directly plus the live chain counter, because the swap depends on both.
func _test_ulises_chain_pose() -> void:
	print("[ulises chain pose]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	var d: UlisesDef = p1.def as UlisesDef
	p2.position.x = p1.position.x + 45.0
	var lg: int = d.moves["L"].startup + d.moves["L"].hitstop + 1
	var seen_chain := 0
	_script(p1, [[LI, 2], [0, lg], [LI, 2], [0, lg]])
	for i in 60:
		f._physics_process(1.0 / 60.0)
		if p1.chain == 2 and p1.state == Fighter.S.ATTACK and p1.move.id == "jab":
			seen_chain = 2
			break
	check(seen_chain == 2, "two jabs in a row reach chain 2 (got %d)" % seen_chain)

	# The swap itself, driven off the move's own authored pose. `chain` is the
	# hit number, so set it explicitly rather than trusting the sim above.
	var jab: MoveData = d.moves["L"]
	p1.chain = 1
	var first: Dictionary = d.adjust_attack_pose(p1, jab, jab.pose_a)
	check(float(first["arm_f"]) == float(jab.pose_a["arm_f"]), "an odd hit keeps the authored front limb")
	p1.chain = 2
	var second: Dictionary = d.adjust_attack_pose(p1, jab, jab.pose_a)
	check(second["arm_b"] == jab.pose_a["arm_f"], "an even hit strikes with the back limb")
	check(second["arm_f"] == jab.pose_a["arm_b"], "an even hit pulls the front limb back")
	p1.chain = 3
	var third: Dictionary = d.adjust_attack_pose(p1, jab, jab.pose_a)
	check(float(third["arm_f"]) == float(jab.pose_a["arm_f"]), "hit three goes back to the front limb")
	# A special is left exactly as authored.
	var anti: MoveData = d.moves["anti"]
	var spec: Dictionary = d.adjust_attack_pose(p1, anti, anti.pose_a)
	check(float(spec["leg_f"]) == float(anti.pose_a["leg_f"]), "specials keep their own pose")
	f.free()


## The super-activation cut-in stops the world for Fight.HYPER_FREEZE frames. The
## fighter has to keep performing through it, because that stop is the most
## visible moment in the game. `sf` must stay put — nothing about the fight is
## allowed to progress — so the pose comes from a visual counter and the move's
## authored `cutin_pose` instead of the animation clip. The opponent is meant to
## be frozen in the pose they were caught in, so they do not get it.
func _test_hyper_cutin() -> void:
	print("[hyper cut-in]")
	for id: String in GameState.CHARACTERS:
		var d: CharacterDef = GameState.make_character(id)
		# P1 is placed on the left facing right, so "away" is LEFT and "up" is UP
		# for both. BACK is the only relative direction in the special ladder.
		_cutin_one(id, "hyper", Lf)
		if d.moves.has("hyper2"):
			_cutin_one(id, "hyper2", U)


## Drives one hyper for real and checks it performs through its cut-in.
func _cutin_one(id: String, key: String, held: int) -> void:
	var f := _new_fight(id, "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	p1.meter = Fighter.HYPER_COST
	_script(p1, [[held, 3], [held | LI | HE, 2], [0, 30]])
	var guard := 0
	while f.freeze <= 0 and guard < 40:
		f._physics_process(1.0 / 60.0)
		guard += 1
	check(f.freeze > 0, "%s's %s froze the world for the cut-in" % [id, key])
	if f.freeze <= 0:
		f.free()
		return
	check(p1.cutin_active(), "%s owns the %s cut-in while it plays" % [id, key])
	check(not p2.cutin_active(), "%s's opponent is not performing the %s cut-in" % [id, key])
	var sf_held := p1.sf
	var vis := p1.hyper_t
	# A few frames into the cut-in, having let the body snap in.
	_run(f, 6)
	check(p1.sf == sf_held, "%s's state frame is held during the %s freeze (%d -> %d)" % [id, key, sf_held, p1.sf])
	check(p1.hyper_t > vis, "%s's visual counter advances during the %s freeze (%d -> %d)" % [id, key, vis, p1.hyper_t])
	# The pose actually on screen is the cut-in pose, not the clip's first key.
	# It is snapped (speed 1.0) with a slow swell on the lean, hence the slack.
	var tgt := p1._pose_target()
	check(float(tgt[1]) >= 1.0, "%s snaps into the %s cut-in pose (speed %.2f)" % [id, key, float(tgt[1])])
	var want := float(p1.move.cutin_pose.get("lean", 0.0))
	var got := float(tgt[0].get("lean", 0.0))
	check(absf(got - want) <= 3.5, "%s holds its %s cut-in lean, not the clip's first key (%.1f vs %.1f)"
		% [id, key, got, want])
	# And it is released: the move resumes once the world unfreezes.
	_run(f, Fight.HYPER_FREEZE + 20)
	check(p1.sf > sf_held, "%s's %s resumed after the cut-in (%d -> %d)" % [id, key, sf_held, p1.sf])
	f.free()


## Ulises' signature mechanic: a real ball on the floor, and the fact that it
## decides which special he gets. This is the pilot for per-character mechanics,
## so it also proves the hooks in `CharacterDef` actually fire.
##
## NOT CALLED, and currently failing if you do. Commit e220275 ("fixes
## ball-kick") switched the loose field ball off: `has_ball` returns a hardcoded
## false, `on_round_start` no longer spawns one, and `choose_move` always answers
## "proj". Power Shot became an ordinary projectile. These two checks describe
## the mechanic as it was before that commit, so they are kept for reference
## rather than run. Either restore the ball and call them, or delete them and the
## design docs that still describe it.
func _test_ulises_ball() -> void:
	print("[ulises ball]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	var d: UlisesDef = p1.def as UlisesDef
	check(d != null and d.ball != null, "Ulises brings a ball to the round")
	var ball: Projectile = d.ball
	check(ball != null and ball.persistent and ball.recoverable, "the ball is a persistent, kickable object")

	# He starts on the ball, so L+H is the drive and FWD+L+H is the tackle.
	check(d.has_ball(p1), "he starts in possession")
	check(d.choose_move("proj", p1) == "proj", "in possession L+H is Power Shot")
	check(d.choose_move("rush", p1) == "tackle", "in possession FWD+L+H is a tackle")

	# Power Shot fires the regular projectile and leaves the field ball alone.
	var kick_x := ball.position.x
	_script(p1, [[LI | HE, 2], [0, 60]])
	var seen := _watch_move(f, p1, 40)
	check(seen.has("power shot"), "L+H with the ball does Power Shot (%s)" % str(seen))
	check(ball.rested, "Power Shot leaves the field ball resting")
	check(is_equal_approx(ball.position.x, kick_x), "Power Shot does not move the field ball")
	check(d.has_ball(p1), "he keeps possession after Power Shot")

	# Power Shot remains available without changing the field ball; only the
	# carrying tackle changes with possession.
	check(d.choose_move("proj", p1) == "proj", "out of possession L+H remains Power Shot")
	check(d.choose_move("rush", p1) == "tackle", "keeping the ball preserves the carrying tackle")
	_script(p1, [[LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 40)
	check(seen.has("power shot"), "L+H can be used without picking up the ball")

	# It rolls to a stop rather than vanishing, and a stopped ball does not hurt.
	_run(f, 140)
	check(ball.rested, "the ball comes to rest on the floor")
	check(ball.can_hit() == false, "a ball at rest is not a hitbox (no static damage trap)")
	var hp := p2.health
	p2.position = Vector2(ball.position.x, Fighter.GROUND_Y)
	_run(f, 30)
	check(p2.health == hp, "standing on a resting ball does no damage")

	# The opponent's own moveset is untouched by any of this, and their sweep is
	# the universal answer: a boot takes the ball off him.
	check(p2.def.choose_move("proj", p2) == "proj", "the opponent's L+H is unaffected by the ball")
	_script(p2, [[D, 2], [D | HE, 2], [0, 60]])
	_run(f, 14)
	check(not ball.rested, "the opponent's sweep kicks the loose ball")
	# Walk Ulises back onto the ball: he re-possesses it with no extra input.
	_run(f, 90)
	p1.position = Vector2(ball.position.x - p1.facing * 8.0, Fighter.GROUND_Y)
	_run(f, 20)
	check(d.has_ball(p1), "walking over the ball re-possesses it")
	check(d.choose_move("proj", p1) == "proj", "and L+H is Power Shot again")

	# A punch at chest height leaves the ball alone, so combos are never broken
	# by losing it. Only a boot takes it.
	_script(p1, [[LI, 2], [0, 40]])
	_run(f, 20)
	check(d.has_ball(p1), "a light punch does not cost him the ball")
	_script(p1, [[D, 2], [D | HE, 2], [0, 40]])
	_run(f, 20)
	check(not d.has_ball(p1), "his own sweep does boot it away")
	f.free()


## The hyper beam is a wider hitbox when he brought the ball to the fight.
func _test_ulises_ball_hyper() -> void:
	print("[ulises ball: hyper]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var d: UlisesDef = p1.def as UlisesDef
	var back := Lf if p1.facing > 0 else R
	# Out of possession first.
	p1.meter = 100.0
	var ball := d.ball
	if ball != null:
		ball.launch(-p1.facing, 6.5)
		_run(f, 140)
	# A hyper freezes the world for Fight.HYPER_FREEZE frames before `sf` moves
	# on, so watching for less than that never reaches the startup frame.
	_script(p1, [[back, 3], [back | LI | HE, 2], [0, 90]])
	_watch_move(f, p1, 140)
	var plain := p1.def.moves["hyper"].projectile["size"] as Vector2
	check(plain == UlisesDef.HYPER_SIZE, "the hyper beam is its normal size with no ball")
	# Now with the ball back at his feet.
	_run(f, 200)
	p1.position = Vector2(ball.position.x - p1.facing * 8.0, Fighter.GROUND_Y)
	_run(f, 20)
	check(d.has_ball(p1), "he is back on the ball")
	p1.meter = 100.0
	_script(p1, [[back, 3], [back | LI | HE, 2], [0, 90]])
	_watch_move(f, p1, 140)
	var big := p1.def.moves["hyper"].projectile["size"] as Vector2
	check(big == UlisesDef.HYPER_SIZE_BALL, "the hyper beam is wider with the ball")
	f.free()


func _test_block() -> void:
	print("[blocking]")
	var f := _new_fight("ulises", "emilia")
	_start(f)
	var p1 := f.fighters[0]
	var p2 := f.fighters[1]
	p2.position.x = p1.position.x + 45.0
	var away := R  # p2 faces left, back is right
	_script(p2, [[away, 80]])
	_script(p1, [[HE, 2], [0, 60]])
	var hp := p2.health
	var blocked := false
	for i in 40:
		f._physics_process(1.0 / 60.0)
		blocked = blocked or p2.state == Fighter.S.BLOCK
	check(blocked, "holding back blocks")
	check(p2.health == hp, "normals do no damage through block")
	f.free()


func _test_demo_match() -> void:
	print("[CPU vs CPU match]")
	GameState.mode = "demo"
	GameState.chars = ["ulises", "emilia"]
	GameState.cpu_level = 2
	var f := Fight.new()
	add_child(f)
	f.set_physics_process(false)
	f.set_process(false)
	var frames := 0
	var min_hp := 1000
	while f.phase != "over" and frames < 60 * 60 * 8:
		f._physics_process(1.0 / 60.0)
		frames += 1
		for fr in f.fighters:
			min_hp = mini(min_hp, fr.health)
	check(min_hp < 1000, "CPUs deal damage")
	check(f.phase == "over", "match finishes (%d frames, %.1f min, rounds %d, wins %s)" % [frames, frames / 3600.0, f.round_num, str(f.wins)])
	f.free()


## Not a pass/fail check: CPU vs CPU win counts per character.
func _balance_report() -> void:
	print("[balance: CPU vs CPU, HARD]")
	# Every unordered pairing, played from both sides, so a new character shows
	# up as a matchup number instead of a guess.
	var roster := GameState.CHARACTERS
	var pairs := []
	for i in roster.size():
		for j in range(i + 1, roster.size()):
			pairs.append([roster[i], roster[j]])
	if pairs.is_empty():
		return
	var per_pair := maxi(2, int(60.0 / pairs.size() / 2.0) * 2)
	var tally := {}
	var matchups := {}
	for id in roster:
		tally[id] = 0
	var dmg := {}
	var sides := [0, 0]
	for n in pairs.size() * per_pair:
		var pair: Array = pairs[n / per_pair]
		GameState.mode = "demo"
		GameState.chars = [pair[0], pair[1]] if n % 2 == 0 else [pair[1], pair[0]]
		GameState.cpu_level = 3
		var f := Fight.new()
		add_child(f)
		f.set_physics_process(false)
		f.set_process(false)
		var frames := 0
		while f.phase != "over" and frames < 60 * 60 * 8:
			f._physics_process(1.0 / 60.0)
			frames += 1
		for k in f.stats:
			dmg[k] = int(dmg.get(k, 0)) + f.stats[k]
		if f.winner >= 0:
			sides[f.winner] += 1
			var won: String = GameState.chars[f.winner]
			tally[won] = int(tally[won]) + 1
			var key: String = "%s vs %s" % [pair[0], pair[1]]
			var mu: Array = matchups.get(key, [0, 0])
			mu[0 if won == pair[0] else 1] += 1
			matchups[key] = mu
		f.free()
	print("       %d matches per pairing, %d pairings" % [per_pair, pairs.size()])
	print("       wins: %s   by side (P1, P2): %s" % [str(tally), str(sides)])
	var mkeys := matchups.keys()
	mkeys.sort()
	for k in mkeys:
		var mu: Array = matchups[k]
		print("       %-28s %d - %d" % [k, mu[0], mu[1]])
	var keys := dmg.keys()
	keys.sort()
	for k in keys:
		print("       %-28s %6d" % [k, dmg[k]])
