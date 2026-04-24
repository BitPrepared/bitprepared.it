#!/bin/bash
# Script per creare baseline nel container Docker

docker run --rm \
    --mount type=bind,source="$(pwd)",target=/app \
    --add-host=host.docker.internal:host-gateway \
    -e HOST_IP=host.docker.internal \
    --entrypoint="" \
    bitprepared-visual-regression:latest \
    sh -c 'cd /app/scripts/visual-regression && npm run create-baseline'
