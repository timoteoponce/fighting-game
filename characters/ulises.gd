class_name UlisesDef
extends CharacterDef
## Ulises: soccer, running, reading and video games. Fast and sporty.


func _init() -> void:
	id = "ulises"
	display = "ULISES"
	likes = "Soccer, running, reading, video games"
	win_quote = "Reading is for winners!"
	gag_items = ["ball", "tooth", "star"]
	taunt_lines = ["TOO SLOW!", "GOOOAL!", "NICE TRY!"]
	hurt_lines = ["OOF!", "MY BALL!", "HEY!"]
	# "white" is a warm off-white, not Color.WHITE. shaders/post_fx.gdshader blooms
	# anything above luminance 0.90, so a true white fill blooms, glows and loses
	# its ink edge — the eyes, the shirt number and the sock cuffs all read as
	# washed-out blobs. Everything that needs to look like white fabric or a
	# sclera uses this instead.
	colors = {
		"skin": Color("f2c29b"), "hair": Color("1c120c"), "shirt": Color("2f6fe0"), "sleeve": Color("2f6fe0"),
		"forearm": Color("f2c29b"), "hands": Color("f2c29b"), "pants": Color("f2c29b"), "shorts": Color("e6e0d2"),
		"legs": Color("2f6fe0"), "shoes": Color("8ed63a"), "eyes": Color("4a2a14"), "accent": Color("3cb54a"),
		"band": Color("e02323"), "white": Color("e6e0d2"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("e0402f"), "sleeve": Color("e0402f"), "accent": Color("ffd23f"), "legs": Color("e0402f"),
		"shoes": Color("e8c84a"), "band": Color("2f6fe0"), "shorts": Color("e6e0d2"), "white": Color("e6e0d2")}, true)
	walk_speed = 3.4
	back_speed = 2.8
	jump_vel = -10.5
	jump_x = 4.0
	voice_pitch = 250.0
	roster_order = 0
	win_prop = "v_sign"
	intro_prop = "ball_intro"
	specials_text = [
		["L + H", "Power Shot"],
		["FWD + L + H", "Sprint Dash"],
		["DOWN + L + H", "Bicycle Kick"],
		["BACK + L + H", "GAME OVER COMBO"],
	]
	poses = {
		"intro": {"arm_f": 160, "elb_f": 15, "arm_b": 30, "elb_b": 100, "lean": -4},
		# Raised V, not a book: the front arm is straight up along the sign and
		# the back arm hangs loose. `lean` is negative so his chin is up.
		"win": {"lean": -4, "head": 4, "leg_f": 26, "knee_f": 14, "leg_b": -22, "knee_b": 16,
			"arm_f": 158, "elb_f": 8, "arm_b": 52, "elb_b": 62},
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
	var white: Color = r.colors["white"]
	# Chest shading down the back half, so the jersey is not one flat blue mass.
	r.draw_colored_polygon(PackedVector2Array([
		hip - perp * 5.2 + up * 2.0, hip - perp * 6.0 + up * 14.0,
		hip - perp * 4.6 + up * 24.0, top - perp * 3.2 - up * 1.0,
	]), r.colors["shirt"].darkened(0.13))
	# Shoulder yoke: a seam across the top of the chest, the detail that makes
	# the kit read as a made garment rather than a painted tube.
	r.draw_line(top + perp * 5.2 - up * 1.2, top - perp * 4.2 - up * 1.2, r.colors["shirt"].darkened(0.22), 1.3, true)
	# White V-neck: skin inside, white trim on the two edges. The painting has a
	# V, not a collar band, and no side stripe down the body.
	var v := top + perp * 0.8 - up * 5.0
	r.draw_colored_polygon(PackedVector2Array([top + perp * 4.6 - up * 0.5, top - perp * 3.4 - up * 0.5, v]), r.colors["skin"])
	r.draw_line(top + perp * 4.6 - up * 0.2, v, white, 1.4, true)
	r.draw_line(top - perp * 3.4 - up * 0.2, v, white, 1.4, true)
	# Hem, hanging a little loose below the waist.
	r.draw_line(hip + perp * 5.6 + up * 1.5, hip - perp * 5.2 + up * 1.5, r.colors["shirt"].darkened(0.28), 1.5, true)
	# Slight belly curve, not a balloon. The painting has a round stomach.
	var belly := hip + up * 8.0 + perp * 4.8
	r.poly(FighterRenderer.ellipse_pts(belly, 5.6, 3.8, atan2(perp.y, perp.x)), r.colors["shirt"], 1.2)
	# Number 10, clean and readable.
	var num: Vector2 = hip + up * 17.0 + perp * 1.0
	r.draw_set_transform(num, atan2(up.x, -up.y), Vector2(signf(r.scale.x) * 0.5, 0.5))
	UI.text(r, Vector2(0, 5), "10", 16, white, HORIZONTAL_ALIGNMENT_CENTER, 4, acc.darkened(0.4))
	r.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not r.head_only:
		# Back leg of the shorts (the front one is drawn over the front leg).
		var sb: Vector2 = s["hip_b"].lerp(s["knee_b"], 0.62)
		_short(r, s["hip_b"], sb, true)
		_shoulder(r, s["sh_b"], s["elb_b"])
		_cuff(r, s["sh_b"], s["elb_b"])


## His own jersey, in torso space: `up` is shoulder-ward, `perp` is forward
## (the belly side, since the fighter faces +x). Shoulders wider than the waist,
## chest fuller than the back, and a hem that hangs slightly loose.
func torso_outline(_r: FighterRenderer, s: Dictionary) -> PackedVector2Array:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var b := build
	var pts := PackedVector2Array()
	for f in [[0.0, 5.8], [0.30, 6.4], [0.62, 7.6], [0.85, 9.2], [1.0, 6.4],
			[1.0, -6.0], [0.86, -8.4], [0.58, -6.6], [0.0, -5.4]]:
		pts.append(hip + up * FighterRenderer.TORSO * float(f[0]) + perp * float(f[1]) * b)
	return pts


## Green shoulder flash, the band the painting has over each shoulder. Drawn as
## a thick stroke across the top of the upper arm, so it survives the arm swing.
func _shoulder(r: FighterRenderer, sh: Vector2, elb: Vector2) -> void:
	var d := elb - sh
	if d.length() < 1.0:
		return
	var u := d.normalized()
	var n := Vector2(-u.y, u.x)
	var p := sh + u * 3.4
	r.draw_line(p - n * 3.2, p + n * 3.2, r.colors["accent"], 2.2, true)


## White sleeve cuff at the end of the short sleeve. The shared `_sleeve` is
## drawn by the renderer before `draw_props`, so this sits on top of it.
func _cuff(r: FighterRenderer, sh: Vector2, elb: Vector2) -> void:
	var d := elb - sh
	if d.length() < 2.0:
		return
	var u := d.normalized()
	var n := Vector2(-u.y, u.x)
	var w := 7.2 * build
	var p := sh + u * (w * 0.42)
	var white: Color = r.colors["white"]
	r.draw_line(p - n * (w * 0.48), p + n * (w * 0.48), white, 1.8, true)


## One short: a fitted tube over the hip with the green side stripe the painting
## has. `back` darkens it so the far leg reads behind the near one.
func _short(r: FighterRenderer, hip: Vector2, end: Vector2, back: bool) -> void:
	var col: Color = r.colors["shorts"]
	if back:
		col = FighterRenderer.dk(col)
	r.limb(hip, end, 12.0, 11.0, col)
	var d := end - hip
	if d.length() < 1.0:
		return
	var n := Vector2(-d.y, d.x).normalized()
	r.draw_line(hip + n * 3.4, end + n * 2.8, r.colors["accent"], 1.6, true)


## Studs and a lace tick on the shared shoe. `FighterRenderer.shoe` is not
## overridden, so the lime cleat colour is all the base needed.
func _cleat(r: FighterRenderer, foot: Vector2, fwd: Vector2) -> void:
	if fwd.length_squared() < 0.001:
		return
	fwd = fwd.normalized()
	var up := Vector2(fwd.y, -fwd.x)
	var stud := Color(0.16, 0.14, 0.12)
	for t: float in [-1.5, 1.8, 5.0]:
		r.draw_circle(foot + fwd * t - up * 2.3, 0.5, stud)
	r.draw_line(foot + fwd * 1.0 + up * 1.2, foot + fwd * 3.5 + up * 1.4, r.colors["white"], 0.7, true)


func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	_short(r, s["hip_f"], s["hip_f"].lerp(s["knee_f"], 0.62), false)
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	# Waistband, sitting on the hip rather than a second pair of thighs.
	r.limb(s["hip"] - perp * 6.0 + up * 2.0, s["hip"] + perp * 6.0 + up * 2.0, 4.5, 4.5, r.colors["shorts"].darkened(0.08))
	# Socks are solid blue in the painting, with a bare knee between short and
	# sock, so there is no white cuff. A darker turnover at the top of each sock
	# is the one detail that stops them reading as painted tubes.
	for leg in [["knee_f", "foot_f"], ["knee_b", "foot_b"]]:
		var knee: Vector2 = s[leg[0]]
		var foot: Vector2 = s[leg[1]]
		var d: Vector2 = foot - knee
		if d.length() < 1.0:
			continue
		var n := Vector2(-d.y, d.x).normalized()
		var a: Vector2 = knee + d.normalized() * 4.5
		r.draw_line(a - n * 3.4, a + n * 3.4, r.colors["legs"].darkened(0.22), 1.6, true)
	_cleat(r, s["foot_f"], s["foot_dir_f"])
	_cleat(r, s["foot_b"], s["foot_dir_b"])


func draw_face(r: FighterRenderer) -> void:
	_ear(r)
	_jaw(r)
	_eyes(r)
	_brows(r)
	_nose(r)
	_mouth(r)


## A warm shadow tone. `FighterRenderer.shade` lerps toward a purple, which on
## warm skin reads as grey and looks like a scar at this size. This is the same
## value, just on the skin's own hue.
func _warm_shade(col: Color, amount := 0.22) -> Color:
	return col.darkened(amount).lerp(Color(0.42, 0.22, 0.26), 0.10)


## Cheekbone and the shadow under the jaw, as two soft warm shapes. Anything
## stronger than this on a head 20 units wide reads as a hollow rather than
## as form.
func _jaw(r: FighterRenderer) -> void:
	var skin: Color = r.colors["skin"]
	r.draw_colored_polygon(PackedVector2Array([
		Vector2(-3.4, 3.2), Vector2(-1.2, 7.4), Vector2(1.0, 8.2), Vector2(-0.6, 6.0), Vector2(-2.2, 3.6),
	]), _warm_shade(skin, 0.13))


## The ear on the back edge of the cheek, below the hairline and in front of the
## hair mass, so it reads as an ear rather than a patch on the temple. Drawn
## first, so the head fill and the hair tidy its front edge.
func _ear(r: FighterRenderer) -> void:
	var skin: Color = r.colors["skin"]
	var c := Vector2(-7.6, 1.8)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(c, 1.5, 2.4, -0.2, 12), skin)
	r.draw_polyline(Stage._closed(FighterRenderer.ellipse_pts(c, 1.5, 2.4, -0.2, 12)), FighterRenderer.OUT, 0.85, true)
	r.draw_arc(c + Vector2(0.5, 0.0), 0.95, 0.3, PI - 0.35, 8, _warm_shade(skin, 0.2), 0.6, true)


