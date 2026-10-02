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
	win_quote = "Don't cry, it's just a game!"
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
		# "white" is a warm off-white, not Color.WHITE: the post-FX shader blooms
		# anything above luminance 0.90, and his snaggletooth was fff8cc at 0.961,
		# so one tooth glowed and lost its ink edge.
		"white": Color("e6e0d2"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("2f9e57"), "pants": Color("2f9e57"), "accent": Color("f4f4f4"),
		"trim": Color("f4f4f4"), "shoes": Color("2a2a2a"), "white": Color("dcd6c6"),
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
	win_prop = "tears_win"
	intro_prop = "ball"
	specials_text = [
		["L + H", "Chest Pass"],
		["FWD + L + H", "Fast Break"],
		["DOWN + L + H", "Rim Shot"],
		["BACK + L + H", "CRYBABY FLOOD"],
		["UP + L + H", "TEAR GEYSER!"],
	]
	poses = {
		"intro": {"arm_f": 70, "elb_f": 60, "arm_b": 30, "elb_b": 90, "lean": 4, "head": 6},
		# Both hands up over his head, bawling. He cries whether he wins or
		# loses, and the win pose finally admits it.
		"win": {"arm_f": 168, "elb_f": 18, "arm_b": 172, "elb_b": 14, "head": -20, "lean": -6,
			"leg_f": 26, "knee_f": 14, "leg_b": -24, "knee_b": 16},
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
			# Held through the cut-in: fists still pressed to the eyes, chin
			# already going up, braced for it. The sob building before the wail.
			"cutin_pose": {"lean": -16, "head": -26, "arm_f": 148, "elb_f": 152, "arm_b": 138, "elb_b": 152,
				"leg_f": 26, "knee_f": 34, "leg_b": -22, "knee_b": 30},
			# The flood is through them and he is still going.
			"contact_pose": {"lean": -22, "head": -32, "arm_f": 126, "elb_f": 4, "arm_b": 156, "elb_b": 4,
				"leg_f": 34, "knee_f": 22, "leg_b": -30, "knee_b": 20},
			"events": {18: [["shake", {"amount": 4.0}]]},
		}),
		# Hyper B — UP + L + H. His flood spreads sideways along the floor. This
		# one goes straight up: a geyser of tears that erupts over his head, so it
		# catches jumpers and anyone hovering above him.
		"hyper2": MoveData.make({
			"id": "tear geyser", "display": "TEAR GEYSER!", "level": 3, "startup": 17,
			"active": 1, "recovery": 46, "invuln": 43, "prop": "tears", "sfx": "hyper",
			"flash": 5, "shake": 2.0,
			"projectile": {
				# Tall and narrow, against the flood's wide and low. The tears art
				# runs from the floor up to the top of `size.y`, so this is a column.
				"kind": "tears", "anchored": true, "size": Vector2(230, 300), "offset": Vector2(50, -150),
				"life": 60, "hits": 12, "interval": 4, "damage": 20, "hitstun": 16,
				"kb": Vector2(1.0, -5.0), "chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "sfx": "hyper",
			},
			# Head thrown right back, eyes shut, cheeks blown out: the inhale before
			# the geyser, with his whole body arched away from where it will come out.
			"cutin_pose": {"lean": -30, "head": -34, "arm_f": 168, "elb_f": 12, "arm_b": 150, "elb_b": 20,
				"leg_f": 30, "knee_f": 26, "leg_b": -24, "knee_b": 24},
			"keys": [
				# Reeling back, arms up and away from his face...
				[0, {"lean": -28, "head": -32, "arm_f": 164, "elb_f": 14, "arm_b": 146, "elb_b": 22,
					"leg_f": 28, "knee_f": 28, "leg_b": -22, "knee_b": 26}, 0.5],
				# ...then the wail, straight up, on his toes with both arms punched out.
				[16, {"lean": -6, "head": -30, "arm_f": 178, "elb_f": 4, "arm_b": 174, "elb_b": 4,
					"leg_f": 44, "knee_f": 10, "leg_b": -16, "knee_b": 14}, 0.95],
				[40, {"lean": -12, "head": -26, "arm_f": 172, "elb_f": 8, "arm_b": 168, "elb_b": 8,
					"leg_f": 38, "knee_f": 14, "leg_b": -20, "knee_b": 18}, 0.4],
				[56, {"lean": 4, "head": 0, "arm_f": 40, "elb_f": 100, "arm_b": 42, "elb_b": 100}, 0.35],
			],
			# The column is up and he is still pushing at the sky.
			"contact_pose": {"lean": -2, "head": -36, "arm_f": 184, "elb_f": 0, "arm_b": 180, "elb_b": 0,
				"leg_f": 50, "knee_f": 8, "leg_b": -14, "knee_b": 12},
			"events": {16: [["shake", {"amount": 5.0}]]},
		}),
	}
	size = 1.12  # the tall one
	scale_moves()


