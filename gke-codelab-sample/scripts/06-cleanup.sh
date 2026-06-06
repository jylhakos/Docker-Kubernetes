#!/bin/bash

# Cleanup Script
# Removes all GKE resources created by this demo

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-gke-demo-cluster}"
ZONE="${GCP_ZONE:-us-central1-a}"

echo -e "${RED}====================================${NC}"
echo -e "${RED}GKE Cleanup Script${NC}"
echo -e "${RED}====================================${NC}"
echo ""

echo -e "${YELLOW}WARNING: This will delete all resources!${NC}"
echo ""
echo -e "${YELLOW}Resources to be deleted:${NC}"
echo "  - Kubernetes deployment: gke-demo-app"
echo "  - Kubernetes service: gke-demo-service"
echo "  - HPA: gke-demo-hpa"
echo "  - GKE cluster: $CLUSTER_NAME"
echo "  - Container images in GCR"
echo ""

read -p "Are you sure you want to delete all resources? (yes/no) " -r
echo
if [[ ! $REPLY == "yes" ]]; then
    echo -e "${YELLOW}Cleanup cancelled${NC}"
    exit 0
fi

# Check if kubectl is available
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}Deleting Kubernetes resources...${NC}"
    
    # Delete HPA
    kubectl delete hpa gke-demo-hpa --ignore-not-found=true
    
    # Delete service
    kubectl delete service gke-demo-service --ignore-not-found=true
    
    # Delete deployment
    kubectl delete deployment gke-demo-app --ignore-not-found=true
    
    echo -e "${GREEN}Kubernetes resources deleted${NC}"
fi

# Delete GKE cluster
echo ""
echo -e "${GREEN}Deleting GKE cluster...${NC}"
echo "This may take a few minutes..."

if command -v gcloud &> /dev/null; then
    gcloud container clusters delete "$CLUSTER_NAME" \
        --zone="$ZONE" \
        --quiet
    
    echo -e "${GREEN}GKE cluster deleted${NC}"
else
    echo -e "${YELLOW}gcloud CLI not found, skipping cluster deletion${NC}"
fi

# Optional: Delete container images
echo ""
read -p "Do you want to delete container images from GCR? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Deleting container images...${NC}"
    
    # List and delete images
    gcloud container images list --repository=gcr.io/$PROJECT_ID | grep gke-demo-app | while read -r image; do
        echo "Deleting $image"
        gcloud container images delete "$image" --quiet --force-delete-tags
    done
    
    echo -e "${GREEN}Container images deleted${NC}"
fi

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Cleanup completed!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

echo -e "${YELLOW}Verify deletion:${NC}"
echo "  gcloud container clusters list"
echo "  gcloud container images list --repository=gcr.io/$PROJECT_ID"
echo ""
