#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-}"
REPO="${GITHUB_REPOSITORY:-henkipapp/filebrowser}"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <vX.Y.Z>" >&2
  exit 2
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version must match vX.Y.Z" >&2
  exit 2
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

ARCHIVE="sfb-${VERSION}.tar.gz"

git archive --format=tar.gz --output "$WORKDIR/$ARCHIVE" "$VERSION"
SHA256="$(shasum -a 256 "$WORKDIR/$ARCHIVE" | awk '{print $1}')"

URL="https://github.com/${REPO}/archive/refs/tags/${VERSION}.tar.gz"

awk -v url="$URL" -v sha="$SHA256" '
  /^  url / { print "  url \"" url "\""; next }
  /^  sha256 / { print "  sha256 \"" sha "\""; next }
  { print }
' Formula/sfb.rb > "$WORKDIR/sfb.rb"

mv "$WORKDIR/sfb.rb" Formula/sfb.rb

echo "Updated Formula/sfb.rb"
echo "Version: $VERSION"
echo "SHA256: $SHA256"
echo "URL: $URL"
