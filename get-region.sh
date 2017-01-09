#!/bin/sh

curl --silent http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'

