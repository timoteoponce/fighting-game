# PJ's Clash

A 2D fighting game in the style of Marvel vs Capcom. The stage and the
fighters in a match are drawn in code, so the body can move every frame.
The paintings in `art/portraits/` are the title and character-select portraits.

Music is synthesized in code too: a mellow track for the menus and a driving
one for the fight, with a short fanfare when a match is won. Drop `.ogg`,
`.wav`, or `.mp3` files in `music/` and those play instead, in order, quietly,
behind the menus and the match.

Six stages, picked at random each match: a soccer stadium at dusk, a magic
library hall, a rooftop at night, a dojo at sunset, a beach at sunset and a
snowy park.

- **Ulises**: soccer, running, reading and video games. Fast, and he plays with a
  real ball that rolls around the stage — with it at his feet he is quicker and
  hits harder, without it he is a much poorer fighter. His supers are a
  game-over beam and a slide down the length of the pitch, and he throws the
  controller into both.
- **Emilia**: wizard stories, anime, drawing and aerobics. High jumps, a long-range wand spark, and a doodle-dragon hyper.
- **Charlie**: basketball and crying. A skinny kid with a huge bald head and a nasty grin — slow, long reach, and the hardest single hits on the roster.
- **Silvan**: two years old, in pants and little boots, and somehow part puppy. Fastest walk and highest jump, weakest hits.

Everyone has **two supers** — see "Two supers, one meter bar" below.

Modes: **VS Player** (2 players, local) and **VS CPU** (Very Easy / Easy / Normal / Hard).

## Running on Linux (x86_64)

```sh
tar xzf PJsClash-linux-x86_64.tar.gz
cd PJsClash
./PJsClash.x86_64
```

- Needs a graphics card or driver with **OpenGL 3.3** (almost any PC from the last 12+ years; Mesa drivers are fine).
- The game starts in **fullscreen**. **F11** (or Alt+Enter) switches between fullscreen and a window.
  To start windowed: `./PJsClash.x86_64 --windowed`
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
| L + H | Power Shot (even with the field ball loose) | Wand Spark | Chest Pass | Bark Blast |
| Forward + L + H | Driving Tackle, or **Sprint Dash** with no ball | Cartwheel Rush | Fast Break | Puppy Dash |
| Down + L + H | Bicycle Kick (anti-air) | Star Jump (anti-air) | Rim Shot (anti-air) | Bouncy Bounce (anti-air) |
| Back + L + H, **full HYPER meter** | GAME OVER COMBO | SKETCHBOOK SUMMON | CRYBABY FLOOD | MOON HOWL |
| Up + L + H, **full HYPER meter** | FULL PITCH! | WAND BLITZ! | TEAR GEYSER! | FULL MOON! |
| ...with **all three** bars | FINAL SCORE!! | PAGE ONE HUNDRED! | SOBBING FIT! | THE WHOLE SKY! |
| ...with all three bars | THE LAST DITCH! | THE WHOLE CHAPTER! | ABSOLUTE DELUGE! | SUPER MOON! |

### Two supers, one meter bar

Every fighter has **two** supers and a full meter bar buys you either one, so
which direction you press is the whole decision:

- **BACK + L + H** is the heavy cinematic super — a screen-crossing beam, a
  summoned creature, a wave.
- **UP + L + H** is the faster, more situational one — Ulises slides the length
  of the pitch on his side, Emilia fires a solid bar of raw wand light, Charlie
  puts a geyser of tears straight up (good against jumpers), Silvan drops a
  pillar of moonlight (it comes from above, so stepping back does not help).

### The third bar: MAX supers

Banking two bars used to buy you nothing, because both supers cost one. Now **all
three bars** upgrades whichever super you press into its MAX version — a bigger,
longer, considerably nastier version of the same move. The gauge says
**MAX SUPER READY!!** when you can afford one.

