# AGENTS.md

Godot **4.7** / GDScript 2D fighting game. `README.md` covers players, controls and
distribution — this file covers working on the code. Both are living notes: when
the code and a sentence here disagree, rewrite the sentence.

## First: a fresh clone cannot run

```sh
godot --headless --path . --import   # REQUIRED after clone / after pulling new scripts
```

Everything cross-file is referenced by Godot global `class_name`, not by `preload`.
Without an import pass the class cache is empty and *both* the game and the tests die
with `Parse Error: Identifier "Fight" not declared in the current scope`.

## Commands

```sh
godot --path .                                                  # play (starts FULLSCREEN; F11/Alt+Enter toggles)
godot --headless --path . -- --test                             # gameplay tests; exit 0 pass / 1 fail
godot --headless --path . -- --test --balance                   # + ~60 CPU-vs-CPU matches, every pairing (slow, no pass/fail)
godot --path . -- --demo                                        # CPU vs CPU
godot --path . -- --screen=select                               # jump straight to one screen
./build_linux.sh                                                # export tarball -> build/ (needs export templates)
./build_web.sh                                                  # export web -> build/web/ (needs the web templates too)
```

- **Args after `--` are read by the game** (`OS.get_cmdline_user_args()`, `scripts/main.gd:12`).
  Engine flags like `--windowed` / `--fullscreen` must go **before** the `--` or they are ignored.
- Full flag set: `--demo --test --balance --chars=a,b --stage=library --screen=NAME
  --full-meter`. Screens: `splash title select fight setup howto options`. The
  player-facing list is the README's "For developers" section. Cold boot is
  `splash`. `--demo` and any `--screen=` skip the logo slam; coming back from a
  match goes to `title`.
- **No linter, formatter or typecheck exists.** The test run is the local
  verification step. `.github/workflows/cicd.yml` runs that same test, exports
  the web build, and on a push to `main` copies it over SSH. Secrets and the
  one-time nginx site are in the README.
- **The web build is tuned for a phone.** `run/max_fps=60` (the sim is 60 Hz; a
  120 Hz panel would otherwise render twice the frames), the project-wide
  `anti_aliasing/quality/msaa_2d=0`, and Canvas Resize Policy **None** with
  `export/web_shell.html` sizing the canvas to the window at **pixel ratio 1**
  (Godot's Adaptive policy multiplies the backing store by the phone's ~2.5-3x
  ratio for a 320x180 game). The export is **threaded**
  (`variant/thread_support=true`), so the page must be cross-origin isolated:
  nginx sends COOP/COEP and the site must be HTTPS, or the game refuses to boot.
  Don't turn any of these back without a reason.
- `F1` toggles the debug overlay during a fight: each fighter's hurtbox (green
  outline), hitbox (filled red) and a `STATE f<frame> <move id>` label. It does
  **not** show inputs or full frame data. Read-only; great for tuning frame data.

## Where the character roster stands

The roster is *not* differentiated by mechanic: all four fighters share one
archetype (jab / launcher / low jab / sweep / air light / air spike / fireball /
dash / DP / hyper) with only the numbers changed. Making each fighter own a
mechanic was designed and prototyped once, then abandoned — see the two
paragraphs below, because the code and this file disagree in a way that will
bite you.

- **The `CharacterDef` behaviour hooks are real and still in use:**
  `tick`, `on_round_start`, `choose_move` and `adjust_attack_pose`. All four
  fighters use `adjust_attack_pose` for the alternating combo limbs; nothing
  uses the first three.
- **Ulises' contested ball is switched off.** `has_ball` returns a hardcoded
  `false`, `on_round_start` never spawns the ball and `tick` does nothing
  (commit `e220275`, "fixes ball-kick"). Power Shot is an ordinary projectile
  and `choose_move` always answers `"proj"`. `_spawn_ball`, `BALL_PICKUP`,
  `BALL_DRIBBLE`, `Fight._kicks` and the persistent `Projectile` lifecycle are
  all still in the tree and still work; nothing calls them. The supporting
  checks `tests/sim_test.gd:_test_ulises_ball` and `_test_ulises_ball_hyper`
  are **not called** and fail if you call them. Restoring the mechanic means
  un-stubbing those four functions and turning the two tests back on.
