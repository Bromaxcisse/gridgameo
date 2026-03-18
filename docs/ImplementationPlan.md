## Implementation Plan: The Oxygen Grid

A comprehensive, step-by-step plan to bring **The Oxygen Grid** from its current skeleton to a shippable game. Structured chronologically for a solo developer using Flutter and Flame.

**Reference Documents:**
* **GDD** — Game Design Document (gameplay, screens, mechanics, progression)
* **DLS** — Design Language System (colors, typography, layout, animation)

**Current State:** The project has a working Flutter + Flame shell (`TheOxygenGrid` extends `FlameGame`), a logo asset, and platform scaffolding for Android, iOS, Web, macOS, Windows, and Linux. No game logic, screens, or UI have been implemented yet.

---

### Phase 1: Foundation & Architecture

**Goal:** Finalize the project skeleton, install all dependencies, establish the folder structure, and define core constants before writing any game logic.

**1.1 — Install Dependencies**

Add the required packages to `pubspec.yaml`:
* `flame` — Core game engine (already installed)
* `google_fonts` — Loads Chakra Petch at runtime (no bundled `.ttf` files)
* `shared_preferences` — Offline persistence for unlocked Sectors and Efficiency Ratings

**1.2 — Establish Folder Structure**

```
lib/
├── main.dart                  (App entry point — already exists)
├── the_oxygen_grid.dart       (Main FlameGame class — already exists)
├── core/
│   ├── app_colors.dart        (DLS color palette as named Color constants)
│   ├── app_theme.dart         (Flutter ThemeData using Chakra Petch + DLS values)
│   ├── app_constants.dart     (Grid entity codes, timing values, O2 thresholds)
│   └── app_text_styles.dart   (DLS typographic hierarchy as TextStyle constants)
├── game/
│   ├── components/
│   │   ├── grid_component.dart       (Renders the playable grid)
│   │   ├── drone_component.dart      (Player entity — movement, glow, rendering)
│   │   ├── extraction_point.dart     (Goal entity — rotating hex/diamond)
│   │   ├── wall_component.dart       (Static impassable blocks)
│   │   ├── sentry_node.dart          (Patrolling red hazard)
│   │   ├── corrosive_tile.dart       (Yellow penalty tile)
│   │   └── decaying_wall.dart        (Timed appearing/disappearing wall)
│   ├── managers/
│   │   ├── o2_manager.dart           (O2 countdown timer + deduction logic)
│   │   ├── input_manager.dart        (Swipe detection and movement queuing)
│   │   └── game_state_manager.dart   (GameState enum, state transitions)
│   └── effects/
│       ├── vignette_effect.dart      (Low-O2 screen-edge pulsing)
│       └── camera_shake.dart         (Damage feedback)
├── models/
│   ├── sector_data.dart       (2D array representation of a Sector layout)
│   ├── sector_factory.dart    (Static class holding all Sector definitions)
│   └── save_data.dart         (Serialization for shared_preferences)
└── screens/
    ├── boot_sequence.dart     (Splash screen with logo fade-in)
    ├── command_terminal.dart   (Main menu)
    ├── active_grid.dart        (GameWidget wrapper + HUD overlay)
    ├── suspended_state.dart    (Pause overlay)
    ├── extraction_success.dart (Level complete modal)
    ├── signal_lost.dart        (Game over modal)
    ├── simulation_guide.dart   (How to Play — 3 instructional panels)
    ├── mission_logs.dart       (Score progression list)
    └── data_integrity.dart     (Privacy policy)
```

**1.3 — Define Core Constants (`lib/core/`)**

* Translate the DLS color palette into named Dart `Color` constants in `app_colors.dart`.
* Define the typographic hierarchy in `app_text_styles.dart` using `google_fonts` for Chakra Petch.
* Create `app_constants.dart` with grid entity codes (`0` = Empty, `1` = Wall, `2` = Drone Start, `3` = Extraction Point, `4` = Sentry Node, `5` = Corrosive Tile, `6` = Decaying Wall), timing values (movement duration: 0.12s, O2 tick: 1.0s), and O2 threshold percentages (50%, 20%).
* Build a `ThemeData` in `app_theme.dart` that applies the DLS globally to all Flutter widgets.

**1.4 — Define the Grid Data Model (`lib/models/`)**

* Create `SectorData` as a data class holding: sector number, grid width, grid height, starting O2, and a 2D `List<List<int>>` grid layout.
* Create `SectorFactory` with static methods returning `SectorData` for Sectors 1-10 (hardcoded). Later sectors can be added incrementally.