| | MAX of hyper 1 (Back) | MAX of hyper 2 (Up) |
|---|---|---|
| Ulises | the beam fills the whole screen | an even longer slide down the pitch |
| Emilia | an enormous doodle dragon | one bar of light for the whole chapter |
| Charlie | the flood climbs past his head | a column that comes off the top of the screen |
| Silvan | the whole pack arrives, not two wolves | the moon comes down over the whole stage |

Two bars is not enough, so the input falls back to the ordinary super — you are
never left with a dead button.

UP is also the jump, so **UP + L + H works in the air too**: you can throw your
second super out of a jump, and holding Up a moment before the buttons still
comes out as the super rather than a jump into an ordinary air attack.

The meter gauge names both inputs as soon as it is full, so you can find the
second one without pausing.

### The ball (Ulises)

Ulises' Power Shot throws a soccer ball projectile whenever it is used:

- `Forward + L + H` is his sprint dash.
- He can throw Power Shot repeatedly without retrieving anything.

**Throw:** L + H while *touching* a grounded opponent grabs them instead of
firing the projectile. The victim can break it by pressing L + H back within
10 frames.

**Super combo:** L, L, H (the H launches) → hold **Up** to super jump → L, L, H in the air.

## Custom voices (record your own screams!)

Fighters shout on attacks, specials, hits, K.O. and wins. The voices are synthesized,
but you can replace any of them with real recordings: make a `voices` folder next to
`PJsClash.x86_64` and add WAV (16-bit) or OGG files named like this:

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

The mapping is saved per controller model (in `~/.local/share/godot/app_userdata/PJ's Clash/controls.cfg`
on Linux), so you only do this once. Two identical adapters share the same mapping.
Tip: if the D-pad does nothing, press the adapter's **Analog** button and set it up again.

## For developers

- Engine: **Godot 4.7** (GDScript). Fighters, stages, the HUD and hit effects are drawn in code, so a body can move every frame. `art/portraits/` is only the title and character-select paintings. Shouts and the soundtrack are synthesized until you drop files in `voices/` or `music/`.
- Run from source: `godot --path .` (opens fullscreen; F11 or Alt+Enter toggles). Engine flags such as `--windowed` go *before* the `--`.
- CPU vs CPU demo: `godot --path . -- --demo` (optional: `--chars=ulises,emilia --stage=library`; stages: field, library, rooftop, dojo, beach, snow)
- Jump to one screen: `godot --path . -- --screen=select` (`title`, `select`, `fight`, `setup`, `howto`). `--full-meter` starts the hyper bar full.
- Gameplay tests: `godot --headless --path . -- --test` (add `--balance` for a CPU win/damage report across every pairing — 60 matches with a four-fighter roster, more as the roster grows)
- Build for Linux: `./build_linux.sh` (needs the Godot 4.7 export templates) → `build/PJsClash-linux-x86_64.tar.gz`
- F1 during a fight shows the hitboxes, the hurtboxes and a readout of each fighter's state and frame count.

Code map:

- `autoload/controls.gd`: per-device input reading, joypad remapping and axis calibration.
- `autoload/game_state.gd`: match setup, screen switching, and the roster scanned from `characters/`.
- `scripts/fighter/fighter.gd`: fighter state machine, cancels, hits and blocking. It also aims the pupils at the opponent.
- `scripts/fighter/fighter_renderer.gd`: flat clothing on the posable skeleton, and a different face for each kid.
- `scripts/fighter/move_data.gd`: frame data, animation clips and the per-frame FX event track.
- `characters/*.gd`: each character's stats, frame data, poses, colours and the bits drawn on top of the body.
- `characters/_template.gd`: a complete, commented starting point for a new fighter.
- `scripts/fight/`: the match (rounds, collisions, camera), projectiles, stages and the HUD.
- `scripts/fight/effects.gd`: inked hits, blocks and dust, plus a small additive halo.
- `scripts/input/cpu_input.gd`: the CPU opponent (it sends the same button presses a player would).
- `scripts/ui/`: title, character select, how to play and controller setup screens. Portraits come from `scripts/ui/portrait.gd`.

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

## Changelog

Graphics uplift pass — making the game look and feel like a real release.

