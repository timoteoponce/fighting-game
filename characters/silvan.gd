class_name SilvanDef
extends CharacterDef
## Silvan: two years old, in pants and little boots, and somehow part puppy. He
## can't reach far and he can't hit hard, but nobody on the roster runs or jumps
## like he does. The archetype gap: a tiny, relentless pest.


func _init() -> void:
	id = "silvan"
	display = "SILVAN"
	likes = "Jumping, running, puppies, snack time"
	win_quote = "Woof! Again! Again!"
	gag_items = ["pacifier", "bone", "star"]
	taunt_lines = ["WOOF WOOF!", "BORK!", "CHASE ME!"]
	hurt_lines = ["YIPE!", "AWOOO?", "WAAAH!"]
	roster_order = 3
	colors = {
		"skin": Color("ffd9b8"), "hair": Color("8a5a32"), "shirt": Color("ffe27a"),
		"sleeve": Color("ffe27a"), "forearm": Color("ffd9b8"), "hands": Color("ffd9b8"),
		"pants": Color("3a78c4"), "legs": Color("3a78c4"), "shoes": Color("6e4630"),
		"eyes": Color("5b7f3a"), "accent": Color("6fc4ff"),
		"fur": Color("a8703f"), "nose": Color("3a2a22"), "tongue": Color("ff7f9e"),
		"white": Color("e6e0d2"),
	}
	# Player 2 is the "were-puppy" palette: darker fur, green shirt.
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("b6e36f"), "sleeve": Color("b6e36f"), "hair": Color("3a2a22"),
		"fur": Color("54402f"), "accent": Color("ff8ac4"), "eyes": Color("c8a13a"),
		"pants": Color("2a4e86"), "legs": Color("2a4e86"), "shoes": Color("3a2a22"),
		"white": Color("dcd6c6"),
	}, true)
	# Fastest walk and highest jump on the roster; everything else is a trade
	# against that. He is meant to be hard to pin down, not hard to survive.
	walk_speed = 4.1
	back_speed = 3.4
	jump_vel = -12.4
	jump_x = 4.5
	voice_pitch = 430.0  # a two-year-old's shriek
	win_prop = "bone"
	intro_prop = "bone"
	specials_text = [
		["L + H", "Bark Blast"],
		["FWD + L + H", "Puppy Dash"],
		["DOWN + L + H", "Bouncy Bounce"],
		["BACK + L + H", "MOON HOWL"],
		["UP + L + H", "FULL MOON!"],
	]
	poses = {
		"intro": {"arm_f": 140, "elb_f": 60, "arm_b": 140, "elb_b": 60, "head": 12, "lean": -4},
		"win": {"arm_f": 160, "elb_f": 30, "arm_b": 160, "elb_b": 30, "head": 18, "leg_f": 70, "knee_f": 60, "lean": -6},
	}
	moves = {
		# Three-frame light: the fastest button in the game, and the weakest.
		"L": MoveData.make({
			"id": "paw swipe", "startup": 3, "active": 3, "recovery": 7, "damage": 33,
			"hitbox": Rect2(12, -90, 52, 24), "hitstun": 13, "blockstun": 8,
			"kb": Vector2(1.6, 0), "meter": 4.5, "hitstop": 4,
			"keys": [
				[0, {"arm_f": 40, "elb_f": 120, "lean": -4, "head": 6}, 0.55],
				[3, {"arm_f": 95, "elb_f": 5, "lean": 16, "head": -4}, 0.95],
				[7, {"arm_f": 60, "elb_f": 90, "lean": 4, "head": 4}, 0.4],
			],
		}),
		# The launcher is a hop-and-tail-whip, so it looks like play-fighting.
		"H": MoveData.make({
			"id": "tail whip", "level": 1, "startup": 8, "active": 4, "recovery": 17, "damage": 82,
			"hitbox": Rect2(6, -140, 60, 86), "launch": true, "kb": Vector2(1.3, -10.6),
			"hitstun": 30, "blockstun": 15, "hitstop": 7, "meter": 9.0, "hit_sfx": "heavy",
			"keys": [
				[0, {"lean": -18, "leg_f": 30, "knee_f": 70, "arm_f": 10, "elb_f": 90}, 0.45],
				[8, {"lean": 10, "rot": -180, "arm_f": 150, "arm_b": 150, "leg_f": 40, "leg_b": -40, "ground": 0, "hip": -34}, 0.9],
				[14, {"lean": 0, "rot": -360, "arm_f": 90, "arm_b": 90, "hip": -10}, 0.6],
				[20, {"lean": 4, "arm_f": 50, "elb_f": 90}, 0.35],
			],
			"contact_pose": {"lean": 14, "rot": -200, "head": -10},
			"events": {8: [["slash", {}], ["voice", {"line": "heavy"}]]},
		}),
		"cL": MoveData.make({
			"id": "crawl nip", "crouch": true, "startup": 3, "active": 3, "recovery": 7, "damage": 29,
			"hitbox": Rect2(12, -46, 50, 22), "hitstun": 13, "blockstun": 8, "meter": 4.5, "hitstop": 4,
			"pose_a": {"arm_f": 80, "elb_f": 0, "lean": 18, "head": -6},
		}),
		# The roly-poly: he tucks into a ball and rolls through your ankles.
		"cH": MoveData.make({
			"id": "roly poly", "crouch": true, "level": 1, "startup": 7, "active": 5, "recovery": 19,
			"damage": 72, "hitbox": Rect2(6, -30, 78, 30), "knockdown": true, "kb": Vector2(2.2, -4),
			"hitstop": 7, "meter": 7.5, "hit_sfx": "heavy",
			"keys": [
				[0, {"lean": 20, "leg_f": 50, "knee_f": 100, "leg_b": 20, "knee_b": 100, "arm_f": 30, "elb_f": 130}, 0.5],
				[7, {"rot": -160, "leg_f": 80, "knee_f": 120, "leg_b": 60, "knee_b": 120, "arm_f": 40, "elb_f": 140,
					"arm_b": 40, "elb_b": 140, "ground": 0, "hip": -16}, 0.9],
				[14, {"rot": -330, "hip": -14}, 0.8],
			],
			"events": {7: [["dust", {"offset": Vector2(20, 0)}]]},
		}),
		"jL": MoveData.make({
			"id": "air nibble", "air": true, "startup": 3, "active": 5, "recovery": 6, "damage": 35,
			"hitbox": Rect2(4, -80, 52, 38), "hitstun": 16, "blockstun": 8, "meter": 4.5, "hitstop": 4,
			"pose_a": {"arm_f": 110, "elb_f": 10, "head": 8, "lean": 10},
		}),
		# Belly flop: the classic toddler dive-bomb.
		"jH": MoveData.make({
			"id": "belly flop", "air": true, "level": 1, "startup": 6, "active": 6, "recovery": 10,
			"damage": 78, "hitbox": Rect2(-10, -62, 72, 46), "spike": true, "hitstun": 18,
			"blockstun": 11, "kb": Vector2(2.8, 0), "hitstop": 8, "meter": 7.5, "hit_sfx": "heavy",
			"keys": [
				[0, {"lean": -10, "arm_f": 140, "arm_b": 140, "leg_f": 20, "knee_f": 60}, 0.5],
				[6, {"lean": 70, "arm_f": 170, "elb_f": 0, "arm_b": 170, "elb_b": 0, "leg_f": -20, "leg_b": -30}, 0.95],
			],
		}),
		# Bark Blast: a visible yelp. Fast and cheap, but it barely travels and
		# does the least damage of any fireball on the roster.
		"proj": MoveData.make({
			"id": "bark blast", "display": "BARK BLAST", "level": 2, "startup": 10, "active": 1,
			"recovery": 18, "sfx": "whoosh", "flash": 3, "shake": 1.0,
			"projectile": {
				"kind": "spark", "speed": 7.8, "size": Vector2(20, 20), "offset": Vector2(36, -62),
				"life": 80, "damage": 60, "hitstun": 18, "kb": Vector2(2.6, 0), "hitstop": 5,
				"meter": 8.5, "sfx": "light", "hit_sfx": "light",
			},
			"keys": [
				[0, {"head": -14, "lean": -12, "arm_f": 20, "elb_f": 120, "arm_b": 20, "elb_b": 120}, 0.5],
				[10, {"head": 16, "lean": 18, "arm_f": 60, "elb_f": 60, "arm_b": 60, "elb_b": 60}, 1.0],
				[18, {"head": 4, "lean": 4}, 0.35],
			],
			"events": {10: [["voice", {"line": "special"}], ["shake", {"amount": 1.5}]]},
		}),
		# Puppy Dash: down on all fours and straight through you.
		"rush": MoveData.make({
			"id": "puppy dash", "display": "PUPPY DASH", "level": 2, "startup": 5, "active": 20,
			"recovery": 13, "damage": 46, "hits": 3, "hit_interval": 7,
			"hitbox": Rect2(-8, -76, 62, 66), "dash_speed": 8.6, "dash_from": 5, "dash_to": 26,
			"knockdown": true, "kb": Vector2(3.2, -5), "hitstun": 20, "blockstun": 12, "chip": 0.15,
			"hitstop": 5, "meter": 8.5, "hit_sfx": "light",
			"flash": 4, "shake": 2.0,
			"keys": [
				[0, {"lean": -20, "leg_f": 40, "knee_f": 80, "arm_f": 30, "elb_f": 120}, 0.5],
				[5, {"lean": 62, "hip": -22, "arm_f": 120, "elb_f": 30, "arm_b": 20, "elb_b": 30,
					"leg_f": 70, "knee_f": 60, "leg_b": -50, "knee_b": 60, "head": -30}, 0.9],
				[13, {"lean": 62, "hip": -22, "arm_f": 20, "elb_f": 30, "arm_b": 120, "elb_b": 30,
					"leg_f": -50, "knee_f": 60, "leg_b": 70, "knee_b": 60, "head": -30}, 0.85],
				[20, {"lean": 62, "hip": -22, "arm_f": 120, "elb_f": 30, "arm_b": 20, "elb_b": 30,
					"leg_f": 70, "knee_f": 60, "leg_b": -50, "knee_b": 60, "head": -30}, 0.85],
				[26, {"lean": 20, "hip": 0, "head": 0}, 0.4],
			],
			"events": {
				5: [["dust", {"offset": Vector2(-6, 0)}], ["voice", {"line": "special"}]],
				13: [["dust", {"offset": Vector2(-6, 0)}]],
				20: [["dust", {"offset": Vector2(-6, 0)}]],
			},
		}),
		# Bouncy Bounce: a springy headbutt. Weakest anti-air on the roster, but
		# it goes the highest and recovers fast enough to do again.
		"anti": MoveData.make({
			"id": "bouncy bounce", "display": "BOUNCY BOUNCE", "level": 2, "startup": 3, "active": 14,
			"recovery": 15, "damage": 43, "hits": 3, "hit_interval": 5,
			"hitbox": Rect2(-10, -152, 74, 118), "rise_vel": Vector2(1.2, -11.8), "rise_frame": 3,
			"invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0), "hitstun": 30, "blockstun": 12,
			"chip": 0.15, "hitstop": 5, "meter": 8.5, "hit_sfx": "light",
			"flash": 3, "shake": 1.5,
			"keys": [
				[0, {"leg_f": 50, "knee_f": 110, "leg_b": 30, "knee_b": 110, "lean": 14, "head": -10}, 0.5],
				[3, {"arm_f": 170, "elb_f": 0, "arm_b": 175, "elb_b": 0, "lean": -14, "head": 16,
					"leg_f": 30, "knee_f": 30, "leg_b": -30, "knee_b": 30, "ground": 0, "hip": -40}, 0.95],
				[12, {"arm_f": 150, "elb_f": 20, "arm_b": 155, "elb_b": 20, "lean": -4, "head": 8, "hip": -40}, 0.6],
			],
			"events": {3: [["voice", {"line": "special"}], ["dust", {}]]},
		}),
		# Moon Howl: he finally goes full were-puppy and howls the screen down.
		"hyper": MoveData.make({
			"id": "moon howl", "display": "MOON HOWL!", "level": 3, "startup": 18, "active": 1,
			"recovery": 46, "invuln": 44, "prop": "moon", "sfx": "hyper",
			"projectile": {
				"kind": "wolf", "anchored": true, "size": Vector2(520, 96), "offset": Vector2(40, -66),
				"life": 58, "hits": 13, "interval": 4, "damage": 18, "hitstun": 16, "kb": Vector2(1.1, -0.6),
				"chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3, "final_knockdown": true,
				"strength": 99, "shake": 0.8, "sfx": "hyper",
				# The pack's own colour: cold blue-white, so the wolf reads as
				# a spirit and not as one of the beams.
				"tint": {"core": Color("f4faff"), "mid": Color("8fc4ff"), "edge": Color("2e4f96"),
					"halo": Color("a8d4ff")},
			},
			"keys": [
				[0, {"head": 10, "lean": 16, "arm_f": 30, "elb_f": 120, "arm_b": 30, "elb_b": 120, "leg_f": 20, "knee_f": 60}, 0.5],
				[12, {"head": -8, "lean": -6, "arm_f": 60, "elb_f": 80, "arm_b": 60, "elb_b": 80}, 0.7],
				[18, {"head": -26, "lean": -24, "arm_f": 165, "elb_f": 10, "arm_b": 170, "elb_b": 10,
					"leg_f": 25, "knee_f": 20}, 0.95],
				[40, {"head": -22, "lean": -18, "arm_f": 150, "elb_f": 30, "arm_b": 155, "elb_b": 30}, 0.5],
				[55, {"head": 0, "lean": 4, "arm_f": 40, "elb_f": 100, "arm_b": 40, "elb_b": 100}, 0.3],
			],
			# Through the cut-in he is already up on his back legs, head thrown
			# back, front paws up in the air — a two-year-old about to lose it.
			"cutin_pose": {"head": -30, "lean": -26, "arm_f": 172, "elb_f": 6, "arm_b": 176, "elb_b": 6,
				"leg_f": 30, "knee_f": 16, "leg_b": -14, "knee_b": 18},
			# The wolves are on them and he is leaning into the howl.
			"contact_pose": {"head": -36, "lean": -32, "arm_f": 180, "elb_f": 0, "arm_b": 182, "elb_b": 0,
				"leg_f": 38, "knee_f": 12, "leg_b": -20, "knee_b": 14},
			"events": {
				18: [["voice", {"line": "hyper"}], ["shake", {"amount": 5.0}]],
				24: [["shake", {"amount": 3.0}]],
				32: [["shake", {"amount": 2.0}]],
			},
		}),
		# Hyper B — UP + L + H. His first super sends the wolves running along the
		# ground. This one calls up the moon itself: a pillar of light that drops
		# onto him from above, so it catches anyone above and cannot be dodged by
		# stepping back.
		"hyper2": MoveData.make({
			"id": "full moon", "display": "FULL MOON!", "level": 3, "startup": 16,
			"active": 1, "recovery": 44, "invuln": 43, "prop": "moon", "sfx": "hyper",
			"projectile": {
				# A tall narrow column instead of the howl's long low charge.
				"kind": "beam", "anchored": true, "size": Vector2(190, 320), "offset": Vector2(50, -160),
				"life": 60, "hits": 11, "interval": 4, "damage": 20, "hitstun": 16,
				"kb": Vector2(1.2, -3.0), "chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "shake": 0.8, "sfx": "hyper",
				# Moonlight, not a laser: a pale yellow column with a warm halo.
				"tint": {"core": Color("fffdf2"), "mid": Color("ffe9a8"), "edge": Color("8f7423"),
					"halo": Color("fff3c4")},
			},
			# Arms up, chin up, back leg stretched out behind him, reaching for it.
			"cutin_pose": {"head": -34, "lean": -18, "arm_f": 180, "elb_f": 0, "arm_b": 176, "elb_b": 4,
				"leg_f": 18, "knee_f": 8, "leg_b": -34, "knee_b": 40},
			"keys": [
				# Reaches for the sky, up on his toes, one leg trailing.
				[0, {"head": -32, "lean": -16, "arm_f": 178, "elb_f": 2, "arm_b": 174, "elb_b": 6,
					"leg_f": 16, "knee_f": 10, "leg_b": -32, "knee_b": 38}, 0.5],
				# Splayed out under it, front leg planted, whole body lifted.
				[15, {"head": -38, "lean": -6, "arm_f": 100, "elb_f": 20, "arm_b": 96, "elb_b": 24,
					"leg_f": 62, "knee_f": 12, "leg_b": -46, "knee_b": 56}, 0.95],
				[40, {"head": -34, "lean": -10, "arm_f": 108, "elb_f": 14, "arm_b": 104, "elb_b": 18,
					"leg_f": 52, "knee_f": 16, "leg_b": -40, "knee_b": 48}, 0.4],
				[54, {"head": -2, "lean": 6, "arm_f": 40, "elb_f": 100, "arm_b": 42, "elb_b": 100}, 0.35],
			],
			# The light lands on him and he holds it open over his head.
			"contact_pose": {"head": -42, "lean": -2, "arm_f": 112, "elb_f": 8, "arm_b": 108, "elb_b": 12,
				"leg_f": 70, "knee_f": 10, "leg_b": -52, "knee_b": 60},
			"events": {
				15: [["voice", {"line": "hyper"}], ["shake", {"amount": 5.0}]],
				26: [["shake", {"amount": 3.0}]],
			},
		}),
		# MAX version of MOON HOWL — same input, all three bars. The whole pack
		# arrives, not just the two at the front.
		"hyper_max": MoveData.make({
			"id": "the whole sky", "display": "THE WHOLE SKY!", "level": 3, "startup": 20,
			"active": 1, "recovery": 52, "invuln": 47, "prop": "moon", "sfx": "hyper",
			"meter_cost": 300,
			"projectile": {
				"kind": "wolf", "anchored": true, "size": Vector2(700, 140), "offset": Vector2(40, -70),
				"life": 76, "hits": 19, "interval": 4, "damage": 20, "hitstun": 18,
				"kb": Vector2(1.2, -2.0), "chip": 0.2, "hitstop": 4, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "hyper",
				# Brighter and icier than the two-wolf howl, so the full pack
				# reads as more of them rather than the same wolf scaled up.
				"tint": {"core": Color("ffffff"), "mid": Color("b8dcff"), "edge": Color("1f3a7a"),
					"halo": Color("d4ecff")},
			},
			# Thrown back on one leg, both arms straight up, mouth wide open.
			"cutin_pose": {"head": -42, "lean": -30, "arm_f": 188, "elb_f": 0, "arm_b": 190, "elb_b": 0,
				"leg_f": 22, "knee_f": 6, "leg_b": -42, "knee_b": 48},
			"keys": [
				[0, {"head": -38, "lean": -26, "arm_f": 184, "elb_f": 0, "arm_b": 186, "elb_b": 0,
					"leg_f": 20, "knee_f": 8, "leg_b": -38, "knee_b": 44}, 0.5],
				[19, {"head": -46, "lean": -32, "arm_f": 178, "elb_f": 0, "arm_b": 182, "elb_b": 0,
					"leg_f": 34, "knee_f": 6, "leg_b": -26, "knee_b": 26}, 0.95],
				[52, {"head": -40, "lean": -28, "arm_f": 172, "elb_f": 4, "arm_b": 176, "elb_b": 4,
					"leg_f": 30, "knee_f": 8, "leg_b": -30, "knee_b": 30}, 0.4],
				[68, {"head": -2, "lean": 6, "arm_f": 40, "elb_f": 100, "arm_b": 42, "elb_b": 100}, 0.35],
			],
			# Leaning into the full pack, nose up.
			"contact_pose": {"head": -50, "lean": -38, "arm_f": 186, "elb_f": 0, "arm_b": 190, "elb_b": 0,
				"leg_f": 40, "knee_f": 4, "leg_b": -22, "knee_b": 20},
			"events": {
				19: [["voice", {"line": "hyper"}], ["shake", {"amount": 6.0}]],
				30: [["shake", {"amount": 3.0}]],
			},
		}),
		# MAX version of FULL MOON! — the moon comes down over the whole stage.
		"hyper2_max": MoveData.make({
			"id": "super moon", "display": "SUPER MOON!", "level": 3, "startup": 18,
			"active": 1, "recovery": 50, "invuln": 47, "prop": "moon", "sfx": "hyper",
			"meter_cost": 300,
			"projectile": {
				"kind": "beam", "anchored": true, "size": Vector2(270, 410), "offset": Vector2(50, -205),
				"life": 70, "hits": 16, "interval": 4, "damage": 22, "hitstun": 18,
				"kb": Vector2(1.2, -4.0), "chip": 0.2, "hitstop": 4, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "hyper",
				# The moon coming down over the whole stage: near-white, with the
				# warm rim the smaller pillar keeps.
				"tint": {"core": Color("ffffff"), "mid": Color("fff4c8"), "edge": Color("a8862b"),
					"halo": Color("fffbe8")},
			},
			# Arms crossed over his eyes, bracing for it to land on him.
			"cutin_pose": {"head": -38, "lean": -12, "arm_f": 186, "elb_f": 0, "arm_b": 182, "elb_b": 0,
				"leg_f": 30, "knee_f": 20, "leg_b": -26, "knee_b": 26},
			"keys": [
				[0, {"head": -36, "lean": -10, "arm_f": 184, "elb_f": 2, "arm_b": 180, "elb_b": 2,
					"leg_f": 28, "knee_f": 22, "leg_b": -24, "knee_b": 28}, 0.5],
				[17, {"head": -44, "lean": 4, "arm_f": 106, "elb_f": 16, "arm_b": 102, "elb_b": 20,
					"leg_f": 72, "knee_f": 8, "leg_b": -54, "knee_b": 64}, 0.95],
				[48, {"head": -40, "lean": 0, "arm_f": 114, "elb_f": 12, "arm_b": 110, "elb_b": 16,
					"leg_f": 64, "knee_f": 12, "leg_b": -48, "knee_b": 58}, 0.4],
				[62, {"head": -2, "lean": 6, "arm_f": 40, "elb_f": 100, "arm_b": 42, "elb_b": 100}, 0.35],
			],
			# Holding it open over his head with the whole moon behind it.
			"contact_pose": {"head": -48, "lean": 8, "arm_f": 118, "elb_f": 6, "arm_b": 114, "elb_b": 10,
				"leg_f": 82, "knee_f": 6, "leg_b": -60, "knee_b": 70},
			"events": {
				17: [["voice", {"line": "hyper"}], ["shake", {"amount": 6.0}]],
				30: [["shake", {"amount": 3.0}]],
			},
		}),
	}
	size = 0.78  # he is two
	build = 0.84  # slimmer than the old round diaper silhouette; still a toddler
	scale_moves()


