mkdir -p data
cd ./data
unzip ../*.zip
count=$( find . -type f -iname "*.jmx" | wc -l )

echo "Setting permissons on input dir"
sudo chown -R jenkins. /input-data/

if [ $count -eq 1 ]; then
  echo "all fine"  
  jmx=$( find . -type f -iname "*.jmx" )  
  jmxfile=$( basename $jmx )
else
  echo "error to much jmx files"  
  exit 1
fi

find . -type f -exec cp -f {} /input-data \;

export IFS=","
for slave in $( get-slaves-ip.sh )
do
   ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${slave} "rm -rf /input-data/*"
   scp -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /input-data/* ubuntu@${slave}:/input-data/
done
unset IFS

TESTSCRIPT=$jmxfile
SERVERIP=$( ip addr show dev eth0 | awk  '/inet / {print $2}' | cut -d "/" -f 1)
SLAVEIPS=$( /usr/local/bin/get-slaves-ip.sh )

if [ "x${REPORTDIR}" = "x" ]; then
  REPORTDIR=$( mktemp -d -p /logs)
else
  REPORTDIR=$(echo ${REPORTDIR} |  sed "s/[ -\/?]/_/g" )
  REPORTDIR=/logs/${REPORTDIR}_$(date +%Y%m%d_%H%M)
  if [ -d ${REPORTDIR} ]; then
    echo "ERROR: ${REPORTDIR} exists already"
    exit 1
  else
    mkdir -p ${REPORTDIR}
  fi
fi

LOGFILE=${REPORTDIR}.log
JTLFILE=${REPORTDIR}.jtl

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

docker run --rm  --name master -v /tmp/:/tmp/ -v /input-data:/input-data -v /logs/:/logs --rm -p 60000:60000 --name master confirmed/jmeter-master   /var/lib/apache-jmeter/bin/jmeter -n -t /input-data/${TESTSCRIPT} -l ${JTLFILE} -j ${LOGFILE} -e -o ${REPORTDIR} -Djava.rmi.server.hostname=${SERVERIP} -Dclient.rmi.localport=60000 -R${SLAVEIPS}

sudo chmod -R 755 ${REPORTDIR}
