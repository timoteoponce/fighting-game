class_name Hud
extends Node2D
## Health bars, timer, meters, combo counter, banners, hyper cut-in, menus.

var fight: Fight
var shown_hp := [1000.0, 1000.0]
var combo_show := [0, 0]
var combo_timer := [0, 0]
var frame := 0


func _process(_delta: float) -> void:
	frame += 1
	for i in 2:
		var fr := fight.fighters[i]
		# Red "damage" bar catches up once the combo ends.
		var target := float(fr.health)
		if fr.combo == 0 or shown_hp[i] < target:
			shown_hp[i] = move_toward(shown_hp[i], target, 8.0)
		var d := fight.fighters[1 - i]
		if d.combo >= 2 and d.state in [Fighter.S.HITSTUN, Fighter.S.LAUNCHED, Fighter.S.KO]:
			combo_show[i] = d.combo
			combo_timer[i] = 50
		elif combo_timer[i] > 0:
			combo_timer[i] -= 1
	queue_redraw()


func _draw() -> void:
	for i in 2:
		_player_bars(i)
	draw_rect(Rect2(298, 6, 44, 34), Color(0.05, 0.03, 0.1))
	draw_rect(Rect2(298, 6, 44, 34), Color(1, 0.85, 0.3), false, 2.0)
	UI.text(self, Vector2(320, 33), str(ceili(fight.timer / 60.0)), 24, Color.WHITE)
	for i in 2:
		if combo_timer[i] > 0:
			var x := 100.0 if i == 0 else 540.0
			UI.text(self, Vector2(x, 110), "%d HITS!" % combo_show[i], 26, Color(1, 0.8, 0.2), HORIZONTAL_ALIGNMENT_CENTER, 6, Color(0.7, 0.1, 0.2))
			if combo_show[i] >= 5:
				UI.text(self, Vector2(x, 132), "AWESOME!" if combo_show[i] < 10 else "INCREDIBLE!", 14, Color.WHITE)
	if fight.banner != "" and (fight.banner_t < 80 or fight.phase == "over"):
		var pop := 1.0 + 0.6 * maxf(0.0, 1.0 - fight.banner_t / 8.0)
		UI.text(self, Vector2(320, 175), fight.banner, int(42 * pop), Color(1, 0.9, 0.25), HORIZONTAL_ALIGNMENT_CENTER, 10, Color(0.75, 0.05, 0.2))
	if fight.freeze > 0:
		_cutin()
	if not fight.menu_items.is_empty():
		_menu()
	if fight.debug:
		for i in 2:
			var f := fight.fighters[i]
			UI.text(self, Vector2(24 + i * 400, 322), "P%d input: %s  meter %d" % [i + 1, _mask_text(f.buf.current()), int(f.meter)], 10, Color(0.7, 1, 0.7), HORIZONTAL_ALIGNMENT_LEFT)


