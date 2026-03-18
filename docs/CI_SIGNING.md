# CI / Signing — The Oxygen Grid

## Overview

This project uses **GitHub Actions** to automatically build a **signed release APK** and **AAB** on every push. The signing keystore is stored exclusively in GitHub Secrets and is never committed to the repository.

---

## 1. Generate the Keystore

A helper script is provided at `scripts/generate_keystore.sh`.

### Prerequisites

- **Java JDK** (8+) — the `keytool` utility must be available on your PATH.
- **bash** — Git Bash (Windows), Terminal (macOS/Linux), or WSL.

### Run the script

```bash
cd scripts
bash generate_keystore.sh
```

The script will prompt you for **all** of the following (nothing is auto-filled):

| # | Prompt | Example |
|---|--------|---------|
| 1 | Key alias | `oxygengrid-upload` |
| 2 | Keystore password | *(your choice, min 6 chars)* |
| 3 | Key password | *(your choice, min 6 chars)* |
| 4 | Full name (CN) | `John Smith` |
| 5 | Organizational Unit (OU) | `Mobile Development` |
| 6 | Organization (O) | `Oxygen Grid Studios` |
| 7 | City / Locality (L) | `Berlin` |
| 8 | State / Province (ST) | `Bavaria` |
| 9 | Country code (C) | `DE` |
| 10 | Company domain | `oxygengrid.com` |

### Privacy Notice

The script does **NOT** read, collect, or transmit any:
- System information (hostname, OS, hardware)
- User account data (username, home directory)
- IP addresses or MAC addresses
- Geographic/location data
- Environment variables

Every value used in the keystore is provided manually by the operator.

### Output

The script creates two files in the current directory:

| File | Purpose |
|------|---------|
| `oxygengrid-release.jks` | The JKS keystore (keep a secure backup) |
| `oxygengrid-release.jks.base64.txt` | Base64-encoded keystore for GitHub Secrets |

**Delete both files from the project directory after saving the secrets.** They are git-ignored, but should not linger on disk.

---

## 2. Add GitHub Secrets

Go to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

Add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `OxygenGridBase64` | Entire contents of `oxygengrid-release.jks.base64.txt` |
| `OxygenGridStorePassword` | The keystore password you entered |
| `OxygenGridKeyPassword` | The key password you entered |
| `OxygenGridKeyAlias` | The key alias you entered (e.g. `oxygengrid-upload`) |

---

## 3. Trigger the Workflow

The workflow runs automatically on **every push** to any branch.

To trigger manually:
1. Push any commit to any branch.
2. Go to **Actions** tab in your GitHub repository.
3. Select the **"Build Signed APK & AAB"** workflow.
4. View the build progress and download artifacts.

### Artifacts

After a successful build, two artifacts are available for download:

| Artifact | Contents |
|----------|----------|
| `release-apk` | `app-release.apk` — signed release APK |
| `release-aab` | `app-release.aab` — signed release AAB (for Play Store) |

---

## 4. Security Model

| Concern | Mitigation |
|---------|------------|
| Keystore in repo | Never committed — `.gitignore` blocks `*.jks`, `*.keystore`, `*.base64.txt`, `key.properties` |
| Keystore in CI | Decoded from `OxygenGridBase64` secret at runtime; deleted in `always()` cleanup step |
| Passwords in logs | Passed via environment variables from GitHub Secrets (masked automatically) |
| Debug fallback | Release build type uses the `release` signing config only — no debug fallback |
| ProGuard / R8 | Enabled with `proguard-rules.pro` suppressing Play Core warnings |

---

## 5. Files Reference

| File | Purpose |
|------|---------|
| `.github/workflows/build.yml` | GitHub Actions workflow |
| `scripts/generate_keystore.sh` | Keystore generation script |
| `android/app/build.gradle.kts` | Gradle build config with release signing |
| `android/app/proguard-rules.pro` | R8/ProGuard rules (Play Core dontwarn) |
| `docs/CI_SIGNING.md` | This document |
