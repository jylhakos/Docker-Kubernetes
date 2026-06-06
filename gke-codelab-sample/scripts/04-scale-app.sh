#!/bin/bash

# Application Scaling Script
# Demonstrates manual and automatic scaling of the application

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Application Scaling Script${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Menu for scaling options
echo -e "${YELLOW}Select scaling option:${NC}"
echo "  1. Manual scaling (kubectl scale)"
echo "  2. Enable Horizontal Pod Autoscaler (HPA)"
echo "  3. View current scaling status"
echo "  4. Stress test (generate load)"
echo "  5. Exit"
echo ""
read -p "Enter your choice [1-5]: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Manual Scaling${NC}"
        echo -e "${YELLOW}Current replicas:${NC}"
        kubectl get deployment gke-demo-app -o jsonpath='{.spec.replicas}'
        echo ""
        echo ""
        read -p "Enter desired number of replicas: " replicas
        
        echo -e "${GREEN}Scaling deployment to $replicas replicas...${NC}"
        kubectl scale deployment gke-demo-app --replicas=$replicas
        
        echo -e "${GREEN}Waiting for scaling to complete...${NC}"
        kubectl rollout status deployment/gke-demo-app
        
        echo ""
        echo -e "${GREEN}Scaling complete!${NC}"
        kubectl get pods -l app=gke-demo
        ;;
    
    2)
        echo ""
        echo -e "${BLUE}Horizontal Pod Autoscaler (HPA)${NC}"
        echo -e "${GREEN}Creating HPA...${NC}"
        kubectl apply -f ../manifests/hpa.yaml
        
        echo ""
        echo -e "${GREEN}HPA created successfully!${NC}"
        echo -e "${YELLOW}HPA Configuration:${NC}"
        kubectl describe hpa gke-demo-hpa
        
        echo ""
        echo -e "${YELLOW}Note:${NC} The HPA will automatically scale between 2 and 10 replicas"
        echo "based on CPU and memory utilization."
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}Current Scaling Status${NC}"
        
        echo -e "${YELLOW}Deployment:${NC}"
        kubectl get deployment gke-demo-app
        
        echo ""
        echo -e "${YELLOW}Pods:${NC}"
        kubectl get pods -l app=gke-demo
        
        echo ""
        echo -e "${YELLOW}HPA Status:${NC}"
        if kubectl get hpa gke-demo-hpa &> /dev/null; then
            kubectl get hpa gke-demo-hpa
            echo ""
            kubectl describe hpa gke-demo-hpa
        else
            echo "HPA not configured"
        fi
        
        echo ""
        echo -e "${YELLOW}Service:${NC}"
        kubectl get service gke-demo-service
        ;;
    
    4)
        echo ""
        echo -e "${BLUE}Stress Test${NC}"
        
        # Get the external IP
        EXTERNAL_IP=$(kubectl get service gke-demo-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        
        if [ -z "$EXTERNAL_IP" ]; then
            echo -e "${RED}Error: Could not get external IP${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Generating load on: http://$EXTERNAL_IP${NC}"
        echo "This will send 1000 requests with 10 concurrent connections"
        echo ""
        read -p "Press Enter to start the stress test..."
        
        if command -v ab &> /dev/null; then
            ab -n 1000 -c 10 "http://$EXTERNAL_IP/"
        elif command -v hey &> /dev/null; then
            hey -n 1000 -c 10 "http://$EXTERNAL_IP/"
        else
            echo -e "${YELLOW}Neither 'ab' nor 'hey' is installed${NC}"
            echo "Install one of them to run stress tests:"
            echo "  - ApacheBench (ab): sudo apt-get install apache2-utils"
            echo "  - hey: go install github.com/rakyll/hey@latest"
            echo ""
            echo "Alternative: Use curl in a loop"
            read -p "Press Enter to run 100 curl requests..."
            for i in {1..100}; do
                curl -s "http://$EXTERNAL_IP/" > /dev/null
                echo -n "."
            done
            echo ""
        fi
        
        echo ""
        echo -e "${GREEN}Stress test complete!${NC}"
        echo "Check HPA status to see if pods were scaled:"
        echo "  kubectl get hpa gke-demo-hpa"
        echo "  kubectl get pods -l app=gke-demo"
        ;;
    
    5)
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
        ;;
    
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Operation completed!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
