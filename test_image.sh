#!/bin/bash

IMAGE_NAME="ubuntu-impi:test"

# Build the Docker image
docker build -t $IMAGE_NAME .

# Run a container with --rm and start bash
docker run --rm -it $IMAGE_NAME bash