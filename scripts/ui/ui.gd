class_name UI
extends RefCounted
## Shared text drawing helpers.

static func text(ci: CanvasItem, pos: Vector2, s: String, size := 16, col := Color.WHITE,
		align := HORIZONTAL_ALIGNMENT_CENTER, outline := 4, ocol := Color(0.05, 0.03, 0.1)) -> void:
	var font := ThemeDB.fallback_font
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x := pos.x
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		x -= w * 0.5
	elif align == HORIZONTAL_ALIGNMENT_RIGHT:
		x -= w
	var p := Vector2(x, pos.y)
	if outline > 0:
		ci.draw_string_outline(font, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, outline, ocol)
	ci.draw_string(font, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


static func gradient_rect(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	ci.draw_polygon(
		PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))


static func menu(ci: CanvasItem, items: Array, idx: int, center: Vector2, size := 18, spacing := 28) -> void:
	for i in items.size():
		var y := center.y + i * spacing
		var sel := i == idx
		if sel:
			ci.draw_rect(Rect2(center.x - 130, y - size - 2, 260, size + 10), Color(1, 0.4, 0.7, 0.35))
		text(ci, Vector2(center.x, y), ("> %s <" if sel else "%s") % items[i], size, Color(1, 0.9, 0.3) if sel else Color.WHITE)