func _player_bars(i: int) -> void:
	var fr := fight.fighters[i]
	var right := i == 1
	var x0 := 348.0 if right else 12.0
	var w := 280.0
	var y := 12.0
	draw_rect(Rect2(x0 - 2, y - 2, w + 4, 20), Color(0.05, 0.03, 0.1))
	draw_rect(Rect2(x0, y, w, 16), Color(0.3, 0.06, 0.12))
	draw_rect(_bar(x0, y, w, 16, shown_hp[i] / Fighter.MAX_HEALTH, right), Color(1, 0.3, 0.3))
	var frac := float(fr.health) / Fighter.MAX_HEALTH
	var col := Color("ffd23f") if frac > 0.3 else (Color("ff4d4d") if frame % 20 < 10 else Color("ff9a3d"))
	draw_rect(_bar(x0, y, w, 16, frac, right), col)
	draw_rect(_bar(x0, y + 2, w, 4, frac, right), Color(1, 1, 1, 0.35))
	var name := fr.def.display
	if not fr.is_human():
		name += "  (CPU %s)" % GameState.CPU_LEVELS[GameState.cpu_level]
	UI.text(self, Vector2(x0 + w if right else x0, y + 34), name, 15, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT)
	for k in Fight.ROUNDS_TO_WIN:
		var sx := x0 + 12.0 + k * 18.0 if right else x0 + w - 12.0 - k * 18.0
		var won: bool = fight.wins[i] > k
		var star := FighterRenderer.star_pts(Vector2(sx, y + 28), 7, 3)
		draw_colored_polygon(star, Color(1, 0.85, 0.2) if won else Color(0.2, 0.15, 0.3))
		draw_polyline(star + PackedVector2Array([star[0]]), Color(0.05, 0.03, 0.1), 1.5, true)
	# Hyper meter.
	var mw := 170.0
	var mx := 616.0 - mw if right else 24.0
	var my := 336.0
	draw_rect(Rect2(mx - 2, my - 2, mw + 4, 14), Color(0.05, 0.03, 0.1))
	var m := fr.meter / Fighter.MAX_METER
	var full := m >= 1.0
	var mcol := Color(0.3, 0.8, 1.0).lerp(Color(1, 0.4, 0.8), m)
	if full and frame % 16 < 8:
		mcol = Color.WHITE
	draw_rect(_bar(mx, my, mw, 10, m, not right), mcol)
	UI.text(self, Vector2(mx + (mw if right else 0.0), my - 6), "HYPER READY!  BACK + L + H" if full else "HYPER", 11,
		Color(1, 0.9, 0.3) if full else Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT)


func _bar(x0: float, y: float, w: float, h: float, frac: float, from_left: bool) -> Rect2:
	frac = clampf(frac, 0.0, 1.0)
	if from_left:
		return Rect2(x0, y, w * frac, h)
	return Rect2(x0 + w * (1.0 - frac), y, w * frac, h)


func _cutin() -> void:
	var k := minf(1.0, (45 - fight.freeze) / 6.0)
	var band := PackedVector2Array([Vector2(0, 140), Vector2(640 * k, 128), Vector2(640 * k, 196), Vector2(0, 208)])
	draw_colored_polygon(band, Color(fight.cutin_color.darkened(0.3), 0.9))
	for i in 12:
		var x := fmod(i * 60.0 + frame * 14.0, 700.0) - 30.0
		if x < 640 * k:
			draw_line(Vector2(x, 140), Vector2(x + 30, 196), Color(1, 1, 1, 0.2), 6.0)
	UI.text(self, Vector2(320, 164), fight.freeze_owner.def.display, 14, Color(1, 1, 1, 0.9))
	UI.text(self, Vector2(320, 192), fight.cutin_text, 30, Color(1, 0.95, 0.4), HORIZONTAL_ALIGNMENT_CENTER, 8, Color(0.4, 0.05, 0.3))


func _menu() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0.05, 0.6))
	var y := 120.0
	if fight.menu_title != "":
		UI.text(self, Vector2(320, 90), fight.menu_title, 30, Color(1, 0.9, 0.3))
	else:
		y = 220.0
	UI.menu(self, fight.menu_items, fight.menu_idx, Vector2(320, y), 16, 26)
	if fight.paused:
		for i in 2:
			var d := fight.fighters[i].def
			var x := 20.0 if i == 0 else 330.0
			UI.text(self, Vector2(x, 232), d.display + " - MOVES", 13, Color(1, 0.7, 0.9), HORIZONTAL_ALIGNMENT_LEFT)
			for j in d.specials_text.size():
				var row: Array = d.specials_text[j]
				UI.text(self, Vector2(x, 252 + j * 18), "%s:  %s" % [row[0], row[1]], 11, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 3)
		UI.text(self, Vector2(320, 348), "L / START: choose     H: resume", 11, Color(0.8, 0.8, 0.9))


func _mask_text(m: int) -> String:
	var s := ""
	for pair in [[Controls.UP, "U"], [Controls.DOWN, "D"], [Controls.LEFT, "<"], [Controls.RIGHT, ">"], [Controls.LIGHT, "L"], [Controls.HEAVY, "H"], [Controls.START, "S"]]:
		if m & pair[0]:
			s += pair[1] + " "
	return s if s != "" else "-"
