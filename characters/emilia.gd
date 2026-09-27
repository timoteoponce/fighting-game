class_name EmiliaDef
extends CharacterDef
## Emilia: magic wand, anime, drawing and aerobics. Jumps high, long-range spark.


func _init() -> void:
	id = "emilia"
	display = "EMILIA"
	likes = "Wizard stories, anime, drawing, aerobics"
	win_quote = "That's going in my sketchbook!"
	gag_items = ["pencil", "star", "note"]
	taunt_lines = ["ABRACADABRA!", "SPARKLE!", "DRAW THIS!"]
	hurt_lines = ["EEK!", "MY PENCIL!", "RUDE!"]
	colors = {
		"skin": Color("f5cfb0"), "hair": Color("2e1a2a"), "shirt": Color("7b3fd1"), "sleeve": Color("7b3fd1"),
		"forearm": Color("7b3fd1"), "hands": Color("f5cfb0"), "pants": Color("4b2a8a"), "legs": Color("4b2a8a"),
		"shoes": Color("5a2a6e"), "eyes": Color("8a4fff"), "accent": Color("ff7eb6"), "skirt": Color("4b2a8a"),
		"trim": Color("ffd24a"), "cape": Color("3b1f6e"), "blouse": Color("fff4fa"), "boots": Color("5a2a6e"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("1fa3a3"), "sleeve": Color("1fa3a3"), "forearm": Color("1fa3a3"), "accent": Color("ffd24a"),
		"skirt": Color("12706f"), "pants": Color("12706f"), "legs": Color("12706f"),
		"shoes": Color("3a2a10"), "boots": Color("3a2a10"), "eyes": Color("1f9e6a"), "cape": Color("0d4a4a")}, true)
	walk_speed = 3.3
	back_speed = 2.7
	jump_vel = -11.6
	jump_x = 3.5
	voice_pitch = 330.0
	roster_order = 1
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
			"hitbox": Rect2(13, -96, 55, 23), "hitstun": 14, "blockstun": 9, "kb": Vector2(2, 0), "meter": 4.0,
			"pose_s": {"arm_f": 60, "elb_f": 100, "lean": 8}, "pose_a": {"arm_f": 95, "elb_f": 0, "lean": 14}}),
		"H": MoveData.make({"id": "rising swirl", "level": 1, "startup": 8, "active": 4, "recovery": 18, "damage": 90,
			"hitbox": Rect2(5, -153, 60, 91), "launch": true, "kb": Vector2(1.5, -10.5), "hitstun": 30, "blockstun": 16,
			"hitstop": 8, "meter": 8.0, "hit_sfx": "heavy", "prop": "cast",
			"pose_s": {"arm_f": 10, "elb_f": 40, "lean": 15}, "pose_a": {"arm_f": 175, "elb_f": 0, "lean": -12, "leg_f": 30, "arm_b": -20}}),
		"cL": MoveData.make({"id": "low poke", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 35,
			"hitbox": Rect2(13, -52, 55, 23), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 85, "elb_f": 0}}),
		"cH": MoveData.make({"id": "split sweep", "crouch": true, "level": 1, "startup": 8, "active": 5, "recovery": 20,
			"damage": 80, "hitbox": Rect2(8, -26, 81, 26), "knockdown": true, "kb": Vector2(2, -4), "hitstop": 7,
			"meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 88, "knee_f": 0, "leg_b": -80, "knee_b": 0, "lean": 10}}),
		"jL": MoveData.make({"id": "air poke", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 45,
			"hitbox": Rect2(5, -83, 55, 39), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 120, "elb_f": 0}}),
		"jH": MoveData.make({"id": "split kick", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 80, "hitbox": Rect2(-13, -70, 81, 47), "spike": true, "hitstun": 18, "blockstun": 12, "kb": Vector2(3, 0),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": -80, "knee_b": 0, "arm_f": 160, "arm_b": 200}}),
		"proj": MoveData.make({"id": "wand spark", "display": "WAND SPARK", "level": 2, "startup": 13, "active": 1,
			"recovery": 20, "prop": "cast", "sfx": "whoosh",
			"projectile": {"kind": "spark", "speed": 8.0, "size": Vector2(22, 16), "offset": Vector2(49, -83), "life": 200,
				"damage": 72, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "magic", "hit_sfx": "light"},
			"pose_s": {"arm_f": 150, "elb_f": 30, "lean": -8}, "pose_a": {"arm_f": 92, "elb_f": 0, "lean": 12}}),
		"rush": MoveData.make({"id": "cartwheel rush", "display": "CARTWHEEL RUSH", "level": 2, "startup": 6, "active": 20,
			"recovery": 12, "damage": 58, "hits": 2, "hit_interval": 9, "hitbox": Rect2(-13, -120, 68, 114),
			"dash_speed": 7.5, "dash_from": 6, "dash_to": 26, "knockdown": true, "kb": Vector2(3, -5), "hitstun": 20,
			"blockstun": 12, "chip": 0.15, "hitstop": 6, "meter": 8.0, "spin": 360.0, "hit_sfx": "heavy",
			"pose_s": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "lean": 15},
			"pose_a": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "leg_f": 35, "knee_f": 0, "leg_b": -35, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -58}}),
		"anti": MoveData.make({"id": "star jump", "display": "STAR JUMP", "level": 2, "startup": 3, "active": 14,
			"recovery": 16, "damage": 45, "hits": 3, "hit_interval": 5, "hitbox": Rect2(-39, -151, 107, 125),
			"rise_vel": Vector2(0.5, -11.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0),
			"hitstun": 30, "blockstun": 12, "chip": 0.15, "hitstop": 5, "meter": 8.0, "prop": "sparkle", "hit_sfx": "light",
			"pose_s": {"leg_f": 60, "knee_f": 100, "leg_b": 20, "knee_b": 100},
			"pose_a": {"arm_f": 150, "elb_f": 0, "arm_b": 210, "elb_b": 0, "leg_f": 40, "knee_f": 0, "leg_b": -40, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -46}}),
		"hyper": MoveData.make({"id": "sketchbook summon", "display": "SKETCHBOOK SUMMON!", "level": 3, "startup": 20, "active": 1,
			"recovery": 40, "invuln": 45, "prop": "sketch", "sfx": "magic",
			"projectile": {"kind": "dragon", "speed": 6.5, "size": Vector2(130, 120), "offset": Vector2(65, -78), "life": 170,
				"hits": 10, "interval": 6, "damage": 32, "hitstun": 18, "kb": Vector2(5, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "hyper"},
			"pose_s": {"arm_f": 140, "elb_f": 40, "arm_b": 70, "elb_b": 80},
			"pose_a": {"arm_f": 100, "elb_f": 0, "arm_b": 70, "elb_b": 80, "lean": 8}}),
	}


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	# Shoulder-length locks. Short segments, so they stop around the collar instead of the waist.
	r.chain("tail1", FighterRenderer.head_point(s, Vector2(-4, -6)), 4, 3.2, 0.28, 0.86, 0.12)
	r.chain("tail2", FighterRenderer.head_point(s, Vector2(-8, -2)), 4, 3.2, 0.30, 0.86, 0.10)
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	r.chain("cape", s["sh_b"] + up * 1.0 - perp * 1.0, 6, 8.5, 0.55, 0.85, 0.08)
	r.chain("scarf", s["neck"] - up * 2.0 - perp * 3.0, 5, 5.0, 0.22, 0.84, 0.3)


func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
	var cape := r.chain_local("cape")
	if cape.size() > 1:
		r.shaded_poly(FighterRenderer.ribbon_pts(cape, 12.0, 20.0), r.colors["cape"], 2.0, 0.75)
		var lining := FighterRenderer.ribbon_pts(cape.slice(cape.size() - 2), 17.0, 20.0)
		r.draw_colored_polygon(lining, r.colors["accent"].darkened(0.2))
	for name in ["tail2", "tail1"]:
		var tail := r.chain_local(name)
		r.ribbon(tail, 8.0, 1.5, r.colors["hair"])
		if tail.size() > 0:
			r.ball(tail[0], 2.4, r.colors["accent"])
	var scarf := r.chain_local("scarf")
	if scarf.size() > 1:
		r.ribbon(scarf, 5.0, 4.0, r.colors["accent"])
		for i in range(1, scarf.size(), 2):
			r.draw_circle(scarf[i], 1.6, Color.WHITE, true, -1.0, true)


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var top: Vector2 = hip + up * FighterRenderer.TORSO
	var trim: Color = r.colors["trim"]
	# Robe lapels and gold trim.
	r.draw_line(top + perp * 5.0 - up * 1.0, hip + perp * 7.0 + up * 12.0, trim, 1.8, true)
	r.draw_line(top - perp * 1.0 - up * 1.0, hip + perp * 3.0 + up * 12.0, trim, 1.4, true)
	r.draw_colored_polygon(PackedVector2Array([top + perp * 4.5 - up * 1.5, top - perp * 0.5 - up * 1.5, hip + perp * 5.0 + up * 13.0]), r.colors["blouse"])
	# Belt.
	r.part(hip - perp * 7.5 + up * 4.0, hip + perp * 7.5 + up * 4.0, 3.5, 3.5, r.colors["cape"])
	r.draw_colored_polygon(FighterRenderer.star_pts(hip + perp * 4.0 + up * 4.0, 3.0, 1.3), trim)
	# Scarf wrapped around the neck.
	var n: Vector2 = top - up * 1.5
	r.part(n - perp * 6.0, n + perp * 6.0, 5.0, 5.0, r.colors["accent"])
	r.draw_line(n - up * 1.0, n + up * 1.5, Color.WHITE, 1.4, true)


func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	var trim: Color = r.colors["trim"]
	var cloth: Color = r.colors["skirt"]
	# Back leg first, so the front flare covers it. Wider at the hem than at the hip.
	for leg in [["hip_b", "foot_b", 0.82], ["hip_f", "foot_f", 1.0]]:
		var a: Vector2 = s[leg[0]]
		var b: Vector2 = s[leg[1]]
		var d: Vector2 = b - a
		if d.length() < 1.0:
			continue
		var n := Vector2(-d.y, d.x).normalized()
		var hem: Vector2 = a.lerp(b, 0.7)
		var top_w: float = 5.2 * float(leg[2])
		var bot_w: float = 11.5 * float(leg[2])
		r.shaded_poly(PackedVector2Array([
			a + n * top_w, a - n * top_w, hem - n * bot_w, hem + n * bot_w,
		]), cloth.darkened(0.12 * (1.0 - leg[2])), 1.8, 0.82)
		r.draw_line(hem - n * (bot_w - 0.4), hem + n * (bot_w - 0.4), trim, 1.7, true)
	# Boot cuffs.
	for leg in [["knee_f", "foot_f", 1.0], ["knee_b", "foot_b", 0.8]]:
		var a: Vector2 = s[leg[0]].lerp(s[leg[1]], 0.5)
		var d: Vector2 = (s[leg[1]] - s[leg[0]]).normalized()
		var boot: Color = r.colors["boots"].darkened(0.2 * (1.0 - leg[2]))
		var n := Vector2(-d.y, d.x)
		r.part(a, s[leg[1]], 8.8, 7.2, boot)
		r.draw_line(a - n * 4.8, a + n * 4.8, boot.lightened(0.35), 2.2, true)


func draw_face(r: FighterRenderer) -> void:
	r.face(r.colors["eyes"], true)


func draw_hair_back(r: FighterRenderer) -> void:
	r.shaded_poly(PackedVector2Array([Vector2(-11, 2), Vector2(-14, -2), Vector2(-12, -10), Vector2(-4, -15.5),
		Vector2(6, -14), Vector2(5, 0), Vector2(-2, 3)]), r.colors["hair"], 1.8, 0.75)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	var bangs := PackedVector2Array([
		Vector2(-11, 4), Vector2(-14, -4), Vector2(-11, -12), Vector2(-3, -16.5), Vector2(6, -15.5), Vector2(12, -10),
		Vector2(14, -3), Vector2(13.5, 4), Vector2(12, -1), Vector2(10.5, -5), Vector2(9, 0), Vector2(7, -6.5),
		Vector2(4.5, -1.5), Vector2(2, -7.5), Vector2(-1, -3), Vector2(-3, -8), Vector2(-5, -1), Vector2(-7, 6),
	])
	r.shaded_poly(bangs, hc, 2.0, 0.85)
	# Side lock framing the face.
	r.shaded_poly(PackedVector2Array([Vector2(11, -6), Vector2(13.5, 0), Vector2(12, 5), Vector2(10, 1)]), hc, 1.5, 0.7)
	for st in [[Vector2(-6, -12), Vector2(0, -14.5)], [Vector2(3, -13.5), Vector2(8, -12)]]:
		r.draw_line(st[0], st[1], FighterRenderer.hl(hc), 1.2, true)
	r.poly(FighterRenderer.star_pts(Vector2(8, -12.5), 3.6, 1.6), r.colors["trim"], 1.1)


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	var hand: Vector2 = s["hand_f"]
	var d: Vector2 = (hand - s["elb_f"]).normalized()
	var tip := hand + d * 22.0
	r.draw_line(hand - d * 3.0, tip, FighterRenderer.OUT, 5.0, true)
	r.draw_line(hand - d * 3.0, tip, Color("8b5a2b"), 3.0, true)
	r.draw_line(hand - d * 2.0, hand + d * 6.0, Color("5a3620"), 3.0, true)
	var glow := r.prop == "cast" or r.prop == "sparkle"
	r.draw_circle(tip, 2.8 if glow else 1.6, Color.WHITE, true, -1.0, true)
	if glow:
		r.draw_circle(tip, 9.0, Color(1, 0.6, 0.9, 0.3), true, -1.0, true)
		r.draw_colored_polygon(FighterRenderer.star_pts(tip, 6.0, 2.4, 4, r.t * 0.2), Color(1, 0.8, 0.95))
	if r.prop == "sparkle":
		for i in 4:
			var a := r.t * 0.08 + TAU * i / 4.0
			var p: Vector2 = s["head"] + Vector2(cos(a) * 32.0, sin(a) * 18.0 - 6.0)
			r.draw_colored_polygon(FighterRenderer.star_pts(p, 4.0, 1.6, 4, a), Color(1, 0.85, 0.3, 0.9))
	if r.prop == "sketch":
		var b: Vector2 = s["hand_b"]
		r.poly(PackedVector2Array([b + Vector2(-2, -15), b + Vector2(17, -17), b + Vector2(18, 7), b + Vector2(-1, 9)]), Color("fffaf0"), 1.5)
		r.draw_line(b + Vector2(-2, -15), b + Vector2(-1, 9), r.colors["accent"], 3.5)
		r.draw_arc(b + Vector2(8, -4), 5.0, 0, TAU * minf(1.0, r.prop_t / 18.0), 12, FighterRenderer.OUT, 1.3, true)
