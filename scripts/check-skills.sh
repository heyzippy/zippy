#!/usr/bin/env sh
#
# Verify the published skill tree satisfies the contract that
# https://heyzippy.io/skills/install.sh depends on.
#
# The installer does exactly this:
#
#   BASE="https://raw.githubusercontent.com/heyzippy/zippy/main/skills"
#   files=$(curl -fsSL "$BASE/manifest.txt")
#   for f in $files; do curl -fsSL "$BASE/zippy/$f" -o "$dir/$f"; done
#
# and runs under `set -eu`, so a single missing path aborts the whole install
# with a bare curl error. This script is that loop against the working tree, so
# a PR that breaks the layout fails here instead of in users' terminals.
#
# Usage: scripts/check-skills.sh   (from the repo root; exit 0 = install works)

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS="$ROOT/skills"
MANIFEST="$SKILLS/manifest.txt"
NAME="zippy"
fail=0

err() { printf 'FAIL: %s\n' "$*" >&2; fail=1; }
ok()  { printf 'ok:   %s\n' "$*"; }

# 1. The manifest the installer fetches first. Its absence is what broke the
#    install for ~3.5 weeks: curl -f exits 22, set -e kills the script.
if [ ! -f "$MANIFEST" ]; then
  err "skills/manifest.txt is missing — install.sh aborts at its first fetch"
  exit 1
fi
[ -s "$MANIFEST" ] || err "skills/manifest.txt is empty — nothing would install"
ok "skills/manifest.txt exists"

# 2. Every path it lists must resolve under skills/zippy/.
count=0
while IFS= read -r f || [ -n "$f" ]; do
  case "$f" in ''|\#*) continue ;; esac
  count=$((count + 1))
  if [ -f "$SKILLS/$NAME/$f" ]; then
    ok "manifest -> skills/$NAME/$f"
  else
    err "manifest lists '$f' but skills/$NAME/$f does not exist"
  fi
done < "$MANIFEST"
[ "$count" -gt 0 ] || err "manifest lists no files"

# 3. SKILL.md is the entry point; the installer's success message points at it.
grep -qx 'SKILL.md' "$MANIFEST" || err "manifest does not list SKILL.md"
if [ -f "$SKILLS/$NAME/SKILL.md" ]; then
  head -1 "$SKILLS/$NAME/SKILL.md" | grep -q '^---$' \
    || err "skills/$NAME/SKILL.md has no YAML frontmatter (agents will not load it)"
  grep -q '^name:' "$SKILLS/$NAME/SKILL.md" || err "skills/$NAME/SKILL.md frontmatter has no 'name:'"
  grep -q '^description:' "$SKILLS/$NAME/SKILL.md" || err "skills/$NAME/SKILL.md frontmatter has no 'description:'"
fi

# 4. Nothing under skills/ that the installer cannot serve. The v0.1.5 sync
#    flattened the tree into skills/zippy_*.md (the platform's internal distri
#    runtime skills, from agents/distri-skills/ — not this CLI's skill) and
#    deleted the real one. Catch that shape specifically.
if ls "$SKILLS"/zippy_*.md >/dev/null 2>&1; then
  err "flat skills/zippy_*.md present — the distri runtime skills were synced here again; they belong in the platform repo under agents/distri-skills/"
fi

# 5. Orphans: files under skills/zippy/ that the manifest never lists are
#    invisible to the installer, so they ship to nobody.
find "$SKILLS/$NAME" -type f | sed "s|^$SKILLS/$NAME/||" | while IFS= read -r f; do
  grep -qx "$f" "$MANIFEST" || printf 'WARN: skills/%s/%s is not in manifest.txt (it will not be installed)\n' "$NAME" "$f" >&2
done

if [ "$fail" -ne 0 ]; then
  printf '\nskill tree is broken — https://heyzippy.io/skills/install.sh would fail\n' >&2
  exit 1
fi
printf '\nskill tree ok: %s file(s), install.sh contract satisfied\n' "$count"
