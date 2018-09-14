#!/usr/bin/env bash

set -e

versions=( "1.3.0" "1.5.2" )

for version in "${versions[@]}"
do
    echo $version

    echo Build defect dojo image
    docker build \
        -t cloudchefs/defect-dojo:$version \
        --build-arg VERSION="$version" dojo

    echo Build nginx image
    docker build \
        -t cloudchefs/defect-dojo-nginx:$version \
        --build-arg DOJO_HOST="dojo" \
        --build-arg VERSION="$version" nginx

    echo Build nginx image for fargate
    docker build \
        -t cloudchefs/defect-dojo-fargate-nginx:$version \
        --build-arg DOJO_HOST="localhost" \
        --build-arg VERSION="$version" nginx
done