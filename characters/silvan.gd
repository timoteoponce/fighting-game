class_name SilvanDef
extends CharacterDef
## Silvan: two years old, in pants and little boots, and somehow part puppy. He
## can't reach far and he can't hit hard, but nobody on the roster runs or jumps
## like he does. The archetype gap: a tiny, relentless pest.


func _init() -> void:
	id = "silvan"
	display = "SILVAN"
	likes = "Jumping, running, puppies, snack time"
	win_quote = "Good dog! ...I am a good dog!"
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
		# The star on his tee. The portrait has a big orange one and the game
		# never drew it.
		"star": Color("f08a3c"), "white": Color("e6e0d2"),
	}
	# Player 2 is the "were-puppy" palette: darker fur, green shirt.
	alt_colors = colors.duplicate()
	alt_colors.merge({
		"shirt": Color("b6e36f"), "sleeve": Color("b6e36f"), "hair": Color("3a2a22"),
		"fur": Color("54402f"), "accent": Color("ff8ac4"), "eyes": Color("c8a13a"),
		"pants": Color("2a4e86"), "legs": Color("2a4e86"), "shoes": Color("3a2a22"),
		"star": Color("ffd24a"), "white": Color("dcd6c6"),
	}, true)
	# Fastest walk and highest jump on the roster; everything else is a trade
	# against that. He is meant to be hard to pin down, not hard to survive.
	walk_speed = 4.1
	back_speed = 3.4
	jump_vel = -12.4
	jump_x = 4.5
	voice_pitch = 430.0  # a two-year-old's shriek
	win_prop = "bone_win"
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
		# Both arms straight up, hands open, exactly the pose the portrait
		# catches him in. The `bone_win` prop keeps the bone in one hand.
		"win": {"arm_f": 172, "elb_f": 8, "arm_b": 168, "elb_b": 14, "head": 14,
			"leg_f": 30, "knee_f": 20, "leg_b": -26, "knee_b": 22, "lean": -5},
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


## A very round toddler skull, nose to the right: wide cheeks, a low soft chin,
## and everything sitting low because he is two. The shared circle reads as a
## generic head, not a baby's.
func head_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-1.6, -12.4), Vector2(3.4, -11.6), Vector2(7.4, -8.8), Vector2(9.6, -4.6),
		Vector2(10.2, 0.4), Vector2(9.2, 4.6), Vector2(6.8, 7.4), Vector2(3.2, 8.8),
		Vector2(-0.4, 9.0), Vector2(-3.8, 7.8), Vector2(-6.8, 5.2), Vector2(-9.0, 1.4),
		Vector2(-10.0, -2.8), Vector2(-9.0, -7.4), Vector2(-6.0, -11.4),
	])


## A loose tee on a toddler, so this is soft and barely tapered — no waist, no
## shoulder line. Width follows the roundedness of the frame.
func torso_outline(_r: FighterRenderer, s: Dictionary) -> PackedVector2Array:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var b := build
	var pts := PackedVector2Array()
	for f in [[0.0, 5.4], [0.34, 6.0], [0.68, 7.4], [0.90, 7.6], [1.0, 5.8],
			[1.0, -5.4], [0.88, -7.2], [0.56, -5.8], [0.0, -5.0]]:
		pts.append(hip + up * FighterRenderer.TORSO * float(f[0]) + perp * float(f[1]) * b)
	return pts


