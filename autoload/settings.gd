extends Node
## Player settings: volumes, match rules and stage choice. Saved to
## user://settings.cfg so they survive between runs. The options screen
## (scripts/ui/options_screen.gd) is the only writer; Sfx and Fight are
## the readers.

const SAVE_PATH := "user://settings.cfg"

## Volumes are stored linear (0.0-1.0) and applied as dB, so a slider
## reads naturally and 0.0 mutes instead of erroring.
var sfx_volume := 1.0
var voice_volume := 1.0
var music_volume := 1.0

## Match rules. Fight reads these in _ready(); the defaults match what the
## game shipped with before settings existed.
var rounds_to_win := 2
var timer_enabled := true

## "" = random stage each match, otherwise a key of Stage.KINDS.
var stage := ""


func _ready() -> void:
	load_settings()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("audio", "voice", voice_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("match", "rounds_to_win", rounds_to_win)
	cfg.set_value("match", "timer", timer_enabled)
	cfg.set_value("match", "stage", stage)
	cfg.save(SAVE_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if cfg.has_section("audio"):
		sfx_volume = clampf(float(cfg.get_value("audio", "sfx", sfx_volume)), 0.0, 1.0)
		voice_volume = clampf(float(cfg.get_value("audio", "voice", voice_volume)), 0.0, 1.0)
		music_volume = clampf(float(cfg.get_value("audio", "music", music_volume)), 0.0, 1.0)
	if cfg.has_section("match"):
		rounds_to_win = clampi(int(cfg.get_value("match", "rounds_to_win", rounds_to_win)), 1, 3)
		timer_enabled = bool(cfg.get_value("match", "timer", timer_enabled))
		stage = str(cfg.get_value("match", "stage", stage))


## Linear 0.0-1.0 to dB. 0.0 mutes: linear_to_db of a tiny positive value,
## so the math never sees a true zero.
static func lin2db(v: float) -> float:
	return linear_to_db(clampf(v, 0.0001, 1.0))