- **Next, if the roster work restarts:** per-character mechanics first (one
  resource or rule each, in that character's own file), then a character-aware
  `CpuInput`, then balance tuning. Asymmetric kits — taking moves *away* — are
  the cheapest first lever and need no engine work at all.

## Architecture (the parts filenames don't tell you)

- **One scene file only**: `scenes/main.tscn`. Every screen is built in code and swapped by
  `scripts/main.gd:_switch` (`Fight.new()`, `TitleScreen.new()`, `ArcadeScreen.new()`, ...).
  Don't go looking for `.tscn` files; to add a screen, add a `match` branch in `_switch` and
  call `GameState.goto("name")` (which is `call_deferred`, so it lands after the current frame).
- **The arcade run is `GameState` state, not a screen variable.** `mode == "arcade"` makes
  `Fight` hand P1 a `PlayerInput` and the opponent a `CpuInput`, force first-to-two rounds and
  take the opponent's level from `GameState.arcade_level()`. `start_arcade(id)` derives the
  ladder from `CHARACTERS` minus the pick plus `BOSS_ID`; `arcade_opponent/advance/done/continues`
  are the rest of the run. `scripts/ui/arcade_screen.gd` (`ArcadeScreen`) is the tower view
  *and* the win screen; a loss opens `CONTINUE?` on the fight's `menu_stack`, and CONTINUE
  replays the same bout. `arcade_advance` records `arcade_climb_from`, and the screen plays a
  Mortal-Kombat-style climb (one hop per rung) on entry — START skips it. There is no
  give-up on the tower any more; a run ends only by losing out of continues or quitting
  through the pause menu. The boss is the whole reason the `hidden` flag exists.
- **No script preloads anywhere.** Types resolve via `class_name` globals
  (`Fight`, `Fighter`, `MoveData`, `CharacterDef`, `FighterRenderer`, `UI`, ...) plus
  4 autoloads: `Controls` (input polling + joypad remap), `GameState` (match setup,
  screen switching, `make_character`), `Sfx` (synthesized audio, plus optional files
  in `voices/` and `music/`) and `Settings` (volumes, match rules and stage choice,
  saved to `user://settings.cfg`). Adding a `preload` would be off-style.
- **The match is drawn in code; a few recordings are files.** Fighters, stages, the
  HUD, the menus and synthesized SFX are all generated in code — there are no image
  files in the game at all. `design/` is a scratch directory kept out of the import via
  `design/.gdignore`; nothing in the game reads it. Optional voice clips load
  from `<exe dir>/voices/<char>/<line>.wav|ogg` or `res://voices/...` (`autoload/sfx.gd`).
  Optional music is the same idea for `music/` (`.ogg`, `.wav`, `.mp3`). Leave other
  people's tracks out of the build. The cold-boot sting is `Sfx.logo_cues()` /
  `build_logo_sting()`: nine hits spelling PJ'S CLASH, drawn by `SplashScreen`.
  It plays even when `music/` has files, and those files stay paused until the menu.
- **The body is clothing on the pose skeleton.** `FighterRenderer.cloth()`, `_arm()` and
  `_leg()` draw one outlined ribbon when a limb is a single colour, and two overlapping
  pieces when it changes colour at the elbow or knee (a hem). Pose springs, squash and
  hitstop stay in `Fighter`. Hits, blocks and dust are ink in `Effects._draw`, and the
  additive `glow` child is only a small halo, because there is no bloom pass to catch
  and a hyper is a short burst. **The title and character-select screens draw live
  `FighterRenderer`s, not images** (`title_screen.gd:_ready` and `char_select.gd:_ready`
  both build a `chibis` array and pose it every frame), so the menus and the match are
  the same art. There are no image files in the game at all.
- **The head, torso, hands and shoes are shared shapes, not hooks.** A circle head with
  a chin blob, a straight wedge torso, mitten hands and a five-point slipper, all in
  `FighterRenderer` (`head_shape`, `torso`, `fist` / `open_hand`, `shoe`). There is no
  `head_outline`, `torso_outline`, `draw_hand` or `draw_shoe` override — those were added
  for a portrait-matching pass and removed again. A character that wants real footwear or
  claws paints them on in `draw_over_legs` or `draw_props`. Every kid in a match is the
  same body, which is deliberate.
- **The face is shared too, and it carries the whole expression vocabulary.**
  `FighterRenderer.face(iris, girl)` is one function for all four, with `girl = true`
  giving Emilia the bigger lash-and-blush eyes. It switches on `expr`: blink (6 frames
  of every 190, calm only), X eyes on `ko`, a spiral on `dizzy`, pinprick pupils on
  `shock`, a raised lid on `smug`, closed arcs on `happy`/`win`, a squint per
  expression, plus `eye_pop` on a big hit. Pupils drift toward whoever is being looked
  at, via `renderer.gaze`, which `Fighter._update_visual` points at the opponent.
  **A character's `draw_face` should call `r.face(...)` first and then draw only what is
  specific to it** — a nose, a unibrow, a snaggletooth. Do not reimplement the eyes: a
  face that overrides the eye *shape* and drops `expr` ends up as a permanent stare,
  which is easy to miss in a screenshot and obvious in a match. If a new fighter does
  need its own eyes, copy the whole `match expr` block rather than one case.
- **Generic behaviour lives on `CharacterDef`.** One shared default exists because more
  than one character needed it: `cross_limbs(p)`, the KOF limb swap a connected string
  uses. A character file should contain only what is genuinely its own.
- **Never fill with `Color.WHITE` on a fighter.** The ink is `INK = 2.4` at this
  resolution, and a true white fill swallows its own outline, so the shape reads as a
  gap rather than as white fabric or a sclera. A character that needs white paints it
  in a `"white"` colour key: Ulises uses `e6e0d2` for the shirt number and the sock
  stripes, Emilia for the blouse and the scarf, Charlie for his snaggletooth. Tiny
  specular dots are the exception — a catchlight *should* sparkle, and so should
  Emilia's wand tip, so those two keep `Color.WHITE`.
- **Pixel pipeline**: the arena renders into a **`320x180` `SubViewport`**
  (`Fight.world`, `Fight.BUFFER_SIZE`, `Fight.PIXEL = 0.5`) shown at an exact integer
  scale on a `640x360` logical screen (window override `1920x1080`). This chunky
  look is the point, so three things protect it and must not be "improved" away:
  `Fight.PIXEL` must stay `0.5`, `Fight.world.msaa_2d` must stay `MSAA_DISABLED`
  (anti-aliasing softens exactly the pixels the look is built on) — and so must
  the project-wide `anti_aliasing/quality/msaa_2d`, which is what the *root*
  viewport (the scaled frame, HUD and menus) would otherwise multisample at the
  full canvas size, a 4x cost on a phone for no gain — and
  `FighterRenderer.INK` must stay `2.4` (thin lines vanish at 320x180). **There is no
  post-FX shader pass** — it was removed because a fullscreen bloom resamples the
  buffer with linear filtering and undoes the pixels. Nearest filtering is set on
  both the SubViewport and the TextureRect. Anything that must stay sharp (HUD,
  menus, comic words) belongs on a `CanvasLayer`, not in `world` — that's why `Hud` is
  parented to a `CanvasLayer` in `Fight._ready`.
- **The frame loop lives in `Fight._physics_process`** (60 Hz fixed, `physics_ticks_per_second=60`).
  `hitstop` / `freeze` / `slowmo` return *before* fighters step, so those frames intentionally
  don't advance the sim. `Fighter` is split into `poll_input()` (once per frame) and `step()`
  (per state).
- **Input does not use Godot's InputMap** — there are no `input/*` actions in `project.godot`.
  `Controls` polls `Input.is_physical_key_pressed` / `is_joy_button_pressed` into a 7-bit mask
  (`UP DOWN LEFT RIGHT LIGHT HEAVY START`). Fighters never see devices: `input_source.sample()`
  returns a mask. `CpuInput` returns the same mask shape and converts its relative
  `FWD`/`BACK` bits to absolute via `_to_abs(mask, facing)`, so fighter code is
  player/CPU-agnostic — keep it that way. A cellphone adds `Controls.TOUCH`,
  fed by `scripts/ui/touch_controls.gd`. `Controls.phone` is
  `is_phone_screen()`: the browser has touch points and the glass's short
  side is at most `PHONE_SHORT_MAX` (520 CSS px). That is the gap between a
  large phone and a small tablet, so a computer, a tablet and a touchscreen
  laptop stay on the keyboard and gamepad. A finger
  (`InputEventScreenTouch` → `Controls.adopt_touch()`) asks the browser
  again, for a page that was not ready at boot, and still refuses anything
  that is not a cellphone. A mouse click must not call it.
  The title rows are hit-tested (`UI.menu_index_at`). On fighter select the
  touch device is already player 1, and `CharSelect.column_bit()` maps a tap
  on the active name to left / light / right for one poll.

## Conventions that differ from defaults

- **Tabs**, `snake_case` locals (short: `f`, `p1`, `sf`, `m`), `##` one-line docstrings on
  classes and any non-obvious function, and deliberately heavy inline `#` commentary. Match it.
- **Move keys are a fixed 10-slot contract**: `L, H, cL, cH, jL, jH, proj, rush, anti, hyper`.
  `Fighter._try_normal` / `_try_special` index `def.moves[key]` directly, so every character
  **must define all 10** — a missing key is a runtime error, not a fallback.
- **`hyper2` is the one optional key**: the `UP + L + H` super. `_try_special` gates the UP
  rung on `def.moves.has("hyper2")`, so a fighter without one falls through to `proj` instead
  of swallowing the input, and `CharacterDef.REQUIRED_MOVES` deliberately still lists only ten.
  Extra keys beyond the ten have always been legal (Ulises has `"slide"` and `"tackle"`).
  **UP is the only direction the ladder left free** — down is anti-air, forward is rush,
  back is hyper — and it is *also the jump*, which is the whole awkwardness: `_try_special`
  runs before `_jump`, so pressing them together works from the ground, but a player who
  holds up first is already airborne by the time `L+H` arrives. `_try_air_special` resolves
  the same input in `S.JUMP` so both orderings work and you can super out of a jump.
- **`<key>_max` is the MAX super, and it is generic.** `MAX_METER` is 300 and
  `HYPER_COST` is 100, so with one key per super the third bar had no way to be spent — both
  supers cost one bar and the third was dead weight. `_try_special` (and `_try_air_special`)
  resolve `key + "_max"` whenever `meter >= Fighter.EX_COST` and the character defines it, so a
  fighter opts in by **defining the key** and nothing else. Set `"meter_cost": 300` on it;
  `Fighter.hyper_cost()` treats 0 as "the default" so nobody restates `HYPER_COST` on every
  super. Two bars is deliberately not enough: the input falls back to the ordinary super.
- **A level 3 move is gated on its *own* cost, and that is what keeps the meter sane.**
  `Fighter.can_pay()` is checked against the resolved move just before `_start_move`. The old
  code spent an unclamped `HYPER_COST` and relied on the caller having already checked, so a
  level 3 move arriving by any other route drove the meter below zero.
- **A hyper projectile must carry `"level": 3` in its own spec.** The one-projectile slot
  exemption (`Fight.spawn_projectile`) and the meter spend are both keyed on it, so a
  hyper that forgets it silently occupies the slot and fires for free. `_check_hyper_spec`
  checks this for every hyper the fighter defines.
- **A hyper does not have to be a projectile.** Six of the sixteen are *melee* — Ulises'
  `MURILLO`, Silvan's `SUPER BITE`, Emilia's `CARTWHEEL ATTACK` (and all three `_max`
  versions) have no `"projectile"` key at all and carry their damage on the move's own
  hitbox. `_check_hyper_spec` therefore accepts either form: a projectile hyper needs
  `"level": 3` plus a `shake`, while a melee hyper needs `hits >= 2`, a positive
  `hit_interval`, forward reach (`hitbox.size.x > 0`) and a `dash` or a `shake`. The
  reason to insist on `hits >= 2` is the same as for a projectile: a super has to be able
  to finish.
- **A melee super earns its finishing beat differently from a projectile one.** A
  projectile hyper reaches the payoff when its `hits_left` hits zero; a melee hyper has no
  projectile to run out, so `Fighter._attack_step` calls `Fight.hyper_finisher()` on the
  last frame of the active window (once it has connected), which is where the screen
  flash, the camera push and the slow-motion catch live. Without this a melee super just
  stopped, and `_test_hyper_landing` covers it because it drives the *first* hyper.
- **Ten hypers share seven projectile kinds, so the colour is on the move.** A `kind`
  picks the *shape* (`beam`, `wolf`, `tears`, `dragon`, ...) and `Projectile.pal(key)`
  picks the *colour*: the spec's `"tint"` dictionary wins key by key, and anything it
  omits falls back to `Projectile.TINTS` for that kind. Keys are `core` (hot centre),
  `mid` (body), `edge` (ink-side rim), `halo` (additive glow), and `label` / `label_ink`
  for a beam's pixel text. A `bball` is the exception that proves the halo rule: the ball is
  a 10px sprite inside a 34x40 hitbox, so its halo is keyed off the ball rather than the
  box — the shared formula wrapped it in a glow three times its size and it read as a brown
  ellipse, not a basketball. `tint` may also carry `text`, the word drawn on a wide beam.
  A character only needs a `"tint"` when two of its supers would otherwise look alike.
- **A beam is one shape, drawn as one shape.** `_draw_beam` lays down an ink rim, a
  `mid` body, a `core` spine and a few chunky 8px energy bars. It used to be a grid of
  8px cells walked through an HSV hue ramp, which at 320x180 was a rainbow checkerboard:
  no single colour survived, the hitbox edge was unreadable and the text was illegible.
  **Do not reintroduce per-cell hue.** The spine runs along the beam's long axis, so a
  `size` taller than it is wide is a pillar and needs the column branch.
- **Pixel text on a beam sits on an ink plate.** `draw_string` puts `pos.y` on the
  *baseline* and the glyphs sit above it, so the plate is sized to the cap height and
  centred *above* the baseline. Centring it on the origin leaves it hanging under the
  letters.
- **`tears` draws two different things.** A wide, low hitbox is the flood that rolls
  along the floor (`_draw_tears`); a tall one is the geyser, a column climbing off him
  (`_draw_geyser`). The branch is the same aspect test `_draw_beam` uses. Both read their
  colours from `tint`, so the flood and the geyser are told apart by palette as well as
  by shape.
- **A halo is keyed off the smaller dimension.** It used to scale by `maxf(size) * 0.9`
  and again by up to 2.35, which on a 200px dragon painted an opaque disc over half the
  screen. Beam halos also have to use the same orientation test as `_draw_beam`, or a tall
  pillar gets a wide slab beside it instead of a glow around it.
- `MoveData.hitbox` is relative to the fighter's **feet, facing right**. `CharacterDef.size`
  (body scale) does *not* rescale hitboxes automatically: the character must call
  `scale_moves()` at the end of `_init()` whenever `size != 1.0`.
- `MoveData.level` (0 light / 1 heavy / 2 special / 3 hyper) drives cancels in
  `Fighter._can_start`, the SFX and the voice line. Higher cancels lower; a chain of
  lights reaches four in a row (`chain < 4`).
- **Adding a character is one file.** Copy `characters/_template.gd`, rename the
  `class_name`, set `id`, drop the leading `_` from the filename. `GameState._scan_characters`
  finds it; there is **no list, no match statement and no audio table to edit**. Files
  starting with `_` are skipped, which is only reason the template isn't playable.
  `roster_order` sets select-screen position, `voice_pitch` (Hz, on `CharacterDef`) is all
  the synthesized shouts need. `tests/sim_test.gd:_test_character_def` validates every
  registered fighter, so a half-finished one fails with a clear message.
  **Setting `hidden = true` takes a finished fighter off the select screen** without taking
  it out of the registry: `_scan_characters` files it under `GameState.LOCKED` instead of
  `CHARACTERS`, so `make_character` still builds it and the arcade can face it. Only
  `character/luna.gd` (the boss, `BOSS_ID`) uses this today; the roster-wide tests reach it
  through `_all_ids()`.
  **Setting `damage_scale` above 1** makes every point the fighter deals count for that much
  more, chip included — `Fighter.take_hit` multiplies by the *attacker's* scale, and
  `Fight._apply_hit` / the throw pass it in. The roster leaves it at 1.0; the boss sets 1.3,
  so she is about 30% stronger without a single `MoveData` being restated. **Setting
  `health_scale` above 1** is the other half of a boss: `Fighter.setup` turns it into the
  instance's `max_health`, `reset_for_round` refills to that, and the HUD lifebar measures
  against `fr.max_health` (not the `MAX_HEALTH` constant) so a bigger bar still reads full.
  The boss sets 1.4.
- **A character can own a rule, not just a number.** `CharacterDef` has six
  behaviour hooks besides the drawing ones, all no-ops so nobody else is affected:
  `tick(f)` (once per step, after the state machine), `on_round_start(f)` (from
  `Fighter.reset_for_round`), `on_move_frame(f, m, sf)` (every attack frame, *just
  before the move's projectile spawns*, so a move can be re-scaled on the way out),
  `choose_move(key, f)` (swap in a variant of an input), `adjust_attack_pose(f, m, p)`
  (rewrite the pose a move is animating toward — this is how all four fighters
  alternate limbs across a combo), and `throw_data()`. The ten-key
  contract still holds:
  `choose_move` may only return keys the character actually defines.
- **Combo animation is per character, and it is pose-only.** `Fighter._pose_target`
  calls `def.adjust_attack_pose(self, move, p)` on every attack frame, so a character
  can vary how a move *looks* per hit of a string without touching frame data. The
  signal is `Fighter.chain`, already bumped in `_start_move`: 1 for a fresh attack,
  2-4 for a cancel out of one that connected. Ulises swaps front and back limb on even
  hits and leaves `level > 1` alone, because the bicycle kick already poses both legs.
  A chain cancel also forces a faster pose spring (`speed >= 0.85`), or the new limb
  still looks like the old one for several frames.
- **Ulises' ball machinery is dormant, not absent.** A `Projectile` has the
  `persistent` lifecycle: it outlives its `life`, sheds speed in `_roll()`, and
  `rest()` leaves it on the floor. It opts out of the "one projectile in flight"
  slot with `"slot": false`. Possession was *derived*
  (`absf(ball.x - f.x) <= BALL_PICKUP` while `rested`), never a flag, and a
  ball would be kept inside `Fight.view_bounds()` so it could never rest where
  the camera had left behind. `Fight._kicks(m)` decides who may boot it: either
  the move sets `"kicks": true`, or its hitbox reaches within 22px of the ground.
  All of this still works; `e220275` just stopped calling it (see the roster
  section at the top).
- **Adding a stage is one `match` branch.** `Stage.KINDS` (`scripts/fight/stage.gd`) is the
  registry — add the name there and a `_draw_<name>()` method, then add a branch in
  `Stage._draw`. `Fight._ready` picks from `Stage.KINDS` when `--stage` is empty. Every
  stage's floor must be drawn at or below `Fighter.GROUND_Y` (300) so the fighters' feet
  land on it, and the parallax helper `layer(f)` does the rest (`f=0` fixed to screen,
  `f=1` moves with the fighters).

## Animation clips and the FX event track

`MoveData` supports two authoring forms and `make()` desugars the old one into the new one,
so existing moves keep working untouched:

```gdscript
"pose_s": {...}, "pose_a": {...}        # startup pose, active pose (the simple form)

"keys": [[0, {...}, 0.5], [8, {...}, 0.95], [16, {...}, 0.35]]   # [frame, pose, approach speed]
"contact_pose": {...}                   # snapped to for a few frames when the move lands
"cutin_pose": {...}                     # held through the super-activation freeze
"events": {8: [["slash", {}], ["sfx", {"name": "whoosh"}]]}
```

- `Fighter._pose_target` reads the clip; `_fire_events(sf)` fires the track.
- **The simple form is a trap on anything long.** `pose_s`/`pose_a` desugars into a
  *two-key* clip, so `pose_a` is held, motionless, for the whole `active + recovery`.
  That is fine for a 14-frame jab and it is why Ulises' and Emilia's hypers used to look
  like a standing statue. Any move over ~30 frames wants real `keys`.
- **`cutin_pose` is what makes a hyper look alive.** `Fight` stops the simulation for
  `HYPER_FREEZE` (56) frames during super activation, and it returns *before* `f.step()`,
  so `sf` cannot advance — the body would sit on the clip's first key for the entire
  cinematic. `cutin_pose` is snapped in (speed 1.0) and held, with a slow sine swell on
  `lean`/`hip` so it is not a dead frame. Driven by `Fighter.cutin_active()`, which is
  true only for `Fight.freeze_owner`; the opponent deliberately does not get it, since
  they are supposed to be frozen in the pose they were caught in. `hyper_t` is the
  visual-only counter — `sf` must not advance, that is the whole point of a freeze.
  Every hyper is required to have one, a `contact_pose`, and a >=3-key clip that is
  still moving at `startup`; `_test_hyper_spec` (roster-wide) checks all three.
- **Only the finishing hit is allowed to punch the screen.** `Fight.flash` is a frame
  count the HUD draws as a flat white rect, and a level 3 move used to set it on all
  ten to fourteen hits, so the whole super sat white and read as a washed-out smear.
  Now the running hits leave it alone and `final_knockdown` supplies it on the last
  one, which is also where `HYPER_CATCH_SLOWMO` fires. `slowmo` skips every other sim
  frame, so it is about a sixth of a second.
- **A hyper is the only thing that moves the camera other than a KO or a win.**
  `_hyper_focus()` checks the fighter's move and then the live projectiles, because the
  two cover different halves of a super: the body is in its recovery while the beam is
  still chewing on the opponent. It pushes to `HYPER_ZOOM` and leans 34px toward the
  opponent, and the KO framing deliberately outranks it so a super that ends the round
  still gets the KO camera. `_update_camera` is skipped entirely during the cut-in
  freeze, which is fine — the HUD cut-in covers those frames.
- **A hyper's `flash` and `shake` live on the *projectile* spec, not on the move.**
  `_apply_hit` reads them off the `MoveData` it is handed, and for a projectile hit
  that is the one `Projectile.setup` builds from the spec — so a `"flash": 5` on
  the hyper *move* does nothing at all, which is exactly where all four used to
  sit. `final_knockdown` supplies the screen flash on the finishing hit; leave
  `flash` alone and use `shake` as the per-hit rumble. `flash` is a flat rect drawn
  by the HUD, not a shader uniform, so it survives the removal of post-FX.
- **A multi-hit hyper has to be able to finish.** `hits_left` reaching 0 is what
  triggers the finishing hit, and `_apply_hit` keys the screen punch, the flash
  and the slow-motion catch on it. Six of the eight hypers are `anchored: true`
  and sit in front of their owner, so they land every hit. **Emilia's two fly
  across the arena**, and when they were fast they crossed the opponent in about
  thirty frames and could only ever land four of ten — a third of the damage they
  advertise, and no finishing hit, so no punch and no catch. Her rule of thumb is
  the one to remember: keep `(size.x + hurtbox) / speed` comfortably longer than
  `hits * interval`, or anchor the projectile. `_test_hyper_landing` catches it.
- **A hyper can be several projectiles instead of several hits on one.** Charlie's
  `BASKETBALL RAIN` throws four balls over the super's startup: the move's own
  `"projectile"` fires the first, and `tick` spawns the rest on `RAIN_GAPS`. Each
  ball is a single-hit projectile, so **the last copy is the one that carries
  `final_knockdown`** — that is what still triggers the punch and the catch, and
  `_test_hyper_landing` asserts on the state after the run rather than on one
  `MoveData`. A character opts in by setting `CharacterDef.volley_count`, which is
  how `_check_hyper_spec` knows the hyper is allowed to be single-hit per ball.
- Event kinds (`Fighter._fire_event`): `slash`, `fx`, `dust`, `sfx`, `voice`, `shake`.
  `data.offset` is in the fighter's own space facing right, exactly like a hitbox.
- Events fire on **exact frames only, and never during hitstop** (`sf` does not advance
  while frozen, so an event authored on a hitstop frame is silently skipped). Author with
  margin.
- A default `slash` is injected at `startup + 1` **only** when the move has a hitbox and the
  author wrote nothing at that frame. Authoring any event there replaces it. Note `slash`
  early-returns when the move has no hitbox, so it is a no-op on every hyper.
- Impact feedback: `Fighter.contact` (contact-pose countdown) and `shook` (jitter) are set
  during hit resolution, which runs *after* fighters step, so `Fight` calls
  `Fighter.freeze_visual()` from the hitstop branch to make those frames visible.

## The input map (only two attack buttons — keep it that way)

| Mechanic | Input | Notes |
|---|---|---|
| Ground dash / forward roll | double-tap forward | passes through the opponent, invulnerable frames 4-13 |
| Backdash | double-tap back | 6 invulnerable frames |
| Air dash | double-tap a direction in the air | one per jump, halves gravity for 12 frames |
| Double jump | Up in the air | one per jump |
| Hyper 1 | `BACK+L+H`, full meter | also a cancel out of anything that connected |
| Hyper 2 | `UP+L+H`, full meter | resolves in the air too, so it is an air super as well |
| MAX hyper | either of the above with **all 3** bars | same input, bigger move, costs the whole meter. Two bars is not enough — it falls back to the ordinary super |
| Throw | `L+H` within `THROW_RANGE * def.size` of a grounded opponent | unblockable; victim breaks with `L+H` within 10 frames. Outside that range `L+H` is still `proj` |
| Air block | hold away in the air | |
| Quick-rise | any input during `KNOCKDOWN` after frame 10 | |

Double-tap detection lives in `InputBuffer.double_tapped()` / `consume_tap()`. `_jump()` must
`buf.consume(Controls.UP)` or the ground jump immediately re-triggers as a double jump.

**`_try_throw()` runs before `_try_special()` in `_ground_step`, for every direction.** A close
`L+H` is therefore a throw and *not* a hyper, whichever hyper you were reaching for. That is
deliberate, and it is the first thing that bites a test firing several supers in a row: the
opponent is left standing next to you and the next `L+H` quietly becomes a throw, which sets
no `move` at all — so `_watch_move` returns an empty list and the failure reads as though the
input did nothing. Move the opponent out of range before scripting another super.

## Controllers (cheap PSX/PS2 USB adapters are the target)

- `Controls` keeps a **per-GUID resting-axis baseline** (`_rest`, `set_rest`, `rest_of`),
  subtracted in `binding_active`. Without it, an adapter whose stick rests off-centre holds a
  direction forever. The setup screen captures it on button release.
- `ControllerSetup` allows **several bindings per action** (press more buttons, START to move
  on) — it used to silently replace the default's second face button.
- `default_mapping(dev)` adds hat-as-axis (6/7) bindings **only when `not Input.is_joy_known(dev)`**.
  On a recognised pad those axes are often triggers resting at -1, which would jam a direction.
- Community mappings load from `gamecontrollerdb.txt` in `user://`, `res://` or next to the
  executable — prefer that over inventing GUID tables you cannot verify.
- `Controls.device_changed` fires on hot-plug; `Fight._on_device_changed` auto-pauses.

## Settings and pause

- **`Settings` (autoload) is the only place match rules live.** `Fight._ready`
  reads `Settings.rounds_to_win`, `Settings.timer_enabled` and `Settings.stage`;
  the old `ROUNDS_TO_WIN` / random-stage constants are gone. `Sfx.apply_volumes()`
  reads `Settings.sfx_volume` / `voice_volume` / `music_volume`, applied as
  `base_db + Settings.lin2db(v)`. Nothing else writes settings except the
  options screen and the in-fight options sub-menu, both of which call
  `Settings.save_settings()` on every change.
- **`scripts/ui/options_screen.gd` is a normal screen** (`main.gd:_switch`
  branch `"options"`), reached from the title screen and returning to
  `GameState.options_return`. The pause menu does **not** navigate there: it
  pushes an `"OPTIONS"` sub-menu onto `Fight.menu_stack`, so the match is never
  torn down to change a volume.
- **The pause menu is a stack, not three variables.** `Fight.menu_stack` holds
  `{title, items, idx}`; `_current_menu()` is the top, `_open_menu` pushes and
  `_close_menu` pops. `Hud._menu` reads it the same way, and `Hud._draw_options_values`
  draws the value column for the options sub-menu. `START` pauses in every
  phase (`intro`, `fight`, `ko`) — `fight.gd` checks it *above* the phase gate,
  guarded by `menu_stack.is_empty()` so it cannot stack on the over/win menu.
  The one exception is the round intro: `input_enabled` is false there, so
  `poll_input` pushes a zero mask and the START press never reaches the buffer.

## Testing quirks

- No framework, no test discovery, no name filter: `tests/sim_test.gd` runs every check from
  `_ready()`. To focus on one area, comment out the other calls there.
- A hyper freezes the world for `Fight.HYPER_FREEZE` frames before the move's `sf` advances,
  so a test that watches a hyper must run **more than ~75 frames** or it never reaches the
  startup frame. A test that asserts on a hyper's spec can pass vacuously this way.
- `_test_hyper_cutin` checks a hyper's *authoring* (a `cutin_pose`, a `contact_pose`, a
  >=3-key clip that still moves at `startup`, and a `"level": 3` projectile spec) and runs
  for every character from `_test_character_def`, on `hyper`, `hyper2` and both `_max`
  variants alike via `_check_hyper_spec`; the MAX ones additionally have to cost the
  whole meter and be a different move from the version they upgrade. It calls
  `h.pose_at(0)` first, because that is what builds the
  clip out of the `pose_s`/`pose_a` fallback — without it `keys` is empty and the checks
  pass vacuously against an unbuilt move. `_test_hyper_cutin` is the runtime half: it
  drives a real hyper, then asserts `sf` is held while `hyper_t` advances and the pose on
  screen is the cut-in pose.
- `_test_hyper_landing` watches the screen effect per frame — `flash`, `slowmo` and the
  camera push — and snaps the projectile's `MoveData` the moment it spawns, because by the
  end of the run `_cleanup_projectiles` has dropped it from `fight.projectiles` and the
  node is freed with the fight.
- `_test_specials` resolves what a move *should* be through `def.choose_move(key, f)`
  (`_expected`), because a character may swap in a variant of an input. A hard-coded
  `moves["proj"].id` is wrong the moment a character has two answers for one button.
- `_test_specials` covers **both** supers, for every roster entry, in both input orders —
  `UP` held a few frames before `L+H` (the airborne path, `_try_air_special`) and
  `UP+L+H` on one frame (the ground path, `_try_special`). Both are separate code and the
  second one is the one that proves the hyper did not swallow the jump first.
- `_test_roster_faces` is gone: it asserted that every character owns a `head_outline`,
  a `torso_outline` and the `eye_style` vocabulary, and none of those exist. Nothing
  checks the shared face any more, because a shared face cannot be checked headlessly.
- `_test_character_def` checks **every** move a character defines, not just the required ten,
  so extra moves (Ulises' Slide Kick) are held to the same bar.
- `_test_ulises_ball` and `_test_ulises_ball_hyper` exist but are **not called**, and they
  fail if you call them: they describe the contested ball, which `e220275` switched off.
  See the roster section at the top.
- The harness builds a `Fight`, calls `set_physics_process(false)` / `set_process(false)` and
  steps it by hand with `f._physics_process(1.0 / 60.0)`. **Logic placed only in `_process`
  never runs under test** — put testable per-frame work in `_physics_process`.
- Tests mutate the `GameState` autoload (`mode`, `chars`, `cpu_level`), so ordering matters.
- `_test_specials`, `_test_combo` and `_test_character_def` run for **every** roster entry, so
  a new character is covered the moment the file exists. Combo-test gaps are derived from the
  character's own `startup + hitstop + 1` — never hard-code frame numbers there, or a slower
  fighter fails a test about Ulises' timing. **The roster-wide loops use `_all_ids()`
  (`CHARACTERS + LOCKED`)**, so the hidden boss is held to the same bar even though she is not
  selectable; `_balance_report` stays on `CHARACTERS`, so a boss does not skew the numbers.
- `_test_arcade` covers the run: the ladder excludes the player, ends on `BOSS_ID`, forces
  first-to-two and wires P1 human / P2 CPU. `_test_roster` asserts the boss is in `LOCKED`,
  not `CHARACTERS`. `_test_damage_scale` proves the boss's `damage_scale`/`health_scale`
  really land, and `_test_arcade_ui` fakes a `Controls` edge to prove START begins a bout on
  the tower (and that HEAVY no longer gives up) — it mutes `screen_requested` first, because
  `GameState.goto` would otherwise hand the test over to the real Main scene.
- `cpu_level` is an index into `GameState.CPU_LEVELS` = `VERY EASY, EASY, NORMAL, HARD`
  (0-3). `CpuInput`'s `THINK` / `BLOCK_P` / `ANTI_AIR_P` / `COMBO_DROP_P` / `MOBILITY_P`
  tables must all stay the same length as that list.
- **`--balance` is noisy and must not be tuned against on a single run.**
  `per_pair` is 10 matches with a four-fighter roster and `CpuInput` calls
  `rng.randomize()`, so a pairing can legitimately report anywhere from 4-6 to
  8-2 for the same code. Run it twice before believing a number, and raise
  `per_pair` in `_balance_report` when you actually need signal. It is also
  *character-blind*: it measures the neutral game, so a mechanic the CPU does not
  think to use barely shows up in the numbers.
- Helpers worth reusing: `_new_fight(p1, p2)`, `_start(f)` (runs the 101-frame round intro),
  `_script(fighter, [[mask, frames], ...])`, `_watch_move(f, fighter, frames)`, `check(cond, what)`.
- The `WARNING: N ObjectDB instances were leaked at exit` line at the end of every run is
  pre-existing and harmless — the harness uses `free()`, not `queue_free()`. Don't chase it.

## Definition of done

1. `godot --headless --path . --import` is clean (no `SCRIPT ERROR`).
2. `godot --headless --path . -- --test` prints `FAILURES: 0`.
3. Anything touching damage, frame data or the roster also gets a
   `--test --balance` run; no pairing should be worse than roughly 7-3.
4. New mechanics have a test in `tests/sim_test.gd`; new characters need none
   (the roster-wide checks cover them).
5. `README.md` records every player-visible change: a move, a mode, a control, or
   how a fight looks and sounds (bodies, faces, hits, stages, the HUD, music).
   A rule in this file that no longer matches the game is updated in the same change.
6. GDScript type inference gotcha: `var x := <untyped array element>` fails to compile.
   Use a typed loop (`for bit: int in [...]`) or an explicit type.