## Connected chain: an odd hit is the authored front limb, an even hit is the
## other one, so a light-light string reads as a one-two. Specials are left
## alone: his slam dunk and tantrum already pose both arms.
func adjust_attack_pose(f: Fighter, m: MoveData, p: Dictionary) -> Dictionary:
	if m.level > 1 or f.chain % 2 == 1:
		return p
	return cross_limbs(p)


## A true bald egg, nose to the right: a wide round cranium narrowing to a small
## low chin, with no jaw at all. The shared circle plus a chin blob passes for a
## dome but he does have a skull, and at head_scale 1.9 the difference is the
## whole silhouette. Wide at the top, widest just above the eyes.
func head_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-1.0, -13.4), Vector2(4.0, -12.6), Vector2(7.6, -9.6), Vector2(9.4, -5.2),
		Vector2(9.8, -0.6), Vector2(8.8, 3.8), Vector2(6.6, 6.8), Vector2(3.6, 8.8),
		Vector2(0.4, 9.4), Vector2(-3.0, 8.4), Vector2(-6.0, 6.0), Vector2(-8.4, 2.2),
		Vector2(-9.8, -2.4), Vector2(-9.4, -7.2), Vector2(-6.6, -11.6),
	])


## A tank top, so this is *narrower* than the shared wedge, with the shoulder
## cut in where the straps sit. He is a beanpole, and the wide shared torso was
## fighting the joke.
func torso_outline(_r: FighterRenderer, s: Dictionary) -> PackedVector2Array:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var b := build
	var pts := PackedVector2Array()
	for f in [[0.0, 4.6], [0.36, 5.0], [0.70, 6.2], [0.90, 6.6], [1.0, 4.6],
			[1.0, -5.0], [0.88, -6.4], [0.54, -5.2], [0.0, -4.2]]:
		pts.append(hip + up * FighterRenderer.TORSO * float(f[0]) + perp * float(f[1]) * b)
	return pts


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
	# Tank-top trim: round the neck, and round both armholes the way the
	# portrait has it. The old version trimmed the neck and put a stripe at the
	# hem and two ring "00"s, none of which the painting has.
	r.draw_line(top + perp * 3.4 - up * 1.4, top - perp * 3.4 - up * 1.4, trim, 2.0, true)
	# Shoulder straps, the giveaway that it is a vest and not a tee.
	for side in [4.6, -5.0]:
		r.draw_line(top + perp * side - up * 0.4, top + perp * (side * 0.55) - up * 5.0, trim, 1.6, true)
	# Gold side stripe down the jersey.
	r.draw_line(hip + perp * 3.6 + up * 2.0, top - perp * 3.0 - up * 1.0, trim, 1.5, true)
	# Hem trim.
	r.draw_line(hip + perp * 4.6 + up * 2.0, hip - perp * 4.2 + up * 2.0, trim, 1.6, true)


## The white ankle socks above his red sneakers, which did not exist at all
## before: he had no draw_over_legs override, so the portrait's socks were
## simply missing. A band of sock over the shin, then the sneaker below it.
func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	var sock: Color = r.colors["white"]
	for leg in [["knee_f", "foot_f", 1.0], ["knee_b", "foot_b", 0.84]]:
		var knee: Vector2 = s[leg[0]]
		var foot: Vector2 = s[leg[1]]
		var d: Vector2 = foot - knee
		if d.length() < 1.0:
			continue
		var depth: float = float(leg[2])
		var u := d.normalized()
		var n := Vector2(-u.y, u.x)
		# A short ankle sock, not a knee-high: the painting's white stops just
		# above the sneaker.
		var top: Vector2 = foot - u * 5.0
		r.limb(top, foot - u * 1.0, 6.4 * depth, 6.0 * depth, sock)
		r.draw_line(top - n * (3.2 * depth), top + n * (3.2 * depth), sock.darkened(0.18), 1.1, true)


