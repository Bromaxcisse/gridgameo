# The Oxygen Grid

A 2D grid-based survival puzzle game built with **Flutter** and **Flame**.

Control a Drone navigating through hazardous grid sectors before your Oxygen runs out. Reach the Extraction Point with as much O2 remaining as possible to maximize your Efficiency Rating.

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Flame** — 2D game engine for Flutter
- **Google Fonts** — Chakra Petch typeface (loaded at runtime)
- **Shared Preferences** — Offline save data

## Project Structure

```
lib/
├── main.dart              App entry point
├── the_oxygen_grid.dart   Main FlameGame class
├── core/                  Theme, colors, constants, text styles
├── game/                  Flame components, managers, effects
├── models/                Sector data, save data
└── screens/               Flutter UI overlays
```

## Getting Started

```bash
flutter pub get
flutter run
```

## Documentation

- [Game Design Document](docs/GDD.md)
- [Design Language System](docs/DesignLanguage.md)
- [Implementation Plan](docs/ImplementationPlan.md)
