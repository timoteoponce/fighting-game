# Character redesign

A plan to make the four fighters an order of magnitude better, without adding
a single button. This is the design doc: nothing here is implemented yet.

## The problem

The engine is not the limit. `MoveData` already supports dashes, rising
invulnerable anti-airs, multi-hit rushes, projectiles, body spin and a
per-frame FX track, and `FighterRenderer` already springs, squashes and
follows chains. The roster just doesn't use any of it for depth.

All four characters are the same archetype with different numbers:

- the same ten move keys, and the same shape for each: a fast light, a
  launching heavy, a low light, a knockdown sweep, an air light, an air spike,
  a projectile, a rushing attack, an invulnerable anti-air and a hyper
  projectile;
- the same global cancel rule (higher level cancels lower, lights chain);
- the same 1000 health, the same meter gain, the same gravity;
- differences that are almost entirely `walk_speed` / `jump_vel` / `size` /
  damage, plus art.

So every matchup is the same rock-paper-scissors, and the way to "counter"
anything is to mash the same four buttons a beat faster. The characters read as
skins of one fighter.

Two things make it worse:

- **No home for per-character behaviour.** `CharacterDef` has drawing hooks
  only. There is no way for a character file to own a rule, a resource or a
  state machine, so anything beyond numbers has to leak into `Fighter` as a
  special case for everyone.
- **A character-blind CPU.** `CpuInput` sends the same masks regardless of who
  it is playing, so a niche kit is invisible in `--balance` and a bland kit is
  not punished.

## The goals

1. Every fighter owns **one mechanic nobody else has**, so the roster is
   bigger than the sum of its parts.
2. Move sets stay **asymmetric** — a character may not have a good fireball, or
   a good anti-air, on purpose.
3. **No new buttons and no motion inputs.** The two-button map in `AGENTS.md`
   stays. All new depth comes from *which* button, *with which direction*, and
   *in what state*.
4. **Readable for kids.** Every mechanic is visible on screen and needs no
   frame-perfect execution.
5. Still **one file per character**, still the fixed ten keys, still data-driven
   rather than a `match` on character id.

## The five pillars

**A. A signature mechanic per fighter.** A small resource or state that only
this fighter has. This is the big lever: it is what makes a character a
character.

**B. Asymmetric kits, not reskins.** Command normals (`FWD`/`UP`/`DOWN` + a
single button), an air special, and an EX-strength variant per character, with
the archetypes deliberately not shared. Charlie should have no fast fireball.
Silvan should trade all of his range for speed.

**C. Engine hooks that keep the one-file rule.** `CharacterDef` gains
behaviour hooks (`tick`, `on_round_start`, `choose_move`) and `MoveData` gains
a few fields. Every mechanic still lives in `characters/<id>.gd`.

**D. A CPU that knows the kit.** A small per-character preference table, so the
CPU uses each fighter properly and `--balance` measures the design instead of
the mash.

**E. A test per mechanic.** A mechanic nobody can test is a mechanic nobody can
balance.

## Pilot: Ulises, the playmaker

Ulises goes first because he already owns the field stage and already has a
ball prop, so the mechanic exercises props, projectiles and normals at once —
if it works on him, it works anywhere.

### The mechanic: a real, contested ball

Ulises plays with a **loose ball on the arena floor** that both players fight
over. It is the same object the game's art already implies: he dribbles it in
his intro pose, kicks it with Power Shot, and holds it up on his win screen.

- At the start of a round the ball rests at Ulises' feet, and he is in
  **possession** — which is *derived* (`ball.rested` and it is within
  `BALL_PICKUP` of him), never a hidden flag, so a player can read it.
- Kicking it sends it away as a projectile that **rolls to a stop** on the floor
  instead of vanishing. It can hit once while it is moving.
- **Walking over a resting ball re-possesses it**, with no extra button, and the
  ball eases along at his feet so it reads as dribbling.
- **A boot takes it off him.** A move boots the ball if it says `"kicks": true`
  or if its hitbox reaches the ground — which gives every character's
  crouching heavy for free. A standing punch leaves it alone, so a combo is
  never broken by losing the ball. This is why a sweep is the universal way to
  steal it.
