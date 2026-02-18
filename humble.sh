docker run -it --user=ros --network=host --ipc=host -v /tmp/.X11-unix:/temp/.X11-unix:rw --env=DISPLAY -v /dev:/dev --device-cgroup-rule='c *:* rmw' ros2-humble:gazebo
