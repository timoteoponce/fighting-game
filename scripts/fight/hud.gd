class_name Hud
extends Node2D
## MvC-style HUD: slanted metallic lifebars with portraits, timer, 3-level
## hyper gauges, combo counter, banners, hyper cut-in, screen flash and menus.

const BAR_W := 232.0
const BAR_H := 18.0
const SKEW := 10.0
const METAL_TOP := Color("f4f1ff")
const METAL_BOTTOM := Color("6b6488")
const LEVEL_COLORS := [Color("3fa9ff"), Color("47e05a"), Color("ff4fa8")]

var fight: Fight
var shown_hp := [1000.0, 1000.0]
var combo_show := [0, 0]
var combo_timer := [0, 0]
## Combo pop (1 -> 0) scales the counter up on each hit; chip flash does the
## same for the leading edge of the lifebar damage trail.
var combo_pop := [0.0, 0.0]
var chip_flash := [0.0, 0.0]
var frame := 0
var portraits: Array[FighterRenderer] = []
var cutin_portrait: FighterRenderer
var overlay: Node2D
var cutin_bg: Node2D
var cutin_fx: Node2D  # dimmer + focus lines; separate because cutin_bg clips
var cutin_slammed := false  # the portrait's landing squish fires once per cut-in


func _ready() -> void:
	for i in 2:
		var clip := _circle_clip(Vector2(36 if i == 0 else 604, 36), 27.0)
		add_child(clip)
		var r := FighterRenderer.new()
		r.head_only = true
		r.base_scale = 1.35
		r.facing = 1 if i == 0 else -1
		r.setup(fight.fighters[i].def, i == 1 and fight.fighters[0].def.id == fight.fighters[1].def.id)
		r.position = Vector2(0, 58)
		clip.add_child(r)
		portraits.append(r)
	cutin_fx = Node2D.new()
	cutin_fx.draw.connect(_draw_cutin_fx)
	add_child(cutin_fx)
	cutin_bg = Node2D.new()
	cutin_bg.draw.connect(_draw_cutin_bg)
	cutin_bg.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	add_child(cutin_bg)
	cutin_portrait = FighterRenderer.new()
	cutin_portrait.head_only = true
	cutin_portrait.base_scale = 3.6
	cutin_bg.add_child(cutin_portrait)
	overlay = Node2D.new()
	overlay.draw.connect(_draw_overlay)
	add_child(overlay)


func _circle_clip(center: Vector2, r: float) -> Node2D:
	var clip := Node2D.new()
	clip.position = center
	clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	clip.draw.connect(func() -> void:
		clip.draw_circle(Vector2.ZERO, r, Color("2a1f4a"), true, -1.0, true)
		clip.draw_circle(Vector2(0, -r * 0.3), r * 0.9, Color("4a3a7a"), true, -1.0, true))
	return clip


