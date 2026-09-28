class_name FighterRenderer
extends Node2D
## Draws an anime-style fighter from code: cel-shaded tapered limbs, a posable
## skeleton, and simulated "chains" for hair, capes and headband tails.
##
## Angles are in degrees. Limbs: 0 = hanging straight down, 90 = pointing
## forward, 180 = pointing up. Knees bend backwards, elbows bend forwards.
## "lean" tilts the torso forward, "rot" spins the whole body around the hip.
## Everything is drawn facing right (local +x); `facing` mirrors it.

const OUT := Color(0.06, 0.04, 0.09)
const LIGHT := Vector2(0.45, -0.89)  # light comes from the front and above
const THIGH := 21.0
const SHIN := 21.0
const TORSO := 30.0
const NECK := 4.0
const UPPER := 15.0
const FORE := 14.0
const WRIST := 4.0
const ANKLE := 3.5
const HEAD := 11.0
const HEAD_SCALE := 1.45  # default head size; each character sets its own in `CharacterDef.head_scale`
## Ink line weight around every limb and shape. Thinner at full resolution.
const INK := 1.2

const POSES := {
	"idle": {"lean": 6, "head": 0, "arm_f": 30, "elb_f": 80, "arm_b": 45, "elb_b": 95,
		"leg_f": 18, "knee_f": 16, "leg_b": -16, "knee_b": 14, "rot": 0, "hip": -42, "ground": 1},
	"crouch": {"lean": 28, "head": -10, "arm_f": 50, "elb_f": 100, "arm_b": 60, "elb_b": 100,
		"leg_f": 85, "knee_f": 135, "leg_b": 15, "knee_b": 140},
	"block": {"lean": -6, "head": -6, "arm_f": 80, "elb_f": 115, "arm_b": 90, "elb_b": 115,
		"leg_f": 20, "knee_f": 20, "leg_b": -26, "knee_b": 14},
	"crouch_block": {"lean": 20, "head": -10, "arm_f": 90, "elb_f": 110, "arm_b": 100, "elb_b": 110,
		"leg_f": 85, "knee_f": 135, "leg_b": 15, "knee_b": 140},
	"jump": {"lean": 5, "arm_f": 150, "elb_f": 20, "arm_b": -40, "elb_b": 30,
		"leg_f": 60, "knee_f": 95, "leg_b": 5, "knee_b": 70, "ground": 0, "hip": -46},
	"hit": {"lean": -22, "head": -18, "arm_f": -25, "elb_f": 30, "arm_b": -40, "elb_b": 30,
		"leg_f": 22, "knee_f": 10, "leg_b": -20, "knee_b": 10},
	"launched": {"lean": -30, "head": -20, "arm_f": 150, "elb_f": 30, "arm_b": 170, "elb_b": 30,
		"leg_f": 40, "knee_f": 60, "leg_b": 10, "knee_b": 50, "rot": -35, "ground": 0, "hip": -46},
	"down": {"lean": 0, "head": 10, "arm_f": 150, "elb_f": 20, "arm_b": 200, "elb_b": 20,
		"leg_f": 12, "knee_f": 8, "leg_b": -4, "knee_b": 20, "rot": -90, "ground": 0, "hip": -9},
	"win": {"arm_f": 165, "elb_f": 10, "arm_b": 40, "elb_b": 110},
	"dash": {"lean": 34, "head": -12, "arm_f": 10, "elb_f": 60, "arm_b": -45, "elb_b": 55,
		"leg_f": 55, "knee_f": 80, "leg_b": -40, "knee_b": 50, "hip": -38},
	"backdash": {"lean": -18, "head": -8, "arm_f": 60, "elb_f": 100, "arm_b": 80, "elb_b": 100,
		"leg_f": 45, "knee_f": 70, "leg_b": -30, "knee_b": 20, "hip": -40},
	"throw": {"lean": 16, "head": -6, "arm_f": 95, "elb_f": 10, "arm_b": 90, "elb_b": 14,
		"leg_f": 26, "knee_f": 26, "leg_b": -22, "knee_b": 18},
	"thrown": {"lean": -20, "head": -16, "arm_f": 150, "elb_f": 20, "arm_b": 165, "elb_b": 25,
		"leg_f": 30, "knee_f": 40, "leg_b": -12, "knee_b": 30},
	"intro": {},
}

var def: CharacterDef
var colors := {}
var pose := {}
var facing := 1
var base_scale := 1.0
var flash := 0
var t := 0.0
var expr := "normal"
var prop := ""
var prop_t := 0
var head_only := false  # portraits: draw only head and shoulders
var chains := {}  # name -> [points (global), previous points (global)]
var sk := {}
var prev_sk := {}  # last frame's skeleton, for motion smears
var pose_vel := {}  # joint spring velocities
## Limbs moving faster than this (pixels per frame) leave a smear behind them.
const SMEAR_MIN := 7.0

## Squash and stretch — the oldest trick in animation and the single biggest
## thing separating a cartoon from a puppet. Positive `squash` flattens the
## fighter wide (landing, taking a hit), negative stretches them tall (jumping,
## lunging). Volume is roughly conserved: what we lose in height we gain in
## width, so the character never looks like it simply changed size.
var squash := 0.0
var hs := HEAD_SCALE  # this fighter's head scale, from its CharacterDef
var squash_vel := 0.0
## How hard the effect hits. 0 would be the old rigid look.
const SQUASH_MAX := 0.42
## Emotes floating over the head: "sweat", "vein", "shock", "hearts", "note",
## "stars" (dizzy), "zzz". Each is [kind, frames left, total frames].
var emotes: Array = []
## Frames left of a bugged-out eye-pop, set on big hits.
var eye_pop := 0


