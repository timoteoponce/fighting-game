class_name UlisesDef
extends CharacterDef
## Ulises: soccer, running, reading and video games. Fast and sporty.


func _init() -> void:
	id = "ulises"
	display = "ULISES"
	likes = "Soccer, running, reading, video games"
	win_quote = "Game over! Now, where was I in my book?"
	gag_items = ["ball", "tooth", "star"]
	taunt_lines = ["TOO SLOW!", "GOOOAL!", "NICE TRY!"]
	hurt_lines = ["OOF!", "MY BALL!", "HEY!"]
	# "white" is a warm off-white, not Color.WHITE. Against the thick ink at
	# 320x180 a true white fill dissolves its own outline, so the shirt number and
	# the sock cuffs read as washed-out gaps. Everything that needs to look like
	# white fabric or a sclera uses this instead.
	colors = {
		"skin": Color("f2c29b"), "hair": Color("2b1a12"), "shirt": Color("2f6fe0"), "sleeve": Color("2f6fe0"),
		"forearm": Color("f2c29b"), "hands": Color("f2c29b"), "pants": Color("f2c29b"), "shorts": Color("e6e0d2"),
		"legs": Color("2f6fe0"), "shoes": Color("b6f23a"), "eyes": Color("5a3a22"), "accent": Color("34c759"),
		"band": Color("e8322e"), "white": Color("e6e0d2"),
	}
	# P2's kit is the red one with white trim. The trim and the shorts were true
	# white once; against the thick ink at 320x180 they lost their own outline, so
	# they are the off-white `"white"` key now.
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("e0402f"), "sleeve": Color("e0402f"), "accent": Color("e6e0d2"), "legs": Color("e0402f"),
		"shoes": Color("ffd23f"), "band": Color("2f6fe0"), "shorts": Color("2a2a38"), "white": Color("e6e0d2")}, true)
	walk_speed = 3.4
	back_speed = 2.8
	jump_vel = -10.5
	jump_x = 4.0
	voice_pitch = 250.0
	roster_order = 0
	win_prop = "book"
	intro_prop = "ball_intro"
	specials_text = [
		["L + H", "Power Shot"],
		["FWD + L + H", "Sprint Dash"],
		["DOWN + L + H", "Bicycle Kick"],
		["BACK + L + H", "GAME OVER COMBO"],
		["UP + L + H", "FULL PITCH!"],
	]
	poses = {
		"intro": {"arm_f": 160, "elb_f": 15, "arm_b": 30, "elb_b": 100, "lean": -4},
		# He holds up the book he was reading when the match started.
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
			"recovery": 50, "invuln": 45, "prop": "controller", "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(560, 72), "offset": Vector2(39, -75), "life": 56,
				"hits": 12, "interval": 4, "damage": 20, "hitstun": 16, "kb": Vector2(1.2, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 0.8, "sfx": "special",
				# A retro arcade beam: phosphor green, the colour a CRT 8-bit
				# shooter used for its laser. `text` is the pixel word on it.
				"tint": {"core": Color("f2fff4"), "mid": Color("35e06a"), "edge": Color("0f5f2c"),
					"halo": Color("2bff77"), "text": "GAME OVER", "label": Color("0b3d1e"),
					"label_ink": Color("c8ffdb")}},
			# Through the cut-in freeze he is planted, controller up, both feet
			# braced — the pose a kid holds before he mashes the final button.
			"cutin_pose": {"lean": -12, "head": -18, "arm_f": 20, "elb_f": 95, "arm_b": 165, "elb_b": 25,
				"leg_f": -8, "knee_f": 10, "leg_b": 30, "knee_b": 26},
			"keys": [
				# Controller cocked over his head, weight on the back foot...
				[0, {"lean": -10, "head": -16, "arm_f": 20, "elb_f": 100, "arm_b": 170, "elb_b": 20,
					"leg_f": -6, "knee_f": 12, "leg_b": 28, "knee_b": 24}, 0.5],
				# ...then he slams it down and both arms punch straight out.
				[14, {"lean": 10, "head": 4, "arm_f": 92, "elb_f": 4, "arm_b": 96, "elb_b": 4,
					"leg_f": 34, "knee_f": 30, "leg_b": -30, "knee_b": 26}, 0.95],
				# The beam holds; he pushes into it and settles onto the front foot.
				[40, {"lean": 6, "head": 0, "arm_f": 88, "elb_f": 10, "arm_b": 92, "elb_b": 10,
					"leg_f": 26, "knee_f": 26, "leg_b": -22, "knee_b": 22}, 0.4],
				[62, {"lean": 2, "head": 2, "arm_f": 40, "elb_f": 90, "arm_b": 45, "elb_b": 95,
					"leg_f": 16, "knee_f": 18, "leg_b": -14, "knee_b": 16}, 0.35],
			],
			# Snapped in while the beam is chewing on them: he drives it forward.
			"contact_pose": {"lean": 16, "head": 8, "arm_f": 100, "elb_f": 0, "arm_b": 104, "elb_b": 0,
				"leg_f": 44, "knee_f": 34, "leg_b": -38, "knee_b": 30}}),
		# Hyper B — UP + L + H. The other Game Over: instead of firing a beam
		# across the screen he slides the length of the pitch on his side, low
		# enough to take the legs out from under anything standing.
		"hyper2": MoveData.make({"id": "full pitch", "display": "FULL PITCH!", "level": 3, "startup": 14, "active": 1,
			"recovery": 46, "invuln": 43, "prop": "controller", "sfx": "kick",
			# Not anchored: this one travels, and it rides low (its belly clears the
			# ball, so it never steals it).
			"projectile": {"kind": "beam", "speed": 11.0, "size": Vector2(430, 60), "offset": Vector2(40, -52), "life": 90,
				"hits": 9, "interval": 5, "damage": 22, "hitstun": 18, "kb": Vector2(1.4, -2.5), "chip": 0.18,
				"hitstop": 3, "meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 0.8, "sfx": "kick",
				# The pitch itself: turf green with a chalk-white core, so it
				# reads as a slide down the grass and not as the other beam.
				"tint": {"core": Color("f6ffe9"), "mid": Color("63c23c"), "edge": Color("20501f"),
					"halo": Color("8ce06a")}},
			"cutin_pose": {"lean": 34, "head": 6, "arm_f": -46, "elb_f": 30, "arm_b": -70, "elb_b": 20,
				"leg_f": 96, "knee_f": 8, "leg_b": -44, "knee_b": 78},
			"keys": [
				# Drops his weight and throws his legs out, head up, still grinning.
				[0, {"lean": 32, "head": 6, "arm_f": -44, "elb_f": 32, "arm_b": -68, "elb_b": 22,
					"leg_f": 92, "knee_f": 10, "leg_b": -42, "knee_b": 74}, 0.5],
				# The slide: front leg thrown right out, trailing leg tucked under.
				[13, {"lean": 52, "head": 14, "arm_f": -68, "elb_f": 16, "arm_b": -92, "elb_b": 10,
					"leg_f": 122, "knee_f": 0, "leg_b": -58, "knee_b": 96}, 0.95],
				# Still travelling: the slide skids and settles lower.
				[40, {"lean": 46, "head": 10, "arm_f": -58, "elb_f": 22, "arm_b": -80, "elb_b": 14,
					"leg_f": 112, "knee_f": 4, "leg_b": -52, "knee_b": 88}, 0.4],
				[58, {"lean": 14, "head": 2, "arm_f": 20, "elb_f": 90, "arm_b": 25, "elb_b": 95,
					"leg_f": 34, "knee_f": 34, "leg_b": -28, "knee_b": 28}, 0.35],
			],
			# The tackle is through them and he skids past, still on his side.
			"contact_pose": {"lean": 58, "head": 18, "arm_f": -76, "elb_f": 10, "arm_b": -100, "elb_b": 6,
				"leg_f": 132, "knee_f": 0, "leg_b": -64, "knee_b": 104}}),
		# MAX version of GAME OVER COMBO — same input, all three bars. The beam is
		# tall enough to fill the screen instead of cutting across it, and it stays
		# out twice as long.
		"hyper_max": MoveData.make({"id": "final score", "display": "FINAL SCORE!!", "level": 3,
			"startup": 18, "active": 1, "recovery": 56, "invuln": 47, "prop": "controller",
			"meter_cost": 300, "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(900, 190), "offset": Vector2(39, -90), "life": 96,
				"hits": 18, "interval": 5, "damage": 26, "hitstun": 20, "kb": Vector2(1.2, -1.5), "chip": 0.2, "hitstop": 4,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "special",
				# Every bar on the gauge, spent at once: white-hot gold.
				"tint": {"core": Color("fffdf2"), "mid": Color("ffc633"), "edge": Color("8a4a00"),
					"halo": Color("ffdd66"), "text": "FINAL SCORE", "label": Color("5c2f00"),
					"label_ink": Color("fff2cc")}},
			# Arms flung wide and up, head back, both heels off the floor: he is
			# about to blow the whole game open rather than push a button.
			"cutin_pose": {"lean": -20, "head": -28, "arm_f": 168, "elb_f": 8, "arm_b": 176, "elb_b": 6,
				"leg_f": 6, "knee_f": 4, "leg_b": -6, "knee_b": 6, "ground": 0, "hip": -62},
			"keys": [
				[0, {"lean": -18, "head": -26, "arm_f": 162, "elb_f": 14, "arm_b": 170, "elb_b": 12,
					"leg_f": 4, "knee_f": 6, "leg_b": -4, "knee_b": 8, "ground": 0, "hip": -58}, 0.5],
				[16, {"lean": 14, "head": 6, "arm_f": 94, "elb_f": 0, "arm_b": 98, "elb_b": 0,
					"leg_f": 48, "knee_f": 36, "leg_b": -42, "knee_b": 32, "ground": 0, "hip": -50}, 0.95],
				[48, {"lean": 8, "head": 2, "arm_f": 90, "elb_f": 8, "arm_b": 94, "elb_b": 8,
					"leg_f": 38, "knee_f": 30, "leg_b": -34, "knee_b": 28, "ground": 0, "hip": -52}, 0.4],
				[70, {"lean": 2, "head": 2, "arm_f": 40, "elb_f": 90, "arm_b": 45, "elb_b": 95}, 0.35],
			],
			# Driving it forward with everything he has.
			"contact_pose": {"lean": 24, "head": 10, "arm_f": 108, "elb_f": 0, "arm_b": 112, "elb_b": 0,
				"leg_f": 60, "knee_f": 40, "leg_b": -52, "knee_b": 36, "ground": 0, "hip": -46}}),
		# MAX version of FULL PITCH! — the slide down the whole pitch, wide enough
		# and long enough that stepping over it is not an option.
		"hyper2_max": MoveData.make({"id": "the last ditch", "display": "THE LAST DITCH!", "level": 3,
			"startup": 16, "active": 1, "recovery": 50, "invuln": 45, "prop": "controller",
			"meter_cost": 300, "sfx": "kick",
			"projectile": {"kind": "beam", "speed": 12.0, "size": Vector2(640, 96), "offset": Vector2(40, -56), "life": 110,
				"hits": 14, "interval": 5, "damage": 28, "hitstun": 20, "kb": Vector2(1.4, -3.0), "chip": 0.18,
				"hitstop": 4, "meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "kick",
				# The red card. Nothing else in the game is this colour.
				"tint": {"core": Color("fff0ec"), "mid": Color("ff4d4d"), "edge": Color("7a0f18"),
					"halo": Color("ff6b5e")}},
			# Down on his side before he has even moved, arms tucked, chin up.
			"cutin_pose": {"lean": 56, "head": 20, "arm_f": -80, "elb_f": 8, "arm_b": -104, "elb_b": 4,
				"leg_f": 132, "knee_f": 0, "leg_b": -66, "knee_b": 106},
			"keys": [
				[0, {"lean": 54, "head": 18, "arm_f": -78, "elb_f": 10, "arm_b": -102, "elb_b": 6,
					"leg_f": 128, "knee_f": 0, "leg_b": -64, "knee_b": 102}, 0.5],
				[15, {"lean": 70, "head": 26, "arm_f": -100, "elb_f": 2, "arm_b": -124, "elb_b": 0,
					"leg_f": 152, "knee_f": 0, "leg_b": -76, "knee_b": 118}, 0.95],
				[48, {"lean": 60, "head": 20, "arm_f": -84, "elb_f": 8, "arm_b": -108, "elb_b": 4,
					"leg_f": 138, "knee_f": 0, "leg_b": -70, "knee_b": 110}, 0.4],
				[64, {"lean": 14, "head": 2, "arm_f": 20, "elb_f": 90, "arm_b": 25, "elb_b": 95,
					"leg_f": 34, "knee_f": 34, "leg_b": -28, "knee_b": 28}, 0.35],
			],
			# Straight through them, still horizontal.
			"contact_pose": {"lean": 78, "head": 30, "arm_f": -112, "elb_f": 0, "arm_b": -136, "elb_b": 0,
				"leg_f": 164, "knee_f": 0, "leg_b": -82, "knee_b": 124}}),
	}
	size = 0.9  # Ulises is about 10% shorter than Emilia
	scale_moves()