## A red sneaker with a white sole and laces. The shared slipper is not a shoe
## the portrait would recognise.
func draw_shoe(r: FighterRenderer, foot: Vector2, fwd: Vector2, col: Color) -> void:
	if fwd.length_squared() < 0.001:
		fwd = Vector2.RIGHT
	fwd = fwd.normalized()
	var up := Vector2(fwd.y, -fwd.x)
	# Chunky upper, wider than the shared slipper.
	r.shaded_poly(PackedVector2Array([
		foot - fwd * 3.4 + up * 2.4, foot + fwd * 0.4 + up * 3.0, foot + fwd * 4.6 + up * 2.4,
		foot + fwd * 7.0 - up * 0.4, foot + fwd * 6.6 - up * 1.8, foot - fwd * 3.6 - up * 1.8,
	]), col, 1.1, 0.82)
	# White sole slab, which is what makes it a sneaker.
	r.draw_line(foot - fwd * 3.4 - up * 1.2, foot + fwd * 7.0 - up * 1.2, r.colors["white"], 1.8, true)
	r.draw_line(foot - fwd * 3.4 - up * 0.2, foot + fwd * 6.8 - up * 0.2, col.darkened(0.24), 0.8, true)
	# Laces.
	for li in 3:
		var lp := foot + fwd * (0.6 + float(li) * 1.5) + up * 1.6
		r.draw_line(lp - fwd * 0.4, lp + fwd * 0.4, r.colors["white"], 0.7, true)


func draw_hair_back(r: FighterRenderer) -> void:
	# Jug-handle ears, one bigger than the other, on the back edge of the new egg.
	# These sat on the shared circle at x -6.5 and -5.0, which on a head this wide
	# put the second one on the cheek in front of the eye; they moved out to -9.4
	# and -8.2 so both straddle the silhouette instead.
	for e: Array in [[Vector2(-9.4, 1.6), 4.0], [Vector2(-8.2, -0.4), 3.0]]:
		var c: Vector2 = e[0]
		var rr: float = e[1]
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-1.6, 0), rr + 0.9, rr * 1.3 + 0.9, 0.2, 14), FighterRenderer.OUT)
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-1.6, 0), rr, rr * 1.3, 0.2, 14), r.colors["skin"])
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(c + Vector2(-1.2, 0.3), rr * 0.5, rr * 0.8, 0.2, 10), warm_shade(r.colors["skin"], 0.18))


## Eye centres in head space, nose to the right, low on the big egg.
func eye_spots() -> Array:
	return [Vector2(3.8, 1.4), Vector2(8.4, 1.0)]


func draw_face(r: FighterRenderer) -> void:
	var skin: Color = r.colors["skin"]
	var ink := FighterRenderer.OUT
	# Eye bags first, so the eyes sit in them.
	for spot: Vector2 in eye_spots():
		r.draw_arc(spot + Vector2(0, 1.6), 2.4, 0.15, PI - 0.15, 8, warm_shade(skin, 0.16), 1.25, true)
	_eyes(r)
	# A big lumpy nose, drooping over the mouth, with the old shade() swapped for
	# the warm one — purple toward his sallow yellow read as olive.
	var nose := FighterRenderer.ellipse_pts(Vector2(9.4, 4.0), 2.5, 2.0, 0.3, 12)
	r.draw_colored_polygon(nose, warm_shade(skin, 0.2).lerp(Color(0.9, 0.45, 0.35), 0.3))
	r.draw_polyline(Stage._closed(nose), ink, 1.0, true)
	# The sniffle: a drip that swells and drops, over and over.
	var drip := fmod(r.t * 0.04, 1.0)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(8.8, 6.2 + drip * 2.0), 0.9, 1.0 + drip * 1.2), Color(0.7, 0.95, 0.6, 0.9))
	_tooth(r)
	# Pimples on the cheeks and brow, not scattered over the bald dome where the
	# old coordinates used to put them.
	for pp: Vector2 in [Vector2(1.0, 3.2), Vector2(-0.4, -1.6), Vector2(6.0, 3.0)]:
		r.draw_circle(pp, 0.8, Color(0.95, 0.4, 0.35), true, -1.0, true)
	# Cheek blush, which the portrait has and he did not.
	var blush := Color(0.95, 0.45, 0.4, 0.45)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(0.6, 4.4), 2.4, 1.5), blush)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(6.2, 4.0), 2.2, 1.4), blush)
	# He likes crying. When it goes badly, the taps open.
	if r.expr in ["hurt", "ko", "shock", "dizzy"] or r.prop == "tears":
		for spot: Vector2 in eye_spots():
			var k := fmod(r.t * 0.12 + spot.x, 1.0)
			r.draw_line(spot, spot + Vector2(-0.6, 6.0), Color(0.55, 0.8, 1.0, 0.85), 1.4, true)
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(spot + Vector2(-0.6, 3.0 + k * 5.0), 0.9, 1.3), Color(0.6, 0.85, 1.0))


