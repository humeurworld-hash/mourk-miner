# Mourk Miner — Project Memory

## What This Is
A Godot 4.6 2D platformer / mining game. Player swings an axe to break rocks, collect shards, and descend through levels via holes in the ground.

## Repo
- GitHub: https://github.com/humeurworld-hash/mourk-miner.git
- Main branch: `main`
- Godot app: `/Users/humeurworld/Desktop/Godot.app`
- Run game: `/Users/humeurworld/Desktop/Godot.app/Contents/MacOS/Godot --path /Users/humeurworld/mourk-miner`

## Current State (as of last session)
- **4 levels**: `gameclaude.tscn` (L1), `level2.tscn`, `level3.tscn`, `level4.tscn` (boss)
- **Flow**: main_menu → L1 → L2 → L3 → L4 (PrimeMourk boss) → win_screen
- **Level exit**: `hole.gd` / `hole.tscn` — dark ellipse pit drawn with `_draw()`, triggers `TransitionLayer.fade_out()` on player contact
- **Player**: `player.gd` — movement, jump, axe swing with tween animation, flip on direction, death/respawn, health system, 25-shard = extra life
- **Enemies**: `drone.gd` / `drone.tscn` — patrol, hover, axe damage; placed in L1 and L2
- **Rocks**: `rock.gd` / `rock.tscn` — breakable, spawn shards on death; `special_rock.gd` — Break mechanic with lightning strike
- **Shards**: `shard.gd` — fly-to-counter animation on collection; reset to 0 on game start and death
- **Life pickups**: `life_pickup.gd` / `life_pickup.tscn` — dropped by special rocks
- **Companion**: Fuse sprite with panic state (`fuse_frames.tres`, `player_frames.tres` for animation)
- **HUD**: `hud.gd` — shard counter + health display
- **Save system**: `game_state.gd` — persistent state across scenes
- **Touch controls**: `touch_controls.gd` / `touch_controls.tscn`
- **Music**: `echoveil/music/Mist in the Circuit-2.mp3` (looping)
- **SFX**: axe swing, rock break, shard revel in `echoveil/music/animations/`

## Key Scene: gameclaude.tscn (Level 1)
- Floor split into left/right sections with a gap for the hole exit
- `LevelHole` placed at (1100, 570) — links to `level2.tscn`
- Drones added to Level 1
- Player starts at (200, 300), in group `"player"`

## Input Map
- Move: `ui_left` / `ui_right`
- Jump: `ui_accept`
- Swing axe: `swing` (mapped to X key)

## What's TODO / In Progress
- `feature/level-exit-hole` branch exists locally (stale — can delete)
- Level layouts are functional but may need visual polish in the Godot editor
- PrimeMourk in level4 uses player sprite as placeholder — consider a dedicated boss sprite
- Could add a proper game-over screen (currently just respawns or returns to menu)

## Code Patterns
- Rocks use `collision_layer = 2`, pickaxe hitbox checks mask 2
- Shards use `collision_layer = 8`
- Player must be in group `"player"` for triggers to fire
- Scene transitions use `TransitionLayer.fade_out(callable, duration)` (added in hole.gd)
- `shard.position = global_position + offset` then `get_parent().add_child(shard)` for spawning

## Assets
- Player sprite: `echoveil/forme/Remove background project 2.PNG`
- Axe: `echoveil/forme/Glowing fantasy battle axe design.png`
- Drone: `echoveil/drones/Hovering robot with glowing trail.png`
- Rock: `echoveil/platforms/Rocks/26BD4AED-AB96-4AD0-B798-DAE0D240A86D.png`
- Hole image (unused): `echoveil/platforms/holes exits/Gemini_Generated_Image_dko0j0dko0j0dko0.png`
- Backgrounds: `echoveil/backgrounds/` (farback, mid, foreground)