## Kicks the squash spring. `amount` is positive to flatten, negative to stretch.
func squish(amount: float) -> void:
	squash_vel += amount


## Floats a little cartoon symbol over the head for `frames`.
func emote(kind: String, frames := 40) -> void:
	for e in emotes:
		if e[0] == kind:
			e[1] = maxi(e[1], frames)
			return
	emotes.append([kind, frames, frames])

## Per-joint spring response: legs snap, torso follows, arms and head trail
## behind with a little overshoot. That lag is what stops the puppet look.
const JOINT_RESPONSE := {
	"leg_f": 1.0, "knee_f": 1.0, "leg_b": 1.0, "knee_b": 1.0, "hip": 1.0,
	"lean": 0.8, "rot": 1.0, "arm_f": 0.75, "elb_f": 0.7, "arm_b": 0.65, "elb_b": 0.6, "head": 0.5,
}


func setup(d: CharacterDef, alt := false) -> void:
	def = d
	hs = d.head_scale
	colors = d.alt_colors if alt else d.colors
	pose = d.pose("idle")
	chains.clear()


func update_pose(target: Dictionary, speed: float) -> void:
	for k in target:
		if k == "ground" or not pose.has(k) or speed >= 1.0:
			pose[k] = target[k]
			pose_vel[k] = 0.0
			continue
		# Underdamped spring: moves fast, overshoots slightly, settles.
		var stiff := clampf(speed, 0.05, 0.9) * float(JOINT_RESPONSE.get(k, 1.0)) * 0.55
		var v := float(pose_vel.get(k, 0.0)) * 0.62 + (float(target[k]) - float(pose[k])) * stiff
		pose_vel[k] = v
		pose[k] = float(pose[k]) + v
	_step_squash()
	# Volume-conserving scale: squash wide and short, stretch tall and thin.
	var sq := clampf(squash, -SQUASH_MAX, SQUASH_MAX)
	scale = Vector2(base_scale * facing * (1.0 + sq), base_scale * (1.0 - sq))
	modulate = Color(2.2, 2.2, 2.2) if flash > 0 else Color.WHITE
	if eye_pop > 0:
		eye_pop -= 1
	for e in emotes:
		e[1] -= 1
	emotes = emotes.filter(func(e: Array) -> bool: return e[1] > 0)
	prev_sk = sk
	sk = skeleton()
	if is_inside_tree() and def != null:
		def.update_chains(self, sk)
	queue_redraw()


## A springy return to neutral, so a squash always bounces back through a small
## stretch instead of snapping. That overshoot is what reads as "rubbery".
func _step_squash() -> void:
	squash_vel = squash_vel * 0.72 - squash * 0.28
	squash = clampf(squash + squash_vel, -SQUASH_MAX, SQUASH_MAX)
	if absf(squash) < 0.002 and absf(squash_vel) < 0.002:
		squash = 0.0
		squash_vel = 0.0


## Copies another renderer's current look (used for afterimages).
func copy_from(src: FighterRenderer) -> void:
	def = src.def
	colors = src.colors
	pose = src.pose.duplicate()
	facing = src.facing
	base_scale = src.base_scale
	expr = src.expr
	prop = src.prop
	prop_t = src.prop_t
	t = src.t
	squash = src.squash
	hs = src.hs
	eye_pop = src.eye_pop
	chains = src.chains.duplicate(true)
	scale = src.scale
	global_position = src.global_position
	sk = src.sk.duplicate()
	prev_sk = src.prev_sk.duplicate()
	queue_redraw()


## A point given in head space (as the hair is drawn), in local space.
static func head_point(s: Dictionary, p: Vector2) -> Vector2:
	return s["head"] + (p * float(s.get("hs", HEAD_SCALE))).rotated(s["head_ang"])


static func dir(a: float) -> Vector2:
	var r := deg_to_rad(a)
	return Vector2(sin(r), cos(r))