## Two snaggletooth pointing up over the lower lip, the way the portrait has
## them. He had one before, which is a detail the painting never agreed to.
func _tooth(r: FighterRenderer) -> void:
	var ink := FighterRenderer.OUT
	var tooth: Color = r.colors["white"]
	if r.expr == "ko" or r.expr == "dizzy":
		return
	for tx: float in [5.6, 7.6]:
		r.draw_colored_polygon(PackedVector2Array([
			Vector2(tx, 6.8), Vector2(tx + 1.3, 6.8), Vector2(tx + 0.65, 8.7),
		]), tooth)
		r.draw_polyline(PackedVector2Array([Vector2(tx, 6.8), Vector2(tx + 0.65, 8.7), Vector2(tx + 1.3, 6.8)]), ink, 0.7, true)


## His eyes: small and green under the unibrow, but carrying the whole
## expression vocabulary through eye_style. Without that he would stand through a
## match with a permanent stare.
func _eyes(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(3.8, 1.4), Vector2(8.4, 1.0)]
	var ink := FighterRenderer.OUT
	var sclera: Color = r.colors["white"]
	var style := eye_style(r.expr, r.t)
	var pop := 1.0 + 0.6 * (float(r.eye_pop) / 9.0)
	var g := Vector2.ZERO if r.expr in ["ko", "dizzy", "hurt"] else r.gaze.limit_length(1.0)
	for i in 2:
		var e: Vector2 = spots[i]
		var near := 0.8 if i == 1 else 1.0
		if style == "happy":
			r.draw_arc(e + Vector2(0, 0.8), 2.0 * near, PI, TAU, 8, ink, 1.5, true)
			continue
		if style == "ko":
			var rad := 2.0 * near
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
			r.draw_line(e + Vector2(-2.4 * sc, 0.3), e + Vector2(2.3 * sc, 0.15), ink, 1.3, true)
			continue
		# Small, but big enough that the green iris survives the unibrow above it.
		var squint := 1.0
		var pupil := 0.32
		match r.expr:
			"attack":
				squint = 0.6
			"hurt":
				squint = 0.55
				pupil = 0.2
			"shock":
				squint = 1.15
				pupil = 0.18
			"smug":
				squint = 0.45 if i == 1 else 0.7
		var ry := maxf(0.9, 2.1 * sc * clampf(squint, 0.4, 1.15))
		var rx := 2.6 * sc
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, rx, ry, 0.0, 10), sclera)
		var ir := minf(rx * 0.5, ry * 0.95)
		var ic := e + g * rx * 0.16
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(ic, ir, ir * 0.9, 0.0, 8), r.colors["eyes"])
		r.draw_circle(ic + g * 0.1, maxf(0.4, ir * pupil * 1.3), ink)
		r.draw_circle(ic + Vector2(-ir * 0.34, -ir * 0.36), 0.28, Color.WHITE)
		r.draw_arc(e + Vector2(0, -ry * 0.15), rx * 0.94, PI + 0.35, TAU - 0.35, 8, ink, 0.9, true)


## The heavy black unibrow. The scowl is the whole character, so it stays
## through every expression, but it lifts and drops rather than sitting frozen.
func _brows(r: FighterRenderer) -> void:
	var a: Vector2 = eye_spots()[0]
	var b: Vector2 = eye_spots()[1]
	var lift := -6.0
	var tilt := 0.7
	match r.expr:
		"attack", "smug":
			tilt = 1.4
		"hurt", "shock":
			lift = -7.0
			tilt = -0.4
		"ko", "dizzy":
			lift = -7.2
			tilt = -0.6
		"win", "happy":
			lift = -5.4
			tilt = 0.0
	r.draw_polyline(PackedVector2Array([
		a + Vector2(-2.6, lift + tilt), a + Vector2(1.0, lift),
		(a + b) * 0.5 + Vector2(0, lift - 0.5),
		b + Vector2(-0.4, lift), b + Vector2(2.6, lift + tilt),
	]), FighterRenderer.OUT, 2.2, true)


