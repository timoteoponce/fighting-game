# PJ's Clash

A 2D fighting game in the style of Marvel vs Capcom. The stage and the
fighters in a match are drawn in code into a 320x180 buffer and scaled up, so
the game has a chunky KOF-era pixel look and the body can still move every
frame. The menus draw the same fighters, live.

The game opens on a short logo slam — the letters of **PJ'S CLASH** hit one
at a time, with a synthesized sting — and any button skips it to the menu.
Music after that is synthesized too: a mellow track for the menus and a driving
one for the fight, with a short fanfare when a match is won. Drop `.ogg`,
`.wav`, or `.mp3` files in `music/` and those play instead, in order, quietly,
behind the menus and the match. The logo sting still plays over them.

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

## Playing in a browser

The web build is a folder of static files (`index.html` and the files next to
it). Open it from a web server, not by double-clicking the html file.

The page asks you to click once before the game starts. That click is what
lets the browser play the logo sting. Keyboard and gamepad work the same as
on the desktop build. A phone, held sideways, gets a pad on the left and L
and H on the right. A computer does not show that pad.

A push to `main` builds this and copies it onto the server. See "For
developers" for the secrets that deploy needs, and `deploy/nginx/pjclash.conf`
for the one-time web server setup.

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

### First-run checklist (a fresh machine)

1. Untar somewhere the user can write to and run `./PJsClash.x86_64`.
2. The title screen opens fullscreen and shows the version in the bottom-left.
3. Open **OPTIONS**: move a volume and confirm the confirm-blip changes; set
   **STAGE** to a specific stage and start a match to confirm it sticks.
4. Open **CONTROLLER SETUP** if a pad is misread; the mapping is remembered for
   that controller model.
5. Optional folders live next to the executable and are picked up on launch:
   `voices/<character>/<line>.wav|ogg`, `music/*.ogg|wav|mp3`,
   `gamecontrollerdb.txt`. None are required.
6. Player settings land in `~/.local/share/godot/app_userdata/PJ's Clash/`.

## Controls

| Action | Gamepad | Keyboard P1 | Keyboard P2 |
|---|---|---|---|
| Move / jump / crouch | D-pad or left stick | W A S D | Arrow keys |
| Block | hold **away** from the opponent | | |
| **L**: light attack | Square or Cross | F | K |
| **H**: heavy attack (launches!) | Triangle or Circle | G | L |
| Pause | Start | Esc | Enter |

### Pause and options

**Start** pauses at any point in a match (intro, fight, or KO). The pause menu has:

- **RESUME** — back to the fight (H also resumes).
- **OPTIONS** — volumes (SFX / voices / music), rounds to win (1-3), timer on/off, and stage select. Changes save immediately and apply to the next match.
- **REMATCH** — restart the match from round 1.
- **CHARACTER SELECT** — back to character select (VS Player / VS CPU).
- **QUIT TO TITLE** — back to the title screen.

Settings are saved to `~/.local/share/godot/app_userdata/PJ's Clash/settings.cfg` on Linux.

### Special moves: press L and H together

| Input | Ulises | Emilia | Charlie | Silvan |
|---|---|---|---|---|
| L + H | Power Shot (even with the field ball loose) | Wand Spark | Chest Pass | Bark Blast |
| Forward + L + H | Driving Tackle, or **Sprint Dash** with no ball | Cartwheel Rush | Fast Break | Puppy Dash |
| Down + L + H | Bicycle Kick (anti-air) | Star Jump (anti-air) | Rim Shot (anti-air) | Bouncy Bounce (anti-air) |
| Back + L + H, **full HYPER meter** | GAME THUNDER! | CARTWHEEL ATTACK! | BASKETBALL RAIN! | MOONLIGHT HOWL! |
| Up + L + H, **full HYPER meter** | MURILLO!! | FELINE ATTACK! | CRYBABY FLOOD! | SUPER BITE! |
| ...with **all three** bars | FINAL SCORE!! | CARTWHEEL CYCLONE! | SOBBING FIT! | THE WHOLE SKY! |
| ...with all three bars | THE LAST DITCH! | THE WHOLE CHAPTER! | ABSOLUTE DELUGE! | THE WHOLE PUPPY! |

### Two supers, one meter bar

Every fighter has **two** supers and a full meter bar buys you either one, so
which direction you press is the whole decision:

