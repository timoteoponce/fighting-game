class_name TemplateDef
extends CharacterDef
## COPY ME to make a new fighter.
##
## How to add a character, start to finish:
##   1. Copy this file to `characters/yourname.gd`.
##   2. Rename the class on line 1 (`class_name YournameDef`) — it must be
##      unique across the whole project.
##   3. Change `id` to a lowercase, one-word name. That id is what the roster,
##      the save files and the `--chars=` flag use.
##   4. Delete the leading underscore from the filename. Files starting with
##      "_" are skipped by the roster scanner, which is the only reason this
##      template doesn't show up on the select screen.
##   5. Run `godot --headless --path . -- --test`. The character validation
##      test will tell you exactly what is still missing.
##
## That's it. There is no list to register in, no audio table, no match
## statement. One file is a whole fighter.
##
## Every value below is already playable — this template is a complete,
## balanced-ish fighter, not a stub. Change things one at a time and replay.


func _init() -> void:
	# --- Identity ---------------------------------------------------------
	id = "template"  # lowercase, no spaces; this is the roster key
	display = "TEMPLATE"  # shown on the select screen and the HUD
	likes = "Being copied into a real character"  # a line of flavour, kid-facing
	win_quote = "Now go make me into someone!"  # shown on the victory screen
	# Stuff that flies off when you get clobbered, and lines for speech bubbles.
	gag_items = ["star", "tooth"]
	taunt_lines = ["HA HA!"]
	hurt_lines = ["OUCH!"]
	roster_order = 999  # lower numbers come first on the select screen

	# --- Colours ----------------------------------------------------------
	# The shared body renderer needs every key in CharacterDef.REQUIRED_COLORS.
	# Add your own extra keys if you draw extra parts in draw_behind/draw_front.
	colors = {
		"skin": Color("e8b98f"), "hair": Color("332218"), "shirt": Color("3aa76d"),
		"sleeve": Color("3aa76d"), "forearm": Color("e8b98f"), "hands": Color("e8b98f"),
		"pants": Color("2b3a4a"), "legs": Color("2b3a4a"), "shoes": Color("d8d8d8"),
		"eyes": Color("3a5a2a"), "accent": Color("ffd24a"),
	}
	# Player 2 (or a mirror match) uses these instead, so the two fighters are
	# never the same colour. Start from `colors` and change only what matters.
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("c8532f"), "sleeve": Color("c8532f"), "pants": Color("40243a"),
		"legs": Color("40243a"), "accent": Color("7fd0ff"), "shoes": Color("2a2a2a"),
	}, true)

	# --- Movement ---------------------------------------------------------
	# size = 1.0 is the default build. If you change it, call scale_moves() at
	# the end of _init() so the hitboxes grow or shrink with the body.
	size = 1.0
	walk_speed = 3.3  # pixels per frame walking forward
	back_speed = 2.7  # walking backward; always make this slower than forward
	jump_vel = -11.0  # more negative = higher jump
	jump_x = 3.7  # horizontal speed during a jump
	voice_pitch = 290.0  # Hz; ~250 reads as a boy, ~330 as a girl

	# --- Menus ------------------------------------------------------------
	# The move list on the pause screen is built from this, so it can never
	# drift away from what the moves actually do. Keep it in sync by hand.
	specials_text = [
		["L + H", "Palm Blast"],
		["FWD + L + H", "Shoulder Rush"],
		["DOWN + L + H", "Sky Uppercut"],
		["BACK + L + H", "TEMPLATE FINISH"],
	]

	# --- Signature poses --------------------------------------------------
	# Angles are degrees, merged on top of the shared pose of the same name.
	poses = {
		"intro": {"arm_f": 155, "elb_f": 20, "arm_b": 35, "elb_b": 95, "lean": -5},
		"win": {"arm_f": 140, "elb_f": 120, "arm_b": 30, "elb_b": 100, "head": 12},
	}

	# --- Moves ------------------------------------------------------------
	# All ten keys are required: six normals, three specials and one hyper.
	#
	# Frame data is in 60ths of a second:
	#   startup  - frames before the hitbox exists (low = fast, hard to punish)
	#   active   - frames the hitbox is out
	#   recovery - frames you are stuck afterwards (the cost of whiffing)
	# hitbox is a Rect2 in local pixels, measured from the fighter's feet, with
	# negative Y going up and positive X being forward. So Rect2(13, -94, 47, 23)
	# is a box starting 13px in front, 94px up, 47 wide and 23 tall.
	#
	# Animation: the simple form is `pose_s` (held during startup) and `pose_a`
	# (snapped to on the active frame). For something nicer, use a `keys` clip:
	#   "keys": [[0, {...}, 0.5], [4, {...}, 0.8], [9, {...}, 0.45]]
	# which is [frame, pose, approach speed]. And `events` fires FX and sounds
	# at authored frames. The event kinds are:
	#   ["slash", {"r": 30.0}]              a swoosh sized to the hitbox
	#   ["fx", {"kind": "spark", ...}]      any effect from effects.gd
	#   ["dust", {"offset": Vector2(30, 0)}] a puff at ground level
	#   ["sfx", {"name": "whoosh", "pitch": 1.0}]
	#   ["voice", {"line": "heavy"}]
	#   ["shake", {"amount": 3.0}]
	# `offset` is in the fighter's own space, facing right, like a hitbox:
	#   "events": {6: [["slash", {}], ["sfx", {"name": "whoosh"}]]}
	moves = {
		# Light: your fast poke. Keep startup at 4 and recovery short.
		"L": MoveData.make({
			"id": "quick palm", "startup": 4, "active": 3, "recovery": 8, "damage": 40,
			"hitbox": Rect2(13, -92, 48, 23), "hitstun": 14, "blockstun": 9,
			"kb": Vector2(2, 0), "meter": 4.0,
			"pose_s": {"arm_f": 55, "elb_f": 105, "lean": 9},
			"pose_a": {"arm_f": 92, "elb_f": 0, "lean": 15, "arm_b": 30, "elb_b": 110},
		}),
		# Heavy: the launcher that starts air combos. `launch` plus upward kb.
		"H": MoveData.make({
			"id": "lift strike", "level": 1, "startup": 9, "active": 4, "recovery": 18, "damage": 90,
			"hitbox": Rect2(10, -148, 58, 86), "launch": true, "kb": Vector2(1.5, -10.5),
			"hitstun": 30, "blockstun": 16, "hitstop": 8, "meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"arm_f": 20, "elb_f": 60, "lean": 12},
			"pose_a": {"arm_f": 170, "elb_f": 0, "lean": -14, "arm_b": -10},
		}),
		# Crouching light: hits low, so it beats a standing block.
		"cL": MoveData.make({
			"id": "low jab", "crouch": true, "startup": 4, "active": 3, "recovery": 8, "damage": 35,
			"hitbox": Rect2(13, -52, 49, 23), "hitstun": 14, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 85, "elb_f": 0},
		}),
		# Crouching heavy: the sweep. `knockdown` puts them on the floor.
		"cH": MoveData.make({
			"id": "sweep", "crouch": true, "level": 1, "startup": 8, "active": 5, "recovery": 20,
			"damage": 80, "hitbox": Rect2(8, -26, 82, 26), "knockdown": true, "kb": Vector2(2, -4),
			"hitstop": 7, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 88, "knee_f": 0, "lean": -18, "arm_b": -30},
		}),
		# Jumping light: your air-to-air.
		"jL": MoveData.make({
			"id": "air palm", "air": true, "startup": 4, "active": 5, "recovery": 6, "damage": 42,
			"hitbox": Rect2(5, -84, 53, 39), "hitstun": 16, "blockstun": 9, "meter": 4.0,
			"pose_a": {"arm_f": 118, "elb_f": 0},
		}),
		# Jumping heavy: `spike` slams a juggled opponent back down.
		"jH": MoveData.make({
			"id": "air stomp", "air": true, "level": 1, "startup": 7, "active": 5, "recovery": 10,
			"damage": 80, "hitbox": Rect2(3, -68, 64, 47), "spike": true, "hitstun": 18,
			"blockstun": 12, "kb": Vector2(3, 0), "hitstop": 8, "meter": 7.0, "hit_sfx": "heavy",
			"pose_a": {"leg_f": 100, "knee_f": 0, "leg_b": 20, "knee_b": 90, "lean": -10},
		}),
		# Special 1 — L+H at range. The fireball: it keeps the opponent honest.
		"proj": MoveData.make({
			"id": "palm blast", "display": "PALM BLAST", "level": 2, "startup": 13, "active": 1,
			"recovery": 20, "sfx": "whoosh",
			"projectile": {
				"kind": "spark", "speed": 7.5, "size": Vector2(24, 18), "offset": Vector2(48, -84),
				"life": 200, "damage": 70, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6,
				"meter": 8.0, "hit_sfx": "light",
			},
			"pose_s": {"arm_f": 40, "elb_f": 120, "lean": -6},
			"pose_a": {"arm_f": 95, "elb_f": 0, "lean": 14},
		}),
		# Special 2 — FWD + L+H. The rush: `dash_speed` carries you forward
		# between `dash_from` and `dash_to`.
		"rush": MoveData.make({
			"id": "shoulder rush", "display": "SHOULDER RUSH", "level": 2, "startup": 6, "active": 18,
			"recovery": 14, "damage": 60, "hits": 2, "hit_interval": 9,
			"hitbox": Rect2(-10, -118, 66, 110), "dash_speed": 7.2, "dash_from": 6, "dash_to": 24,
			"knockdown": true, "kb": Vector2(3, -5), "hitstun": 20, "blockstun": 12, "chip": 0.15,
			"hitstop": 6, "meter": 8.0, "hit_sfx": "heavy",
			"pose_s": {"lean": 22, "arm_f": 30, "elb_f": 120, "arm_b": -20},
			"pose_a": {"lean": 30, "arm_f": 10, "elb_f": 20, "arm_b": -40, "leg_f": 40, "knee_f": 20},
		}),
		# Special 3 — DOWN + L+H. The anti-air: `invuln` frames plus `rise_vel`
		# make it the answer to a jump-in.
		"anti": MoveData.make({
			"id": "sky uppercut", "display": "SKY UPPERCUT", "level": 2, "startup": 3, "active": 14,
			"recovery": 18, "damage": 46, "hits": 3, "hit_interval": 5,
			"hitbox": Rect2(-6, -150, 78, 122), "rise_vel": Vector2(0.8, -11.0), "rise_frame": 3,
			"invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0), "hitstun": 30, "blockstun": 12,
			"chip": 0.15, "hitstop": 5, "meter": 8.0, "hit_sfx": "light",
			"pose_s": {"leg_f": 55, "knee_f": 100, "lean": 8},
			"pose_a": {"arm_f": 175, "elb_f": 0, "arm_b": -20, "lean": -12, "leg_b": -30},
		}),
		# Hyper — BACK + L+H, costs a meter level. Big, invulnerable, loud.
		"hyper": MoveData.make({
			"id": "template finish", "display": "TEMPLATE FINISH!", "level": 3, "startup": 18,
			"active": 1, "recovery": 40, "invuln": 42, "sfx": "magic",
			"projectile": {
				"kind": "beam", "speed": 9.0, "size": Vector2(120, 70), "offset": Vector2(60, -80),
				"life": 160, "hits": 8, "interval": 6, "damage": 34, "hitstun": 18,
				"kb": Vector2(5, 0), "chip": 0.2, "hitstop": 3, "meter": 0.0, "level": 3,
				"final_knockdown": true, "strength": 99, "sfx": "hyper",
			},
			"pose_s": {"arm_f": 30, "elb_f": 140, "arm_b": 20, "elb_b": 140, "lean": -10},
			"pose_a": {"arm_f": 95, "elb_f": 0, "arm_b": 95, "elb_b": 0, "lean": 16},
		}),
	}

	# If you changed `size` above, uncomment this so hitboxes match the body:
	# scale_moves()


## Optional. Called every frame to drive dangling parts (hair, capes, scarves)
## with the built-in spring chains. Delete if your fighter has none.
#func update_chains(r: FighterRenderer, s: Dictionary) -> void:
#	r.chain("ponytail", FighterRenderer.head_point(s, Vector2(-8, -10)), 7, 5.0, 0.3, 0.86, 0.15)


## Optional. Drawn behind the body — capes, tails, back-mounted gear.
#func draw_behind(r: FighterRenderer, _s: Dictionary) -> void:
#	r.ribbon(r.chain_local("ponytail"), 8.0, 1.5, r.colors["hair"])


## Optional. Drawn in front of the body — headbands, goggles, held props.
#func draw_front(r: FighterRenderer, _s: Dictionary) -> void:
#	pass
