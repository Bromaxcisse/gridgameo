## Game Design Document: The Oxygen Grid

### 1. Core Concept & Gameplay Loop

**The Oxygen Grid** is a 2D grid-based survival puzzle game. The player controls a "Drone" attempting to reach an "Extraction Point" on a procedurally or manually designed grid before running out of "Oxygen" (O2).

**The Loop:**

1. **Assess:** The Drone drops into the grid. The player has a split second to view the layout.
2. **Calculate & Move:** The player swipes to move the Drone.
   * Moving 1 tile costs **1 O2**.
   * Standing still costs **1 O2 per second**.
   * Hitting hazards incurs additional O2 penalties (see Section 5).
3. **Survive:** Navigate around obstacles and hazards.
4. **Extract:** Reach the exit. Leftover O2 is converted into an "Efficiency Rating" (Score).
5. **Progress:** Proceed to the next, slightly harder Sector.

---

### 2. Thematic Terminology Mapping

To maintain a cohesive, immersive sci-fi atmosphere, generic UI terms are replaced with the following in-game language:

| Generic Term | In-Game Thematic Term |
| --- | --- |
| Main Menu | **Command Terminal** |
| Play / Start | **Deploy Drone** |
| Pause | **Suspend Protocol** |
| Resume | **Restore Telemetry** |
| Settings | **System Config** |
| Level | **Sector** |
| Game Over | **Signal Lost (O2 Depleted)** |
| Level Complete | **Extraction Successful** |
| Score / High Score | **Efficiency Rating / Mission Logs** |
| Player | **The Drone** |
| Exit / Goal | **Extraction Point** |

---

### 3. Screen Requirements & Navigation

**Boot Sequence (Splash Screen)**

* **Visuals:** A Deep Void (`#05050A`) screen with the O₂ logo (`assets/images/logo.png`) fading in with a neon glow. A loading bar labeled "Initializing Life Support..." in Chakra Petch.
* **Action:** Automatically transitions to the Command Terminal after 2 seconds.
* **Note:** The logo is the single pre-made image asset in the project; all other visuals are code-rendered.

**Command Terminal (Main Menu)**

* **Visuals:** Clean, dark UI with glowing neon grid lines in the background.
* **Options:**
  * **Deploy Drone:** Starts Sector 1 (or resumes highest unlocked Sector).
  * **Simulation Guide:** Opens the How to Play screen.
  * **Mission Logs:** Opens the Score progression screen.
  * **System Config:** Opens volume toggles.
  * **Data Integrity:** Opens the Privacy Policy.

**Active Grid (Gameplay Screen)**

* **Visuals:** The playable grid. The Drone is a glowing Cyan Plasma (`#00F0FF`) square; the Extraction Point is a pulsing Neon Isotope (`#39FF14`) hex. O2 levels are displayed prominently at the top as a depleting numeric counter.
* **UI Overlays:** A subtle "Suspend Protocol" (Pause) icon in the top right.
* **Effects:** As O2 drops below 20%, the screen edges darken (vignette effect) and the background grid slowly pulses Core Breach red (`#FF003C`).

**Suspended State (Pause Menu)**

* **Trigger:** Tapping the pause icon freezes all game logic, timers, and Flame update loops.
* **Visuals:** A translucent dark overlay over the active grid.
* **Options:**
  * **Restore Telemetry:** Resumes the Flame game loop.
  * **Abort Mission:** Returns to the Command Terminal.

**Extraction Successful (Level Complete)**

* **Trigger:** Drone overlaps the Extraction Point tile.
* **Visuals:** A clean, satisfying animation of the Drone warping out.
* **Data Displayed:** "O2 Remaining" calculated into an "Efficiency Rating".
* **Options:** **Next Sector** or **Return to Terminal**.

**Signal Lost (Game Over Screen)**

* **Trigger:** O2 counter reaches 0.
* **Visuals:** The Drone flickers and turns gray. The screen glitches slightly (a simple shader or offset effect in Flame).
* **Options:** **Redeploy** (Restart level) or **Return to Terminal**.

