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
const HEAD := 11.0
const HEAD_SCALE := 1.18  # head-space drawings are authored for HEAD = 11

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

## Per-joint spring response: legs snap, torso follows, arms and head trail
## behind with a little overshoot. That lag is what stops the puppet look.
const JOINT_RESPONSE := {
	"leg_f": 1.0, "knee_f": 1.0, "leg_b": 1.0, "knee_b": 1.0, "hip": 1.0,
	"lean": 0.8, "rot": 1.0, "arm_f": 0.75, "elb_f": 0.7, "arm_b": 0.65, "elb_b": 0.6, "head": 0.5,
}


func setup(d: CharacterDef, alt := false) -> void:
	def = d
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
	scale = Vector2(base_scale * facing, base_scale)
	modulate = Color(2.2, 2.2, 2.2) if flash > 0 else Color.WHITE
	prev_sk = sk
	sk = skeleton()
	if is_inside_tree() and def != null:
		def.update_chains(self, sk)
	queue_redraw()


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
	chains = src.chains.duplicate(true)
	scale = src.scale
	global_position = src.global_position
	sk = src.sk.duplicate()
	prev_sk = src.prev_sk.duplicate()
	queue_redraw()


## A point given in head space (as the hair is drawn), in local space.
static func head_point(s: Dictionary, p: Vector2) -> Vector2:
	return s["head"] + (p * HEAD_SCALE).rotated(s["head_ang"])


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
	s["foot_f"] = s["knee_f"] + dir(p["leg_f"] - p["knee_f"]) * SHIN
	s["knee_b"] = s["hip_b"] + dir(p["leg_b"]) * THIGH
	s["foot_b"] = s["knee_b"] + dir(p["leg_b"] - p["knee_b"]) * SHIN
	s["neck"] = up * TORSO
	# Torso twist: a reaching front arm drags its shoulder forward, the back one pulls away.
	var twist := clampf((float(p["arm_f"]) - 45.0) / 50.0, -0.6, 1.0)
	s["sh_f"] = up * (TORSO - 3.0 - absf(twist) * 1.5) + perp * (1.5 + twist * 4.0)
	s["sh_b"] = up * (TORSO - 2.5) - perp * (3.0 + twist * 2.0)
	s["elb_f"] = s["sh_f"] + dir(p["arm_f"]) * UPPER
	s["hand_f"] = s["elb_f"] + dir(p["arm_f"] + p["elb_f"]) * FORE
	s["elb_b"] = s["sh_b"] + dir(p["arm_b"]) * UPPER
	s["hand_b"] = s["elb_b"] + dir(p["arm_b"] + p["elb_b"]) * FORE
	var head_ang := lean * 0.5 + deg_to_rad(float(p["head"]))
	s["head"] = s["neck"] + up.rotated(head_ang - lean) * (NECK + HEAD * 0.8 * HEAD_SCALE)
	var rot := deg_to_rad(float(p["rot"]))
	var pts := ["hip", "hip_f", "hip_b", "knee_f", "foot_f", "knee_b", "foot_b", "neck", "sh_f", "sh_b",
		"elb_f", "hand_f", "elb_b", "hand_b", "head"]
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
	def.draw_behind(self, s)
	_smears(s)
	# Back arm and leg: darker, they're further away.
	part(s["sh_b"], s["elb_b"], 8.0, 7.0, dk(c["sleeve"]))
	part(s["elb_b"], s["hand_b"], 6.5, 5.5, dk(c["forearm"]))
	fist(s["hand_b"], dk(c["hands"]), s["hand_b"] - s["elb_b"])
	part(s["hip_b"], s["knee_b"], 11.0, 8.5, dk(c["pants"]))
	part(s["knee_b"], s["foot_b"], 8.5, 6.5, dk(c["legs"]))
	shoe(s["foot_b"], s["foot_dir_b"], dk(c["shoes"]))
	torso(s)
	def.draw_torso(self, s)
	part(s["hip_f"], s["knee_f"], 11.0, 8.5, c["pants"])
	part(s["knee_f"], s["foot_f"], 8.5, 6.5, c["legs"])
	shoe(s["foot_f"], s["foot_dir_f"], c["shoes"])
	def.draw_over_legs(self, s)
	_draw_head(s)
	part(s["sh_f"], s["elb_f"], 8.0, 7.0, c["sleeve"])
	part(s["elb_f"], s["hand_f"], 6.5, 5.5, c["forearm"])
	fist(s["hand_f"], c["hands"], s["hand_f"] - s["elb_f"])
	def.draw_props(self, s)


