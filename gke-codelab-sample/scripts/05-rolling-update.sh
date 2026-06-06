#!/bin/bash

# Rolling Update Script
# Demonstrates zero-downtime rolling updates in Kubernetes

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
IMAGE_NAME="${IMAGE_NAME:-gke-demo-app}"
NEW_TAG="${NEW_TAG:-v2}"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Rolling Update Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}This script will perform a rolling update to version $NEW_TAG${NC}"
echo ""

# Get current version
CURRENT_IMAGE=$(kubectl get deployment gke-demo-app -o jsonpath='{.spec.template.spec.containers[0].image}')
echo -e "${YELLOW}Current image:${NC} $CURRENT_IMAGE"
echo -e "${YELLOW}New image:${NC} gcr.io/$PROJECT_ID/$IMAGE_NAME:$NEW_TAG"
echo ""

read -p "Do you want to proceed with the rolling update? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rolling update cancelled${NC}"
    exit 0
fi

# Step 1: Build new image version (optional)
echo ""
echo -e "${BLUE}Step 1: Build new image (optional)${NC}"
read -p "Do you want to build a new image version? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Building new image version...${NC}"
    
    # Update VERSION in deployment to v2
    export VERSION="2.0.0"
    
    # Build new image
    docker build -t "$IMAGE_NAME:$NEW_TAG" \
        --build-arg VERSION="$VERSION" ..
    
    # Tag and push
    docker tag "$IMAGE_NAME:$NEW_TAG" "gcr.io/$PROJECT_ID/$IMAGE_NAME:$NEW_TAG"
    docker push "gcr.io/$PROJECT_ID/$IMAGE_NAME:$NEW_TAG"
    
    echo -e "${GREEN}New image built and pushed!${NC}"
fi

# Step 2: Update the deployment
echo ""
echo -e "${BLUE}Step 2: Update deployment image${NC}"
echo -e "${GREEN}Updating deployment to new image version...${NC}"
kubectl set image deployment/gke-demo-app \
    gke-demo-container="gcr.io/$PROJECT_ID/$IMAGE_NAME:$NEW_TAG"

# Also update VERSION environment variable
kubectl set env deployment/gke-demo-app VERSION="2.0.0"

# Step 3: Monitor rollout
echo ""
echo -e "${BLUE}Step 3: Monitor rollout progress${NC}"
echo -e "${GREEN}Rolling update in progress...${NC}"
echo ""

# Watch the rollout status
kubectl rollout status deployment/gke-demo-app

# Show rollout history
echo ""
echo -e "${YELLOW}Rollout history:${NC}"
kubectl rollout history deployment/gke-demo-app

# Step 4: Verify the update
echo ""
echo -e "${BLUE}Step 4: Verify the update${NC}"

echo -e "${YELLOW}New pods:${NC}"
kubectl get pods -l app=gke-demo

echo ""
echo -e "${YELLOW}Testing the application...${NC}"
EXTERNAL_IP=$(kubectl get service gke-demo-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n "$EXTERNAL_IP" ]; then
    echo "Sending test request to http://$EXTERNAL_IP"
    curl -s "http://$EXTERNAL_IP" | grep -o "Version [0-9.]*" || echo "Could not determine version"
fi

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Rolling update completed!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

echo -e "${YELLOW}Useful commands:${NC}"
echo "  View rollout status:  kubectl rollout status deployment/gke-demo-app"
echo "  View rollout history: kubectl rollout history deployment/gke-demo-app"
echo "  Rollback to previous: kubectl rollout undo deployment/gke-demo-app"
echo "  Pause rollout:        kubectl rollout pause deployment/gke-demo-app"
echo "  Resume rollout:       kubectl rollout resume deployment/gke-demo-app"
echo ""

echo -e "${BLUE}To rollback the deployment, run:${NC}"
echo "  kubectl rollout undo deployment/gke-demo-app"
echo ""
