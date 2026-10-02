class_name EmiliaDef
extends CharacterDef
## Emilia: magic wand, anime, drawing and aerobics. Jumps high, long-range spark.


func _init() -> void:
	id = "emilia"
	display = "EMILIA"
	likes = "Wizard stories, anime, drawing, aerobics"
	win_quote = "Page forty-one: you lose!"
	gag_items = ["pencil", "star", "note"]
	taunt_lines = ["ABRACADABRA!", "SPARKLE!", "DRAW THIS!"]
	hurt_lines = ["EEK!", "MY PENCIL!", "RUDE!"]
	# "white" is a warm off-white, not Color.WHITE. shaders/post_fx.gdshader blooms
	# anything above luminance 0.90, so a true white fill blooms, glows and loses
	# its ink edge. The old blouse was fff4fa at 0.972, a large fill, and it read
	# as a glowing hole in her chest. The wand tip keeps pure white on purpose:
	# it is a magic spark and should sparkle, like a catchlight.
	colors = {
		"skin": Color("f5cfb0"), "hair": Color("2e1a2a"), "shirt": Color("7b3fd1"), "sleeve": Color("7b3fd1"),
		"forearm": Color("f5cfb0"), "hands": Color("f5cfb0"), "pants": Color("4b2a8a"), "legs": Color("4b2a8a"),
		"shoes": Color("5a2a6e"), "eyes": Color("4a2a22"), "accent": Color("ff7eb6"), "skirt": Color("4b2a8a"),
		"trim": Color("ffd24a"), "cape": Color("3b1f6e"), "blouse": Color("e6e0d2"), "boots": Color("5a2a6e"),
		"white": Color("e6e0d2"),
	}
	alt_colors = colors.duplicate()
	alt_colors.merge({"shirt": Color("1fa3a3"), "sleeve": Color("1fa3a3"), "accent": Color("ffd24a"),
		"skirt": Color("12706f"), "pants": Color("12706f"), "legs": Color("12706f"),
		"shoes": Color("3a2a10"), "boots": Color("3a2a10"), "eyes": Color("8a4a1a"), "cape": Color("0d4a4a"),
		"blouse": Color("dcd6c6"), "white": Color("dcd6c6")}, true)
	walk_speed = 3.3
	back_speed = 2.7
	jump_vel = -11.6
	jump_x = 3.5
	voice_pitch = 330.0
	roster_order = 1
	# A smaller head than the chibi default, and a narrow build: the puff
	# sleeves and the cape are meant to sit on a slim frame, not the shared
	# wide wedge.
	head_scale = 1.24
	build = 0.8
	win_prop = "sketch_win"
	intro_prop = "sparkle"
	specials_text = [
		["L + H", "Wand Spark"],
		["FWD + L + H", "Cartwheel Rush"],
		["DOWN + L + H", "Star Jump"],
		["BACK + L + H", "SKETCHBOOK SUMMON"],
	]
	poses = {
		"intro": {"arm_f": 165, "elb_f": 10, "arm_b": 25, "elb_b": 110, "lean": -6},
		# The portrait's pose: wand up in one hand, the other on her hip, and
		# her chin lifted. The sketch_win prop draws the page beside the wand.
		"win": {"arm_f": 158, "elb_f": 12, "arm_b": 34, "elb_b": 108, "leg_f": 24, "knee_f": 12,
			"leg_b": -20, "knee_b": 14, "head": -6, "lean": -3},
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
			"recovery": 20, "prop": "cast", "sfx": "whoosh", "flash": 3, "shake": 1.0,
			"projectile": {"kind": "spark", "speed": 8.0, "size": Vector2(22, 16), "offset": Vector2(49, -83), "life": 200,
				"damage": 72, "hitstun": 20, "kb": Vector2(3, 0), "hitstop": 6, "meter": 8.0, "sfx": "magic", "hit_sfx": "light"},
			"pose_s": {"arm_f": 150, "elb_f": 30, "lean": -8}, "pose_a": {"arm_f": 92, "elb_f": 0, "lean": 12}}),
		"rush": MoveData.make({"id": "cartwheel rush", "display": "CARTWHEEL RUSH", "level": 2, "startup": 6, "active": 20,
			"recovery": 12, "damage": 58, "hits": 2, "hit_interval": 9, "hitbox": Rect2(-13, -120, 68, 114),
			"dash_speed": 7.5, "dash_from": 6, "dash_to": 26, "knockdown": true, "kb": Vector2(3, -5), "hitstun": 20,
			"blockstun": 12, "chip": 0.15, "hitstop": 6, "meter": 8.0, "spin": 360.0, "hit_sfx": "heavy",
			"flash": 4, "shake": 2.0,
			"pose_s": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "lean": 15},
			"pose_a": {"arm_f": 170, "elb_f": 0, "arm_b": 190, "elb_b": 0, "leg_f": 35, "knee_f": 0, "leg_b": -35, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -58}}),
		"anti": MoveData.make({"id": "star jump", "display": "STAR JUMP", "level": 2, "startup": 3, "active": 14,
			"recovery": 16, "damage": 45, "hits": 3, "hit_interval": 5, "hitbox": Rect2(-39, -151, 107, 125),
			"rise_vel": Vector2(0.5, -11.0), "rise_frame": 3, "invuln": 8, "launch": true, "kb": Vector2(1.0, -8.0),
			"hitstun": 30, "blockstun": 12, "chip": 0.15, "hitstop": 5, "meter": 8.0, "prop": "sparkle", "hit_sfx": "light",
			"flash": 3, "shake": 1.5,
			"pose_s": {"leg_f": 60, "knee_f": 100, "leg_b": 20, "knee_b": 100},
			"pose_a": {"arm_f": 150, "elb_f": 0, "arm_b": 210, "elb_b": 0, "leg_f": 40, "knee_f": 0, "leg_b": -40, "knee_b": 0,
				"lean": 0, "ground": 0, "hip": -46}}),
		"hyper": MoveData.make({"id": "sketchbook summon", "display": "SKETCHBOOK SUMMON!", "level": 3, "startup": 20, "active": 1,
			"recovery": 40, "invuln": 45, "prop": "sketch", "sfx": "magic", "flash": 5, "shake": 2.0,
			"projectile": {"kind": "dragon", "speed": 6.5, "size": Vector2(130, 120), "offset": Vector2(65, -78), "life": 170,
				"hits": 10, "interval": 6, "damage": 32, "hitstun": 18, "kb": Vector2(5, 0), "chip": 0.2, "hitstop": 3,
				"meter": 0.0, "level": 3, "final_knockdown": true, "strength": 99, "sfx": "hyper"},
			# She floats for the cut-in, sketchbook open above her, both feet off
			# the floor — a wizard summoning, not a kid holding a stance.
			"cutin_pose": {"lean": -6, "head": -20, "arm_f": 168, "elb_f": 30, "arm_b": 150, "elb_b": 45,
				"leg_f": 34, "knee_f": 40, "leg_b": -26, "knee_b": 34, "ground": 0, "hip": -58},
			"keys": [
				# Reaches up and back, heels lifting off the floor...
				[0, {"lean": -4, "head": -18, "arm_f": 160, "elb_f": 35, "arm_b": 145, "elb_b": 50,
					"leg_f": 28, "knee_f": 34, "leg_b": -20, "knee_b": 28, "ground": 0, "hip": -52}, 0.5],
				# ...then throws the page forward and drops back onto one leg.
				[18, {"lean": 6, "head": 2, "arm_f": 108, "elb_f": 10, "arm_b": 128, "elb_b": 20,
					"leg_f": 52, "knee_f": 30, "leg_b": -44, "knee_b": 52, "ground": 0, "hip": -50}, 0.95],
				[44, {"lean": 0, "head": -4, "arm_f": 96, "elb_f": 25, "arm_b": 118, "elb_b": 35,
					"leg_f": 40, "knee_f": 40, "leg_b": -34, "knee_b": 46, "ground": 0, "hip": -54}, 0.4],
				[58, {"lean": 4, "head": 0, "arm_f": 40, "elb_f": 90, "arm_b": 50, "elb_b": 95}, 0.35],
			],
			# The dragon is through them: she flings the page after it.
			"contact_pose": {"lean": 14, "head": 6, "arm_f": 118, "elb_f": 0, "arm_b": 136, "elb_b": 6,
				"leg_f": 62, "knee_f": 34, "leg_b": -52, "knee_b": 58, "ground": 0, "hip": -48}}),
	}