## The mouth. A small scowl, a cry on the losing expressions, and a squiggle
## when dizzy so it is not frozen in one shape all match.
func _mouth(r: FighterRenderer) -> void:
	var m := Vector2(5.2, 4.4)
	var ink := Color(0.45, 0.16, 0.10)
	if r.expr == "dizzy":
		var w := PackedVector2Array()
		for wi in 5:
			w.append(m + Vector2(-2.0 + float(wi) * 1.0, 0.4 + (0.7 if wi % 2 == 0 else -0.7)))
		r.draw_polyline(w, ink, 1.1, true)
		return
	if r.expr == "hurt" or r.expr == "ko":
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(m + Vector2(0, 0.6), 1.4, 1.9, 0.0, 10), ink)
		return
	if r.expr == "happy" or r.expr == "win":
		r.draw_arc(m + Vector2(0.1, -0.4), 2.1, 0.2, PI - 0.2, 8, ink, 1.3, true)
		return
	if r.expr == "smug":
		r.draw_line(m + Vector2(-1.5, 0.3), m + Vector2(1.6, -0.5), ink, 1.1, true)
		return
	# Rest: the scowl, and it deepens when he is going for it.
	var drop := 1.2 if r.expr == "attack" else 0.0
	r.draw_line(m + Vector2(-2.2, -0.2), m + Vector2(0, 0.6 + drop), FighterRenderer.OUT, 1.4, true)
	r.draw_line(m + Vector2(0, 0.6 + drop), m + Vector2(2.2, -0.4), FighterRenderer.OUT, 1.4, true)


## His long noodle-arm fist, with knuckles.
func draw_hand(r: FighterRenderer, p: Vector2, col: Color, d: Vector2, _front: bool, open: bool) -> void:
	if open:
		r.open_hand(p, col, d)
	else:
		_fist(r, p, col, d)


func _fist(r: FighterRenderer, p: Vector2, col: Color, d: Vector2) -> void:
	if d.length_squared() < 0.001:
		d = Vector2.DOWN
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	var sh := FighterRenderer.shade(col)
	r.shaded_poly(PackedVector2Array([
		p - n * 2.4 - d * 0.8, p + n * 2.4 - d * 0.8, p + n * 2.2 + d * 1.5,
		p + n * 1.4 + d * 3.1, p - n * 1.4 + d * 3.1, p - n * 2.2 + d * 1.5,
	]), col, 1.0, 0.82)
	for k: float in [-1.4, -0.5, 0.5, 1.4]:
		r.draw_line(p + n * k + d * 1.5, p + n * k + d * 2.9, sh, 0.55, true)
	r.part(p + n * 1.9 - d * 0.2, p + n * 0.4 + d * 2.3, 1.4, 1.2, col)
	r.draw_line(p - n * 2.0 + d * 1.5, p + n * 2.0 + d * 1.5, FighterRenderer.hl(col), 0.5, true)


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
			for e: Vector2 in eye_spots():
				var src := FighterRenderer.head_point(s, e)
				for j in 6:
					var k := fmod(r.t * 0.08 + j / 6.0, 1.0)
					var p := src + Vector2(k * 46.0 * (1.0 if e.x > 6.0 else -0.6), -14.0 * sin(k * PI) + k * 30.0)
					r.draw_colored_polygon(FighterRenderer.ellipse_pts(p, 2.2 - k, 2.8 - k), Color(0.6, 0.85, 1.0, 1.0 - k * 0.6))
		"tears_win":
			# His celebration: he wins and immediately starts bawling, hands up,
			# tears streaming. He cried about basketball either way, so winning
			# does not surprise him in the slightest.
			for e: Vector2 in eye_spots():
				var src := FighterRenderer.head_point(s, e)
				for j in 7:
					var k := fmod(r.t * 0.10 + j / 7.0, 1.0)
					var p := src + Vector2(k * 30.0 * (1.0 if e.x > 6.0 else -0.7), -10.0 * sin(k * PI) + k * 44.0)
					r.draw_colored_polygon(FighterRenderer.ellipse_pts(p, 2.0 - k * 0.8, 2.6 - k), Color(0.6, 0.85, 1.0, 0.95 - k * 0.5))


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
