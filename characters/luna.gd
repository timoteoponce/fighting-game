class_name LunaDef
extends CharacterDef
## Luna: the arcade's secret boss. A big indoor cat who is lazy, strong and
## bored almost all of the time — until someone touches her food. She is
## `hidden = true`, so she never shows up on the select screen and this file is
## the only record that she exists at all.
##
## Her two supers mirror her two moods: SLEEPY ATTACK (BACK+L+H) is a beam of
## drifting "Z"s she barely bothers to aim, and ANGER FOR FOOD (UP+L+H) is a
## furious all-fours maul with a food can in one paw.


func _init() -> void:
	hidden = true
	roster_order = 900
	id = "luna"
	display = "LUNA"
	likes = "Naps, warm laps, snacks, being left alone"
	win_quote = "...Wake me when it's dinner."
	gag_items = ["ball", "tooth", "note"]
	taunt_lines = ["...meh.", "FEED ME!", "ZZZ"]
	hurt_lines = ["MRRROW!", "HSSS!", "MREOW!"]
	colors = {
		"skin": Color("c9cbe0"), "hair": Color("8b8fa8"), "shirt": Color("b6a0d8"),
		"sleeve": Color("b6a0d8"), "forearm": Color("c9cbe0"), "hands": Color("c9cbe0"),
		"pants": Color("3a3450"), "legs": Color("3a3450"), "shoes": Color("5a5478"),
		"eyes": Color("c9d83f"), "accent": Color("ffd27a"),
		"fur": Color("8b8fa8"), "fur_dark": Color("5a5478"), "nose": Color("e07a9a"),
		"inner": Color("e7a9c4"), "white": Color("e6e0d2"), "bell": Color("ffd24a"),
	}
	# Player 2 (or a mirror match) is the night-black cat: charcoal fur and a
	# teal collar bell.
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"skin": Color("9a8fb0"), "hair": Color("2a2436"), "shirt": Color("4a6b8a"),
		"sleeve": Color("4a6b8a"), "forearm": Color("9a8fb0"), "hands": Color("9a8fb0"),
		"pants": Color("241f30"), "legs": Color("241f30"), "shoes": Color("3a3450"),
		"eyes": Color("7fe0c4"), "accent": Color("7fd0ff"),
		"fur": Color("2a2436"), "fur_dark": Color("141020"), "nose": Color("e07a9a"),
		"inner": Color("b06a8a"), "white": Color("dcd6c6"), "bell": Color("7fd0ff"),
	}, true)
	# Lazy: the slowest walk on the roster, but a cat still lands on her feet —
	# a high, floaty jump. The weight is all in the damage.
	walk_speed = 2.9
	back_speed = 2.3
	jump_vel = -11.6
	jump_x = 3.8
	voice_pitch = 250.0  # a low, unimpressed yowl
	head_scale = 1.6
	build = 1.06
	size = 0.95
	# The boss is a boss: every hit she lands does about a third more than the
	# same hit from anyone else, and she has 40% more health, so she both hits
	# harder and takes longer to put down.
	damage_scale = 1.3
	health_scale = 1.4
	win_prop = "fish"
	intro_prop = "fish"
	specials_text = [
		["L + H", "Hairball"],
		["FWD + L + H", "Pounce"],
		["DOWN + L + H", "Yowl Uppercut"],
		["BACK + L + H", "SLEEPY ATTACK!"],
		["UP + L + H", "ANGER FOR FOOD!"],
	]
	poses = {
		"intro": {"arm_f": 150, "elb_f": 40, "arm_b": 140, "elb_b": 50, "head": 8, "lean": 8},
		"win": {"arm_f": 155, "elb_f": 20, "arm_b": 150, "elb_b": 30, "head": 14, "lean": 6},
	}
	moves = {
		# Light: three quick claws, all weight, no effort.
		"L": MoveData.make({
			"id": "claw swipe", "startup": 4, "active": 3, "recovery": 8, "damage": 40,
			"hitbox": Rect2(13, -92, 52, 24), "hitstun": 14, "blockstun": 9,
			"kb": Vector2(2, 0), "meter": 4.0, "hitstop": 5,
			"keys": [
				[0, {"arm_f": 40, "elb_f": 120, "lean": -2, "head": 4}, 0.55],
				[4, {"arm_f": 96, "elb_f": 4, "lean": 15, "head": -4}, 0.95],
				[8, {"arm_f": 60, "elb_f": 90, "lean": 4, "head": 4}, 0.4],
			],
		}),
		# Heavy: a lazy uppercut with the whole body behind it.
		"H": MoveData.make({
			"id": "yawn uppercut", "level": 1, "startup": 9, "active": 4, "recovery": 18, "damage": 100,
			"hitbox": Rect2(10, -150, 60, 88), "launch": true, "kb": Vector2(1.4, -10.8),
			"hitstun": 30, "blockstun": 16, "hitstop": 8, "meter": 8.0, "hit_sfx": "heavy",
			"keys": [
				[0, {"arm_f": 20, "elb_f": 60, "lean": 12}, 0.5],
				[9, {"arm_f": 172, "elb_f": 0, "lean": -14, "arm_b": -10}, 0.95],
				[18, {"arm_f": 60, "elb_f": 90, "lean": 4}, 0.4],
			],
		}),
		"cL": MoveData.make({
			"id": "floor paw", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 36,
			"hitbox": Rect2(13, -52, 50, 23), "hitstun": 14, "blockstun": 9, "meter": 4.0, "hitstop": 5,
			"pose_a": {"arm_f": 85, "elb_f": 0, "lean": 18, "head": -6},
		}),
		# Crouching heavy: a big lazy tail sweep.
		"cH": MoveData.make({
			"id": "tail sweep", "crouch": true, "level": 1, "startup": 9, "active": 5, "recovery": 21,
			"damage": 92, "hitbox": Rect2(8, -28, 88, 28), "knockdown": true, "kb": Vector2(2.4, -4),
			"hitstop": 7, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 90, "knee_f": 0, "lean": -20, "arm_b": -30},
		}),
		"jL": MoveData.make({
			"id": "air paw", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 42,
			"hitbox": Rect2(5, -84, 54, 39), "hitstun": 16, "blockstun": 9, "meter": 4.0, "hitstop": 5,
			"pose_a": {"arm_f": 118, "elb_f": 0, "head": 8, "lean": 10},
		}),
		"jH": MoveData.make({
			"id": "cat stomp", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 92, "hitbox": Rect2(3, -70, 66, 48), "spike": true, "hitstun": 18,
			"blockstun": 12, "kb": Vector2(3, 0), "hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": 20, "knee_b": 90, "lean": -10},
		}),
		# Hairball: the ordinary fireball, chucked with a flick of the wrist
		# because actually standing up would be too much work.
		"proj": MoveData.make({
			"id": "hairball", "display": "HAIRBALL", "level": 2, "startup": 12, "active": 1,
			"recovery": 20, "sfx": "whoosh", "flash": 2, "shake": 1.0,
			"projectile": {
				"kind": "spark", "speed": 7.2, "size": Vector2(24, 20), "offset": Vector2(40, -78),
				"life": 200, "damage": 74, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6,
				"meter": 8.0, "hit_sfx": "light",
				"tint": {"core": Color("fff3d8"), "mid": Color("8b8fa8"), "edge": Color("4a4460"),
					"halo": Color("c9cbe0")},
			},
			"keys": [
				[0, {"arm_f": 40, "elb_f": 120, "lean": -6, "head": 8}, 0.5],
				[12, {"arm_f": 95, "elb_f": 0, "lean": 14, "head": -8}, 0.95],
				[20, {"arm_f": 55, "elb_f": 80, "lean": 4}, 0.4],
			],
			"events": {12: [["voice", {"line": "special"}]]},
		}),
		# Pounce: down low and straight through you, all four paws at once.
		"rush": MoveData.make({
			"id": "pounce", "display": "POUNCE", "level": 2, "startup": 6, "active": 18,
			"recovery": 15, "damage": 62, "hits": 2, "hit_interval": 9,
			"hitbox": Rect2(-10, -114, 70, 108), "dash_speed": 8.0, "dash_from": 6, "dash_to": 24,
			"knockdown": true, "kb": Vector2(3, -5), "hitstun": 20, "blockstun": 12, "chip": 0.15,
			"hitstop": 6, "meter": 8.0, "hit_sfx": "heavy", "flash": 3, "shake": 1.6,
			"keys": [
				[0, {"lean": -18, "leg_f": 45, "knee_f": 90, "arm_f": 30, "elb_f": 120}, 0.5],
				[6, {"lean": 44, "hip": -30, "arm_f": 120, "elb_f": 20, "arm_b": 30, "elb_b": 20,
					"leg_f": 80, "knee_f": 40, "leg_b": -50, "knee_b": 70, "head": -22}, 0.95],
				[24, {"lean": 20, "hip": 0, "arm_f": 60, "elb_f": 80, "head": -6}, 0.45],
			],
			"events": {6: [["dust", {"offset": Vector2(-8, 0)}], ["voice", {"line": "special"}]]},
		}),
		# Yowl Uppercut: claws up. The one move she puts real effort into.
		"anti": MoveData.make({
			"id": "yowl uppercut", "display": "YOWL UPPERCUT", "level": 2, "startup": 3, "active": 14,
			"recovery": 18, "damage": 50, "hits": 3, "hit_interval": 5,
			"hitbox": Rect2(-6, -152, 80, 124), "rise_vel": Vector2(0.8, -11.2), "rise_frame": 3,
			"invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0), "hitstun": 30, "blockstun": 12,
			"chip": 0.15, "hitstop": 5, "meter": 8.0, "hit_sfx": "light", "flash": 3, "shake": 1.6,
			"keys": [
				[0, {"leg_f": 55, "knee_f": 100, "lean": 8}, 0.5],
				[3, {"arm_f": 175, "elb_f": 0, "arm_b": -20, "lean": -12, "leg_b": -30,
					"head": 14}, 0.95],
				[12, {"arm_f": 150, "elb_f": 20, "lean": -4, "head": 6}, 0.5],
			],
			"events": {3: [["voice", {"line": "special"}]]},
		}),
		# Hyper A — SLEEPY ATTACK. She yawns so hard it comes out as a drifting
		# wall of Z's. Anchored in front of her, so a bored cat does not have to
		# chase anyone to connect with it.
		"hyper": MoveData.make({
			"id": "sleepy attack", "display": "SLEEPY ATTACK!", "level": 3, "startup": 18,
			"active": 1, "recovery": 46, "invuln": 44, "sfx": "magic",
			"projectile": {
				"kind": "beam", "anchored": true, "size": Vector2(220, 150), "offset": Vector2(60, -84),
				"life": 70, "hits": 10, "interval": 5, "damage": 24, "hitstun": 17,
				"kb": Vector2(4, 0), "chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "shake": 0.8, "sfx": "hyper",
				"text": "Z Z Z",
				"tint": {"core": Color("fffdf2"), "mid": Color("c9b6f0"), "edge": Color("5a5478"),
					"halo": Color("e3d9ff"), "label": Color("ffffff"), "label_ink": Color("3a2a50")},
			},
			"cutin_pose": {"head": 24, "lean": 12, "arm_f": 30, "elb_f": 110, "arm_b": 30, "elb_b": 110,
				"leg_f": 10, "knee_f": 10, "leg_b": -18, "knee_b": 16},
			"keys": [
				[0, {"head": 20, "lean": 10, "arm_f": 25, "elb_f": 120, "arm_b": 25, "elb_b": 120}, 0.5],
				[18, {"head": -14, "lean": 16, "arm_f": 60, "elb_f": 40, "arm_b": 60, "elb_b": 40}, 0.95],
				[44, {"head": 10, "lean": 6, "arm_f": 40, "elb_f": 90, "arm_b": 40, "elb_b": 90}, 0.4],
			],
			"contact_pose": {"head": -20, "lean": 20, "arm_f": 70, "elb_f": 30, "arm_b": 70, "elb_b": 30},
			"events": {
				18: [["voice", {"line": "hyper"}], ["shake", {"amount": 5.0}]],
				30: [["shake", {"amount": 3.0}]],
			},
		}),
		# Hyper B — ANGER FOR FOOD. Someone touched the can. She drops to all
		# fours and mauls, can still in one paw.
		"hyper2": MoveData.make({
			"id": "anger for food", "display": "ANGER FOR FOOD!", "level": 3, "startup": 12,
			"active": 26, "recovery": 42, "invuln": 43, "prop": "can", "sfx": "heavy",
			"hits": 8, "hit_interval": 4, "damage": 22, "hitstun": 16,
			"hitbox": Rect2(-24, -108, 138, 88), "kb": Vector2(2.0, -1.2), "chip": 0.18,
			"hitstop": 4, "meter": 0.0, "shake": 1.8, "hit_sfx": "light",
			"dash_speed": 8.8, "dash_from": 4, "dash_to": 20,
			"strength": 99,
			"cutin_pose": {"head": -28, "lean": 32, "arm_f": 130, "elb_f": 50, "arm_b": 150, "elb_b": 40,
				"leg_f": 120, "knee_f": 40, "leg_b": -40, "knee_b": 90},
			"keys": [
				[0, {"head": -8, "lean": 24, "arm_f": 55, "elb_f": 110, "arm_b": 65, "elb_b": 120,
					"leg_f": 60, "knee_f": 100, "leg_b": 30, "knee_b": 100}, 0.5],
				[10, {"head": -26, "lean": 40, "arm_f": 158, "elb_f": 16, "arm_b": 178, "elb_b": 10,
					"leg_f": 132, "knee_f": 18, "leg_b": -52, "knee_b": 102}, 0.95],
				[26, {"head": -18, "lean": 22, "arm_f": 115, "elb_f": 46, "arm_b": 135, "elb_b": 38,
					"leg_f": 98, "knee_f": 38, "leg_b": -34, "knee_b": 72}, 0.5],
				[40, {"head": -4, "lean": 8, "arm_f": 50, "elb_f": 90, "arm_b": 60, "elb_b": 90,
					"leg_f": 42, "knee_f": 38, "leg_b": 20, "knee_b": 38}, 0.35],
			],
			"contact_pose": {"head": -32, "lean": 44, "arm_f": 172, "elb_f": 8, "arm_b": 184, "elb_b": 4,
				"leg_f": 142, "knee_f": 10, "leg_b": -58, "knee_b": 106},
			"events": {
				12: [["voice", {"line": "hyper"}], ["dust", {"offset": Vector2(-10, 0)}]],
				18: [["dust", {"offset": Vector2(-10, 0)}], ["slash", {"r": 62.0}]],
				24: [["dust", {"offset": Vector2(-10, 0)}], ["slash", {"r": 56.0}]],
				30: [["slash", {"r": 60.0}]],
			},
		}),
		# MAX of SLEEPY ATTACK — a full-on coma. Bigger wall of Z's.
		"hyper_max": MoveData.make({
			"id": "deep sleep", "display": "DEEP SLEEP!", "level": 3, "startup": 20,
			"active": 1, "recovery": 52, "invuln": 47, "sfx": "magic",
			"meter_cost": 300,
			"projectile": {
				"kind": "beam", "anchored": true, "size": Vector2(300, 200), "offset": Vector2(60, -96),
				"life": 84, "hits": 16, "interval": 5, "damage": 28, "hitstun": 18,
				"kb": Vector2(4.4, -1.0), "chip": 0.2, "hitstop": 4, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "hyper",
				"text": "Z Z Z Z",
				"tint": {"core": Color("ffffff"), "mid": Color("d9c8ff"), "edge": Color("6a6090"),
					"halo": Color("f0e8ff"), "label": Color("ffffff"), "label_ink": Color("2a1a40")},
			},
			"cutin_pose": {"head": 30, "lean": 8, "arm_f": 24, "elb_f": 116, "arm_b": 24, "elb_b": 116,
				"leg_f": 8, "knee_f": 8, "leg_b": -14, "knee_b": 12},
			"keys": [
				[0, {"head": 26, "lean": 6, "arm_f": 20, "elb_f": 124, "arm_b": 20, "elb_b": 124}, 0.5],
				[20, {"head": -18, "lean": 20, "arm_f": 70, "elb_f": 30, "arm_b": 70, "elb_b": 30}, 0.95],
				[50, {"head": 12, "lean": 6, "arm_f": 44, "elb_f": 88, "arm_b": 44, "elb_b": 88}, 0.4],
			],
			"contact_pose": {"head": -24, "lean": 24, "arm_f": 80, "elb_f": 24, "arm_b": 80, "elb_b": 24},
			"events": {
				20: [["voice", {"line": "hyper"}], ["shake", {"amount": 6.0}]],
				32: [["shake", {"amount": 3.0}]],
			},
		}),
		# MAX of ANGER FOR FOOD — she crosses the stage twice and still gets a
		# bite in on the way back.
		"hyper2_max": MoveData.make({
			"id": "second dinner", "display": "SECOND DINNER!", "level": 3, "startup": 13,
			"active": 32, "recovery": 46, "invuln": 45, "prop": "can",
			"meter_cost": 300, "sfx": "heavy",
			"hits": 12, "hit_interval": 4, "damage": 25, "hitstun": 16,
			"hitbox": Rect2(-28, -112, 150, 94), "kb": Vector2(2.2, -1.4), "chip": 0.18,
			"hitstop": 4, "meter": 0.0, "shake": 2.2, "hit_sfx": "light",
			"dash_speed": 9.4, "dash_from": 4, "dash_to": 24,
			"knockdown": true, "strength": 99,
			"cutin_pose": {"head": -36, "lean": 36, "arm_f": 140, "elb_f": 44, "arm_b": 160, "elb_b": 36,
				"leg_f": 136, "knee_f": 30, "leg_b": -50, "knee_b": 100},
			"keys": [
				[0, {"head": -10, "lean": 30, "arm_f": 50, "elb_f": 120, "arm_b": 60, "elb_b": 130,
					"leg_f": 70, "knee_f": 104, "leg_b": 36, "knee_b": 104}, 0.5],
				[11, {"head": -32, "lean": 46, "arm_f": 168, "elb_f": 12, "arm_b": 188, "elb_b": 4,
					"leg_f": 146, "knee_f": 14, "leg_b": -60, "knee_b": 106}, 0.95],
				[34, {"head": -20, "lean": 24, "arm_f": 120, "elb_f": 44, "arm_b": 140, "elb_b": 34,
					"leg_f": 104, "knee_f": 36, "leg_b": -38, "knee_b": 74}, 0.5],
				[52, {"head": -4, "lean": 8, "arm_f": 50, "elb_f": 90, "arm_b": 60, "elb_b": 90,
					"leg_f": 44, "knee_f": 38, "leg_b": 22, "knee_b": 38}, 0.35],
			],
			"contact_pose": {"head": -40, "lean": 50, "arm_f": 184, "elb_f": 4, "arm_b": 190, "elb_b": 0,
				"leg_f": 152, "knee_f": 8, "leg_b": -64, "knee_b": 110},
			"events": {
				13: [["voice", {"line": "hyper"}], ["dust", {"offset": Vector2(-10, 0)}]],
				18: [["dust", {"offset": Vector2(-10, 0)}], ["slash", {"r": 70.0}]],
				24: [["dust", {"offset": Vector2(-10, 0)}], ["slash", {"r": 62.0}]],
				30: [["dust", {"offset": Vector2(-10, 0)}], ["slash", {"r": 66.0}]],
				38: [["slash", {"r": 58.0}]],
			},
		}),
	}
	scale_moves()


