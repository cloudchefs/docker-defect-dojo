#!/usr/bin/env bash

set -e

docker push cloudchefs/defect-dojo:1.3.0
docker push cloudchefs/defect-dojo-nginx:1.3.0
docker push cloudchefs/defect-dojo-fargate-nginx:1.3.0