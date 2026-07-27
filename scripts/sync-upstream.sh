#!/usr/bin/env bash
# Refresh the vendored last30days engine from upstream.
#
#   scripts/sync-upstream.sh            # track upstream main
#   scripts/sync-upstream.sh v3.19.0    # track a specific tag or branch
#
# Only upstream-owned files are replaced. SKILL.md and scripts/find-ideas.sh
# (this profile's own files) are left untouched.
set -euo pipefail

UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/mvanhorn/last30days-skill.git}"
UPSTREAM_REF="${1:-main}"

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/last30days-safe"
WRAPPER="$SKILL_DIR/scripts/find-ideas.sh"

command -v git >/dev/null 2>&1 || { echo "sync-upstream: git is required" >&2; exit 1; }
[[ -f "$SKILL_DIR/SKILL.md" ]] || { echo "sync-upstream: run this from the repository, $SKILL_DIR not found" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "Cloning $UPSTREAM_REPO @ $UPSTREAM_REF ..."
git clone --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_REPO" "$TMP_DIR/upstream" >/dev/null 2>&1 \
  || { echo "sync-upstream: clone failed (bad ref '$UPSTREAM_REF'?)" >&2; exit 1; }

SRC="$TMP_DIR/upstream/skills/last30days"
[[ -f "$SRC/scripts/last30days.py" ]] || { echo "sync-upstream: upstream layout changed, engine not found" >&2; exit 1; }

# Keep this profile's wrapper, replace everything else that upstream owns.
cp "$WRAPPER" "$TMP_DIR/find-ideas.sh"
rm -rf "$SKILL_DIR/scripts" "$SKILL_DIR/references" "$SKILL_DIR/agents"
cp -R "$SRC/scripts"    "$SKILL_DIR/scripts"
cp -R "$SRC/references" "$SKILL_DIR/references"
cp -R "$SRC/agents"     "$SKILL_DIR/agents"
cp "$SRC/.skillignore"  "$SKILL_DIR/.skillignore"
cp "$TMP_DIR/find-ideas.sh" "$WRAPPER"
chmod +x "$WRAPPER"

UPSTREAM_VERSION="$(sed -n 's/^version: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' "$SRC/SKILL.md" | head -1)"
echo "Done. Vendored engine is now upstream ${UPSTREAM_VERSION:-$UPSTREAM_REF}."
echo "Review 'git diff', then bump the version in SKILL.md and .claude-plugin/*.json if needed."
