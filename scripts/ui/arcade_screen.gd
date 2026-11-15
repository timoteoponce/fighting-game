class_name ArcadeScreen
extends Node2D
## The arcade tower: a Mortal-Kombat-style column of blocks, one per opponent,
## each inlaid with that kid's face. Rung 0 — the first fight — sits at the
## bottom and the boss crowns the top as a faceless "???" until she is the next
## bout. After a win the player's fighter hops up from the old block to the new
## one, one hop per rung, on entry. It is also the win screen — once
## `GameState.arcade_done()` is true it draws the cleared panel instead. The run
## itself lives on the `GameState` autoload, so this screen is just a view
## over it.

## Tower geometry, in the 640x360 menu space. The blocks stack tightly into a
## column standing on FLOOR_Y; the column may not grow past TOP_LIMIT, so a
## longer ladder shrinks the blocks instead of leaving the screen.
const FLOOR_Y := 316.0
const TOP_LIMIT := 96.0
const BLOCK_W := 150.0
const BLOCK_H := 56.0
const MIN_BLOCK_H := 26.0
const TOWER_X := 430.0
## The lip the player stands on, sticking out of the current block to the left
## of the tower so the fighter never covers a face.
const LEDGE_W := 52.0
## Seconds per rung for the climb. A single advance is one quick hop; a longer
## jump plays one hop per rung.
const STEP_TIME := 0.42

## Palette. The background is the dark purple gradient, so the blocks are lit
## purple stone; the current block goes gold, the beaten ones sink back into
## the dark, and the boss's cell stays black until her reveal.
const INK := Color(0.07, 0.05, 0.12)
const COL_PLAIN := Color("443469")
const COL_CURRENT := Color("7d5a1d")
const COL_BEATEN := Color("2c2547")
const COL_BOSS := Color("201636")
const COL_GOLD := Color(1, 0.85, 0.35)
const COL_PINK := Color(1, 0.4, 0.5)
const COL_EDGE := Color(0.62, 0.55, 0.9, 0.5)
## A beaten portrait dims to this — applied after `update_pose`, which resets
## modulate on every call.
const COL_DIM := Color(0.55, 0.52, 0.66)

var t := 0.0
var player_r: FighterRenderer
var portraits: Array[FighterRenderer] = []
var clips: Array[Node2D] = []
## Ink that has to sit ON TOP of the portraits: the boss's "?" and the
## elimination strikes. A parent's own `_draw` renders behind its children,
## so this screen keeps a child node for anything that must cover a face.
var marks: Node2D
var climb_from := -1  # rung we are climbing from, -1 = not climbing
var climb_t := 1.0  # 0..1 across the whole climb
var _last_hop := 0  # hop we last landed on, for the per-hop landing tick


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
	player_r.setup(GameState.make_character(GameState.arcade_player))
	player_r.base_scale = 1.0 * player_r.def.size
	# One portrait per rung: the same head-and-shoulders close-up the HUD
	# lifebars wear, clipped to a disc inlaid in the block.
	for i in GameState.arcade_ladder.size():
		var id: String = GameState.arcade_ladder[i]
		var clip := _portrait_clip(id, i)
		clips.append(clip)
		# The boss keeps a faceless disc until she is the next fight.
		portraits[i].visible = not (id == GameState.BOSS_ID and i != GameState.arcade_index)
	# Ink above the portraits (see `marks`).
	marks = Node2D.new()
	marks.draw.connect(_draw_marks)
	add_child(marks)
	# A finished run shows the cleared panel; the tower hides underneath it.
	if GameState.arcade_done():
		for c in clips:
			c.visible = false
	_place_player()
	Sfx.set_music_mode("title")


## The portrait recipe the HUD lifebars use (`hud.gd`): a clipping disc with a
## dark backing, and a `head_only` renderer inside, sized so the face fills the
## disc. 27px of disc to 1.35 of scale is the HUD's ratio; the tower keeps it.
func _portrait_clip(id: String, i: int) -> Node2D:
	var r := _portrait_radius()
	var s := r / 20.0
	var clip := Node2D.new()
	clip.position = Vector2(TOWER_X - BLOCK_W * 0.5 + r + 9.0, _rung_y(i))
	clip.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	clip.draw.connect(func() -> void:
		clip.draw_circle(Vector2.ZERO, r, Color("1e1435"), true, -1.0, true)
		clip.draw_circle(Vector2(0.0, -r * 0.35), r * 0.92, Color("33255c"), true, -1.0, true))
	add_child(clip)
	var p := FighterRenderer.new()
	p.head_only = true
	p.base_scale = s
	p.facing = -1  # the tower's kids look left, out at the challenger
	p.setup(GameState.make_character(id))
	p.position = Vector2(0.0, 43.0 * s)
	clip.add_child(p)
	portraits.append(p)
	return clip