## Connected chain: an odd hit is the authored front limb, an even hit is the
## other one, so a light-light string reads as a one-two. Specials are left
## alone: his tail whip, roly poly and belly flop already pose both limbs.
func adjust_attack_pose(f: Fighter, m: MoveData, p: Dictionary) -> Dictionary:
	if m.level > 1 or f.chain % 2 == 1:
		return p
	return cross_limbs(p)

# --- The look -------------------------------------------------------------------
# The shared body does the work: a circle head, a wedge torso, mitten hands and a
# slipper. What is drawn here is what is specific to him — the curls, the floppy
# ears and the curly tail on their chains, the puppy nose, the blush, and the
# bone and moon he holds.


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	# A curly tail that trails behind him, and two floppy ears that swing off
	# the head. The springs do all the animation work for free.
	r.chain("tail", s["hip"] - perp * 5.0 + up * 2.0, 6, 4.0, -0.22, 0.86, 0.22)
	r.chain("ear_f", FighterRenderer.head_point(s, Vector2(6.0, -9.0)), 5, 4.0, 0.42, 0.82, 0.3)
	r.chain("ear_b", FighterRenderer.head_point(s, Vector2(-7.0, -8.0)), 5, 4.0, 0.42, 0.82, 0.3)


func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
	var fur: Color = r.colors["fur"]
	var tail := r.chain_local("tail")
	if tail.size() > 1:
		r.ribbon(tail, 7.0, 3.0, fur)
		r.ball(tail[tail.size() - 1], 3.2, FighterRenderer.hl(fur))
	var ear := r.chain_local("ear_b")
	if ear.size() > 1:
		r.ribbon(ear, 7.0, 4.0, FighterRenderer.dk(fur))