## Connected chain, same one-two as everyone else. Specials are left alone:
## her pounce and maul already pose all four limbs.
func adjust_attack_pose(f: Fighter, m: MoveData, p: Dictionary) -> Dictionary:
	if m.level > 1 or f.chain % 2 == 1:
		return p
	return cross_limbs(p)


# --- The look -------------------------------------------------------------------
# The shared body does the work: a circle head, a wedge torso, mitten hands and
# a slipper. What is drawn here is what makes her a cat — the long tail on its
# chain, two pointed ears that swivel, a pink nose with whiskers, the white
# muzzle and chest, and the food can in her paw.

func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	# A long tail that trails low behind her, and two tall ears off the head.
	r.chain("tail", s["hip"] - perp * 6.0 + up * 3.0, 7, 4.4, -0.16, 0.87, 0.26)
	r.chain("ear_f", FighterRenderer.head_point(s, Vector2(6.5, -9.0)), 4, 5.2, 0.16, 0.8, 0.28)
	r.chain("ear_b", FighterRenderer.head_point(s, Vector2(-7.5, -8.5)), 4, 5.2, 0.18, 0.8, 0.24)


func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
	var fur: Color = r.colors["fur"]
	var tail := r.chain_local("tail")
	if tail.size() > 1:
		r.ribbon(tail, 6.5, 2.6, fur)
		r.ball(tail[tail.size() - 1], 3.0, r.colors["white"])
	var ear := r.chain_local("ear_b")
	if ear.size() > 1:
		r.ribbon(ear, 8.0, 4.0, r.colors["fur_dark"])


