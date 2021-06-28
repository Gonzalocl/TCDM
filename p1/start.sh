#!/bin/bash

# sudo systemctl start docker.service
docker container start namenode datanode{1..4}