- A resting ball does **no damage**. A static damage box on the floor is a trap,
  not a toy, so `can_hit()` is false while it is at rest.
- The ball is Ulises' — it is his to pick up, and it never hurts him. The
  opponent's answer is to boot it down the pitch, which makes it contested.
- Ulises in possession gets the better version of his kit. Out of possession he
  still has a full moveset, but a worse one.

### The moves

| Input | In possession | Out of possession |
|---|---|---|
| `L + H` (proj) | **Power Shot** — a fast, low, straight drive | **Slide Kick** — a short, low, projectile-free poke that boots a loose ball away |
| `FWD + L + H` (rush) | **Driving Tackle** — carries the ball, and the ball pops loose on the first active frame | **Sprint Dash** — as today, no ball interaction |
| `DOWN + L + H` (anti) | **Bicycle Kick** — as today | as today |
| `BACK + L + H` (hyper) | **GAME OVER COMBO** — the beam is wider | the beam at its normal size |
| normals | unchanged, and they never cost him the ball | unchanged |

Two notes on why this is a good design and not just a gimmick:

- The ball is **legible**: it is a ball, on the floor, and everyone can see
  whose it is. No HUD, no meter, no tutorial.
- It is **contested, not given**. The ball rewards you for playing toward the
  opponent, and the opponent has a real answer to it, so it adds a layer of
  play instead of a stat boost.

### The engine hooks it needed

All generic, none Ulises-specific, all additive:

1. **`CharacterDef.tick(f: Fighter) -> void`** — called once per step from
   `Fighter.step()`. A no-op by default; this is where a character runs its own
   state machine, so `characters/ulises.gd` owns possession, dribbling and
   re-possession without touching `Fighter`.
2. **`CharacterDef.on_round_start(f: Fighter) -> void`** — called from
   `Fighter.reset_for_round()`, so a character can place its own objects.
3. **`CharacterDef.choose_move(key: String, f: Fighter) -> String`** — lets a
   character swap a move for an alternative based on its own state (this is how
   `proj` becomes Slide Kick when out of possession). Defaults to `key`, so
   nothing else changes.
4. **`CharacterDef.on_move_frame(f, m, sf) -> void`** — called on every attack
   frame, just before the move's projectile spawns. This is what launches the
   ball on Power Shot's first active frame and re-scales the hyper beam.
5. **A `Projectile` hazard lifecycle** — new spec fields `persistent`,
   `recoverable` and `slot`, plus `rest()` and `launch()`. A persistent
   projectile is not removed when its life runs out, sheds speed in `_roll()`
   until it stops, and can then be booted away by any fighter. Friction is what
   stops it, so there is no frame cap to tune.
6. **`Fight.view_bounds()`** — the camera window the fighters are kept in,
   now shared with the ball, so a loose ball can never rest somewhere the camera
   has left behind and be unreachable for the rest of the round.
7. **`Fight._kicks(m)`** — the boot rule, next to the existing hit loop.
8. **`MoveData.kicks`** — the one new field, a bool.

### The test

`tests/sim_test.gd` gains `[ulises ball]` and `[ulises ball: hyper]`, covering:
he starts in possession; `proj` is Power Shot and `rush` is the tackle; the kick
sends the ball rolling and out of possession; the input then gives a Slide Kick
and a plain dash; it comes to rest; a resting ball does no damage; the
opponent's sweep boots it; walking back over it re-possesses it; a light punch
keeps the ball while his own sweep loses it; and the hyper beam is wider with the
ball than without. Two supporting changes were needed: `_test_specials` now
resolves its expectation through `_expected()` (`choose_move`), and
`_test_character_def` validates every move a character defines rather than only
the required ten.

## The other three, sketched

Same shape as Ulises, to be specified in the same detail when he lands.

- **Emilia — the spellbook.** She banks charges by casting and whiffing, and
  spends them to empower a special (a charged Wand Spark that homes and
  pierces). An install: the threat is that she is saving up, not that she is
  about to hit you.
