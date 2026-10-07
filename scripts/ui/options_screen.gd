class_name OptionsScreen
extends Node2D
## Volumes, match rules and stage choice. Every change saves immediately to
## user://settings.cfg (autoload/settings.gd), so there is no apply button and
## a crash never loses a setting.

const STAGES := ["", "field", "library", "rooftop", "dojo", "beach", "snow"]
const STAGE_NAMES := ["RANDOM", "FIELD", "LIBRARY", "ROOFTOP", "DOJO", "BEACH", "SNOW"]

var idx := 0
var t := 0.0


func _process(delta: float) -> void:
	t += delta
	if Controls.any_just_pressed(Controls.UP) != Controls.NONE:
		idx = posmod(idx - 1, 7)
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.DOWN) != Controls.NONE:
		idx = posmod(idx + 1, 7)
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.LEFT) != Controls.NONE:
		_change(-1)
	if Controls.any_just_pressed(Controls.RIGHT) != Controls.NONE:
		_change(1)
	if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
		if idx == 6:  # DONE
			Sfx.play("confirm")
			_back()
	if Controls.any_just_pressed(Controls.HEAVY) != Controls.NONE:
		Sfx.play("select")
		_back()
	queue_redraw()


func _change(d: int) -> void:
	match idx:
		0:
			Settings.sfx_volume = clampf(Settings.sfx_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		1:
			Settings.voice_volume = clampf(Settings.voice_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		2:
			Settings.music_volume = clampf(Settings.music_volume + d * 0.1, 0.0, 1.0)
			Sfx.apply_volumes()
			Sfx.play("confirm")
		3:
			Settings.rounds_to_win = clampi(Settings.rounds_to_win + d, 1, 3)
			Sfx.play("select")
		4:
			Settings.timer_enabled = not Settings.timer_enabled
			Sfx.play("select")
		5:
			var i := STAGES.find(Settings.stage)
			if i < 0:
				i = 0
			i = posmod(i + d, STAGES.size())
			Settings.stage = STAGES[i]
			Sfx.play("select")
	Settings.save_settings()


func _back() -> void:
	if GameState.options_return == "title":
		GameState.goto("title")


func _draw_bar(pos: Vector2, w: float, h: float, frac: float, sel: bool) -> void:
	draw_rect(Rect2(pos, Vector2(w, h)), Color(0.1, 0.08, 0.2))
	draw_rect(Rect2(pos, Vector2(w * frac, h)), Color(1, 0.85, 0.3) if sel else Color(0.7, 0.6, 0.2))
	draw_rect(Rect2(pos, Vector2(w, h)), Color(1, 1, 1, 0.3), false, 1.5)


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("1a0f3a"), Color("3a1a5a"))
	UI.title(self, Vector2(320, 50), "OPTIONS", 36)
	var labels := ["SFX VOLUME", "VOICE VOLUME", "MUSIC VOLUME", "ROUNDS TO WIN", "TIMER", "STAGE", "DONE"]
	var y := 120.0
	for i in labels.size():
		var sel := i == idx
		var col := Color(1, 0.95, 0.4) if sel else Color.WHITE
		UI.text(self, Vector2(180, y), labels[i], 16, col, HORIZONTAL_ALIGNMENT_RIGHT, 4, Color(0.05, 0.03, 0.1))
		if i < 3:
			_draw_bar(Vector2(220, y - 12), 200, 12, [Settings.sfx_volume, Settings.voice_volume, Settings.music_volume][i], sel)
		elif i == 3:
			UI.text(self, Vector2(220, y), str(Settings.rounds_to_win), 16, col, HORIZONTAL_ALIGNMENT_LEFT, 4, Color(0.05, 0.03, 0.1))
		elif i == 4:
			UI.text(self, Vector2(220, y), "ON" if Settings.timer_enabled else "OFF", 16, col, HORIZONTAL_ALIGNMENT_LEFT, 4, Color(0.05, 0.03, 0.1))
		elif i == 5:
			var si := STAGES.find(Settings.stage)
			if si < 0:
				si = 0
			UI.text(self, Vector2(220, y), STAGE_NAMES[si], 16, col, HORIZONTAL_ALIGNMENT_LEFT, 4, Color(0.05, 0.03, 0.1))
		y += 30
	UI.text(self, Vector2(320, 340), "LEFT / RIGHT: change     L: done     H: back", 11, Color(1, 1, 1, 0.8))
