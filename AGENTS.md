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
  --full-meter`. Screens: `splash title select fight setup howto`. The player-facing
  list is the README's "For developers" section. Cold boot is `splash`. `--demo`
  and any `--screen=` skip the logo slam; coming back from a match goes to `title`.
- **No linter, formatter or typecheck exists.** The test run is the local
  verification step. `.github/workflows/cicd.yml` runs that same test, exports
  the web build, and on a push to `main` copies it over SSH. Secrets and the
  one-time nginx site are in the README.
- `F1` toggles the debug overlay during a fight: each fighter's hurtbox (green
  outline), hitbox (filled red) and a `STATE f<frame> <move id>` label. It does
  **not** show inputs or full frame data. Read-only; great for tuning frame data.

## Where the character redesign stands

The roster is being rebuilt so each fighter owns a mechanic, not just numbers.
Full design in `design/characters_redesign.md`; this is the status.

- **Done — phase A, Ulises (the pilot).** He has a contested ball. The pattern
  to copy: the whole mechanic lives in `characters/<id>.gd` using the
  `CharacterDef` behaviour hooks; only the generic support is in the engine.
- **Next — phase B.** Emilia, Charlie and Silvan mechanics (sketched in the
  design doc), then command normals, air specials and EX variants on top.
- **Then — phase C.** A character-aware `CpuInput`, then real balance tuning.

To read the phase-A code in the order it runs:

1. `UlisesDef.on_round_start` → `_spawn_ball` → `Fight.spawn_projectile` — the
   ball is created, resting, and opts out of the projectile slot.
2. `Projectile.setup` / `_roll` / `rest` / `launch` — the persistent lifecycle.
3. `Fight._resolve_hits` → `_kicks` — who is allowed to boot it.
4. `UlisesDef.tick` — dribbling and re-possession (possession is *derived*).
5. `UlisesDef.choose_move` / `on_move_frame` — the kit swap and hyper sizing.
6. `tests/sim_test.gd:_test_ulises_ball` — the spec, written as assertions.

Things that were true of the *old* roster and are now the point of the work:
all four fighters shared one archetype (jab / launcher / low jab / sweep / air
light / air spike / fireball / dash / DP / hyper) with only numbers changed.
Phase B is where that actually gets broken up.

## Architecture (the parts filenames don't tell you)

- **One scene file only**: `scenes/main.tscn`. Every screen is built in code and swapped by
  `scripts/main.gd:_switch` (`Fight.new()`, `TitleScreen.new()`, ...). Don't go looking for
  `.tscn` files; to add a screen, add a `match` branch in `_switch` and call
  `GameState.goto("name")` (which is `call_deferred`, so it lands after the current frame).
- **No script preloads anywhere.** Types resolve via `class_name` globals
  (`Fight`, `Fighter`, `MoveData`, `CharacterDef`, `FighterRenderer`, `UI`, ...) plus 3
  autoloads: `Controls` (input polling + joypad remap), `GameState` (match setup, screen
  switching, `make_character`), `Sfx` (synthesized audio, plus optional files in
  `voices/` and `music/`). Adding a `preload` would be off-style.
- **The match is drawn in code; a few pictures and recordings are files.** Fighters,
  stages, the HUD and synthesized SFX are generated in code. Title and select portraits
  are `art/portraits/<id>.png` (`scripts/ui/portrait.gd`). Sheets in `design/` stay out
  of the import via `design/.gdignore` and are not game art. Optional voice clips load
  from `<exe dir>/voices/<char>/<line>.wav|ogg` or `res://voices/...` (`autoload/sfx.gd`).
  Optional music is the same idea for `music/` (`.ogg`, `.wav`, `.mp3`). Leave other
  people's tracks out of the build. The cold-boot sting is `Sfx.logo_cues()` /
  `build_logo_sting()`: nine hits spelling PJ'S CLASH, drawn by `SplashScreen`.
  It plays even when `music/` has files, and those files stay paused until the menu.
