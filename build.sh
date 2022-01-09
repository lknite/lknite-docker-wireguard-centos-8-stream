#!/bin/bash

# clean up stale images just taking up space
#docker image prune --all --force

# build docker image
docker build .
