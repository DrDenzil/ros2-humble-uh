#!/bin/bash

# Only 1 docker container can be running for this to work
gnome-terminal -- docker exec -it $(docker ps -q) bash
