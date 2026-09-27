class_name ChibiRenderer
extends Node2D
## Draws a chibi character from simple shapes, posed by joint angles.
##
## Angles are in degrees. Limbs: 0 = hanging straight down, 90 = pointing
## forward, 180 = pointing up. Knees bend backwards, elbows bend forwards.
## "lean" tilts the torso forward, "rot" spins the whole body around the hip.
## Everything is drawn facing right; `facing` mirrors it.

const OUT := Color(0.09, 0.07, 0.13)
const THIGH := 13.0
const SHIN := 13.0
const TORSO := 22.0
const UPPER := 10.0
const FORE := 10.0
const HEAD_R := 17.0

const POSES := {
	"idle": {"lean": 6, "head": 0, "arm_f": 35, "elb_f": 95, "arm_b": 50, "elb_b": 95,
		"leg_f": 18, "knee_f": 14, "leg_b": -16, "knee_b": 12, "rot": 0, "hip": -27, "ground": 1},
	"crouch": {"lean": 32, "head": -14, "arm_f": 50, "elb_f": 100, "arm_b": 60, "elb_b": 100,
		"leg_f": 85, "knee_f": 135, "leg_b": 15, "knee_b": 140},
	"block": {"lean": -6, "head": -6, "arm_f": 80, "elb_f": 115, "arm_b": 90, "elb_b": 115,
		"leg_f": 20, "knee_f": 20, "leg_b": -26, "knee_b": 14},
	"crouch_block": {"lean": 20, "head": -10, "arm_f": 90, "elb_f": 110, "arm_b": 100, "elb_b": 110,
		"leg_f": 85, "knee_f": 135, "leg_b": 15, "knee_b": 140},
	"jump": {"lean": 5, "arm_f": 150, "elb_f": 20, "arm_b": -40, "elb_b": 30,
		"leg_f": 60, "knee_f": 95, "leg_b": 5, "knee_b": 70, "ground": 0, "hip": -32},
	"hit": {"lean": -22, "head": -18, "arm_f": -25, "elb_f": 30, "arm_b": -40, "elb_b": 30,
		"leg_f": 22, "knee_f": 10, "leg_b": -20, "knee_b": 10},
	"launched": {"lean": -30, "head": -20, "arm_f": 150, "elb_f": 30, "arm_b": 170, "elb_b": 30,
		"leg_f": 40, "knee_f": 60, "leg_b": 10, "knee_b": 50, "rot": -35, "ground": 0, "hip": -32},
	"down": {"lean": 0, "head": 10, "arm_f": 150, "elb_f": 20, "arm_b": 200, "elb_b": 20,
		"leg_f": 12, "knee_f": 8, "leg_b": -4, "knee_b": 20, "rot": -90, "ground": 0, "hip": -7},
	"win": {"arm_f": 165, "elb_f": 10, "arm_b": 40, "elb_b": 110},
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


func setup(d: CharacterDef, alt := false) -> void:
	def = d
	colors = d.alt_colors if alt else d.colors
	pose = d.pose("idle")


func update_pose(target: Dictionary, speed: float) -> void:
	for k in target:
		if k == "ground" or not pose.has(k):
			pose[k] = target[k]
		else:
			pose[k] = lerpf(float(pose[k]), float(target[k]), speed)
	scale = Vector2(base_scale * facing, base_scale)
	modulate = Color(2.2, 2.2, 2.2) if flash > 0 else Color.WHITE
	queue_redraw()


static func dir(a: float) -> Vector2:
	var r := deg_to_rad(a)
	return Vector2(sin(r), cos(r))


func skeleton() -> Dictionary:
	var p := pose
	var lean := deg_to_rad(float(p["lean"]))
	var up := Vector2(sin(lean), -cos(lean))
	var s := {}
	s["hip"] = Vector2.ZERO
	s["knee_f"] = dir(p["leg_f"]) * THIGH
	s["foot_f"] = s["knee_f"] + dir(p["leg_f"] - p["knee_f"]) * SHIN
	s["knee_b"] = dir(p["leg_b"]) * THIGH
	s["foot_b"] = s["knee_b"] + dir(p["leg_b"] - p["knee_b"]) * SHIN
	s["neck"] = up * TORSO
	s["sh"] = up * (TORSO - 3.0)
	s["elb_f"] = s["sh"] + dir(p["arm_f"]) * UPPER
	s["hand_f"] = s["elb_f"] + dir(p["arm_f"] + p["elb_f"]) * FORE
	s["elb_b"] = s["sh"] + dir(p["arm_b"]) * UPPER
	s["hand_b"] = s["elb_b"] + dir(p["arm_b"] + p["elb_b"]) * FORE
	var head_ang := lean * 0.5 + deg_to_rad(float(p["head"]))
	s["head"] = s["neck"] + up.rotated(head_ang - lean) * (HEAD_R - 3.0)
	var rot := deg_to_rad(float(p["rot"]))
	var pts := ["hip", "knee_f", "foot_f", "knee_b", "foot_b", "neck", "sh", "elb_f", "hand_f", "elb_b", "hand_b", "head"]
	for k in pts:
		s[k] = (s[k] as Vector2).rotated(rot)
	var offset := Vector2(0, float(p["hip"]))
	if int(p["ground"]) == 1:
		var low := maxf(maxf(s["foot_f"].y, s["foot_b"].y), maxf(s["knee_f"].y, s["knee_b"].y))
		offset = Vector2(0, -low - 3.0)
	for k in pts:
		s[k] = s[k] + offset
	s["up"] = up.rotated(rot)
	s["head_ang"] = head_ang + rot
	s["rot"] = rot
	return s


func _draw() -> void:
	if def == null:
		return
	var s := skeleton()
	var c := colors
	# Back arm and leg (a bit darker, they're further away).
	limb2(s["sh"], s["elb_b"], s["hand_b"], 7.0, 6.0, dk(c["shirt"]), dk(c["skin"]))
	ball(s["hand_b"], 4.0, dk(c["skin"]))
	limb2(s["hip"], s["knee_b"], s["foot_b"], 8.0, 7.0, dk(c["pants"]), dk(c["legs"]))
	shoe(s["foot_b"], dk(c["shoes"]), s["rot"])
	def.draw_behind(self, s)
	torso(s)
	def.draw_torso(self, s)
	limb2(s["hip"], s["knee_f"], s["foot_f"], 8.0, 7.0, c["pants"], c["legs"])
	shoe(s["foot_f"], c["shoes"], s["rot"])
	def.draw_over_legs(self, s)
	# Head, drawn in its own rotated space centred on (0, 0).
	draw_set_transform(s["head"], s["head_ang"], Vector2.ONE)
	def.draw_hair_back(self)
	ball(Vector2.ZERO, HEAD_R, c["skin"])
	ball(Vector2(-5, 3), 3.5, c["skin"])
	def.draw_face(self)
	def.draw_hair_front(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Front arm on top.
	limb2(s["sh"], s["elb_f"], s["hand_f"], 7.0, 6.0, c["shirt"], c["skin"])
	ball(s["hand_f"], 4.0, c["skin"])
	def.draw_props(self, s)


# --- Drawing helpers (also used by character defs) ----------------------------

static func dk(col: Color) -> Color:
	return col.darkened(0.22)


func limb2(a: Vector2, b: Vector2, e: Vector2, w1: float, w2: float, c1: Color, c2: Color) -> void:
	for pair in [[a, b, w1], [b, e, w2]]:
		draw_line(pair[0], pair[1], OUT, pair[2] + 3.0, true)
		draw_circle(pair[0], (pair[2] + 3.0) * 0.5, OUT, true, -1.0, true)
		draw_circle(pair[1], (pair[2] + 3.0) * 0.5, OUT, true, -1.0, true)
	draw_line(a, b, c1, w1, true)
	draw_circle(a, w1 * 0.5, c1, true, -1.0, true)
	draw_circle(b, w1 * 0.5, c1, true, -1.0, true)
	draw_line(b, e, c2, w2, true)
	draw_circle(e, w2 * 0.5, c2, true, -1.0, true)


func ball(p: Vector2, r: float, col: Color) -> void:
	draw_circle(p, r + 1.5, OUT, true, -1.0, true)
	draw_circle(p, r, col, true, -1.0, true)


func poly(pts: PackedVector2Array, col: Color, outline := 1.8) -> void:
	draw_colored_polygon(pts, col)
	if outline > 0.0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, OUT, outline, true)


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


func shoe(foot: Vector2, col: Color, rot: float) -> void:
	poly(ellipse_pts(foot + Vector2(3, 0).rotated(rot), 7.0, 4.0, rot, 12), col, 1.8)


func torso(s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp := Vector2(-up.y, up.x)
	var hip: Vector2 = s["hip"]
	var sh: Vector2 = s["neck"] - up * 2.0
	poly(PackedVector2Array([hip + perp * 9.0, hip - perp * 9.0, sh - perp * 11.0, sh + perp * 11.0]), colors["shirt"], 2.2)


## Generic face: eyes + mouth, driven by `expr`. `big` gives anime eyes.
func face(iris: Color, big := false, blush := false) -> void:
	var eyes := [Vector2(2, 1), Vector2(11, 0)]
	var blink := int(t) % 190 < 6 and expr == "normal"
	for i in 2:
		var e: Vector2 = eyes[i]
		var rx := (3.6 if big else 3.1) * (0.85 if i == 1 else 1.0)
		var ry := 5.6 if big else 4.2
		match expr:
			"hurt":
				var sgn := 1.0 if i == 0 else -1.0
				draw_polyline(PackedVector2Array([e + Vector2(-2.5 * sgn, -2.5), e + Vector2(2.0 * sgn, 0), e + Vector2(-2.5 * sgn, 2.5)]), OUT, 1.8, true)
			"happy":
				draw_arc(e + Vector2(0, 1.5), 3.0, PI, TAU, 8, OUT, 1.8, true)
			_:
				if blink:
					draw_line(e + Vector2(-rx, 0), e + Vector2(rx, 0), OUT, 1.6, true)
				else:
					draw_colored_polygon(ellipse_pts(e, rx + 0.8, ry + 0.8), OUT)
					draw_colored_polygon(ellipse_pts(e, rx, ry), Color.WHITE)
					draw_colored_polygon(ellipse_pts(e + Vector2(0.7, 0.5), rx * 0.75, ry * 0.78), iris)
					draw_circle(e + Vector2(0.9, 0.8), rx * 0.38, OUT, true, -1.0, true)
					draw_circle(e + Vector2(-0.4, -ry * 0.35), rx * 0.3, Color.WHITE, true, -1.0, true)
					if big:
						draw_circle(e + Vector2(1.4, ry * 0.4), rx * 0.18, Color.WHITE, true, -1.0, true)
						draw_line(e + Vector2(-rx - 0.5, -ry + 0.8), e + Vector2(rx + 0.8, -ry - 0.2), OUT, 1.8, true)
				if expr == "attack":
					draw_line(e + Vector2(-3, -ry - 2.5), e + Vector2(3, -ry - 0.8), OUT, 1.8, true)
	if blush:
		draw_colored_polygon(ellipse_pts(Vector2(0, 7), 2.8, 1.5), Color(1, 0.45, 0.6, 0.45))
		draw_colored_polygon(ellipse_pts(Vector2(12, 6.5), 2.3, 1.4), Color(1, 0.45, 0.6, 0.45))
	var m := Vector2(8, 10)
	match expr:
		"attack":
			poly(PackedVector2Array([m + Vector2(-3, -1), m + Vector2(3, -1.5), m + Vector2(1, 2.5)]), Color(0.6, 0.15, 0.2), 1.2)
		"hurt":
			poly(ellipse_pts(m + Vector2(0, 0.5), 2.0, 2.6, 0.0, 10), Color(0.5, 0.1, 0.15), 1.2)
		"happy":
			draw_colored_polygon(PackedVector2Array([m + Vector2(-3.5, -1), m + Vector2(3.5, -1.5), m + Vector2(2, 2.5), m + Vector2(-1.5, 2.5)]), Color(0.6, 0.15, 0.2))
		_:
			draw_arc(m + Vector2(0, -2), 3.0, 0.4, 2.4, 8, OUT, 1.5, true)
