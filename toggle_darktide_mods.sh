#!/usr/bin/env bash
# Simple Darktide dtkit-patch toggler for Linux
set -euo pipefail

# Re-exec with bash if started under /bin/sh
if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANDIDATES=(
  "$SCRIPT_DIR"
  "$HOME/.steam/steam/steamapps/common"
  "$HOME/.local/share/Steam/steamapps/common"
  "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common"
  "$HOME/.local/share/steam/steamapps/common"
)

DTKIT_PATH="${DTKIT_PATCH:-}"
BUNDLE_PATH="./bundle"

find_dtkit() {
  # prefer a DTKIT_PATCH override
  if [ -n "$DTKIT_PATH" ] && [ -f "$DTKIT_PATH" ]; then
    return 0
  fi

  for base in "${CANDIDATES[@]}"; do
    [ -d "$base" ] || continue
    # if script lives inside the game dir, check tools next to it
    if [ "$base" = "$SCRIPT_DIR" ]; then
      maybe="$base/tools/dtkit-patch"
      [ -f "$maybe" ] && { DTKIT_PATH="$maybe"; BUNDLE_PATH="$base/bundle"; return 0; }
    fi

    # look for a directory named like darktide directly under base
    game="$(find "$base" -maxdepth 1 -type d -iname '*darktide*' -print -quit 2>/dev/null || true)"
    if [ -n "$game" ]; then
      maybe="$game/tools/dtkit-patch"
      if [ -f "$maybe" ]; then
        DTKIT_PATH="$maybe"
        BUNDLE_PATH="$game/bundle"
        return 0
      fi
    fi
  done

  # last resort: any dtkit-patch under candidates
  for base in "${CANDIDATES[@]}"; do
    [ -d "$base" ] || continue
    dt="$(find "$base" -type f -name 'dtkit-patch' -print -quit 2>/dev/null || true)"
    if [ -n "$dt" ]; then
      DTKIT_PATH="$dt"
      # if path contains /tools/, guess game dir
      case "$DTKIT_PATH" in
        */tools/dtkit-patch) BUNDLE_PATH="${DTKIT_PATH%/tools/dtkit-patch}/bundle";;
      esac
      return 0
    fi
  done

  return 1
}

run_dtkit() {
  # Determine file type
  if [ ! -f "$DTKIT_PATH" ]; then
    echo "dtkit-patch not found at $DTKIT_PATH" >&2
    return 2
  fi

  # If file is executable, run directly
  if [ -x "$DTKIT_PATH" ]; then
    "$DTKIT_PATH" --toggle "$BUNDLE_PATH"
    return $?
  fi

  # Try to make it executable (may fail if filesystem is readonly)
  if chmod +x -- "$DTKIT_PATH" >/dev/null 2>&1; then
    echo "Made dtkit-patch executable and running..."
    "$DTKIT_PATH" --toggle "$BUNDLE_PATH"
    return $?
  fi

  # Inspect type: if it's a script run with bash; if Windows exe, try wine
  type_out="$(file -b -- "$DTKIT_PATH" || true)"
  case "$type_out" in
    *script*|*ASCII*)
      echo "dtkit-patch looks like a script; running with bash..."
      bash "$DTKIT_PATH" --toggle "$BUNDLE_PATH"
      return $?
      ;;
    *PE32*|*MS-DOS*|*Windows*|*.exe*)
      if command -v wine >/dev/null 2>&1; then
        echo "dtkit-patch is a Windows binary; running with wine..."
        wine "$DTKIT_PATH" --toggle "$BUNDLE_PATH"
        return $?
      else
        echo "dtkit-patch appears to be a Windows executable and is not runnable on this system without wine." >&2
        return 3
      fi
      ;;
    *)
      echo "dtkit-patch exists but is not executable and not recognized as a runnable script/binary: $type_out" >&2
      return 4
      ;;
  esac
}

echo "Starting Darktide patcher from $SCRIPT_DIR..."
if ! find_dtkit; then
  echo "Error: could not locate dtkit-patch. Set DTKIT_PATCH or DARKTIDE_DIR to the game folder." >&2
  exit 1
fi

echo "Using dtkit-patch: $DTKIT_PATH"
echo "Toggling bundle: $BUNDLE_PATH"

if ! run_dtkit; then
  echo "Failed to run dtkit-patch." >&2
  exit 1
fi

echo "Patch completed."
exit 0