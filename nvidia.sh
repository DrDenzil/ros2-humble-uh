#!/bin/bash
set -euo pipefail

if [[ "${1:-}" != "--inside-terminal" ]] && [[ ! -t 0 ]] && [[ -n "${DISPLAY:-}" ]]; then
  for term in x-terminal-emulator gnome-terminal konsole xfce4-terminal xterm; do
    if command -v "$term" >/dev/null 2>&1; then
      case "$term" in
        x-terminal-emulator|gnome-terminal|xfce4-terminal)
          exec "$term" -e bash -lc '"$0" --inside-terminal'
          ;;
        konsole)
          exec "$term" -e bash -lc '"$0" --inside-terminal'
          ;;
        xterm)
          exec "$term" -e bash -lc '"$0" --inside-terminal'
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

IMAGE="ghcr.io/drdenzil/ros2-humble-uh:nvidia"
CONTAINER_NAME="ros2-humble-nvidia"

DOCKER_ARGS=(
  --rm -it
  --name "$CONTAINER_NAME"
  --gpus all
  --user=ros
  --network=host
  --ipc=host
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw
  --env DISPLAY
  -v /dev:/dev
  --device-cgroup-rule='c *:* rmw'
)

if [[ -n "${XAUTHORITY:-}" && -f "${XAUTHORITY}" ]]; then
  DOCKER_ARGS+=(
    --env XAUTHORITY=/tmp/.docker.xauth
    -v "${XAUTHORITY}:/tmp/.docker.xauth:ro"
  )
fi

exec docker run "${DOCKER_ARGS[@]}" "$IMAGE"
