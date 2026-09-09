# Waste Corp

Sort. Process. Build the company. — a waste / recycling tycoon for mobile (Flutter).

**Org / package:** `com.wastecorp.waste_corp`  
**Repo (target):** https://github.com/KonstantinosKoufopoulos/wastecorp

## Stack (locked — Sprint 1)

| Layer | Tech |
|--------|------|
| UI | Flutter screens + yard placeholders |
| State | Riverpod |
| Persistence | Hive |
| Game engine | **No Flame in Sprint 1** |

Ads / IAP stubs are deferred — **not in the tutorial**.

## Architecture

```
lib/
  ui/           screens (S0–S6), yard widgets, theme, shared UI
  domain/       economy, contracts, reputation, models
  services/     storage (Hive); ads/IAP later
```

- **UI** — first-5-min shell (Christos wireframes S0–S6), industrial-light palette, one primary CTA per screen.
- **Domain** — cash, hire costs, district contracts, reputation points (tutorial stubs).
- **Services** — `StorageService` via Hive for tutorial step / cash / reputation flags.

Research notes live in [`docs/`](docs/) (copied from workspace research; originals kept).

## How to run

```bash
export PATH=/home/box/flutter/bin:$PATH   # if needed
cd waste_corp
flutter pub get
flutter run -d chrome          # web
# or
flutter run -d android         # device / emulator
```

Analyze:

```bash
flutter analyze
```

## Sprint 1 scope

**In (this scaffold)**

- First-5-min navigation shell: S0 Splash → S1 Sort → S2 Plastic press → S3 Hire → S4 Lines open → S5 Contract → S6 Upgrade choice
- Placeholders OK; screens named correctly
- Money HUD; tap-to-sort stub; process progress + cash pop; hire card; metal/paper lines; district Accept + chip; Truck \| Yard forced pick + dismissable offline banner
- Riverpod + Hive wired; android + web platforms

**Out of Sprint 1 / tutorial**

- Flame, glass/organic lines, deep clients, season pass, ads/shop in tutorial
- Full drag-sort physics, real offline sim, IAP

See also: `docs/waste-corp-v1-scope.md`, `docs/waste-corp-first-5-min.md`.

## Gate note

**Do not publish GitHub Pages (or store builds) without Carolos playtest PASS.**

Tutorial feel target: sort → process → get paid → grow. No menu wall, no gambling, no ads in the first five minutes.

## First-5-min map (S0–S6)

| ID | Screen | Primary action |
|----|--------|----------------|
| S0 | Splash / dirty yard | Start |
| S1 | Sort (3 bins) | Sort → open press |
| S2 | Plastic press | Process |
| S3 | Hire | Hire |
| S4 | Lines open | Continue |
| S5 | Contract | Accept → run |
| S6 | Upgrade | Truck or Yard |

## License

Private — Waste Corp / Konstantinos Koufopoulos.
