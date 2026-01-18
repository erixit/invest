#!/bin/bash

# Check if a module name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <module_name>"
  echo "Example: $0 adminui"
  exit 1
fi

MODULE_NAME=$1

# Configuration
CONTAINER_NAME="invest_$MODULE_NAME"
SOURCE_JAR="/home/pi/development/repos/invest_microservices/adminapi/target/adminapi-1.0.0.jar"
DEPLOY_DIR="/home/pi/development/repos/invest/deploy"

echo "Starting deployment for $CONTAINER_NAME..."

# 1. Stop the adminapi container
echo "Stopping container: $CONTAINER_NAME"
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    docker stop "$CONTAINER_NAME"
else
    echo "Container $CONTAINER_NAME is not running."
fi

# 2. Copy the JAR file
if [ -f "$SOURCE_JAR" ]; then
    echo "Copying JAR file to $DEPLOY_DIR..."
    # Create directory if it doesn't exist
    mkdir -p "$DEPLOY_DIR"
    cp "$SOURCE_JAR" "$DEPLOY_DIR"
    echo "Copy successful."
else
    echo "Error: Source JAR not found at $SOURCE_JAR"
    exit 1
fi

# 3. Start the container
echo "Starting container: $MODULE_NAME"
docker compose up -d "$MODULE_NAME"

echo "Deployment complete."

