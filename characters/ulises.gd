class_name UlisesDef
extends CharacterDef
## Ulises: soccer, running, reading and video games. Fast and sporty.


func _init() -> void:
	id = "ulises"
	display = "ULISES"
	likes = "Soccer, running, reading, video games"
	win_quote = "Game over! Now, where was I in my book?"
	colors = {
		"skin": Color("f2c29b"), "hair": Color("3b2417"), "shirt": Color("2f6fe0"), "accent": Color("34c759"),
		"pants": Color("f4f4f4"), "legs": Color("2f6fe0"), "shoes": Color("b6f23a"), "eyes": Color("5a3a22"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("e0402f"), "accent": Color("ffffff"), "legs": Color("e0402f"), "shoes": Color("ffd23f")}, true)
	walk_speed = 3.6
	back_speed = 2.8
	jump_vel = -10.5
	jump_x = 4.0
	win_prop = "book"
	intro_prop = "ball_intro"
	specials_text = [
		["L + H", "Power Shot"],
		["FWD + L + H", "Sprint Dash"],
		["DOWN + L + H", "Bicycle Kick"],
		["BACK + L + H", "GAME OVER COMBO (full meter)"],
	]
	poses = {
		"intro": {"arm_f": 160, "elb_f": 15, "arm_b": 30, "elb_b": 100, "lean": -4},
		"win": {"lean": 0, "head": 14, "leg_f": 82, "knee_f": 12, "leg_b": 76, "knee_b": 28,
			"arm_f": 72, "elb_f": 65, "arm_b": 84, "elb_b": 62},
	}
	moves = {
		"L": MoveData.make({"id": "jab", "startup": 4, "active": 3, "recovery": 8, "damage": 40,
			"hitbox": Rect2(10, -72, 36, 18), "hitstun": 14, "blockstun": 9, "kb": Vector2(2, 0), "meter": 4.0,
			"pose_s": {"arm_f": 60, "elb_f": 100, "lean": 10}, "pose_a": {"arm_f": 92, "elb_f": 0, "lean": 16, "arm_b": 30, "elb_b": 110}}),
		"H": MoveData.make({"id": "rising kick", "level": 1, "startup": 9, "active": 4, "recovery": 18, "damage": 90,
			"hitbox": Rect2(10, -112, 46, 64), "launch": true, "kb": Vector2(1.5, -10.5), "hitstun": 30, "blockstun": 16,
			"hitstop": 8, "meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"lean": 0, "leg_f": 60, "knee_f": 90}, "pose_a": {"lean": -18, "leg_f": 165, "knee_f": 0, "arm_f": -20, "elb_f": 30, "arm_b": 60, "elb_b": 60}}),
		"cL": MoveData.make({"id": "low jab", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 35,
			"hitbox": Rect2(10, -40, 38, 18), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 85, "elb_f": 0}}),
		"cH": MoveData.make({"id": "slide tackle", "crouch": true, "level": 1, "startup": 8, "active": 5, "recovery": 20,
			"damage": 80, "hitbox": Rect2(6, -20, 64, 20), "knockdown": true, "kb": Vector2(2, -4), "hitstop": 7,
			"meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 88, "knee_f": 0, "lean": -20, "arm_b": -30}}),
		"jL": MoveData.make({"id": "air punch", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 40,
			"hitbox": Rect2(4, -66, 40, 30), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 115, "elb_f": 0}}),
		"jH": MoveData.make({"id": "volley kick", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 80, "hitbox": Rect2(2, -52, 50, 36), "spike": true, "hitstun": 18, "blockstun": 12, "kb": Vector2(3, 0),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": 20, "knee_b": 90, "lean": -10}}),
		"proj": MoveData.make({"id": "power shot", "display": "POWER SHOT", "level": 2, "startup": 12, "active": 1,
			"recovery": 20, "prop": "ball", "sfx": "whoosh",
			"projectile": {"kind": "ball", "speed": 6.5, "size": Vector2(18, 18), "offset": Vector2(26, -14), "life": 150,
				"damage": 70, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "kick", "hit_sfx": "heavy"},
			"pose_s": {"leg_f": -40, "knee_f": 40, "lean": -5, "arm_f": 60, "arm_b": -20},
			"pose_a": {"leg_f": 95, "knee_f": 5, "lean": -10, "arm_b": 60, "arm_f": -20}}),
		"rush": MoveData.make({"id": "sprint dash", "display": "SPRINT DASH", "level": 2, "startup": 6, "active": 16,
			"recovery": 14, "damage": 100, "hitbox": Rect2(4, -84, 40, 66), "dash_speed": 9.0, "dash_from": 6, "dash_to": 22,
			"knockdown": true, "kb": Vector2(4, -5), "hitstun": 20, "blockstun": 14, "chip": 0.15, "hitstop": 8,
			"meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"lean": 20, "leg_f": 40, "knee_f": 60},
			"pose_a": {"lean": 38, "arm_f": 20, "elb_f": 70, "arm_b": -40, "elb_b": 60, "leg_f": 55, "knee_f": 70, "leg_b": -35, "knee_b": 40}}),
		"anti": MoveData.make({"id": "bicycle kick", "display": "BICYCLE KICK", "level": 2, "startup": 4, "active": 12,
			"recovery": 16, "damage": 55, "hits": 2, "hit_interval": 6, "hitbox": Rect2(-6, -120, 52, 80),
			"rise_vel": Vector2(1.5, -10.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.5, -8.0),
			"hitstun": 30, "blockstun": 14, "chip": 0.15, "hitstop": 7, "meter": 8.0, "spin": -360.0, "hit_sfx": "heavy",
			"pose_s": {"leg_f": 40, "knee_f": 80, "lean": -5},
			"pose_a": {"leg_f": 170, "knee_f": 0, "leg_b": 40, "knee_b": 80, "arm_f": -30, "arm_b": -50, "ground": 0, "hip": -32}}),
		"hyper": MoveData.make({"id": "game over combo", "display": "GAME OVER COMBO!", "level": 3, "startup": 16, "active": 1,
			"recovery": 50, "invuln": 45, "prop": "controller", "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(560, 56), "offset": Vector2(30, -58), "life": 56,
				"hits": 12, "interval": 4, "damage": 25, "hitstun": 16, "kb": Vector2(1.2, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "special"},
			"pose_s": {"arm_f": 80, "elb_f": 60, "arm_b": 80, "elb_b": 60, "lean": -5},
			"pose_a": {"arm_f": 90, "elb_f": 0, "arm_b": 95, "elb_b": 0, "lean": 8}}),
	}


func draw_torso(r: ChibiRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp := Vector2(-up.y, up.x)
	var neck: Vector2 = s["neck"]
	var hip: Vector2 = s["hip"]
	var acc: Color = r.colors["accent"]
	# Jersey stripe, collar and number badge.
	r.draw_line(hip + perp * 3.0, neck - up * 2.0 + perp * 3.0, acc, 3.0, true)
	r.draw_colored_polygon(PackedVector2Array([neck - up * 2.0 + perp * 6.0, neck - up * 2.0 - perp * 6.0, neck - up * 7.0]), acc)
	var badge := hip + up * 13.0 - perp * 3.0
	r.draw_circle(badge, 3.5, Color.WHITE, true, -1.0, true)
	r.draw_circle(badge, 2.0, acc, true, -1.0, true)
	r.draw_line(hip + perp * 9.0 + up * 1.5, hip - perp * 9.0 + up * 1.5, acc, 2.5, true)


func draw_face(r: ChibiRenderer) -> void:
	r.face(colors["eyes"])
	r.draw_line(Vector2(-1, -6), Vector2(5, -6.5), ChibiRenderer.OUT, 1.6, true)
	r.draw_line(Vector2(9, -6.5), Vector2(14, -6), ChibiRenderer.OUT, 1.6, true)


func draw_hair_front(r: ChibiRenderer) -> void:
	var hair := PackedVector2Array([
		Vector2(-17, 4), Vector2(-22, -2), Vector2(-18, -7), Vector2(-23, -12), Vector2(-16, -15), Vector2(-19, -22),
		Vector2(-10, -20), Vector2(-9, -27), Vector2(-2, -21), Vector2(3, -26), Vector2(7, -19), Vector2(14, -22),
		Vector2(14, -14), Vector2(20, -12), Vector2(15, -8), Vector2(11, -9), Vector2(8, -6), Vector2(5, -10),
		Vector2(1, -8), Vector2(-3, -9), Vector2(-7, -5), Vector2(-10, 1), Vector2(-13, 6),
	])
	r.poly(hair, colors["hair"], 2.0)
	r.draw_line(Vector2(-6, -17), Vector2(2, -18), colors["hair"].lightened(0.3), 2.0, true)


func draw_props(r: ChibiRenderer, s: Dictionary) -> void:
	match r.prop:
		"ball":
			if r.prop_t < 12:
				Projectile.draw_soccer_ball(r, s["foot_f"] + Vector2(10, -3), 7.0, 0.0)
		"ball_intro":
			var bounce := absf(sin(r.t * 0.12)) * 14.0
			Projectile.draw_soccer_ball(r, s["hand_f"] + Vector2(0, -10 - bounce), 7.0, r.t * 0.1)
		"book":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5 + Vector2(2, -4)
			r.poly(PackedVector2Array([c, c + Vector2(-12, -3), c + Vector2(-12, 9), c + Vector2(0, 12)]), Color("fffaf0"), 1.5)
			r.poly(PackedVector2Array([c, c + Vector2(12, -3), c + Vector2(12, 9), c + Vector2(0, 12)]), Color("fffaf0"), 1.5)
			for i in 3:
				r.draw_line(c + Vector2(-10, 1 + i * 3), c + Vector2(-3, 3 + i * 3), Color(0.5, 0.5, 0.6), 1.0)
				r.draw_line(c + Vector2(3, 3 + i * 3), c + Vector2(10, 1 + i * 3), Color(0.5, 0.5, 0.6), 1.0)
		"controller":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5
			r.poly(PackedVector2Array([c + Vector2(-11, -5), c + Vector2(11, -5), c + Vector2(13, 5), c + Vector2(6, 7), c + Vector2(-6, 7), c + Vector2(-13, 5)]), Color("3a3a48"), 1.5)
			r.draw_rect(Rect2(c + Vector2(-9, -1.5), Vector2(6, 2)), Color.WHITE)
			r.draw_rect(Rect2(c + Vector2(-7, -3.5), Vector2(2, 6)), Color.WHITE)
			r.draw_circle(c + Vector2(6, -2), 1.6, Color("ff5a5a"))
			r.draw_circle(c + Vector2(9, 1), 1.6, Color("5ac8ff"))