## A pale chest and tummy patch, so the body reads soft and catlike.
func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var chest: Vector2 = s["hip"] + up * 11.0 + perp * 1.0
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(chest, 6.8, 7.6), r.colors["white"])


func draw_hair_back(r: FighterRenderer) -> void:
	# A soft fur crown, slightly ruffled.
	r.shaded_poly(PackedVector2Array([
		Vector2(-12, 3), Vector2(-13, -6), Vector2(-6, -14), Vector2(4, -15),
		Vector2(12, -9), Vector2(12, 1),
	]), r.colors["hair"], 1.8, 0.8)


func draw_hair_front(r: FighterRenderer) -> void:
	# A little fur fringe between the ears.
	r.shaded_poly(PackedVector2Array([
		Vector2(-9, -6), Vector2(-4, -13), Vector2(1, -8), Vector2(6, -13),
		Vector2(10, -6), Vector2(7, -2), Vector2(2, -5), Vector2(-3, -1), Vector2(-7, -4),
	]), r.colors["hair"], 1.8, 0.85)


func draw_face(r: FighterRenderer) -> void:
	# Keep the shared face (and its whole expression vocabulary) and put the
	# cat on top: a white muzzle, a pink nose, whiskers, and the front ear.
	r.face(r.colors["eyes"])
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(7.0, 3.6), 5.0, 3.4), r.colors["white"])
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(8.6, 3.0), 2.0, 1.5), r.colors["nose"])
	for wy in [-1.4, 1.0]:
		for side in [-1.0, 1.0]:
			r.draw_line(Vector2(8.6, 3.6 + wy), Vector2(8.6 + side * 7.0, 3.2 + wy * 1.6),
				Color(0.05, 0.04, 0.09, 0.75), 0.8, true)
	var ear := r.chain_local("ear_f")
	if ear.size() > 1:
		# `draw_face` runs inside the head transform, so a node-space chain has
		# to come back through `head_local` or the offset lands twice.
		var pts := r.head_local(ear)
		r.ribbon(pts, 8.0, 3.0, r.colors["fur"])
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(pts[1], 2.4, 3.2), r.colors["inner"])


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	match r.prop:
		"fish":
			# A little silver fish, held up in the front hand.
			var c: Vector2 = s["hand_f"] + Vector2(0, -3)
			var fish := Color("bcd4e8")
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(c, 9.0, 4.6), fish)
			r.draw_colored_polygon(PackedVector2Array([
				c + Vector2(8, 0), c + Vector2(14, -5), c + Vector2(14, 5),
			]), fish.darkened(0.15))
			r.draw_circle(c + Vector2(-3, -1.5), 1.0, FighterRenderer.OUT, true, -1.0, true)
		"can":
			# The food can. She is not letting go of it.
			var c: Vector2 = s["hand_f"] + Vector2(2, -2)
			var tin := Color("c8ccd8")
			r.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-5, -7), c + Vector2(5, -7), c + Vector2(5, 7), c + Vector2(-5, 7),
			]), tin)
			r.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-5, -7), c + Vector2(5, -7), c + Vector2(4, -10), c + Vector2(-4, -10),
			]), tin.darkened(0.2))
			r.draw_line(c + Vector2(-5, 0), c + Vector2(5, 0), Color("e8b25a"), 2.4, true)
