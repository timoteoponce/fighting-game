class_name CpuInput
extends RefCounted
## Computer opponent. Produces the same button masks a human would, so the
## fighter code can't tell the difference.

const FWD := 256
const BACK := 512

const U := Controls.UP
const D := Controls.DOWN
const L := Controls.LIGHT
const H := Controls.HEAVY

var level := 1
var queue: Array = []  # [[relative mask, frames], ...]
var think := 30
var block_timer := 0
var rng := RandomNumberGenerator.new()
var _seen_attack := false
var _seen_projectile := false

# Per level: EASY, NORMAL, HARD
const THINK := [26, 15, 8]
const BLOCK_P := [0.15, 0.45, 0.8]
const ANTI_AIR_P := [0.15, 0.45, 0.8]
const COMBO_DROP_P := [0.5, 0.2, 0.0]


func _init(lvl: int) -> void:
	level = clampi(lvl, 0, 2)
	rng.randomize()


func is_human() -> bool:
	return false


func sample(f: Fighter) -> int:
	var o := f.opponent
	_react(f, o)
	var mask := 0
	if not queue.is_empty():
		var step: Array = queue[0]
		mask = step[0]
		step[1] -= 1
		if step[1] <= 0:
			queue.pop_front()
	elif block_timer > 0:
		block_timer -= 1
		mask = BACK
		if o.move and o.move.crouch:
			mask |= D
	else:
		think -= 1
		if think <= 0:
			think = THINK[level] + rng.randi_range(0, THINK[level])
			_decide(f, o)
	return _to_abs(mask, f.facing)


func _react(f: Fighter, o: Fighter) -> void:
	# Roll once per incoming attack / projectile to decide whether to block it.
	var attacking := o.state == Fighter.S.ATTACK
	if attacking and not _seen_attack and queue.is_empty() and f.is_actionable():
		if absf(o.position.x - f.position.x) < 200 and rng.randf() < BLOCK_P[level]:
			block_timer = 24
			queue.clear()
	_seen_attack = attacking
	var proj := false
	for p in f.fight.projectiles:
		if p.owner_f == o:
			proj = true
	if proj and not _seen_projectile and f.is_actionable() and rng.randf() < BLOCK_P[level]:
		block_timer = 40
	_seen_projectile = proj


func _decide(f: Fighter, o: Fighter) -> void:
	var dx := absf(o.position.x - f.position.x)
	var r := rng.randf()
	if f.launch_window > 0:
		_q([[U, 3], [0, 8], [L, 2], [0, 6], [L, 2], [0, 7], [H, 2], [0, 10]])
	elif f.meter >= 100 and dx < 320 and r < 0.35:
		_q([[BACK, 3], [BACK | L | H, 3], [0, 20]])
	elif o.state == Fighter.S.JUMP and dx < 130 and r < ANTI_AIR_P[level]:
		_q([[D | L | H, 3], [0, 10]])
	elif dx > 260:
		if r < 0.35:
			_q([[L | H, 3], [0, 25]])
		elif r < 0.75:
			_q([[FWD, rng.randi_range(20, 45)]])
		elif r < 0.85:
			_q([[U | FWD, 4], [0, 30]])
		else:
			_q([[0, 20]])
	elif dx > 100:
		if r < 0.2:
			_q([[FWD | L | H, 3], [0, 25]])
		elif r < 0.6:
			_q([[FWD, rng.randi_range(12, 30)]])
		elif r < 0.75:
			_q([[U | FWD, 4], [0, 14], [H, 2], [0, 20]])
		elif r < 0.88:
			_q([[L | H, 3], [0, 25]])
		else:
			_q([[BACK, 20]])
	else:
		if r < 0.5:
			var seq := [[L, 2], [0, 5], [L, 2], [0, 7], [H, 2], [0, 12]]
			if rng.randf() < COMBO_DROP_P[level]:
				seq = [[L, 2], [0, 14]]
			_q(seq)
		elif r < 0.62:
			_q([[D | L, 2], [0, 6], [D | H, 2], [0, 20]])
		elif r < 0.72:
			_q([[D | L | H, 3], [0, 25]])
		elif r < 0.85:
			_q([[BACK, 20]])
		else:
			_q([[U | BACK, 4], [0, 30]])


func _q(seq: Array) -> void:
	queue = seq.duplicate(true)


func _to_abs(mask: int, facing: int) -> int:
	var out := mask & ~(FWD | BACK)
	if mask & FWD:
		out |= Controls.RIGHT if facing > 0 else Controls.LEFT
	if mask & BACK:
		out |= Controls.LEFT if facing > 0 else Controls.RIGHT
	return out
