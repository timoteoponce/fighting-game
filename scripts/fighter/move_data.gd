class_name MoveData
extends Resource
## Frame data and hit properties for one attack (or one projectile's hits).
## Hitboxes are relative to the fighter's feet, facing right.

var id := ""
var display := ""
var level := 0  # 0 light, 1 heavy, 2 special, 3 hyper (higher cancels lower)
var startup := 5
var active := 3
var recovery := 10
var damage := 50
var hitbox := Rect2()
var hitstun := 16
var blockstun := 10
var kb := Vector2(2.5, 0.0)  # knockback (x away from attacker, y up is negative)
var launch := false  # sends a grounded opponent into the air
var knockdown := false
var spike := false  # slams an airborne opponent down
var chip := 0.0  # fraction of damage dealt through block
var hitstop := 5
var flash := 0  # full-screen white flash frames on hit (0 = none)
var shake := 0.0  # extra screen shake on hit (added to the level-derived base)
var meter := 5.0
## What a level 3 move costs. 0 means "the default" (`Fighter.HYPER_COST`), so
## only the 3-bar EX versions set it and nobody has to restate the price on
## every super. See `Fighter.hyper_cost`.
var meter_cost := 0
var hits := 1
var hit_interval := 0
var air := false
var crouch := false
var dash_speed := 0.0
var dash_from := 0
var dash_to := 0
var rise_vel := Vector2.ZERO
var rise_frame := 0
var invuln := 0
var projectile := {}
var pose_s := {}  # pose during startup
var pose_a := {}  # pose while active / recovering
## Pose merged in while the hit freeze plays, so a connecting move visibly
## bites instead of only stopping the world. Empty = no impact emphasis.
var contact_pose := {}
## The pose the fighter snaps into and holds through the super-activation
## cut-in. `Fight` stops the simulation for `HYPER_FREEZE` frames there, so `sf`
## cannot advance and the animation clip would sit on its first key for the whole
## cinematic — a hyper that looks like it never moved. Authoring this separately
## is what makes the freeze read as a charge. Empty = no cut-in pose.
var cutin_pose := {}
## Animation clip: [[frame, pose, speed], ...] in ascending order of state frame.
## Each key sets a new pose *target*; the renderer's springs do the in-between,
## so two keys 6 frames apart read as one smooth motion, not a snap. Leave this
## empty and the move falls back to the two-pose pose_s / pose_a form.
var keys := []
## FX and sound track: state frame -> [[kind, data], ...].
## Kinds: "slash", "fx", "sfx", "voice", "shake", "dust". See Fighter._fire_event.
var events := {}
var spin := 0.0  # body rotation in degrees across the move
## This move boots a ball lying on the floor (Ulises' mechanic). Moves whose
## hitbox reaches the ground get that for free — see `Fight._kicks`.
var kicks := false
var sfx := "whoosh"
var hit_sfx := "light"
var prop := ""
var _built := false


func total() -> int:
	return startup + active + recovery


## Builds the clip and the default events the first time they're needed.
func _build() -> void:
	if _built:
		return
	_built = true
	if keys.is_empty():
		keys = [[0, pose_s, 0.55], [startup + 1, pose_a, 0.6]]
	# Every move with a hitbox gets a swoosh on its first active frame unless
	# the character authored its own event on that frame.
	if hitbox.size != Vector2.ZERO and not events.has(startup + 1):
		events[startup + 1] = [["slash", {}]]


## Pose target and spring speed at state frame `sf`: the last key at or before it.
func pose_at(sf: int) -> Array:
	_build()
	var best: Array = keys[0]
	for k in keys:
		if int(k[0]) > sf:
			break
		best = k
	return [best[1], float(best[2])]


## The [kind, data] pairs authored on exactly this state frame.
func events_at(sf: int) -> Array:
	_build()
	return events.get(sf, [])


## Accepts "name", ["name", {data}] or [["name", {}], ["other", {}]].
static func _norm_events(v) -> Array:
	if v is String:
		return [[v, {}]]
	var a: Array = v
	if a.is_empty():
		return []
	if a[0] is String:
		return [[a[0], a[1] if a.size() > 1 else {}]]
	var out := []
	for e in a:
		out.append_array(_norm_events(e))
	return out


static func make(d: Dictionary) -> MoveData:
	var m := MoveData.new()
	for k in d:
		if k == "keys":
			var clip := []
			for e in d[k]:
				var key: Array = e
				clip.append([int(key[0]), key[1], float(key[2]) if key.size() > 2 else 0.6])
			clip.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
			if clip.is_empty() or int(clip[0][0]) > 0:
				clip.push_front([0, {}, 0.55])
			m.keys = clip
		elif k == "events":
			var ev := {}
			for f in d[k]:
				ev[int(f)] = _norm_events(d[k][f])
			m.events = ev
		else:
			m.set(k, d[k])
	return m