func _process(_delta: float) -> void:
	frame += 1
	for i in 2:
		var fr := fight.fighters[i]
		# The red "damage" part catches up once the combo ends.
		var target := float(fr.health)
		if shown_hp[i] > target:
			chip_flash[i] = 1.0
		if fr.combo == 0 or shown_hp[i] < target:
			shown_hp[i] = move_toward(shown_hp[i], target, 5.0)
		var d := fight.fighters[1 - i]
		if d.combo >= 2 and d.state in [Fighter.S.HITSTUN, Fighter.S.LAUNCHED, Fighter.S.KO]:
			if d.combo > combo_show[i]:
				combo_pop[i] = 1.0
			if combo_timer[i] <= 0:
				combo_timer[i] = 60
			combo_show[i] = d.combo
			combo_timer[i] = maxi(combo_timer[i], 50)
		elif combo_timer[i] > 0:
			combo_timer[i] -= 1
		combo_pop[i] = maxf(0.0, combo_pop[i] - 0.08)
		chip_flash[i] = maxf(0.0, chip_flash[i] - 0.1)
		var p := portraits[i]
		p.t = frame
		p.expr = fr.renderer.expr
		p.update_pose(fr.def.pose("idle"), 1.0)
	if fight.freeze > 0 and fight.freeze_owner:
		var owner := fight.freeze_owner
		if cutin_portrait.def != owner.def:
			cutin_portrait.setup(owner.def, owner.index == 1 and fight.fighters[0].def.id == fight.fighters[1].def.id)
		var left := owner.index == 0
		cutin_portrait.facing = 1 if left else -1
		# Slam in past the mark and spring back, creep forward during the hold,
		# then whip back out the way it came.
		var e := _cutin_e()
		var x := lerpf(-140.0, 150.0, _back_out(e / 8.0)) + e * 0.6 - _cutin_out() * 320.0
		cutin_portrait.position = Vector2(x if left else 640.0 - x, 312)
		if e >= 8.0 and not cutin_slammed:
			cutin_slammed = true
			cutin_portrait.squish(0.35)
			cutin_portrait.eye_pop = 9
		# Shout first, then the smug "you're finished" look.
		cutin_portrait.expr = "attack" if e < 30.0 else "smug"
		cutin_portrait.t = frame
		cutin_portrait.update_pose(owner.def.pose("idle", {"head": -6}), 1.0)
	cutin_portrait.visible = fight.freeze > 0
	if fight.freeze <= 0:
		cutin_slammed = false
	queue_redraw()
	cutin_fx.queue_redraw()
	cutin_bg.queue_redraw()
	overlay.queue_redraw()


func _draw() -> void:
	# Plates behind the portraits.
	for i in 2:
		var c := Vector2(36 if i == 0 else 604, 36)
		draw_circle(c, 31.0, Color("141024"), true, -1.0, true)


# --- Lifebars, timer, gauges -----------------------------------------------------------

func _draw_overlay() -> void:
	var o := overlay
	for i in 2:
		_lifebar(o, i)
		_gauge(o, i)
	_timer(o)
	for i in 2:
		if combo_timer[i] > 0:
			_combo(o, i)
	if fight.banner != "" and (fight.banner_t < 80 or fight.phase == "over"):
		_banner(o)
	if fight.freeze > 0:
		_cutin_text(o)
	if fight.flash > 0:
		o.draw_rect(Rect2(0, 0, 640, 360), Color(1, 1, 1, fight.flash / 8.0))
	if not fight.menu_items.is_empty():
		_menu(o)
	if fight.debug:
		for i in 2:
			var f := fight.fighters[i]
			UI.text(o, Vector2(24 + i * 400, 322), "P%d input: %s  meter %d" % [i + 1, _mask_text(f.buf.current()), int(f.meter)], 10, Color(0.7, 1, 0.7), HORIZONTAL_ALIGNMENT_LEFT)


## Slanted bar polygon, filled `frac` from the outer (portrait) side.
func _bar_poly(x0: float, y: float, w: float, h: float, frac: float, right: bool) -> PackedVector2Array:
	frac = clampf(frac, 0.0, 1.0)
	if right:
		var xs := x0 + w * (1.0 - frac)
		return PackedVector2Array([Vector2(xs, y), Vector2(x0 + w, y), Vector2(x0 + w - SKEW, y + h), Vector2(maxf(xs - SKEW, x0), y + h)])
	var xe := x0 + w * frac
	return PackedVector2Array([Vector2(x0 + SKEW, y), Vector2(maxf(xe, x0 + SKEW), y), Vector2(xe, y + h), Vector2(x0, y + h)])


## The inner edge of a bar at `frac` — where the damage trail meets the real
## health. Used to draw the bright leading-edge flash.
func _bar_edge(x0: float, y: float, w: float, h: float, frac: float, right: bool) -> PackedVector2Array:
	if right:
		var xs := x0 + w * (1.0 - frac)
		return PackedVector2Array([Vector2(xs, y), Vector2(maxf(xs - SKEW, x0), y + h)])
	var xe := x0 + w * frac
	return PackedVector2Array([Vector2(maxf(xe, x0 + SKEW), y), Vector2(xe, y + h)])


