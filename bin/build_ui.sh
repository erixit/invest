#!/bin/bash

# Check if a module name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <module_name>"
  echo "Example: $0 adminui"
  exit 1
fi

MODULE_NAME=$1
SOURCE_DIR="/home/pi/development/repos/invest_userinterfaces/$MODULE_NAME"
DEPLOY_DIST_DIR="/home/pi/development/repos/invest/deploy/$MODULE_NAME/dist"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found."
  exit 1
fi

# Ensure the output directory exists
mkdir -p "$DEPLOY_DIST_DIR"

# Run the build in a Docker container
docker run --rm \
  -u $(id -u):$(id -g) \
  -v "$SOURCE_DIR":/app \
  -v "$DEPLOY_DIST_DIR":/deploy_dist \
  -w /app \
  node:18-alpine \
  /bin/sh -c "npm install && npx ng build --configuration production --output-path /deploy_dist/$MODULE_NAME"

# Fix permissions for web server access
chmod -R 755 "$DEPLOY_DIST_DIR"