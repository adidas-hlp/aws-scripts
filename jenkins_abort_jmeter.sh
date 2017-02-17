#!/bin/bash

docker kill master
docker rm master

export IFS=","
for server in $(get-slaves-ip.sh )
do 
  ssh -i /var/lib/jenkins/.ssh/id_rsa ubuntu@$server "docker restart slave"
done