## Motion smear: a translucent streak from where a fast limb was last frame to
## where it is now. Two frames of a hard kick read as one continuous arc instead
## of two disconnected legs — the cheapest big win in hand-drawn animation.
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
		draw_colored_polygon(capsule_pts(a, b, w * 0.35, w * 0.6), Color(1, 1, 1, fade * 0.55))


func _draw_head(s: Dictionary) -> void:
	var c := colors
	var up: Vector2 = s["up"]
	part(s["neck"] - up * 2.0, s["neck"] + up * NECK, 6.0, 5.5, c["skin"])
	draw_set_transform(s["head"], s["head_ang"], Vector2.ONE * HEAD_SCALE)
	def.draw_hair_back(self)
	poly(head_shape(), c["skin"], 2.0)
	# Shadow under the jaw and at the back of the face.
	draw_colored_polygon(PackedVector2Array([Vector2(-8, 2), Vector2(-3, 7.5), Vector2(3, 10.2), Vector2(0, 5), Vector2(-5, 1)]), shade(c["skin"]))
	def.draw_face(self)
	def.draw_hair_front(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func head_shape() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 13:
		var a := deg_to_rad(160.0 + 200.0 * i / 12.0)
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
	for i in 7:
		pts.append(b + Vector2.from_angle(base + PI * 0.5 - PI * i / 6.0) * r2)
	for i in 7:
		pts.append(a + Vector2.from_angle(base - PI * 0.5 - PI * i / 6.0) * r1)
	return pts


## A cel-shaded tapered limb: outline, shadow, lit side and a highlight.
func part(a: Vector2, b: Vector2, w1: float, w2: float, col: Color) -> void:
	var r1 := w1 * 0.5
	var r2 := w2 * 0.5
	draw_colored_polygon(capsule_pts(a, b, r1 + 1.6, r2 + 1.6), OUT)
	draw_colored_polygon(capsule_pts(a, b, r1, r2), shade(col))
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	if n.dot(LIGHT) < 0.0:
		n = -n
	draw_colored_polygon(capsule_pts(a + n * r1 * 0.3, b + n * r2 * 0.3, r1 * 0.7, r2 * 0.7), col)
	draw_line(a + n * r1 * 0.55, b + n * r2 * 0.55, hl(col), maxf(1.0, r2 * 0.28), true)
	# Cool rim light on the shadow side, like arcade sprite shading.
	draw_line(a - n * r1 * 0.78, b - n * r2 * 0.78, Color(0.7, 0.8, 1.0, 0.35), maxf(0.8, r2 * 0.16), true)


func ball(p: Vector2, r: float, col: Color) -> void:
	draw_circle(p, r + 1.5, OUT, true, -1.0, true)
	draw_circle(p, r, shade(col), true, -1.0, true)
	draw_circle(p + LIGHT * r * 0.25, r * 0.75, col, true, -1.0, true)


## A clenched fist pointing along `d` (the forearm direction).
func fist(p: Vector2, col: Color, d := Vector2.DOWN) -> void:
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	var box := PackedVector2Array([p - n * 3.6 - d * 1.5, p + n * 3.6 - d * 1.5, p + n * 4.0 + d * 3.2,
		p + n * 2.8 + d * 5.2, p - n * 2.8 + d * 5.2, p - n * 4.0 + d * 3.2])
	shaded_poly(box, col, 1.6, 0.78)
	for k in [-1.4, 1.4]:
		draw_line(p + n * k + d * 2.4, p + n * k + d * 4.6, shade(col), 0.9, true)
	part(p + n * 3.2 - d * 0.5, p + n * 2.6 + d * 2.6, 2.6, 2.4, col)


## Filled polygon with an outline. Self-intersecting shapes (a twisted cape)
## fall back to their convex hull instead of failing to draw.
func poly(pts: PackedVector2Array, col: Color, outline := 1.8) -> void:
	pts = safe(pts)
	draw_colored_polygon(pts, col)
	if outline > 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, OUT, outline, true)


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
	var up := Vector2(fwd.y, -fwd.x)
	var pts := PackedVector2Array([foot - fwd * 3.0 + up * 3.0, foot + fwd * 5.0 + up * 3.0, foot + fwd * 10.0 - up * 0.5,
		foot + fwd * 9.0 - up * 3.0, foot - fwd * 4.0 - up * 3.0])
	shaded_poly(pts, col, 1.8, 0.75)
	draw_line(foot - fwd * 4.0 - up * 2.6, foot + fwd * 9.0 - up * 2.6, OUT.lightened(0.3), 1.5, true)