func skeleton() -> Dictionary:
	var p := pose
	var lean := deg_to_rad(float(p["lean"]))
	var up := Vector2(sin(lean), -cos(lean))
	var perp := Vector2(-up.y, up.x)
	var s := {}
	s["hip"] = Vector2.ZERO
	s["hip_f"] = perp * 2.0
	s["hip_b"] = -perp * 2.0
	s["knee_f"] = s["hip_f"] + dir(p["leg_f"]) * THIGH
	s["ankle_f"] = s["knee_f"] + dir(p["leg_f"] - p["knee_f"]) * SHIN
	s["foot_f"] = s["ankle_f"] + dir(p["leg_f"] - p["knee_f"] + 90.0) * ANKLE
	s["knee_b"] = s["hip_b"] + dir(p["leg_b"]) * THIGH
	s["ankle_b"] = s["knee_b"] + dir(p["leg_b"] - p["knee_b"]) * SHIN
	s["foot_b"] = s["ankle_b"] + dir(p["leg_b"] - p["knee_b"] + 90.0) * ANKLE
	s["neck"] = up * TORSO
	# Torso twist: a reaching front arm drags its shoulder forward, the back one pulls away.
	var twist := clampf((float(p["arm_f"]) - 45.0) / 50.0, -0.6, 1.0)
	s["sh_f"] = up * (TORSO - 3.0 - absf(twist) * 1.5) + perp * (1.5 + twist * 4.0)
	s["sh_b"] = up * (TORSO - 2.5) - perp * (3.0 + twist * 2.0)
	s["elb_f"] = s["sh_f"] + dir(p["arm_f"]) * UPPER
	s["wrist_f"] = s["elb_f"] + dir(p["arm_f"] + p["elb_f"]) * FORE
	s["hand_f"] = s["wrist_f"] + dir(p["arm_f"] + p["elb_f"] + 15.0) * WRIST
	s["elb_b"] = s["sh_b"] + dir(p["arm_b"]) * UPPER
	s["wrist_b"] = s["elb_b"] + dir(p["arm_b"] + p["elb_b"]) * FORE
	s["hand_b"] = s["wrist_b"] + dir(p["arm_b"] + p["elb_b"] + 15.0) * WRIST
	var head_ang := lean * 0.5 + deg_to_rad(float(p["head"]))
	s["head"] = s["neck"] + up.rotated(head_ang - lean) * (NECK + HEAD * 0.8 * hs)
	var rot := deg_to_rad(float(p["rot"]))
	var pts := ["hip", "hip_f", "hip_b", "knee_f", "ankle_f", "foot_f", "knee_b", "ankle_b", "foot_b",
		"neck", "sh_f", "sh_b", "elb_f", "wrist_f", "hand_f", "elb_b", "wrist_b", "hand_b", "head"]
	for k in pts:
		s[k] = (s[k] as Vector2).rotated(rot)
	var offset := Vector2(0, float(p["hip"]))
	if head_only:
		offset = Vector2.ZERO
	elif int(p["ground"]) == 1:
		var low := maxf(maxf(s["foot_f"].y, s["foot_b"].y), maxf(s["knee_f"].y, s["knee_b"].y))
		offset = Vector2(0, -low - 3.0)
	for k in pts:
		s[k] = s[k] + offset
	s["up"] = up.rotated(rot)
	s["perp"] = perp.rotated(rot)
	s["head_ang"] = head_ang + rot
	s["rot"] = rot
	s["hs"] = hs
	s["foot_dir_f"] = dir(p["leg_f"] - p["knee_f"] + 90.0).rotated(rot)
	s["foot_dir_b"] = dir(p["leg_b"] - p["knee_b"] + 90.0).rotated(rot)
	return s


func _draw() -> void:
	if def == null:
		return
	if sk.is_empty():
		sk = skeleton()
	var s := sk
	var c := colors
	if head_only:
		torso(s)
		def.draw_torso(self, s)
		_draw_head(s)
		return
	var b := def.build  # limb thickness: skinny < 1 < chunky
	var open := expr == "happy" or expr == "smug"
	def.draw_behind(self, s)
	_smears(s)
	# Back arm and leg: darker, they're further away.
	part(s["sh_b"], s["elb_b"], 8.0 * b, 7.0 * b, dk(c["sleeve"]))
	part(s["elb_b"], s["wrist_b"], 6.5 * b, 5.5 * b, dk(c["forearm"]))
	_weld_arm(s, "b", b, dk(c["sleeve"]))
	if open:
		open_hand(s["hand_b"], dk(c["hands"]), s["hand_b"] - s["wrist_b"])
	else:
		fist(s["hand_b"], dk(c["hands"]), s["hand_b"] - s["wrist_b"])
	part(s["hip_b"], s["knee_b"], 11.0 * b, 8.5 * b, dk(c["pants"]))
	part(s["knee_b"], s["ankle_b"], 8.5 * b, 6.5 * b, dk(c["legs"]))
	_weld_leg(s, "b", b, dk(c["pants"]))
	shoe(s["foot_b"], s["foot_dir_b"], dk(c["shoes"]))
	torso(s)
	def.draw_torso(self, s)
	part(s["hip_f"], s["knee_f"], 11.0 * b, 8.5 * b, c["pants"])
	part(s["knee_f"], s["ankle_f"], 8.5 * b, 6.5 * b, c["legs"])
	_weld_leg(s, "f", b, c["pants"])
	shoe(s["foot_f"], s["foot_dir_f"], c["shoes"])
	def.draw_over_legs(self, s)
	_draw_head(s)
	part(s["sh_f"], s["elb_f"], 8.0 * b, 7.0 * b, c["sleeve"])
	part(s["elb_f"], s["wrist_f"], 6.5 * b, 5.5 * b, c["forearm"])
	_weld_arm(s, "f", b, c["sleeve"])
	# Props draw before the fist so the hand wraps over them and reads as gripped.
	def.draw_props(self, s)
	if open:
		open_hand(s["hand_f"], c["hands"], s["hand_f"] - s["wrist_f"])
	else:
		fist(s["hand_f"], c["hands"], s["hand_f"] - s["wrist_f"])
	_draw_emotes(s)


