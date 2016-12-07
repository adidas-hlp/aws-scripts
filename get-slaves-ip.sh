#!/bin/bash

zone=$( curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone )
region=${zone%%[a-z]}
as_group_name="${1:-as_hlp_jmeter_slave}"

instance_ids=$( aws --region ${region} \
                    --output text --query "AutoScalingGroups[0].Instances[*].InstanceId" autoscaling describe-auto-scaling-groups \
                    --auto-scaling-group-names ${as_group_name} )


aws --region ${region} --output text  \
    --query "Reservations[*].Instances[*].PrivateIpAddress" ec2 describe-instances \
    --instance-ids ${instance_ids} | sed "s/\t/,/"