func _lifebar(o: Node2D, i: int) -> void:
	var fr := fight.fighters[i]
	var right := i == 1
	var x0 := 640.0 - 70.0 - BAR_W if right else 70.0
	var y := 14.0
	var frame_pts := _bar_poly(x0 - 4, y - 4, BAR_W + 8, BAR_H + 8, 1.0, right)
	UI.gradient_quad(o, frame_pts, METAL_TOP, METAL_BOTTOM)
	o.draw_polyline(frame_pts + PackedVector2Array([frame_pts[0]]), Color("15102a"), 2.0, true)
	o.draw_colored_polygon(_bar_poly(x0, y, BAR_W, BAR_H, 1.0, right), Color("1a0a18"))
	o.draw_colored_polygon(_bar_poly(x0, y, BAR_W, BAR_H, shown_hp[i] / Fighter.MAX_HEALTH, right), Color("e8302a"))
	# Bright leading edge on the damage trail, right after a hit.
	if chip_flash[i] > 0.0:
		o.draw_polyline(_bar_edge(x0, y, BAR_W, BAR_H, shown_hp[i] / Fighter.MAX_HEALTH, right),
			Color(1, 1, 1, chip_flash[i] * 0.9), 3.0, true)
	var frac := float(fr.health) / Fighter.MAX_HEALTH
	var low := frac < 0.25
	var top := Color("fff27a") if not low or frame % 20 < 10 else Color("ffb0a0")
	var bottom := Color("ffa91e") if not low else Color("ff3d2a")
	UI.gradient_quad(o, _bar_poly(x0, y, BAR_W, BAR_H, frac, right), top, bottom)
	o.draw_colored_polygon(_bar_poly(x0, y + 2, BAR_W, 4, frac, right), Color(1, 1, 1, 0.45))
	# Name plate.
	var nx := x0 + BAR_W - 8 if right else x0 + 8
	var label := fr.def.display
	if not fr.is_human():
		label += "  CPU"
	UI.text(o, Vector2(nx, y + BAR_H + 17), label, 15, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT, 5, Color("15102a"), UI.arcade_font())
	# Round wins.
	for k in Fight.ROUNDS_TO_WIN:
		var sx := x0 + 14.0 + k * 18.0 if right else x0 + BAR_W - 14.0 - k * 18.0
		var won: bool = fight.wins[i] > k
		var gem := PackedVector2Array([Vector2(sx, y + BAR_H + 5), Vector2(sx + 6, y + BAR_H + 11), Vector2(sx, y + BAR_H + 17), Vector2(sx - 6, y + BAR_H + 11)])
		o.draw_colored_polygon(gem, Color("ffd23f") if won else Color("2a2440"))
		o.draw_polyline(gem + PackedVector2Array([gem[0]]), Color("15102a"), 1.5, true)
	# Portrait ring.
	var c := Vector2(36 if i == 0 else 604, 36)
	o.draw_arc(c, 28.5, 0, TAU, 48, METAL_TOP, 3.0, true)
	o.draw_arc(c, 31.0, 0, TAU, 48, Color("15102a"), 2.0, true)


func _timer(o: Node2D) -> void:
	var c := Vector2(320, 28)
	var oct := PackedVector2Array()
	for k in 8:
		oct.append(c + Vector2.from_angle(TAU * k / 8.0 + PI / 8.0) * 25.0)
	o.draw_polygon(oct, PackedColorArray([METAL_TOP, METAL_TOP, METAL_BOTTOM, METAL_BOTTOM, METAL_BOTTOM, METAL_BOTTOM, METAL_TOP, METAL_TOP]))
	var inner := PackedVector2Array()
	for p in oct:
		inner.append(c + (p - c) * 0.84)
	o.draw_colored_polygon(inner, Color("15102a"))
	var secs := ceili(fight.timer / 60.0)
	var col := Color("ffe14d") if secs > 10 or frame % 20 < 10 else Color("ff4d4d")
	UI.text(o, c + Vector2(0, 10), str(secs), 26, col, HORIZONTAL_ALIGNMENT_CENTER, 4, Color("15102a"), UI.arcade_font())