func torso(s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var pts := PackedVector2Array()
	for f in [[0.0, 8.0], [0.45, 6.5], [0.78, 9.5], [1.0, 7.0], [1.0, -9.0], [0.78, -8.5], [0.45, -6.5], [0.0, -8.0]]:
		pts.append(hip + up * TORSO * f[0] + perp * f[1])
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
	for i in 2:
		var e: Vector2 = eyes[i]
		var rx := (3.2 if girl else 2.8) * (0.62 if i == 1 else 1.0)
		var ry := 4.6 if girl else 3.7
		if expr == "attack":
			ry *= 0.78
		match expr:
			"hurt":
				var sgn := 1.0 if i == 0 else -1.0
				draw_polyline(PackedVector2Array([e + Vector2(-2.0 * sgn, -2.0), e + Vector2(1.5 * sgn, 0), e + Vector2(-2.0 * sgn, 2.0)]), OUT, 1.4, true)
			"happy":
				draw_arc(e + Vector2(0, 1.2), 2.2, PI, TAU, 8, OUT, 1.5, true)
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
		if expr == "attack":
			b0.y -= 1.0
			b1.y += 1.0
		elif expr == "hurt":
			b0.y += 1.0
			b1.y -= 1.0
		draw_line(b0, b1, OUT, 1.0 if girl else 1.6, true)
	draw_line(Vector2(12.2, 2.8), Vector2(11.4, 4.3), shade(colors["skin"]), 1.0, true)
	if girl:
		draw_colored_polygon(ellipse_pts(Vector2(5.5, 5.2), 2.0, 0.9), Color(1, 0.45, 0.6, 0.45))
	var m := Vector2(8.5, 7.3)
	match expr:
		"attack":
			poly(PackedVector2Array([m + Vector2(-1.8, -0.8), m + Vector2(2.0, -1.0), m + Vector2(0.6, 1.8)]), Color(0.55, 0.12, 0.18), 1.0)
		"hurt":
			poly(ellipse_pts(m + Vector2(0, 0.3), 1.3, 1.7, 0.0, 10), Color(0.45, 0.1, 0.15), 1.0)
		"happy":
			draw_colored_polygon(PackedVector2Array([m + Vector2(-2.2, -0.8), m + Vector2(2.2, -1.0), m + Vector2(0.8, 1.6), m + Vector2(-1.0, 1.4)]), Color(0.55, 0.12, 0.18))
		_:
			draw_line(m + Vector2(-1.5, 0), m + Vector2(1.5, -0.2), OUT, 1.0, true)