## Connected chain: an odd hit is the authored front limb, an even hit is the
## other one, so a light-light string reads as a one-two. Specials are left
## alone: her rising swirl and star jump already pose both arms.
func adjust_attack_pose(f: Fighter, m: MoveData, p: Dictionary) -> Dictionary:
	if m.level > 1 or f.chain % 2 == 1:
		return p
	return cross_limbs(p)


## A narrower head than the shared circle, with a small chin. The portrait is
## not a bobblehead. Smooth on purpose: a self-intersecting outline gets
## replaced by its convex hull and turns into a blob.
## Vertical layout: hairline -10.5, brow -4.4, eye 0.2, nose 3.2, mouth 5.8.
func head_outline() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-3.0, -11.8), Vector2(2.4, -11.2), Vector2(6.8, -8.4), Vector2(9.4, -4.2),
		Vector2(10.0, 0.6), Vector2(8.8, 4.4), Vector2(6.4, 7.2), Vector2(2.8, 9.0),
		Vector2(-0.6, 9.4), Vector2(-3.8, 8.2), Vector2(-6.4, 5.4), Vector2(-8.8, 1.0),
		Vector2(-9.8, -3.6), Vector2(-8.2, -8.2), Vector2(-5.6, -11.0),
	])


## Her own torso, in torso space: `up` is shoulder-ward, `perp` is forward. The
## portrait is slim under a cape, so this is narrower than the shared wedge and
## tapers to a waist, with the blouse puffing slightly at the chest.
func torso_outline(_r: FighterRenderer, s: Dictionary) -> PackedVector2Array:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var b := build
	var pts := PackedVector2Array()
	for f in [[0.0, 5.0], [0.34, 5.4], [0.66, 7.0], [0.88, 7.6], [1.0, 5.4],
			[1.0, -5.4], [0.86, -7.2], [0.55, -5.4], [0.0, -4.6]]:
		pts.append(hip + up * FighterRenderer.TORSO * float(f[0]) + perp * float(f[1]) * b)
	return pts


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
		# The portrait's cape is trimmed in gold along the hem, not in the pink
		# of her scarf. That was the old lining colour.
		var lining := FighterRenderer.ribbon_pts(cape.slice(cape.size() - 2), 17.0, 20.0)
		r.draw_colored_polygon(lining, r.colors["trim"].darkened(0.1))
	for name in ["tail2", "tail1"]:
		var tail := r.chain_local(name)
		r.ribbon(tail, 8.0, 1.5, r.colors["hair"])
		if tail.size() > 0:
			r.ball(tail[0], 2.4, r.colors["accent"])
	var scarf := r.chain_local("scarf")
	if scarf.size() > 1:
		r.ribbon(scarf, 5.0, 4.0, r.colors["accent"])
		for i in range(1, scarf.size(), 2):
			r.draw_circle(scarf[i], 1.6, r.colors["white"], true, -1.0, true)


