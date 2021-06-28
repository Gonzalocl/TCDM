#!/bin/bash

# sudo systemctl start docker.service
docker container start namenode datanode1 datanode2 datanode3 datanode5
#docker container run -ti --name timelineserver --network=hadoop-cluster --hostname timelineserver --cpus=1 --memory=3072m --expose 10200 -p 8188:8188 hadoop-base /bin/bash
#su - hdadmin
#yarn --daemon start timelineserver
