#!/usr/bin/env bash
# =============================================================================
# wait-for-central.sh
# =============================================================================
# Waits until all IDEasy release archives of a given version are actually
# downloadable from Maven Central (repo1.maven.org) and reports their SHA256
# checksums.
#
# Publishing to Maven Central is not instantaneous: even once the Central
# Portal reports a deployment as published, it takes a moment until the
# artifacts are served from repo1. The Homebrew formula points at repo1, so it
# must not be published before the URLs it references actually resolve.
#
# When expected checksums are passed, they are compared against what Central
# serves. That proves the bytes that were released and the bytes referenced by
# the formula are identical.
#
# Usage:
#   ./wait-for-central.sh VERSION [SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64]
#
# Environment:
#   WAIT_MAX_SECONDS       overall timeout, default 1800 (30 minutes)
#   POLL_INTERVAL_SECONDS  delay between attempts, default 30
#
# Output:
#   Writes 'sha_<platform>=<checksum>' lines to stdout and, when running in
#   GitHub Actions, appends them to $GITHUB_OUTPUT.
#
# Note: kept compatible with bash 3.2 (the default bash on macOS runners), so
# no associative arrays are used here.
# =============================================================================

set -euo pipefail

MAVEN_BASE="https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli"
PLATFORMS=(mac-arm64 mac-x64 linux-arm64 linux-x64)

WAIT_MAX_SECONDS="${WAIT_MAX_SECONDS:-1800}"
POLL_INTERVAL_SECONDS="${POLL_INTERVAL_SECONDS:-30}"

if [ "$#" -ne 1 ] && [ "$#" -ne 5 ]; then
  echo "ERROR: expected 1 or 5 arguments, got $#." >&2
  echo "Usage: $0 VERSION [SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64]" >&2
  exit 1
fi

VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "ERROR: VERSION must not be empty." >&2
  exit 1
fi

# Expected checksums in the same order as PLATFORMS, empty when not provided.
EXPECTED=()
if [ "$#" -eq 5 ]; then
  EXPECTED=("$2" "$3" "$4" "$5")
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

deadline=$(( $(date +%s) + WAIT_MAX_SECONDS ))

echo "Waiting for IDEasy ${VERSION} to become available on Maven Central"
echo "  timeout: ${WAIT_MAX_SECONDS}s, poll interval: ${POLL_INTERVAL_SECONDS}s"

SHAS=()

index=0
for platform in "${PLATFORMS[@]}"; do
  url="${MAVEN_BASE}/${VERSION}/ide-cli-${VERSION}-${platform}.tar.gz"
  archive="${workdir}/ide-cli-${VERSION}-${platform}.tar.gz"

  echo ""
  echo "Checking ${platform}: ${url}"

  until curl -fsSI "$url" > /dev/null 2>&1; do
    now="$(date +%s)"
    if [ "$now" -ge "$deadline" ]; then
      echo "ERROR: ${url} did not become available within ${WAIT_MAX_SECONDS}s." >&2
      echo "       The release was not fully published to Maven Central." >&2
      exit 1
    fi
    echo "  not available yet, retrying in ${POLL_INTERVAL_SECONDS}s ($(( deadline - now ))s left)"
    sleep "$POLL_INTERVAL_SECONDS"
  done

  curl -fsSL -o "$archive" "$url"
  sha="$(shasum -a 256 "$archive" | awk '{print $1}')"
  SHAS[$index]="$sha"
  echo "  available, sha256: ${sha}"

  if [ "${#EXPECTED[@]}" -gt 0 ]; then
    expected="${EXPECTED[$index]}"
    if [ "$sha" != "$expected" ]; then
      echo "ERROR: checksum mismatch for ${platform}." >&2
      echo "       released: ${expected}" >&2
      echo "       central:  ${sha}" >&2
      exit 1
    fi
    echo "  matches the released artifact"
  fi

  rm -f "$archive"
  index=$(( index + 1 ))
done

echo ""
echo "All IDEasy ${VERSION} archives are available on Maven Central."

index=0
for platform in "${PLATFORMS[@]}"; do
  key="sha_$(echo "$platform" | tr '-' '_')"
  echo "${key}=${SHAS[$index]}"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "${key}=${SHAS[$index]}" >> "$GITHUB_OUTPUT"
  fi
  index=$(( index + 1 ))
done