---

### Phase 2: The Core Flame Engine & Rendering

**Goal:** Get a responsive, dynamically sized grid drawn on the screen with a Drone that can move around it.

**2.1 — Configure `TheOxygenGrid` (FlameGame)**

* Update `the_oxygen_grid.dart` to accept a `SectorData` object.
* In `onLoad()`, calculate tile size using the DLS formula: `(screenWidth - padding * 2) / columns`.
* Center the grid on the canvas.
* Set the background color to Deep Void (`#05050A`).

**2.2 — Render the Grid (`GridComponent`)**

* Draw grid lines in Terminal Dim (`#1A1A2E`) using `canvas.drawLine()` with 1px stroke.
* Draw wall tiles as filled rectangles in the same color with a lighter 1px border.

**2.3 — Spawn the Drone (`DroneComponent`)**

* Render as a solid Cyan Plasma (`#00F0FF`) square at 80% tile size.
* Apply `MaskFilter.blur(BlurStyle.outer, 10)` for the glow effect.
* Position at the grid coordinates marked `2` in the `SectorData` array.

**2.4 — Spawn the Extraction Point**

* Render as a hollow Neon Isotope (`#39FF14`) diamond/hexagon.
* Rotate at 15 degrees per second in the `update` loop.
* Position at grid coordinates marked `3`.

**2.5 — Implement Swipe Input (`InputManager`)**

* Use Flame's `PanDetector` mixin to detect swipe direction.
* Map swipes to logical grid coordinate changes (up: row-1, down: row+1, etc.).
* Validate against walls before allowing movement.

**2.6 — Animate Drone Movement**

* Use Flame's `MoveToEffect` with `EffectController(duration: 0.12, curve: Curves.easeOutExpo)`.
* Update logical grid position first, then animate the visual component.
* Add `HapticFeedback.lightImpact()` on successful move, `heavyImpact()` on blocked move.

---

### Phase 3: The Oxygen Loop & Game Logic

**Goal:** Implement the survival mechanic, hazards, win/lose states, and scoring.

**3.1 — O2 Timer (`O2Manager`)**

* Add a Flame `TimerComponent` that fires every 1.0 second, deducting 1 O2.
* Expose a `currentO2` value and `o2Percentage` getter for the HUD.
* Pause the timer when `GameState` is not `playing`.

**3.2 — Movement O2 Deduction**

* On every successful Drone move, instantly deduct 1 O2 via the `O2Manager`.

**3.3 — Collision & Rule Evaluation**

After every move, check the Drone's new logical position:
* **Wall (`1`):** Block the move entirely (handled in 2.5).
* **Extraction Point (`3`):** Trigger `GameState.extractionSuccessful`.
* **Sentry Node (`4`):** Deduct 10 O2, trigger camera shake, heavy haptic.
* **Corrosive Tile (`5`):** Deduct 2 additional O2 (3 total for the move).

**3.4 — Game State Machine (`GameStateManager`)**

* Define enum: `booting`, `menu`, `playing`, `suspended`, `extractionSuccessful`, `signalLost`.
* `playing` -> O2 reaches 0 -> transition to `signalLost`.
* `playing` -> Drone reaches Extraction -> transition to `extractionSuccessful`.
* `playing` -> pause tapped -> transition to `suspended` (freeze timers and input).
* `suspended` -> resume -> transition to `playing`.

**3.5 — Scoring (Efficiency Rating)**

* On extraction: calculate `100 + (remainingO2 * 10)`.
* Pass the result to the Extraction Successful screen.
* Save the rating for the current Sector via `shared_preferences` (keep highest).

---

### Phase 4: Flutter UI Overlays & Screens

**Goal:** Build every screen defined in the GDD over the top of the Flame canvas using standard Flutter widgets, styled per the DLS.

**4.1 — Boot Sequence (Splash Screen)**

* Full-screen Deep Void background.
* Fade in `assets/images/logo.png` with a neon glow (`BoxShadow` blur in Cyan Plasma at 40% opacity).
* Show "Initializing Life Support..." loading bar in Chakra Petch.
* Auto-navigate to Command Terminal after 2 seconds.

**4.2 — Command Terminal (Main Menu)**

* Animated neon grid background (subtle, slow-scrolling grid lines).
* Game title "THE OXYGEN GRID" in Chakra Petch Bold, 42sp, uppercase, tracking +2.0.
* Five hollow/outlined neon buttons per DLS Section 5:
  * **Deploy Drone** — navigates to Active Grid (Sector 1 or highest unlocked).
  * **Simulation Guide** — opens How to Play.
  * **Mission Logs** — opens score progression.
  * **System Config** — opens volume toggles.
  * **Data Integrity** — opens privacy policy.
