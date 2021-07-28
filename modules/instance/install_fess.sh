#!/bin/bash

# change timezone
timedatectl set-timezone Asia/Tokyo

# install docker
amazon-linux-extras install -y docker
systemctl enable docker
systemctl start docker

# change parameter for Elasticsearch
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -q -w vm.max_map_count=262144

# start fess
yum install -y git
git clone https://github.com/inayuky/docker-fess.git
cd docker-fess/compose
docker compose -f docker-compose.yml -f docker-compose.standalone.yml up -d