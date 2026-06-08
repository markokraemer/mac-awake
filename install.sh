#!/bin/bash
set -euo pipefail

REPO="markokraemer/mac-awake"
BRANCH="${MAC_AWAKE_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
ROOT="${MAC_AWAKE_HOME:-$HOME/.local/share/mac-awake}"
BIN="$ROOT/bin/mac-awake"
LINK_DIR="$HOME/.local/bin"
LINK="$LINK_DIR/mac-awake"
START="# >>> mac-awake >>>"
END="# <<< mac-awake <<<"
# Old name, stripped on upgrade so reinstalls leave no duplicate block.
LEGACY_START="# >>> mac-sleep-forever >>>"
LEGACY_END="# <<< mac-sleep-forever <<<"
LEGACY_ROOT="$HOME/.local/share/mac-sleep-forever"
LEGACY_LINK="$LINK_DIR/mac-sleep-forever"

copy_if_different() {
  local src="$1"
  local dest="$2"

  [ -f "$src" ] || return 1
  if [ ! -f "$dest" ] || ! /usr/bin/cmp -s "$src" "$dest"; then
    /bin/cp "$src" "$dest"
  fi
}

install_block() {
  local file="$1"
  local tmp
  tmp="$(/usr/bin/mktemp)"

  if [ -f "$file" ]; then
    /usr/bin/awk \
      -v start="$START" -v end="$END" \
      -v lstart="$LEGACY_START" -v lend="$LEGACY_END" '
      $0 == start || $0 == lstart { skip=1; next }
      $0 == end || $0 == lend { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp"
  fi

  {
    /bin/cat "$tmp"
    echo
    echo "$START"
    echo "export MAC_AWAKE_HOME=\"$ROOT\""
    echo "alias mac-awake=\"\$MAC_AWAKE_HOME/bin/mac-awake\""
    echo "alias awake-on=\"\$MAC_AWAKE_HOME/bin/mac-awake on\""
    echo "alias awake-off=\"\$MAC_AWAKE_HOME/bin/mac-awake off\""
    echo "alias awake-status=\"\$MAC_AWAKE_HOME/bin/mac-awake status\""
    echo "$END"
  } > "$file"

  /bin/rm -f "$tmp"
}

[ "$(uname -s)" = "Darwin" ] || {
  echo "mac-awake: macOS only" >&2
  exit 1
}

if [ -n "$SOURCE_ROOT" ] && [ -f "$SOURCE_ROOT/bin/mac-awake" ]; then
  /bin/mkdir -p "$ROOT/bin"
  copy_if_different "$SOURCE_ROOT/bin/mac-awake" "$BIN"
  copy_if_different "$SOURCE_ROOT/install.sh" "$ROOT/install.sh" || true
  copy_if_different "$SOURCE_ROOT/README.md" "$ROOT/README.md" || true
else
  /bin/mkdir -p "$ROOT/bin"
  /usr/bin/curl -fsSL "$RAW_BASE/bin/mac-awake" -o "$BIN"
  /usr/bin/curl -fsSL "$RAW_BASE/install.sh" -o "$ROOT/install.sh"
  /usr/bin/curl -fsSL "$RAW_BASE/README.md" -o "$ROOT/README.md"
fi

/bin/chmod +x "$BIN"
/bin/chmod +x "$ROOT/install.sh" 2>/dev/null || true
/bin/mkdir -p "$LINK_DIR"
/bin/ln -sf "$BIN" "$LINK"

install_block "$HOME/.zshrc"
install_block "$HOME/.bashrc"

# Remove leftovers from the old "mac-sleep-forever" name.
[ -L "$LEGACY_LINK" ] && /bin/rm -f "$LEGACY_LINK"
[ "$LEGACY_ROOT" != "$ROOT" ] && [ -d "$LEGACY_ROOT" ] && /bin/rm -rf "$LEGACY_ROOT"

echo "Installed mac-awake"
echo "Install dir: $ROOT"
echo "Open a new shell, then run: awake-on | awake-off | awake-status"
