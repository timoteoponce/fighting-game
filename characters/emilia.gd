class_name EmiliaDef
extends CharacterDef
## Emilia: magic wand, anime, drawing and aerobics. Jumps high, long-range spark.


func _init() -> void:
	id = "emilia"
	display = "EMILIA"
	likes = "Wizard stories, anime, drawing, aerobics"
	win_quote = "That's going in my sketchbook!"
	colors = {
		"skin": Color("f5cfb0"), "hair": Color("3a2230"), "shirt": Color("7b3fd1"), "accent": Color("ff7eb6"),
		"pants": Color("2d2340"), "legs": Color("2d2340"), "shoes": Color("ff7eb6"), "eyes": Color("8a4fff"),
		"skirt": Color("4b2a8a"), "trim": Color("ffd24a"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("1fa3a3"), "accent": Color("ffd24a"), "skirt": Color("12706f"), "shoes": Color("ffd24a"), "eyes": Color("1f9e6a")}, true)
	walk_speed = 3.3
	back_speed = 2.7
	jump_vel = -11.6
	jump_x = 3.5
	win_prop = "sparkle"
	intro_prop = "sparkle"
	specials_text = [
		["L + H", "Wand Spark"],
		["FWD + L + H", "Cartwheel Rush"],
		["DOWN + L + H", "Star Jump"],
		["BACK + L + H", "SKETCHBOOK SUMMON"],
	]
	poses = {
		"intro": {"arm_f": 165, "elb_f": 10, "arm_b": 25, "elb_b": 110, "lean": -6},
		"win": {"arm_f": 150, "elb_f": 150, "arm_b": 20, "elb_b": 115, "leg_b": -26, "head": 10, "lean": -4},
	}
	moves = {
		"L": MoveData.make({"id": "wand poke", "startup": 4, "active": 3, "recovery": 8, "damage": 42,
			"hitbox": Rect2(10, -74, 42, 18), "hitstun": 14, "blockstun": 9, "kb": Vector2(2, 0), "meter": 4.0,
			"pose_s": {"arm_f": 60, "elb_f": 100, "lean": 8}, "pose_a": {"arm_f": 95, "elb_f": 0, "lean": 14}}),
		"H": MoveData.make({"id": "rising swirl", "level": 1, "startup": 8, "active": 4, "recovery": 18, "damage": 90,
			"hitbox": Rect2(4, -118, 46, 70), "launch": true, "kb": Vector2(1.5, -10.5), "hitstun": 30, "blockstun": 16,
			"hitstop": 8, "meter": 8.0, "hit_sfx": "heavy", "prop": "cast",
			"pose_s": {"arm_f": 10, "elb_f": 40, "lean": 15}, "pose_a": {"arm_f": 175, "elb_f": 0, "lean": -12, "leg_f": 30, "arm_b": -20}}),
		"cL": MoveData.make({"id": "low poke", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 35,
			"hitbox": Rect2(10, -40, 42, 18), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 85, "elb_f": 0}}),
		"cH": MoveData.make({"id": "split sweep", "crouch": true, "level": 1, "startup": 8, "active": 5, "recovery": 20,
			"damage": 80, "hitbox": Rect2(6, -20, 62, 20), "knockdown": true, "kb": Vector2(2, -4), "hitstop": 7,
			"meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 88, "knee_f": 0, "leg_b": -80, "knee_b": 0, "lean": 10}}),
		"jL": MoveData.make({"id": "air poke", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 45,
			"hitbox": Rect2(4, -64, 42, 30), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 120, "elb_f": 0}}),
		"jH": MoveData.make({"id": "split kick", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 80, "hitbox": Rect2(-10, -54, 62, 36), "spike": true, "hitstun": 18, "blockstun": 12, "kb": Vector2(3, 0),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": -80, "knee_b": 0, "arm_f": 160, "arm_b": 200}}),
		"proj": MoveData.make({"id": "wand spark", "display": "WAND SPARK", "level": 2, "startup": 13, "active": 1,
			"recovery": 20, "prop": "cast", "sfx": "whoosh",
			"projectile": {"kind": "spark", "speed": 8.0, "size": Vector2(22, 16), "offset": Vector2(38, -64), "life": 200,
				"damage": 72, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "magic", "hit_sfx": "light"},
			"pose_s": {"arm_f": 150, "elb_f": 30, "lean": -8}, "pose_a": {"arm_f": 92, "elb_f": 0, "lean": 12}}),
		"rush": MoveData.make({"id": "cartwheel rush", "display": "CARTWHEEL RUSH", "level": 2, "startup": 6, "active": 20,
			"recovery": 12, "damage": 58, "hits": 2, "hit_interval": 9, "hitbox": Rect2(-10, -92, 52, 88),
			"dash_speed": 7.5, "dash_from": 6, "dash_to": 26, "knockdown": true, "kb": Vector2(3, -5), "hitstun": 20,
			"blockstun": 12, "chip": 0.15, "hitstop": 6, "meter": 8.0, "spin": 360.0, "hit_sfx": "heavy",
			"pose_s": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "lean": 15},
			"pose_a": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "leg_f": 35, "knee_f": 0, "leg_b": -35, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -42}}),
		"anti": MoveData.make({"id": "star jump", "display": "STAR JUMP", "level": 2, "startup": 3, "active": 14,
			"recovery": 16, "damage": 45, "hits": 3, "hit_interval": 5, "hitbox": Rect2(-30, -116, 82, 96),
			"rise_vel": Vector2(0.5, -11.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0),
			"hitstun": 30, "blockstun": 12, "chip": 0.15, "hitstop": 5, "meter": 8.0, "prop": "sparkle", "hit_sfx": "light",
			"pose_s": {"leg_f": 60, "knee_f": 100, "leg_b": 20, "knee_b": 100},
			"pose_a": {"arm_f": 150, "elb_f": 0, "arm_b": 210, "elb_b": 0, "leg_f": 40, "knee_f": 0, "leg_b": -40, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -32}}),
		"hyper": MoveData.make({"id": "sketchbook summon", "display": "SKETCHBOOK SUMMON!", "level": 3, "startup": 20, "active": 1,
			"recovery": 40, "invuln": 45, "prop": "sketch", "sfx": "magic",
			"projectile": {"kind": "dragon", "speed": 6.5, "size": Vector2(130, 120), "offset": Vector2(50, -60), "life": 170,
				"hits": 10, "interval": 6, "damage": 32, "hitstun": 18, "kb": Vector2(5, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "hyper"},
			"pose_s": {"arm_f": 140, "elb_f": 40, "arm_b": 70, "elb_b": 80},
			"pose_a": {"arm_f": 100, "elb_f": 0, "arm_b": 70, "elb_b": 80, "lean": 8}}),
	}


func draw_behind(r: ChibiRenderer, s: Dictionary) -> void:
	# Long hair and twin tails, behind the body.
	var head: Vector2 = s["head"]
	var sway := sin(r.t * 0.1) * 3.0
	var hc: Color = r.colors["hair"]
	r.poly(PackedVector2Array([head + Vector2(-16, -4), head + Vector2(-20 + sway, 22), head + Vector2(-8 + sway, 26), head + Vector2(4, 16), head + Vector2(8, 0)]), hc, 2.0)
	for side in [-1.0, 1.0]:
		var base := head + Vector2(-8 + side * 10.0, -12)
		var tip := base + Vector2(-14 + sway * 2.0, 26)
		r.poly(PackedVector2Array([base, base + Vector2(-12, 8), tip, base + Vector2(2, 14)]), hc, 2.0)
		r.ball(base, 3.0, r.colors["accent"])


func draw_torso(r: ChibiRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp := Vector2(-up.y, up.x)
	var neck: Vector2 = s["neck"]
	var hip: Vector2 = s["hip"]
	var trim: Color = r.colors["trim"]
	var acc: Color = r.colors["accent"]
	# Robe trim down the middle.
	r.draw_line(hip, neck - up * 3.0, trim, 2.0, true)
	# Striped scarf: a band at the neck and a tail on the chest.
	var n := neck - up * 3.0
	r.poly(PackedVector2Array([n + perp * 9.0, n - perp * 9.0, n - perp * 8.0 - up * 5.0, n + perp * 8.0 - up * 5.0]), acc, 1.5)
	var tail := [n + perp * 4.0 - up * 4.0, n + perp * 7.0 - up * 16.0]
	r.draw_line(tail[0], tail[1], ChibiRenderer.OUT, 6.5, true)
	r.draw_line(tail[0], tail[1], acc, 4.5, true)
	for i in 3:
		var p: Vector2 = tail[0].lerp(tail[1], 0.25 + i * 0.3)
		r.draw_line(p - perp * 2.0, p + perp * 2.0, Color.WHITE, 1.5, true)


func draw_over_legs(r: ChibiRenderer, s: Dictionary) -> void:
	# Skirt / robe hem.
	var up: Vector2 = s["up"]
	var perp := Vector2(-up.y, up.x)
	var hip: Vector2 = s["hip"] + up * 3.0
	var hem := hip - up * 12.0
	r.poly(PackedVector2Array([hip + perp * 10.0, hip - perp * 10.0, hem - perp * 14.0, hem + perp * 14.0]), r.colors["skirt"], 2.0)
	r.draw_line(hem - perp * 13.0 + up * 1.5, hem + perp * 13.0 + up * 1.5, r.colors["trim"], 1.5, true)


func draw_hair_back(r: ChibiRenderer) -> void:
	r.ball(Vector2(-2, -1), 19.0, r.colors["hair"])


func draw_face(r: ChibiRenderer) -> void:
	r.face(r.colors["eyes"], true, true)


func draw_hair_front(r: ChibiRenderer) -> void:
	var bangs := PackedVector2Array([
		Vector2(-17, 4), Vector2(-20, -6), Vector2(-15, -16), Vector2(-5, -21), Vector2(6, -20), Vector2(14, -15),
		Vector2(18, -6), Vector2(17, 2), Vector2(15, -3), Vector2(12, -9), Vector2(9, -3), Vector2(6, -10),
		Vector2(2, -4), Vector2(-2, -11), Vector2(-6, -5), Vector2(-9, -10), Vector2(-12, 2), Vector2(-14, 7),
	])
	r.poly(bangs, r.colors["hair"], 2.0)
	var clip := ChibiRenderer.star_pts(Vector2(10, -14), 4.5, 2.0)
	r.poly(clip, r.colors["trim"], 1.2)


func draw_props(r: ChibiRenderer, s: Dictionary) -> void:
	var hand: Vector2 = s["hand_f"]
	var d: Vector2 = (hand - s["elb_f"]).normalized()
	var tip := hand + d * 17.0
	r.draw_line(hand - d * 2.0, tip, ChibiRenderer.OUT, 4.5, true)
	r.draw_line(hand - d * 2.0, tip, Color("8b5a2b"), 2.5, true)
	var glow := r.prop == "cast" or r.prop == "sparkle"
	r.draw_circle(tip, 2.5 if glow else 1.5, Color.WHITE, true, -1.0, true)
	if glow:
		r.draw_circle(tip, 7.0, Color(1, 0.6, 0.9, 0.35), true, -1.0, true)
		r.draw_colored_polygon(ChibiRenderer.star_pts(tip, 5.0, 2.0, 4, r.t * 0.2), Color(1, 0.8, 0.95))
	if r.prop == "sparkle":
		for i in 4:
			var a := r.t * 0.08 + TAU * i / 4.0
			var p: Vector2 = s["head"] + Vector2(cos(a) * 28.0, sin(a) * 16.0 - 6.0)
			r.draw_colored_polygon(ChibiRenderer.star_pts(p, 3.5, 1.4, 4, a), Color(1, 0.85, 0.3, 0.9))
	if r.prop == "sketch":
		var b: Vector2 = s["hand_b"]
		r.poly(PackedVector2Array([b + Vector2(-2, -12), b + Vector2(14, -14), b + Vector2(15, 6), b + Vector2(-1, 8)]), Color("fffaf0"), 1.5)
		r.draw_line(b + Vector2(-2, -12), b + Vector2(-1, 8), r.colors["accent"], 3.0)
		r.draw_arc(b + Vector2(7, -3), 4.0, 0, TAU * minf(1.0, r.prop_t / 18.0), 10, ChibiRenderer.OUT, 1.2, true)
