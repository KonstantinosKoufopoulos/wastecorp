# Waste Corp Assets v1

Stylized low-poly GLB set for Godot 4 (mobile). Generated with Blender 4.2.23 LTS via scripts in `../scripts/`.

## Scale

- **1 Blender/Godot unit = 1 meter**
- Player height ≈ **1.7 m** (origin at feet)
- Bins ≈ **1.2 m** tall, ~0.9 m wide (oversized for camera readability)
- Yard props spaced along +X in the source file for easy inspection; move/instance freely in Godot

## Files

| File | Contents | Tris (approx) | Size |
|------|----------|---------------|------|
| `player.glb` | Character + armature + animations | ~412 | ~110 KB |
| `bin_plastic.glb` | Blue plastic recycling bin | ~224 | ~12 KB |
| `bin_metal.glb` | Grey metal bin | ~224 | ~12 KB |
| `bin_paper.glb` | Brown paper/cardboard bin | ~224 | ~12 KB |
| `yard_props.glb` | Named props in one file | ~288 total | ~24 KB |
| `trash_item.glb` | Pickup trash bag (bonus) | ~56 | ~6 KB |

### `yard_props.glb` object names

- `crate`
- `pallet`
- `trash_bag_pile`
- `fence_post`
- `dirt_mound`

## Player animations

Exported animation clip names (AnimationPlayer / glTF importer):

- `idle` — subtle breathe / rest
- `walk` — loopable walk cycle (~24 frames)
- `carry_idle` — arms forward as if holding trash/bin
- `deposit` — lean-forward dump into bin, return to rest

Armature root bone: `root`. Other bones: `hips`, `spine`, `chest`, `neck`, `head`, `thigh_L/R`, `shin_L/R`, `foot_L/R`, `upper_arm_L/R`, `forearm_L/R`, `hand_L/R`.

Readable silhouette cues: **hi-vis yellow vest** + **orange gloves**.

## Poly budgets

| Asset | Budget | Actual | Notes |
|-------|--------|--------|-------|
| Player | ≤ 3000 | ~412 | Under budget; mobile-friendly |
| Each bin | ≤ 1000 | ~224 | Under budget |
| Yard props | n/a | ≤ 100 each | Intentionally simple |

## Material color hexes

Flat Principled BSDF base colors (stylized, soft AO feel — rely on Godot lighting/SSAO rather than baked maps):

| Role | Hex | RGB approx |
|------|-----|------------|
| Skin | `#D9AD8C` | 217, 173, 140 |
| Hair | `#2E1F14` | 46, 31, 20 |
| Shirt | `#40596B` | 64, 89, 107 |
| Vest (hi-vis) | `#F2B814` | 242, 184, 20 |
| Pants | `#384759` | 56, 71, 89 |
| Boots | `#261F1A` | 38, 31, 26 |
| Gloves | `#E68C1F` | 230, 140, 31 |
| Bin plastic | `#2666D9` | 38, 102, 217 |
| Bin metal | `#8C949E` | 140, 148, 158 |
| Bin paper | `#8C592E` | 140, 89, 46 |
| Bin lid | `#1F1F24` | 31, 31, 36 |
| Crate | `#8C6138` | 140, 97, 56 |
| Pallet | `#9E7A47` | 158, 122, 71 |
| Trash bag | `#1F241F` | 31, 36, 31 |
| Fence | `#736B61` | 115, 107, 97 |
| Dirt beige | `#8C7352` | 140, 115, 82 |

Metal bins use a mild metallic factor (~0.55); plastics are non-metal with mid roughness.

## Godot 4 import tips

1. Drop `.glb` files into `res://` (e.g. `assets/waste_corp/`). Godot imports glTF/GLB natively.
2. **Player**: instance as child of `CharacterBody3D`. Prefer the imported scene; use `AnimationPlayer` (or generated `AnimationLibrary`) with clip names above. Enable root-motion only if you intentionally author it — these clips use in-place locomotion (move the `CharacterBody3D` in code).
3. Retarget / rename: if clips appear as `walk_Armature`, trim the suffix or set library names in the import dock.
4. **Bins / props**: instance as `StaticBody3D` / `AnimatableBody3D` with a `CollisionShape3D` (BoxShape or simple convex). Bins are oversized on purpose.
5. Materials come in as `StandardMaterial3D` approximations of Principled BSDF. For the soft AO look: enable SSAO in the WorldEnvironment and keep roughness high; avoid adding noisy PBR textures.
6. Forward+ or mobile renderer both fine; these meshes are tiny.
7. Y-up export matches Godot. If a mesh appears rotated, check that you did not double-apply a `-90° X` fix meant for Z-up sources.
8. To regenerate: install Blender 4.x on PATH, then run `python3 ../scripts/build_all.py` from this folder’s parent tooling (see scripts).

## Reproduce

```bash
export PATH="/home/box/bin:$PATH"   # or your blender symlink
python3 /workspace/waste_corp_assets/scripts/build_all.py
```

Scripts: `common.py`, `build_player.py`, `build_bins.py`, `build_yard_props.py`, `build_trash_item.py`, `build_all.py`.
