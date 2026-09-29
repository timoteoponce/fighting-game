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
```

- **Args after `--` are read by the game** (`OS.get_cmdline_user_args()`, `scripts/main.gd:12`).
  Engine flags like `--windowed` / `--fullscreen` must go **before** the `--` or they are ignored.
- Full flag set: `--demo --test --balance --chars=a,b --stage=library --screen=NAME
  --full-meter`. Screens: `title select fight setup howto`. The player-facing
  list is the README's "For developers" section.
- **No linter, formatter, typecheck or CI exists.** The test run *is* the verification step.
- `F1` toggles hitbox / frame-data / input overlay during a fight. Read-only; great for
  tuning frame data.

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
  people's tracks out of the build.
- **The body is clothing on the pose skeleton.** `FighterRenderer.cloth()`, `_arm()` and
  `_leg()` draw one outlined ribbon when a limb is a single colour, and two overlapping
  pieces when it changes colour at the elbow or knee (a hem). Pose springs, squash and
  hitstop stay in `Fighter`. Each kid's eyes are `face()`, keyed by `def.id`; pupils
  follow `renderer.gaze`, which `Fighter._update_visual` points at the opponent. Hits,
  blocks and dust are ink in `Effects._draw`. The additive `glow` child is only a small
  halo, because `shaders/post_fx.gdshader` blooms anything above luminance 0.90, and a
  hyper is a short burst. Menu portraits, and the unused `scripts/fight/painted_fighter.gd`
  slideshow, are not the in-match body.
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
- `MoveData.hitbox` is relative to the fighter's **feet, facing right**. `CharacterDef.size`
  (body scale) does *not* rescale hitboxes automatically: the character must call
  `scale_moves()` at the end of `_init()` whenever `size != 1.0`.
- `MoveData.level` (0 light / 1 heavy / 2 special / 3 hyper) drives cancels in
  `Fighter._can_start`, the SFX and the voice line. Higher cancels lower; lights chain up to 3.
- **Adding a character is one file.** Copy `characters/_template.gd`, rename the
  `class_name`, set `id`, drop the leading `_` from the filename. `GameState._scan_characters`
  finds it; there is **no list, no match statement and no audio table to edit**. Files
  starting with `_` are skipped, which is only reason the template isn't playable.
  `roster_order` sets select-screen position, `voice_pitch` (Hz, on `CharacterDef`) is all
  the synthesized shouts need. `tests/sim_test.gd:_test_character_def` validates every
  registered fighter, so a half-finished one fails with a clear message.
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
"events": {8: [["slash", {}], ["sfx", {"name": "whoosh"}]]}
```

- `Fighter._pose_target` reads the clip; `_fire_events(sf)` fires the track.
- Event kinds (`Fighter._fire_event`): `slash`, `fx`, `dust`, `sfx`, `voice`, `shake`.
  `data.offset` is in the fighter's own space facing right, exactly like a hitbox.
- A default `slash` is injected at `startup + 1` **only** when the move has a hitbox and the
  author wrote nothing at that frame. Authoring any event there replaces it.
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
| Throw | `L+H` within `THROW_RANGE * def.size` of a grounded opponent | unblockable; victim breaks with `L+H` within 10 frames. Outside that range `L+H` is still `proj` |
| Air block | hold away in the air | |
| Quick-rise | any input during `KNOCKDOWN` after frame 10 | |

Double-tap detection lives in `InputBuffer.double_tapped()` / `consume_tap()`. `_jump()` must
`buf.consume(Controls.UP)` or the ground jump immediately re-triggers as a double jump.

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