- **Charlie — the tantrum.** Taking damage fills a cry meter, and a full meter
  turns a blocked hit or a knockdown into an armoured, rage-scaling burst. He is
  the only character who wants to be hit, which inverts the usual rhythm.
- **Silvan — the zoomies.** Movement builds momentum that decays when he stops;
  momentum widens his hitboxes and lengthens his dash. He is a character you
  have to keep moving, which is exactly the character the others are not.

## Phase B, concretely

The order below is deliberate: do the cheap, high-information work before the
expensive one.

1. **Asymmetric kits first, mechanics second.** Before adding a new system to
   Emilia, take away something the others have. Concretely: give Charlie no fast
   fireball and no reliable anti-air, and let Silvan trade all of his range for
   speed. This needs no engine work at all, only `choose_move` swapping in worse
   alternatives, and it is the single biggest lever on how different the roster
   feels. Do it first because it is cheap and it tells you whether the mechanics
   are even needed.
2. **Then Emilia**, as the second mechanic. She is the closest to Ulises in that
   her thing is a resource, so her hooks are already proven. The interesting
   question is whether "spend to empower" is *decision-making* or just a bigger
   number; aim for a number of charges that forces a choice (one or two), not a
   bar that fills on its own.
3. **Then Charlie and Silvan**, which are the two that need genuinely new
   support: Charlie needs a damage-taken counter, and Silvan needs a movement
   counter. Both fit in `tick` with no new engine surface, but both interact with
   the state machine, so expect to add a hook if you find yourself reaching
   around `Fighter`.
4. **Command normals, air specials and EX** last, on top of four working
   mechanics. These are expression, not identity, and they are much easier to
   balance once each fighter is already distinct.

### Open questions to decide, not inherit

- **Does an EX variant need a third input?** With two buttons, EX has to be
  something like `L+H` while holding away, or `L+H` tapped twice. Both are
  discoverable by kids, but the first collides with `choose_move` variants
  (Ulises' `BACK + L + H` is a hyper, so `BACK + L + H` in EX form is ambiguous).
  Pick one rule and apply it to all four, or drop EX entirely.
- **How does `CpuInput` learn a kit?** Options: a per-character table on
  `CharacterDef`, or a few new `CpuInput` branches that ask the character what
  it prefers. The table is less code and easier to balance; the branches are more
  expressive. Phase C should not start until phase B has settled what a kit even
  *is* in data.
- **Is one mechanic per character enough, or does each need a resource too?**
  Ulises has an object and a derived state, not a bar. A bar is a second thing to
  read on screen, and the roster may not need it.

## Phasing

- **A — prove the pattern.** *(done)* The hooks above, Ulises' mechanic, and the
  `[ulises ball]` checks. Nothing else changed: the other three are untouched and
  `--test` is green.
- **B — the rest of the roster.** Emilia, Charlie and Silvan mechanics, then
  command normals, air specials and EX variants on top.
- **C — the CPU and the balance.** Per-character preferences in `CpuInput`, then
  tuning against `--test --balance` until every pairing is in range. Note that
  the balance run is *not* yet a measure of the ball: `CpuInput` is still
  character-blind, so the CPU barely plays with it. Phase C is what makes the
  numbers mean something.

## Risks

- **Scope.** This is the largest change the project has had since the sprite
  system was removed. Phase A is deliberately small and self-contained for
  exactly that reason.
- **Balance.** A persistent object on the floor is a new thing to balance
  around. If the ball turns out to dominate, the fix is in Ulises' numbers, not
  in `Fight` — which is why the mechanic lives in his file.
- **Regression.** The fixed ten-key contract and the one-file rule are load
  bearing. The hooks are no-ops by default, so a character that does not use
  them behaves exactly as it does today.

## Definition of done

Same bar as `AGENTS.md`, restated for this work:

1. `godot --headless --path . --import` is clean.
2. `godot --headless --path . -- --test` prints `FAILURES: 0`.
3. `--test --balance` is still in range for every pairing.
4. Every new mechanic has a check in `tests/sim_test.gd`.
5. `README.md` records the player-visible change (a move, a control, how a
   fight looks), and `AGENTS.md` is updated for any new rule the code now has —
   including these hooks, so the next character knows they exist.