## His own head, in head space, nose to the right. The shared head is a circle
## with a chin blob stuck on; this is a real skull: brow, cheekbone, jaw angle
## and a chin that comes to a soft point. Keep it convex-ish and smooth — a
## self-intersecting outline gets replaced by its convex hull in `safe()`.
## Vertical layout: hairline -11, brow -4.6, eye 0.4, nose 3.6, mouth 6.4.
func head_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-3.2, -12.6), Vector2(2.6, -12.0), Vector2(7.2, -9.2), Vector2(10.0, -4.8),
		Vector2(10.6, 0.4), Vector2(9.2, 4.6), Vector2(6.6, 7.6), Vector2(2.8, 9.6),
		Vector2(-0.6, 10.0), Vector2(-4.0, 8.6), Vector2(-6.8, 5.6), Vector2(-9.2, 1.2),
		Vector2(-10.2, -3.6), Vector2(-8.6, -8.6), Vector2(-6.0, -11.8),
	])


## The back of the skull, drawn before the head fill. A separate mass so the
## face outline stays clean where the two meet.
func draw_hair_back(r: FighterRenderer) -> void:
	r.shaded_poly(PackedVector2Array([
		Vector2(-9.4, 2.0), Vector2(-12.4, -2.4), Vector2(-11.6, -8.0), Vector2(-6.0, -11.4),
		Vector2(-1.0, -6.0), Vector2(-3.0, 1.0),
	]), r.colors["hair"], 1.8, 0.7)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	# A cap that follows his new skull, kept flat so a self-intersecting polygon
	# cannot be replaced by its convex hull and turn the whole hair into a blob.
	# It stops at the hairline so it never sits on the brows.
	r.shaded_poly(PackedVector2Array([
		Vector2(-8.2, -1.4), Vector2(-10.4, -5.4), Vector2(-8.8, -9.4), Vector2(-4.6, -12.4),
		Vector2(0.6, -13.0), Vector2(5.6, -11.2), Vector2(9.0, -7.4), Vector2(10.0, -3.0),
		Vector2(7.0, -3.6), Vector2(3.0, -6.4), Vector2(-2.0, -6.8), Vector2(-6.0, -4.6),
	]), hc, 1.8, 0.8)
	# The painting's spikes, each its own triangle so one spike cannot collapse
	# the rest of the hair. Bigger and more layered than a plain cap.
	for tuft in [
		[Vector2(-5.4, -9.6), Vector2(-3.0, -17.0), Vector2(0.2, -10.0)],
		[Vector2(0.4, -10.2), Vector2(3.8, -18.4), Vector2(6.6, -9.4)],
		[Vector2(-8.6, -6.6), Vector2(-12.6, -13.0), Vector2(-5.4, -8.6)],
		[Vector2(5.4, -7.6), Vector2(10.2, -13.6), Vector2(9.0, -5.2)],
		[Vector2(-1.8, -11.2), Vector2(0.6, -20.0), Vector2(3.0, -11.6)],
	]:
		r.shaded_poly(PackedVector2Array(tuft), hc, 1.0, 0.8)
	# One highlight band across the front of the cap, which is what makes hair
	# look like hair and not a black helmet.
	for st in [[Vector2(-5.6, -8.4), Vector2(-0.6, -10.2)], [Vector2(0.8, -10.0), Vector2(5.0, -8.6)]]:
		r.draw_line(st[0], st[1], FighterRenderer.hl(hc), 1.1, true)
	# Headband. The knot stays at the chain anchor, or the tails detach.
	var band: Color = r.colors["band"]
	r.shaded_poly(PackedVector2Array([Vector2(-10.4, -7.0), Vector2(-2, -8.6), Vector2(9.8, -7.6), Vector2(9.8, -5.0),
		Vector2(-1.5, -6.0), Vector2(-9.8, -4.4)]), band, 1.4, 0.75)
	r.ball(Vector2(-10.5, -6.5), 2.0, band)


