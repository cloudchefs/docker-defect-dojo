#!/usr/bin/env bash

set -e

versions=( "1.3.0" "1.5.2" )

for version in "${versions[@]}"
do
    echo $version

    docker push cloudchefs/defect-dojo:$version
    docker push cloudchefs/defect-dojo-nginx:$version
    docker push cloudchefs/defect-dojo-fargate-nginx:$version
done