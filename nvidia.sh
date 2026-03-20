#!/bin/bash
set -euo pipefail

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
