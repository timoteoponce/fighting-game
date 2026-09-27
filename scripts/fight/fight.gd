class_name Fight
extends Node2D
## A match: two fighters, rounds, timer, hit detection, camera and menus.

const STAGE_W := 1000.0
const HALF_VIEW := 320.0
const WALL := 24.0
const PUSH_W := 34.0
const ROUNDS_TO_WIN := 2
const ROUND_FRAMES := 99 * 60

var fighters: Array[Fighter] = []
var projectiles: Array[Projectile] = []
var stage: Stage
var effects: Effects
var camera: Camera2D
var hud: Hud
var debug_draw: Node2D

var hitstop := 0
var freeze := 0
var freeze_owner: Fighter
var cutin_text := ""
var cutin_color := Color.WHITE
var slowmo := 0
var shake := 0.0

var round_num := 1
var wins := [0, 0]
var timer := ROUND_FRAMES
var phase := "intro"  # intro, fight, ko, over
var phase_t := 0
var winner := -1
var banner := ""
var banner_t := 0

var debug := false
var paused := false
var menu_items: Array = []
var menu_idx := 0
var menu_title := ""


func _ready() -> void:
	stage = Stage.new()
	stage.kind = ["field", "library"].pick_random()
	add_child(stage)
	var ids: Array = GameState.chars
	for i in 2:
		var f := Fighter.new()
		var src
		if GameState.mode == "vs" or (i == 0 and GameState.mode == "cpu"):
			src = PlayerInput.new(GameState.devices[i])
		else:
			src = CpuInput.new(GameState.cpu_level)
		f.setup(GameState.make_character(ids[i]), i, src, i == 1 and ids[0] == ids[1])
		f.fight = self
		add_child(f)
		fighters.append(f)
	fighters[0].opponent = fighters[1]
	fighters[1].opponent = fighters[0]
	effects = Effects.new()
	effects.z_index = 5
	add_child(effects)
	debug_draw = Node2D.new()
	debug_draw.z_index = 10
	debug_draw.draw.connect(_draw_debug)
	add_child(debug_draw)
	camera = Camera2D.new()
	camera.position = Vector2(STAGE_W * 0.5, 180)
	add_child(camera)
	camera.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.fight = self
	layer.add_child(hud)
	start_round()


func start_round() -> void:
	for p in projectiles:
		p.queue_free()
	projectiles.clear()
	fighters[0].reset_for_round(STAGE_W * 0.5 - 110.0, 1)
	fighters[1].reset_for_round(STAGE_W * 0.5 + 110.0, -1)
	for f in fighters:
		f.input_enabled = false
	timer = ROUND_FRAMES
	phase = "intro"
	phase_t = 0
	winner = -1
	hitstop = 0
	freeze = 0
	slowmo = 0
	stage.dim = 0.0
	var final: bool = wins[0] == ROUNDS_TO_WIN - 1 and wins[1] == ROUNDS_TO_WIN - 1
	_banner("FINAL ROUND" if final else "ROUND %d" % round_num)
	_update_camera()


func _banner(s: String) -> void:
	banner = s
	banner_t = 0


# --- Main loop ---------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	if paused:
		return
	for f in fighters:
		f.poll_input()
	if phase == "fight":
		for f in fighters:
			if f.is_human() and f.buf.pressed_now(Controls.START):
				_open_menu("PAUSE", ["RESUME", "CHARACTER SELECT", "TITLE SCREEN"])
				paused = true
				return
	effects.step()
	banner_t += 1
	shake = maxf(0.0, shake - 0.5)
	camera.offset = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	debug_draw.queue_redraw()
	if freeze > 0:
		freeze -= 1
		stage.dim = 1.0
		return
	if hitstop > 0:
		hitstop -= 1
		return
	if slowmo > 0:
		slowmo -= 1
		if slowmo % 2 == 1:
			return
	phase_t += 1
	for f in fighters:
		f.step()
	for p in projectiles:
		p.step()
	_resolve_hits()
	_resolve_bounds()
	_cleanup_projectiles()
	_update_camera()
	var hyper_on := fighters.any(func(f: Fighter) -> bool: return f.is_hyper_active())
	hyper_on = hyper_on or projectiles.any(func(p: Projectile) -> bool: return p.m.level == 3)
	stage.dim = move_toward(stage.dim, 1.0 if hyper_on else 0.0, 0.05)
	_update_phase()