# --- The ball -------------------------------------------------------------------
# Ulises' signature mechanic: a real ball on the floor that both players fight
# over. It is a Projectile with the `persistent`
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
	return cross_limbs(p)


# --- The look -------------------------------------------------------------------
# The shared body does the work: a circle head, a wedge torso, mitten hands and a
# slipper. What is drawn here is what is specific to him — the headband on its
# chain, the jersey trim, the sock stripes, the spikes and the props he holds.
# Every white is the off-white `"white"` colour key rather than `Color.WHITE`:
# against the thick ink at 320x180 a true white fill loses its own outline.


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
	# A small belly pushing the jersey out in front. The shared torso is a straight wedge.
	var belly := hip + up * 9.0 + perp * 5.5
	r.poly(FighterRenderer.ellipse_pts(belly, 7.2, 5.0, atan2(perp.y, perp.x)), r.colors["shirt"], 1.6)
	# Number 10, kept readable when facing left.
	var num: Vector2 = hip + up * 17.0 + perp * 1.0
	r.draw_set_transform(num, atan2(up.x, -up.y), Vector2(signf(r.scale.x) * 0.5, 0.5))
	UI.text(r, Vector2(0, 5), "10", 16, r.colors["white"], HORIZONTAL_ALIGNMENT_CENTER, 4, acc.darkened(0.4))
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
		r.draw_line(a - n * 3.6, a + n * 3.6, r.colors["white"], 1.8, true)


