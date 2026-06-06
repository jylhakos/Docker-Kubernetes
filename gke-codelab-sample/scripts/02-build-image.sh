#!/bin/bash

# Docker Image Build and Push Script
# Builds Docker image and pushes to Google Container Registry

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
IMAGE_NAME="${IMAGE_NAME:-gke-demo-app}"
IMAGE_TAG="${IMAGE_TAG:-v1}"
REGION="${GCP_REGION:-us-central1}"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Docker Image Build Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Image Name: $IMAGE_NAME"
echo "  Image Tag: $IMAGE_TAG"
echo "  Full Image: gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"
echo ""

# Set the project
gcloud config set project "$PROJECT_ID"

# Option 1: Build locally and push
echo -e "${GREEN}Building Docker image locally...${NC}"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" ..

echo -e "${GREEN}Tagging image for GCR...${NC}"
docker tag "$IMAGE_NAME:$IMAGE_TAG" "gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"

echo -e "${GREEN}Configuring Docker to use gcloud as credential helper...${NC}"
gcloud auth configure-docker

echo -e "${GREEN}Pushing image to Google Container Registry...${NC}"
docker push "gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Image built and pushed successfully!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}Image URL:${NC} gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"
echo ""
echo -e "${YELLOW}Alternative: Build with Cloud Build${NC}"
echo "Run the following command to build using Cloud Build:"
echo "  gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .."
echo ""
echo -e "${YELLOW}Next step:${NC}"
echo "  Deploy the application: ./scripts/03-deploy-app.sh"
echo ""