## Eye centres in head space, nose to the right. The nose-side eye sits further
## right and slightly smaller, so the face has a 3/4 turn rather than staring
## straight out. `eye_spots` is the shared lookup; the HUD cut-in reads it.
func eye_spots() -> Array:
	return [Vector2(3.6, 0.4), Vector2(8.6, 0.1)]


## Which eye to draw. Split out from the drawing so the choice is a pure
## function of the expression: a character that owns the face owns the whole
## vocabulary, not just the static shape. Returns "happy", "ko", "dizzy",
## "blink" or "open".
func eye_style(expr: String, t: float) -> String:
	if expr in ["happy", "win"]:
		return "happy"
	if expr == "ko":
		return "ko"
	if expr == "dizzy":
		return "dizzy"
	# The blink timer is the shared one: 6 frames of every 190, only while calm.
	if expr == "normal" and int(t) % 190 < 6:
		return "blink"
	return "open"


## His eyes. Five shapes at most, the same budget the shared `face()` works to:
## white, iris, pupil, one catchlight and a single lid arc. His head is ~28
## units wide in a fight, so an eye is about six logical pixels across — any
## more layers than this stop reading as an eye and start reading as a smudge.
## That thinness is also why the eye has to carry the expression through shape
## alone, which is what `eye_style` picks.
func _eyes(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(3.6, 0.4), Vector2(8.6, 0.1)]
	var ink := FighterRenderer.OUT
	var sclera: Color = r.colors["white"]
	var style := eye_style(r.expr, r.t)
	# A big hit bugs the eyes out for a few frames.
	var pop := 1.0 + 0.6 * (float(r.eye_pop) / 9.0)
	# Knocked-out faces stop tracking the opponent.
	var g := Vector2.ZERO if r.expr in ["ko", "dizzy", "hurt"] else r.gaze.limit_length(1.0)
	for i in 2:
		var e: Vector2 = spots[i]
		var near := 0.82 if i == 1 else 1.0
		if style == "happy":
			r.draw_arc(e + Vector2(0, 0.8), 2.0 * near, PI, TAU, 8, ink, 1.5, true)
			continue
		if style == "ko":
			var rad := 2.1 * near
			r.draw_line(e + Vector2(-rad, -rad * 0.8), e + Vector2(rad, rad * 0.8), ink, 1.6, true)
			r.draw_line(e + Vector2(rad, -rad * 0.8), e + Vector2(-rad, rad * 0.8), ink, 1.6, true)
			continue
		if style == "dizzy":
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, 2.0 * near, 1.7 * near, 0.0, 10), sclera)
			r.draw_arc(e, 2.0 * near, 0.0, TAU, 10, ink, 0.9, true)
			r.draw_circle(e + Vector2.from_angle(r.t * 0.15 + float(i)) * 0.7 * near, 0.55, ink)
			continue
		var sc := near * pop
		if style == "blink":
			r.draw_line(e + Vector2(-2.6 * sc, 0.3), e + Vector2(2.5 * sc, 0.15), ink, 1.3, true)
			continue
		# Squint: the lid drops over the iris on an attack and opens wide on a
		# shock. This is most of what sells the expression at six pixels.
		var squint := 1.0
		var pupil := 0.34
		match r.expr:
			"attack":
				squint = 0.55
			"hurt":
				squint = 0.5
				pupil = 0.22
			"shock":
				squint = 1.12
				pupil = 0.18
			"smug":
				squint = 0.45 if i == 1 else 0.72
		var ry := maxf(0.9, 2.4 * sc * clampf(squint, 0.4, 1.15))
		var rx := 3.0 * sc
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, rx, ry, 0.0, 10), sclera)
		var ir := minf(rx * 0.44, ry * 0.9)
		var ic := e + g * rx * 0.16
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(ic, ir, ir * 0.9, 0.0, 8), r.colors["eyes"])
		r.draw_circle(ic + g * 0.1, maxf(0.4, ir * pupil * 1.3), ink)
		# The one deliberately bright white: a sub-pixel specular dot that
		# should sparkle, the only thing on a fighter allowed to bloom.
		r.draw_circle(ic + Vector2(-ir * 0.4, -ir * 0.4), 0.28, Color.WHITE)
		# Upper lid, drawn last so it crops the iris.
		r.draw_arc(e + Vector2(0, -ry * 0.15), rx * 0.94, PI + 0.35, TAU - 0.35, 8, ink, 0.95, true)


