# Ulises vs Emilia: Ultimate Friends Showdown

A 2D fighting game in the style of Marvel vs Capcom, with a roster of chibi
fighters drawn entirely in code — there is not a single image file in the repo.

- **Ulises**: soccer, running, reading and video games. Fast, with a soccer-ball shot and a pixel-beam hyper.
- **Emilia**: wizard stories, anime, drawing and aerobics. High jumps, a long-range wand spark, and a doodle-dragon hyper.
- **Charlie**: basketball and crying. A skinny kid with a huge bald head and a nasty grin — slow, long reach, and the hardest single hits on the roster.
- **Silvan**: two years old, still in diapers, and somehow part puppy. Fastest walk and highest jump, weakest hits.

Modes: **VS Player** (2 players, local) and **VS CPU** (Very Easy / Easy / Normal / Hard).

## Running on Linux (x86_64)

```sh
tar xzf UlisesVsEmilia-linux-x86_64.tar.gz
cd UlisesVsEmilia
./UlisesVsEmilia.x86_64
```

- Needs a graphics card or driver with **OpenGL 3.3** (almost any PC from the last 12+ years; Mesa drivers are fine).
- The game starts in **fullscreen**. **F11** (or Alt+Enter) switches between fullscreen and a window.
  To start windowed: `./UlisesVsEmilia.x86_64 --windowed`
- If the gamepad isn't detected, check that your user can read `/dev/input/event*`
  (`ls -l /dev/input/`). On most desktops this works out of the box; otherwise add
  your user to the `input` group: `sudo usermod -aG input $USER` and log in again.

## Controls

| Action | Gamepad | Keyboard P1 | Keyboard P2 |
|---|---|---|---|
| Move / jump / crouch | D-pad or left stick | W A S D | Arrow keys |
| Block | hold **away** from the opponent | | |
| **L**: light attack | Square or Cross | F | K |
| **H**: heavy attack (launches!) | Triangle or Circle | G | L |
| Pause | Start | Esc | Enter |

### Special moves: press L and H together

| Input | Ulises | Emilia | Charlie | Silvan |
|---|---|---|---|---|
| L + H | Power Shot (soccer ball) | Wand Spark | Chest Pass | Bark Blast |
| Forward + L + H | Sprint Dash | Cartwheel Rush | Fast Break | Puppy Dash |
| Down + L + H | Bicycle Kick (anti-air) | Star Jump (anti-air) | Rim Shot (anti-air) | Bouncy Bounce (anti-air) |
| Back + L + H, **full HYPER meter** | GAME OVER COMBO | SKETCHBOOK SUMMON | CRYBABY FLOOD | MOON HOWL |

**Throw:** L + H while *touching* a grounded opponent grabs them instead of
firing the projectile. The victim can break it by pressing L + H back within
10 frames.

**Super combo:** L, L, H (the H launches) → hold **Up** to super jump → L, L, H in the air.

## Custom voices (record your own screams!)

Fighters shout on attacks, specials, hits, K.O. and wins. The voices are synthesized,
but you can replace any of them with real recordings: make a `voices` folder next to
`UlisesVsEmilia.x86_64` and add WAV (16-bit) or OGG files named like this:

```
voices/ulises/light.wav    voices/emilia/light.wav     quick "Ha!"
voices/ulises/heavy.wav    voices/emilia/heavy.wav     strong "Hyaah!"
voices/ulises/special.wav  ...                         special move shout
voices/ulises/hyper.wav                                big hyper yell
voices/ulises/hurt.wav                                 getting hit "Ugh!"
voices/ulises/ko.wav                                   knocked out
voices/ulises/win.wav                                  victory "Yeah!"
```

Any file you leave out keeps its synthesized voice. Keep clips short (under a second).

## PS2 controllers with USB adapters

Generic PS2-to-USB adapters often aren't recognized, so their buttons come out scrambled.
To fix that, open **Controller Setup** from the title screen:

1. Press any button on the pad you want to set up.
2. Press each button it asks for: Up, Down, Left, Right, Light, Heavy, Start.
3. Try the buttons on the test screen, then press Start.

The mapping is saved per controller model (in `~/.local/share/godot/app_userdata/Ulises vs Emilia/controls.cfg`
on Linux), so you only do this once. Two identical adapters share the same mapping.
Tip: if the D-pad does nothing, press the adapter's **Analog** button and set it up again.

## For developers

- Engine: **Godot 4.7** (GDScript). Everything is drawn in code, so there are no image or sound files.
- Run from source: `godot --path .`
- CPU vs CPU demo: `godot --path . -- --demo` (optional: `--chars=ulises,emilia --stage=library`)
- Gameplay tests: `godot --headless --path . -- --test` (add `--balance` for a 60-match CPU win/damage report)
- Build for Linux: `./build_linux.sh` (needs the Godot 4.7 export templates) → `build/UlisesVsEmilia-linux-x86_64.tar.gz`
- F1 during a fight shows hitboxes and inputs.

Code map:

- `autoload/controls.gd`: per-device input reading, joypad remapping and axis calibration.
- `autoload/game_state.gd`: match setup, screen switching, and the roster scanned from `characters/`.
- `scripts/fighter/fighter.gd`: fighter state machine, cancels, hits and blocking.
- `scripts/fighter/fighter_renderer.gd`: the posable, code-drawn chibi.
- `scripts/fighter/move_data.gd`: frame data, animation clips and the per-frame FX event track.
- `characters/*.gd`: each character's stats, frame data, poses and drawing details.
- `characters/_template.gd`: a complete, commented starting point for a new fighter.
- `scripts/fight/`: the match (rounds, collisions, camera), projectiles, stages, HUD and effects.
- `scripts/input/cpu_input.gd`: the CPU opponent (it sends the same button presses a player would).
- `scripts/ui/`: title, character select, how to play and controller setup screens.

## Adding a character

A fighter is one file. There is no list to register in, no audio table and no
match statement to edit.

1. Copy `characters/_template.gd` to `characters/yourname.gd`.
2. Rename the class on line 1 — `class_name YournameDef` — and set `id` to a
   lowercase one-word name.
3. Drop the leading underscore from the filename. Files starting with `_` are
   skipped by the roster scanner, which is the only reason the template itself
   never shows up on the select screen.
4. Run `godot --headless --path . -- --test`. The character validation checks
   name every missing move, colour or out-of-range frame number, so a
   half-finished fighter fails with a clear message instead of crashing
   mid-match.

`roster_order` controls where the fighter sits on the select screen (lower comes
first), and `voice_pitch` is the only thing the synthesized shouts need — around
250 Hz reads as a boy, 330 Hz as a girl, 430 Hz as a toddler.
