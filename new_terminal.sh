#!/bin/bash
set -euo pipefail

CONTAINER_NAME="${1:-ros2-humble-nvidia}"

exec docker exec -it "$CONTAINER_NAME" bash