- **BACK + L + H** is the heavy cinematic super — a bolt of lightning, a
  spinning cartwheel, a rain of basketballs, a pillar of moonlight. Emilia's is
  a *melee* super: she throws herself through you rather than firing anything.
- **UP + L + H** is the faster, more situational one, and two of the four are
  *melee*: Ulises runs in with a super kick (MURILLO) and Silvan crosses the
  whole stage biting (SUPER BITE). Emilia sends a tiger she drew (FELINE
  ATTACK) and Charlie floods the floor with tears (CRYBABY FLOOD).

### The third bar: MAX supers

Banking two bars used to buy you nothing, because both supers cost one. Now **all
three bars** upgrades whichever super you press into its MAX version — a bigger,
longer, considerably nastier version of the same move. The gauge says
**MAX SUPER READY!!** when you can afford one.

| | MAX of hyper 1 (Back) | MAX of hyper 2 (Up) |
|---|---|---|
| Ulises | the bolt fills the whole screen | an even bigger kick, off a full sprint |
| Emilia | a longer, faster wheel that spins twice | the big cat, drawn mid-leap |
| Charlie | a bigger rain, dropped from higher | the water comes up past his head |
| Silvan | the moon comes down over the whole stage | he crosses the stage twice, biting |

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

- Engine: **Godot 4.7** (GDScript). Fighters, stages, the HUD and hit effects are drawn in code into a 320x180 buffer, so a body can move every frame and the pixels stay chunky. There are no image files in the game at all. Shouts and the soundtrack are synthesized until you drop files in `voices/` or `music/`.
- Run from source: `godot --path .` (opens fullscreen; F11 or Alt+Enter toggles). Engine flags such as `--windowed` go *before* the `--`.
- CPU vs CPU demo: `godot --path . -- --demo` (optional: `--chars=ulises,emilia --stage=library`; stages: field, library, rooftop, dojo, beach, snow)
- Jump to one screen: `godot --path . -- --screen=select` (`splash`, `title`, `select`, `fight`, `setup`, `howto`, `options`). `--full-meter` starts the hyper bar full. `--demo` and any `--screen=` skip the logo slam.
- Gameplay tests: `godot --headless --path . -- --test` (add `--balance` for a CPU win/damage report across every pairing — 60 matches with a four-fighter roster, more as the roster grows)
- Build for Linux: `./build_linux.sh` (needs the Godot 4.7 export templates) → `build/PJsClash-linux-x86_64.tar.gz`
- Build for web: `./build_web.sh` (same templates, plus the web ones) → `build/web/`. Serve that directory over http.
- F1 during a fight shows the hitboxes, the hurtboxes and a readout of each fighter's state and frame count.

GitHub Actions (`.github/workflows/cicd.yml`) runs the tests on every push and pull request, exports the web build, and on a push to `main` copies it over SSH. Add these repository secrets. The first three are the same ones rent_tracker uses. The game does not read them at runtime.

| Secret | What it is |
|---|---|
| `SSH_PRIVATE_KEY` | Deploy key |
| `SSH_HOST` | Server |
| `SSH_USER` | SSH user |
| `DEPLOY_PATH` | Absolute directory the web build replaces. Use a directory that holds only this game. |

Nginx is installed once by hand from `deploy/nginx/pjclash.conf`. Point `root` at `DEPLOY_PATH`.

Code map:

- `autoload/controls.gd`: per-device input reading, joypad remapping and axis calibration.
- `autoload/game_state.gd`: match setup, screen switching, and the roster scanned from `characters/`.
- `scripts/fighter/fighter.gd`: fighter state machine, cancels, hits and blocking. It also aims the pupils at the opponent.
- `scripts/fighter/fighter_renderer.gd`: flat clothing on the posable skeleton, and the shared head, face, hands and shoes every fighter wears.
- `scripts/fighter/move_data.gd`: frame data, animation clips and the per-frame FX event track.
- `characters/*.gd`: each character's stats, frame data, poses, colours and the bits drawn on top of the body.
- `characters/_template.gd`: a complete, commented starting point for a new fighter.
- `scripts/fight/`: the match (rounds, collisions, camera), projectiles, stages and the HUD.
- `scripts/fight/effects.gd`: inked hits, blocks and dust, plus a small additive halo.
- `scripts/input/cpu_input.gd`: the CPU opponent (it sends the same button presses a player would).
- `scripts/ui/`: title, character select, how to play and controller setup screens. The title and select screens draw live `FighterRenderer`s, the same as a match.

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

