# Waste Corp

**Sort. Process. Build the company.** — recycling tycoon.

**Org / package:** `com.wastecorp.waste_corp`  
**Repo (target):** https://github.com/KonstantinosKoufopoulos/wastecorp

## Primary development → Godot 3D

| Path | Status |
|------|--------|
| **[`godot/`](godot/)** | **Active** — Godot 4.3+ CharacterBody3D yard, S0–S6 tutorial |
| [`legacy_flutter_2d/`](legacy_flutter_2d/) | **Frozen / legacy** — Flutter 2D Sprint 1 scaffold (do not extend for v1 3D) |
| [`docs/`](docs/) | Design notes (first-5-min, scope, store copy) |

Open the 3D project:

```bash
# Godot 4.3+ Editor → Open
# select: waste_corp/godot/project.godot
```

See [`godot/README.md`](godot/README.md) for architecture, controls, and placeholder → `.glb` swap path.

### Locked stack (v1 3D)

Godot 4 · CharacterBody3D · AnimationPlayer · placeholder meshes until Alex 3D `.glb` · ConfigFile/JSON save · Control HUD · **no Flutter for v1 3D**.

### First-5-min (Christos 3D)

S0 Start → S1 walk/pick (E) → S2 deposit to 3 bins → S3 plastic press → S4 hire worker → S5 metal/paper unlock → S6 contract + Truck|Yard upgrade. Camera ¾ follow. No drag-sort.

## Legacy Flutter 2D

The previous Flutter + Riverpod + Hive tutorial shell was moved to [`legacy_flutter_2d/`](legacy_flutter_2d/). It remains for reference only.

```bash
cd legacy_flutter_2d
flutter pub get
flutter run -d chrome   # legacy only
```

## Gate note

**Do not publish GitHub Pages (or store builds) without Carolos playtest PASS.**

Tutorial feel: sort → process → get paid → grow. No menu wall, no gambling, no ads in the first five minutes.

## License

Private — Waste Corp / Konstantinos Koufopoulos.