### Phase 0 — Anti-aliasing

- Enabled 4x MSAA on the arena `SubViewport` (`scripts/fight/fight.gd`). Every
  limb, stage polygon, spark and the F1 debug overlay is now anti-aliased
  instead of hard-jagged. Texture filtering stays nearest-neighbour, so the
  640x360 buffer still upscales crisply to 1080p.

### Phase 1 — Ground shadows

- Fighters had no contact shadow, so they read as floating. Added a soft
  elliptical shadow under each fighter (`FighterRenderer._draw_shadow()`),
  drawn first so it sits behind every limb.
- The shadow shrinks and fades as the fighter rises, so a jump arc visibly
  lifts it off the floor. It is compensated for the renderer's `base_scale`
  so it stays a true world-space ellipse.
- Wired from `Fighter._update_visual()`: `renderer.ground_y = GROUND_Y - position.y`.
- Afterimage ghosts (`copy_from`) and head-only portraits skip the shadow.

### Phase 2 — Post-processing

- Added a full-screen post-FX pass (`shaders/post_fx.gdshader`) on a `CanvasLayer`
  between the world and the comic/HUD layers, so it never touches the lettering.
- **Bloom**: bright-pass + 16-tap golden-angle spiral blur. This is what makes
  the already-additive hit sparks, projectiles and hyper glow actually glow
  instead of reading flat.
- **Impact frame**: a 1-2 frame white push on heavy/special connects, driven by
  a new `impact` value set in `_apply_hit` and decayed each frame.
- **Chromatic aberration**: radial, scaled by screen shake.
- **Vignette**: unified, replacing the per-stage hand-drawn one.
- The shader samples the screen with linear filtering even though the world
  upscales nearest-neighbour, so the bloom stays smooth.
- CanvasLayers now use explicit `.layer` values (post 10, comic 20, HUD 30)
  instead of relying on tree order at the default layer 1.

### Phase 3 — Foreground occluders

- Added `scripts/fight/foreground.gd`: dark, out-of-focus silhouettes drawn in
  front of the fighters to sell depth. Sits at `z_index` 4 — above the
  fighters, below the effects — so hit sparks still read on top.
- Parallax `f > 1` makes them move faster than the fighters, so they read as
  close to the camera.
- Per-stage occluders: near crowd (field), bookshelf + candle (library),
  railing + antenna (rooftop), pillar + lantern (dojo), palm frond + rock
  (beach), snowdrift + bare branch (snow).

### Phase 4 — HUD polish

- **Damage trail**: the red lifebar trail now catches up slower so recent damage
  reads, and flashes a bright leading edge for a few frames after each hit.
- **Combo counter**: pops (scales up) on every hit, then settles. Its colour
  climbs with the count — yellow, then orange, then hot red at 10+.
- Fixed a regression where the bloom threshold sat below the skin luminance,
  so the bloom bled a haze into the dark eye lines and the faces read wrong.
  Raised it to 0.90 so only genuinely bright things (white spark cores, the
  hyper flash) bloom.

### Phase 5 — Faces, clothes, ink hits

- **Every fighter in the match is their own character now.** Each one owns its
  head, torso, hands, shoes and face, and is drawn to match their painted
  portrait in `art/portraits/`: Ulises in the football kit with his trailing
  red band and a two-finger victory sign, Emilia in wide trousers with the gold
  star clip and the page she drew, Charlie as a bald egg with white socks, red
  sneakers and his snaggletooths, Silvan in the star tee with his tongue out and
  the bone held overhead. Every one of them blinks, squints into an attack and
  gets X eyes on a knockout.
- Limbs are one outlined ribbon of clothing (`cloth()`, `_arm()`, `_leg()`) on
  the same pose skeleton. A same-coloured thigh and shin is a single shape. A
  sleeve over a bare forearm, or a sock under shorts, is two pieces overlapping
  at the joint, so the colour break is a hem. Emilia's forearms are skin and
  her irises are brown, matching her portrait. Charlie's arms are bare. Hair,
  cape, ears and tail stay on their chains. Pose springs are unchanged.
