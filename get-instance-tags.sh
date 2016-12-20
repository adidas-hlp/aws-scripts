#!/bin/sh

#if [ -f /usr/bin/yum ]
#then
#  sudo yum install -y aws-cli
#fi

INSTANCE_ID=$( curl --silent http://169.254.169.254/latest/meta-data/instance-id )
REGION=$( curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//' )

aws ec2 describe-tags --region $REGION --filter "Name=resource-id,Values=$INSTANCE_ID" --output=text | 
    sed -r 's/TAGS\t(.*)\t.*\t.*\t(.*)/\1="\2"/'