## Cartoon symbols floating over the head. This is the vocabulary every kid
## already reads without being taught: a sweat drop means "uh oh", a vein means
## "furious", stars mean "seeing stars". They do more characterisation per pixel
## than anything else we can draw at this size.
func _draw_emotes(s: Dictionary) -> void:
	if emotes.is_empty():
		return
	var head: Vector2 = s["head"]
	for i in emotes.size():
		var e: Array = emotes[i]
		var kind: String = e[0]
		var left := float(e[1])
		var total := float(e[2])
		var k := 1.0 - left / total
		# Pop in fast, fade out over the last third.
		var a := minf(1.0, left / (total * 0.34))
		var grow := minf(1.0, (total - left) / 4.0)
		# Stack multiple emotes so they never sit on top of each other.
		var anchor := head + Vector2(6.0 + i * 13.0, -22.0)
		match kind:
			"sweat":
				# A big bead of sweat sliding down beside the temple.
				var p := anchor + Vector2(-16.0, -2.0 + 9.0 * k)
				var drop := PackedVector2Array([
					p + Vector2(0, -6.5), p + Vector2(3.4, 1.0), p + Vector2(2.4, 4.4),
					p + Vector2(0, 5.2), p + Vector2(-2.4, 4.4), p + Vector2(-3.4, 1.0),
				])
				draw_colored_polygon(drop, Color(0.55, 0.85, 1.0, 0.92 * a))
				draw_polyline(Stage._closed(drop), Color(0.15, 0.45, 0.75, a), 1.1, true)
				draw_circle(p + Vector2(-1.0, 0.6), 1.0, Color(1, 1, 1, 0.85 * a), true, -1.0, true)
			"vein":
				# The four-lobed anger cross. Throbs on a fast pulse.
				var p := anchor + Vector2(0, -2.0)
				var pulse := 1.0 + 0.22 * sin(left * 0.55)
				var col := Color(0.95, 0.2, 0.25, a)
				for arm in 4:
					var ang := TAU * arm / 4.0 + 0.78
					var d := Vector2.from_angle(ang)
					var n := Vector2(-d.y, d.x)
					var r := 6.4 * grow * pulse
					draw_colored_polygon(PackedVector2Array([
						p + n * 1.9 * grow, p + d * r, p - n * 1.9 * grow,
					]), col)
				draw_circle(p, 2.1 * grow * pulse, col, true, -1.0, true)
			"shock":
				# Exclamation burst: something just went very wrong.
				var p := anchor + Vector2(0, -4.0 - 3.0 * grow)
				draw_colored_polygon(star_pts(p, 11.0 * grow, 5.0 * grow, 9, left * 0.05), Color(1, 0.92, 0.3, 0.85 * a))
				draw_colored_polygon(PackedVector2Array([
					p + Vector2(-1.7, -6.0), p + Vector2(1.7, -6.0), p + Vector2(1.1, 1.4), p + Vector2(-1.1, 1.4),
				]), Color(0.15, 0.08, 0.12, a))
				draw_circle(p + Vector2(0, 3.8), 1.5, Color(0.15, 0.08, 0.12, a), true, -1.0, true)
			"hearts":
				for h in 3:
					var ph := left * 0.09 + h * 2.1
					var p := anchor + Vector2(-8.0 + h * 7.0 + sin(ph) * 3.0, -2.0 - fposmod(ph * 2.4, 16.0))
					var r := (3.4 - h * 0.5) * grow
					var col := Color(1.0, 0.35, 0.55, a * 0.9)
					draw_circle(p + Vector2(-r * 0.5, -r * 0.35), r * 0.62, col, true, -1.0, true)
					draw_circle(p + Vector2(r * 0.5, -r * 0.35), r * 0.62, col, true, -1.0, true)
					draw_colored_polygon(PackedVector2Array([
						p + Vector2(-r, -r * 0.2), p + Vector2(r, -r * 0.2), p + Vector2(0, r * 1.25),
					]), col)
			"note":
				for n in 2:
					var ph := left * 0.07 + n * 2.6
					var p := anchor + Vector2(-6.0 + n * 9.0 + sin(ph) * 4.0, -fposmod(ph * 2.2, 18.0))
					var col := Color(0.15, 0.08, 0.12, a)
					draw_line(p + Vector2(3.0, -7.0), p + Vector2(3.0, 1.0), col, 1.4, true)
					draw_colored_polygon(ellipse_pts(p, 3.0, 2.2, -0.4), col)
					draw_colored_polygon(PackedVector2Array([
						p + Vector2(3.0, -7.0), p + Vector2(7.0, -5.6), p + Vector2(7.0, -3.4), p + Vector2(3.0, -5.0),
					]), col)
			"stars":
				# Seeing stars: the dizzy halo. Drawn in the head's own space so
				# it orbits the skull rather than the world.
				for si in 5:
					var ang := left * 0.14 + TAU * si / 5.0
					var p := head + Vector2(cos(ang) * 17.0, -20.0 + sin(ang) * 5.0)
					var r := 4.6 + 1.6 * sin(ang)
					var col := Color(1.0, 0.88, 0.3, a * (0.55 + 0.45 * (sin(ang) * 0.5 + 0.5)))
					draw_colored_polygon(star_pts(p, r, r * 0.42, 5, ang), col)
					draw_polyline(Stage._closed(star_pts(p, r, r * 0.42, 5, ang)), Color(0.5, 0.3, 0.05, a * 0.7), 0.9, true)
			"zzz":
				for z in 3:
					var ph := left * 0.05 + z * 1.4
					var p := anchor + Vector2(z * 6.0, -fposmod(ph * 3.0, 20.0))
					var r := (5.0 - z) * grow
					var col := Color(0.8, 0.9, 1.0, a * 0.9)
					draw_polyline(PackedVector2Array([
						p + Vector2(-r, -r), p + Vector2(r, -r), p + Vector2(-r, r), p + Vector2(r, r),
					]), col, 1.3, true)


