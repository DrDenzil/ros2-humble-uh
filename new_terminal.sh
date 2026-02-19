#!/bin/bash

gnome-terminal -- docker exec -it $(docker ps -q) bash