func draw_torso(r: FighterRenderer, s: Dictionary) -> void:
	var up: Vector2 = s["up"]
	var perp: Vector2 = s["perp"]
	var hip: Vector2 = s["hip"]
	var top: Vector2 = hip + up * FighterRenderer.TORSO
	var trim: Color = r.colors["trim"]
	# The blouse front, inset from the torso so the puff sleeves read as separate.
	r.draw_colored_polygon(PackedVector2Array([
		top + perp * 4.2 - up * 2.2, top - perp * 3.6 - up * 2.2,
		hip + perp * 3.4 + up * 11.0, hip - perp * 2.4 + up * 11.0,
	]), r.colors["blouse"])
	# Robe lapels and gold trim.
	r.draw_line(top + perp * 5.0 - up * 1.0, hip + perp * 6.0 + up * 12.0, trim, 1.8, true)
	r.draw_line(top - perp * 1.0 - up * 1.0, hip + perp * 2.6 + up * 12.0, trim, 1.4, true)
	# Belt.
	r.limb(hip - perp * 6.0 + up * 4.0, hip + perp * 6.0 + up * 4.0, 4.2, 4.2, r.colors["cape"])
	r.draw_colored_polygon(FighterRenderer.star_pts(hip + perp * 3.6 + up * 4.0, 3.0, 1.3), trim)
	# Scarf wrapped around the neck.
	var n: Vector2 = top - up * 1.5
	r.limb(n - perp * 5.4, n + perp * 5.4, 5.4, 5.4, r.colors["accent"])
	r.draw_line(n - up * 1.0, n + up * 1.5, r.colors["white"], 1.4, true)


