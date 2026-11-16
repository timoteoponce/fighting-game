extends Node2D
## Dev screen (`godot --path . -- --screen=icon`): renders the launcher icon
## with the game's own FighterRenderer — Ulises' bust on the title gradient —
## and quits. The PNG is committed, so phones, fresh checkouts and CI never
## need a GPU to have the icon.
##
## Needs a real rendering context, so it cannot run headless; a window appears
## for a fraction of a second. Re-run after changing the renderer or Ulises.

const SIZE := 432
const BG_TOP := Color("2a1660")
const BG_BOTTOM := Color("ff6fa8")
## Where the bust sits: renderer scale, and the head's home in the square. The
## bust spans ~93 local units (Ulises' hair spikes reach -31 in head space,
## ~45 units above the head, and the torso ends ~5 below the hip), so the scale
## keeps that span inside the square with margin for the adaptive-icon mask.
const FIG_SCALE := 3.3
const HEAD_AT := Vector2(0.44, 0.49)

var _vp: SubViewport
var _r: FighterRenderer
var _frames := 0


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://art")
	var stage := Node2D.new()
	stage.draw.connect(_draw_bg.bind(stage))
	_vp = SubViewport.new()
	_vp.size = Vector2i(SIZE, SIZE)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# Nearest: the icon is a chunky-pixel game's flag, not a smooth photo.
	_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_vp)
	_vp.add_child(stage)
	_r = FighterRenderer.new()
	_r.setup(load("res://characters/ulises.gd").new())
	_r.head_only = true  # the bust: torso and head, no limbs
	_r.base_scale = FIG_SCALE
	_r.facing = 1
	# The win expression (grin, closed-arc eyes) is the face the game ends on.
	_r.expr = "win"
	_r.gaze = Vector2.ZERO
	_r.update_pose(_r.def.pose("win"), 1.0)
	_r.t = 60.0
	stage.add_child(_r)
	# Park the head at HEAD_AT: in the bust the head sits about 43 units above
	# the hip, so the origin moves down by that much, scaled.
	_r.position = Vector2(SIZE * HEAD_AT.x, SIZE * HEAD_AT.y + 43.0 * FIG_SCALE)


func _draw_bg(ci: CanvasItem) -> void:
	UI.gradient_rect(ci, Rect2(0, 0, SIZE, SIZE), BG_TOP, BG_BOTTOM)


func _process(_delta: float) -> void:
	_frames += 1
	# A few frames: the SubViewport must present at least once, and pose chains
	# (hair) need a beat to settle after the snap.
	if _frames < 6:
		return
	var img: Image = _vp.get_texture().get_image()
	img.save_png("res://art/icon.png")
	print("icon screen: wrote art/icon.png (%dx%d)" % [img.get_width(), img.get_height()])
	# Composition diagnostics (the point of the tool): where the head landed
	# and the bust's ink box, in icon pixels. The head should sit near
	# HEAD_AT * SIZE with generous margin — the adaptive-icon mask crops the
	# outer ~third of the square.
	var head_px: Vector2 = _r.position + (_r.sk["head"] as Vector2) * FIG_SCALE
	print("icon screen: head at (%d, %d)" % [roundi(head_px.x), roundi(head_px.y)])
	print("icon screen: %s" % _ink_report(img))
	get_tree().quit()


## Numeric look at the rendered bust: the bounding box of everything that is
## not the background gradient, in pixels, plus how much of the square it
## fills. Keeps the framing honest without eyeballing the PNG.
func _ink_report(img: Image) -> String:
	var min_p := Vector2i(SIZE, SIZE)
	var max_p := Vector2i(0, 0)
	var hits := 0
	for y in SIZE:
		var bg := BG_TOP.lerp(BG_BOTTOM, float(y) / float(SIZE - 1))
		for x in SIZE:
			var c := img.get_pixel(x, y)
			# Colour distance by hand: Color has no distance_to.
			var d := Vector3(c.r - bg.r, c.g - bg.g, c.b - bg.b).length()
			if d > 0.25:
				hits += 1
				min_p = min_p.min(Vector2i(x, y))
				max_p = max_p.max(Vector2i(x, y))
	if hits == 0:
		return "no content pixels found (background only?)"
	var bands := ""
	for b in 8:
		var band_hits := 0
		for y in range(b * SIZE / 8, (b + 1) * SIZE / 8):
			var bg_b := BG_TOP.lerp(BG_BOTTOM, float(y) / float(SIZE - 1))
			for x in SIZE:
				var cb := img.get_pixel(x, y)
				var db := Vector3(cb.r - bg_b.r, cb.g - bg_b.g, cb.b - bg_b.b).length()
				if db > 0.25:
					band_hits += 1
		bands += "%d " % int(band_hits * 100.0 / (SIZE * SIZE / 8))
	return "ink box (%d, %d)-(%d, %d), covers %d%%; per-band %%: %s" % [
		min_p.x, min_p.y, max_p.x, max_p.y, int(hits * 100.0 / (SIZE * SIZE)), bands]