func _brows(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(3.6, 0.4), Vector2(8.6, 0.1)]
	for i in 2:
		var e: Vector2 = spots[i]
		# Determined, like the painting: the inner end sits lower, so the two
		# brows angle in toward the nose.
		var y := -4.0
		var inner := 1.3
		if r.expr == "attack" or r.expr == "smug":
			inner += 0.8
		elif r.expr == "hurt" or r.expr == "shock" or r.expr == "ko" or r.expr == "dizzy":
			y -= 1.3
			inner = -0.4
		var rx := 2.4
		var a := e + Vector2(-rx, y)
		var b := e + Vector2(rx * 0.85, y - inner)
		if i == 1:
			a = e + Vector2(-rx * 0.85, y - inner)
			b = e + Vector2(rx, y)
		r.draw_line(a, b, FighterRenderer.OUT, 1.6, true)


## A small nose, drawn as a warm shadow on the bridge with one nostril. It sits
## between the eyes and the mouth, well inside the cheek at x 10.6 so it cannot
## spike out past the outline.
func _nose(r: FighterRenderer) -> void:
	var sh: Color = _warm_shade(r.colors["skin"], 0.2)
	r.draw_colored_polygon(PackedVector2Array([
		Vector2(5.8, 0.8), Vector2(7.0, 2.7), Vector2(5.4, 3.2),
	]), sh)
	r.draw_circle(Vector2(5.5, 3.1), 0.32, sh.darkened(0.18))


