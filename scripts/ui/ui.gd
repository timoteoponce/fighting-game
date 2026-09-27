class_name UI
extends RefCounted
## Shared text and shape drawing helpers.

static var _arcade: FontVariation


## Chunky bold italic version of the built-in font, for arcade-style text.
static func arcade_font() -> Font:
	if _arcade == null:
		_arcade = FontVariation.new()
		_arcade.base_font = ThemeDB.fallback_font
		_arcade.variation_embolden = 1.0
		_arcade.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(-0.22, 1.0), Vector2.ZERO)
		_arcade.spacing_glyph = 1
	return _arcade


static func text(ci: CanvasItem, pos: Vector2, s: String, size := 16, col := Color.WHITE,
		align := HORIZONTAL_ALIGNMENT_CENTER, outline := 4, ocol := Color(0.05, 0.03, 0.1), font: Font = null) -> void:
	if font == null:
		font = ThemeDB.fallback_font
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


## Big arcade title text: drop shadow, thick outline, bold italic.
static func title(ci: CanvasItem, pos: Vector2, s: String, size := 32, col := Color(1, 0.9, 0.25),
		align := HORIZONTAL_ALIGNMENT_CENTER, ocol := Color(0.55, 0.05, 0.15)) -> void:
	var f := arcade_font()
	var o := maxi(4, size / 5)
	text(ci, pos + Vector2(size * 0.06, size * 0.08), s, size, Color(0, 0, 0, 0.6), align, o + 2, Color(0, 0, 0, 0.6), f)
	text(ci, pos, s, size, col, align, o, ocol, f)


static func gradient_rect(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	ci.draw_polygon(
		PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))


## Vertical gradient quad (any 4 points: top-left, top-right, bottom-right, bottom-left).
static func gradient_quad(ci: CanvasItem, pts: PackedVector2Array, top: Color, bottom: Color) -> void:
	ci.draw_polygon(pts, PackedColorArray([top, top, bottom, bottom]))


## Parallelogram slanted by `skew` pixels (MvC-style bars).
static func slant(r: Rect2, skew: float) -> PackedVector2Array:
	return PackedVector2Array([r.position + Vector2(skew, 0), Vector2(r.end.x, r.position.y), r.end - Vector2(skew, 0), Vector2(r.position.x, r.end.y)])


static func menu(ci: CanvasItem, items: Array, idx: int, center: Vector2, size := 18, spacing := 28) -> void:
	for i in items.size():
		var y := center.y + i * spacing
		var sel := i == idx
		if sel:
			gradient_quad(ci, slant(Rect2(center.x - 140, y - size - 3, 280, size + 12), 10.0), Color(1, 0.35, 0.6, 0.85), Color(0.6, 0.1, 0.4, 0.85))
		text(ci, Vector2(center.x, y), items[i], size, Color(1, 0.95, 0.4) if sel else Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 5, Color(0.05, 0.03, 0.1), arcade_font())
