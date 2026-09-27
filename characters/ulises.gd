class_name UlisesDef
extends CharacterDef
## Ulises: soccer, running, reading and video games. Fast and sporty.


func _init() -> void:
	id = "ulises"
	display = "ULISES"
	likes = "Soccer, running, reading, video games"
	win_quote = "Game over! Now, where was I in my book?"
	colors = {
		"skin": Color("f2c29b"), "hair": Color("2b1a12"), "shirt": Color("2f6fe0"), "sleeve": Color("2f6fe0"),
		"forearm": Color("f2c29b"), "hands": Color("f2c29b"), "pants": Color("f2c29b"), "shorts": Color("f4f4f4"),
		"legs": Color("2f6fe0"), "shoes": Color("b6f23a"), "eyes": Color("5a3a22"), "accent": Color("34c759"),
		"band": Color("e8322e"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("e0402f"), "sleeve": Color("e0402f"), "accent": Color("ffffff"), "legs": Color("e0402f"),
		"shoes": Color("ffd23f"), "band": Color("2f6fe0"), "shorts": Color("2a2a38")}, true)
	walk_speed = 3.4
	back_speed = 2.8
	jump_vel = -10.5
	jump_x = 4.0
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
		"win": {"lean": 0, "head": 14, "leg_f": 82, "knee_f": 12, "leg_b": 76, "knee_b": 28,
			"arm_f": 72, "elb_f": 65, "arm_b": 84, "elb_b": 62},
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
		"proj": MoveData.make({"id": "power shot", "display": "POWER SHOT", "level": 2, "startup": 12, "active": 1,
			"recovery": 20, "prop": "ball", "sfx": "whoosh",
			"projectile": {"kind": "ball", "speed": 6.5, "size": Vector2(18, 18), "offset": Vector2(34, -18), "life": 150,
				"damage": 70, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "kick", "hit_sfx": "heavy"},
			"pose_s": {"leg_f": -40, "knee_f": 40, "lean": -5, "arm_f": 60, "arm_b": -20},
			"pose_a": {"leg_f": 95, "knee_f": 5, "lean": -10, "arm_b": 60, "arm_f": -20}}),
		"rush": MoveData.make({"id": "sprint dash", "display": "SPRINT DASH", "level": 2, "startup": 6, "active": 16,
			"recovery": 14, "damage": 100, "hitbox": Rect2(5, -109, 52, 86), "dash_speed": 8.0, "dash_from": 6, "dash_to": 22,
			"knockdown": true, "kb": Vector2(4, -5), "hitstun": 20, "blockstun": 14, "chip": 0.15, "hitstop": 8,
			"meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"lean": 20, "leg_f": 40, "knee_f": 60},
			"pose_a": {"lean": 38, "arm_f": 20, "elb_f": 70, "arm_b": -40, "elb_b": 60, "leg_f": 55, "knee_f": 70, "leg_b": -35, "knee_b": 40}}),
		"anti": MoveData.make({"id": "bicycle kick", "display": "BICYCLE KICK", "level": 2, "startup": 4, "active": 12,
			"recovery": 16, "damage": 55, "hits": 2, "hit_interval": 6, "hitbox": Rect2(-8, -156, 68, 104),
			"rise_vel": Vector2(1.5, -10.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.5, -8.0),
			"hitstun": 30, "blockstun": 14, "chip": 0.15, "hitstop": 7, "meter": 8.0, "spin": -360.0, "hit_sfx": "heavy",
			"pose_s": {"leg_f": 40, "knee_f": 80, "lean": -5},
			"pose_a": {"leg_f": 170, "knee_f": 0, "leg_b": 40, "knee_b": 80, "arm_f": -30, "arm_b": -50, "ground": 0, "hip": -46}}),
		"hyper": MoveData.make({"id": "game over combo", "display": "GAME OVER COMBO!", "level": 3, "startup": 16, "active": 1,
			"recovery": 50, "invuln": 45, "prop": "controller", "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(560, 72), "offset": Vector2(39, -75), "life": 56,
				"hits": 12, "interval": 4, "damage": 20, "hitstun": 16, "kb": Vector2(1.2, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "special"},
			"pose_s": {"arm_f": 80, "elb_f": 60, "arm_b": 80, "elb_b": 60, "lean": -5},
			"pose_a": {"arm_f": 90, "elb_f": 0, "arm_b": 95, "elb_b": 0, "lean": 8}}),
	}
	size = 0.9  # Ulises is about 10% shorter than Emilia
	scale_moves()


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
	# Side stripe, V collar and hem of the jersey.
	r.draw_line(hip + perp * 6.0 + up * 2.0, top + perp * 5.0 - up * 3.0, acc, 2.5, true)
	r.poly(PackedVector2Array([top + perp * 5.5 - up * 0.5, top - perp * 5.0 - up * 0.5, top + perp * 1.5 - up * 6.0]), acc, 1.2)
	r.draw_colored_polygon(PackedVector2Array([top + perp * 3.5 - up * 1.0, top - perp * 2.5 - up * 1.0, top + perp * 1.2 - up * 4.0]), r.colors["skin"])
	r.draw_line(hip + perp * 8.0 + up * 1.5, hip - perp * 8.0 + up * 1.5, acc, 2.0, true)
	# Number 10, kept readable when facing left.
	var num: Vector2 = hip + up * 17.0 + perp * 1.0
	r.draw_set_transform(num, atan2(up.x, -up.y), Vector2(signf(r.scale.x) * 0.5, 0.5))
	UI.text(r, Vector2(0, 5), "10", 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 4, acc.darkened(0.4))
	r.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not r.head_only:
		# Back leg of the shorts (the front one is drawn over the front leg).
		r.part(s["hip_b"], s["hip_b"].lerp(s["knee_b"], 0.6), 13.0, 12.0, FighterRenderer.dk(r.colors["shorts"]))


