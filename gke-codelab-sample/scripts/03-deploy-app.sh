#!/bin/bash

# Application Deployment Script
# Deploys the application to GKE cluster

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
CLUSTER_NAME="${CLUSTER_NAME:-gke-demo-cluster}"
ZONE="${GCP_ZONE:-us-central1-a}"

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Application Deployment Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Image: gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"
echo ""

# Get cluster credentials
echo -e "${GREEN}Getting cluster credentials...${NC}"
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone="$ZONE"

# Update deployment manifest with actual project ID
echo -e "${GREEN}Updating deployment manifest...${NC}"
sed "s/PROJECT_ID/$PROJECT_ID/g" ../manifests/deployment.yaml > /tmp/deployment-updated.yaml
sed -i "s/:v1/:$IMAGE_TAG/g" /tmp/deployment-updated.yaml

# Deploy the application
echo -e "${GREEN}Deploying application to GKE...${NC}"
kubectl apply -f /tmp/deployment-updated.yaml

# Deploy the service
echo -e "${GREEN}Creating LoadBalancer service...${NC}"
kubectl apply -f ../manifests/service.yaml

# Wait for deployment to be ready
echo -e "${GREEN}Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/gke-demo-app

# Get the LoadBalancer IP
echo -e "${GREEN}Waiting for LoadBalancer IP assignment...${NC}"
echo "This may take a few minutes..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    EXTERNAL_IP=$(kubectl get service gke-demo-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    [ -z "$EXTERNAL_IP" ] && sleep 5
done

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}Application Details:${NC}"
echo "  External IP: http://$EXTERNAL_IP"
echo "  Health Check: http://$EXTERNAL_IP/healthz"
echo ""

# Display pod information
echo -e "${YELLOW}Running Pods:${NC}"
kubectl get pods -l app=gke-demo

echo ""
echo -e "${YELLOW}Service Information:${NC}"
kubectl get service gke-demo-service

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Access the application: http://$EXTERNAL_IP"
echo "  2. Scale the application: ./scripts/04-scale-app.sh"
echo "  3. Perform rolling update: ./scripts/05-rolling-update.sh"
echo ""
