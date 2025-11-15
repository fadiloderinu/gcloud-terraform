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

# Install Docker and gcloud
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin google-cloud-cli

# Start Docker
systemctl start docker
systemctl enable docker

# Add root to docker group so we don't need sudo
usermod -aG docker root
newgrp docker

# Configure Docker authentication for Artifact Registry using gcloud
echo "Configuring Docker authentication for ${REGISTRY_HOST}..."
gcloud auth configure-docker ${REGISTRY_HOST}

# Pull the latest image
echo "Pulling Docker image: ${container_image}"
if docker pull ${container_image}; then
  echo "Successfully pulled image"
else
  echo "Failed to pull image, retrying..."
  sleep 5
  docker pull ${container_image}
fi

# Stop and remove old container if it exists
echo "Stopping old container if it exists..."
docker stop flask-backend 2>/dev/null || true
docker rm flask-backend 2>/dev/null || true

# Run the container
echo "Starting new container..."
docker run -d \
  --name flask-backend \
  -p ${app_port}:5000 \
  --restart=always \
  ${container_image}

if [ $? -eq 0 ]; then
  echo "Container started successfully"
else
  echo "Failed to start container"
  exit 1
fi

# Verify container is running
echo "Container status:"
docker ps

echo "Container started successfully on port ${app_port}"