func _gauge(o: Node2D, i: int) -> void:
	var fr := fight.fighters[i]
	var right := i == 1
	var w := 200.0
	var h := 11.0
	var x0 := 640.0 - 58.0 - w if right else 58.0
	var y := 334.0
	var levels := int(fr.meter / Fighter.HYPER_COST)
	var part := fmod(fr.meter, Fighter.HYPER_COST) / Fighter.HYPER_COST
	if levels >= 3:
		part = 1.0
	var frame_pts := _bar_poly(x0 - 3, y - 3, w + 6, h + 6, 1.0, right)
	UI.gradient_quad(o, frame_pts, METAL_TOP, METAL_BOTTOM)
	o.draw_colored_polygon(_bar_poly(x0, y, w, h, 1.0, right), Color("15102a"))
	if levels > 0:
		var prev: Color = LEVEL_COLORS[mini(levels, 3) - 1]
		o.draw_colored_polygon(_bar_poly(x0, y, w, h, 1.0, right), prev.darkened(0.45))
	var col: Color = LEVEL_COLORS[mini(levels, 2)]
	UI.gradient_quad(o, _bar_poly(x0, y, w, h, part, right), col.lightened(0.4), col)
	# Moving shine.
	var sx := fmod(frame * 4.0, w + 60.0) - 30.0
	var shine_x := x0 + (w - sx if right else sx)
	if part > 0.05:
		o.draw_line(Vector2(shine_x, y), Vector2(shine_x - 6, y + h), Color(1, 1, 1, 0.5), 4.0)
	# Level badge.
	var bc := Vector2(x0 + w + 22 if right else x0 - 22, y + 4)
	o.draw_circle(bc, 17.0, Color("15102a"), true, -1.0, true)
	o.draw_circle(bc, 15.0, LEVEL_COLORS[mini(maxi(levels, 1), 3) - 1] if levels > 0 else Color("3a3458"), true, -1.0, true)
	UI.text(o, bc + Vector2(0, 9), str(levels), 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 4, Color("15102a"), UI.arcade_font())
	var label := "HYPER COMBO" if levels == 0 else ("HYPER COMBO  READY!" if frame % 30 < 20 else "HYPER COMBO")
	UI.text(o, Vector2(x0 + w if right else x0, y - 6), label, 11, Color(1, 0.95, 0.5) if levels > 0 else Color.WHITE,
		HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT, 4, Color("15102a"), UI.arcade_font())