func _update_phase() -> void:
	match phase:
		"intro":
			if phase_t == 70:
				_banner("FIGHT!")
				Sfx.play("confirm")
			if phase_t >= 100:
				phase = "fight"
				for f in fighters:
					f.input_enabled = true
					f.set_state(Fighter.S.IDLE, true)
					f.buf.clear()
		"fight":
			if timer > 0:
				timer -= 1
			var down := fighters.filter(func(f: Fighter) -> bool: return f.health <= 0)
			if not down.is_empty():
				_end_round("K.O.!")
				winner = -1 if down.size() == 2 else 1 - down[0].index
				slowmo = 60
				Sfx.play("ko")
			elif timer == 0:
				_end_round("TIME!")
				var h0 := fighters[0].health
				var h1 := fighters[1].health
				winner = -1 if h0 == h1 else (0 if h0 > h1 else 1)
		"ko":
			if phase_t >= 90 and winner >= 0:
				var w := fighters[winner]
				if w.state != Fighter.S.WIN and w.on_ground():
					w.move = null
					w.vel = Vector2.ZERO
					w.set_state(Fighter.S.WIN, true)
			if phase_t == 100:
				_banner("DRAW!" if winner < 0 else "%s!" % fighters[winner].def.display)
			if phase_t >= 210:
				if winner >= 0:
					wins[winner] += 1
				if winner >= 0 and wins[winner] >= ROUNDS_TO_WIN:
					phase = "over"
					phase_t = 0
					_banner("%s WINS!" % fighters[winner].def.display)
				else:
					round_num += 1
					start_round()
		"over":
			if phase_t == 70:
				_open_menu("", ["REMATCH", "CHARACTER SELECT", "TITLE SCREEN"])


func _end_round(text: String) -> void:
	phase = "ko"
	phase_t = 0
	_banner(text)
	for f in fighters:
		f.input_enabled = false


func on_hyper(f: Fighter, m: MoveData) -> void:
	freeze = 45
	freeze_owner = f
	cutin_text = m.display
	cutin_color = f.renderer.colors["shirt"]
	Sfx.play("hyper")
	effects.spawn("sparkle", f.position + Vector2(0, -60))


func spawn_projectile(f: Fighter, spec: Dictionary) -> void:
	var p := Projectile.new()
	p.setup(f, spec)
	p.z_index = 2
	add_child(p)
	projectiles.append(p)
	if int(spec.get("level", 2)) < 3:
		f.projectile = p
	Sfx.play(spec.get("sfx", "special"))


# --- Collisions ----------------------------------------------------------------

func _resolve_hits() -> void:
	var events := []
	for i in 2:
		var a := fighters[i]
		var d := fighters[1 - i]
		var hb := a.hitbox_world()
		var hu := d.hurtbox_world()
		if hb.has_area() and hu.has_area() and hb.intersects(hu):
			events.append([a, d, a.move, hb.intersection(hu).get_center(), null])
	for p in projectiles:
		if not p.can_hit():
			continue
		var d := p.owner_f.opponent
		var hu := d.hurtbox_world()
		var r := p.rect()
		if hu.has_area() and r.has_area() and r.intersects(hu):
			events.append([p.owner_f, d, p.current_hit(), r.intersection(hu).get_center(), p])
	# Projectiles from different players cancel each other; hypers win.
	for i in projectiles.size():
		for j in range(i + 1, projectiles.size()):
			var a := projectiles[i]
			var b := projectiles[j]
			if a.dead or b.dead or a.owner_f == b.owner_f or not a.rect().intersects(b.rect()):
				continue
			if a.strength <= b.strength:
				a.dead = true
			if b.strength <= a.strength:
				b.dead = true
			effects.spawn("heavy", (a.position + b.position) * 0.5)
			Sfx.play("block", 0.7)
	for e in events:
		_apply_hit(e[0], e[1], e[2], e[3], e[4])


