#!/bin/bash
set -e

# Log startup
echo "Starting Flask backend container..."

# Configure Docker authentication for Artifact Registry
gcloud auth configure-docker us-docker.pkg.dev

# Pull and run the container
docker run -d \
  --name flask-backend \
  -p ${app_port}:5000 \
  --restart=always \
  ${container_image}

# Verify container is running
docker ps

echo "Container started successfully on port ${app_port}"
