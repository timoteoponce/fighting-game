class_name CharacterDef
extends RefCounted
## Base class for a playable character: stats, colors, moves, poses and the
## drawing hooks that give each fighter their own look.
##
## Move keys: L, H, cL, cH, jL, jH (normals), proj, rush, anti (specials), hyper.

## Every character must define all ten. `char-validate` in the test suite
## enforces this, so a half-finished fighter fails loudly instead of crashing
## mid-match.
const REQUIRED_MOVES := ["L", "H", "cL", "cH", "jL", "jH", "proj", "rush", "anti", "hyper"]
## Colour keys the shared body renderer reads. Characters may add more for
## their own `draw_behind` / `draw_front` parts (capes, skirts, headbands).
const REQUIRED_COLORS := ["skin", "hair", "shirt", "sleeve", "forearm", "hands",
	"pants", "legs", "shoes", "eyes", "accent"]

var id := ""
var size := 1.0  # body scale; hitboxes are scaled to match by scale_moves()
## Head size relative to the body. Purely visual (hitboxes ignore it), and the
## cheapest way to give a fighter a silhouette: big head = chibi cartoon.
var head_scale := 1.45
## Limb and torso thickness, also purely visual: 0.7 is a beanpole, 1.3 is stocky.
var build := 1.0
var display := ""
var likes := ""
var colors := {}
var alt_colors := {}
var walk_speed := 3.0
var back_speed := 2.4
var jump_vel := -10.5
var jump_x := 3.6
## Base pitch (Hz) of this character's synthesized shouts. Lower = older or
## bigger. Set it and the voice works; there is no table to register in.
var voice_pitch := 280.0
## Where this fighter sits on the select screen. Lower comes first; ties break
## alphabetically by id.
var roster_order := 100
var moves := {}
var poses := {}
var win_prop := ""
var intro_prop := ""
var win_quote := ""
## Things that get knocked loose when this fighter eats a big hit. Names come
## from `Effects._draw_gag` ("pacifier", "bone", "tissue", "ball", "pencil",
## "tooth", "note"); anything else becomes a spinning star.
var gag_items: Array = ["star"]
## Short shouty lines that appear in a speech bubble. Keep them under ~14
## characters or the bubble grows wider than the fighter.
var taunt_lines: Array = ["HA!"]
var hurt_lines: Array = ["OW!"]
var specials_text := []  # [[input, name], ...] for menus
var _throw: MoveData


## Shrinks or grows hitboxes and projectile spawn points to match `size`.
func scale_moves() -> void:
	for key in moves:
		var m: MoveData = moves[key]
		m.hitbox = Rect2(m.hitbox.position * size, m.hitbox.size * size)
		if m.projectile.has("offset"):
			m.projectile["offset"] = m.projectile["offset"] * size


## Pose = idle, overlaid with the named base pose, this character's version of
## it, and finally `extra`.
func pose(pname: String, extra := {}) -> Dictionary:
	var p: Dictionary = FighterRenderer.POSES["idle"].duplicate()
	if pname != "idle":
		p.merge(FighterRenderer.POSES.get(pname, {}), true)
	p.merge(poses.get(pname, {}), true)
	p.merge(extra, true)
	return p


## The universal throw. Characters may override this to retune it.
func throw_data() -> MoveData:
	if _throw == null:
		_throw = MoveData.make({
			"id": "throw", "display": "THROW", "level": 1, "damage": 110, "knockdown": true,
			"kb": Vector2(6.5, -7.0), "hitstun": 24, "blockstun": 0, "hitstop": 10, "meter": 12.0,
			"hit_sfx": "heavy",
		})
	return _throw


# --- Behaviour hooks -------------------------------------------------------------
# These are what let a character own a *rule* instead of a number. They are all
# no-ops here, so a fighter that does not use them behaves exactly as before and
# `characters/<id>.gd` still holds the whole mechanic — see
# design/characters_redesign.md.

## Called from `Fighter.step()` once per physics frame, after the state machine
## has run. This is where a character keeps its own state: Ulises' ball is
## dribbled, re-possessed and launched from here.
func tick(_f: Fighter) -> void:
	pass


## Called from `Fighter.reset_for_round()`, before the round intro. A character
## that owns objects in the arena (Ulises' ball) puts them in the world here.
func on_round_start(_f: Fighter) -> void:
	pass


## Called from `Fighter._attack_step()` on every frame of an attack, just
## before a projectile of that move would spawn. Lets a character do timed
## things: Ulises kicks the ball on the first active frame.
func on_move_frame(_f: Fighter, _m: MoveData, _sf: int) -> void:
	pass


## Which move actually comes out of `key` for this fighter *right now*. The
## default returns `key` unchanged, so nobody else is affected. Characters
## override it to swap in a worse alternative when they are not set up.
func choose_move(key: String, _f: Fighter) -> String:
	return key


# Drawing hooks. `r` is the FighterRenderer, `s` its skeleton points.

## Called once per animation step to advance hair / cape chains (see FighterRenderer.chain).
func update_chains(_r: FighterRenderer, _s: Dictionary) -> void:
	pass


func draw_behind(_r: FighterRenderer, _s: Dictionary) -> void:
	pass


func draw_torso(_r: FighterRenderer, _s: Dictionary) -> void:
	pass


func draw_over_legs(_r: FighterRenderer, _s: Dictionary) -> void:
	pass


func draw_hair_back(_r: FighterRenderer) -> void:
	pass


## Small ear, for characters whose hair doesn't cover it (head space).
static func draw_ear(r: FighterRenderer) -> void:
	var col: Color = r.colors["skin"]
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(-5.5, 2.0), 2.0, 2.8, 0.0, 12), FighterRenderer.OUT)
	r.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2(-5.5, 2.0), 1.3, 2.1, 0.0, 12), col)
	r.draw_line(Vector2(-5.2, 1.0), Vector2(-5.0, 3.0), FighterRenderer.shade(col), 0.8, true)


func draw_face(r: FighterRenderer) -> void:
	r.face(colors.get("eyes", Color("3b2a20")))


func draw_hair_front(_r: FighterRenderer) -> void:
	pass


func draw_props(_r: FighterRenderer, _s: Dictionary) -> void:
	pass