## Motion smear: translucent streaks trailing fast limbs. Multiple frames of a
## hard kick read as one continuous arc instead of disconnected legs.
func _smears(s: Dictionary) -> void:
	if prev_sk.is_empty():
		return
	for joint in ["hand_f", "foot_f", "hand_b", "foot_b"]:
		if not prev_sk.has(joint):
			continue
		var a: Vector2 = prev_sk[joint]
		var b: Vector2 = s[joint]
		var d := b - a
		if d.length() < SMEAR_MIN:
			continue
		var w: float = 7.0 if joint.begins_with("foot") else 5.5
		var fade := clampf(d.length() / 40.0, 0.18, 0.5)
		# Two trailing ghosts at different opacities for a smoother arc.
		var mid := a.lerp(b, 0.5)
		draw_colored_polygon(capsule_pts(a, mid, w * 0.3, w * 0.5), Color(1, 1, 1, fade * 0.35))
		draw_colored_polygon(capsule_pts(mid, b, w * 0.35, w * 0.6), Color(1, 1, 1, fade * 0.55))


func _draw_head(s: Dictionary) -> void:
	var c := colors
	var up: Vector2 = s["up"]
	part(s["neck"] - up * 2.0, s["neck"] + up * NECK, 6.0 * def.build, 5.5 * def.build, c["skin"])
	draw_set_transform(s["head"], s["head_ang"], Vector2.ONE * hs)
	def.draw_hair_back(self)
	poly(head_shape(), c["skin"], 2.0)
	# Shadow under the jaw and at the back of the face.
	draw_colored_polygon(PackedVector2Array([Vector2(-8, 2), Vector2(-3, 7.5), Vector2(3, 10.2), Vector2(0, 5), Vector2(-5, 1)]), shade(c["skin"]))
	def.draw_face(self)
	def.draw_hair_front(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func head_shape() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 20:
		var a := deg_to_rad(160.0 + 200.0 * i / 19.0)
		pts.append(Vector2(cos(a), sin(a)) * HEAD + Vector2(0, -3))
	pts.append_array(PackedVector2Array([Vector2(11.6, 1.5), Vector2(10.5, 5.5), Vector2(7, 9.5), Vector2(3, 10.8),
		Vector2(-1, 9.5), Vector2(-5, 6.5), Vector2(-8.5, 3)]))
	return pts


# --- Colors ---------------------------------------------------------------------

static func dk(col: Color) -> Color:
	return col.darkened(0.2)


static func shade(col: Color) -> Color:
	return col.darkened(0.32).lerp(Color(0.25, 0.12, 0.45), 0.15)


static func hl(col: Color) -> Color:
	var h := col.lightened(0.5)
	h.a = 0.9
	return h


# --- Shape helpers (also used by character defs) ----------------------------------

static func capsule_pts(a: Vector2, b: Vector2, r1: float, r2: float) -> PackedVector2Array:
	var d := b - a
	var base := d.angle() if d.length_squared() > 0.0001 else PI * 0.5
	var pts := PackedVector2Array()
	for i in 10:
		pts.append(b + Vector2.from_angle(base + PI * 0.5 - PI * i / 9.0) * r2)
	for i in 10:
		pts.append(a + Vector2.from_angle(base - PI * 0.5 - PI * i / 9.0) * r1)
	return pts


## Cover the ink ring where two capsules meet, so a limb reads as one tube.
func weld(p: Vector2, r: float, col: Color) -> void:
	draw_circle(p, r + INK * 0.45, col, true, -1.0, true)


func _weld_arm(s: Dictionary, side: String, b: float, col: Color) -> void:
	weld(s["elb_" + side], 3.5 * b, col)
	weld(s["sh_" + side], 4.0 * b, col)
	weld(s["wrist_" + side], 3.0 * b, col)


func _weld_leg(s: Dictionary, side: String, b: float, col: Color) -> void:
	weld(s["knee_" + side], 4.25 * b, col)
	weld(s["hip_" + side], 5.5 * b, col)
	weld(s["ankle_" + side], 3.5 * b, col)


## A cel-shaded tapered limb: outline, shadow, lit side, muscle tone and rim light.
func part(a: Vector2, b: Vector2, w1: float, w2: float, col: Color) -> void:
	var r1 := w1 * 0.5
	var r2 := w2 * 0.5
	draw_colored_polygon(capsule_pts(a, b, r1 + INK, r2 + INK), OUT)
	draw_colored_polygon(capsule_pts(a, b, r1, r2), shade(col))
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	if n.dot(LIGHT) < 0.0:
		n = -n
	# Lit area.
	draw_colored_polygon(capsule_pts(a + n * r1 * 0.22, b + n * r2 * 0.22, r1 * 0.8, r2 * 0.8), col)
	# Muscle tone: a subtle mid-shade stripe along the limb.
	var mid := a.lerp(b, 0.45)
	var md := (b - a).normalized()
	var mn := Vector2(-md.y, md.x)
	if mn.dot(LIGHT) < 0.0:
		mn = -mn
	draw_colored_polygon(capsule_pts(mid - mn * r1 * 0.3, mid + mn * r1 * 0.3, r1 * 0.25, r2 * 0.25), col.darkened(0.12))
	# Rim light on the lit edge.
	draw_line(a + n * r1 * 0.75, b + n * r2 * 0.75, hl(col), 0.5, true)


func ball(p: Vector2, r: float, col: Color) -> void:
	draw_circle(p, r + INK, OUT, true, -1.0, true)
	draw_circle(p, r, shade(col), true, -1.0, true)
	draw_circle(p + LIGHT * r * 0.25, r * 0.75, col, true, -1.0, true)


## Cartoon hands and feet are oversized: it reads at a glance and it's funny.
const EXTREMITY := 1.3


## A clenched fist pointing along `d` (the forearm direction).
func fist(p: Vector2, col: Color, d := Vector2.DOWN) -> void:
	draw_set_transform(p, 0.0, Vector2.ONE * EXTREMITY)
	_fist(Vector2.ZERO, col, d)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fist(p: Vector2, col: Color, d: Vector2) -> void:
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	var box := PackedVector2Array([p - n * 3.6 - d * 1.5, p + n * 3.6 - d * 1.5, p + n * 4.0 + d * 3.2,
		p + n * 2.8 + d * 5.2, p - n * 2.8 + d * 5.2, p - n * 4.0 + d * 3.2])
	shaded_poly(box, col, 1.2, 0.78)
	# Individual finger segments.
	for k in [-2.6, -0.9, 0.9, 2.6]:
		var fw := 1.0 - absf(k) * 0.12
		draw_line(p + n * k * fw + d * 2.8, p + n * k * fw + d * 4.8, shade(col), 0.7, true)
	# Thumb.
	part(p + n * 3.0 - d * 0.5, p + n * 2.4 + d * 2.8, 2.2, 2.0, col)
	# Knuckle highlight.
	draw_line(p - n * 2.8 + d * 3.4, p + n * 2.8 + d * 3.4, hl(col), 0.6, true)


## An open hand with spread fingers, for win/intro poses.
func open_hand(p: Vector2, col: Color, d := Vector2.DOWN) -> void:
	draw_set_transform(p, 0.0, Vector2.ONE * EXTREMITY)
	_open_hand(Vector2.ZERO, col, d)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _open_hand(p: Vector2, col: Color, d: Vector2) -> void:
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	# Palm.
	var palm := PackedVector2Array([p - n * 3.0 - d * 1.0, p + n * 3.0 - d * 1.0,
		p + n * 3.4 + d * 2.0, p - n * 3.4 + d * 2.0])
	shaded_poly(palm, col, 1.0, 0.8)
	# Four fingers.
	for k: float in [-2.4, -0.8, 0.8, 2.4]:
		var fw := 1.0 - absf(k) * 0.1
		var tip := p + n * k * fw + d * (5.5 + (1.0 if k == 0.0 else 0.0))
		part(p + n * k * fw + d * 2.0, tip, 1.6, 1.2, col)
	# Thumb.
	part(p + n * 2.8, p + n * 4.5 + d * 1.5, 2.0, 1.6, col)


## Filled polygon with an outline. Self-intersecting shapes (a twisted cape)
## fall back to their convex hull instead of failing to draw.
func poly(pts: PackedVector2Array, col: Color, outline := 1.8) -> void:
	pts = safe(pts)
	draw_colored_polygon(pts, col)
	if outline > 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, OUT, outline * 1.35, true)


