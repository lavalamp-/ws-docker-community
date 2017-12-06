#!/bin/bash

SLEEP_TIME=20

docker-compose up -d
echo "Now sleeping for $SLEEP_TIME seconds to allow Web Sight to bootstrap..."
sleep $SLEEP_TIME
echo "Now invoking 'check_deployment.sh' script on tasknode..."
TASKNODE="$(docker ps | grep ws | grep tasknode | awk '{print $1}')"
echo "Tasknode ID is $TASKNODE..."
docker exec -it $TASKNODE scripts/check_deployment.sh
echo "Deployment checker completed! Shutting things down..."
docker-compose stop
docker-compose rm -f
