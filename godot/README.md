# Waste Corp 3D (Godot 4)

Primary development target for Waste Corp. Flutter 2D lives under `../legacy_flutter_2d/` and is **frozen / legacy**.

**Do not publish GitHub Pages (or store builds) without Carolos playtest PASS.**

## Requirements

- Godot **4.3+** (Forward Plus)
- Open this folder as a project: `waste_corp/godot/` (the directory that contains `project.godot`)

```bash
# Example
godot4 --path /path/to/waste_corp/godot
# or: Godot Editor → Import / Open → select project.godot
```

## Locked stack (v1 3D)

| Piece | Choice |
|--------|--------|
| Engine | Godot 4 |
| Player | `CharacterBody3D` + `AnimationPlayer` |
| Meshes | Placeholders (boxes/capsule) until Alex 3D `.glb` |
| Save | `ConfigFile` + JSON export (`SaveService`) |
| HUD | `Control` / CanvasLayer |
| Mobile UI | No Flutter for v1 3D |

## Christos first-5-min flow (S0–S6)

| Step | Gameplay |
|------|----------|
| **S0** | Dirty yard + **Start** |
| **S1** | Walk + pick trash (**E** / tap Interact) |
| **S2** | Deposit to 3 bins (proximity + tap) — plastic **blue** / metal **grey** / paper **brown** |
| **S3** | Plastic **press** zone |
| **S4** | Hire worker NPC |
| **S5** | Metal / paper unlock |
| **S6** | Contract truck + upgrade choice (Truck \| Yard) |

Camera: **¾ follow** behind/above (`FollowCamera`). **No drag-sort.**

Controls: **WASD** / arrows, **E** or Space to interact, on-screen Start / Accept / Hire / Upgrade + Interact button (virtual-stick hook on player: `set_virtual_stick`).

## Architecture

```
godot/
  project.godot
  scenes/main.tscn          # yard + player + camera + HUD
  scripts/
    main.gd                 # wires bin unlock / truck
    player.gd               # move, pick, carry, deposit
    tutorial_state.gd       # autoload S0–S6
    save_service.gd         # autoload ConfigFile + JSON
    sorting_bin.gd          # Area3D bins
    trash_pickup.gd         # Area3D pickups
    press_zone.gd
    worker_npc.gd
    follow_camera.gd
    hud.gd
  assets/
    models/                 # drop Alex 3D .glb here
    placeholders/           # reserved
```

Autoloads: `SaveService`, `TutorialState`.

## Placeholder → `.glb` swap path

1. Export / receive models from Alex 3D into `assets/models/` (e.g. `player.glb`, `bin_plastic.glb`, `trash_plastic.glb`, `press.glb`, `worker.glb`, `truck.glb`).
2. In `scenes/main.tscn`, select the relevant `MeshInstance3D` (or replace the node with an instanced `.glb` scene).
3. Keep scripts / `Area3D` collision shapes — only visual meshes change.
4. Optional: re-target `AnimationPlayer` clips from the GLB skeleton; keep method names on `player.gd` (`try_interact`, carry anchor).

Until then, colored `BoxMesh` / `CapsuleMesh` placeholders are intentional.

## Save data

- `user://waste_corp_save.cfg` — canonical
- `user://waste_corp_save.json` — mirror for debugging / tooling

## Gate

No Pages / store deploy until **Carolos PASS**.