- **The body is clothing on the pose skeleton.** `FighterRenderer.cloth()`, `_arm()` and
  `_leg()` draw one outlined ribbon when a limb is a single colour, and two overlapping
  pieces when it changes colour at the elbow or knee (a hem). Pose springs, squash and
  hitstop stay in `Fighter`. Each kid's eyes are `face()`, keyed by `def.id`; pupils
  follow `renderer.gaze`, which `Fighter._update_visual` points at the opponent. Hits,
  blocks and dust are ink in `Effects._draw`. The additive `glow` child is only a small
  halo, because `shaders/post_fx.gdshader` blooms anything above luminance 0.90, and a
  hyper is a short burst. Menu portraits come from `art/portraits/<id>.png`
  (`scripts/ui/portrait.gd`); they are painted, and they are not the in-match body.
- **A character can replace the shared shapes.** Three optional hooks, detected with
  `has_method` so an absent one changes nothing: `head_outline()` (a head in head space,
  replacing the circle-plus-chin), `torso_outline(r, s)` (a torso in torso space,
  replacing the straight wedge) and `draw_hand(r, p, col, d, front, open)`. A fourth,
  `draw_shoe(r, foot, fwd, col)`, is a normal override rather than a `has_method`
  branch, because both its defaults *are* the shared shapes. All four are in use.
  **Owning the head also means owning its shading**: `_draw_head` only draws the shared
  jaw blob on the shared head, so a character with its own outline must shade the face
  in `draw_face` instead. `front` is false for the back hand.
- **Every fighter owns its face, and the renderer no longer has a switchboard.**
  `FighterRenderer.face()` was once 18 `who == ` branches for the four roster members
  plus a `match` in `eye_spots()`. That hardcoded the whole cast into the shared
  renderer, and it caused the worst bug of the redesign: a character could override its
  eye *shape* and silently keep the shared *vocabulary*, which is how Ulises stood
  through a whole match with a permanent stare. All four now draw their own
  `draw_face`, and `face()` is a generic default that `_template.gd` inherits. Do not
  add an `id ==` branch there; add a hook instead.
