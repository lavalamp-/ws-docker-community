#!/bin/bash

SLEEP_TIME=20

docker-compose up -d
echo "Now sleeping for $SLEEP_TIME seconds to allow database to bootstrap..."
sleep $SLEEP_TIME
echo "Now invoking 'initialize_data_stores.sh' script on tasknode..."
TASKNODE="$(docker ps | grep ws | grep tasknode | awk '{print $1}')"
echo "Tasknode ID is $TASKNODE..."
docker exec -it $TASKNODE scripts/initialize_data_stores.sh
echo "Data stores should now be initialized. Shutting things down..."
docker-compose stop
docker-compose rm -f