## Cel-shaded polygon: shadow color base, lit copy shrunk toward the light.
func shaded_poly(pts: PackedVector2Array, col: Color, outline := 2.0, shrink := 0.8) -> void:
	pts = safe(pts)
	poly(pts, shade(col), outline)
	var ctr := Vector2.ZERO
	for p in pts:
		ctr += p
	ctr /= pts.size()
	var lit := PackedVector2Array()
	for p in pts:
		lit.append(ctr + (p - ctr) * shrink + LIGHT * 1.5)
	draw_colored_polygon(safe(lit), col)


static func safe(pts: PackedVector2Array) -> PackedVector2Array:
	if pts.size() >= 3 and Geometry2D.triangulate_polygon(pts).is_empty():
		var hull := Geometry2D.convex_hull(pts)
		hull.remove_at(hull.size() - 1)
		return hull
	return pts


static func ellipse_pts(c: Vector2, rx: float, ry: float, rot := 0.0, n := 18) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	return pts


static func star_pts(c: Vector2, r_out: float, r_in: float, n := 5, rot := 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n * 2:
		var a := rot - PI / 2 + PI * i / n
		var r := r_out if i % 2 == 0 else r_in
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts


## Ribbon along a list of points, tapering from w0 to w1 (hair, capes, tails).
static func ribbon_pts(pts: PackedVector2Array, w0: float, w1: float) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := pts.size()
	for i in n:
		var d := (pts[mini(i + 1, n - 1)] - pts[maxi(i - 1, 0)]).normalized()
		var nrm := Vector2(-d.y, d.x)
		var w := lerpf(w0, w1, float(i) / maxf(1.0, n - 1)) * 0.5
		left.append(pts[i] + nrm * w)
		right.append(pts[i] - nrm * w)
	right.reverse()
	left.append_array(right)
	return left


func ribbon(pts: PackedVector2Array, w0: float, w1: float, col: Color) -> void:
	if pts.size() < 2:
		return
	shaded_poly(ribbon_pts(pts, w0, w1), col, 1.8, 0.7)


func shoe(foot: Vector2, fwd: Vector2, col: Color) -> void:
	draw_set_transform(foot, 0.0, Vector2.ONE * EXTREMITY)
	_shoe(Vector2.ZERO, fwd, col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _shoe(foot: Vector2, fwd: Vector2, col: Color) -> void:
	var up := Vector2(fwd.y, -fwd.x)
	var pts := PackedVector2Array([foot - fwd * 3.0 + up * 3.0, foot + fwd * 5.0 + up * 3.0, foot + fwd * 10.0 - up * 0.5,
		foot + fwd * 9.0 - up * 3.0, foot - fwd * 4.0 - up * 3.0])
	shaded_poly(pts, col, 1.2, 0.75)
	draw_line(foot - fwd * 4.0 - up * 2.6, foot + fwd * 9.0 - up * 2.6, OUT.lightened(0.3), 1.0, true)
	# Sole detail.
	draw_line(foot - fwd * 3.0 - up * 2.8, foot + fwd * 8.0 - up * 2.8, shade(col), 0.8, true)


func torso(s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var pts := PackedVector2Array()
	for f in [[0.0, 8.0], [0.45, 6.5], [0.78, 9.5], [1.0, 7.0], [1.0, -9.0], [0.78, -8.5], [0.45, -6.5], [0.0, -8.0]]:
		pts.append(hip + up * TORSO * f[0] + perp * f[1] * def.build)
	shaded_poly(pts, colors["shirt"], 2.2, 0.8)


# --- Chains: simple verlet ropes for hair, capes and tails ---------------------

## Advances chain `name` hanging from `anchor` (local). Returns local points.
func chain(name: String, anchor: Vector2, n: int, seg: float, grav := 0.35, drag := 0.86, wind := 0.12) -> PackedVector2Array:
	var k := absf(global_transform.get_scale().y)
	var a := to_global(anchor)
	var back := Vector2(-signf(global_transform.x.x), 0.0)
	if not chains.has(name):
		var init := PackedVector2Array()
		for i in n:
			init.append(a + (back + Vector2(0, 0.6)).normalized() * seg * k * i)
		chains[name] = [init, init.duplicate()]
	var pts: PackedVector2Array = chains[name][0]
	var prev: PackedVector2Array = chains[name][1]
	pts[0] = a
	for i in range(1, n):
		var v := (pts[i] - prev[i]) * drag
		prev[i] = pts[i]
		pts[i] += v + Vector2(0, grav * k) + back * wind * k
	for _it in 2:
		for i in range(1, n):
			var d := pts[i] - pts[i - 1]
			var len := d.length()
			if len > 0.0001:
				pts[i] = pts[i - 1] + d / len * seg * k
	chains[name] = [pts, prev]
	return chain_local(name)


func chain_local(name: String) -> PackedVector2Array:
	var out := PackedVector2Array()
	if not chains.has(name):
		return out
	for p in chains[name][0]:
		out.append(to_local(p))
	return out


# --- Faces ---------------------------------------------------------------------

## Anime face in head space. `girl` = bigger eyes with lashes and blush.
func face(iris: Color, girl := false) -> void:
	var eyes := [Vector2(4.8, 0.9), Vector2(10.7, 0.6)]
	var blink := int(t) % 190 < 6 and expr == "normal"
	# A big hit bugs the eyes right out of the skull for a few frames. Nothing
	# says "cartoon" faster, and it costs one multiplier.
	var pop := 1.0 + 1.15 * (float(eye_pop) / 9.0)
	for i in 2:
		var e: Vector2 = eyes[i]
		var rx := (3.5 if girl else 3.2) * (0.66 if i == 1 else 1.0) * pop
		var ry := (4.9 if girl else 4.3) * pop
		if expr == "attack":
			# Emilia squints harder than the boys: a decided glare, not a cute gasp.
			ry *= 0.62 if girl else 0.78
		match expr:
			"hurt":
				var sgn := 1.0 if i == 0 else -1.0
				draw_polyline(PackedVector2Array([e + Vector2(-2.0 * sgn, -2.0), e + Vector2(1.5 * sgn, 0), e + Vector2(-2.0 * sgn, 2.0)]), OUT, 1.4, true)
			"happy":
				draw_arc(e + Vector2(0, 1.2), 2.2, PI, TAU, 8, OUT, 1.5, true)
			"win":
				# Bigger, brighter happy arcs — the "I won!" face.
				draw_arc(e + Vector2(0, 1.4), 2.8, PI, TAU, 10, OUT, 1.8, true)
				draw_arc(e + Vector2(0, 1.4), 2.0, PI, TAU, 8, Color(1, 1, 1, 0.5), 0.8, true)
			"ko":
				# Classic knocked-out X eyes.
				var r := 3.0
				draw_line(e + Vector2(-r, -r), e + Vector2(r, r), OUT, 1.7, true)
				draw_line(e + Vector2(r, -r), e + Vector2(-r, r), OUT, 1.7, true)
			"dizzy":
				# Spiral eyes, drawn as a tightening arc.
				var pts := PackedVector2Array()
				for st in 17:
					var a := t * 0.12 + st * 0.62
					pts.append(e + Vector2.from_angle(a) * (0.4 + st * 0.22))
				draw_polyline(pts, OUT, 1.2, true)
			"shock":
				# Tiny pinprick pupils in a huge white eye: pure panic.
				draw_colored_polygon(ellipse_pts(e, rx * 1.25, ry * 1.25), Color(1, 0.99, 0.97))
				draw_polyline(Stage._closed(ellipse_pts(e, rx * 1.25, ry * 1.25)), OUT, 1.2, true)
				draw_circle(e + Vector2(0.4, 0.3), maxf(0.9, rx * 0.26), OUT, true, -1.0, true)
			"smug":
				# One raised lid, a flat confident line.
				draw_line(e + Vector2(-rx, 0.4), e + Vector2(rx, -0.9), OUT, 1.6, true)
				draw_circle(e + Vector2(0.3, 1.5), rx * 0.42, OUT, true, -1.0, true)
			_:
				if blink:
					draw_line(e + Vector2(-rx, 0.5), e + Vector2(rx, 0.5), OUT, 1.3, true)
				else:
					draw_colored_polygon(ellipse_pts(e, rx, ry), Color(1, 0.98, 0.95))
					draw_colored_polygon(ellipse_pts(e + Vector2(0.5, 0.4), rx * 0.78, ry * 0.8), iris)
					draw_colored_polygon(ellipse_pts(e + Vector2(0.5, -ry * 0.25), rx * 0.78, ry * 0.4), iris.darkened(0.35))
					draw_circle(e + Vector2(0.7, 0.5), rx * 0.36, OUT, true, -1.0, true)
					draw_circle(e + Vector2(-0.2, -ry * 0.35), rx * 0.3, Color.WHITE, true, -1.0, true)
					draw_circle(e + Vector2(1.0, ry * 0.4), rx * 0.14, Color(1, 1, 1, 0.8), true, -1.0, true)
					draw_colored_polygon(ellipse_pts(e + Vector2(0.5, ry * 0.45), rx * 0.55, ry * 0.18), iris.lightened(0.35))
					# Upper eyelid line.
					draw_line(e + Vector2(-rx - 0.4, -ry + 0.9), e + Vector2(rx + 0.5, -ry + 0.1), OUT, 2.2 if girl else 1.6, true)
					if girl and i == 0:
						draw_line(e + Vector2(rx, -ry + 0.4), e + Vector2(rx + 1.8, -ry - 0.8), OUT, 1.0, true)
		# Eyebrows.
		var b0 := e + Vector2(-2.4, -ry - 2.2)
		var b1 := e + Vector2(2.4, -ry - 2.0)
		match expr:
			"attack":
				if girl:
					# Inner corners drop toward the nose: a scowl, not a parallel slant.
					if i == 0:
						b0.y -= 1.4
						b1.y += 2.4
					else:
						b0.y += 2.4
						b1.y -= 1.4
				else:
					b0.y -= 1.0
					b1.y += 1.0
			"hurt", "shock":
				b0.y += 1.0
				b1.y -= 1.0
			"smug":
				# One brow way up, one flat: the "oh really?" face.
				b0.y -= 2.2 if i == 0 else 0.0
				b1.y -= 3.0 if i == 0 else 0.0
			"ko", "dizzy":
				b0.y -= 1.4
				b1.y -= 1.4
		if girl and expr == "normal":
			# Idle is decided, not smiling: a shallow V even between attacks.
			if i == 0:
				b1.y += 1.3
			else:
				b0.y += 1.3
		draw_line(b0, b1, OUT, 1.35 if girl else 1.6, true)
	draw_line(Vector2(12.2, 2.8), Vector2(11.4, 4.3), shade(colors["skin"]), 1.0, true)
	if girl:
		draw_colored_polygon(ellipse_pts(Vector2(5.5, 5.2), 2.0, 0.9), Color(1, 0.45, 0.6, 0.45))
	var m := Vector2(8.5, 7.3)
	match expr:
		"attack":
			if girl:
				poly(PackedVector2Array([m + Vector2(-2.6, -1.4), m + Vector2(2.8, -1.6), m + Vector2(1.4, 2.6), m + Vector2(-1.2, 2.4)]), Color(0.45, 0.08, 0.12), 1.2)
			else:
				poly(PackedVector2Array([m + Vector2(-1.8, -0.8), m + Vector2(2.0, -1.0), m + Vector2(0.6, 1.8)]), Color(0.55, 0.12, 0.18), 1.0)
		"hurt":
			poly(ellipse_pts(m + Vector2(0, 0.3), 1.3, 1.7, 0.0, 10), Color(0.45, 0.1, 0.15), 1.0)
		"happy":
			draw_colored_polygon(PackedVector2Array([m + Vector2(-2.2, -0.8), m + Vector2(2.2, -1.0), m + Vector2(0.8, 1.6), m + Vector2(-1.0, 1.4)]), Color(0.55, 0.12, 0.18))
		"win":
			# Open grin with a tongue — pure joy.
			draw_colored_polygon(PackedVector2Array([m + Vector2(-2.8, -1.0), m + Vector2(2.8, -1.0), m + Vector2(1.8, 2.2), m + Vector2(-1.8, 2.2)]), Color(0.45, 0.08, 0.12))
			draw_colored_polygon(PackedVector2Array([m + Vector2(-1.2, 0.8), m + Vector2(1.2, 0.8), m + Vector2(0.6, 2.4), m + Vector2(-0.6, 2.4)]), Color(1.0, 0.45, 0.55))
		"ko", "shock":
			# Jaw on the floor: a big round wail of a mouth.
			poly(ellipse_pts(m + Vector2(0, 1.2), 2.6, 3.4, 0.0, 12), Color(0.45, 0.1, 0.15), 1.2)
			draw_colored_polygon(ellipse_pts(m + Vector2(0.2, 3.0), 1.7, 1.2, 0.0, 10), Color(1.0, 0.45, 0.55))
		"dizzy":
			# Wobbly line: not quite conscious.
			var w := PackedVector2Array()
			for wi in 5:
				w.append(m + Vector2(-2.4 + wi * 1.2, 0.6 + (1.0 if wi % 2 == 0 else -1.0) * 0.8))
			draw_polyline(w, Color(0.5, 0.12, 0.18), 1.3, true)
		"smug":
			draw_arc(m + Vector2(0.4, -1.0), 2.6, 0.25, 1.5, 8, Color(0.5, 0.12, 0.18), 1.4, true)
		_:
			if girl:
				draw_line(m + Vector2(-2.1, -0.3), m + Vector2(2.1, 0.7), OUT, 1.4, true)
			else:
				draw_line(m + Vector2(-1.5, 0), m + Vector2(1.5, -0.2), OUT, 1.0, true)
