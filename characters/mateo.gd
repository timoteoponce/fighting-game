class_name MateoDef
extends CharacterDef
## Mateo: drums, basketball and dinosaurs. The big one — slow, tough, and he
## hits like a dropped amplifier. Built entirely from `characters/_template.gd`
## as proof that one file really is a whole fighter.


func _init() -> void:
	id = "mateo"
	display = "MATEO"
	likes = "Drums, basketball, dinosaurs, pancakes"
	win_quote = "Big drum, bigger finish!"
	roster_order = 2
	colors = {
		"skin": Color("c98a5e"), "hair": Color("1c1410"), "shirt": Color("ff8a2b"),
		"sleeve": Color("ff8a2b"), "forearm": Color("c98a5e"), "hands": Color("c98a5e"),
		"pants": Color("2b3244"), "legs": Color("2b3244"), "shoes": Color("f2f2f2"),
		"eyes": Color("4a2f1c"), "accent": Color("1d9bf0"), "vest": Color("d9541f"),
		"wrist": Color("1d9bf0"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("2fbf71"), "sleeve": Color("2fbf71"), "vest": Color("1d7a4a"),
		"pants": Color("3a2a22"), "legs": Color("3a2a22"), "accent": Color("ffd24a"),
		"wrist": Color("ffd24a"), "shoes": Color("2a2a2a"),
	}, true)
	# The heavyweight trade: slowest walk and lowest jump on the roster, but the
	# biggest hitboxes and the hardest single hits.
	walk_speed = 2.9
	back_speed = 2.3
	jump_vel = -10.0
	jump_x = 3.2
	voice_pitch = 215.0
	win_prop = "drum"
	intro_prop = "drum"
	specials_text = [
		["L + H", "Bass Drop"],
		["FWD + L + H", "Shoulder Charge"],
		["DOWN + L + H", "Rim Shot"],
		["BACK + L + H", "DRUM SOLO FINISH"],
	]
	poses = {
		"intro": {"arm_f": 120, "elb_f": 80, "arm_b": 60, "elb_b": 90, "lean": 4, "head": 6},
		"win": {"arm_f": 150, "elb_f": 60, "arm_b": 150, "elb_b": 60, "head": 14, "lean": -3},
	}
	moves = {
		# Slower than everyone else's light, but it reaches further.
		"L": MoveData.make({
			"id": "hammer jab", "startup": 5, "active": 3, "recovery": 9, "damage": 45,
			"hitbox": Rect2(13, -96, 56, 26), "hitstun": 14, "blockstun": 9,
			"kb": Vector2(2.2, 0), "meter": 4.0,
			"keys": [
				[0, {"arm_f": 45, "elb_f": 120, "lean": -6, "arm_b": 40, "elb_b": 80}, 0.5],
				[5, {"arm_f": 88, "elb_f": 10, "lean": 14, "arm_b": 25, "elb_b": 110}, 0.85],
				[9, {"arm_f": 70, "elb_f": 70, "lean": 6}, 0.4],
			],
			"events": {5: [["sfx", {"name": "whoosh"}]]},
		}),
		"H": MoveData.make({
			"id": "drum lift", "level": 1, "startup": 10, "active": 4, "recovery": 20, "damage": 95,
			"hitbox": Rect2(8, -154, 64, 92), "launch": true, "kb": Vector2(1.4, -10.2),
			"hitstun": 30, "blockstun": 16, "hitstop": 9, "meter": 8.0, "hit_sfx": "heavy",
			"keys": [
				[0, {"arm_f": -30, "elb_f": 70, "lean": 16, "leg_f": -10}, 0.45],
				[10, {"arm_f": 175, "elb_f": 0, "lean": -16, "arm_b": -20, "leg_f": 25}, 0.9],
				[16, {"arm_f": 150, "elb_f": 40, "lean": -6}, 0.35],
			],
			"contact_pose": {"arm_f": 185, "elb_f": 0, "lean": -22, "head": -8},
		}),
		"cL": MoveData.make({
			"id": "low knuckle", "crouch": true, "startup": 5, "active": 3, "recovery": 9, "damage": 38,
			"hitbox": Rect2(13, -52, 54, 24), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 82, "elb_f": 0, "lean": 8},
		}),
		"cH": MoveData.make({
			"id": "low spin kick", "crouch": true, "level": 1, "startup": 9, "active": 5, "recovery": 22,
			"damage": 85, "hitbox": Rect2(8, -28, 90, 28), "knockdown": true, "kb": Vector2(2.4, -4.5),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 90, "knee_f": 0, "lean": -22, "arm_b": -35, "arm_f": 10, "elb_f": 60},
		}),
		"jL": MoveData.make({
			"id": "air swat", "air": true, "startup": 5, "active": 5, "recovery": 7, "damage": 46,
			"hitbox": Rect2(3, -86, 58, 42), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 112, "elb_f": 0, "arm_b": -20},
		}),
		"jH": MoveData.make({
			"id": "body drop", "air": true, "level": 1, "startup": 8, "active": 6, "recovery": 11,
			"damage": 85, "hitbox": Rect2(-8, -66, 74, 50), "spike": true, "hitstun": 18,
			"blockstun": 12, "kb": Vector2(3.2, 0), "hitstop": 9, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 70, "knee_f": 50, "leg_b": 40, "knee_b": 70, "lean": 18, "arm_f": -30, "arm_b": -40},
		}),
		# Slow, short-lived shockwave rather than a true fireball: Mateo is not
		# allowed to win the long-range game, only to make you respect it.
		"proj": MoveData.make({
			"id": "bass drop", "display": "BASS DROP", "level": 2, "startup": 15, "active": 1,
			"recovery": 22, "prop": "drum", "sfx": "heavy",
			"projectile": {
				"kind": "spark", "speed": 4.6, "size": Vector2(34, 44), "offset": Vector2(44, -40),
				"life": 90, "damage": 78, "hitstun": 22, "kb": Vector2(3.5, -2.0), "hitstop": 7,
				"meter": 8.0, "sfx": "heavy", "hit_sfx": "heavy",
			},
			"keys": [
				[0, {"arm_f": 150, "elb_f": 30, "arm_b": 150, "elb_b": 30, "lean": -10}, 0.5],
				[15, {"arm_f": 70, "elb_f": 0, "arm_b": 70, "elb_b": 0, "lean": 20, "head": 10}, 0.95],
				[24, {"arm_f": 50, "elb_f": 80, "arm_b": 50, "elb_b": 80, "lean": 6}, 0.3],
			],
			"events": {15: [["sfx", {"name": "heavy"}], ["dust", {"offset": Vector2(30, 0)}], ["shake", {"amount": 3.0}]]},
		}),
		"rush": MoveData.make({
			"id": "shoulder charge", "display": "SHOULDER CHARGE", "level": 2, "startup": 8, "active": 20,
			"recovery": 17, "damage": 102, "hitbox": Rect2(2, -112, 58, 92), "dash_speed": 7.0,
			"dash_from": 8, "dash_to": 26, "knockdown": true, "kb": Vector2(5.0, -5.5), "hitstun": 22,
			"blockstun": 15, "chip": 0.18, "hitstop": 9, "meter": 8.0, "hit_sfx": "heavy",
			"keys": [
				[0, {"lean": -14, "arm_f": 30, "elb_f": 110, "leg_f": 30, "knee_f": 70}, 0.4],
				[8, {"lean": 34, "arm_f": 5, "elb_f": 30, "arm_b": -45, "elb_b": 50, "leg_f": 50, "knee_f": 60}, 0.9],
				[24, {"lean": 30, "arm_f": 10, "elb_f": 40, "leg_f": 20, "knee_f": 40}, 0.25],
			],
		}),
		"anti": MoveData.make({
			"id": "rim shot", "display": "RIM SHOT", "level": 2, "startup": 4, "active": 13,
			"recovery": 18, "damage": 50, "hits": 2, "hit_interval": 6,
			"hitbox": Rect2(-6, -158, 74, 116), "rise_vel": Vector2(1.0, -10.2), "rise_frame": 4,
			"invuln": 9, "launch": true, "kb": Vector2(1.2, -8.2), "hitstun": 30, "blockstun": 14,
			"chip": 0.15, "hitstop": 7, "meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"arm_f": -20, "elb_f": 60, "leg_f": 40, "knee_f": 90, "lean": 10},
			"pose_a": {"arm_f": 180, "elb_f": 0, "arm_b": -30, "lean": -14, "leg_f": 20, "leg_b": -40, "ground": 0, "hip": -40},
		}),
		"hyper": MoveData.make({
			"id": "drum solo finish", "display": "DRUM SOLO FINISH!", "level": 3, "startup": 18,
			"active": 1, "recovery": 48, "invuln": 44, "prop": "drum", "sfx": "hyper",
			"projectile": {
				"kind": "beam", "anchored": true, "size": Vector2(300, 150), "offset": Vector2(60, -80),
				"life": 60, "hits": 14, "interval": 4, "damage": 19, "hitstun": 16, "kb": Vector2(1.0, -1.0),
				"chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3, "final_knockdown": true,
				"strength": 99, "sfx": "hyper",
			},
			"keys": [
				[0, {"arm_f": 160, "elb_f": 20, "arm_b": 40, "elb_b": 100, "lean": -8}, 0.5],
				[18, {"arm_f": 80, "elb_f": 0, "arm_b": 150, "elb_b": 20, "lean": 12}, 0.95],
				[24, {"arm_f": 150, "elb_f": 20, "arm_b": 80, "elb_b": 0, "lean": 8}, 0.8],
				[30, {"arm_f": 80, "elb_f": 0, "arm_b": 150, "elb_b": 20, "lean": 12}, 0.8],
				[36, {"arm_f": 150, "elb_f": 20, "arm_b": 80, "elb_b": 0, "lean": 8}, 0.8],
				[44, {"arm_f": 120, "elb_f": 60, "arm_b": 120, "elb_b": 60, "lean": 0}, 0.3],
			],
			"events": {
				24: [["sfx", {"name": "heavy"}]],
				30: [["sfx", {"name": "heavy"}]],
				36: [["sfx", {"name": "heavy"}]],
			},
		}),
	}
	size = 1.12  # the big kid
	scale_moves()


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	# Two drumsticks tucked in the back pocket, swinging as he moves.
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	r.chain("stick1", s["hip"] - perp * 5.0 + up * 3.0, 4, 5.0, 0.5, 0.9, 0.05)
	r.chain("stick2", s["hip"] - perp * 7.0 + up * 2.0, 4, 5.0, 0.5, 0.9, 0.05)