* All buttons: 2px Cyan Plasma border, sharp 2px radius, `BoxShadow` glow, transparent background filling to 20% Cyan on press.

**4.3 — Active Grid Screen (Gameplay Wrapper)**

* Uses `GameWidget` to host the Flame `TheOxygenGrid` instance.
* Registers Flame overlays for: HUD, Suspended State, Extraction Successful, Signal Lost.

**4.4 — HUD Overlay**

* Positioned top-center within `SafeArea`.
* Displays O2 count in Chakra Petch Bold 32sp with a thin horizontal underline.
* Color shifts based on O2 percentage:
  * \>50%: Cyan Plasma (`#00F0FF`)
  * 20%-50%: Amber Alert (`#FFD700`)
  * <20%: Core Breach (`#FF003C`) + pulsing scale animation
* Subtle "Suspend Protocol" pause icon in top-right corner (48x48 min touch target).

**4.5 — Suspended State (Pause Overlay)**

* Translucent `#0F0F1A` at 90% opacity covering the full screen.
* Two centered buttons:
  * **Restore Telemetry** — resumes game.
  * **Abort Mission** — returns to Command Terminal.

**4.6 — Extraction Successful (Level Complete)**

* Centered modal with Neon Isotope accent.
* Displays: Sector number, O2 remaining, calculated Efficiency Rating.
* Drone "warp out" animation (scale down + fade out + particle burst).
* Two buttons: **Next Sector**, **Return to Terminal**.

**4.7 — Signal Lost (Game Over)**

* Centered modal with Core Breach accent.
* Drone flickers gray, subtle screen glitch effect (random horizontal offset frames).
* Two buttons: **Redeploy** (restart same Sector), **Return to Terminal**.

**4.8 — Simulation Guide (How to Play)**

* Three paged panels (swipeable or tap-to-advance):
  * Panel 1: Swipe arrows demonstrating movement.
  * Panel 2: O2 cost diagram (move = -1, rest = -1/sec).
  * Panel 3: Avoid red, reach green.
* All graphics are code-rendered (Canvas drawings), not images.
* **Acknowledge** button at bottom.

**4.9 — Mission Logs (Score Progression)**

* Scrollable list of Sectors.
* Each row shows: Sector number, highest Efficiency Rating, completion status.
* Completed Sectors highlighted with Neon Isotope text.
* Locked Sectors shown in Muted Blue-Gray (`#8892B0`).
* Data loaded from `shared_preferences`.
* **Return to Terminal** button.

**4.10 — Data Integrity (Privacy Policy)**

* Scrollable text box with body text styling (Chakra Petch Regular, 16sp).
* Content: "The Oxygen Grid operates entirely offline. No user telemetry, personal data, or location metrics are tracked, stored, or transmitted by this application."
* **Acknowledge** button.

---

### Phase 5: Level Design & Progression

**Goal:** Move from a single test grid to a fully playable multi-sector progression system.

**5.1 — Design Sectors 1-5 (Tutorial Arc)**

* 5x5 grids, 30 starting O2.
* Static Walls only. Increasing complexity of wall placement.
* Sector 1 is trivially simple (2-3 walls). Sector 5 requires deliberate path planning.

**5.2 — Design Sectors 6-15 (Sentry Nodes)**

* 7x7 grids, 45 starting O2.
* Implement `SentryNode` component: patrols left/right or up/down on a 2-second timer.
* Hitting a Sentry deducts 10 O2 + camera shake + heavy haptic.

**5.3 — Design Sectors 16-25 (Corrosive Tiles)**

* 7x9 grids, 60 starting O2.
* Implement `CorrosiveTile` component: semi-transparent Amber Alert fill.
* Crossing costs 3 O2 instead of 1.

**5.4 — Design Sectors 26-40 (Decaying Walls)**

* 9x11 grids, 75 starting O2.
* Implement `DecayingWall` component: opacity pulses on a 3-second cycle (visible -> invisible -> visible).
* Player must time their movement through gaps.

**5.5 — Design Sectors 41-50 (Hunter Wakes)**

* 10x12 grids, 85 starting O2.
* Hunter Wakes are Sentry Nodes with 20% faster patrol speed.

**5.6 — Level Transition Logic**