func _combo(o: Node2D, i: int) -> void:
	var slide := clampf((60 - combo_timer[i]) / 6.0, 0.0, 1.0)
	var fade := clampf(combo_timer[i] / 12.0, 0.0, 1.0)
	# The counter pops on each hit, then settles back.
	var pop: float = 1.0 + 0.45 * combo_pop[i]
	var x := lerpf(-80.0, 40.0, slide) if i == 0 else lerpf(720.0, 600.0, slide)
	var align := HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT
	var n := str(combo_show[i])
	# Colour climbs with the count: yellow -> orange -> hot red.
	var col := Color(1, 0.92, 0.3, fade)
	if combo_show[i] >= 10:
		col = Color(1, 0.45, 0.25, fade)
	elif combo_show[i] >= 5:
		col = Color(1, 0.7, 0.2, fade)
	var size := int(40.0 * pop)
	var nw := UI.arcade_font().get_string_size(n, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var hw := UI.arcade_font().get_string_size("HITS", HORIZONTAL_ALIGNMENT_LEFT, -1, int(18.0 * pop)).x
	# Always reads "12 HITS": number first, whichever side it sits on.
	var nx := x if i == 0 else x - hw - 6 - nw
	UI.text(o, Vector2(nx, 122), n, size, col, HORIZONTAL_ALIGNMENT_LEFT, 7, Color(0.7, 0.1, 0.1, fade), UI.arcade_font())
	UI.text(o, Vector2(nx + nw + 6, 122), "HITS", int(18.0 * pop), Color(1, 1, 1, fade), HORIZONTAL_ALIGNMENT_LEFT, 5, Color(0.7, 0.1, 0.1, fade), UI.arcade_font())
	if combo_show[i] >= 5:
		var word := "AWESOME!" if combo_show[i] < 10 else "INCREDIBLE!"
		UI.text(o, Vector2(x, 144), word, 14, Color(0.6, 0.95, 1, fade), align, 4, Color(0.1, 0.1, 0.4, fade), UI.arcade_font())


func _banner(o: Node2D) -> void:
	var bt := fight.banner_t
	var pop := 1.0 + 0.8 * maxf(0.0, 1.0 - bt / 7.0)
	# Speed streaks behind the text.
	var a := clampf(1.0 - absf(bt - 20) / 60.0, 0.0, 1.0) if fight.phase != "over" else 0.8
	for k in 7:
		var yy := 150.0 + k * 7.0
		var len := 200.0 + fmod(k * 97.0, 160.0)
		var xx := fmod(k * 131.0 + bt * 22.0, 900.0) - 130.0
		o.draw_line(Vector2(xx, yy), Vector2(xx + len, yy), Color(1, 0.8, 0.3, 0.25 * a), 3.0)
	UI.title(o, Vector2(320, 182), fight.banner, int(46 * pop))


## Frames since the hyper froze the world.
func _cutin_e() -> float:
	return float(Fight.HYPER_FREEZE - fight.freeze)


## 0 during the cut-in, rising to 1 over its last 8 frames as it leaves.
func _cutin_out() -> float:
	return clampf((_cutin_e() - Fight.HYPER_FREEZE + 8.0) / 8.0, 0.0, 1.0)


## Ease-out with overshoot: goes a little past 1 and settles back. It's what
## makes things slam into place instead of sliding.
static func _back_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0) - 1.0
	return 1.0 + x * x * (2.7 * x + 1.7)


## The slanted band: wipes across in 6 frames, pinches shut vertically on exit.
func _cutin_band() -> PackedVector2Array:
	var x_end := 640.0 * minf(1.0, _cutin_e() / 6.0)
	var h := 54.0 * (1.0 - _cutin_out())
	var c := 182.0
	if fight.freeze_owner.index == 0:
		return PackedVector2Array([Vector2(0, c - h + 15), Vector2(x_end, c - h - 15), Vector2(x_end, c + h - 15), Vector2(0, c + h + 15)])
	return PackedVector2Array([Vector2(640 - x_end, c - h - 15), Vector2(640, c - h + 15), Vector2(640, c + h + 15), Vector2(640 - x_end, c + h - 15)])


