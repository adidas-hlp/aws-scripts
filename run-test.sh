#!/bin/bash

TESTSCRIPT=$1
SERVERIP=$( ip addr show dev eth0 | awk  '/inet / {print $2}' | cut -d "/" -f 1)
SLAVEIPS=$( /usr/local/bin/get-slaves-ip.sh )
REPORTDIR=$( mktemp -d -p /logs)
LOGFILE=${REPORTDIR}.log

# distribute input-data
export IFS=","
for slave in ${SLAVEIPS}
do
  echo -en "Processing $slave"
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /input-data/* ${slave}:/input-data/ >/dev/null 2>&1
  echo "."
done
unset IFS


count=$( docker ps -a | wc -l )
if [ $count -gt 1 ]
then
  docker rm master
  if [ $? -ne 0 ]
  then
  	echo "maybe some tests are still active? Can't remove the container"
  	exit 1
  fi
fi

docker run --rm -it --name master -v /input-data:/input-data -v /logs/:/logs --rm -p 60000:60000 --name master confirmed/jmeter-master \
    /var/lib/apache-jmeter/bin/jmeter -n -t /input-data/${TESTSCRIPT} -l ${LOGFILE} -e -o ${REPORTDIR} \
    -Djava.rmi.server.hostname=${SERVERIP} -Dclient.rmi.localport=60000 -R${SLAVEIPS} 

chmod -R 755 ${REPORTDIR}
