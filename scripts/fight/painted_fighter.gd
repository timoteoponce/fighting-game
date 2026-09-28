class_name PaintedFighter
extends Node2D
## Whole painted poses, swapped with the fighter's state. The drawings are not
## bent. A walk is two steps, a jump is a jump picture, a hit is a hit picture.


## Move id -> file in art/gameplay/<character>/, when that special was drawn.
const MOVE_FILE := {
	"power shot": "shot",
	"sprint dash": "sprint",
	"bicycle kick": "bicycle",
	"wand spark": "spark",
	"cartwheel rush": "rush",
	"star jump": "star",
	"chest pass": "pass",
	"fast break": "break",
	"crybaby flood": "cry",
	"bark blast": "bark",
	"puppy dash": "dash",
	"moon howl": "howl",
}

## Poses every fighter tries to load. Missing ones fall back down the list in _key.
const POSE_FILES := [
	"idle", "walk_a", "walk_b", "crouch", "block", "jump", "strike", "hit", "down", "back",
	"shot", "sprint", "bicycle", "spark", "rush", "star", "pass", "break", "cry", "bark", "dash", "howl",
]

const HEIGHT := 168.0

var fighter: Fighter
var _tex := {}


func setup(f: Fighter) -> void:
	fighter = f
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var id := f.def.id
	for pose_name in POSE_FILES:
		var path := "res://art/gameplay/%s/%s.png" % [id, pose_name]
		if ResourceLoader.exists(path):
			_tex[pose_name] = load(path)


func has_art() -> bool:
	return _tex.has("idle")


func _process(_dt: float) -> void:
	if fighter == null or not is_instance_valid(fighter):
		return
	visible = has_art() and fighter.visible
	z_index = 2 if fighter.position.y < Fighter.GROUND_Y - 1.0 else 1
	queue_redraw()


func _key() -> String:
	var key := "idle"
	match fighter.state:
		Fighter.S.WALK, Fighter.S.DASH:
			key = _walk_key()
		Fighter.S.BACKDASH:
			key = "back" if _tex.has("back") else "walk_a"
		Fighter.S.CROUCH:
			key = "crouch"
		Fighter.S.BLOCK:
			key = "block" if _tex.has("block") else "crouch"
		Fighter.S.JUMP:
			key = "jump"
		Fighter.S.LAUNCHED:
			key = "hit" if fighter.vel.y > 2.0 and _tex.has("hit") else "jump"
		Fighter.S.ATTACK:
			key = _attack_key()
		Fighter.S.HITSTUN, Fighter.S.THROWN:
			key = "hit"
		Fighter.S.KNOCKDOWN, Fighter.S.KO:
			key = "down" if _tex.has("down") else "hit"
		Fighter.S.GETUP:
			key = "crouch"
		Fighter.S.THROW:
			key = "strike"
		_:
			key = "idle"
	if not _tex.has(key):
		key = "idle"
	return key


func _walk_key() -> String:
	# Two drawn steps, held for 8 frames each. A fighter with only one step
	# drawing flips it for the other step.
	var phase := int(fighter.sf / 8) % 2
	if phase == 1 and _tex.has("walk_b"):
		return "walk_b"
	if _tex.has("walk_a"):
		return "walk_a"
	return "idle"


func _attack_key() -> String:
	if fighter.move != null:
		var file: String = MOVE_FILE.get(fighter.move.id, "")
		if file != "" and _tex.has(file):
			return file
		# A rising special with no picture of its own uses the jump drawing.
		if (fighter.move.air or fighter.move.rise_vel != Vector2.ZERO) and _tex.has("jump"):
			return "jump"
		if fighter.move.crouch and _tex.has("crouch"):
			return "crouch"
	if _tex.has("strike"):
		return "strike"
	return "idle"


func _extra_flip() -> bool:
	if not (fighter.state == Fighter.S.WALK or fighter.state == Fighter.S.DASH):
		return false
	if _tex.has("walk_b"):
		return false
	return int(fighter.sf / 8) % 2 == 1


func _draw() -> void:
	if fighter == null or fighter.fight == null or not _tex.has("idle"):
		return
	var key := _key()
	var tex: Texture2D = _tex[key]
	var zoom_k := fighter.fight.cam_z / Fight.ZOOM
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var h := HEIGHT * fighter.def.size * zoom_k
	var w := h * tw / th
	var cap := 280.0 * zoom_k
	if key == "down" or w > cap:
		w = minf(w, cap)
		h = w * th / tw
	var feet := fighter.fight.world_to_screen(fighter.position + fighter.renderer.position)
	# The lowest pixel of a cropped drawing sits on the floor, including a knockdown.
	var ay := 0.97 if key == "down" else 0.98
	var flip := fighter.renderer.scale.x < 0.0
	if _extra_flip():
		flip = not flip
	var origin := feet - Vector2(w * 0.5, h * ay)
	var sx := w / tw
	var sy := h / th
	if flip:
		origin.x += w
		sx = -sx
	var tint := Color(1.5, 1.5, 1.5) if fighter.flash > 0 else Color.WHITE
	draw_set_transform(origin, 0.0, Vector2(sx, sy))
	draw_texture(tex, Vector2.ZERO, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