- Hits are a white core, a thick black outline and a few spikes along the
  knockback (`Effects._draw_impact`). Lights are small, heavies bigger, hypers
  a short burst. Blocks are an outlined blue shard. Dust is a few soft clumps
  with an edge. The additive glow is only a small halo, and the bloom threshold
  stays at 0.90 so it does not fog the eyes.
- **Ulises matches his portrait in the fight.** The in-match body is a lean kid
  in the painted football kit, not the chibi mascot the old head suggested:
  spiked hair, the red headband still trailing on its chain, an open grin with
  one tooth and two blush strokes, a blue jersey with a white V and green
  shoulder flashes, white shorts with a green side stripe, solid blue socks and
  lime cleats. The menus still use `art/portraits/ulises.png`. Every white on
  him is the off-white `"white"` colour key, never `Color.WHITE`, so it stays
  under the bloom threshold and keeps its ink edge.
- **Every fighter owns its head, torso, hands and shoes.** The shared body is a
  circle head with a chin blob, a straight wedge torso, mitten hands and a
  five-point slipper. All four characters replace all four, via `head_outline()`,
  `torso_outline(r, s)`, `draw_hand(...)` and `draw_shoe(...)`, so nobody in a
  match is wearing the defaults.
- **Every fighter blinks and reacts.** Each one blinks on a timer (6 frames of
  every 190, calm only), shows X eyes on a knockout, a pupil sliding a ring when
  dizzy, closed arcs when winning, and a squints on an attack and when hit, via
  `CharacterDef.eye_style`. A character that overrides only the eye *shape*
  keeps the shared *vocabulary* and stands through a match with a permanent
  stare, so a character that owns its face owns all of that too.
- **Everyone has a victory.** Ulises raises a two-finger V and says "Reading is
  for winners!", Emilia holds up the page she just drew — "Page forty-one: you
  lose!", Charlie wins and immediately starts bawling — "Don't cry, it's just a
  game!", and Silvan cheers with both arms up and the bone overhead — "Good dog!
  ...I am a good dog!"
- **A connected string alternates limbs, for all four.** Any light-light chain
  reads like a KOF one-two: the first hit leads with the front limb, a cancel out
  of it leads with the back one while the first comes back to guard, and the
  third goes front again. It is `CharacterDef.adjust_attack_pose` calling the
  shared `cross_limbs`, and it is pose-only — no frame data or hitboxes move.

### The third meter bar finally means something

You could bank three HYPER bars but both supers cost one, so the third bar was
dead weight and there was nothing to save up for. Now **all three bars** upgrades
whichever super you press into its **MAX** version — bigger, longer and much
nastier: Ulises' beam fills the whole screen, Charlie's flood climbs past his
head, Silvan's moon comes down over the whole stage. Two bars is not enough, so
the input falls back to the ordinary super rather than becoming a dead button.
The gauge announces **MAX SUPER READY!!** when you can afford one.

### A super lands like one hit

A hyper used to arrive as ten to fourteen identical chip hits that each slammed the
screen to its whitest, so it read as a wash rather than a blow. Now:

- **Only the finishing hit punches.** The running hits breathe; the last one flashes
  the screen, hits the post-FX harder, and drops the world into a sixth of a second
  of slow motion so a dozen small hits resolve into one heavy landing.
- **The camera leans in** on whoever just fired, led slightly toward the opponent so
  the beam has somewhere to go. A super is the only thing besides a KO that moves the
  camera now.
- **The screen effects every super already asked for actually happen.** They were
  authored on the move but read from the projectile, so all four were silently doing
  nothing. They belong on the projectile spec, where they are now.

Also fixed: **Emilia's two supers fly across the arena** instead of sitting anchored
like everyone else's, which meant they crossed the opponent in about thirty frames
and could only land four of their ten hits — a third of the damage they advertised,
and never reaching the finishing hit at all. She now deals 208 instead of 109, and
every super on the roster can land all of its hits.

### Two supers per fighter

