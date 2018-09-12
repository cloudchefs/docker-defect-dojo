#!/usr/bin/env bash

set -e

docker build \
    -t cloudchefs/defect-dojo:1.3.0
    --build-arg VERSION="1.3.0" .