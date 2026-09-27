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
	for id in ["ulises", "emilia"]:
		_test_specials(id)
		_test_combo(id)
	_test_movement("ulises")
	_test_throw("ulises")
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
	var moves: Dictionary = p1.def.moves
	_script(p1, [[LI | HE, 2], [0, 60]])
	var seen := _watch_move(f, p1, 40)
	check(seen.has(moves["proj"].id), "L+H does projectile (%s)" % str(seen))
	check(f.projectiles.size() > 0 or seen.has(moves["proj"].id), "projectile spawned")
	_run(f, 80)
	# L then H two frames later should still become the special.
	_script(p1, [[LI, 2], [LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 40)
	check(seen.has(moves["proj"].id), "L, then H 2 frames later, still does projectile (%s)" % str(seen))
	_run(f, 120)
	_script(p1, [[R, 3], [R | LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 50)
	check(seen.has(moves["rush"].id), "FWD+L+H does rush (%s)" % str(seen))
	_run(f, 120)
	_script(p1, [[D, 3], [D | LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 50)
	check(seen.has(moves["anti"].id), "DOWN+L+H does anti-air (%s)" % str(seen))
	_run(f, 120)
	p1.meter = 100.0
	var back := Lf if p1.facing > 0 else R
	_script(p1, [[back, 3], [back | LI | HE, 2], [0, 60]])
	seen = _watch_move(f, p1, 60)
	check(seen.has(moves["hyper"].id), "BACK+L+H with full meter does hyper (%s)" % str(seen))
	check(p1.meter < 1.0, "hyper spends the meter")
	var hp := f.fighters[1].health
	_run(f, 200)
	check(f.fighters[1].health < hp, "hyper damages the opponent (%d -> %d)" % [hp, f.fighters[1].health])
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
	check(f.projectiles.is_empty(), "no projectile came out of the throw")

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
	_script(p1, [[LI, 2], [0, 6], [LI, 2], [0, 8], [HE, 2], [0, 14], [U, 4], [0, 8], [LI, 2], [0, 6], [LI, 2], [0, 7], [HE, 2], [0, 60]])
	var max_combo := 0
	var launched := false
	var jumped := false
	for i in 120:
		f._physics_process(1.0 / 60.0)
		max_combo = maxi(max_combo, p2.combo)
		launched = launched or p2.state == Fighter.S.LAUNCHED
		jumped = jumped or p1.position.y < Fighter.GROUND_Y - 100.0
	check(launched, "L, L, H launches the opponent")
	check(jumped, "UP after launcher does a super jump")
	check(max_combo >= 3, "ground chain combos (max combo %d)" % max_combo)
	print("       air combo reached %d hits, health left %d" % [max_combo, p2.health])
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
	var tally := {"ulises": 0, "emilia": 0}
	var dmg := {}
	var sides := [0, 0]
	for n in 60:
		GameState.mode = "demo"
		GameState.chars = ["ulises", "emilia"] if n % 2 == 0 else ["emilia", "ulises"]
		GameState.cpu_level = 2
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
			tally[GameState.chars[f.winner]] += 1
		f.free()
	print("       wins: %s   by side (P1, P2): %s" % [str(tally), str(sides)])
	var keys := dmg.keys()
	keys.sort()
	for k in keys:
		print("       %-28s %6d" % [k, dmg[k]])