func update_chains(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	# A curly tail that trails behind him, and two floppy ears that swing off
	# the head. The springs do all the animation work for free.
	r.chain("tail", s["hip"] - perp * 5.0 + up * 2.0, 6, 4.0, -0.22, 0.86, 0.22)
	# Hanging *below* the skull, not anchored inside it. At (6,-9) and (-7,-8) the
	# roots sat on the crown and the ribbons then fell straight across his face;
	# these start at the temples so the ears hang beside the cheeks.
	r.chain("ear_f", FighterRenderer.head_point(s, Vector2(9.0, -2.0)), 5, 4.2, 0.5, 0.82, 0.3)
	r.chain("ear_b", FighterRenderer.head_point(s, Vector2(-9.4, -1.0)), 5, 4.2, 0.5, 0.82, 0.3)


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
	# The one stubborn sprout on top, which the portrait has.
	r.draw_line(Vector2(1, -15), Vector2(3, -21), hc, 1.6, true)
	r.draw_line(Vector2(3, -21), Vector2(6, -19), hc, 1.4, true)


## Brown calf boots, the way the portrait has them, in place of the shared
## slipper. He is two and standing in grown-up boots, which is the joke.
func draw_shoe(r: FighterRenderer, foot: Vector2, fwd: Vector2, col: Color) -> void:
	if fwd.length_squared() < 0.001:
		fwd = Vector2.RIGHT
	fwd = fwd.normalized()
	var up := Vector2(fwd.y, -fwd.x)
	r.shaded_poly(PackedVector2Array([
		foot - fwd * 2.8 + up * 5.0, foot + fwd * 0.8 + up * 5.0, foot + fwd * 4.6 + up * 4.4,
		foot + fwd * 6.8 - up * 0.2, foot + fwd * 6.4 - up * 1.6, foot - fwd * 3.0 - up * 1.6,
	]), col, 1.0, 0.8)
	# Sole, then the fold at the top of the boot shaft.
	r.draw_line(foot - fwd * 2.8 - up * 1.2, foot + fwd * 6.6 - up * 1.2, col.darkened(0.3), 1.2, true)
	r.draw_line(foot - fwd * 2.6 + up * 4.6, foot + fwd * 0.6 + up * 4.6, col.darkened(0.2), 1.3, true)


## Tiny hands. He cheers with them open, and a toddler's fist is mostly a
## rounded mitt anyway, so both shapes stay soft.
##
## The shared hand selection is `open := expr == "happy" or expr == "smug"`, so
## a win expression would draw a closed fist — which is why the win prop forces
## the open hand here. The portrait catches him with both arms up and his
## fingers spread.
func draw_hand(r: FighterRenderer, p: Vector2, col: Color, d: Vector2, front: bool, open: bool) -> void:
	if r.prop == "bone_win":
		# The bone is held in the front hand, so that one stays a paw around it.
		if not front:
			r.open_hand(p, col, d)
		else:
			_paw(r, p, col, d)
		return
	if open:
		r.open_hand(p, col, d)
	else:
		_paw(r, p, col, d)


func _paw(r: FighterRenderer, p: Vector2, col: Color, d: Vector2) -> void:
	if d.length_squared() < 0.001:
		d = Vector2.DOWN
	d = d.normalized()
	var n := Vector2(-d.y, d.x)
	var sh := FighterRenderer.shade(col)
	r.shaded_poly(PackedVector2Array([
		p - n * 2.2 - d * 0.6, p + n * 2.2 - d * 0.6, p + n * 2.0 + d * 1.3,
		p + n * 1.3 + d * 2.7, p - n * 1.3 + d * 2.7, p - n * 2.0 + d * 1.3,
	]), col, 1.0, 0.82)
	# Three soft knuckle bumps, enough to read as fingers and not as a stone.
	for k: float in [-1.2, 0.0, 1.2]:
		r.draw_line(p + n * k + d * 1.4, p + n * k + d * 2.5, sh, 0.5, true)
	r.part(p + n * 1.7 - d * 0.2, p + n * 0.4 + d * 2.0, 1.3, 1.1, col)


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	# The orange star on the tee, which the portrait has and the game never drew.
	# Kept small and flat: at 4.6 it read as a second emblem on his chest.
	r.poly(FighterRenderer.star_pts(hip + up * (FighterRenderer.TORSO * 0.48) + perp * 1.0, 3.2, 1.4), r.colors["star"], 0.9)
	# Neckline, so the tee reads as a garment and not a painted torso.
	r.draw_line(hip + up * FighterRenderer.TORSO + perp * 3.6 - up * 0.8,
		hip + up * FighterRenderer.TORSO - perp * 3.6 - up * 0.8, r.colors["skin"], 1.4, true)
	# A soft fold at the hem, the only wrinkle a two-year-old's tee has.
	r.draw_line(hip + perp * 4.4 + up * 1.8, hip - perp * 4.4 + up * 1.8, r.colors["shirt"].darkened(0.16), 1.3, true)


## The big anime eyes, kept: the round dot eye is exactly right for a two-year
## old and the portrait confirms it. Scaled up, and carrying the whole expression
## vocabulary through eye_style so he is not a permanent stare.
func draw_face(r: FighterRenderer) -> void:
	_eyes(r)
	_brows(r)
	_nose(r)
	_mouth(r)


## Eye centres in head space, low and wide, because he is two.
func eye_spots() -> Array:
	return [Vector2(2.2, 1.4), Vector2(7.6, 1.0)]


func _eyes(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(2.2, 1.4), Vector2(7.6, 1.0)]
	var ink := FighterRenderer.OUT
	var style := eye_style(r.expr, r.t)
	var pop := 1.0 + 0.6 * (float(r.eye_pop) / 9.0)
	var g := Vector2.ZERO if r.expr in ["ko", "dizzy", "hurt"] else r.gaze.limit_length(1.0)
	for i in 2:
		var e: Vector2 = spots[i]
		var near := 0.86 if i == 1 else 1.0
		if style == "happy":
			r.draw_arc(e + Vector2(0, 0.9), 2.4 * near, PI, TAU, 8, ink, 1.6, true)
			continue
		if style == "ko":
			var rad := 2.2 * near
			r.draw_line(e + Vector2(-rad, -rad * 0.8), e + Vector2(rad, rad * 0.8), ink, 1.6, true)
			r.draw_line(e + Vector2(rad, -rad * 0.8), e + Vector2(-rad, rad * 0.8), ink, 1.6, true)
			continue
		if style == "dizzy":
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, 2.4 * near, 2.0 * near, 0.0, 10), r.colors["white"])
			r.draw_arc(e, 2.4 * near, 0.0, TAU, 10, ink, 0.9, true)
			r.draw_circle(e + Vector2.from_angle(r.t * 0.15 + float(i)) * 0.8 * near, 0.6, ink)
			continue
		var sc := near * pop
		if style == "blink":
			r.draw_line(e + Vector2(-3.0 * sc, 0.3), e + Vector2(2.9 * sc, 0.15), ink, 1.4, true)
			continue
		# A toddler eye: big round white, a big dark iris, one catchlight.
		# The squint barely registers on a baby, so it stays high.
		var squint := 1.0
		var iris := 1.9
		match r.expr:
			"attack":
				squint = 0.7
			"hurt":
				squint = 0.75
			"shock":
				squint = 1.1
				iris = 2.1
			"smug":
				squint = 0.55 if i == 1 else 0.8
		var rr := maxf(1.1, 3.2 * sc * clampf(squint, 0.55, 1.15))
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, rr, rr * 1.02, 0.0, 12), r.colors["white"])
		r.draw_polyline(Stage._closed(FighterRenderer.ellipse_pts(e, rr, rr * 1.02, 0.0, 12)), ink, 1.3, true)
		var p := e + g * rr * 0.4
		r.draw_circle(p, iris * sc, r.colors["eyes"])
		r.draw_circle(p + g * 0.2, iris * 0.52 * sc, ink)
		r.draw_circle(p + Vector2(-iris * 0.36, -iris * 0.36) * sc, 0.34, Color.WHITE)


