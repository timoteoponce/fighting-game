class_name Portrait
extends RefCounted
## The painted stance of a fighter, cropped from design/characters into
## art/portraits/<id>.png by hand. Menus draw these. The fight still uses
## FighterRenderer, which can move.


static var _cache: Dictionary = {}


static func texture(id: String) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var path := "res://art/portraits/%s.png" % id
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[id] = tex
	return tex


## Stands `id` inside `box`, feet on the bottom edge. `flip` turns them to face the other way.
static func draw(ci: CanvasItem, id: String, box: Rect2, flip := false) -> void:
	var tex := texture(id)
	if tex == null:
		return
	var sz := tex.get_size()
	var fit := minf(box.size.x / sz.x, box.size.y / sz.y)
	var w := sz.x * fit
	var h := sz.y * fit
	var x := box.position.x + (box.size.x - w) * 0.5
	var y := box.position.y + box.size.y - h
	var shadow := Rect2(x + w * 0.2, y + h - 7.0, w * 0.6, 9.0)
	ci.draw_set_transform(shadow.get_center(), 0.0, Vector2(shadow.size.x * 0.5, shadow.size.y * 0.45))
	ci.draw_colored_polygon(FighterRenderer.ellipse_pts(Vector2.ZERO, 1.0, 1.0), Color(0, 0, 0, 0.32))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if flip:
		ci.draw_set_transform(Vector2(x + w, y), 0.0, Vector2(-fit, fit))
		ci.draw_texture(tex, Vector2.ZERO)
	else:
		ci.draw_set_transform(Vector2(x, y), 0.0, Vector2(fit, fit))
		ci.draw_texture(tex, Vector2.ZERO)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