func draw_hair_back(r: FighterRenderer) -> void:
	# A soft round mop — toddler hair, no styling.
	r.shaded_poly(PackedVector2Array([
		Vector2(-12, 4), Vector2(-13, -6), Vector2(-7, -14), Vector2(3, -15),
		Vector2(11, -10), Vector2(12, 0),
	]), r.colors["hair"], 1.8, 0.75)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	# Three fat curls across the forehead.
	r.shaded_poly(PackedVector2Array([
		Vector2(-11, 1), Vector2(-12, -8), Vector2(-5, -15), Vector2(4, -15.5),
		Vector2(12, -10), Vector2(13, -2), Vector2(10, -6), Vector2(6, -1),
		Vector2(2, -7), Vector2(-3, -1.5), Vector2(-7, -7),
	]), hc, 2.0, 0.85)
	# The one stubborn sprout on top.
	r.draw_line(Vector2(1, -15), Vector2(3, -21), hc, 1.6, true)
	r.draw_line(Vector2(3, -21), Vector2(6, -19), hc, 1.4, true)


func draw_face(r: FighterRenderer) -> void:
	r.face(r.colors["eyes"])
	# Puppy nose and two dots of blush: this is the whole character in 3 shapes.
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(9.0, 3.0), 2.2, 1.7), r.colors["nose"])
	for cx in [-2.0, 11.0]:
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(cx, 5.5), 2.6, 1.6), Color(1, 0.55, 0.6, 0.45))
	var ear := r.chain_local("ear_f")
	if ear.size() > 1:
		r.ribbon(ear, 7.0, 4.0, r.colors["fur"])


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	match r.prop:
		"bone":
			var c: Vector2 = (s["hand_f"] + s["hand_b"]) * 0.5 + Vector2(2, -4)
			var bone := Color("fff3d8")
			r.part(c + Vector2(-8, 0), c + Vector2(8, 0), 4.0, 4.0, bone)
			for e in [-9.0, 9.0]:
				r.ball(c + Vector2(e, -3), 2.6, bone)
				r.ball(c + Vector2(e, 3), 2.6, bone)
		"moon":
			# A low moon rises behind him while he howls.
			var m: Vector2 = s["head"] + Vector2(-26, -34)
			var t := minf(r.prop_t / 18.0, 1.0)
			var rad := 13.0 * t
			r.draw_circle(m, rad + 3.0, Color(0.85, 0.9, 1.0, 0.20 * t))
			r.draw_circle(m, rad, Color(0.96, 0.97, 1.0, 0.9 * t))
			for spot in [Vector2(-4, -3), Vector2(3, 2), Vector2(-1, 5)]:
				r.draw_circle(m + spot * t, 2.0 * t, Color(0.82, 0.85, 0.95, 0.9 * t))
