#!/bin/bash
set -euo pipefail

GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$GAME_DIR/patch_debug.log"

{
  echo "=== Proton Darktide Patcher at $(date) ==="
  echo "Game directory: $GAME_DIR"

  # Run patch
  if [ -f "$GAME_DIR/toggle_darktide_mods.sh" ]; then
    bash "$GAME_DIR/toggle_darktide_mods.sh" 2>&1
    PATCH_EXIT=$?
    echo "Patch exit code: $PATCH_EXIT"
  else
    echo "ERROR: toggle_darktide_mods.sh not found"
    exit 1
  fi

  echo "Patch complete at $(date)"

} >> "$LOG_FILE" 2>&1

# Exit cleanly so Proton can launch the game
exit 0
