# APK Crash Diagnostic — Full Investigation Report

**Date:** March 2026  
**Symptom:** App runs perfectly on Chrome via `flutter run -d chrome`, but the release APK built by GitHub Actions crashes immediately on launch — the app never renders a single frame.  
**Previous fixes:** `docs/ANDROID_CRASH_FIX.md` (R8 minification, error handling, late-variable guards, etc.) — these did not resolve the crash.

---

## Executive Summary

The immediate crash is caused by a **namespace/package mismatch** between `build.gradle.kts` and `MainActivity.kt`. Android cannot find the activity class at runtime, producing a `ClassNotFoundException` before any Flutter or Dart code executes. A secondary issue — `pubspec.lock` being gitignored — introduces a reproducibility risk for CI builds.

---

## Investigation Scope

| Area | Status |
|------|--------|
| Android namespace vs. MainActivity package | **ROOT CAUSE FOUND** |
| GitHub Actions workflow (`build.yml`) | Reviewed — structurally correct |
| `.gitignore` exclusions | `pubspec.lock` gitignored (secondary issue) |
| Dart source code (36 files in `lib/`) | No web-only APIs on Android paths |
| Asset files (images + fonts) | All present and git-tracked |
| Signing configuration | Correctly wired via CI secrets |
| Conditional platform code (audio) | Properly isolated with conditional exports |
| Firebase / Supabase / network calls | None used — app is offline |
| Gradle configuration | Memory flags too high for CI runners (minor) |

---

## ROOT CAUSE — Activity Class Not Found

### The Mismatch

| Property | Value |
|----------|-------|
| `namespace` in `android/app/build.gradle.kts` (line 17) | `com.oxygengrid.tripple` |
| `applicationId` in `android/app/build.gradle.kts` (line 31) | `com.oxygengrid.tripple` |
| `android:name` in `AndroidManifest.xml` (line 7) | `.MainActivity` |
| **Resolved class at runtime** | `com.oxygengrid.tripple.MainActivity` |
| `package` declaration in `MainActivity.kt` (line 1) | `com.oxygengrid.tripple.the_oxygen_grid` |
| **Actual class in the APK** | `com.oxygengrid.tripple.the_oxygen_grid.MainActivity` |

### How Android Resolves Activity Names

In Android Gradle Plugin 8.x, the `namespace` property in `build.gradle.kts` replaces the deprecated `package` attribute in `AndroidManifest.xml`. When the manifest declares `android:name=".MainActivity"`, the leading dot tells Android to prefix it with the application's namespace:

```
.MainActivity  →  {namespace}.MainActivity  →  com.oxygengrid.tripple.MainActivity
```

But `MainActivity.kt` declares itself in a **different** package:

```kotlin
package com.oxygengrid.tripple.the_oxygen_grid   // ← actual location

class MainActivity : FlutterActivity()
```

At runtime, Android's `ActivityManager` attempts to instantiate `com.oxygengrid.tripple.MainActivity` via reflection. That class does not exist. The result is:

```
java.lang.ClassNotFoundException:
  Didn't find class "com.oxygengrid.tripple.MainActivity"
```

This exception occurs at the native Android framework level — before the Flutter engine initializes, before any Dart code runs, and before any error handler can intercept it. This perfectly explains the symptom: **the app crashes immediately and never renders anything.**

### Why It Works on Chrome

`flutter run -d chrome` builds and serves the **web** target. The web build does not use `AndroidManifest.xml`, `build.gradle.kts`, or any Android-specific configuration. The namespace/package mismatch is invisible to the web platform.

### Why the Build Succeeds

Gradle compiles `MainActivity.kt` successfully because the Kotlin compiler only cares that the source file's package declaration matches its directory location (`kotlin/com/oxygengrid/tripple/the_oxygen_grid/`). AAPT2 processes the manifest XML without validating that declared activity class names resolve to actual compiled classes. The mismatch is only detected at runtime by the Android framework.

### How This Likely Happened

When `flutter create --org com.oxygengrid.tripple the_oxygen_grid` was run, Flutter generated:
- `namespace = "com.oxygengrid.tripple.the_oxygen_grid"`
- Directory: `kotlin/com/oxygengrid/tripple/the_oxygen_grid/`
- Package: `package com.oxygengrid.tripple.the_oxygen_grid`

At some point, the `namespace` (and `applicationId`) were shortened to `com.oxygengrid.tripple` — but `MainActivity.kt` was never moved or updated to match.

---

## Fix Plan — Root Cause

Two options are available. **Option A is recommended** as the safest, most targeted fix.

### Option A: Fully-Qualify the Activity Name in AndroidManifest.xml (Recommended)

In `android/app/src/main/AndroidManifest.xml`, change line 7 from:

```xml
android:name=".MainActivity"
```

to:

```xml
android:name="com.oxygengrid.tripple.the_oxygen_grid.MainActivity"
```

This uses an absolute class reference that bypasses namespace resolution entirely. No other files need to change. The `applicationId` remains `com.oxygengrid.tripple` (the identity on the Play Store and device).

### Option B: Align the Namespace to the Kotlin Package

In `android/app/build.gradle.kts`, change line 17 from:

```kotlin
namespace = "com.oxygengrid.tripple"
```

to:

```kotlin
namespace = "com.oxygengrid.tripple.the_oxygen_grid"
```

