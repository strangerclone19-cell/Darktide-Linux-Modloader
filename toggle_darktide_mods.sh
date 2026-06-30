#!/usr/bin/env bash
# toggle_darktide_mods.sh
# Auto-detect Warhammer 40,000 DARKTIDE installation and run tools/dtkit-patch --toggle on the game's bundle

# Re-exec with bash if the script was started with /bin/sh (dash) so arrays and bash features work.
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  else
    echo "This script requires bash. Please run it with bash or install bash." >&2
    exit 1
  fi
fi

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Starting Darktide patcher from $SCRIPT_DIR..."
cd "$SCRIPT_DIR"

# Behavior:
# - If DTKIT_PATCH is set, use that full path.
# - Else if DARKTIDE_DIR is set (or discovered), use $DARKTIDE_DIR/tools/dtkit-patch.
# - If DARKTIDE_DIR is discovered, toggle the bundle in the game folder ($DARKTIDE_DIR/bundle).
# - Otherwise fall back to toggling ./bundle (script directory).

DTKIT_PATH=""
BUNDLE_PATH="./bundle"  # default when Darktide folder not found

# Allow overrides via environment variables
if [ -n "${DTKIT_PATCH:-}" ]; then
  DTKIT_PATH="$DTKIT_PATCH"
fi

if [ -n "${DARKTIDE_DIR:-}" ] && [ -z "${DTKIT_PATH:-}" ]; then
  maybe="$DARKTIDE_DIR/tools/dtkit-patch"
  if [ -x "$maybe" ]; then
    DTKIT_PATH="$maybe"
    BUNDLE_PATH="$DARKTIDE_DIR/bundle"
  fi
fi

# Candidate Steam 'common' locations to search
CANDIDATES=(
  "$HOME/.steam/steam/steamapps/common"
  "$HOME/.local/share/Steam/steamapps/common"
  "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common"
  "$HOME/.local/share/steam/steamapps/common"
)

# Try to discover Darktide install and its tools/dtkit-patch
if [ -z "${DTKIT_PATH:-}" ]; then
  for base in "${CANDIDATES[@]}"; do
    [ -d "$base" ] || continue
    GAME_DIR="$(find "$base" -maxdepth 1 -type d -iname '*darktide*' -print -quit 2>/dev/null || true)"
    if [ -n "$GAME_DIR" ]; then
      maybe="$GAME_DIR/tools/dtkit-patch"
      if [ -x "$maybe" ]; then
        DTKIT_PATH="$maybe"
        DARKTIDE_DIR="$GAME_DIR"
        BUNDLE_PATH="$DARKTIDE_DIR/bundle"
        echo "Found Darktide game folder at: $GAME_DIR"
        break
      fi
    fi
  done
fi

# If still not found, try to locate an executable named dtkit-patch under the candidate roots
if [ -z "${DTKIT_PATH:-}" ]; then
  for base in "${CANDIDATES[@]}"; do
    [ -d "$base" ] || continue
    dt="$(find "$base" -type f -name 'dtkit-patch' -perm /111 -print -quit 2>/dev/null || true)"
    if [ -n "$dt" ]; then
      DTKIT_PATH="$dt"
      echo "Found dtkit-patch at: $DTKIT_PATH"
      case "$DTKIT_PATH" in
        */common/*/tools/dtkit-patch)
          DARKTIDE_DIR="${DTKIT_PATH%/tools/dtkit-patch}"
          BUNDLE_PATH="$DARKTIDE_DIR/bundle"
          ;;
      esac
      break
    fi
  done
fi

# Last fallback: dtkit-patch in PATH
if [ -z "${DTKIT_PATH:-}" ] && command -v dtkit-patch >/dev/null 2>&1; then
  DTKIT_PATH="$(command -v dtkit-patch)"
  echo "Using dtkit-patch from PATH: $DTKIT_PATH"
fi

if [ -z "${DTKIT_PATH:-}" ]; then
  echo "Error: could not find dtkit-patch (expected inside Darktide/tools/dtkit-patch)."
  echo "Options to fix this:"
  echo "  - Set DARKTIDE_DIR to your Darktide game folder (the folder that contains 'tools'):"
  echo "      export DARKTIDE_DIR=\"/path/to/Warhammer 40,000 DARKTIDE\""
  echo "  - Or set DTKIT_PATCH to the full path of the dtkit-patch executable:"
  echo "      export DTKIT_PATCH=\"/full/path/to/dtkit-patch\""
  echo "  - Or install/move dtkit-patch under your Steam 'common' directory so it can be auto-discovered."
  read -p "Press Enter to continue..."
  exit 1
fi

echo "Using dtkit-patch: $DTKIT_PATH"
echo "Toggling bundle: $BUNDLE_PATH"

"$DTKIT_PATH" --toggle "$BUNDLE_PATH"
RC=$?
if [ $RC -ne 0 ]; then
    echo "Error patching the Darktide bundle database (exit code $RC). See logs."
    read -p "Press Enter to continue..."
    exit $RC
fi

read -p "Patch complete. Press Enter to continue..."
exit 0
