#!/bin/bash

# GKE Cluster Creation Script
# Based on Google Cloud's "Deploy, scale, and update your website with GKE" codelab

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
CLUSTER_NAME="${CLUSTER_NAME:-gke-demo-cluster}"
REGION="${GCP_REGION:-us-central1}"
ZONE="${GCP_ZONE:-us-central1-a}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-standard-2}"
NUM_NODES="${NUM_NODES:-3}"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}GKE Cluster Creation Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Region: $REGION"
echo "  Zone: $ZONE"
echo "  Machine Type: $MACHINE_TYPE"
echo "  Number of Nodes: $NUM_NODES"
echo ""

# Prompt for confirmation
read -p "Do you want to proceed with cluster creation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cluster creation cancelled${NC}"
    exit 0
fi

# Set the project
echo -e "${GREEN}Setting GCP project...${NC}"
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo -e "${GREEN}Enabling required APIs...${NC}"
gcloud services enable container.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Create the GKE cluster
echo -e "${GREEN}Creating GKE cluster...${NC}"
gcloud container clusters create "$CLUSTER_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --num-nodes="$NUM_NODES" \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --enable-autorepair \
    --enable-autoupgrade \
    --disk-size=50 \
    --disk-type=pd-standard \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --addons=HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver

# Get credentials for kubectl
echo -e "${GREEN}Getting cluster credentials...${NC}"
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone="$ZONE"

# Verify cluster is running
echo -e "${GREEN}Verifying cluster status...${NC}"
kubectl cluster-info
kubectl get nodes

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Cluster created successfully!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Build and push your Docker image: ./scripts/02-build-image.sh"
echo "  2. Deploy your application: ./scripts/03-deploy-app.sh"
echo "  3. Scale your application: ./scripts/04-scale-app.sh"
echo ""
