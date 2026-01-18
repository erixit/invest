#!/bin/bash

# Ensure the output directory exists
mkdir -p /home/pi/development/repos/invest/deploy/consultui_test/dist

# Run the build in a Docker container
# Note: We mount the parent 'dist' directory to /deploy_dist to avoid the "EACCES: permission denied, rmdir" error
docker run --rm \
  -u $(id -u):$(id -g) \
  -v /home/pi/development/repos/invest_userinterfaces/consultui:/app \
  -v /home/pi/development/repos/invest/deploy/consultui_test/dist:/deploy_dist \
  -w /app \
  node:18-alpine \
  /bin/sh -c "npm install && npx ng build --configuration production --output-path /deploy_dist/consultui"
