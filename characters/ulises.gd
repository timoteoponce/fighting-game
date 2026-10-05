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
		["BACK + L + H", "GAME THUNDER!"],
		["UP + L + H", "MURILLO!!"],
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
# Hyper A — GAME THUNDER. A screen-crossing bolt of light along the
		# ground, in a storm palette: deep blue body, white-hot core, gold forks.
		"hyper": MoveData.make({"id": "game thunder", "display": "GAME THUNDER!", "level": 3, "startup": 15,
			"active": 1, "recovery": 48, "invuln": 45, "prop": "controller", "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(600, 86), "offset": Vector2(39, -72), "life": 54,
				"hits": 13, "interval": 4, "damage": 21, "hitstun": 16, "kb": Vector2(1.2, -0.4), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 0.9, "sfx": "special",
				# A lightning bolt, not an arcade laser: storm blue with a
				# white-hot core, and the word spelled out on it.
				"tint": {"core": Color("ffffff"), "mid": Color("3d7dff"), "edge": Color("101c66"),
					"halo": Color("6f9dff"), "text": "GAME THUNDER", "label": Color("0a1240"),
					"label_ink": Color("dbe6ff")}},
			# Controller held overhead, both hands, head back: the last input.
			"cutin_pose": {"lean": -14, "head": -22, "arm_f": 172, "elb_f": 6, "arm_b": 168, "elb_b": 10,
				"leg_f": -6, "knee_f": 8, "leg_b": 22, "knee_b": 20},
			"keys": [
				# Winds up low, controller drawn back behind him...
				[0, {"lean": 18, "head": 6, "arm_f": -40, "elb_f": 60, "arm_b": -50, "elb_b": 70,
					"leg_f": 40, "knee_f": 60, "leg_b": 20, "knee_b": 60}, 0.5],
				# ...then drives it forward and the bolt leaves the yard line.
				[14, {"lean": -10, "head": -16, "arm_f": 150, "elb_f": 10, "arm_b": 120, "elb_b": 20,
					"leg_f": 60, "knee_f": 10, "leg_b": -30, "knee_b": 20}, 0.95],
				# Held out through the beam.
				[36, {"lean": -6, "head": -12, "arm_f": 142, "elb_f": 16, "arm_b": 112, "elb_b": 26,
					"leg_f": 54, "knee_f": 14, "leg_b": -26, "knee_b": 22}, 0.4],
				[50, {"lean": 4, "head": 0, "arm_f": 40, "elb_f": 90, "arm_b": 45, "elb_b": 95}, 0.35],
			],
			# Throwing it down the line.
			"contact_pose": {"lean": -2, "head": -8, "arm_f": 130, "elb_f": 24, "arm_b": 100, "elb_b": 34,
				"leg_f": 48, "knee_f": 18, "leg_b": -22, "knee_b": 24}}),
		# Hyper B — MURILLO. His super is a kick: he sprints in and scissors a
		# super kick through them. Pure melee, so it paces its own hits and
		# carries no projectile; the boot streak is a `slash` event, which the
		# renderer sizes to the hitbox, so the art cannot drift from the hit.
		"hyper2": MoveData.make({"id": "murillo", "display": "MURILLO!!", "level": 3, "startup": 14,
			"active": 18, "recovery": 44, "invuln": 43, "prop": "controller", "sfx": "kick",
			"hits": 5, "hit_interval": 5, "damage": 26, "hitstun": 20,
			"hitbox": Rect2(6, -132, 128, 112), "kb": Vector2(3.2, -3.0), "chip": 0.2,
			"hitstop": 6, "meter": 0.0, "shake": 2.2, "hit_sfx": "heavy",
			"dash_speed": 9.5, "dash_from": 6, "dash_to": 20,
			"knockdown": true, "strength": 99,
			"cutin_pose": {"lean": 26, "head": 10, "arm_f": -50, "elb_f": 30, "arm_b": -80, "elb_b": 20,
				"leg_f": 150, "knee_f": 10, "leg_b": 20, "knee_b": 110},
			"keys": [
				# Crouched coil, both arms back for balance.
				[0, {"lean": 24, "head": 8, "arm_f": -60, "elb_f": 40, "arm_b": -90, "elb_b": 30,
					"leg_f": 70, "knee_f": 90, "leg_b": 30, "knee_b": 90}, 0.5],
				# He is already airborne by the time the boot comes round.
				[12, {"lean": 34, "head": 14, "arm_f": -110, "elb_f": 10, "arm_b": -140, "elb_b": 6,
					"leg_f": 165, "knee_f": 0, "leg_b": 10, "knee_b": 118}, 0.95],
				# Follow-through, scissoring back the other way.
				[26, {"lean": 12, "head": 6, "arm_f": -70, "elb_f": 40, "arm_b": -90, "elb_b": 30,
					"leg_f": 120, "knee_f": 20, "leg_b": 60, "knee_b": 80}, 0.5],
				[42, {"lean": 8, "head": 2, "arm_f": 30, "elb_f": 90, "arm_b": 35, "elb_b": 95,
					"leg_f": 50, "knee_f": 40, "leg_b": 30, "knee_b": 40}, 0.35],
			],
			# A swoosh on the way in and a bigger one on the follow-through, both
			# sized from the hitbox so they match it exactly.
			"events": {
				12: [["voice", {"line": "hyper"}], ["slash", {}], ["shake", {"amount": 2.2}]],
				20: [["slash", {"r": 90.0}], ["sfx", {"name": "heavy"}]],
				28: [["slash", {"r": 74.0}]],
			},
			# The boot is through them and he is still up.
			"contact_pose": {"lean": 40, "head": 18, "arm_f": -130, "elb_f": 0, "arm_b": -160, "elb_b": 0,
				"leg_f": 172, "knee_f": 0, "leg_b": 0, "knee_b": 124}}),
		# MAX of GAME THUNDER — the whole storm, along the ground and up the
		# screen, so the bolt is twice as long and no longer a clean rectangle.
		"hyper_max": MoveData.make({"id": "final score", "display": "FINAL SCORE!!", "level": 3,
			"startup": 18, "active": 1, "recovery": 54, "invuln": 47, "prop": "controller",
			"meter_cost": 300, "sfx": "special",
			"projectile": {"kind": "beam", "anchored": true, "size": Vector2(940, 210), "offset": Vector2(39, -104), "life": 88,
				"hits": 19, "interval": 5, "damage": 27, "hitstun": 20, "kb": Vector2(1.2, -1.5), "chip": 0.2, "hitstop": 4,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "shake": 1.0, "sfx": "special",
				# White-hot core so it reads as the same storm at full voltage.
				"tint": {"core": Color("ffffff"), "mid": Color("6f9dff"), "edge": Color("0a1240"),
					"halo": Color("a8c0ff"), "text": "FINAL SCORE", "label": Color("0a1240"),
					"label_ink": Color("ffffff")}},
			# Arms flung wide, head back, both heels off the floor: he is about to
			# blow the whole game open rather than push a button.
			"cutin_pose": {"lean": -20, "head": -28, "arm_f": 168, "elb_f": 8, "arm_b": 176, "elb_b": 6,
				"leg_f": 24, "knee_f": 12, "leg_b": -18, "knee_b": 16},
			"keys": [
				[0, {"lean": 20, "head": 8, "arm_f": -50, "elb_f": 55, "arm_b": -60, "elb_b": 65,
					"leg_f": 44, "knee_f": 56, "leg_b": 24, "knee_b": 56}, 0.5],
				[17, {"lean": -14, "head": -22, "arm_f": 164, "elb_f": 4, "arm_b": 172, "elb_b": 4,
					"leg_f": 30, "knee_f": 6, "leg_b": -14, "knee_b": 12}, 0.95],
				[62, {"lean": -8, "head": -16, "arm_f": 150, "elb_f": 18, "arm_b": 158, "elb_b": 16,
					"leg_f": 22, "knee_f": 10, "leg_b": -10, "knee_b": 14}, 0.4],
				[80, {"lean": 4, "head": 0, "arm_f": 40, "elb_f": 90, "arm_b": 45, "elb_b": 95}, 0.35],
			],
			"contact_pose": {"lean": -4, "head": -12, "arm_f": 136, "elb_f": 22, "arm_b": 144, "elb_b": 20,
				"leg_f": 26, "knee_f": 12, "leg_b": -12, "knee_b": 14}}),
		# MAX of MURILLO — the same scissor kick, but he comes in off a full
		# sprint and keeps his foot going through them.
		"hyper2_max": MoveData.make({"id": "the last ditch", "display": "THE LAST DITCH!", "level": 3,
			"startup": 15, "active": 22, "recovery": 46, "invuln": 45, "prop": "controller",
			"meter_cost": 300, "sfx": "kick",
			"hits": 7, "hit_interval": 5, "damage": 30, "hitstun": 22,
			"hitbox": Rect2(4, -140, 168, 128), "kb": Vector2(3.6, -4.0), "chip": 0.2,
			"hitstop": 6, "meter": 0.0, "shake": 2.6, "hit_sfx": "heavy",
			"dash_speed": 11.0, "dash_from": 5, "dash_to": 22,
			"knockdown": true, "strength": 99,
			"cutin_pose": {"lean": 34, "head": 16, "arm_f": -70, "elb_f": 20, "arm_b": -100, "elb_b": 14,
				"leg_f": 168, "knee_f": 0, "leg_b": 6, "knee_b": 126},
			"keys": [
				[0, {"lean": 30, "head": 10, "arm_f": -80, "elb_f": 30, "arm_b": -110, "elb_b": 20,
					"leg_f": 88, "knee_f": 96, "leg_b": 40, "knee_b": 96}, 0.5],
				[13, {"lean": 42, "head": 20, "arm_f": -140, "elb_f": 0, "arm_b": -170, "elb_b": 0,
					"leg_f": 178, "knee_f": 0, "leg_b": -6, "knee_b": 130}, 0.95],
				[32, {"lean": 16, "head": 8, "arm_f": -80, "elb_f": 36, "arm_b": -100, "elb_b": 26,
					"leg_f": 130, "knee_f": 16, "leg_b": 50, "knee_b": 86}, 0.5],
				[52, {"lean": 10, "head": 2, "arm_f": 30, "elb_f": 90, "arm_b": 35, "elb_b": 95,
					"leg_f": 54, "knee_f": 36, "leg_b": 32, "knee_b": 36}, 0.35],
			],
			# More swooshes, all off the bigger hitbox.
			"events": {
				13: [["voice", {"line": "hyper"}], ["slash", {}], ["shake", {"amount": 2.6}]],
				19: [["slash", {"r": 112.0}], ["sfx", {"name": "heavy"}]],
				25: [["slash", {"r": 96.0}]],
				31: [["slash", {"r": 88.0}]],
			},
			# Straight through them, still horizontal.
			"contact_pose": {"lean": 50, "head": 24, "arm_f": -160, "elb_f": 0, "arm_b": -186, "elb_b": 0,
				"leg_f": 182, "knee_f": 0, "leg_b": -10, "knee_b": 132}}),
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
