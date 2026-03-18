#!/bin/bash
set -euo pipefail

IMAGE="ros2-humble:nvidia"
CONTAINER_NAME="ros2-humble-nvidia"

exec docker run --rm -it \
  --name "$CONTAINER_NAME" \
  --gpus all \
  --user=ros \
  --network=host \
  --ipc=host \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --env DISPLAY \
  -v /dev:/dev \
  --device-cgroup-rule='c *:* rmw' \
  "$IMAGE"