- **Generic behaviour lives on `CharacterDef`, art lives in the file.** Four defaults
  exist because more than one character needed them: `eye_style(expr, t)` (the
  expression vocabulary as a pure function), `cross_limbs(p)` (the KOF limb swap),
  `warm_shade(col, amount)` (skin shadow on the skin's own hue) and the two shape hooks
  above. A character file should contain only what is genuinely its own.
- **Owning a face means owning the whole expression vocabulary, not just the
  static shape.** The shared `face()` picks from: blink (6 frames of every 190,
  calm only), X on `ko`, a pupil sliding a ring on `dizzy`, closed arcs on
  `happy`/`win`, and a squint per expression, plus `eye_pop` on a big hit. A
  character that overrides only the eye *shape* and ignores `expr` ends up with
  a permanently open stare, which is easy to miss in a screenshot and obvious in
  a match. Ulises' `eye_style(expr, t)` is a pure function returning
  `happy` / `ko` / `dizzy` / `blink` / `open`, kept separate from the drawing so
  it is testable headlessly — pixel comparison is not, and the same rule applies
  to any character's mouth: give it the `dizzy` and `smug` variants or it will
  grin through a knockdown.
- **Owning a face means owning the whole expression vocabulary, not just the
  static shape.** `CharacterDef.eye_style(expr, t)` is the shared default and
  returns `happy` / `ko` / `dizzy` / `blink` / `open`: blink is 6 frames of
  every 190 and calm only, `ko` is X, `dizzy` slides a pupil around a ring,
  `happy`/`win` are closed arcs. A character that overrides only the eye *shape*
  and ignores `expr` ends up with a permanently open stare, which is easy to
  miss in a screenshot and obvious in a match. The same applies to the mouth:
  give it the `dizzy` and `smug` variants or it will grin through a knockdown.
  `eye_style` is a pure function so it is testable headlessly — pixel comparison
  is not, since the suite runs `--headless` where a SubViewport renders nothing.
- **Never fill with `Color.WHITE` on a fighter.** The bloom threshold means a true
  white fill glows, and the ink edge around it dissolves, so the shape reads as a
  pale smear instead of white fabric or a sclera. A character that needs white
  paints it in a `"white"` colour key under the threshold: Ulises uses `e6e0d2`
  (luminance 0.879) for the shirt number, the sock and shoe ticks, the V-neck and
  his tooth. Tiny specular dots are the exception — a catchlight *should* sparkle,
  so `FighterRenderer._almond` still uses `Color.WHITE` for that.
- **Shading skin: do not use the shared `shade()`.** `FighterRenderer.shade` lerps toward
  a purple, which on warm skin at this size reads as a grey scar rather than as form, and
  on Charlie's sallow yellow it reads as olive. Use `CharacterDef.warm_shade`, and keep
  it light: on a head 20 units wide anything stronger than ~0.2 reads as a hollow.
- **Pixel pipeline**: the arena renders into a `640x360` `SubViewport` (`Fight.world`,
  `Fight.PIXEL = 1.0`) shown 1:1 on a `640x360` logical screen (window override
  `1920x1080`). All gameplay/arena coordinates are 640x360 logical space, and
  `Fight.camera.zoom` already has `PIXEL` baked in. Nearest filtering is set on
  both the SubViewport and the TextureRect. Anything that must
  stay sharp (HUD, menus) belongs on a `CanvasLayer`, not in `world` — that's why `Hud` is
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
  player/CPU-agnostic — keep it that way.

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
- **A character can own a rule, not just a number.** `CharacterDef` has six
  behaviour hooks besides the drawing ones, all no-ops so nobody else is affected:
  `tick(f)` (once per step, after the state machine), `on_round_start(f)` (from
  `Fighter.reset_for_round`), `on_move_frame(f, m, sf)` (every attack frame, *just
  before the move's projectile spawns*, so a move can be re-scaled on the way out),
  `choose_move(key, f)` (swap in a variant of an input — this is how Ulises gets a
  carrying tackle only while he has the ball), `adjust_attack_pose(f, m, p)` (rewrite
  the pose a move is animating toward — this is how Ulises alternates limbs across a
  combo), and `throw_data()`. The ten-key
  contract still holds:
  `choose_move` may only return keys the character actually defines. Design doc:
  `design/characters_redesign.md`.
- **A character can also own its hand.** `CharacterDef.draw_hand(r, p, col, d,
  front, open)` is the *default* too: it calls `r.open_hand` or `r.fist`, so
  overriding can draw its own hand or fall back to those two. `front` is false
  for the back hand, which is how Ulises flashes a V with one hand only. Note the
  shared hand selection is `open := expr == "happy" or expr == "smug"`, so a
  `win` expression draws a **fist** unless the character overrides this.
- **Combo animation is per character, and it is pose-only.** `Fighter._pose_target`
  calls `def.adjust_attack_pose(self, move, p)` on every attack frame, so a character
  can vary how a move *looks* per hit of a string without touching frame data. The
  signal is `Fighter.chain`, already bumped in `_start_move`: 1 for a fresh attack,
  2-4 for a cancel out of one that connected. Ulises swaps front and back limb on even
  hits and leaves `level > 1` alone, because the bicycle kick already poses both legs.
  A chain cancel also forces a faster pose spring (`speed >= 0.85`), or the new limb
  still looks like the old one for several frames.
- **Ulises' ball is the reference mechanic.** It is a `Projectile` with the
  `persistent` lifecycle: it outlives its `life`, sheds speed in `_roll()`, and
  `rest()` leaves it on the floor. It opts out of the "one projectile in flight"
  slot with `"slot": false`, and of every other character's clash rules. Possession
  is *derived* (`absf(ball.x - f.x) <= BALL_PICKUP` while `rested`), never a flag.
  The ball is kept inside `Fight.view_bounds()` so it can never rest somewhere
  the camera has left behind and be unreachable for the rest of the round.
- **A ball is booted, not punched.** `Fight._kicks(m)` decides: either the move
  sets `"kicks": true`, or its hitbox reaches within 22px of the ground — which
  gives every character's crouching heavy for free. So combos are never broken by
  losing the ball, and a sweep is the universal way to steal it. A resting ball
  has `can_hit() == false` on purpose: a static damage box on the floor is a trap,
  not a toy.
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
- **Only the finishing hit is allowed to punch the screen.** The post-FX shader clamps
  the white `impact` mix at 0.8, and a level 3 move used to ask for `0.35 + 0.25 * 3 =
  1.1` — on all ten to fourteen hits — so the whole super sat pinned at the ceiling and
  read as a washed-out smear. Now `HYPER_TICK_IMPACT` (0.16) on the running hits and
  `HYPER_HIT_IMPACT` (0.62) on the last one, which is also where `HYPER_CATCH_SLOWMO`
  fires. `slowmo` skips every other sim frame, so it is about a sixth of a second.
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
  `flash` alone and use `shake` as the per-hit rumble.
- **A multi-hit hyper has to be able to finish.** `hits_left` reaching 0 is what
  triggers the finishing hit, and `_apply_hit` keys the screen punch, the flash
  and the slow-motion catch on it. Six of the eight hypers are `anchored: true`
  and sit in front of their owner, so they land every hit. **Emilia's two fly
  across the arena**, and when they were fast they crossed the opponent in about
  thirty frames and could only ever land four of ten — a third of the damage they
  advertise, and no finishing hit, so no punch and no catch. Her rule of thumb is
  the one to remember: keep `(size.x + hurtbox) / speed` comfortably longer than
  `hits * interval`, or anchor the projectile. `_test_hyper_landing` catches it.
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
- `_test_hyper_landing` watches the screen effect per frame and samples **`impact` before
  each step**, not after: it decays `-0.2` at the top of `_physics_process`, so reading it
  once the frame is done only ever shows the decayed value and misses the peak entirely.
  It also snaps the projectile's `MoveData` the moment it spawns, because by the end of the
  run `_cleanup_projectiles` has dropped it from `fight.projectiles` and the node is freed
  with the fight.
- `_test_specials` resolves what a move *should* be through `def.choose_move(key, f)`
  (`_expected`), because a character may swap in a variant of an input. A hard-coded
  `moves["proj"].id` is wrong the moment a character has two answers for one button.
- `_test_specials` covers **both** supers, for every roster entry, in both input orders —
  `UP` held a few frames before `L+H` (the airborne path, `_try_air_special`) and
  `UP+L+H` on one frame (the ground path, `_try_special`). Both are separate code and the
  second one is the one that proves the hyper did not swallow the jump first.
- A fighter that owns an object in the arena puts it in `fight.projectiles`, so assertions
  like "no projectile came out of the throw" must filter `not p.persistent`.
- `_test_character_def` checks **every** move a character defines, not just the required ten,
  so extra moves (Ulises' Slide Kick) are held to the same bar.
- The harness builds a `Fight`, calls `set_physics_process(false)` / `set_process(false)` and
  steps it by hand with `f._physics_process(1.0 / 60.0)`. **Logic placed only in `_process`
  never runs under test** — put testable per-frame work in `_physics_process`.
- Tests mutate the `GameState` autoload (`mode`, `chars`, `cpu_level`), so ordering matters.
- `_test_specials`, `_test_combo` and `_test_character_def` run for **every** roster entry, so
  a new character is covered the moment the file exists. Combo-test gaps are derived from the
  character's own `startup + hitstop + 1` — never hard-code frame numbers there, or a slower
  fighter fails a test about Ulises' timing.
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
