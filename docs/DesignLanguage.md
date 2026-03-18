## Design Language System: The Oxygen Grid

### 1. Overall Vibe & Art Direction

**"Neon Terminal / Minimalist Sci-Fi"**
The visual identity is cold, precise, and high-contrast. It evokes the feeling of a heads-up display (HUD) inside a futuristic spacesuit or a tactical command console. The design relies on stark geometry, glowing neon accents against deep darkness, and snappy, mathematical animations.

All in-game entities and UI elements are code-rendered using Flutter's `Canvas` API and standard widgets — no sprite sheets or image assets are needed. The single exception is the O₂ logo (`assets/images/logo.png`), used exclusively on the Boot Sequence splash screen.

### 2. Typography: The Single-Font System

**Google Font:** **[Chakra Petch](https://fonts.google.com/specimen/Chakra+Petch)**
*Why this font?* Chakra Petch is a geometric sans-serif with subtle, squared-off corners. It looks inherently technical and futuristic, matching the grid-based gameplay perfectly. It remains highly legible on small mobile screens and includes multiple weights, eliminating the need for a secondary font.

Loaded at runtime via the `google_fonts` package — no bundled `.ttf` files required.

**Typographic Hierarchy (Responsive scaling):**

* **Main Titles (Command Terminal):** Chakra Petch Bold, 42sp, Uppercase, tracking (letter-spacing) +2.0.
* **Headers (Sector Titles, Mission Logs):** Chakra Petch SemiBold, 24sp, Uppercase, tracking +1.0.
* **Body Text (Simulation Guide, Data Integrity):** Chakra Petch Regular, 16sp, Normal case, high line-height (1.5) for readability.
* **HUD / O2 Counter:** Chakra Petch Bold, 32sp, Monospaced numerals (to prevent the UI from jittering as the countdown ticks).

### 3. Color Palette (Zero-Asset Colors)

Everything is drawn using Flutter's `Canvas` API and basic container widgets. **Always reference these named hex values; do not use Flutter's built-in color constants** (e.g., avoid `Colors.cyanAccent`) as they differ from the intended palette.

**Backgrounds & Structure:**

* **Deep Void (Main Background):** `#05050A` — A near-black, deep navy. Softer on the eyes than pure black.
* **Grid Lines (Terminal Dim):** `#1A1A2E` — Subtle structure. Drawn with a 1px stroke width.
* **Panels/Modals (Suspended State):** `#0F0F1A` with 90% opacity — creates a dark overlay.

**Primary Accents (Neon Glows):**

* **Cyan Plasma (The Drone / Primary UI):** `#00F0FF` — Used for the player, active buttons, and standard O2 levels.
* **Neon Isotope (Extraction Point / Success):** `#39FF14` — Used exclusively for the goal and "Extraction Successful" screens.
* **Core Breach (Hazards / Low O2 / Danger):** `#FF003C` — Used for Sentry Nodes and when O2 drops below 20%.
* **Amber Alert (Corrosive Tiles / Warnings):** `#FFD700` — Used for secondary hazards and O2 in the 20%-50% range.
* **Text Colors:** Pure White (`#FFFFFF`) for primary text, Muted Blue-Gray (`#8892B0`) for secondary text and inactive states.

### 4. Layout Rules & Responsive Spacing

To ensure the game scales perfectly from a compact phone to a large curved gaming monitor (or standard tablets), the layout strictly follows these rules:

* **The 8-Point Grid System:** All padding, margins, and gaps must be multiples of 8 (8, 16, 24, 32, 48, 64).
* **Mobile Safe Areas:** All critical UI (O2 Counter, Suspend Protocol button) must be wrapped in Flutter's `SafeArea` widget to avoid notches and bottom gesture bars.
* **Touch Targets:** Every interactive element (buttons, toggles) must have a minimum hit area of **48x48 logical pixels** to prevent frustrating mis-taps during frantic gameplay.
* **Dynamic Grid Sizing:** The Flame game canvas must calculate tile size dynamically.
  * *Formula:* `(Screen Width - (Screen Padding * 2)) / Number of Columns`.
  * This ensures the grid is always perfectly centered and maximizes screen real estate regardless of the device's aspect ratio.

### 5. UI Element Styling

Since there are no sprites, the UI relies on code-based styling.

**Buttons (Command Terminal & Menus):**

* **Style:** Hollow/Outlined.
* **Border:** 2px stroke of Cyan Plasma (`#00F0FF`).
* **Background:** Transparent by default. On press, fills with a 20% opacity of Cyan Plasma.
* **Corners:** Sharp, 2px border radius. No pill-shaped buttons; everything remains geometric.
* **Glow Effect:** Use Flutter's `BoxShadow` with a high blur radius (e.g., `blurRadius: 15`) and the exact color of the border at 40% opacity to create a neon bleed effect.

**The O2 HUD (Heads-Up Display):**

* Positioned top-center.
* Consists of the Chakra Petch Monospaced integer and a thin horizontal line underneath it.
* **Color shifting logic (percentage-based, scales across all Sector difficulties):**
  * O2 > 50%: Cyan Plasma (`#00F0FF`).
  * O2 20% - 50%: Amber Alert (`#FFD700`).
  * O2 < 20%: Core Breach (`#FF003C`) + the text scales up and down slightly (pulsing effect) using a Flutter `AnimationController`.

**In-Game Entities (Flame Rendered):**

* **The Drone:** A solid square of Cyan Plasma, rendered slightly smaller than the grid tile (e.g., 80% of tile size) to leave negative space around it. Apply a `MaskFilter.blur(BlurStyle.outer, 10)` in Flame to make it glow.
* **Extraction Point:** A hollow hexagon or diamond of Neon Isotope, rotating slowly (15 degrees per second) using Flame's `update` loop.
* **Static Walls:** Solid rectangles of `#1A1A2E` (same as grid lines but filled) with a subtle 1px lighter border.
* **Sentry Nodes:** Solid squares of Core Breach (`#FF003C`) with a harsh, unblurred edge to make them look aggressive and distinct from the glowing player.
* **Corrosive Tiles:** Semi-transparent Amber Alert (`#FFD700` at 30% opacity) fill covering the tile, with a thin dashed border.
* **Decaying Walls:** Same as Static Walls but with a pulsing opacity animation (fade in/out over 3 seconds).

### 6. Animation & Feedback ("The Juice")

Minimalist games live or die by how they feel.

* **Easing Curves:** Never use linear animation. Use `Curves.easeOutExpo` for UI elements entering the screen (fast entry, slow settle) and movement interpolation.
* **Movement Snap:** When swiping, the Drone should take exactly **0.12 seconds** to slide to the next tile. This feels instantaneous but visually smooth.
* **Haptics:** Add a light system vibration (using Flutter's `HapticFeedback.lightImpact()`) every time the Drone successfully moves to a tile, and a `heavyImpact()` if the player swipes into an impassable wall or takes damage.
* **Low O2 Vignette:** When O2 drops below 20%, a full-screen semi-transparent overlay pulses red at the edges. Intensity increases as O2 approaches 0.

---