## A short puff sleeve, in place of the shared one. The renderer used to
## hardcode `puff = 1.35` for her id; a hook draws it like everyone else's cuff
## instead, and on both arms rather than only the front one.
##
## It has to be *wider* than the plain sleeve it sits on top of, or it hides
## inside it and reads as no puff at all.
func _puff_sleeve(r: FighterRenderer, sh: Vector2, elb: Vector2, col: Color) -> void:
	var d := elb - sh
	if d.length() < 1.0:
		return
	var u := d.normalized()
	var n := Vector2(-u.y, u.x)
	var p := sh + u * 5.0
	r.shaded_poly(PackedVector2Array([
		sh + n * 5.4 - u * 1.4, sh - n * 5.4 - u * 1.4, p - n * 4.4, p + n * 4.4,
	]), col, 1.5, 0.88)
	# The white cuff at the hem, the way the portrait's puff sleeve ends.
	r.draw_line(p - n * 4.4, p + n * 4.4, r.colors["white"], 1.5, true)


## Full-length wide trousers, which is what the portrait wears, in place of the
## flared skirt the game has always drawn. Wide all the way down, with the gold
## wavy trim the painting has at the hem.
func draw_over_legs(r: FighterRenderer, s: Dictionary) -> void:
	var cloth: Color = r.colors["skirt"]
	var trim: Color = r.colors["trim"]
	# Back leg first, so the front leg overlaps it.
	for leg in [["hip_b", "knee_b", "foot_b", 0.84], ["hip_f", "knee_f", "foot_f", 1.0]]:
		var hip: Vector2 = s[leg[0]]
		var knee: Vector2 = s[leg[1]]
		var foot: Vector2 = s[leg[2]]
		var hip_to_foot: Vector2 = foot - hip
		if hip_to_foot.length() < 1.0:
			continue
		var n := Vector2(-hip_to_foot.y, hip_to_foot.x).normalized()
		var depth: float = float(leg[3])
		# Trouser leg: from the hip, bulging slightly at the thigh, then
		# straight down to just above the ankle, so the boot still shows. The
		# old flared skirt reached 0.7 of the way to the foot and swallowed it.
		var thigh: Vector2 = hip.lerp(foot, 0.34)
		var ankle: Vector2 = foot - hip_to_foot.normalized() * 5.5
		r.shaded_poly(PackedVector2Array([
			hip + n * (4.2 * depth), hip - n * (4.2 * depth),
			thigh + n * (6.0 * depth), thigh - n * (6.0 * depth),
			ankle + n * (5.4 * depth), ankle - n * (5.4 * depth),
		]), cloth.darkened(0.10 * (1.0 - depth)), 1.7, 0.84)
		# Gold wavy trim at the hem, just above the ankle. A single zigzag
		# across the leg, not one stroke per column: drawn along `n` it
		# streaked down the front of the leg like two yellow bars.
		var hem: Vector2 = ankle - hip_to_foot.normalized() * 5.5
		var wav := PackedVector2Array()
		for wv in 7:
			var wx: float = lerpf(-4.6 * depth, 4.6 * depth, float(wv) / 6.0)
			wav.append(hem + n * wx + hip_to_foot.normalized() * (0.9 if wv % 2 == 0 else -0.9))
		r.draw_polyline(wav, trim, 1.1, true)
	# Boots at the ankle.
	for leg in [["knee_f", "foot_f", 1.0], ["knee_b", "foot_b", 0.8]]:
		var knee: Vector2 = s[leg[0]].lerp(s[leg[1]], 0.72)
		var foot: Vector2 = s[leg[1]]
		var boot: Color = r.colors["boots"].darkened(0.18 * (1.0 - float(leg[2])))
		r.limb(knee, foot, 8.4, 6.6, boot)


func draw_face(r: FighterRenderer) -> void:
	_ear(r)
	_eyes(r)
	_brows(r)
	_nose(r)
	_mouth(r)