## Light brows, because he is a happy two-year-old until he isn't.
func _brows(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(2.2, 1.4), Vector2(7.6, 1.0)]
	for i in 2:
		var e: Vector2 = spots[i]
		var y := -4.4
		var inner := 0.4
		match r.expr:
			"attack":
				inner = 1.2
			"hurt", "shock", "ko", "dizzy":
				y = -5.2
				inner = -0.4
		var rx := 2.3
		var a := e + Vector2(-rx, y - inner)
		var b := e + Vector2(rx * 0.85, y)
		if i == 1:
			a = e + Vector2(-rx * 0.85, y)
			b = e + Vector2(rx, y - inner)
		r.draw_line(a, b, FighterRenderer.OUT, 1.2, true)


## The puppy nose and two dots of blush, which is most of the character.
func _nose(r: FighterRenderer) -> void:
	var sh: Color = warm_shade(r.colors["skin"], 0.16)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(5.2, 4.2), 1.7, 1.2), r.colors["nose"])
	r.draw_arc(Vector2(5.2, 4.6), 0.8, 0.3, PI - 0.3, 6, sh, 0.5, true)
	for cx: float in [-3.0, 7.4]:
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(cx, 4.6), 1.9, 1.1), Color(1, 0.55, 0.6, 0.4))
	# The floppy front ear hangs over the face, like the portrait.
	var ear := r.chain_local("ear_f")
	if ear.size() > 1:
		r.ribbon(ear, 7.0, 4.0, r.colors["fur"])


