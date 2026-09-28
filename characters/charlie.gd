class_name CharlieDef
extends CharacterDef
## Charlie: basketball and crying, in roughly equal amounts. A beanpole with a
## huge bald head, a nasty grin and a permanent sniffle. Plays as the roster's
## heavyweight — slow, long reach, the hardest single hits — so the frame data
## is the old heavy's, untouched; only the look and the jokes changed.


func _init() -> void:
	id = "charlie"
	display = "CHARLIE"
	likes = "Basketball, crying, crying about basketball"
	win_quote = "I won! ...WAAAAH! These are happy tears!"
	gag_items = ["ball", "tissue", "tooth"]
	taunt_lines = ["NYEH NYEH!", "SWISH!", "CRY ABOUT IT!"]
	hurt_lines = ["WAAAH!", "MOMMY!", "SNIFF..."]
	roster_order = 2
	colors = {
		# Sallow yellow skin and a purple-and-gold tank top jersey. Sleeves and
		# forearms are skin: the bare noodle arms are the joke.
		"skin": Color("e6d163"), "hair": Color("3a2a10"), "shirt": Color("7a3fbf"),
		"sleeve": Color("e6d163"), "forearm": Color("e6d163"), "hands": Color("e6d163"),
		"pants": Color("7a3fbf"), "legs": Color("e6d163"), "shoes": Color("e8453a"),
		"eyes": Color("4f7a2a"), "accent": Color("ffb400"), "trim": Color("ffb400"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("2f9e57"), "pants": Color("2f9e57"), "accent": Color("f4f4f4"),
		"trim": Color("f4f4f4"), "shoes": Color("2a2a2a"),
	}, true)
	# The heavyweight trade: slowest walk and lowest jump on the roster, but the
	# biggest hitboxes and the hardest single hits.
	walk_speed = 2.9
	back_speed = 2.3
	jump_vel = -10.0
	jump_x = 3.2
	voice_pitch = 290.0  # whiny
	head_scale = 1.9  # enormous, egg-shaped, bald
	build = 0.62  # noodle limbs
	win_prop = "tears"
	intro_prop = "ball"
	specials_text = [
		["L + H", "Chest Pass"],
		["FWD + L + H", "Fast Break"],
		["DOWN + L + H", "Rim Shot"],
		["BACK + L + H", "CRYBABY FLOOD"],
	]
	poses = {
		"intro": {"arm_f": 70, "elb_f": 60, "arm_b": 30, "elb_b": 90, "lean": 4, "head": 6},
		"win": {"arm_f": 165, "elb_f": 20, "arm_b": 165, "elb_b": 20, "head": -18, "lean": -5,
			"leg_f": 30, "leg_b": -30},
	}
	moves = {
		# Slower than everyone else's light, but those noodle arms reach.
		"L": MoveData.make({
			"id": "noodle jab", "startup": 5, "active": 3, "recovery": 9, "damage": 45,
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
			"id": "slam dunk", "level": 1, "startup": 10, "active": 4, "recovery": 20, "damage": 95,
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
			"id": "ankle pinch", "crouch": true, "startup": 5, "active": 3, "recovery": 9, "damage": 38,
			"hitbox": Rect2(13, -52, 54, 24), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 82, "elb_f": 0, "lean": 8},
		}),
		# A full floor tantrum, legs flailing.
		"cH": MoveData.make({
			"id": "tantrum kick", "crouch": true, "level": 1, "startup": 9, "active": 5, "recovery": 22,
			"damage": 85, "hitbox": Rect2(8, -28, 90, 28), "knockdown": true, "kb": Vector2(2.4, -4.5),
			"hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 90, "knee_f": 0, "lean": -22, "arm_b": -35, "arm_f": 10, "elb_f": 60},
		}),
		"jL": MoveData.make({
			"id": "block party", "air": true, "startup": 5, "active": 5, "recovery": 7, "damage": 46,
			"hitbox": Rect2(3, -86, 58, 42), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 112, "elb_f": 0, "arm_b": -20},
		}),
		"jH": MoveData.make({
			"id": "dunk drop", "air": true, "level": 1, "startup": 8, "active": 6, "recovery": 11,
			"damage": 85, "hitbox": Rect2(-8, -66, 74, 50), "spike": true, "hitstun": 18,
			"blockstun": 12, "kb": Vector2(3.2, 0), "hitstop": 9, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 70, "knee_f": 50, "leg_b": 40, "knee_b": 70, "lean": 18, "arm_f": -30, "arm_b": -40},
		}),
		# A slow, heavy basketball rather than a quick fireball: Charlie is not
		# allowed to win the long-range game, only to make you respect it.
		"proj": MoveData.make({
			"id": "chest pass", "display": "CHEST PASS", "level": 2, "startup": 15, "active": 1,
			"recovery": 22, "prop": "ball", "sfx": "heavy", "flash": 3, "shake": 1.0,
			"projectile": {
				"kind": "bball", "speed": 4.6, "size": Vector2(34, 44), "offset": Vector2(44, -40),
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
			"id": "fast break", "display": "FAST BREAK", "level": 2, "startup": 8, "active": 20,
			"recovery": 17, "damage": 102, "hitbox": Rect2(2, -112, 58, 92), "dash_speed": 7.0,
			"dash_from": 8, "dash_to": 26, "knockdown": true, "kb": Vector2(5.0, -5.5), "hitstun": 22,
			"blockstun": 15, "chip": 0.18, "hitstop": 9, "meter": 8.0, "hit_sfx": "heavy",
			"flash": 4, "shake": 2.0,
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
			"flash": 3, "shake": 1.5,
			"pose_s": {"arm_f": -20, "elb_f": 60, "leg_f": 40, "knee_f": 90, "lean": 10},
			"pose_a": {"arm_f": 180, "elb_f": 0, "arm_b": -30, "lean": -14, "leg_f": 20, "leg_b": -40, "ground": 0, "hip": -40},
		}),
		# He winds up a sob, then bawls so hard it becomes a tidal wave.
		"hyper": MoveData.make({
			"id": "crybaby flood", "display": "CRYBABY FLOOD!", "level": 3, "startup": 18,
			"active": 1, "recovery": 48, "invuln": 44, "prop": "tears", "sfx": "hyper",
			"flash": 5, "shake": 2.0,
			"projectile": {
				"kind": "tears", "anchored": true, "size": Vector2(300, 150), "offset": Vector2(60, -80),
				"life": 60, "hits": 14, "interval": 4, "damage": 19, "hitstun": 16, "kb": Vector2(1.0, -1.0),
				"chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3, "final_knockdown": true,
				"strength": 99, "sfx": "hyper",
			},
			"keys": [
				# Fists to the eyes, shoulders shaking...
				[0, {"arm_f": 150, "elb_f": 150, "arm_b": 140, "elb_b": 150, "lean": 10, "head": 12}, 0.5],
				[10, {"arm_f": 145, "elb_f": 155, "arm_b": 135, "elb_b": 155, "lean": 14, "head": 16}, 0.8],
				# ...then head back and arms flung wide: full wail.
				[18, {"arm_f": 120, "elb_f": 10, "arm_b": 150, "elb_b": 10, "lean": -14, "head": -22}, 0.95],
				[44, {"arm_f": 110, "elb_f": 30, "arm_b": 130, "elb_b": 30, "lean": -8, "head": -14}, 0.3],
			],
			"events": {18: [["shake", {"amount": 4.0}]]},
		}),
	}
	size = 1.12  # the tall one
	scale_moves()


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	# Three sad wiry hairs on top of the dome, flopping about.
	for i in 3:
		r.chain("hair%d" % i, FighterRenderer.head_point(s, Vector2(-3.0 + i * 3.5, -13.8)), 4, 3.6, -0.2, 0.8, 0.2)


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var top: Vector2 = hip + up * FighterRenderer.TORSO
	var trim: Color = r.colors["trim"]
	# Tank-top trim round the neck and a jersey stripe at the hem.
	r.draw_line(top + perp * 4.0 - up * 1.5, top - perp * 4.0 - up * 1.5, trim, 2.0, true)
	r.draw_line(hip + perp * 5.0 + up * 3.0, hip - perp * 5.0 + up * 3.0, trim, 2.0, true)
	# Jersey number 00, drawn as two rings so it survives the pixel buffer.
	var mid := hip + up * (FighterRenderer.TORSO * 0.55)
	for k in [-1.6, 1.6]:
		r.draw_arc(mid + perp * k, 1.6, 0.0, TAU, 10, trim, 1.0, true)