The head, torso, hands and shoes are **not** per-character — they are the shared
shapes in `FighterRenderer`, and a new fighter gets them for free. What makes a
fighter different is what its file draws on top: the kit in `draw_torso` and
`draw_over_legs`, the hair in `draw_hair_back` / `draw_hair_front`, and its
`draw_face`, which should call `r.face(r.colors["eyes"])` and then add only what
is specific to it — a nose, a unibrow, a snaggletooth. The shared face already
handles blinking, X eyes on a knockout and the squint on an attack.

## Changelog

### Silvan actually looks two now

He was a small, straight wedge on a mop of hair. Now he is a big head on a
short, round body: a larger `head_scale`, a paunchier `build` and a soft belly
on the shirt with a little navel. Purely a look — his frame data, hitboxes and
movement are untouched.

### Emilia's heavy super is a cartwheel now

Her BACK + L + H super was a beam of wand light, which made two of her supers
the same "point the wand and fire" move. It is now **CARTWHEEL ATTACK!**: a
full sideways wheel, aerobics being her whole thing, that dashes through you
and kicks six times on the way past. It is a *melee* super with no projectile
at all, so it resolves as a run of small kicks into one heavy finish. The
three-bar version is **CARTWHEEL CYCLONE!**, a longer, faster wheel that spins
the whole way round twice. Her UP super (FELINE ATTACK!) is untouched.

Melee supers also got the payoff projectile supers already had: the screen
punch, flash and slow-motion catch used to require a projectile running out of
hits, so a melee super just stopped. A melee super now fires the finishing beat
on the last frame of its active window, after it has connected.

### Options, a real pause, and the first-run checklist

- **Options screen.** Volumes (SFX / voices / music), rounds to win (1-3), timer
  on/off and stage select, reachable from the title screen and from the in-fight
  pause menu. Changes apply live and save immediately to `settings.cfg`, so
  there is no apply button and nothing is lost on a crash.
- **Start pauses at any point**, not just mid-fight — during the round intro, the
  KO and the win pose too. The pause menu is now RESUME / OPTIONS / REMATCH /
  CHARACTER SELECT / QUIT TO TITLE (with the move list still on screen).
- **A version number** (`1.0.0`) is shown on the title screen.

### The supers finally look like sixteen different moves

- **The beams are one solid bar of light, not a rainbow.** The old beam was a
  grid of 8px squares walked through a hue ramp. At 320x180 that turned into a
  rainbow checkerboard where no single colour survived, the hitbox edge was
  unreadable and the pixel text on top was illegible. A beam is now drawn as one
  shape — a dark ink rim, a body, a hot spine, a muzzle cap and a few chunky
  energy bars — so you can read both what it is and exactly where it hits.
- **Every super has its own colour.** Sixteen supers share seven shapes, so the
  palette moved onto the move: a `"tint"` on the projectile spec, read through
  `Projectile.pal()`. Ulises' storm-blue GAME THUNDER is told apart from his
  white-gold FINAL SCORE at a glance, even though both are beams. Emilia's wand
  light is pink and her tiger orange; Silvan's moonlight is a warm gold pillar;
  Charlie's basketball is orange on its own dark halo.
- **Charlie finally has two different water moves.** A wide, low hitbox is the
  flood that rolls along the ground; a tall one is a geyser, a column of water
  climbing off him. Before this, both of his `tears` supers drew the same
  horizontal wave.
- **The word on the beam is legible.** "GAME THUNDER" and "FINAL SCORE" sit on a
  dark plate sized to the text and centred on its cap height, instead of
  disappearing into the beam.
- **Halos stop swallowing the screen.** They were scaled off the largest
  dimension and then scaled up again, which painted an opaque disc over half the
  view on a big projectile; they are now keyed off the smaller dimension and hug
  the body. A basketball keys its halo off the ball rather than its hitbox, so a
  small sprite inside a 34x40 box is no longer wrapped in a glow three times its
  size.

### The pixel look is back

- **The arena is pixelated again.** The world renders into a **320x180** buffer
  and is scaled up by an exact integer factor, instead of drawing at 640x360.
  Anti-aliasing is off (`Fight.world.msaa_2d = MSAA_DISABLED`) because it
  softens exactly the pixels this look is built on, and the ink line weight is
  back up to `INK = 2.4` — thin lines vanish at that resolution. This is the
  chunky KOF-era look the game had before the high-res pass.