func _apply_hit(a: Fighter, d: Fighter, m: MoveData, point: Vector2, p: Projectile) -> void:
	var from_x := a.position.x if p == null or p.anchored else p.position.x
	var res := d.take_hit(m, from_x)
	var blocked := res == "block"
	if p != null:
		p.register_hit()
	a.on_hit_landed(m, blocked)
	if blocked:
		effects.spawn("block", point, {"dir": signf(a.position.x - d.position.x)})
		Sfx.play("block")
		hitstop = maxi(hitstop, 4)
		return
	var heavy := m.level >= 1
	effects.spawn("heavy" if heavy else "hit", point)
	Sfx.play(m.hit_sfx)
	hitstop = maxi(hitstop, m.hitstop)
	if heavy:
		shake = maxf(shake, 3.0 + m.level)
	if (m.launch or m.knockdown) and randf() < 0.6:
		effects.word(point)
	if res == "ko":
		hitstop = 24
		shake = 9.0
		effects.word(point)


func _resolve_bounds() -> void:
	var a := fighters[0]
	var b := fighters[1]
	for pass_i in 2:
		var dx := b.position.x - a.position.x
		var solid := a.state != Fighter.S.KO and b.state != Fighter.S.KO
		if solid and absf(dx) < PUSH_W and absf(b.position.y - a.position.y) < 70.0:
			var s := signf(dx) if dx != 0.0 else float(a.facing)
			var push := (PUSH_W - absf(dx)) * (0.5 if pass_i == 0 else 1.0)
			if pass_i == 0:
				a.position.x -= push * s
				b.position.x += push * s
			else:
				# Someone is cornered: move whoever is further from the wall.
				var mover := b if absf(b.position.x - STAGE_W * 0.5) < absf(a.position.x - STAGE_W * 0.5) else a
				mover.position.x += push * (s if mover == b else -s)
		var cam := clampf((a.position.x + b.position.x) * 0.5, HALF_VIEW, STAGE_W - HALF_VIEW)
		for f in fighters:
			f.position.x = clampf(f.position.x, maxf(WALL, cam - HALF_VIEW + WALL), minf(STAGE_W - WALL, cam + HALF_VIEW - WALL))


func _cleanup_projectiles() -> void:
	for p in projectiles:
		if p.dead:
			p.queue_free()
	projectiles = projectiles.filter(func(p: Projectile) -> bool: return not p.dead)


func _update_camera() -> void:
	var mid := (fighters[0].position.x + fighters[1].position.x) * 0.5
	camera.position.x = clampf(mid, HALF_VIEW, STAGE_W - HALF_VIEW)
	stage.cam_x = camera.position.x


# --- Menus -------------------------------------------------------------------

func _open_menu(title: String, items: Array) -> void:
	menu_title = title
	menu_items = items
	menu_idx = 0


func _process(_delta: float) -> void:
	if menu_items.is_empty():
		return
	if Controls.any_just_pressed(Controls.UP) != Controls.NONE:
		menu_idx = posmod(menu_idx - 1, menu_items.size())
		Sfx.play("select")
	if Controls.any_just_pressed(Controls.DOWN) != Controls.NONE:
		menu_idx = posmod(menu_idx + 1, menu_items.size())
		Sfx.play("select")
	if paused and Controls.any_just_pressed(Controls.HEAVY) != Controls.NONE:
		_menu_action("RESUME")
		return
	if Controls.any_just_pressed(Controls.LIGHT | Controls.START) != Controls.NONE:
		Sfx.play("confirm")
		_menu_action(menu_items[menu_idx])


func _menu_action(item: String) -> void:
	match item:
		"RESUME":
			menu_items = []
			paused = false
			for f in fighters:
				f.resync_input()
		"REMATCH":
			menu_items = []
			wins = [0, 0]
			round_num = 1
			for f in fighters:
				f.meter = 0.0
			start_round()
		"CHARACTER SELECT":
			GameState.goto("select")
		"TITLE SCREEN":
			GameState.goto("title")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_F1:
		debug = not debug


func _draw_debug() -> void:
	if not debug:
		return
	for f in fighters:
		var hu := f.hurtbox_world()
		if hu.has_area():
			debug_draw.draw_rect(hu, Color(0.2, 1, 0.3, 0.9), false, 1.5)
		var hb := f.hitbox_world()
		if hb.has_area():
			debug_draw.draw_rect(hb, Color(1, 0.1, 0.1, 0.45))
		var label := "%s f%d" % [Fighter.S.keys()[f.state], f.sf]
		if f.move:
			label += " " + f.move.id
		UI.text(debug_draw, f.position + Vector2(0, -118), label, 10)
	for p in projectiles:
		debug_draw.draw_rect(p.rect(), Color(1, 0.5, 0.1, 0.4))
