# ROS 2 Humble Container for UH Students

A simple way to run a ready-made ROS 2 Humble environment for TIAGo work.

The container images are already published on GHCR, so most students should **pull and run** rather than build locally.

---

## 1. Pull the image

Choose the image that matches your system.

### NVIDIA systems
Use this if your machine has an NVIDIA GPU and working NVIDIA Container Toolkit support.

```bash
docker pull ghcr.io/drdenzil/ros2-humble-uh:nvidia
```

### Intel / AMD systems
Use this for most laptops and desktops using Intel or AMD graphics.

```bash
docker pull ghcr.io/drdenzil/ros2-humble-uh:mesa
```

---

## 2. Run it on your system

### Option A: NVIDIA GPU

```bash
./nvidia.sh
```

This starts the NVIDIA version of the container.

### Option B: Intel / AMD graphics

```bash
./mesa.sh
```

This starts the Mesa version of the container.

### Open another shell in the running container

```bash
./new_terminal.sh
```

If needed, you can also give the container name manually:

```bash
./new_terminal.sh ros2-humble-nvidia
./new_terminal.sh ros2-humble-mesa
```

---

## Which system should I use?

Use:

- **`nvidia.sh`** on Linux systems with an **NVIDIA GPU**
- **`mesa.sh`** on Linux systems with **Intel or AMD graphics**

These launcher scripts are intended for **Linux hosts with Docker installed**.

If you are unsure which one to use:

- NVIDIA graphics card → try `nvidia.sh`
- Intel / AMD graphics → use `mesa.sh`

---

## 3. Supporting files

### `nvidia.sh`
Starts the NVIDIA-based container from:

```text
ghcr.io/drdenzil/ros2-humble-uh:nvidia
```

### `mesa.sh`
Starts the Intel/AMD (Mesa) container from:

```text
ghcr.io/drdenzil/ros2-humble-uh:mesa
```

### `new_terminal.sh`
Opens a new terminal inside a running container.

### `ros_entrypoint.sh`
Sets up the ROS environment automatically when the container starts.

### `Dockerfile`
Used to build the images locally. Most students do **not** need this.

---

## What you get in the container

The container is set up with:

- ROS 2 Humble
- TIAGo tutorial workspace
- Gazebo / ROS simulation support
- A ready-to-use shell environment

---

## Advanced use

For local builds and extra technical details, see:

- [ADVANCED.md](ADVANCED.md)