## Dims the arena and fires manga focus lines at the portrait. The lines are
## reshuffled every other frame so the whole screen seems to vibrate.
func _draw_cutin_fx() -> void:
	if fight.freeze <= 0 or fight.freeze_owner == null:
		return
	var fade := minf(1.0, _cutin_e() / 4.0) * (1.0 - _cutin_out())
	cutin_fx.draw_rect(Rect2(0, 0, 640, 360), Color(0.04, 0.02, 0.1, 0.5 * fade))
	var c := Vector2(150.0 if fight.freeze_owner.index == 0 else 490.0, 182.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = frame >> 1
	for i in 48:
		var ang := TAU * i / 48.0 + rng.randf_range(-0.06, 0.06)
		var r0 := rng.randf_range(90.0, 170.0)
		var w := rng.randf_range(0.008, 0.022)
		cutin_fx.draw_colored_polygon(PackedVector2Array([
			c + Vector2.from_angle(ang) * r0,
			c + Vector2.from_angle(ang - w) * 760.0,
			c + Vector2.from_angle(ang + w) * 760.0,
		]), Color(1, 1, 1, 0.5 * fade))


func _draw_cutin_bg() -> void:
	if fight.freeze <= 0 or fight.freeze_owner == null:
		return
	var left := fight.freeze_owner.index == 0
	var col := fight.cutin_color
	cutin_bg.draw_polygon(_cutin_band(), PackedColorArray([col.darkened(0.2), col.lightened(0.1), col.darkened(0.5), col.darkened(0.6)]))
	for i in 14:
		var x := fmod(i * 53.0 + frame * (18.0 if left else -18.0), 700.0) - 30.0
		cutin_bg.draw_line(Vector2(x, 110), Vector2(x + 40, 250), Color(1, 1, 1, 0.14), 8.0)


func _cutin_text(o: Node2D) -> void:
	var e := _cutin_e()
	var out := _cutin_out()
	var left := fight.freeze_owner.index == 0
	var band := _cutin_band()
	o.draw_line(band[0], band[1], Color(1, 1, 1, 0.9), 3.0)
	o.draw_line(band[3], band[2], Color(1, 1, 1, 0.9), 3.0)
	# Text lives in the half of the band away from the portrait, and is sized
	# to fit there, so it can never sit on the face.
	var font := UI.arcade_font()
	var slide := (1.0 - _back_out((e - 4.0) / 8.0)) * 340.0 + out * 400.0
	var ne := e - 10.0
	var pop := 1.0 + 0.35 * maxf(0.0, 1.0 - ne / 6.0) if ne >= 0.0 else 1.0
	var size := 28
	while size > 16 and font.get_string_size(fight.cutin_text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > 330.0:
		size -= 2
	var half_w := font.get_string_size(fight.cutin_text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * pop)).x * 0.5 + 16.0
	var tx := (610.0 - half_w + slide) if left else (30.0 + half_w - slide)
	UI.text(o, Vector2(tx, 158), fight.freeze_owner.def.display, 16, Color(1, 1, 1, 0.95), HORIZONTAL_ALIGNMENT_CENTER, 4, Color("15102a"), font)
	# The move name lands a beat later on a jagged comic burst and shudders for
	# a few frames like it hit the screen.
	if ne < 0.0:
		return
	var sz := int(size * pop)
	var jit := Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5)) if ne < 8.0 else Vector2.ZERO
	var at := Vector2(tx, 200) + jit
	var burst := PackedVector2Array()
	for q in FighterRenderer.star_pts(Vector2.ZERO, 1.0, 0.8, 18, frame * 0.03):
		burst.append(at + Vector2(0, -sz * 0.36) + q * Vector2(half_w, sz * 0.9) * (1.0 - out))
	o.draw_colored_polygon(FighterRenderer.safe(burst), fight.cutin_color.darkened(0.45))
	o.draw_polyline(Stage._closed(burst), Color(1, 1, 1, 0.95), 2.5, true)
	if out < 1.0:
		UI.title(o, at, fight.cutin_text, sz, Color(1, 0.95, 0.4), HORIZONTAL_ALIGNMENT_CENTER, Color(0.4, 0.05, 0.3))


func _menu(o: Node2D) -> void:
	o.draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0.05, 0.65))
	var y := 120.0
	if fight.menu_title != "":
		UI.title(o, Vector2(320, 92), fight.menu_title, 34)
	else:
		y = 222.0
	UI.menu(o, fight.menu_items, fight.menu_idx, Vector2(320, y), 16, 28)
	if fight.paused:
		for i in 2:
			var d := fight.fighters[i].def
			var x := 20.0 if i == 0 else 330.0
			UI.text(o, Vector2(x, 236), d.display + "  MOVES", 13, Color(1, 0.7, 0.9), HORIZONTAL_ALIGNMENT_LEFT, 4, Color.BLACK, UI.arcade_font())
			for j in d.specials_text.size():
				var row: Array = d.specials_text[j]
				UI.text(o, Vector2(x, 256 + j * 18), "%s:  %s" % [row[0], row[1]], 11, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 3)
		UI.text(o, Vector2(320, 348), "L / START: choose     H: resume", 11, Color(0.8, 0.8, 0.9))


func _mask_text(m: int) -> String:
	var s := ""
	for pair in [[Controls.UP, "U"], [Controls.DOWN, "D"], [Controls.LEFT, "<"], [Controls.RIGHT, ">"], [Controls.LIGHT, "L"], [Controls.HEAVY, "H"], [Controls.START, "S"]]:
		if m & pair[0]:
			s += pair[1] + " "
	return s if s != "" else "-"
