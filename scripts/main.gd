extends Node
## Root node: swaps between screens (title, select, fight...).

var current: Node


func _ready() -> void:
	GameState.screen_requested.connect(func(s: String) -> void: call_deferred("_switch", s))
	_switch("title")


func _switch(screen: String) -> void:
	if current:
		current.queue_free()
	match screen:
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
