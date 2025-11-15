#!/bin/bash
set -e

# Log startup
echo "Starting Flask backend container..."

# Update system
apt-get update
apt-get install -y ca-certificates curl gnupg

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
systemctl start docker
systemctl enable docker

# Configure Docker authentication for Artifact Registry
gcloud auth configure-docker ${REGISTRY_HOST}

# Pull the latest image
docker pull ${container_image}

# Stop and remove old container if it exists
docker stop flask-backend 2>/dev/null || true
docker rm flask-backend 2>/dev/null || true

# Run the container
docker run -d \
  --name flask-backend \
  -p ${app_port}:5000 \
  --restart=always \
  ${container_image}

# Verify container is running
docker ps

echo "Container started successfully on port ${app_port}"

