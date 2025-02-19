#!/bin/bash

set -e

#####
#
# create custom ocr-pipeline image
#
# $1 => basis container image as name:tag, i.e. my-custom-tesseract:1.0.0
# $2 => create image in format name:tag, i.e. my-pipeline:3.0.0
#
# please note:
#   every traineddata-file in directory ./model will be copied!
#
BASE_IMAGE=${1/:*/}
BASE_IMAGE_TAG=${1/*:/}
IMAGE=${2/:*/}
IMAGE_TAG=${2/*:/}

#
# clear eventually existing image
# 
# remove container image or note absence
docker image rm --force "${IMAGE}:${IMAGE_TAG}" || echo "[WARN] no image ${IMAGE}:${IMAGE_TAG} existing ... "

# go to project root dir for full build context
#cd ../..

# re-build container from scratch (no caches)
docker build --no-cache \
    --network=host \
    --build-arg BASE_IMAGE="${BASE_IMAGE}" \
    --build-arg BASE_IMAGE_TAG="${BASE_IMAGE_TAG}" \
    -t "${IMAGE}:${IMAGE_TAG}" \
    -f container/ocr-pipeline/Dockerfile .
