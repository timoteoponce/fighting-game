extends Node
## Match setup shared between screens, plus screen switching.

signal screen_requested(screen: String)

const CHARACTERS := ["ulises", "emilia"]
const CPU_LEVELS := ["EASY", "NORMAL", "HARD"]

var mode := "vs"  # "vs", "cpu" or "demo" (CPU vs CPU)
var devices := [-1, -2]  # input device per player
var chars := ["ulises", "emilia"]
var cpu_level := 1


func goto(screen: String) -> void:
	screen_requested.emit(screen)


func make_character(id: String) -> CharacterDef:
	match id:
		"emilia":
			return EmiliaDef.new()
		_:
			return UlisesDef.new()