## Height of one block. The tower stands on FLOOR_Y and may not grow past
## TOP_LIMIT, so a longer ladder compresses the blocks instead of running off
## the screen.
func _block_h() -> float:
	var n := maxi(1, GameState.arcade_ladder.size())
	return clampf((FLOOR_Y - TOP_LIMIT) / float(n), MIN_BLOCK_H, BLOCK_H)


## Centre of block i. Rung 0 — the first opponent — sits at the bottom of the
## column, and every win hops the player one block higher, boss on top.
func _rung_y(i: int) -> float:
	return FLOOR_Y - _block_h() * (float(i) + 0.5)


## Radius of the portrait disc inlaid in each block.
func _portrait_radius() -> float:
	return _block_h() * 0.5 - 4.0


## The ledge the player stands on: the current block's top edge, extended out
## to the left of the tower.
func _stand_y(i: int) -> float:
	return _rung_y(i) - _block_h() * 0.5 - 4.0


## Ease-out so each hop lands rather than drifts to a stop.
static func _ease(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)


## Puts the fighter on the ledge of the block they belong on when nothing is
## animating.
func _place_player() -> void:
	player_r.position = Vector2(TOWER_X - BLOCK_W * 0.5 - LEDGE_W * 0.5, _stand_y(GameState.arcade_index))


func _process(delta: float) -> void:
	t += delta
	player_r.t = t * 60.0
	# Cleared: the run is over. Park the champion on the right, striking a win
	# pose, and wait for any button.
	if GameState.arcade_done():
		player_r.position = Vector2(505, 332)
		player_r.expr = "win"
		player_r.prop = player_r.def.win_prop
		player_r.update_pose(player_r.def.pose("win", {"lean": -4 + sin(t * 3.0) * 3.0}), 0.12)
		for c in clips:
			c.visible = false
		if Controls.any_just_pressed(Controls.LIGHT | Controls.HEAVY | Controls.START) != Controls.NONE:
			Sfx.play("confirm")
			GameState.goto("title")
		queue_redraw()
		return
	player_r.prop = ""
	player_r.expr = "normal"
	player_r.update_pose(player_r.def.pose("idle", {"lean": 6 + sin(t * 3.0) * 3.0}), 0.12)
	_sync_portraits()
	# One hop per rung: the whole climb is `steps` hops, and we interpolate
	# inside whichever hop we are on.
	var climbing := climb_t < 1.0
	if climbing:
		var steps := GameState.arcade_index - climb_from
		if steps <= 0:
			climb_t = 1.0
		else:
			climb_t = minf(1.0, climb_t + delta / (STEP_TIME * float(steps)))
	if climb_t < 1.0:
		var prog := climb_t * float(GameState.arcade_index - climb_from)
		var hop := int(floor(prog))
		var frac := prog - float(hop)
		var a := _stand_y(climb_from + hop)
		var b := _stand_y(climb_from + hop + 1)
		var y := lerpf(a, b, _ease(frac)) - sin(frac * PI) * 13.0
		player_r.position = Vector2(TOWER_X - BLOCK_W * 0.5 - LEDGE_W * 0.5 + sin(frac * PI) * 4.0, y)
		# A light tick each time a hop lands.
		if hop != _last_hop:
			_last_hop = hop
			Sfx.play("land", 1.7)
	elif climbing:
		# The climb just finished: one last, heavier landing.
		_last_hop = -1
		_place_player()
		Sfx.play("land", 1.2)
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
	marks.queue_redraw()


## Pose and dress every portrait for its rung's state: the next opponent alert
## (the boss smug, once she is revealed), the beaten ones KO'd and dim under
## their strike, and the ones still waiting calm.
func _sync_portraits() -> void:
	for i in portraits.size():
		var p := portraits[i]
		var boss := GameState.arcade_ladder[i] == GameState.BOSS_ID
		var done := i < GameState.arcade_index
		var here := i == GameState.arcade_index
		p.visible = not (boss and not here)
		p.t = t * 60.0
		p.expr = "ko" if done else ("smug" if boss and here else "normal")
		p.update_pose(p.def.pose("idle"), 1.0)
		if done:
			# update_pose resets modulate every call, so the dim goes on after.
			p.modulate = COL_DIM


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