func draw_face(r: FighterRenderer) -> void:
	draw_ear(r)
	r.face(r.colors["eyes"])


func draw_hair_back(r: FighterRenderer) -> void:
	r.shaded_poly(PackedVector2Array([Vector2(-10, 5), Vector2(-14, 0), Vector2(-12, -8), Vector2(-4, -14), Vector2(0, -4)]), r.colors["hair"], 1.8, 0.7)


func draw_hair_front(r: FighterRenderer) -> void:
	var hc: Color = r.colors["hair"]
	# Sharp spikes on top. The headband, drawn after this, covers the roots.
	var hair := PackedVector2Array([
		Vector2(-9, 5), Vector2(-15, 1), Vector2(-11, -3), Vector2(-20, -8), Vector2(-12, -11), Vector2(-18, -18),
		Vector2(-8, -14), Vector2(-9, -28), Vector2(-3, -15), Vector2(1, -31), Vector2(6, -15), Vector2(12, -26),
		Vector2(9, -13), Vector2(17, -14), Vector2(11.5, -8), Vector2(13, -4.5), Vector2(9, -6), Vector2(7.5, -2),
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
			r.draw_rect(Rect2(c + Vector2(-11, -1.5), Vector2(7, 2.2)), r.colors["white"])
			r.draw_rect(Rect2(c + Vector2(-8.5, -4), Vector2(2.2, 7)), r.colors["white"])
			r.draw_circle(c + Vector2(7, -2), 1.8, Color("ff5a5a"))
			r.draw_circle(c + Vector2(10.5, 1.5), 1.8, Color("5ac8ff"))