This restores the original namespace that `flutter create` would have generated. The `applicationId` can remain `com.oxygengrid.tripple` since AGP 8 treats them as independent properties.

> **Note:** If Option B is chosen, verify that no other code references the R class or BuildConfig under `com.oxygengrid.tripple` — the namespace change would move these to `com.oxygengrid.tripple.the_oxygen_grid`.

---

## SECONDARY ISSUE — `pubspec.lock` Gitignored

### The Problem

`.gitignore` line 34 excludes `pubspec.lock` from version control:

```
pubspec.lock
```

The `pubspec.lock` file pins exact dependency versions (including transitive dependencies). When it is gitignored:

1. CI runs `flutter pub get` and resolves dependencies **from scratch** every time.
2. If `flame`, `shared_preferences`, or any transitive dependency publishes a new version between builds, CI may pull a different version than local development.
3. This can introduce subtle runtime differences between the Chrome build (local, with your lock file) and the APK build (CI, with freshly resolved versions).

### Dart/Flutter Guidance

The official Dart recommendation is:
- **Applications:** Commit `pubspec.lock` for reproducible builds.
- **Packages/Libraries:** Gitignore `pubspec.lock` to test against latest compatible versions.

The Oxygen Grid is an application, not a library. `pubspec.lock` should be committed.

### Fix

Remove `pubspec.lock` from `.gitignore` (delete line 34), then commit the existing lock file:

```bash
# Remove the line "pubspec.lock" from .gitignore
# Then:
git add pubspec.lock
git commit -m "Track pubspec.lock for reproducible CI builds"
```

---

## MINOR OBSERVATION — Gradle JVM Memory for CI

### The Problem

`android/gradle.properties` line 1:

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
```

GitHub Actions `ubuntu-latest` runners have approximately 7 GB of total RAM. Requesting an 8 GB Java heap may cause the Gradle daemon to be killed by the OS OOM killer mid-build. This would cause a **build failure** (not a crashing APK), but it's worth correcting for CI reliability.

### Fix

Either:
- Reduce the values in `gradle.properties` to something CI-safe (e.g., `-Xmx4G -XX:MaxMetaspaceSize=2G`), or
- Override JVM args in the CI workflow with an environment variable before the build step:

```yaml
- name: Build release APK
  env:
    GRADLE_OPTS: "-Xmx4G -XX:MaxMetaspaceSize=2G -XX:ReservedCodeCacheSize=256m"
  run: flutter build apk --release
```

---

## Eliminated Causes

The following were investigated and confirmed to NOT be contributing to the crash:

| Investigated Area | Finding |
|-------------------|---------|
| **Missing assets** | All 11 asset files (`logo.png` + 10 ChakraPetch fonts) exist on disk and are tracked in git. CI will have them. |
| **Web-only Dart imports** | `audio_manager_web.dart` uses `package:web`, but is gated behind `dart.library.js_interop` conditional export. Android uses the no-op stub. No `dart:html` or `dart:js` imports anywhere. |
| **Firebase / Supabase** | Not used. No `google-services.json` needed. |
| **Signing configuration** | CI correctly decodes keystore from `OxygenGridBase64` secret, writes `key.properties` with all four required fields, and references the keystore at the correct absolute path. An invalid signature would prevent installation, not cause a launch crash. |
| **R8 / ProGuard** | Already disabled (`isMinifyEnabled = false`, `isShrinkResources = false`) per the previous crash fix. |
| **`late` variable races** | Already guarded with `_ready` / `_loaded` flags per the previous crash fix. |
| **Network / API calls** | App is fully offline. No network permissions or API URLs. |
| **Gradle wrapper files** | `gradlew`, `gradlew.bat`, and `gradle-wrapper.jar` are gitignored, but Flutter regenerates them automatically during `flutter build apk`. `gradle-wrapper.properties` (specifying Gradle 8.14) IS tracked and available to CI. |
| **`local.properties`** | Gitignored, but `flutter build apk` regenerates it with the correct Flutter SDK path in CI. `settings.gradle.kts` reads it for the Flutter SDK path, which is available after regeneration. |
| **`android:icon="@mipmap/ic_launcher"`** | Flutter's default launcher icons are generated during project creation and are present in the `res/` directories. |

---

## Verification After Fix

After applying the fix, verify with these steps:

1. **Rebuild the APK locally:**
   ```bash
   flutter build apk --release
   ```

2. **Install and test on a physical device or emulator:**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

3. **If the APK still crashes, capture the crash log:**
   ```bash
   adb logcat *:E | grep -E "AndroidRuntime|FATAL|flutter|ClassNotFoundException"
   ```

4. **Push to GitHub and verify the CI-built APK also works.**

5. **Confirm `pubspec.lock` is tracked** (after applying the secondary fix):
   ```bash
   git ls-files pubspec.lock
   ```

---

## Fix Priority Summary

| # | Issue | Severity | Confidence | Fix |
|---|-------|----------|------------|-----|
| 1 | Namespace/package mismatch — `ClassNotFoundException` for `MainActivity` | **CRITICAL** | 100% | Fully-qualify activity name in `AndroidManifest.xml` or align `namespace` |
| 2 | `pubspec.lock` gitignored — non-reproducible CI builds | **MEDIUM** | 100% | Remove from `.gitignore` and commit the lock file |
| 3 | Gradle JVM memory exceeds CI runner RAM | **LOW** | 100% | Reduce `-Xmx` or override in workflow |