func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	r.part(s["hip_f"], s["hip_f"].lerp(s["knee_f"], 0.6), 13.0, 12.0, r.colors["shorts"])
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	r.part(s["hip"] - perp * 7.0 + up * 2.0, s["hip"] + perp * 7.0 + up * 2.0, 5.0, 5.0, r.colors["shorts"])
	# Sock stripes.
	for leg in [["knee_f", "foot_f"], ["knee_b", "foot_b"]]:
		var a: Vector2 = s[leg[0]].lerp(s[leg[1]], 0.18)
		var d: Vector2 = (s[leg[1]] - s[leg[0]]).normalized()
		var n := Vector2(-d.y, d.x)
		r.draw_line(a - n * 3.6, a + n * 3.6, Color.WHITE, 1.8, true)


func draw_face(r: FighterRenderer) -> void:
	draw_ear(r)
	r.face(r.colors["eyes"])


func draw_hair_back(r: FighterRenderer) -> void:
	r.shaded_poly(PackedVector2Array([Vector2(-10, 5), Vector2(-14, 0), Vector2(-12, -8), Vector2(-4, -14), Vector2(0, -4)]), r.colors["hair"], 1.8, 0.7)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	var hair := PackedVector2Array([
		Vector2(-9, 5), Vector2(-15, 1), Vector2(-11, -3), Vector2(-19, -7), Vector2(-11, -10), Vector2(-17, -16),
		Vector2(-8, -15), Vector2(-9, -23), Vector2(-2, -17), Vector2(2, -24), Vector2(5, -16), Vector2(11, -21),
		Vector2(10, -13), Vector2(16, -12), Vector2(11.5, -8), Vector2(13, -4.5), Vector2(9, -6), Vector2(7.5, -2),
		Vector2(5, -6), Vector2(2, -3.5), Vector2(-0.5, -6), Vector2(-3, -2), Vector2(-5.5, -4), Vector2(-6, 3),
	])
	r.shaded_poly(hair, hc, 2.0, 0.82)
	for st in [[Vector2(-6, -14), Vector2(-1, -18)], [Vector2(1, -15), Vector2(5, -18)], [Vector2(-10, -9), Vector2(-5, -11)]]:
		r.draw_line(st[0], st[1], FighterRenderer.hl(hc), 1.3, true)
	# Headband.
	var band: Color = r.colors["band"]
	r.shaded_poly(PackedVector2Array([Vector2(-11, -8.5), Vector2(-2, -11), Vector2(11.8, -9.5), Vector2(11.5, -6.2),
		Vector2(-1.5, -7.6), Vector2(-10.6, -4.8)]), band, 1.6, 0.75)
	r.ball(Vector2(-10.5, -6.5), 2.2, band)


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	# Wristband.
	r.part(s["elb_f"].lerp(s["hand_f"], 0.55), s["elb_f"].lerp(s["hand_f"], 0.7), 7.5, 7.0, r.colors["accent"])
	match r.prop:
		"ball":
			if r.prop_t < 12:
				Projectile.draw_soccer_ball(r, s["foot_f"] + Vector2(12, -5), 8.0, 0.0)
		"ball_intro":
			var bounce := absf(sin(r.t * 0.12)) * 16.0
			Projectile.draw_soccer_ball(r, s["hand_f"] + Vector2(0, -12 - bounce), 8.0, r.t * 0.1)
		"book":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5 + Vector2(2, -5)
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
