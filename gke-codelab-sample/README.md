# GKE Codelab Sample Application

This sample application demonstrates the concepts from Google Cloud's codelab: [Deploy, scale, and update your website with Google Kubernetes Engine (GKE)](https://codelabs.developers.google.com/codelabs/cloud-deploy-website-on-gke).

## What You'll Learn

- How to create a GKE cluster
- How to create a Docker image
- How to deploy Docker images to Kubernetes
- How to scale an application on Kubernetes
- How to perform a rolling update on Kubernetes

## Application Overview

This is a simple Node.js web application that displays:
- Pod hostname
- Application version
- System information
- Health status

The application includes:
- Health check endpoints for Kubernetes probes
- Metrics endpoint for monitoring
- Graceful shutdown handling
- Non-root user security

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Google Cloud SDK (gcloud)**
   - Install: [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
   - Authenticate: `gcloud auth login`
   - Set project: `gcloud config set project YOUR_PROJECT_ID`

2. **Docker**
   - Install: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)

3. **kubectl**
   - Install: [https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

4. **Google Cloud Project**
   - Create a project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable billing

## Project Structure

```
gke-codelab-sample/
├── server.js                    # Node.js application
├── package.json                 # npm dependencies
├── Dockerfile                   # Multi-stage Docker build
├── .dockerignore               # Docker build exclusions
├── manifests/
│   ├── deployment.yaml         # Kubernetes Deployment
│   ├── service.yaml            # LoadBalancer Service
│   └── hpa.yaml                # Horizontal Pod Autoscaler
├── scripts/
│   ├── 01-create-cluster.sh   # Create GKE cluster
│   ├── 02-build-image.sh      # Build and push Docker image
│   ├── 03-deploy-app.sh       # Deploy to Kubernetes
│   ├── 04-scale-app.sh        # Scale application
│   ├── 05-rolling-update.sh   # Perform rolling update
│   └── 06-cleanup.sh          # Clean up resources
└── README.md                   # This file
```

## Quick Start

### Step 1: Set Environment Variables

```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export GCP_ZONE="us-central1-a"
export CLUSTER_NAME="gke-demo-cluster"
```

### Step 2: Create GKE Cluster

```bash
cd scripts
./01-create-cluster.sh
```

This script will:
- Enable required Google Cloud APIs
- Create a GKE cluster with 3 nodes
- Configure autoscaling (1-10 nodes)
- Enable auto-repair and auto-upgrade
- Get cluster credentials for kubectl

**Time:** ~5-10 minutes

### Step 3: Build and Push Docker Image

```bash
./02-build-image.sh
```

This script will:
- Build the Docker image using multi-stage build
- Tag the image for Google Container Registry
- Push the image to GCR

**Alternative using Cloud Build:**
```bash
cd ..
gcloud builds submit --tag gcr.io/$GCP_PROJECT_ID/gke-demo-app:v1 .
```

### Step 4: Deploy Application

```bash
./03-deploy-app.sh
```

This script will:
- Update deployment manifest with your project ID
- Deploy the application (3 replicas)
- Create a LoadBalancer service
- Wait for external IP assignment
- Display application URL

**Time:** ~2-3 minutes for LoadBalancer IP

### Step 5: Scale Application

```bash
./04-scale-app.sh
```

This interactive script provides options to:
1. **Manual scaling** - Scale to specific number of replicas
2. **Enable HPA** - Automatic scaling based on CPU/memory
3. **View status** - Check current scaling configuration
4. **Stress test** - Generate load to trigger autoscaling

**Example: Manual Scaling**
```bash
# Scale to 5 replicas
kubectl scale deployment gke-demo-app --replicas=5

# Verify scaling
kubectl get pods -l app=gke-demo
```

**Example: Enable Autoscaling**
```bash
# Create HPA
kubectl apply -f manifests/hpa.yaml

# Check HPA status
kubectl get hpa
kubectl describe hpa gke-demo-hpa
```

### Step 6: Perform Rolling Update

```bash
./05-rolling-update.sh
```

This script demonstrates zero-downtime rolling updates:
- Build new version of the application
- Update deployment image
- Monitor rollout progress
- Verify the update

**Manual Rolling Update:**
```bash
# Update to new image version
kubectl set image deployment/gke-demo-app \
    gke-demo-container=gcr.io/$GCP_PROJECT_ID/gke-demo-app:v2

# Update environment variable
kubectl set env deployment/gke-demo-app VERSION="2.0.0"

# Watch rollout
kubectl rollout status deployment/gke-demo-app

# View history
kubectl rollout history deployment/gke-demo-app

# Rollback if needed
kubectl rollout undo deployment/gke-demo-app
```

### Step 7: Cleanup

```bash
./06-cleanup.sh
```

This script removes all created resources:
- Kubernetes deployment, service, and HPA
- GKE cluster
- Container images (optional)

## Manual Commands

### Create GKE Cluster

```bash
gcloud container clusters create gke-demo-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --machine-type=e2-standard-2 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10
```

### Build Docker Image

```bash
# Local build
docker build -t gke-demo-app:v1 .
docker tag gke-demo-app:v1 gcr.io/$GCP_PROJECT_ID/gke-demo-app:v1
docker push gcr.io/$GCP_PROJECT_ID/gke-demo-app:v1

# Cloud Build
gcloud builds submit --tag gcr.io/$GCP_PROJECT_ID/gke-demo-app:v1
```

### Deploy to Kubernetes

```bash
# Get cluster credentials
gcloud container clusters get-credentials gke-demo-cluster --zone=us-central1-a

# Deploy application
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml

# Check status
kubectl get deployments
kubectl get pods
kubectl get services
```

### Scale Application

```bash
# Manual scaling
kubectl scale deployment gke-demo-app --replicas=5

# Autoscaling
kubectl autoscale deployment gke-demo-app --min=2 --max=10 --cpu-percent=70

# Check HPA
kubectl get hpa
```

### Rolling Update

```bash
# Update image
kubectl set image deployment/gke-demo-app \
    gke-demo-container=gcr.io/$GCP_PROJECT_ID/gke-demo-app:v2

# Monitor rollout
kubectl rollout status deployment/gke-demo-app

# Rollback
kubectl rollout undo deployment/gke-demo-app
```

## Kubernetes Resources

### Deployment

The [deployment.yaml](manifests/deployment.yaml) defines:
- 3 replicas for high availability
- Rolling update strategy (maxSurge: 1, maxUnavailable: 0)
- Resource requests and limits
- Liveness and readiness probes
- Security context (non-root user)

### Service

The [service.yaml](manifests/service.yaml) creates:
- LoadBalancer type service
- External IP for public access
- Port mapping (80 → 8080)

### Horizontal Pod Autoscaler

The [hpa.yaml](manifests/hpa.yaml) configures:
- Min replicas: 2
- Max replicas: 10
- Target CPU utilization: 70%
- Target memory utilization: 80%
- Scale-up/down policies

## Monitoring and Debugging

### View Logs

```bash
# All pods
kubectl logs -l app=gke-demo

# Specific pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>
```

### Describe Resources

```bash
kubectl describe deployment gke-demo-app
kubectl describe pod <pod-name>
kubectl describe service gke-demo-service
kubectl describe hpa gke-demo-hpa
```

### Execute Commands in Pod

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

### Port Forward (for local testing)

```bash
kubectl port-forward deployment/gke-demo-app 8080:8080
# Access at http://localhost:8080
```

### Top Commands

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods
```

## Application Endpoints

Once deployed, the application exposes:

- **Main page**: `http://<EXTERNAL-IP>/`
- **Health check**: `http://<EXTERNAL-IP>/healthz`
- **Readiness check**: `http://<EXTERNAL-IP>/readyz`
- **Metrics**: `http://<EXTERNAL-IP>/metrics`

Get the external IP:
```bash
kubectl get service gke-demo-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Cost Management

To minimize costs:

1. **Delete resources when not in use**:
   ```bash
   ./scripts/06-cleanup.sh
   ```

2. **Use smaller machine types**:
   ```bash
   --machine-type=e2-micro  # Cheapest option
   ```

3. **Reduce number of nodes**:
   ```bash
   --num-nodes=1
   ```

4. **Enable cluster autoscaling**:
   - Nodes scale down automatically when not needed

5. **Use preemptible VMs** (for development):
   ```bash
   --preemptible
   ```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -l app=gke-demo

# View pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### LoadBalancer IP Pending

```bash
# Check service status
kubectl describe service gke-demo-service

# Ensure firewall rules allow traffic
gcloud compute firewall-rules list
```

### Image Pull Errors

```bash
# Verify image exists
gcloud container images list --repository=gcr.io/$GCP_PROJECT_ID

# Check service account permissions
gcloud projects get-iam-policy $GCP_PROJECT_ID
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl top nodes
kubectl top pods

# View HPA events
kubectl describe hpa gke-demo-hpa

# Generate load
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- \
    /bin/sh -c "while sleep 0.01; do wget -q -O- http://gke-demo-service; done"
```

## Best Practices Implemented

1. **Multi-stage Docker builds** - Smaller, optimized images
2. **Non-root user** - Enhanced security
3. **Health checks** - Kubernetes probes for reliability
4. **Resource limits** - Prevent resource exhaustion
5. **Rolling updates** - Zero-downtime deployments
6. **Autoscaling** - Automatic scaling based on demand
7. **LoadBalancer service** - External access with load balancing
8. **Graceful shutdown** - Proper signal handling

## Additional Resources

- [Google Cloud GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Original Codelab](https://codelabs.developers.google.com/codelabs/cloud-deploy-website-on-gke)

## Related Links

- [Scaling apps on GKE](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/scaling-apps)
- [Build and push Docker images](https://docs.cloud.google.com/build/docs/build-push-docker-image)
- [Cloud Run and Docker Compose](https://cloud.google.com/blog/products/serverless/cloud-run-and-docker-collaboration)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [k3s Quick-Start](https://docs.k3s.io/quick-start)

## License

MIT

## Support

For issues and questions:
- Check the [troubleshooting section](#troubleshooting)
- Review [GKE documentation](https://cloud.google.com/kubernetes-engine/docs)
- Visit [Stack Overflow](https://stackoverflow.com/questions/tagged/google-kubernetes-engine)