func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
	for name in ["stick2", "stick1"]:
		var stick := r.chain_local(name)
		if stick.size() > 1:
			r.ribbon(stick, 3.0, 2.0, Color("d8b07a"))
			r.ball(stick[stick.size() - 1], 2.2, Color("f0e0c0"))


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var top: Vector2 = hip + up * FighterRenderer.TORSO
	# Open vest over the shirt: two panels down the front.
	var vest: Color = r.colors["vest"]
	r.poly(PackedVector2Array([
		top + perp * 6.0, top + perp * 1.5, hip + perp * 2.0, hip + perp * 7.5,
	]), vest, 1.2)
	r.poly(PackedVector2Array([
		top - perp * 5.5, top - perp * 1.5, hip - perp * 2.0, hip - perp * 7.0,
	]), FighterRenderer.dk(vest), 1.2)
	# Collar.
	r.draw_line(top + perp * 6.0 - up * 1.0, top - perp * 5.5 - up * 1.0, FighterRenderer.hl(vest), 2.2, true)


func draw_front(r: FighterRenderer, s: Dictionary) -> void:
	# Sweatbands on both wrists — the easiest way to read a heavy character's
	# hands at 320x180.
	var band: Color = r.colors["wrist"]
	for pair in [["elb_f", "hand_f"], ["elb_b", "hand_b"]]:
		var a: Vector2 = s[pair[0]]
		var b: Vector2 = s[pair[1]]
		r.part(a.lerp(b, 0.72), a.lerp(b, 0.92), 6.5, 6.0, band)


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	if r.prop != "drum":
		return
	# A snare drum that lands in front of him, shivering for a few frames after
	# every hit. The wobble is what sells the weight.
	var c: Vector2 = s["hip"] + Vector2(22, 26)
	var wobble := sin(r.t * 0.9) * maxf(0.0, 4.0 - r.prop_t * 0.12)
	var shell := Color("d9541f")
	r.shaded_poly(PackedVector2Array([
		c + Vector2(-16, -6 + wobble), c + Vector2(16, -6 - wobble),
		c + Vector2(14, 8 - wobble), c + Vector2(-14, 8 + wobble),
	]), shell, 1.6)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(0, -6), 16.0, 5.0), Color("f5eddc"))
	r.draw_arc(c + Vector2(0, -6), 15.0, 0.0, TAU, 16, Color("b0b8c4"), 1.2)
	for i in 3:
		var a := -0.6 + i * 0.6
		r.draw_line(c + Vector2(cos(a) * 15.0, -6 + sin(a) * 4.0), c + Vector2(cos(a) * 14.0, 7.0), Color("b0b8c4"), 1.2)
