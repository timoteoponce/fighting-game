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
