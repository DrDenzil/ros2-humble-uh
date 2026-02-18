#!/usr/bin/env bash
set -e

# Always source ROS 2
if [ -f "/opt/ros/humble/setup.bash" ]; then
  source "/opt/ros/humble/setup.bash"
fi

# Source TIAGo overlay if present
if [ -f "/home/ros/tiago_public_ws/install/setup.bash" ]; then
  source "/home/ros/tiago_public_ws/install/setup.bash"
fi

exec "$@"