- **Everyone has a second super, on `UP + L + H`.** A full meter bar buys either
  one, so the direction is the decision: **BACK + L + H** is the big cinematic
  super, **UP + L + H** is the quicker, more situational one. Ulises slides the
  length of the pitch on his side, Emilia fires a bar of raw wand light, Charlie
  puts a geyser of tears straight up against jumpers, and Silvan drops a pillar
  of moonlight from above so stepping back does not save you.
- **`UP + L + H` also works in the air.** `UP` is both the jump and the only
  direction the special ladder left free, so a player who holds Up a beat before
  the buttons would otherwise jump and get an ordinary air attack. Resolving the
  input in the air as well means both orderings give you the super, and you can
  throw your second super out of a jump.
- **The meter gauge names both inputs** once it is full, so the second super is
  findable without pausing. There is deliberately no "which one is selected"
  marker — the direction is the selection and it is momentary, so anything that
  stayed lit would be a lie.
- **The CPU uses both**, picking one at random when it has the meter.

### The hyper pass

Hypers used to look like the fighter forgot to move. Three separate causes, all
fixed:

- **Two of the four hypers were frozen solid for their whole length.** Ulises and
  Emilia were still authored with the old two-pose form, which silently becomes a
  *two-key* animation clip — so the second pose was held motionless for the entire
  recovery, fifty frames of standing still. Charlie and Silvan already had real
  multi-key clips. All four now do: wind-up, strike, follow-through, settle. Each
  super also has an **impact pose** that gets snapped in the instant the beam or
  dragon connects, so a hyper visibly bites rather than just reaching.
- **The cut-in itself was a statue.** Activating a super stops the world for 56
  frames for the portrait cut-in — and the fighter was frozen along with it,
  stuck in the first frame of their wind-up for the entire cinematic. They now
  snap into a dedicated **charge pose** and hold it, with a slow swell through it,
  while the world is stopped. The opponent still does *not* get it: they are meant
  to be caught mid-reaction.
- **The cut-in was hidden behind a white screen.** The activation flash was set to
  the same 8 frames a knockout gets, so the artwork it was introducing was behind
  solid white for eight of its fifty-six frames. It is now a three-frame punch.

Nothing about frame data, damage or balance changed.

### After the graphics pass

- **Renamed to PJ's Clash.** The game was *Ulises vs Emilia: Ultimate Friends
  Showdown*; it is now *PJ's Clash*, which is also the build name, the window
  title, the windowed/fullscreen toggle and the `user://` save folder
  (`PJ's Clash/controls.cfg`). The old `build/UlisesVsEmilia*` tarball is
  obsolete — rebuild with `./build_linux.sh`.
- **Auto-chaining combos.** You no longer have to cancel by hand: a connecting
  light chains into another light (up to four in a row), and a connecting heavy
  or special chains into anything stronger. The super combo is
  **L, L, H → hold Up to super jump → L, L, H in the air**, and you can cancel
  a normal straight into a special with **L** then **L + H**.
- **Hit-effects overhaul.** Inked white-core hits with knockback-directed
  spikes, a combo counter on the HUD that pops and heats up with the count, a
  full-screen impact frame and shake on heavy connects, and the dropped-junk gag
  items that fly out of whoever you land a big hit on.
- **Victory celebration.** The winner gets their own win pose, expression and
  breathing animation, a burst of confetti in their colours, their `win_quote`
  in a speech bubble, a line they shout, and the camera pushes in on them while
  the loser stays down. The KO camera punches in on the loser first.
- **Four new stages**, bringing the roster of arenas to six: rooftop, dojo,
  beach and snow (alongside the original field and library).
- **Full-resolution graphics and no sprites.** Fighters, stages and the HUD are
  all drawn in code at 640x360 and upscaled to the window, so a body can move
  every frame; the painted portraits in `art/portraits/` are the only images in
  a match's menus.
- **Synthesized music.** A mellow track for the menus, a driving one for the
  fight and a short win fanfare, all generated in code — or drop your own files
  in `music/`.
