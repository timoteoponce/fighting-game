class_name ArcadeScreen
extends Node2D
## The arcade ladder: a Mortal-Kombat-style tower showing who the player has
## beaten, who they face next, and the "???" waiting at the top. After a win the
## player's fighter climbs from the old rung to the new one on entry. It is also
## the win screen — once `GameState.arcade_done()` is true it draws the cleared
## panel instead. The run itself lives on the `GameState` autoload, so this
## screen is just a view over it.

## Where the bottom rung sits and how far apart the rungs are. The player's
## fighter stands on (and hops between) these.
const RUNG0 := 110.0
const RUNG_GAP := 30.0
## Seconds per rung for the climb. A single advance is one quick hop; a longer
## jump plays one hop per rung.
const STEP_TIME := 0.42

var t := 0.0
var player_r: FighterRenderer
var foe_r: FighterRenderer
var climb_from := -1  # rung we are climbing from, -1 = not climbing
var climb_t := 1.0  # 0..1 across the whole climb


func _ready() -> void:
	# `--screen=arcade` boots straight here with no run in progress; give it a
	# default one so the screen is meaningful instead of an empty tower.
	if GameState.arcade_player == "":
		GameState.start_arcade(GameState.CHARACTERS[0])
	# Consume the "just advanced" flag once, so a re-entry does not replay it.
	climb_from = GameState.arcade_climb_from
	GameState.arcade_climb_from = -1
	var climbing := not GameState.arcade_done() and climb_from >= 0 and climb_from < GameState.arcade_index
	climb_t = 0.0 if climbing else 1.0
	player_r = FighterRenderer.new()
	player_r.base_scale = 1.0
	player_r.facing = 1
	add_child(player_r)
	foe_r = FighterRenderer.new()
	foe_r.base_scale = 1.25
	foe_r.facing = -1
	foe_r.position = Vector2(560, 332)
	add_child(foe_r)
	_refresh_models()
	_place_player()
	Sfx.set_music_mode("title")


## Rebuild the live models for whoever is on screen this frame. The boss only
## gets a face once she is the current opponent — before that she stays a "???".
func _refresh_models() -> void:
	player_r.setup(GameState.make_character(GameState.arcade_player))
	player_r.base_scale = 1.0 * player_r.def.size
	if not GameState.arcade_done():
		foe_r.setup(GameState.make_character(GameState.arcade_opponent()))
		foe_r.base_scale = 1.25 * foe_r.def.size
		foe_r.visible = true
	else:
		foe_r.visible = false


func _rung_y(i: int) -> float:
	return RUNG0 + i * RUNG_GAP


## Ease-out so each hop lands rather than drifts to a stop.
static func _ease(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)


## Puts the fighter on the rung they belong on when nothing is animating.
func _place_player() -> void:
	player_r.position = Vector2(330, _rung_y(GameState.arcade_index))


func _process(delta: float) -> void:
	t += delta
	player_r.t = t * 60.0
	player_r.update_pose(player_r.def.pose("idle", {"lean": 6 + sin(t * 3.0) * 3.0}), 0.12)
	if foe_r.visible:
		foe_r.t = t * 60.0
		foe_r.update_pose(foe_r.def.pose("idle", {"lean": -6 + sin(t * 3.0 + 1.5) * 3.0}), 0.12)
	# Cleared: the run is over. Park the champion and wait for any button.
	if GameState.arcade_done():
		player_r.position = Vector2(320, 300)
		if Controls.any_just_pressed(Controls.LIGHT | Controls.HEAVY | Controls.START) != Controls.NONE:
			Sfx.play("confirm")
			GameState.goto("title")
		queue_redraw()
		return
	if climb_t < 1.0:
		# One hop per rung: the whole climb is `steps` hops, and we interpolate
		# inside whichever hop we are on.
		var steps := GameState.arcade_index - climb_from
		if steps <= 0:
			climb_t = 1.0
		else:
			climb_t = minf(1.0, climb_t + delta / (STEP_TIME * float(steps)))
	if climb_t < 1.0:
		var p := climb_t * float(GameState.arcade_index - climb_from)
		var hop := int(floor(p))
		var frac := p - float(hop)
		var a := _rung_y(climb_from + hop)
		var b := _rung_y(climb_from + hop + 1)
		var y := lerpf(a, b, _ease(frac)) - sin(frac * PI) * 13.0
		player_r.position = Vector2(330 + sin(frac * PI) * 4.0, y)
	else:
		_place_player()
	# START or LIGHT begins the bout. START counts on its own (it is what the
	# prompt offers), and while the climb is playing it skips the animation
	# first so the player is never stuck watching it.
	if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
		if climb_t < 1.0:
			climb_t = 1.0
			_place_player()
			Sfx.play("select")
			return
		Sfx.play("confirm")
		GameState.chars = [GameState.arcade_player, GameState.arcade_opponent()]
		GameState.goto("fight")
		return
	queue_redraw()