* On Extraction Successful: save current Sector as cleared, increment Sector counter, load next `SectorData` into the Flame engine.
* If all Sectors cleared, show a "All Sectors Cleared" variant of the Extraction Successful screen.

**5.7 — Persistence Layer**

* Save to `shared_preferences`:
  * `highestUnlockedSector` (int)
  * `efficiencyRatings` (Map<int, int> — sector number to highest rating)
* Load on app start and feed into Command Terminal ("Deploy Drone" resumes highest unlocked).

---

### Phase 6: Polish & "The Juice"

**Goal:** Make the game feel satisfying and premium before release.

**6.1 — Haptics (Already wired in Phase 2)**

* Verify `HapticFeedback.lightImpact()` on successful swipe.
* Verify `HapticFeedback.heavyImpact()` on wall collision, Sentry hit, and Signal Lost.

**6.2 — Camera Shake**

* Use Flame's camera system: `game.camera.viewfinder.add(MoveByEffect(...))` with a small random offset and 0.2s duration.
* Trigger on Sentry Node collision and Signal Lost.

**6.3 — Low-O2 Vignette**

* Full-screen overlay using a `RadialGradient` from transparent center to Core Breach (`#FF003C`) at edges.
* Appears when O2 < 20%. Intensity scales linearly as O2 approaches 0.
* Pulsing opacity animation (0.8s cycle).

**6.4 — Extraction Warp Animation**

* On win: Drone scales down to 0 + fades out + brief particle burst of Cyan Plasma squares.
* Duration: 0.5 seconds.

**6.5 — Signal Lost Glitch Effect**

* On lose: Drone sprite turns gray (desaturate paint color).
* Screen applies 3-4 random horizontal offset frames over 0.3 seconds (glitch aesthetic).

**6.6 — Boot Sequence Polish**

* Logo fade-in over 1 second with `Curves.easeOutExpo`.
* Loading bar fills over 1.5 seconds.
* Smooth transition to Command Terminal (fade-out logo, fade-in menu).

**6.7 — Button Press Feedback**

* On press: fill to 20% Cyan Plasma + scale to 0.97x over 0.1s.
* On release: return to normal over 0.15s.

---

### Phase 7: Cleanup & Release Prep

**Goal:** Finalize the codebase for distribution.

**7.1 — Remove Boilerplate**

* Delete or update `test/widget_test.dart` (currently references non-existent `MyApp`).
* Update `README.md` with project description and build instructions.
* Clean up `assets/audio/` reference from `pubspec.yaml` if no audio is added.

**7.2 — Platform Polish**

* Update `web/manifest.json` theme color from `#0175C2` to `#05050A` (Deep Void).
* Update app icons for all platforms using the O₂ logo as source.
* Verify `SafeArea` and responsive layout on multiple screen sizes.


---

### Appendix: Cross-Reference Checklist

| Item | GDD Section | DLS Section | This Plan |
| --- | --- | --- | --- |
| Boot Sequence | 3 (Splash) | — | Phase 4.1, 6.6 |
| Command Terminal | 3 (Main Menu) | 5 (Buttons) | Phase 4.2 |
| Active Grid + HUD | 3 (Gameplay) | 5 (O2 HUD) | Phase 2, 4.3, 4.4 |
| Suspended State | 3 (Pause) | 3 (Panels) | Phase 4.5 |
| Extraction Successful | 3 (Level Complete) | — | Phase 4.6 |
| Signal Lost | 3 (Game Over) | — | Phase 4.7 |
| Simulation Guide | 3 (How to Play) | — | Phase 4.8 |
| Mission Logs | 3 (Score) | — | Phase 4.9 |
| Data Integrity | 3 (Privacy) | — | Phase 4.10 |
| O2 Mechanic | 4 (Mechanics) | 5 (O2 HUD) | Phase 3.1, 3.2 |
| Swipe Controls | 4 (Movement) | 6 (Movement Snap) | Phase 2.5, 2.6 |
| Scoring | 4 (Efficiency Rating) | — | Phase 3.5 |
| Progression/Hazards | 5 (Full table) | 5 (Entities) | Phase 5.1-5.5 |
| Color Palette | 6 (Dev Notes) | 3 (Full palette) | Phase 1.3 |
| Typography | 6 (Dev Notes) | 2 (Chakra Petch) | Phase 1.3 |
| Haptics | — | 6 (The Juice) | Phase 2.6, 6.1 |
| Camera Shake | — | — | Phase 6.2 |
| Vignette | 3 (Active Grid) | 6 (Low O2 Vignette) | Phase 6.3 |

---
