#!/bin/bash

docker build -f dockerfiles/backend-base.dockerfile -t wsbackend-base:latest .
docker build -f dockerfiles/api.dockerfile -t wsbackend-api:latest .
docker build -f dockerfiles/tasknode.dockerfile -t wsbackend-tasknode:latest .
docker build -f dockerfiles/frontend-base.dockerfile -t wsfrontend-base:latest .
