#!/bin/bash
set -euo pipefail

IMAGE="ghcr.io/drdenzil/ros2-humble-uh:mesa"
CONTAINER_NAME="ros2-humble-mesa"

DOCKER_ARGS=(
  --rm -it
  --name "$CONTAINER_NAME"
  --user=ros
  --network=host
  --ipc=host
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw
  --env DISPLAY
  --device /dev/dri:/dev/dri
)

if [[ -n "${XAUTHORITY:-}" && -f "${XAUTHORITY}" ]]; then
  DOCKER_ARGS+=(
    --env XAUTHORITY=/tmp/.docker.xauth
    -v "${XAUTHORITY}:/tmp/.docker.xauth:ro"
  )
fi

exec docker run "${DOCKER_ARGS[@]}" "$IMAGE"