## The painting's open grin with one tooth, and two blush strokes on the cheek.
## `ko` and `hurt` swap the grin for a taller open mouth, `dizzy` for a squiggle
## and `smug` for a lopsided line, so the mouth agrees with the eyes.
func _mouth(r: FighterRenderer) -> void:
	var m := Vector2(4.9, 6.2)
	var ink := Color(0.45, 0.12, 0.12)
	var blush := Color(0.85, 0.32, 0.32, 0.5)
	if r.expr == "dizzy":
		var w := PackedVector2Array()
		for wi in 5:
			w.append(m + Vector2(-2.0 + float(wi) * 1.0, 0.5 + (0.7 if wi % 2 == 0 else -0.7)))
		r.draw_polyline(w, ink, 1.1, true)
		return
	if r.expr == "smug":
		r.draw_line(m + Vector2(-1.5, 0.35), m + Vector2(1.6, -0.5), ink, 1.1, true)
		return
	var tall := r.expr == "hurt" or r.expr == "ko"
	r.draw_colored_polygon(PackedVector2Array([
		m + Vector2(-1.7, -0.5), m + Vector2(1.7, -0.6),
		m + Vector2(1.2, 2.0 if tall else 1.2), m + Vector2(-1.2, 1.9 if tall else 1.1),
	]), ink)
	if not tall:
		# The one tooth, on the off-white so it does not bloom.
		r.draw_colored_polygon(PackedVector2Array([
			m + Vector2(-0.6, -0.45), m + Vector2(0.5, -0.5), m + Vector2(0.3, 0.35), m + Vector2(-0.4, 0.3),
		]), r.colors["white"])
	# Blush on the cheek, clear of the jaw shadow and below the eye.
	r.draw_line(Vector2(1.6, 3.4), Vector2(3.0, 4.1), blush, 0.95, true)
	r.draw_line(Vector2(2.1, 4.4), Vector2(3.4, 5.0), blush, 0.95, true)


