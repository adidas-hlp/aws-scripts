#/bin/bash

# master
docker rm master
docker pull confirmed/jmeter-master

export IFS=","
for slave in $( get-slaves-ip.sh )
do
  # Slave
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l ubuntu $slave 'docker stop slav && docker rm slave  && docker pull confirmed/jmeter-slave &&
  docker run --restart=always -v /input-data:/input-data -w /input-data -dit  \
    -e AWSINSTANCEIP=\$( ip addr show dev eth0 | awk  '/inet / {print $2}' | cut -d "/" -f 1) \
    -p 1099:1099 -p 60000:60000 --name slave confirmed/jmeter-slave'
done
unset IFS
