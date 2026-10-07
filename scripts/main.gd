extends Node
## Root node: swaps between screens (title, select, fight...).

var current: Node


func _ready() -> void:
	GameState.screen_requested.connect(func(s: String) -> void: call_deferred("_switch", s))
	# Command line (after "--"): --demo = CPU vs CPU fight, --screen=NAME opens a
	# screen, --test runs the gameplay tests.
	# The logo slam is the cold boot. --demo, --test and an explicit --screen=
	# skip it, and coming back from a match lands on the menu, not the slam.
	var start := "splash"
	for arg in OS.get_cmdline_user_args():
		if arg == "--demo":
			GameState.mode = "demo"
			GameState.chars = [GameState.CHARACTERS.pick_random(), GameState.CHARACTERS.pick_random()]
			GameState.cpu_level = 2
			start = "fight"
		elif arg == "--test":
			add_child(load("res://tests/sim_test.gd").new())
			return
		elif arg == "--full-meter":
			GameState.debug_full_meter = true
		elif arg.begins_with("--chars="):
			GameState.chars = Array(arg.trim_prefix("--chars=").split(","))
		elif arg.begins_with("--stage="):
			GameState.stage = arg.trim_prefix("--stage=")
		elif arg.begins_with("--screen="):
			start = arg.trim_prefix("--screen=")
	_switch(start)


func _switch(screen: String) -> void:
	if current:
		current.queue_free()
	# The slam has its own sting. The fight gets the driving track, and every
	# other screen gets the mellow one (or the files in music/, if any).
	if screen == "splash":
		Sfx.play_logo_sting()
	else:
		Sfx.resume_after_sting()
		Sfx.set_music_mode("fight" if screen == "fight" else "title")
	match screen:
		"splash":
			current = SplashScreen.new()
		"select":
			current = CharSelect.new()
		"fight":
			current = Fight.new()
		"setup":
			current = ControllerSetup.new()
		"howto":
			current = HowToPlay.new()
		_:
			current = TitleScreen.new()
	add_child(current)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var k := event as InputEventKey
		if k.keycode == KEY_F11 or (k.keycode == KEY_ENTER and k.alt_pressed):
			var fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fs else DisplayServer.WINDOW_MODE_FULLSCREEN)
