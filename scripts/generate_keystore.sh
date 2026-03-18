#!/usr/bin/env bash
# =============================================================================
# generate_keystore.sh — OxygenGrid Keystore Generator
# =============================================================================
# Generates a JKS keystore for signing The Oxygen Grid Android app.
#
# PRIVACY NOTICE:
#   This script does NOT read, collect, or transmit any system information,
#   user account data, IP addresses, MAC addresses, location data, or any
#   other personal/machine-identifiable information. Every value used in the
#   keystore is provided manually by the operator via interactive prompts.
# =============================================================================

set -euo pipefail

KEYSTORE_FILENAME="oxygengrid-release.jks"
KEY_ALIAS_DEFAULT="oxygengrid-upload"

echo ""
echo "==========================================="
echo "  OxygenGrid — Keystore Generator"
echo "==========================================="
echo ""
echo "  This script will generate a JKS keystore"
echo "  for signing The Oxygen Grid Android app."
echo ""
echo "  No system, user, IP, or location data is"
echo "  read or collected. All values are entered"
echo "  manually by you."
echo ""
echo "==========================================="
echo ""

# ── Prompt for company / certificate details ──────────────────────────────

read -rp "Key alias (default: ${KEY_ALIAS_DEFAULT}): " KEY_ALIAS
KEY_ALIAS="${KEY_ALIAS:-$KEY_ALIAS_DEFAULT}"

read -rsp "Keystore password (min 6 characters): " STORE_PASSWORD
echo ""
if [ "${#STORE_PASSWORD}" -lt 6 ]; then
  echo "ERROR: Keystore password must be at least 6 characters."
  exit 1
fi

read -rsp "Key password (min 6 characters): " KEY_PASSWORD
echo ""
if [ "${#KEY_PASSWORD}" -lt 6 ]; then
  echo "ERROR: Key password must be at least 6 characters."
  exit 1
fi

read -rp "Full name (CN — e.g. John Smith): " CN
if [ -z "$CN" ]; then
  echo "ERROR: Full name (CN) is required."
  exit 1
fi

read -rp "Organizational Unit (OU — e.g. Mobile Development): " OU
if [ -z "$OU" ]; then
  echo "ERROR: Organizational Unit (OU) is required."
  exit 1
fi

read -rp "Organization name (O — e.g. Oxygen Grid Studios): " ORG
if [ -z "$ORG" ]; then
  echo "ERROR: Organization (O) is required."
  exit 1
fi

read -rp "City / Locality (L — e.g. Berlin): " LOCALITY
if [ -z "$LOCALITY" ]; then
  echo "ERROR: City / Locality (L) is required."
  exit 1
fi

read -rp "State / Province (ST — e.g. Bavaria): " STATE
if [ -z "$STATE" ]; then
  echo "ERROR: State / Province (ST) is required."
  exit 1
fi

read -rp "Country code (C — two-letter, e.g. DE): " COUNTRY
if [ -z "$COUNTRY" ] || [ "${#COUNTRY}" -ne 2 ]; then
  echo "ERROR: Country code (C) must be exactly 2 letters."
  exit 1
fi

read -rp "Company website or domain (e.g. oxygengrid.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
  echo "ERROR: Company website/domain is required."
  exit 1
fi

DNAME="CN=${CN}, OU=${OU}, O=${ORG}, L=${LOCALITY}, ST=${STATE}, C=${COUNTRY}"

echo ""
echo "--- Certificate Distinguished Name ---"
echo "  ${DNAME}"
echo "  Domain: ${DOMAIN}"
echo "--------------------------------------"
echo ""

# ── Generate keystore ─────────────────────────────────────────────────────

if [ -f "${KEYSTORE_FILENAME}" ]; then
  echo "WARNING: ${KEYSTORE_FILENAME} already exists in the current directory."
  read -rp "Overwrite? (y/N): " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  rm -f "${KEYSTORE_FILENAME}"
fi

echo "Generating keystore..."

keytool -genkey -v \
  -keystore "${KEYSTORE_FILENAME}" \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias "${KEY_ALIAS}" \
  -storepass "${STORE_PASSWORD}" \
  -keypass "${KEY_PASSWORD}" \
  -dname "${DNAME}"

echo ""
echo "Keystore generated: ${KEYSTORE_FILENAME}"
echo ""

# ── Encode to base64 ─────────────────────────────────────────────────────

BASE64_OUTPUT="${KEYSTORE_FILENAME}.base64.txt"
base64 -w 0 < "${KEYSTORE_FILENAME}" > "${BASE64_OUTPUT}" 2>/dev/null || \
  base64 -i "${KEYSTORE_FILENAME}" -o "${BASE64_OUTPUT}" 2>/dev/null || \
  openssl base64 -A -in "${KEYSTORE_FILENAME}" -out "${BASE64_OUTPUT}"

echo "Base64-encoded keystore saved to: ${BASE64_OUTPUT}"
echo ""

# ── Print GitHub Secrets instructions ─────────────────────────────────────

echo "==========================================="
echo "  GitHub Secrets — Setup Instructions"
echo "==========================================="
echo ""
echo "  Go to your GitHub repository:"
echo "    Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "  Add the following 4 secrets:"
echo ""
echo "  ┌──────────────────────────────┬──────────────────────────────────────┐"
echo "  │ Secret Name                  │ Value                                │"
echo "  ├──────────────────────────────┼──────────────────────────────────────┤"
echo "  │ OxygenGridBase64             │ (entire contents of ${BASE64_OUTPUT})│"
echo "  │ OxygenGridStorePassword      │ Your keystore password               │"
echo "  │ OxygenGridKeyPassword        │ Your key password                    │"
echo "  │ OxygenGridKeyAlias           │ ${KEY_ALIAS}$(printf '%*s' $((22 - ${#KEY_ALIAS})) '')│"
echo "  └──────────────────────────────┴──────────────────────────────────────┘"
echo ""
echo "  IMPORTANT:"
echo "    • Copy the ENTIRE content of ${BASE64_OUTPUT} as the value"
echo "      for OxygenGridBase64 (it is one long line, no line breaks)."
echo "    • Delete ${BASE64_OUTPUT} and ${KEYSTORE_FILENAME} from this"
echo "      directory after saving the secrets. Never commit them."
echo "    • Store a backup of ${KEYSTORE_FILENAME} in a secure location"
echo "      (encrypted USB, password manager, etc.)."
echo ""
echo "==========================================="
echo "  Done!"
echo "==========================================="