- **The post-FX pass is gone.** A fullscreen bloom sampled the screen with
  *linear* filtering, which undid the pixels no matter what resolution it ran
  at, so `shaders/post_fx.gdshader` and its wiring were deleted. What you lose:
  the bloom halo, the chromatic-aberration shake cue, the full-screen impact
  frame and the vignette. What stays: the flat white screen flash (the HUD
  draws it as a plain rect), the victim's own white-out, camera shake, the ink
  hit sparks, the comic words and the slow-motion catch on a super's last hit.
- **The menus draw the fighters again.** The title and character-select screens
  build live `FighterRenderer`s and pose them every frame, the way they did
  before the painted portraits landed. The paintings in `art/portraits/` were
  only used by those two screens and the HUD, so they have been deleted —
  **the game now contains no image files at all**, and the menus and the match
  are unmistakably the same art.

### The fighters are back on the shared body

- **The portrait-matching pass is reverted.** For a while each fighter was drawn
  to match their painted portrait, with their own head outline, torso, hands,
  shoes and a fully hand-written face. That is gone. All four are the same
  shared figure again — circle head, wedge torso, mitten hands, slipper — and
  they are told apart by the kit drawn on top of it, which is how they looked
  before that pass.
- **What did not change:** everything else from that period stayed. Two supers
  per fighter plus their MAX versions, the hyper cut-ins, the ball machinery
  (dormant), the ink hit effects, ground shadows, the foreground occluders, the
  HUD polish, four new stages, the synthesized music, and the KOF limb-swap on
  connected strings.

Graphics uplift pass — making the game look and feel like a real release.

### Phase 1 — Ground shadows

- Fighters had no contact shadow, so they read as floating. Added a soft
  elliptical shadow under each fighter (`FighterRenderer._draw_shadow()`),
  drawn first so it sits behind every limb.
- The shadow shrinks and fades as the fighter rises, so a jump arc visibly
  lifts it off the floor. It is compensated for the renderer's `base_scale`
  so it stays a true world-space ellipse.
- Wired from `Fighter._update_visual()`: `renderer.ground_y = GROUND_Y - position.y`.
- Afterimage ghosts (`copy_from`) and the HUD cut-in portrait skip the shadow.

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

### Phase 5 — Clothes, ink hits, and the shared body

- **The fighters are back on the shared body.** Every kid in a match is the same
  figure — a circle head with a chin blob, a straight wedge torso, mitten hands
  and a five-point slipper — and they differ by what each one draws on top:
  Ulises' headband and jersey trim, Emilia's cape, robe lapels and star clip,
  Charlie's jug-handle ears and unibrow, Silvan's curls and floppy ears.
- **Everyone blinks and reacts.** The face is shared and carries the whole
  vocabulary: a blink on a timer (6 frames of every 190, calm only), X eyes on
  a knockout, a pupil sliding a ring when dizzy, closed arcs when winning, and a
  squint on an attack and when hit. Pupils drift toward the opponent.
- **Limbs are one outlined ribbon of clothing** (`cloth()`, `_arm()`, `_leg()`)
  on the same pose skeleton. A same-coloured thigh and shin is a single shape.
  A sleeve over a bare forearm, or a sock under shorts, is two pieces
  overlapping at the joint, so the colour break is a hem. Hair, cape, ears and
  tail stay on their chains. Pose springs are unchanged.
- **Hits are a white core, a thick black outline and a few spikes along the
  knockback** (`Effects._draw_impact`). Lights are small, heavies bigger, hypers
  a short burst. Blocks are an outlined blue shard. Dust is a few soft clumps
  with an edge. The additive glow is only a small halo, because there is no
  bloom pass to catch it. Whites on a fighter are an off-white `"white"` colour
  key rather than pure white, so the thick ink keeps its edge around them.
- **Everyone has a victory.** Ulises holds up the book he was reading, Emilia
  raises her wand, Charlie bawls whether he wins or loses, and Silvan cheers
  with the bone overhead.
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
- **No sprites.** Fighters, stages and the HUD are all drawn in code, so a body
  can move every frame, and there are no image files in the game at all.
- **Synthesized music.** A mellow track for the menus, a driving one for the
  fight and a short win fanfare, all generated in code — or drop your own files
  in `music/`.
- **Logo slam.** The game opens on PJ'S CLASH, one letter at a time, with a
  generated sting. Any button skips to the menu. In the browser, click the
  loading picture or CLICK TO START so the sting can play. A push to `main` publishes the
  web build; see "Playing in a browser" above.