**Simulation Guide (How to Play)**

* **Visuals:** Three static, text-light graphics demonstrating the rules.
  * *Graphic 1:* Swipe to move.
  * *Graphic 2:* Moving = -1 O2. Resting = -1 O2/sec.
  * *Graphic 3:* Avoid red anomalies. Reach green Extraction.
* **Options:** **Acknowledge** (Back button).

**Mission Logs (Score Progression)**

* **Visuals:** A scrollable list of completed Sectors with their Efficiency Ratings. Highest rating per Sector is highlighted in Neon Isotope (`#39FF14`).
* **Data:** Loaded from local `shared_preferences` storage.
* **Options:** **Return to Terminal**.

**Data Integrity (Privacy Policy)**

* **Visuals:** A simple scrolling text box.
* **Content:** "The Oxygen Grid operates entirely offline. No user telemetry, personal data, or location metrics are tracked, stored, or transmitted by this application."
* **Options:** **Acknowledge**.

---

### 4. Gameplay Mechanics & Systems

**Movement & Controls**

* The game uses swipe gestures.
* Swiping Up, Down, Left, or Right queues a movement to the adjacent grid tile.
* Flame handles movement using smooth interpolation (sliding from Tile A to Tile B over 0.12 seconds with `Curves.easeOutExpo`) rather than instant teleportation, making it feel polished.

**Win/Lose Conditions**

* **Win:** The player's grid coordinates match the Extraction Point's coordinates while O2 > 0.
* **Lose:** The internal O2 integer reaches 0 before the Extraction Point is reached.

**Scoring System (Efficiency Rating)**

* Base score for completing a Sector: 100 points.
* Efficiency Bonus: Remaining O2 multiplied by 10.
* *Example:* Finishing with 12 O2 = 100 + (12 x 10) = 220 Efficiency Rating.

---

### 5. Progression, Difficulty & Hazards (Enemies)

To maintain the "casual but engaging" requirement, traditional enemies are replaced with "Grid Anomalies." Difficulty scales by increasing grid size, lowering starting O2, and introducing faster anomalies.

| Sector Range | Grid Size | Starting O2 | Introduced Mechanics / Anomalies |
| --- | --- | --- | --- |
| **01 - 05** | 5x5 | 30 | **Static Walls:** Basic impassable blocks. Focus is on learning optimal paths. |
| **06 - 15** | 7x7 | 45 | **Sentry Nodes:** Red blocks that patrol left/right or up/down on a set timer. Hitting one deducts 10 O2 instantly. |
| **16 - 25** | 7x9 | 60 | **Corrosive Tiles:** Yellow tiles. Moving across these costs 3 O2 instead of 1. |
| **26 - 40** | 9x11 | 75 | **Decaying Walls:** Walls that appear and disappear every 3 seconds, requiring timing. |
| **41 - 50** | 10x12 | 85 | **Hunter Wakes:** Sentry nodes that move 20% faster, demanding rapid swipe execution. |

---

### 6. Developer Notes for Flutter/Flame Implementation

* **Near-Zero Asset Pipeline:** All game entities are drawn using Flutter's `Canvas` API (`drawRect`, `drawCircle`, `Paint()`). Colors reference the Design Language System: Cyan Plasma (`#00F0FF`), Core Breach (`#FF003C`), Neon Isotope (`#39FF14`), Amber Alert (`#FFD700`) against a Deep Void (`#05050A`) background. The only pre-made image asset is the O₂ logo used on the Boot Sequence.
* **State Management:** Use Flame's built-in `Timer` component for the "1 O2 per second" deduction to ensure it pauses correctly when the game state is suspended.
* **Grid Logic:** Maintain a 2D array (List of Lists) in Dart to represent the Sector. Update the Drone's logical position in the array first, then visually animate the Flame `PositionComponent` to match it.
* **Typography:** All text uses Google Fonts' Chakra Petch to maintain the "Neon Terminal" aesthetic defined in the Design Language System.
* **Persistence:** Use `shared_preferences` to save unlocked Sectors, Efficiency Ratings, and Mission Logs offline.

---
