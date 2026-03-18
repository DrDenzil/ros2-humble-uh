# ROS 2 Humble + TIAGo + Gazebo/RViz Docker Images

This repository provides Docker images for running a ROS 2 Humble environment on **Ubuntu 22.04** with:

- **ROS 2 Humble**
- **Gazebo / ros_gz integration**
- **RViz** (via `ros-humble-desktop`)
- **PAL Robotics TIAGo public tutorials workspace**
- **CycloneDDS** as the selected RMW implementation

It is designed for local Linux use where you want a ready-to-run robotics development and simulation environment with either:

- **NVIDIA GPU acceleration**
- **Mesa / DRI rendering for Intel iGPU or AMD GPU systems**

## What it is

This repo builds two related Docker images from a shared Dockerfile:

- `ros2-humble:nvidia`
- `ros2-humble:mesa`

Both images provide the same ROS/TIAGo/Gazebo/RViz feature set. The difference is the GPU/runtime path:

- **`nvidia`** is for machines using NVIDIA GPUs and the NVIDIA container runtime
- **`mesa`** is for machines using Intel integrated graphics or AMD GPUs via Mesa and `/dev/dri`

## What it supports

### Common features in both images

Both images include:

- Ubuntu 22.04 base
- ROS 2 Humble
- `ros-humble-desktop`
- `ros-humble-ros-gz`
- `ros-humble-gazebo-ros-pkgs`
- `ros-humble-rmw-cyclonedds-cpp`
- `python3-vcstool`
- TIAGo public workspace import from PAL Robotics
- dependency installation with `rosdep`
- TIAGo workspace build with `colcon`
- ROS + TIAGo overlay sourced automatically by the entrypoint

### GPU/runtime variants

#### `ros2-humble:nvidia`

Use this on:

- Linux machines with NVIDIA GPUs
- systems with NVIDIA Container Toolkit installed
- environments where you want `--gpus all`

#### `ros2-humble:mesa`

Use this on:

- Linux machines with Intel iGPU
- Linux machines with AMD GPUs
- systems using Mesa/DRI
- local desktops where `/dev/dri` is available

## How it works

The Dockerfile is structured as:

1. **GPU-specific base**
   - NVIDIA base from CUDA Ubuntu 22.04
   - Mesa base from Ubuntu 22.04
2. **Shared development stage**
   - build tools
   - ROS dev tooling
   - non-root `ros` user
3. **Shared desktop/full stage**
   - installs `ros-humble-desktop`
4. **Shared Gazebo/TIAGo stage**
   - installs Gazebo/ros_gz packages
   - imports TIAGo public repos
   - installs dependencies with `rosdep`
   - builds the workspace with `colcon`
5. **Final runtime targets**
   - `nvidia`
   - `mesa`

At runtime, `ros_entrypoint.sh` automatically sources:

- `/opt/ros/humble/setup.bash`
- `/home/ros/tiago_public_ws/install/setup.bash` (if present)

So when the container starts, the ROS environment and TIAGo overlay are ready to use.

## Repository files

- `Dockerfile` — builds both image variants
- `nvidia.sh` — local-use launcher for the NVIDIA image
- `mesa.sh` — local-use launcher for the Mesa image
- `new_terminal.sh` — open an extra shell in a running container
- `ros_entrypoint.sh` — sources ROS and TIAGo overlays at startup

## Build images

Build the NVIDIA image:

```bash
docker build --build-arg GPU_FLAVOR=nvidia --target nvidia -t ros2-humble:nvidia .
```

Build the Mesa image:

```bash
docker build --build-arg GPU_FLAVOR=mesa --target mesa -t ros2-humble:mesa .
```

## How to use it

### NVIDIA systems

Run:

```bash
./nvidia.sh
```

This launches the NVIDIA image with:

- `--gpus all`
- host networking
- host IPC
- X11 socket mount
- `DISPLAY` passed through
- `/dev` mounted for permissive local use

### Intel / AMD / Mesa systems

Run:

```bash
./mesa.sh
```

This launches the Mesa image with:

- `/dev/dri` passthrough
- host networking
- host IPC
- X11 socket mount
- `DISPLAY` passed through
- `/dev` mounted for permissive local use

## Open another shell in a running container

By default, `new_terminal.sh` opens a shell in the NVIDIA container:

```bash
./new_terminal.sh
```

To open a shell in the Mesa container:

```bash
./new_terminal.sh ros2-humble-mesa
```

To open a shell in the NVIDIA container explicitly:

```bash
./new_terminal.sh ros2-humble-nvidia
```

## Notes about permissions and security

The launcher scripts are intentionally permissive because this repository is aimed at **local workstation use** rather than locked-down multi-tenant environments.

That means they use broad options like:

- host networking
- host IPC
- `/dev` passthrough
- broad device cgroup access

This is convenient for local robotics and simulation work, but it is **not a hardened container security model**.

## Notes about GUI support

The current launchers are primarily oriented around **X11** GUI forwarding via:

- `/tmp/.X11-unix`
- `DISPLAY`

For many Linux desktop setups, that is enough for RViz and Gazebo.

If you need Wayland-specific support later, that can be added as a follow-up.

## Tested status

At the time of writing, both images have been:

- built successfully
- smoke-tested for container startup
- verified to run as the `ros` user
- verified to expose ROS 2 Humble
- verified to include the TIAGo overlay
- verified to include Gazebo / RViz related packages

The Mesa image has also been tested for a permissive local runtime path using `/dev/dri`.

## Summary

If you have:

- **NVIDIA GPU** → use `ros2-humble:nvidia` via `./nvidia.sh`
- **Intel or AMD GPU** → use `ros2-humble:mesa` via `./mesa.sh`

Both provide the same ROS 2 Humble + TIAGo + Gazebo + RViz environment on Ubuntu 22.04.