## The tower itself: a stacked column of blocks standing on a wider base slab,
## a pennant crowning the top. The current block is gold and carries the
## player's ledge; beaten blocks sink into the dark; the boss's block is a
## black cell that pulses pink the moment she is the next fight.
func _draw_tower() -> void:
	var n := GameState.arcade_ladder.size()
	if n == 0:
		return
	var h := _block_h()
	var left := TOWER_X - BLOCK_W * 0.5
	# The base the column stands on, and the pennant: the two bits that make a
	# stack of blocks read as one tower.
	var base := Rect2(left - 12.0, FLOOR_Y, BLOCK_W + 24.0, 12.0)
	draw_rect(base, COL_PLAIN.darkened(0.2))
	draw_rect(base, COL_EDGE, false, 2.0)
	var top := _rung_y(n - 1) - h * 0.5
	draw_line(Vector2(TOWER_X, top), Vector2(TOWER_X, top - 16.0), COL_EDGE, 2.0)
	var fl := Vector2(TOWER_X, top - 16.0)
	draw_colored_polygon(PackedVector2Array([fl, fl + Vector2(13.0, 4.0), fl + Vector2(0.0, 8.0)]), COL_GOLD)
	for i in n:
		var id: String = GameState.arcade_ladder[i]
		var done := i < GameState.arcade_index
		var here := i == GameState.arcade_index
		var boss := id == GameState.BOSS_ID
		var hidden := boss and not here
		var cy := _rung_y(i)
		var rect := Rect2(left, cy - h * 0.5, BLOCK_W, h)
		var fill := COL_BEATEN if done else (COL_CURRENT if here else (COL_BOSS if hidden else COL_PLAIN))
		draw_rect(rect, fill)
		# A lit top lip and a dark foot: two lines that make each slab read as
		# stacked stone rather than a stripe of colour.
		draw_rect(Rect2(left + 2.0, rect.position.y + 1.5, BLOCK_W - 4.0, 2.5), fill.lightened(0.16))
		draw_rect(Rect2(left + 2.0, rect.end.y - 4.0, BLOCK_W - 4.0, 2.5), fill.darkened(0.3))
		var border := COL_GOLD if here else COL_EDGE
		var bw := 3.0 if here else 2.0
		if boss and here:
			# The reveal: her block pulses the moment she is the next fight.
			border = Color(COL_PINK, 0.6 + 0.4 * sin(t * 8.0))
			bw = 4.0
		draw_rect(rect, border, false, bw)
		if here:
			# The ledge the player stands on, sticking out of this block.
			var ly := _stand_y(i)
			draw_rect(Rect2(left - LEDGE_W, ly, LEDGE_W, 6.0), INK)
			draw_rect(Rect2(left - LEDGE_W + 2.0, ly + 1.5, LEDGE_W - 4.0, 3.0), COL_GOLD)
		# The name, centred in the space the portrait disc leaves.
		var name := "???" if hidden else GameState.make_character(id).display
		var col := Color(1, 1, 1, 0.4) if done else (COL_GOLD if here else Color(1, 1, 1, 0.85))
		var cx := left + BLOCK_W * 0.5 + _portrait_radius() + 9.0
		UI.text(self, Vector2(cx, cy + 5.0), name, 15 if here else 13, col,
			HORIZONTAL_ALIGNMENT_CENTER, 4, INK)


## Ink that belongs ON TOP of the portraits: the boss's "?" before her reveal,
## and the elimination strike across each beaten block.
func _draw_marks() -> void:
	var n := GameState.arcade_ladder.size()
	if n == 0 or GameState.arcade_done():
		return
	var h := _block_h()
	var left := TOWER_X - BLOCK_W * 0.5
	var r := _portrait_radius()
	for i in n:
		var cy := _rung_y(i)
		if GameState.arcade_ladder[i] == GameState.BOSS_ID and i != GameState.arcade_index:
			UI.text(marks, Vector2(left + r + 9.0, cy + 8.0), "?", 24, COL_PINK,
				HORIZONTAL_ALIGNMENT_CENTER, 4, Color(0.3, 0.0, 0.1))
		if i < GameState.arcade_index:
			# The elimination strike: one gold slash, inked underneath so it
			# survives any fill, corner to corner across the beaten block.
			var rect := Rect2(left, cy - h * 0.5, BLOCK_W, h)
			var a := rect.position + Vector2(7.0, h - 6.0)
			var b := rect.end - Vector2(7.0, h - 6.0)
			marks.draw_line(a, b, INK, 7.0)
			marks.draw_line(a, b, Color(1, 0.85, 0.35, 0.9), 3.5)


func _level_name() -> String:
	return GameState.CPU_LEVELS[GameState.arcade_level()]


func _draw_cleared() -> void:
	UI.title(self, Vector2(320, 150), "ARCADE CLEARED!", 40, Color(1, 0.95, 0.4))
	UI.text(self, Vector2(320, 196), "%s stands over a very annoyed cat." % player_r.def.display, 14, Color.WHITE)
	UI.text(self, Vector2(320, 220), "Luna is not on the select screen. She never was.", 11, Color(1, 1, 1, 0.7))
	UI.text(self, Vector2(320, 300), "PRESS ANY BUTTON", 14, Color(1, 0.9, 1.0) if int(t * 2.0) % 2 == 0 else Color(1, 0.9, 1.0, 0.3))
