#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Please supply a unique id for the release"
    exit 1
fi

release=$1
versions=( "1.6.2")

for version in "${versions[@]}"
do
    echo $version

    docker push cloudchefs/defect-dojo:$version-$release
    docker push cloudchefs/defect-dojo-nginx:$version-$release
    docker push cloudchefs/defect-dojo-fargate-nginx:$version-$release
done