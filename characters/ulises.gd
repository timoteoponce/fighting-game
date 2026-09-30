class_name UlisesDef
extends CharacterDef
## Ulises: soccer, running, reading and video games. Fast and sporty.


func _init() -> void:
	id = "ulises"
	display = "ULISES"
	likes = "Soccer, running, reading, video games"
	win_quote = "Game over! Now, where was I in my book?"
	gag_items = ["ball", "tooth", "star"]
	taunt_lines = ["TOO SLOW!", "GOOOAL!", "NICE TRY!"]
	hurt_lines = ["OOF!", "MY BALL!", "HEY!"]
	colors = {
		"skin": Color("e8b890"), "hair": Color("2a1a0e"), "shirt": Color("1a4d8f"), "sleeve": Color("1a4d8f"),
		"forearm": Color("e8b890"), "hands": Color("e8b890"), "pants": Color("e8b890"), "shorts": Color("f0ece4"),
		"legs": Color("1a4d8f"), "shoes": Color("2a7a2a"), "eyes": Color("3a2010"), "accent": Color("3a8a3a"),
		"band": Color("c42020"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("8f1a1a"), "sleeve": Color("8f1a1a"), "accent": Color("e8c020"), "legs": Color("8f1a1a"),
		"shoes": Color("d4a020"), "band": Color("1a4d8f"), "shorts": Color("2a2a30")}, true)
	walk_speed = 3.4
	back_speed = 2.8
	jump_vel = -10.5
	jump_x = 4.0
	voice_pitch = 250.0
	roster_order = 0
	win_prop = "book"
	intro_prop = "ball_intro"
	specials_text = [
		["L + H", "Power Shot"],
		["FWD + L + H", "Sprint Dash"],
		["DOWN + L + H", "Bicycle Kick"],
		["BACK + L + H", "GAME OVER COMBO"],
	]
	poses = {
		"intro": {"arm_f": 160, "elb_f": 15, "arm_b": 30, "elb_b": 100, "lean": -4},
		"win": {"lean": 4, "head": 8, "leg_f": 70, "knee_f": 15, "leg_b": -30, "knee_b": 20,
			"arm_f": 175, "elb_f": 5, "arm_b": 55, "elb_b": 45},
	}
	moves = {
		"L": MoveData.make({"id": "jab", "startup": 4, "active": 3, "recovery": 8, "damage": 40,
			"hitbox": Rect2(13, -94, 47, 23), "hitstun": 14, "blockstun": 9, "kb": Vector2(2, 0), "meter": 4.0,
			"pose_s": {"arm_f": 60, "elb_f": 100, "lean": 10}, "pose_a": {"arm_f": 92, "elb_f": 0, "lean": 16, "arm_b": 30, "elb_b": 110}}),
		"H": MoveData.make({"id": "rising kick", "level": 1, "startup": 9, "active": 4, "recovery": 18, "damage": 90,
			"hitbox": Rect2(13, -146, 60, 83), "launch": true, "kb": Vector2(1.5, -10.5), "hitstun": 30, "blockstun": 16,
			"hitstop": 8, "meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"lean": 0, "leg_f": 60, "knee_f": 90}, "pose_a": {"lean": -18, "leg_f": 165, "knee_f": 0, "arm_f": -20, "elb_f": 30, "arm_b": 60, "elb_b": 60}}),
		"cL": MoveData.make({"id": "low jab", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 35,
			"hitbox": Rect2(13, -52, 49, 23), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 85, "elb_f": 0}}),
		"cH": MoveData.make({"id": "slide tackle", "crouch": true, "level": 1, "startup": 8, "active": 5, "recovery": 20,
			"damage": 80, "hitbox": Rect2(8, -26, 83, 26), "knockdown": true, "kb": Vector2(2, -4), "hitstop": 7,
			"meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 88, "knee_f": 0, "lean": -20, "arm_b": -30}}),
		"jL": MoveData.make({"id": "air punch", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 40,
			"hitbox": Rect2(5, -86, 52, 39), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 115, "elb_f": 0}}),
		"jH": MoveData.make({"id": "volley kick", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 80, "hitbox": Rect2(3, -68, 65, 47), "spike": true, "hitstun": 18, "blockstun": 12, "kb": Vector2(3, 0),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": 20, "knee_b": 90, "lean": -10}}),
		"proj": MoveData.make({"id": "power shot", "display": "POWER SHOT", "level": 2, "startup": 11, "active": 3,
			"recovery": 18, "flash": 3, "shake": 1.0, "sfx": "kick",
			"damage": 60, "hitbox": Rect2(10, -48, 44, 20), "kb": Vector2(2.4, -1.5), "hitstun": 18,
			"blockstun": 12, "hitstop": 6, "meter": 8.0, "hit_sfx": "heavy",
			"projectile": {"kind": "ball", "speed": 6.5, "size": BALL_SIZE, "offset": Vector2(34, -18), "life": 150,
				"damage": 70, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "kick", "hit_sfx": "heavy"},
			"pose_s": {"leg_f": -40, "knee_f": 40, "lean": -5, "arm_f": 60, "arm_b": -20},
			"pose_a": {"leg_f": 95, "knee_f": 5, "lean": -10, "arm_b": 60, "arm_f": -20}}),
		# Kept as a low special for the character's move data; Power Shot remains
		# available even when the persistent field ball is loose.
		"slide": MoveData.make({"id": "slide kick", "display": "SLIDE KICK", "level": 2, "startup": 9, "active": 4,
			"recovery": 18, "damage": 52, "hitbox": Rect2(8, -30, 68, 28), "kb": Vector2(2.4, -2.0),
			"hitstun": 18, "blockstun": 11, "hitstop": 6, "meter": 7.0, "hit_sfx": "heavy",
			"flash": 2, "shake": 1.0, "kicks": true,
			"pose_s": {"leg_f": 20, "knee_f": 90, "lean": 26, "arm_b": -30},
			"pose_a": {"leg_f": 120, "knee_f": 10, "lean": 34, "arm_b": -40, "arm_f": 40, "elb_f": 90}}),
		"rush": MoveData.make({"id": "sprint dash", "display": "SPRINT DASH", "level": 2, "startup": 6, "active": 16,
			"recovery": 14, "damage": 100, "hitbox": Rect2(5, -109, 52, 86), "dash_speed": 8.0, "dash_from": 6, "dash_to": 22,
			"knockdown": true, "kb": Vector2(4, -5), "hitstun": 20, "blockstun": 14, "chip": 0.15, "hitstop": 8,
			"meter": 8.0, "hit_sfx": "heavy", "flash": 4, "shake": 2.0,
			"pose_s": {"lean": 20, "leg_f": 40, "knee_f": 60},
			"pose_a": {"lean": 38, "arm_f": 20, "elb_f": 70, "arm_b": -40, "elb_b": 60, "leg_f": 55, "knee_f": 70, "leg_b": -35, "knee_b": 40}}),
		# In possession the dash carries the ball: the tackle's hitbox reaches the
		# ball at his feet, so the ball is knocked loose down the pitch on the
		# first active frame — whiffed or not, which is a fair price for carrying
		# it in.
		"tackle": MoveData.make({"id": "driving tackle", "display": "DRIVING TACKLE", "level": 2, "startup": 6, "active": 16,
			"recovery": 14, "damage": 105, "hitbox": Rect2(5, -104, 58, 82), "dash_speed": 8.2, "dash_from": 6, "dash_to": 22,
			"knockdown": true, "kb": Vector2(4.2, -5), "hitstun": 22, "blockstun": 14, "chip": 0.15, "hitstop": 8,
			"meter": 8.0, "hit_sfx": "heavy", "flash": 4, "shake": 2.0, "kicks": true,
			"pose_s": {"lean": 22, "leg_f": 45, "knee_f": 70},
			"pose_a": {"lean": 40, "arm_f": 18, "elb_f": 65, "arm_b": -42, "elb_b": 55, "leg_f": 58, "knee_f": 74, "leg_b": -38, "knee_b": 44}}),
		"anti": MoveData.make({"id": "bicycle kick", "display": "BICYCLE KICK", "level": 2, "startup": 4, "active": 12,
			"recovery": 16, "damage": 55, "hits": 2, "hit_interval": 6, "hitbox": Rect2(-8, -156, 68, 104),
			"rise_vel": Vector2(1.5, -10.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.5, -8.0),
			"hitstun": 30, "blockstun": 14, "chip": 0.15, "hitstop": 7, "meter": 8.0, "spin": -360.0, "hit_sfx": "heavy",
			"flash": 3, "shake": 1.5,
			"pose_s": {"leg_f": 40, "knee_f": 80, "lean": -5},
			"pose_a": {"leg_f": 170, "knee_f": 0, "leg_b": 40, "knee_b": 80, "arm_f": -30, "arm_b": -50, "ground": 0, "hip": -46}}),
		"hyper": MoveData.make({"id": "game over combo", "display": "GAME OVER COMBO!", "level": 3, "startup": 16, "active": 1,
			"recovery": 50, "invuln": 45, "prop": "controller", "sfx": "special", "flash": 5, "shake": 2.0,
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(560, 72), "offset": Vector2(39, -75), "life": 56,
				"hits": 12, "interval": 4, "damage": 20, "hitstun": 16, "kb": Vector2(1.2, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "special"},
			"pose_s": {"arm_f": 80, "elb_f": 60, "arm_b": 80, "elb_b": 60, "lean": -5},
			"pose_a": {"arm_f": 90, "elb_f": 0, "arm_b": 95, "elb_b": 0, "lean": 8}}),
	}
	size = 0.9  # Ulises is about 10% shorter than Emilia
	# Clean stylized: proportional head, lean limbs, fitted clothing.
	head_scale = 1.3
	build = 0.85
	scale_moves()


# --- The ball -------------------------------------------------------------------
# Ulises' signature mechanic: a real ball on the floor that both players fight
# over. See design/characters_redesign.md. It is a Projectile with the `persistent`
# lifecycle, so it reuses the existing hit resolution and drawing.

## How close the ball has to be for him to be dribbling it.
const BALL_PICKUP := 30.0
## Where the ball sits at his feet while he has it.
const BALL_DRIBBLE := 15.0
const BALL_SIZE := Vector2(18, 18)
## The hyper beam is wider when he brought the ball to the fight.
const HYPER_SIZE := Vector2(560, 72)
const HYPER_SIZE_BALL := Vector2(660, 104)

## The one ball this fighter owns. It is his, so it never hits him.
var ball: Projectile = null


## True when the ball is at rest within `BALL_PICKUP` of his feet. Possession is a
## fact about the arena rather than a hidden flag, so a player can read it.
func has_ball(f: Fighter) -> bool:
	return false


## Puts the ball down at his feet, resting. This is also the self-heal, so a ball
## that somehow left play comes back rather than leaving him without one.
func _spawn_ball(f: Fighter) -> void:
	if f == null or f.fight == null or not is_instance_valid(f.fight):
		return
	ball = f.fight.spawn_projectile(f, {
		"kind": "ball", "size": BALL_SIZE, "speed": 0.0, "life": 99999,
		"damage": 45, "hitstun": 14, "blockstun": 8, "kb": Vector2(2, 0),
		"hitstop": 5, "meter": 4.0, "level": 0, "hit_sfx": "kick",
		"persistent": true, "recoverable": true, "slot": false, "z": 0, "sfx": "",
	})
	if ball != null:
		ball.position = Vector2(f.position.x + f.facing * BALL_DRIBBLE, Fighter.GROUND_Y - BALL_SIZE.y * 0.5)
		ball.rest()


func on_round_start(f: Fighter) -> void:
	ball = null


func tick(f: Fighter) -> void:
	pass


## The ball decides which of the two specials he gets, and whether the rush is a
## carrying tackle. Everything else about him is unchanged.
func choose_move(key: String, f: Fighter) -> String:
	match key:
		"proj":
			return "proj"
		"rush":
			return "tackle" if has_ball(f) else "rush"
	return key


func on_move_frame(f: Fighter, m: MoveData, sf: int) -> void:
	if sf != m.startup or f.fight == null:
		return
	if m.id == "game over combo":
		m.projectile["size"] = HYPER_SIZE_BALL if has_ball(f) else HYPER_SIZE


## Connected chain, KOF-style: an odd hit is the authored front limb, an even
## hit is the other limb, so a light-light string reads as a one-two instead of
## the same arm twice. Specials are left alone: the bicycle kick already poses
## both legs and swapping it lands backwards.
func adjust_attack_pose(f: Fighter, m: MoveData, p: Dictionary) -> Dictionary:
	if m.level > 1 or f.chain % 2 == 1:
		return p
	return _cross_pose(p)


## Trades the front limb for the back one. Only the joints the move actually
## authored are touched, so a jab with one arm and a kick with one leg each get
## the other limb instead of a whole-body mirror, and the idle limb goes to a
## guard or a plant rather than standing still.
func _cross_pose(p: Dictionary) -> Dictionary:
	var out := p.duplicate()
	if p.has("arm_f"):
		var strike_arm: float = p["arm_f"]
		var strike_elb: float = float(p.get("elb_f", 10.0))
		if p.has("arm_b"):
			out["arm_f"] = p["arm_b"]
			out["elb_f"] = float(p.get("elb_b", 90.0))
		else:
			out["arm_f"] = 25.0
			out["elb_f"] = 80.0
		out["arm_b"] = strike_arm
		out["elb_b"] = strike_elb
	if p.has("leg_f"):
		var strike_leg: float = p["leg_f"]
		var strike_knee: float = float(p.get("knee_f", 10.0))
		if p.has("leg_b"):
			out["leg_f"] = p["leg_b"]
			out["knee_f"] = float(p.get("knee_b", 20.0))
		else:
			out["leg_f"] = -12.0
			out["knee_f"] = 18.0
		out["leg_b"] = strike_leg
		out["knee_b"] = strike_knee
	# Lean off the strike side so the weight shift is visible too.
	if p.has("lean"):
		out["lean"] = -float(p["lean"]) * 0.35
	return out


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	var knot := FighterRenderer.head_point(s, Vector2(-10.5, -6.5))
	r.chain("band1", knot, 6, 4.5, 0.1, 0.8, 0.45)
	r.chain("band2", knot + Vector2(0, 1.5), 5, 4.5, 0.18, 0.82, 0.35)


func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
	r.ribbon(r.chain_local("band2"), 3.0, 1.6, r.colors["band"].darkened(0.15))
	r.ribbon(r.chain_local("band1"), 3.4, 2.0, r.colors["band"])


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var top: Vector2 = hip + up * FighterRenderer.TORSO
	var acc: Color = r.colors["accent"]
	# Fitted jersey: follows the body, with a collar, side seam, and hem.
	r.draw_line(hip + perp * 5.5 + up * 2.0, top + perp * 4.5 - up * 3.0, acc, 2.0, true)
	r.poly(PackedVector2Array([top + perp * 5.0 - up * 0.5, top - perp * 4.5 - up * 0.5, top + perp * 1.5 - up * 5.0]), acc, 1.0)
	r.draw_colored_polygon(PackedVector2Array([top + perp * 3.0 - up * 1.0, top - perp * 2.0 - up * 1.0, top + perp * 1.2 - up * 3.5]), r.colors["skin"])
	r.draw_line(hip + perp * 7.0 + up * 1.5, hip - perp * 7.0 + up * 1.5, acc, 1.5, true)
	# Slight belly curve, not a balloon.
	var belly := hip + up * 9.0 + perp * 4.5
	r.poly(FighterRenderer.ellipse_pts(belly, 6.0, 4.0, atan2(perp.y, perp.x)), r.colors["shirt"], 1.2)
	# Number 10, clean and readable.
	var num: Vector2 = hip + up * 17.0 + perp * 1.0
	r.draw_set_transform(num, atan2(up.x, -up.y), Vector2(signf(r.scale.x) * 0.5, 0.5))
	UI.text(r, Vector2(0, 5), "10", 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 4, acc.darkened(0.4))
	r.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not r.head_only:
		r.limb(s["hip_b"], s["hip_b"].lerp(s["knee_b"], 0.62), 12.0, 11.0, FighterRenderer.dk(r.colors["shorts"]))


func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	r.limb(s["hip_f"], s["hip_f"].lerp(s["knee_f"], 0.62), 12.0, 11.0, r.colors["shorts"])
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	# Fitted shorts: mid-thigh, with a hem line.
	r.limb(s["hip"] - perp * 6.0 + up * 2.0, s["hip"] + perp * 6.0 + up * 2.0, 4.5, 4.5, r.colors["shorts"])
	# Sock stripe at the cuff.
	for leg in [["knee_f", "foot_f"], ["knee_b", "foot_b"]]:
		var a: Vector2 = s[leg[0]].lerp(s[leg[1]], 0.15)
		var d: Vector2 = (s[leg[1]] - s[leg[0]]).normalized()
		var n := Vector2(-d.y, d.x)
		r.draw_line(a - n * 3.0, a + n * 3.0, Color.WHITE, 1.5, true)


func draw_face(r: FighterRenderer) -> void:
	draw_ear(r)
	_stylized_eyes(r)
	_stylized_brows(r)
	_stylized_mouth(r)


func draw_hair_back(r: FighterRenderer) -> void:
	r.shaded_poly(PackedVector2Array([Vector2(-10, 5), Vector2(-14, 0), Vector2(-12, -8), Vector2(-4, -14), Vector2(0, -4)]), r.colors["hair"], 1.8, 0.7)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	# Short textured hair that follows the skull. A few tufts at the front.
	var hair := PackedVector2Array([
		Vector2(-9, 5), Vector2(-13, 1), Vector2(-10, -3), Vector2(-14, -8), Vector2(-8, -12),
		Vector2(-3, -14), Vector2(2, -13), Vector2(7, -10), Vector2(10, -6), Vector2(11, -2),
		Vector2(8, -1), Vector2(3, -3), Vector2(-2, -4), Vector2(-6, -2), Vector2(-8, 2),
	])
	r.shaded_poly(hair, hc, 1.8, 0.8)
	for st in [[Vector2(-5, -10), Vector2(-1, -13)], [Vector2(1, -11), Vector2(5, -12)], [Vector2(-9, -6), Vector2(-4, -8)]]:
		r.draw_line(st[0], st[1], FighterRenderer.hl(hc), 1.0, true)
	# Headband.
	var band: Color = r.colors["band"]
	r.shaded_poly(PackedVector2Array([Vector2(-10, -7.5), Vector2(-2, -9), Vector2(10, -8), Vector2(10, -5.5),
		Vector2(-1.5, -6.5), Vector2(-9.5, -4.5)]), band, 1.4, 0.75)
	r.ball(Vector2(-10, -5.5), 2.0, band)


func _stylized_eyes(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(4.4, 1.8), Vector2(10.2, 1.4)]
	var g := r.gaze.limit_length(1.0)
	for i in 2:
		var e: Vector2 = spots[i]
		var near := 0.85 if i == 1 else 1.0
		# Almond shape: wider than tall, with a slight upward tilt at the outer corner.
		var white := FighterRenderer.ellipse_pts(e, 3.2 * near, 2.6 * near, 0.0, 12)
		r.draw_colored_polygon(white, Color(0.98, 0.97, 0.95))
		r.draw_polyline(Stage._closed(white), FighterRenderer.OUT, 1.0, true)
		# Iris and pupil.
		var ic := e + g * 0.5
		r.draw_circle(ic, 1.6 * near, r.colors["eyes"])
		r.draw_circle(ic + g * 0.3, 0.8 * near, FighterRenderer.OUT)
		# Single catchlight.
		r.draw_circle(ic + Vector2(-0.4, -0.4), 0.35, Color.WHITE)
		# Upper lid line.
		r.draw_arc(e + Vector2(0, -0.5), 3.0 * near, PI + 0.3, TAU - 0.3, 8, FighterRenderer.OUT, 0.8, true)


func _stylized_brows(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(4.4, 1.8), Vector2(10.2, 1.4)]
	for i in 2:
		var e: Vector2 = spots[i]
		var ry := 3.8
		var b0 := e + Vector2(-2.5, -ry - 1.5)
		var b1 := e + Vector2(2.5, -ry - 1.0)
		if r.expr == "attack":
			b0.y += 1.0
			b1.y += 1.0
		elif r.expr == "hurt" or r.expr == "shock":
			b0.y -= 1.0
			b1.y -= 1.0
		r.draw_line(b0, b1, FighterRenderer.OUT, 1.2, true)


func _stylized_mouth(r: FighterRenderer) -> void:
	var m := Vector2(8.4, 6.8)
	var ink := Color(0.45, 0.15, 0.12)
	# Confident smirk: a slight curve, not a huge grin.
	r.draw_line(m + Vector2(-1.5, 0.0), m + Vector2(1.5, -0.5), ink, 1.0, true)
	r.draw_line(m + Vector2(-1.0, 0.5), m + Vector2(1.0, 0.3), ink, 0.6, true)


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	if r.prop != "":
		r.part(s["elb_f"].lerp(s["hand_f"], 0.55), s["elb_f"].lerp(s["hand_f"], 0.7), 7.5, 7.0, r.colors["accent"])
	match r.prop:
		"ball_intro":
			var bounce := absf(sin(r.t * 0.12)) * 16.0
			Projectile.draw_soccer_ball(r, s["hand_f"] + Vector2(0, -12 - bounce), 8.0, r.t * 0.1)
		"book":
			# Held open in the left hand, presented outward like a trophy.
			var c: Vector2 = s["hand_b"] + Vector2(4, -10)
			r.poly(PackedVector2Array([c, c + Vector2(-14, -4), c + Vector2(-14, 10), c + Vector2(0, 13)]), Color("fffaf0"), 1.5)
			r.poly(PackedVector2Array([c, c + Vector2(14, -4), c + Vector2(14, 10), c + Vector2(0, 13)]), Color("fffaf0"), 1.5)
			for i in 3:
				r.draw_line(c + Vector2(-12, 1 + i * 3), c + Vector2(-3, 3 + i * 3), Color(0.5, 0.5, 0.6), 1.0)
				r.draw_line(c + Vector2(3, 3 + i * 3), c + Vector2(12, 1 + i * 3), Color(0.5, 0.5, 0.6), 1.0)
		"controller":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5
			r.shaded_poly(PackedVector2Array([c + Vector2(-13, -6), c + Vector2(13, -6), c + Vector2(15, 6), c + Vector2(7, 8),
				c + Vector2(-7, 8), c + Vector2(-15, 6)]), Color("3a3a48"), 1.5)
			r.draw_rect(Rect2(c + Vector2(-11, -1.5), Vector2(7, 2.2)), Color.WHITE)
			r.draw_rect(Rect2(c + Vector2(-8.5, -4), Vector2(2.2, 7)), Color.WHITE)
			r.draw_circle(c + Vector2(7, -2), 1.8, Color("ff5a5a"))
			r.draw_circle(c + Vector2(10.5, 1.5), 1.8, Color("5ac8ff"))
