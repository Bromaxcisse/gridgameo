# Android Crash Fix — Post-Mortem & Changes

**Date:** March 2026
**Symptom:** Release APK builds successfully but crashes immediately on launch on Android devices.

---

## Root Cause

The release build had **R8/ProGuard code minification enabled** (`isMinifyEnabled = true`, `isShrinkResources = true`) with only `-dontwarn` rules for Google Play Core. There were **no `-keep` rules** for Flutter embedding, Flame engine, or any plugin classes.

R8 aggressively strips and renames classes it considers unused. Flutter's native embedding, Flame's component system, and plugin registrations were being removed at build time, causing immediate crashes on app launch.

---

## All Issues Found & Fixed

### 1. CRITICAL — R8/ProGuard Stripping Flutter and Flame Code

**File:** `android/app/build.gradle.kts`

R8 minification was enabled without proper keep rules. Disabled minification entirely since the APK size overhead is negligible for a game of this scope.

**Change:** Set `isMinifyEnabled = false` and `isShrinkResources = false` in the release build type.

---

### 2. HIGH — Missing Global Error Handling

**File:** `lib/main.dart`

No `FlutterError.onError`, no `PlatformDispatcher.instance.onError`, and no `runZonedGuarded` wrapper. Any uncaught exception from SharedPreferences, Flame component lifecycle, or async operations would crash the app with no recovery.

**Change:** Wrapped `runApp` in `runZonedGuarded`, added `FlutterError.onError` and `PlatformDispatcher.instance.onError` handlers that log errors instead of crashing.

---

### 3. HIGH — `late` Variable Race Conditions in Flame Components

**Files:**
- `lib/game/managers/o2_manager.dart`
- `lib/game/managers/obstacle_reveal_manager.dart`
- `lib/the_oxygen_grid.dart`

Multiple managers used `late` fields initialized only in `onLoad()`. If any code accessed these before `onLoad` completed (e.g., a swipe during the first frame, or a render call before mount), it would throw `LateInitializationError`.

**Changes:**
- O2Manager: Replaced `late` fields with safe zero-defaults and added a `_ready` flag. `deductO2()` and `update()` return early if not ready.
- ObstacleRevealManager: Replaced `late _revealDuration` with a default value and added a `_ready` flag. `revealOpacity` returns 1.0 if not ready.
- TheOxygenGrid: Added a `_loaded` flag set after `onLoad` completes. `onPanEnd` returns early if not loaded.

---

### 4. HIGH — `SectorFactory.getSector()` Assert-Only Validation

**File:** `lib/models/sector_factory.dart`

Used `assert` for bounds checking, which is stripped in release builds. An out-of-range sector value would cause a `RangeError`.

**Change:** Replaced `assert` with `sector.clamp(1, totalSectors)` so invalid values are safely clamped instead of crashing.

---

### 5. MEDIUM — DroneComponent Removes Children During Iteration

**File:** `lib/game/components/drone_component.dart`

`_animateOpacity` called `removeWhere((c) => c is TimerComponent)` from inside a `TimerComponent.onTick` callback, modifying the children list while Flame iterates over it. This could cause `ConcurrentModificationError`.

**Change:** Added a `finished` flag to prevent re-entry, and deferred the `removeWhere` call using `Future.microtask()`.

---

### 6. MEDIUM — Division by Zero in CorrosiveTile

**File:** `lib/game/components/corrosive_tile.dart`

`_drawDashedLine` computed `unitDx = dx / length` without checking if `length` was zero. A degenerate rect (e.g., during initialization when tile size is 0) would produce NaN values.

**Change:** Added `if (length <= 0) return;` guard before the division.

---

### 7. LOW — Unhandled Async Errors in SaveData

**File:** `lib/models/save_data.dart`

All methods called `SharedPreferences.getInstance()` without try/catch. On some Android devices (first launch, low storage, or platform quirks), this can throw unhandled exceptions.

**Change:** Wrapped all methods in try/catch blocks with safe fallback return values (1 for sector, 0 for ratings, empty map for all ratings).

---

## Summary of Changed Files

| File | Change |
|------|--------|
| `android/app/build.gradle.kts` | Disabled R8 minification |
| `lib/main.dart` | Added global error handling |
| `lib/game/managers/o2_manager.dart` | Safe defaults + ready guard |
| `lib/game/managers/obstacle_reveal_manager.dart` | Safe defaults + ready guard |
| `lib/the_oxygen_grid.dart` | Added loaded guard for pan events |
| `lib/models/sector_factory.dart` | Replaced assert with clamp |
| `lib/game/components/drone_component.dart` | Deferred child removal |
| `lib/game/components/corrosive_tile.dart` | Division-by-zero guard |
| `lib/models/save_data.dart` | try/catch on all SharedPreferences calls |