## Eye centres in head space, nose to the right. The nose-side eye sits further
## right and slightly smaller, so the face has a 3/4 turn.
func eye_spots() -> Array:
	return [Vector2(3.0, 0.2), Vector2(7.6, -0.1)]


## Her eyes: a large anime almond, the biggest of the roster, but still on the
## five-shape budget because an eye is about six logical pixels in a fight.
## `expr` drives the shape through the shared `eye_style` vocabulary, so she
## blinks and gets X eyes on a KO instead of staring forever.
func _eyes(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(3.0, 0.2), Vector2(7.6, -0.1)]
	var ink := FighterRenderer.OUT
	var sclera: Color = r.colors["white"]
	var style := eye_style(r.expr, r.t)
	var pop := 1.0 + 0.6 * (float(r.eye_pop) / 9.0)
	var g := Vector2.ZERO if r.expr in ["ko", "dizzy", "hurt"] else r.gaze.limit_length(1.0)
	for i in 2:
		var e: Vector2 = spots[i]
		var near := 0.8 if i == 1 else 1.0
		if style == "happy":
			r.draw_arc(e + Vector2(0, 0.8), 2.2 * near, PI, TAU, 8, ink, 1.5, true)
			continue
		if style == "ko":
			var rad := 2.2 * near
			r.draw_line(e + Vector2(-rad, -rad * 0.8), e + Vector2(rad, rad * 0.8), ink, 1.6, true)
			r.draw_line(e + Vector2(rad, -rad * 0.8), e + Vector2(-rad, rad * 0.8), ink, 1.6, true)
			continue
		if style == "dizzy":
			r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, 2.1 * near, 1.8 * near, 0.0, 10), sclera)
			r.draw_arc(e, 2.1 * near, 0.0, TAU, 10, ink, 0.9, true)
			r.draw_circle(e + Vector2.from_angle(r.t * 0.15 + float(i)) * 0.7 * near, 0.55, ink)
			continue
		var sc := near * pop
		if style == "blink":
			r.draw_line(e + Vector2(-2.8 * sc, 0.3), e + Vector2(2.7 * sc, 0.15), ink, 1.3, true)
			continue
		# Squint hard on an attack: a scowl even at rest, and much lower when
		# she is going for it.
		var squint := 0.78
		var pupil := 0.34
		match r.expr:
			"attack":
				squint = 0.42
			"hurt":
				squint = 0.5
				pupil = 0.22
			"shock":
				squint = 1.1
				pupil = 0.18
			"smug":
				squint = 0.4 if i == 1 else 0.62
		var ry := maxf(0.9, 2.6 * sc * clampf(squint, 0.4, 1.15))
		var rx := 3.1 * sc
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(e, rx, ry, 0.0, 10), sclera)
		var ir := minf(rx * 0.5, ry * 0.95)
		var ic := e + g * rx * 0.16
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(ic, ir, ir * 0.9, 0.0, 8), r.colors["eyes"])
		r.draw_circle(ic + g * 0.1, maxf(0.4, ir * pupil * 1.3), ink)
		r.draw_circle(ic + Vector2(-ir * 0.36, -ir * 0.4), 0.3, Color.WHITE)
		r.draw_arc(e + Vector2(0, -ry * 0.15), rx * 0.94, PI + 0.35, TAU - 0.35, 8, ink, 0.95, true)


## The scowl, held at rest. Inner ends down toward the nose, which is what the
## portrait has; it deepens on an attack and lifts when she is hurt or shocked.
func _brows(r: FighterRenderer) -> void:
	var spots: Array[Vector2] = [Vector2(3.0, 0.2), Vector2(7.6, -0.1)]
	for i in 2:
		var e: Vector2 = spots[i]
		var y := -4.4
		var inner := 1.9
		match r.expr:
			"attack":
				inner = 2.5
			"hurt", "shock", "ko", "dizzy":
				y = -5.2
				inner = 0.4
			"smug":
				y = -4.8
				inner = 0.6
		var rx := 2.5
		var a := e + Vector2(-rx, y - inner)
		var b := e + Vector2(rx * 0.85, y)
		if i == 1:
			a = e + Vector2(-rx * 0.85, y)
			b = e + Vector2(rx, y - inner)
		r.draw_line(a, b, FighterRenderer.OUT, 1.5, true)


