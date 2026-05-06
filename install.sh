#!/bin/bash
set -euo pipefail

REPO="markokraemer/mac-sleep-forever"
BRANCH="${MAC_SLEEP_FOREVER_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
ROOT="${MAC_SLEEP_FOREVER_HOME:-$HOME/.local/share/mac-sleep-forever}"
BIN="$ROOT/bin/mac-sleep-forever"
LINK_DIR="$HOME/.local/bin"
LINK="$LINK_DIR/mac-sleep-forever"
START="# >>> mac-sleep-forever >>>"
END="# <<< mac-sleep-forever <<<"

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
    /usr/bin/awk -v start="$START" -v end="$END" '
      $0 == start { skip=1; next }
      $0 == end { skip=0; next }
      !skip { print }
    ' "$file" > "$tmp"
  fi

  {
    /bin/cat "$tmp"
    echo
    echo "$START"
    echo "export MAC_SLEEP_FOREVER_HOME=\"$ROOT\""
    echo "alias mac-sleep-forever=\"\$MAC_SLEEP_FOREVER_HOME/bin/mac-sleep-forever\""
    echo "alias awake-on=\"\$MAC_SLEEP_FOREVER_HOME/bin/mac-sleep-forever on\""
    echo "alias awake-off=\"\$MAC_SLEEP_FOREVER_HOME/bin/mac-sleep-forever off\""
    echo "alias awake-status=\"\$MAC_SLEEP_FOREVER_HOME/bin/mac-sleep-forever status\""
    echo "$END"
  } > "$file"

  /bin/rm -f "$tmp"
}

[ "$(uname -s)" = "Darwin" ] || {
  echo "mac-sleep-forever: macOS only" >&2
  exit 1
}

if [ -n "$SOURCE_ROOT" ] && [ -f "$SOURCE_ROOT/bin/mac-sleep-forever" ]; then
  /bin/mkdir -p "$ROOT/bin"
  copy_if_different "$SOURCE_ROOT/bin/mac-sleep-forever" "$BIN"
  copy_if_different "$SOURCE_ROOT/install.sh" "$ROOT/install.sh" || true
  copy_if_different "$SOURCE_ROOT/README.md" "$ROOT/README.md" || true
else
  /bin/mkdir -p "$ROOT/bin"
  /usr/bin/curl -fsSL "$RAW_BASE/bin/mac-sleep-forever" -o "$BIN"
  /usr/bin/curl -fsSL "$RAW_BASE/install.sh" -o "$ROOT/install.sh"
  /usr/bin/curl -fsSL "$RAW_BASE/README.md" -o "$ROOT/README.md"
fi

/bin/chmod +x "$BIN"
/bin/chmod +x "$ROOT/install.sh" 2>/dev/null || true
/bin/mkdir -p "$LINK_DIR"
/bin/ln -sf "$BIN" "$LINK"

install_block "$HOME/.zshrc"
install_block "$HOME/.bashrc"

echo "Installed mac-sleep-forever"
echo "Install dir: $ROOT"
echo "Open a new shell, then run: awake-on | awake-off | awake-status"
