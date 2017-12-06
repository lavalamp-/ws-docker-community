#!/bin/bash

SLEEP_TIME=20

docker-compose up -d
echo "Now sleeping for $SLEEP_TIME seconds to allow Web Sight to bootstrap..."
sleep $SLEEP_TIME
echo "Now invoking 'migrate_and_test.sh' script on API node..."
API="$(docker ps | grep ws | grep api | awk '{print $1}')"
echo "API ID is $API..."
docker exec -it $API scripts/migrate_and_test.sh
echo "Tests completed! Shutting things down..."
docker-compose stop
docker-compose rm -f
