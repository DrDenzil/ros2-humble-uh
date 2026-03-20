#!/bin/bash
set -euo pipefail

if [[ "${1:-}" != "--inside-terminal" ]] && [[ ! -t 0 ]] && [[ -n "${DISPLAY:-}" ]]; then
  for term in x-terminal-emulator gnome-terminal konsole xfce4-terminal xterm; do
    if command -v "$term" >/dev/null 2>&1; then
      case "$term" in
        x-terminal-emulator|gnome-terminal|xfce4-terminal)
          exec "$term" -e bash -lc '"$0" --inside-terminal "${1:-ros2-humble-nvidia}"'
          ;;
        konsole)
          exec "$term" -e bash -lc '"$0" --inside-terminal "${1:-ros2-humble-nvidia}"'
          ;;
        xterm)
          exec "$term" -e bash -lc '"$0" --inside-terminal "${1:-ros2-humble-nvidia}"'
          ;;
      esac
    fi
  done
  echo "Could not find a terminal emulator. Run this script from a terminal instead." >&2
  exit 1
fi

if [[ "${1:-}" == "--inside-terminal" ]]; then
  shift
fi

CONTAINER_NAME="${1:-ros2-humble-nvidia}"

exec docker exec -it "$CONTAINER_NAME" bash
