class_name CharacterDef
extends RefCounted
## Base class for a playable character: stats, colors, moves, poses and the
## drawing hooks that give each fighter their own look.
##
## Move keys: L, H, cL, cH, jL, jH (normals), proj, rush, anti (specials), hyper.

var id := ""
var display := ""
var likes := ""
var colors := {}
var alt_colors := {}
var walk_speed := 3.0
var back_speed := 2.4
var jump_vel := -10.5
var jump_x := 3.6
var moves := {}
var poses := {}
var win_prop := ""
var intro_prop := ""
var win_quote := ""
var specials_text := []  # [[input, name], ...] for menus


## Pose = idle, overlaid with the named base pose, this character's version of
## it, and finally `extra`.
func pose(pname: String, extra := {}) -> Dictionary:
	var p: Dictionary = FighterRenderer.POSES["idle"].duplicate()
	if pname != "idle":
		p.merge(FighterRenderer.POSES.get(pname, {}), true)
	p.merge(poses.get(pname, {}), true)
	p.merge(extra, true)
	return p


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


func draw_face(r: FighterRenderer) -> void:
	r.face(colors.get("eyes", Color("3b2a20")))


func draw_hair_front(_r: FighterRenderer) -> void:
	pass


func draw_props(_r: FighterRenderer, _s: Dictionary) -> void:
	pass