func draw_hair_back(r: FighterRenderer) -> void:
	# Jug-handle ears, one bigger than the other.
	for e in [[Vector2(-6.5, 1.5), 4.2], [Vector2(-5.0, 0.5), 3.2]]:
		var c: Vector2 = e[0]
		var rr: float = e[1]
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-2.0, 0), rr + 0.9, rr * 1.3 + 0.9, 0.2, 14), FighterRenderer.OUT)
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-2.0, 0), rr, rr * 1.3, 0.2, 14), r.colors["skin"])
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-1.6, 0.3), rr * 0.5, rr * 0.8, 0.2, 10), FighterRenderer.shade(r.colors["skin"]))


func draw_face(r: FighterRenderer) -> void:
	var skin: Color = r.colors["skin"]
	var ink := FighterRenderer.OUT
	# Eye bags first, so the eyes sit in them.
	for e in [Vector2(4.8, 3.6), Vector2(10.7, 3.2)]:
		r.draw_arc(e, 2.6, 0.2, PI - 0.2, 8, FighterRenderer.shade(skin), 1.2, true)
	r.face(r.colors["eyes"])
	# One thick unibrow over both eyes, scowling.
	r.draw_polyline(PackedVector2Array([Vector2(2.0, -5.6), Vector2(5.5, -4.4), Vector2(8.0, -4.9), Vector2(12.6, -6.2)]), ink, 1.3, true)
	# A big lumpy nose, drooping over the mouth.
	var nose := FighterRenderer.ellipse_pts(Vector2(11.6, 4.2), 2.6, 2.1, 0.3, 12)
	r.draw_colored_polygon(nose, FighterRenderer.shade(skin).lerp(Color(0.9, 0.45, 0.35), 0.3))
	r.draw_polyline(Stage._closed(nose), ink, 1.0, true)
	# The sniffle: a drip that swells and drops, over and over.
	var drip := fmod(r.t * 0.04, 1.0)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(11.0, 6.5 + drip * 2.0), 0.9, 1.0 + drip * 1.2), Color(0.7, 0.95, 0.6, 0.9))
	# Snaggletooth poking out over the lip.
	r.draw_colored_polygon(PackedVector2Array([Vector2(7.2, 7.0), Vector2(8.6, 7.0), Vector2(8.2, 9.2)]), Color(1, 0.97, 0.8))
	r.draw_polyline(PackedVector2Array([Vector2(7.2, 7.0), Vector2(8.2, 9.2), Vector2(8.6, 7.0)]), ink, 0.7, true)
	# Pimples.
	for pp in [Vector2(2.0, 5.2), Vector2(-1.0, -6.0), Vector2(6.5, -8.5)]:
		r.draw_circle(pp, 0.8, Color(0.95, 0.4, 0.35), true, -1.0, true)
	# He likes crying. When it goes badly, the taps open.
	if r.expr in ["hurt", "ko", "shock", "dizzy"] or r.prop == "tears":
		for e in [Vector2(4.8, 3.2), Vector2(10.7, 2.8)]:
			var k := fmod(r.t * 0.12 + e.x, 1.0)
			r.draw_line(e, e + Vector2(-0.6, 6.0), Color(0.55, 0.8, 1.0, 0.85), 1.4, true)
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(e + Vector2(-0.6, 3.0 + k * 5.0), 0.9, 1.3), Color(0.6, 0.85, 1.0))


