#!/bin/bash

zone=$( curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone )
region=${zone%%[a-z]}
iptype="PrivateIpAddress"
as_group_name="as_hlp_jmeter_slave"

### GET List of the Paramters
while (( "$#" )); do
  if [ "$1" == "-p" ]; then
    shift
    iptype="PublicIpAddress"
    continue
  fi
  as_group_name="${1:-$as_group_name}"
  shift
done

instance_ids=$( aws --region ${region} \
                    --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups \
                    --auto-scaling-group-names ${as_group_name} )

aws --region ${region} --output text  \
    --query "Reservations[*].Instances[*].${iptype}" ec2 describe-instances \
    --instance-ids ${instance_ids} | tr "\n" ","|  sed "s/\t/,/g" | sed "s/,$//"