## The victory sign, on the front hand only. The win pose raises the front arm,
## so the V points along the forearm and stays put while the pose breathes.
func draw_hand(r: FighterRenderer, p: Vector2, col: Color, d: Vector2, front: bool, open: bool) -> void:
	if r.prop == "v_sign" and front:
		_v_sign(r, p, col, d)
		return
	if open:
		r.open_hand(p, col, d)
	else:
		_fist(r, p, col, d)


## A closed fist with real knuckles: a block, four finger creases, a thumb over
## the top and a wrist shadow. The shared fist is a mitten, and at this size the
## creases are what make it read as a hand.
func _fist(r: FighterRenderer, p: Vector2, col: Color, d: Vector2) -> void:
	if d.length_squared() < 0.001:
		d = Vector2.DOWN
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	var shade := FighterRenderer.shade(col)
	r.shaded_poly(PackedVector2Array([
		p - n * 2.9 - d * 0.8, p + n * 2.9 - d * 0.8, p + n * 2.7 + d * 1.6,
		p + n * 1.8 + d * 3.6, p - n * 1.8 + d * 3.6, p - n * 2.7 + d * 1.6,
	]), col, 1.0, 0.82)
	# Finger creases across the front of the block.
	for k: float in [-1.7, -0.6, 0.5, 1.6]:
		var fw := 1.0 - absf(k) * 0.1
		r.draw_line(p + n * k * fw + d * 1.7, p + n * k * fw + d * 3.4, shade, 0.55, true)
	# Thumb laid across the top, and a shadow under it.
	r.part(p + n * 2.3 - d * 0.2, p + n * 0.5 + d * 2.6, 1.7, 1.4, col)
	r.draw_line(p + n * 0.2 + d * 1.5, p + n * 0.2 + d * 3.5, shade, 0.5, true)
	# Knuckle highlight along the top edge.
	r.draw_line(p - n * 2.4 + d * 1.7, p + n * 2.4 + d * 1.7, FighterRenderer.hl(col), 0.55, true)


