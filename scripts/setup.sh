#!/bin/bash

set -e

docker-compose build --pull
docker-compose up -d postgres