func draw_hair_front(r: FighterRenderer) -> void:
	# Bald dome: just a shine. The three hairs are chains, which live in body
	# space, so they are drawn in draw_props rather than here in head space.
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(1.5, -10.0), 3.2, 1.4, -0.3, 10), Color(1, 1, 0.9, 0.55))


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	for i in 3:
		var hair := r.chain_local("hair%d" % i)
		if hair.size() > 1:
			r.draw_polyline(hair, FighterRenderer.OUT, 1.8, true)
	match r.prop:
		"ball":
			# Dribbling: the ball bounces between his hand and the floor.
			var hand: Vector2 = s["hand_f"]
			var floor_y := maxf(s["foot_f"].y, s["foot_b"].y)
			var k := absf(sin(r.t * 0.18))
			_basketball(r, Vector2(hand.x + 4.0, lerpf(floor_y - 7.0, hand.y + 6.0, k)), 7.0, r.t * 0.2)
		"tears":
			# Two fountains of tears arcing out of his eyes.
			for e in [Vector2(4.8, 2.0), Vector2(10.7, 1.6)]:
				var src := FighterRenderer.head_point(s, e)
				for j in 6:
					var k := fmod(r.t * 0.08 + j / 6.0, 1.0)
					var p := src + Vector2(k * 46.0 * (1.0 if e.x > 6.0 else -0.6), -14.0 * sin(k * PI) + k * 30.0)
					r.draw_colored_polygon(FighterRenderer.ellipse_pts(p, 2.2 - k, 2.8 - k), Color(0.6, 0.85, 1.0, 1.0 - k * 0.6))


## Orange ball with black seams. Static so the projectile can share it.
static func _basketball(ci: CanvasItem, c: Vector2, r: float, rot: float) -> void:
	var ink := FighterRenderer.OUT
	ci.draw_circle(c, r + 1.5, ink, true, -1.0, true)
	ci.draw_circle(c, r, Color("e8722a"), true, -1.0, true)
	ci.draw_circle(c + Vector2(-r * 0.3, -r * 0.3), r * 0.35, Color(1, 0.7, 0.45, 0.6), true, -1.0, true)
	var d := Vector2.from_angle(rot)
	var n := Vector2(-d.y, d.x)
	ci.draw_line(c - d * r, c + d * r, ink, 1.0, true)
	ci.draw_line(c - n * r, c + n * r, ink, 1.0, true)
	ci.draw_arc(c - d * r * 1.1, r * 0.8, rot - 0.9, rot + 0.9, 8, ink, 1.0, true)
	ci.draw_arc(c + d * r * 1.1, r * 0.8, rot + PI - 0.9, rot + PI + 0.9, 8, ink, 1.0, true)