## A small nose inside the cheek at x 10.0, drawn as a warm shadow.
func _nose(r: FighterRenderer) -> void:
	var sh: Color = warm_shade(r.colors["skin"], 0.2)
	r.draw_colored_polygon(PackedVector2Array([
		Vector2(5.2, 0.6), Vector2(6.4, 2.4), Vector2(4.8, 3.0),
	]), sh)


## The mouth. A frown at rest, matching the scowl, but `dizzy` squiggles and
## `smug` goes lopsided rather than smiling through a knockdown.
func _mouth(r: FighterRenderer) -> void:
	var m := Vector2(4.4, 5.8)
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
	if r.expr == "hurt" or r.expr == "ko":
		r.draw_colored_polygon(FighterRenderer.ellipse_pts(m + Vector2(0.2, 0.3), 1.1, 1.4, 0.0, 10), ink)
		return
	if r.expr == "happy" or r.expr == "win":
		r.draw_colored_polygon(PackedVector2Array([
			m + Vector2(-1.8, -0.6), m + Vector2(1.8, -0.7), m + Vector2(1.3, 1.3), m + Vector2(-1.3, 1.2),
		]), ink)
		return
	# Rest: the frown. Two short strokes meeting low.
	r.draw_line(m + Vector2(-1.7, -0.6), m + Vector2(0.0, 0.4), FighterRenderer.OUT, 1.4, true)
	r.draw_line(m + Vector2(0.0, 0.4), m + Vector2(1.7, -0.5), FighterRenderer.OUT, 1.4, true)


## Her ear on the back edge of the cheek, below the hair.
func _ear(r: FighterRenderer) -> void:
	var skin: Color = r.colors["skin"]
	var c := Vector2(-7.4, 1.4)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(c, 1.4, 2.2, -0.2, 12), skin)
	r.draw_polyline(Stage._closed(FighterRenderer.ellipse_pts(c, 1.4, 2.2, -0.2, 12)), FighterRenderer.OUT, 0.85, true)


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
	# The gold star clip, which the portrait makes a feature of. It was a 3.6px
	# dot before; it is now a proper clip on the temple, in the gold trim.
	r.poly(FighterRenderer.star_pts(Vector2(8.5, -11.5), 5.2, 2.3), r.colors["trim"], 1.2)
	r.draw_circle(Vector2(8.5, -11.5), 1.0, r.colors["trim"].lightened(0.3))


