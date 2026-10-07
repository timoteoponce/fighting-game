extends Node
## Match setup shared between screens, plus screen switching and the roster.

signal screen_requested(screen: String)

const CPU_LEVELS := ["VERY EASY", "EASY", "NORMAL", "HARD"]
const CHARACTER_DIR := "res://characters"
## The hidden character the arcade ladder ends on. `LOCKED` holds every hidden
## fighter, so the boss stays a secret until you reach her.
const BOSS_ID := "luna"

## Every *selectable* character id, in roster order. Filled by scanning
## `characters/`, so adding a fighter is one new file — see `_scan_characters`.
var CHARACTERS: Array[String] = []
## Fighters with `hidden = true` (the arcade boss). In the registry, off the
## select screen.
var LOCKED: Array[String] = []

var mode := "vs"  # "vs", "cpu", "demo" (CPU vs CPU), "arcade" or "training"
var devices := [-1, -2]  # input device per player
var chars := ["ulises", "emilia"]
var cpu_level := 2
var stage := ""  # "" = random
var debug_full_meter := false  # --full-meter: start rounds with 3 hyper levels
## Where the options screen returns to. Only "title" for now; the pause menu
## uses an in-fight sub-menu instead of navigating here.
var options_return := "title"

# --- Arcade run ---------------------------------------------------------------
# A single-player gauntlet: pick a fighter, beat every other roster member in
# turn, then the hidden boss. Lives on the autoload so it survives the screen
# swaps between the ladder, each Fight and back.
var arcade_player := ""
var arcade_ladder: Array[String] = []
var arcade_index := 0
var arcade_continues := 0
## The rung the player just climbed *from*, so the tower screen can play the
## Mortal-Kombat-style climb animation on entry. -1 means no climb to play.
var arcade_climb_from := -1

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


# --- Arcade run ---------------------------------------------------------------

## Starts a fresh run as `player_id`. The ladder is every other selectable
## fighter in roster order, then the hidden boss, so it is derived from the
## scanned roster rather than a hand-written list.
func start_arcade(player_id: String) -> void:
	arcade_player = player_id
	arcade_ladder.clear()
	for id in CHARACTERS:
		if id != player_id:
			arcade_ladder.append(id)
	arcade_ladder.append(BOSS_ID)
	arcade_index = 0
	arcade_continues = 3
	arcade_climb_from = -1


## The id the player is up against right now, or "" once the run is over.
func arcade_opponent() -> String:
	if arcade_done():
		return ""
	return arcade_ladder[arcade_index]


func arcade_is_boss() -> bool:
	return not arcade_done() and arcade_ladder[arcade_index] == BOSS_ID


func arcade_advance() -> void:
	arcade_climb_from = arcade_index
	arcade_index += 1


func arcade_done() -> bool:
	return arcade_ladder.is_empty() or arcade_index >= arcade_ladder.size()


## How hard the current opponent thinks. The ladder ramps EASY -> NORMAL ->
## HARD, and the boss is always HARD, so a run gets tenser as it goes.
func arcade_level() -> int:
	if arcade_ladder.is_empty():
		return CPU_LEVELS.size() - 1
	var n := arcade_ladder.size()
	return clampi(1 + int(round(2.0 * float(arcade_index) / maxf(1.0, float(n - 1)))), 0, CPU_LEVELS.size() - 1)


## Builds the roster from `characters/*.gd`. A file whose name starts with "_"
## (the template) is skipped, and so is anything that isn't a CharacterDef with
## an id. Exported builds may present scripts as `.gdc` or `.remap`, so those
## are folded back to the `.gd` path the engine actually loads. A fighter with
## `hidden = true` goes into `LOCKED`, not `CHARACTERS`.
func _scan_characters() -> void:
	_registry.clear()
	CHARACTERS.clear()
	LOCKED.clear()
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
		if cd.hidden:
			LOCKED.append(cd.id)
			continue
		entries.append([cd.roster_order, cd.id])
	entries.sort_custom(func(a, b): return a[0] < b[0] if a[0] != b[0] else a[1] < b[1])
	for e in entries:
		ids.append(e[1])
	CHARACTERS.assign(ids)
	if CHARACTERS.is_empty():
		push_error("No characters found in %s" % CHARACTER_DIR)
