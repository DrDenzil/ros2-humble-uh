##############################################
# ROS 2 Humble + TIAGo + Gazebo/RViz images
# Targets:
#   - nvidia : NVIDIA/CUDA runtime path
#   - mesa   : Intel/AMD Mesa/DRI runtime path
##############################################

ARG UBUNTU_VERSION=22.04
ARG ROS_DISTRO=humble
ARG NVIDIA_BASE=nvidia/cuda:13.0.1-cudnn-runtime-ubuntu22.04
ARG GPU_FLAVOR=nvidia

###########################################
# Base images
###########################################
FROM ${NVIDIA_BASE} AS base-nvidia
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  tzdata \
  curl \
  gnupg2 \
  lsb-release \
  sudo \
  software-properties-common \
  wget \
  libglvnd0 \
  libgl1 \
  libglx0 \
  libegl1 \
  libxext6 \
  libx11-6 \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && add-apt-repository -y universe \
  && add-apt-repository -y multiverse \
  && curl -L -s -o /tmp/ros2-apt-source.deb https://github.com/ros-infrastructure/ros-apt-source/releases/download/1.1.0/ros2-apt-source_1.1.0.$(lsb_release -cs)_all.deb \
  && apt-get install -y /tmp/ros2-apt-source.deb \
  && rm -f /tmp/ros2-apt-source.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-${ROS_DISTRO}-ros-base \
  python3-argcomplete \
  python3-rosdep \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM=1
ENV DEBIAN_FRONTEND=

COPY ./ros_entrypoint.sh /
RUN chmod 0755 /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

FROM ubuntu:${UBUNTU_VERSION} AS base-mesa
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  tzdata \
  curl \
  gnupg2 \
  lsb-release \
  sudo \
  software-properties-common \
  wget \
  libgl1 \
  libgl1-mesa-dri \
  libglx-mesa0 \
  libegl1 \
  mesa-utils \
  libxext6 \
  libx11-6 \
  libxrender1 \
  libxrandr2 \
  libxfixes3 \
  libxi6 \
  libxinerama1 \
  libxcursor1 \
  libsm6 \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && add-apt-repository -y universe \
  && add-apt-repository -y multiverse \
  && curl -L -s -o /tmp/ros2-apt-source.deb https://github.com/ros-infrastructure/ros-apt-source/releases/download/1.1.0/ros2-apt-source_1.1.0.$(lsb_release -cs)_all.deb \
  && apt-get install -y /tmp/ros2-apt-source.deb \
  && rm -f /tmp/ros2-apt-source.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-${ROS_DISTRO}-ros-base \
  python3-argcomplete \
  python3-rosdep \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV QT_X11_NO_MITSHM=1
ENV LIBGL_ALWAYS_SOFTWARE=0
ENV DEBIAN_FRONTEND=

COPY ./ros_entrypoint.sh /
RUN chmod 0755 /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

###########################################
# Shared dev/full/gazebo stages
###########################################
FROM base-${GPU_FLAVOR} AS dev
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  openssh-client \
  python3-argcomplete \
  python3-pip \
  ros-dev-tools \
  ros-${ROS_DISTRO}-ament-* \
  vim \
  && rm -rf /var/lib/apt/lists/*

RUN rosdep init || echo "rosdep already initialized"

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if getent passwd ubuntu > /dev/null 2>&1; then \
      userdel -r ubuntu || true; \
    fi \
    && if getent group ${USER_GID} > /dev/null 2>&1; then groupdel "$(getent group ${USER_GID} | cut -d: -f1)" || true; fi \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]; then source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash; fi" >> /home/$USERNAME/.bashrc

ENV DEBIAN_FRONTEND=
ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1

FROM dev AS full
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-${ROS_DISTRO}-desktop \
  && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=

FROM full AS gazebo-common
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
RUN wget -qO /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg https://packages.osrfoundation.org/gazebo.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] https://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
     > /etc/apt/sources.list.d/gazebo-stable.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     ros-${ROS_DISTRO}-ros-gz \
     ros-${ROS_DISTRO}-gazebo-ros-pkgs \
     ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
     python3-vcstool \
  && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-lc"]
USER ros
WORKDIR /home/ros
RUN mkdir -p /home/ros/tiago_public_ws/src \
  && cd /home/ros/tiago_public_ws \
  && vcs import src --input https://raw.githubusercontent.com/pal-robotics/tiago_tutorials/humble-devel/tiago_public.repos

USER root
RUN apt-get update \
 && rosdep update \
 && rosdep install --rosdistro ${ROS_DISTRO} --from-paths /home/ros/tiago_public_ws/src -y --ignore-src \
 && rm -rf /var/lib/apt/lists/*

USER ros
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  && cd /home/ros/tiago_public_ws \
  && colcon build --symlink-install \
  && echo "source /home/ros/tiago_public_ws/install/setup.bash" >> /home/ros/.bashrc

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV DEBIAN_FRONTEND=

FROM gazebo-common AS nvidia
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute

FROM gazebo-common AS mesa
USER ros
ENV MESA_LOADER_DRIVER_OVERRIDE=
ENV LIBGL_ALWAYS_INDIRECT=0