## The open grin with the tongue out, which the portrait has and the game
## declared a colour for and then never drew. A squiggle when dizzy and a lopsided
## line when smug, so it is not one shape all match.
func _mouth(r: FighterRenderer) -> void:
	var m := Vector2(3.4, 6.2)
	var ink := Color(0.45, 0.12, 0.12)
	if r.expr == "dizzy":
		var w := PackedVector2Array()
		for wi in 5:
			w.append(m + Vector2(-2.0 + float(wi) * 1.0, 0.5 + (0.7 if wi % 2 == 0 else -0.7)))
		r.draw_polyline(w, ink, 1.1, true)
		return
	if r.expr == "smug":
		r.draw_line(m + Vector2(-1.5, 0.35), m + Vector2(1.6, -0.5), ink, 1.1, true)
		return
	# The open happy mouth, with the tongue, on everything warm.
	r.draw_colored_polygon(PackedVector2Array([
		m + Vector2(-1.9, -0.6), m + Vector2(1.9, -0.7), m + Vector2(1.4, 1.8), m + Vector2(-1.4, 1.7),
	]), ink)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(m + Vector2(0.1, 1.3), 1.0, 0.8), r.colors["tongue"])


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	match r.prop:
		"bone":
			# Held up in the right hand like a trophy.
			var c: Vector2 = s["hand_f"] + Vector2(0, -3)
			var bone := Color("fff3d8")
			r.part(c + Vector2(-8, 0), c + Vector2(8, 0), 4.0, 4.0, bone)
			for e in [-9.0, 9.0]:
				r.ball(c + Vector2(e, -3), 2.6, bone)
				r.ball(c + Vector2(e, 3), 2.6, bone)
		"bone_win":
			# His celebration: the portrait's pose, both arms up, and the bone
			# held high in one hand as a trophy.
			var wc: Vector2 = s["hand_f"] + Vector2(0, -3)
			var wbone := Color("fff3d8")
			r.part(wc + Vector2(-8, 0), wc + Vector2(8, 0), 4.0, 4.0, wbone)
			for e: float in [-9.0, 9.0]:
				r.ball(wc + Vector2(e, -3), 2.6, wbone)
				r.ball(wc + Vector2(e, 3), 2.6, wbone)
			# A happy waggle of the tail, because the portrait is mid-wag.
			var tail := r.chain_local("tail")
			if tail.size() > 1:
				r.ribbon(tail, 7.0, 3.0, r.colors["fur"].lightened(0.12))
		"moon":
			# A low moon rises behind him while he howls.
			var m: Vector2 = s["head"] + Vector2(-26, -34)
			var t := minf(r.prop_t / 18.0, 1.0)
			var rad := 13.0 * t
			r.draw_circle(m, rad + 3.0, Color(0.85, 0.9, 1.0, 0.20 * t))
			r.draw_circle(m, rad, Color(0.96, 0.97, 1.0, 0.9 * t))
			for spot in [Vector2(-4, -3), Vector2(3, 2), Vector2(-1, 5)]:
				r.draw_circle(m + spot * t, 2.0 * t, Color(0.82, 0.85, 0.95, 0.9 * t))
