# Advanced Notes

This file is for staff, maintainers, or students who need more than the basic quick-start in `README.md`.

## Build the images locally

Build the NVIDIA image:

```bash
docker build --target nvidia -t ros2-humble:nvidia .
```

Build the Mesa image:

```bash
docker build --build-arg GPU_FLAVOR=mesa --target mesa -t ros2-humble:mesa .
```

## Published images

The current published images are:

```text
ghcr.io/drdenzil/ros2-humble-uh:nvidia
ghcr.io/drdenzil/ros2-humble-uh:mesa
```

## What the launcher scripts do

### `nvidia.sh`
- runs the NVIDIA image
- uses `--gpus all`
- uses host networking and IPC
- mounts `/tmp/.X11-unix`
- passes `DISPLAY`
- mounts `XAUTHORITY` when available
- currently mounts `/dev`

### `mesa.sh`
- runs the Mesa image
- uses host networking and IPC
- mounts `/tmp/.X11-unix`
- passes `DISPLAY`
- mounts `XAUTHORITY` when available
- exposes `/dev/dri`

### `new_terminal.sh`
Runs:

```bash
docker exec -it <container-name> bash
```

## Notes on GUI support

The launchers are configured for X11 forwarding by passing:

- `/tmp/.X11-unix`
- `DISPLAY`
- `XAUTHORITY` when present

GUI applications may still depend on the host X11 permissions and Docker setup.

## Notes on the image contents

The Dockerfile builds a ROS 2 Humble environment with:

- ROS 2 Humble base packages
- development tools
- desktop packages
- Gazebo / ROS integration
- TIAGo public workspace imported and built

## Suggested maintenance tasks

If this repo changes later, keep these in sync:

- image names in `README.md`
- image names in `nvidia.sh` and `mesa.sh`
- any publish instructions you use externally
