#!/usr/bin/env bash
# =============================================================================
# update-formula.sh
# =============================================================================
# Downloads IDEasy release archives and updates the Homebrew formula with
# correct SHA256 checksums and version numbers.
#
# Usage:
#   ./update-formula.sh [VERSION]
#
# If VERSION is omitted, the script fetches the latest release from GitHub.
# =============================================================================

set -euo pipefail

FORMULA_PATH="Formula/ideasy.rb"
MAVEN_BASE="https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli"

# --- Determine version ---
if [ -n "${1:-}" ]; then
  VERSION="$1"
else
  echo "Fetching latest release version from GitHub..."
  VERSION=$(curl -s https://api.github.com/repos/devonfw/IDEasy/releases/latest \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name":\s*"release\/([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "ERROR: Could not determine latest version. Please provide it as an argument."
    exit 1
  fi
fi

echo "Updating formula for IDEasy version: $VERSION"
echo "=============================================="

# --- Download and checksum each platform archive ---
declare -A URLS
URLS[mac-arm64]="${MAVEN_BASE}/${VERSION}/ide-cli-${VERSION}-mac-arm64.tar.gz"
URLS[mac-x64]="${MAVEN_BASE}/${VERSION}/ide-cli-${VERSION}-mac-x64.tar.gz"
URLS[linux-x64]="${MAVEN_BASE}/${VERSION}/ide-cli-${VERSION}-linux-x64.tar.gz"

declare -A SHAS

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

for platform in mac-arm64 mac-x64 linux-x64; do
  url="${URLS[$platform]}"
  file="${TMPDIR}/ide-cli-${VERSION}-${platform}.tar.gz"

  echo ""
  echo "Downloading ${platform}..."
  echo "  URL: ${url}"

  if curl -fSL -o "$file" "$url"; then
    sha=$(shasum -a 256 "$file" | awk '{print $1}')
    SHAS[$platform]="$sha"
    echo "  SHA256: ${sha}"
  else
    echo "  WARNING: Download failed for ${platform}. Skipping."
    SHAS[$platform]="DOWNLOAD_FAILED"
  fi
done

# --- Update the formula file ---
echo ""
echo "Updating ${FORMULA_PATH}..."

if [ ! -f "$FORMULA_PATH" ]; then
  echo "ERROR: Formula file not found at ${FORMULA_PATH}"
  echo "  Make sure you run this script from the tap repository root."
  exit 1
fi

# Update version
sed -i.bak -E "s/version \"[^\"]+\"/version \"${VERSION}\"/" "$FORMULA_PATH"

# Update SHA256 values (handles both placeholder and real hashes)
sed -i.bak -E "/mac-arm64\.tar\.gz/{n;s/sha256 \"[^\"]+\"/sha256 \"${SHAS[mac-arm64]}\"/;}" "$FORMULA_PATH"
sed -i.bak -E "/mac-x64\.tar\.gz/{n;s/sha256 \"[^\"]+\"/sha256 \"${SHAS[mac-x64]}\"/;}" "$FORMULA_PATH"
sed -i.bak -E "/linux-x64\.tar\.gz/{n;s/sha256 \"[^\"]+\"/sha256 \"${SHAS[linux-x64]}\"/;}" "$FORMULA_PATH"

# Clean up backup files
rm -f "${FORMULA_PATH}.bak"

echo ""
echo "=============================================="
echo "Formula updated successfully!"
echo ""
echo "Summary:"
echo "  Version:       ${VERSION}"
echo "  Mac ARM64 SHA: ${SHAS[mac-arm64]}"
echo "  Mac x64 SHA:   ${SHAS[mac-x64]}"
echo "  Linux x64 SHA: ${SHAS[linux-x64]}"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff ${FORMULA_PATH}"
echo "  2. Test locally:       brew install --build-from-source ./Formula/ideasy.rb"
echo "  3. Commit and push:    git add ${FORMULA_PATH} && git commit -m 'ideasy ${VERSION}'"