func _draw() -> void:
	UI.gradient_rect(self, Rect2(0, 0, 640, 360), Color("141024"), Color("3a1261"))
	UI.title(self, Vector2(320, 30), "ARCADE", 34)
	if GameState.arcade_done():
		_draw_cleared()
		return
	_draw_tower()
	# Left column: who is climbing, and how many continues are left.
	UI.text(self, Vector2(120, 84), "YOUR FIGHTER", 11, Color(1, 0.8, 0.95), HORIZONTAL_ALIGNMENT_CENTER, 3)
	UI.text(self, Vector2(120, 104), player_r.def.display, 22, Color(1, 0.95, 0.5),
		HORIZONTAL_ALIGNMENT_CENTER, 6, Color(0.1, 0.05, 0.2))
	UI.text(self, Vector2(120, 126), "Difficulty: %s" % _level_name(), 11, Color(1, 1, 1, 0.85), HORIZONTAL_ALIGNMENT_CENTER)
	UI.text(self, Vector2(120, 146), "Continues: %d" % GameState.arcade_continues, 11, Color(1, 1, 1, 0.85), HORIZONTAL_ALIGNMENT_CENTER)
	if climb_t < 1.0:
		UI.text(self, Vector2(320, 344), "CLIMBING...", 12, Color(1, 0.9, 0.4))
	else:
		UI.text(self, Vector2(320, 344), "L / START: fight", 12, Color(1, 1, 1, 0.8))


## The ladder itself: two rails and a step per rung, with the names beside them.
func _draw_tower() -> void:
	var n := GameState.arcade_ladder.size()
	if n == 0:
		return
	var top := _rung_y(0) - 10.0
	var bottom := _rung_y(n - 1) + 8.0
	var rail := Color(0.62, 0.55, 0.9, 0.5)
	draw_line(Vector2(306, top), Vector2(306, bottom), rail, 2.0)
	draw_line(Vector2(366, top), Vector2(366, bottom), rail, 2.0)
	for i in n:
		var id: String = GameState.arcade_ladder[i]
		var done := i < GameState.arcade_index
		var here := i == GameState.arcade_index
		var boss_here := id == GameState.BOSS_ID and here
		var hidden := id == GameState.BOSS_ID and not here
		var ry := _rung_y(i)
		# A step under the fighter, lit when it is the current one.
		var step := Color(1, 0.85, 0.35) if here else Color(0.5, 0.46, 0.72, 0.7)
		draw_line(Vector2(306, ry), Vector2(366, ry), step, 3.0 if here else 2.0)
		var name := "???" if hidden else GameState.make_character(id).display
		var col := Color(1, 1, 1, 0.35) if done else (Color(1, 0.95, 0.4) if here else Color(1, 1, 1, 0.82))
		var mark := "  x" if done else ("  <" if here else "")
		if hidden:
			UI.text(self, Vector2(400, ry + 5), name + mark, 18, Color(1, 0.4, 0.5),
				HORIZONTAL_ALIGNMENT_LEFT, 4, Color(0.3, 0.0, 0.1))
		else:
			UI.text(self, Vector2(400, ry + 5), name + mark, 16 if here else 13, col,
				HORIZONTAL_ALIGNMENT_LEFT, 4, Color(0.1, 0.05, 0.2))
		if boss_here:
			# The reveal: her rung pulses the moment she is the next fight.
			draw_line(Vector2(306, ry), Vector2(366, ry), Color(1, 0.4, 0.5, 0.6 + 0.4 * sin(t * 8.0)), 4.0)


func _level_name() -> String:
	return GameState.CPU_LEVELS[GameState.arcade_level()]


func _draw_cleared() -> void:
	UI.title(self, Vector2(320, 150), "ARCADE CLEARED!", 40, Color(1, 0.95, 0.4))
	UI.text(self, Vector2(320, 196), "%s stands over a very annoyed cat." % player_r.def.display, 14, Color.WHITE)
	UI.text(self, Vector2(320, 220), "Luna is not on the select screen. She never was.", 11, Color(1, 1, 1, 0.7))
	UI.text(self, Vector2(320, 300), "PRESS ANY BUTTON", 14, Color(1, 0.9, 1.0) if int(t * 2.0) % 2 == 0 else Color(1, 0.9, 1.0, 0.3))
