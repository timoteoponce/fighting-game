extends Node
## Match setup shared between screens, plus screen switching and the roster.

signal screen_requested(screen: String)

const CPU_LEVELS := ["VERY EASY", "EASY", "NORMAL", "HARD"]
const CHARACTER_DIR := "res://characters"

## Every playable character id, in roster order. Filled by scanning
## `characters/`, so adding a fighter is one new file — see `_scan_characters`.
var CHARACTERS: Array[String] = []

var mode := "vs"  # "vs", "cpu", "demo" (CPU vs CPU) or "training"
var devices := [-1, -2]  # input device per player
var chars := ["ulises", "emilia"]
var cpu_level := 2
var stage := ""  # "" = random
var debug_full_meter := false  # --full-meter: start rounds with 3 hyper levels
## Where the options screen returns to. Only "title" for now; the pause menu
## uses an in-fight sub-menu instead of navigating here.
var options_return := "title"

var _registry := {}  # id -> GDScript


func _ready() -> void:
	_scan_characters()


func goto(screen: String) -> void:
	screen_requested.emit(screen)


func make_character(id: String) -> CharacterDef:
	var script: GDScript = _registry.get(id)
	if script == null:
		push_warning("Unknown character '%s', falling back to %s" % [id, CHARACTERS[0]])
		script = _registry[CHARACTERS[0]]
	return script.new()


func has_character(id: String) -> bool:
	return _registry.has(id)


## Builds the roster from `characters/*.gd`. A file whose name starts with "_"
## (the template) is skipped, and so is anything that isn't a CharacterDef with
## an id. Exported builds may present scripts as `.gdc` or `.remap`, so those
## are folded back to the `.gd` path the engine actually loads.
func _scan_characters() -> void:
	_registry.clear()
	CHARACTERS.clear()
	var dir := DirAccess.open(CHARACTER_DIR)
	if dir == null:
		push_error("Cannot open %s" % CHARACTER_DIR)
		return
	var ids: Array[String] = []
	var entries := []  # [sort_order, id]
	for file in dir.get_files():
		if file.begins_with("_"):
			continue
		var name := file
		if name.ends_with(".remap"):
			name = name.trim_suffix(".remap")
		elif name.ends_with(".gdc"):
			name = name.trim_suffix("c")
		if not name.ends_with(".gd"):
			continue
		var script := load(CHARACTER_DIR.path_join(name)) as GDScript
		if script == null:
			continue
		var def = script.new()
		if not (def is CharacterDef) or (def as CharacterDef).id == "":
			continue
		var cd := def as CharacterDef
		if _registry.has(cd.id):
			push_error("Two characters both claim the id '%s'" % cd.id)
			continue
		_registry[cd.id] = script
		entries.append([cd.roster_order, cd.id])
	entries.sort_custom(func(a, b): return a[0] < b[0] if a[0] != b[0] else a[1] < b[1])
	for e in entries:
		ids.append(e[1])
	CHARACTERS.assign(ids)
	if CHARACTERS.is_empty():
		push_error("No characters found in %s" % CHARACTER_DIR)
