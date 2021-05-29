#!/bin/bash

# install docker
amazon-linux-extras install -y docker
systemctl enable docker
systemctl start docker

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# change parameter for Elasticsearch
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -q -w vm.max_map_count=262144

# start fess
yum install -y git
git clone https://github.com/inayuky/docker-fess.git
cd docker-fess/compose
docker-compose -f docker-compose.yml -f docker-compose.standalone.yml up -d