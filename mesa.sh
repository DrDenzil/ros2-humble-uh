#!/bin/bash
set -euo pipefail

IMAGE="ros2-humble:mesa"
CONTAINER_NAME="ros2-humble-mesa"

exec docker run --rm -it \
  --name "$CONTAINER_NAME" \
  --user=ros \
  --network=host \
  --ipc=host \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --env DISPLAY \
  -v /dev:/dev \
  --device /dev/dri:/dev/dri \
  --device-cgroup-rule='c *:* rmw' \
  "$IMAGE"
