#!/usr/bin/env bash
# =============================================================================
# render-formula.sh
# =============================================================================
# Renders Formula/ideasy.rb from Formula/ideasy.rb.template for a given IDEasy
# release version and its per-platform SHA256 checksums.
#
# Every value is a required argument and is validated before anything is
# written. The formula is rendered as a whole file - it is never patched in
# place - so a missing or malformed value fails the script instead of silently
# producing a formula with an empty version or checksum.
#
# Usage:
#   ./render-formula.sh VERSION SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64
#
# Example:
#   ./render-formula.sh 2026.07.002 8ff84081...d458 60969a02...951a f03c8a0b...7ebc 1b2c3d4e...9f00
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="${SCRIPT_DIR}/Formula/ideasy.rb.template"
FORMULA_PATH="${SCRIPT_DIR}/Formula/ideasy.rb"

# IDEasy releases are named <year>.<month>.<counter>, optionally with a suffix such as -beta.
VERSION_PATTERN='^[0-9]{4}\.[0-9]{2}\.[0-9]{3}(-[a-zA-Z0-9.]+)?$'
SHA256_PATTERN='^[0-9a-f]{64}$'

usage() {
  echo "Usage: ${0} VERSION SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64" >&2
}

if [[ "$#" -ne 5 ]]
then
  echo "ERROR: expected 5 arguments, got $#." >&2
  usage
  exit 1
fi

VERSION="${1}"
SHA_MAC_ARM64="${2}"
SHA_MAC_X64="${3}"
SHA_LINUX_ARM64="${4}"
SHA_LINUX_X64="${5}"

if ! [[ "${VERSION}" =~ ${VERSION_PATTERN} ]]
then
  echo "ERROR: '${VERSION}' is not a valid IDEasy version (expected e.g. 2026.07.002)." >&2
  exit 1
fi

for name in SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64
do
  value="${!name}"
  if ! [[ "${value}" =~ ${SHA256_PATTERN} ]]
  then
    echo "ERROR: ${name}='${value}' is not a valid SHA256 (expected 64 lowercase hex characters)." >&2
    exit 1
  fi
done

if [[ ! -f "${TEMPLATE_PATH}" ]]
then
  echo "ERROR: template not found at ${TEMPLATE_PATH}" >&2
  exit 1
fi

# --- Render ---
tmp_formula="$(mktemp)"
trap 'rm -f "${tmp_formula}"' EXIT

sed \
  -e "s|@VERSION@|${VERSION}|g" \
  -e "s|@SHA_MAC_ARM64@|${SHA_MAC_ARM64}|g" \
  -e "s|@SHA_MAC_X64@|${SHA_MAC_X64}|g" \
  -e "s|@SHA_LINUX_ARM64@|${SHA_LINUX_ARM64}|g" \
  -e "s|@SHA_LINUX_X64@|${SHA_LINUX_X64}|g" \
  "${TEMPLATE_PATH}" >"${tmp_formula}"

# --- Verify that no placeholder survived and every field is populated ---
if grep -q '@[A-Z_0-9]\+@' "${tmp_formula}"
then
  echo "ERROR: unresolved placeholders remain in the rendered formula:" >&2
  grep -o '@[A-Z_0-9]\+@' "${tmp_formula}" | sort -u >&2
  exit 1
fi

sha_count="$(grep -c 'sha256 "[0-9a-f]\{64\}"' "${tmp_formula}" || true)"
if [[ "${sha_count}" -ne 4 ]]
then
  echo "ERROR: expected 4 populated sha256 entries in the rendered formula, found ${sha_count}." >&2
  exit 1
fi

if ! grep -q "version \"${VERSION}\"" "${tmp_formula}"
then
  echo "ERROR: rendered formula does not declare version \"${VERSION}\"." >&2
  exit 1
fi

mv "${tmp_formula}" "${FORMULA_PATH}"
trap - EXIT

echo "Rendered ${FORMULA_PATH} for IDEasy ${VERSION}"
echo "  mac-arm64:   ${SHA_MAC_ARM64}"
echo "  mac-x64:     ${SHA_MAC_X64}"
echo "  linux-arm64: ${SHA_LINUX_ARM64}"
echo "  linux-x64:   ${SHA_LINUX_X64}"