## Two fingers up. `d` is the forearm direction, so the hand is drawn along it
## rather than in screen space. The sign is drawn large and well splayed: at
## this scale a small one just reads as a closed fist.
func _v_sign(r: FighterRenderer, p: Vector2, col: Color, d: Vector2) -> void:
	if d.length_squared() < 0.001:
		d = Vector2.UP
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	# Three folded fingers, as a closed block that stops short of the knuckles.
	r.shaded_poly(PackedVector2Array([
		p - n * 3.0, p + n * 3.0, p + n * 2.8 + d * 1.0, p + n * 2.0 + d * 3.6,
		p - n * 2.0 + d * 3.6, p - n * 2.8 + d * 1.0,
	]), col, 1.0, 0.82)
	r.draw_line(p + n * 1.1 + d * 1.8, p + n * 0.7 + d * 3.4, FighterRenderer.shade(col), 0.6, true)
	# The two raised fingers: long, and spread wide enough to make a V.
	r.part(p + n * 1.2 - d * 0.2, p + n * 2.9 + d * 7.6, 2.0, 1.6, col)
	r.part(p - n * 1.2 - d * 0.2, p - n * 2.8 + d * 7.6, 2.0, 1.6, col)
	# Thumb across the folded fingers, so the hand does not read as a fork.
	r.part(p + n * 2.6 + d * 0.4, p + n * 0.7 + d * 3.0, 1.6, 1.3, col)


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	# Front shoulder flash and sleeve cuff, over the arm already drawn.
	_shoulder(r, s["sh_f"], s["elb_f"])
	_cuff(r, s["sh_f"], s["elb_f"])
	if r.prop != "" and r.prop != "v_sign":
		r.part(s["elb_f"].lerp(s["hand_f"], 0.55), s["elb_f"].lerp(s["hand_f"], 0.7), 7.5, 7.0, r.colors["accent"])
	match r.prop:
		"ball_intro":
			var bounce := absf(sin(r.t * 0.12)) * 16.0
			Projectile.draw_soccer_ball(r, s["hand_f"] + Vector2(0, -12 - bounce), 8.0, r.t * 0.1)
		"controller":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5
			r.shaded_poly(PackedVector2Array([c + Vector2(-13, -6), c + Vector2(13, -6), c + Vector2(15, 6), c + Vector2(7, 8),
				c + Vector2(-7, 8), c + Vector2(-15, 6)]), Color("3a3a48"), 1.5)
			r.draw_rect(Rect2(c + Vector2(-11, -1.5), Vector2(7, 2.2)), r.colors["white"])
			r.draw_rect(Rect2(c + Vector2(-8.5, -4), Vector2(2.2, 7)), r.colors["white"])
			r.draw_circle(c + Vector2(7, -2), 1.8, Color("ff5a5a"))
			r.draw_circle(c + Vector2(10.5, 1.5), 1.8, Color("5ac8ff"))