func draw_props(r: FighterRenderer, s: Dictionary) -> void:
	# Puff sleeves on both arms. The back arm exists by the time draw_torso has
	# run, the front one by the time this does.
	_puff_sleeve(r, s["sh_b"], s["elb_b"], FighterRenderer.dk(r.colors["sleeve"]))
	_puff_sleeve(r, s["sh_f"], s["elb_f"], r.colors["sleeve"])
	if r.prop == "":
		return
	var hand: Vector2 = s["hand_f"]
	var d: Vector2 = (hand - s["elb_f"]).normalized()
	var tip := hand + d * 22.0
	r.draw_line(hand - d * 3.0, tip, FighterRenderer.OUT, 5.0, true)
	r.draw_line(hand - d * 3.0, tip, Color("8b5a2b"), 3.0, true)
	r.draw_line(hand - d * 2.0, hand + d * 6.0, Color("5a3620"), 3.0, true)
	# The wand tip keeps pure white: it is a magic spark and should sparkle.
	r.draw_circle(tip, 2.8 if r.prop == "cast" or r.prop == "sparkle" else 1.6, Color.WHITE, true, -1.0, true)
	if r.prop == "cast" or r.prop == "sparkle":
		r.draw_circle(tip, 9.0, Color(1, 0.6, 0.9, 0.3), true, -1.0, true)
		r.draw_colored_polygon(FighterRenderer.star_pts(tip, 6.0, 2.4, 4, r.t * 0.2), Color(1, 0.8, 0.95))
	if r.prop == "sparkle":
		for i in 4:
			var a := r.t * 0.08 + TAU * i / 4.0
			var p: Vector2 = s["head"] + Vector2(cos(a) * 32.0, sin(a) * 18.0 - 6.0)
			r.draw_colored_polygon(FighterRenderer.star_pts(p, 4.0, 1.6, 4, a), Color(1, 0.85, 0.3, 0.9))
	if r.prop == "sketch":
		var b: Vector2 = s["hand_b"]
		r.poly(PackedVector2Array([b + Vector2(-2, -15), b + Vector2(17, -17), b + Vector2(18, 7), b + Vector2(-1, 9)]), r.colors["white"], 1.5)
		r.draw_line(b + Vector2(-2, -15), b + Vector2(-1, 9), r.colors["accent"], 3.5)
		r.draw_arc(b + Vector2(8, -4), 5.0, 0, TAU * minf(1.0, r.prop_t / 18.0), 12, FighterRenderer.OUT, 1.3, true)
	if r.prop == "sketch_win":
		# Her celebration: the wand up, and the page she just finished held out
		# in the other hand so the crowd can see what she drew.
		var p: Vector2 = s["hand_b"] + Vector2(2, -12)
		var page: Color = r.colors["white"]
		var grow: float = minf(1.0, r.prop_t / 14.0)
		r.shaded_poly(PackedVector2Array([
			p + Vector2(-11, -15 * grow), p + Vector2(11, -17 * grow),
			p + Vector2(12, 14 * grow), p + Vector2(-10, 16 * grow),
		]), page, 1.5, 0.88)
		# The drawing on it: a rough, wobbly portrait of the loser.
		r.draw_polyline(Stage._closed(FighterRenderer.ellipse_pts(p + Vector2(0, -1 * grow), 5.0 * grow, 6.5 * grow, 0.0, 12)), r.colors["accent"], 1.2, true)
		r.draw_circle(p + Vector2(-2.0, -2.0), 0.9, FighterRenderer.OUT)
		r.draw_circle(p + Vector2(2.0, -2.0), 0.9, FighterRenderer.OUT)
		r.draw_line(p + Vector2(-2.5, 3.0), p + Vector2(2.5, 3.0), FighterRenderer.OUT, 1.0, true)
		for li in 3:
			r.draw_line(p + Vector2(-6.0, -8.0 + float(li) * 3.0), p + Vector2(6.0, -8.0 + float(li) * 3.0), r.colors["trim"], 0.6, true)


## A closed fist with knuckles, not the shared mitten. Small, because she is
## smaller than the rest of the roster.
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
		p - n * 2.5 - d * 0.8, p + n * 2.5 - d * 0.8, p + n * 2.3 + d * 1.5,
		p + n * 1.5 + d * 3.2, p - n * 1.5 + d * 3.2, p - n * 2.3 + d * 1.5,
	]), col, 1.0, 0.82)
	for k: float in [-1.5, -0.5, 0.5, 1.5]:
		r.draw_line(p + n * k + d * 1.6, p + n * k + d * 3.0, sh, 0.55, true)
	r.part(p + n * 2.0 - d * 0.2, p + n * 0.4 + d * 2.4, 1.5, 1.3, col)
	r.draw_line(p - n * 2.1 + d * 1.6, p + n * 2.1 + d * 1.6, FighterRenderer.hl(col), 0.5, true)


## A purple ankle boot with a small heel, the way the portrait draws them, in
## place of the shared slipper.
func draw_shoe(r: FighterRenderer, foot: Vector2, fwd: Vector2, col: Color) -> void:
	if fwd.length_squared() < 0.001:
		fwd = Vector2.RIGHT
	fwd = fwd.normalized()
	var up := Vector2(fwd.y, -fwd.x)
	r.shaded_poly(PackedVector2Array([
		foot - fwd * 2.6 + up * 3.4, foot + fwd * 0.6 + up * 3.0, foot + fwd * 4.4 + up * 2.2,
		foot + fwd * 6.4 - up * 0.2, foot + fwd * 6.0 - up * 1.4, foot - fwd * 2.8 - up * 1.4,
	]), col, 1.0, 0.8)
	# The heel, which is what makes it read as a boot rather than a slipper.
	r.draw_line(foot - fwd * 1.8 - up * 0.6, foot - fwd * 2.6 + up * 1.4, col.darkened(0.2), 1.4, true)
	r.draw_line(foot - fwd * 3.0 - up * 1.2, foot + fwd * 6.2 - up * 1.2, col.darkened(0.3), 1.0, true)
