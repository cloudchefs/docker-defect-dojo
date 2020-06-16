#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Please supply a unique id for the release"
    exit 1
fi

release=$1
versions=( "1.6.2" )

for version in "${versions[@]}"
do
    echo $version

    echo Build defect dojo image
    docker build \
        -t cloudchefs/defect-dojo:$version-$release \
        --build-arg VERSION="$version" dojo

    echo Build nginx image
    docker build \
        -t cloudchefs/defect-dojo-nginx:$version-$release \
        --build-arg DOJO_HOST="dojo" \
        --build-arg VERSION="$version" nginx

    echo Build nginx image for fargate
    docker build \
        -t cloudchefs/defect-dojo-fargate-nginx:$version-$release \
        --build-arg DOJO_HOST="localhost" \
        --build-arg VERSION="$version" nginx
done