#!/usr/bin/env bash

set -e

# Build defect dojo image
docker build \
    -t cloudchefs/defect-dojo:1.3.0 \
    --build-arg VERSION="1.3.0" dojo

# Build nginx image
docker build \
    -t cloudchefs/defect-dojo-nginx:1.3.0 \
    --build-arg DOJO_HOST="dojo" \
    --build-arg VERSION="1.3.0" nginx

# Build nginx image for fargate
docker build \
    -t cloudchefs/defect-dojo-fargate-nginx:1.3.0 \
    --build-arg DOJO_HOST="localhost" \
    --build-arg VERSION="1.3.0" nginx