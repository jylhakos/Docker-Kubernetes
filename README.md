# Docker-Kubernetes

Docker and Kubernetes infrastructure repository featuring multi-cloud deployments (Google GKE, Amazon EKS, Azure AKS), GitOps workflows with FluxCD, and production-ready application configurations.

## Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Docker Setup](#docker-setup)
- [Kubernetes Setup](#kubernetes-setup)
- [Google Kubernetes Engine (GKE)](#google-kubernetes-engine-gke)
- [GitOps with FluxCD](#gitops-with-fluxcd)
- [Scaling Applications](#scaling-applications)
- [Cloud Build Integration](#cloud-build-integration)
- [Docker Compose](#docker-compose)
- [Best Practices](#best-practices)
- [References](#references)

## Overview

This repository demonstrates modern DevOps practices for containerized applications across multiple environments:

- **Containerization**: Docker-based microservices architecture
- **Orchestration**: Kubernetes deployment configurations
- **Cloud Platforms**: Google Cloud Platform (GKE), AWS, Azure
- **GitOps**: Automated deployment workflows using FluxCD
- **CI/CD**: Integration with GitHub Actions and Cloud Build
- **Monitoring**: Grafana dashboards for NATS messaging system
- **Database**: PostgreSQL with persistent volume claims

## Folder Structure

```
📦 Docker-Kubernetes/
├── 📄 README.md
├── 📁 ga-gke-3.03/                    # GKE GitHub Actions workflow (v3.03)
│   ├── 📄 kustomization.yaml
│   ├── 📁 manifests/
│   │   ├── 📄 deployment-backend.yaml
│   │   ├── 📄 deployment-frontend.yaml
│   │   ├── 📄 ingress.yaml
│   │   ├── 📄 service-backend.yaml
│   │   └── 📄 service-finder.yaml
│   ├── 📁 todo-backend-db/            # Backend API with database
│   │   ├── 📄 Dockerfile
│   │   ├── 📄 index.js
│   │   ├── 📄 package.json
│   │   ├── 📄 script-cron
│   │   └── 📄 script.sh
│   ├── 📁 todo-finder/                # Service discovery component
│   │   ├── 📄 Dockerfile
│   │   ├── 📄 index.js
│   │   └── 📄 package.json
│   └── 📁 todo-response-db/           # Response handler service
│       ├── 📄 Dockerfile
│       ├── 📄 index.js
│       ├── 📄 package.json
│       └── 📁 services/
│
├── 📁 ga-gke-3.04/                    # GKE GitHub Actions workflow (v3.04)
│   ├── 📄 kustomization.yaml
│   ├── 📁 kustomization/              # Kustomize overlays
│   │   ├── 📁 backend/
│   │   └── 📁 frontend/
│   ├── 📁 manifests/
│   │   ├── 📄 deployment-backend.yaml
│   │   ├── 📄 deployment-frontend.yaml
│   │   ├── 📄 ingress-backend.yaml
│   │   ├── 📄 ingress-frontend.yaml
│   │   ├── 📄 persistentvolume.yaml
│   │   ├── 📄 persistentvolumeclaim.yaml
│   │   ├── 📄 postgresql.yaml
│   │   └── 📄 service-*.yaml
│   └── 📁 [application services]
│
├── 📁 kube-cluster-4-0-8/             # Kubernetes cluster v4.0.8
│   ├── 📁 flux-system/                # FluxCD GitOps configuration
│   │   ├── 📄 gotk-components.yaml    # GitOps Toolkit components
│   │   ├── 📄 gotk-sync.yaml          # Sync configuration
│   │   └── 📄 kustomization.yaml
│   ├── 📁 manifests/
│   │   ├── 📁 backend/
│   │   ├── 📁 db/
│   │   ├── 📁 github/
│   │   └── 📁 volume/
│   └── 📁 todo-backend-db/
│
├── 📁 kube-cluster-dwk/               # DevOps with Kubernetes cluster
│   ├── 📁 app/
│   │   ├── 📄 app.go                  # Go application
│   │   ├── 📄 Dockerfile
│   │   └── 📄 go.mod
│   ├── 📁 flux-system/                # FluxCD configuration
│   └── 📁 manifests/
│       ├── 📄 deployment.yaml
│       ├── 📄 example-gitops-app.yaml
│       └── 📄 kustomization.yaml
│
└── 📁 kube-cluster-todos/             # Todo application cluster
    ├── 📁 broadcaster/                # NATS message broadcaster
    │   ├── 📄 Dockerfile
    │   ├── 📄 index.js
    │   ├── 📄 package.json
    │   └── 📁 services/
    ├── 📁 dashboard/                  # Monitoring dashboards
    │   └── 📄 grafana-nats-dash.json
    ├── 📁 flux-system/                # FluxCD GitOps
    └── 📁 manifests/
        ├── 📁 backend/
        ├── 📁 broadcaster/
        ├── 📁 db/
        ├── 📁 frontend/
        ├── 📁 github/
        ├── 📁 monitor/                # Grafana monitoring
        └── 📁 volume/                 # Persistent volumes
```

## Technology Stack

### Core Technologies

#### Docker
- **Alpine Linux** base images for minimal container size
- **Multi-stage builds** for optimized production images
- **Health checks** for container orchestration
- **.dockerignore** files for build optimization

#### Kubernetes
- **Deployments**: Stateless application management
- **StatefulSets**: Stateful applications (databases)
- **Services**: Service discovery and load balancing (ClusterIP, NodePort, LoadBalancer)
- **Ingress**: HTTP(S) routing and load balancing
- **ConfigMaps**: Non-sensitive configuration data
- **Secrets**: Sensitive configuration data
- **PersistentVolumes (PV)**: Storage abstraction
- **PersistentVolumeClaims (PVC)**: Storage requests

#### Kustomize
- **Base configurations**: Shared manifests
- **Overlays**: Environment-specific customizations
- **Patches**: Strategic merge and JSON patches
- **Resource management**: Cross-cutting fields

### Application Technologies

#### Backend Services (Node.js)
- **Express.js**: Web framework for RESTful APIs
- **Sequelize**: ORM for PostgreSQL
- **CORS**: Cross-origin resource sharing
- **dotenv**: Environment variable management
- **NATS**: Message broker for event-driven architecture

#### Frontend Technologies
- **Node.js** runtime
- **Static file serving** via Express
- **REST API consumption**

#### Database
- **PostgreSQL**: Relational database
- **Persistent storage**: Volume mounts
- **Connection pooling**: Via Sequelize

#### Programming Languages
- **JavaScript/Node.js**: Microservices architecture
- **Go (Golang)**: High-performance services (kube-cluster-dwk)
- **Shell scripting**: Automation and cron jobs

### GitOps & CI/CD

#### FluxCD
- **GitOps Toolkit (gotk)**: Core controllers
- **Kustomization Controller**: Manifest reconciliation
- **Source Controller**: Git repository management
- **Notification Controller**: Event handling
- **Image Automation**: Container image updates

Reference: [GitOps-style continuous delivery](https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build)

#### GitHub Actions
- **Automated deployments** to GKE
- **Docker image builds** and pushes
- **Service account authentication** via OIDC
- **Workflow triggers**: Push, pull request, schedule

### Monitoring & Observability

#### Grafana
- **NATS dashboard**: Message broker metrics
- **Custom dashboards**: Application-specific metrics
- **Data sources**: Prometheus integration

## Prerequisites

### Required Tools

1. **Docker Desktop** or Docker Engine
   - Version 20.10+
   - Docker Compose v2.0+

2. **kubectl** - Kubernetes command-line tool
   - Installation: [Install kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   kubectl version --client
   ```

3. **Google Cloud SDK** (for GKE deployments)
   - Download: [Google Cloud SDK](https://docs.cloud.google.com/appengine/downloads)
   ```bash
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

4. **k3s** (for local Kubernetes testing)
   - Quick start: [k3s Quick-Start Guide](https://docs.k3s.io/quick-start)
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

### Cloud Platform Setup

#### Google Cloud Platform

1. **Enable Required APIs**:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   ```
   - [Kubernetes Engine API](https://console.cloud.google.com/apis/library/container.googleapis.com)

2. **Create Service Account** (for GitHub Actions):
   ```bash
   gcloud iam service-accounts create github-actions \
       --display-name="GitHub Actions Service Account"
   
   gcloud iam service-accounts list
   
   gcloud iam service-accounts keys create ./private-key.json \
       --iam-account=github-actions@PROJECT_ID.iam.gserviceaccount.com
   
   export GKE_SA_KEY=$(cat private-key.json | base64)
   echo $GKE_SA_KEY
   ```

3. **Set up gcloud CLI**:
   ```bash
   gcloud config set project PROJECT_ID
   gcloud config set compute/region us-central1
   gcloud config set compute/zone us-central1-a
   ```

## Quick Start

### Local Development with Docker

1. **Build Docker image**:
   ```bash
   cd ga-gke-3.03/todo-backend-db
   docker build -t todo-backend:latest .
   ```

2. **Run container locally**:
   ```bash
   docker run -d -p 3002:3002 \
       -e DB_HOST=localhost \
       -e DB_USER=postgres \
       -e DB_PASSWORD=secret \
       todo-backend:latest
   ```

3. **Check container logs**:
   ```bash
   docker logs <container-id>
   ```

### Deploy to Kubernetes (Minikube/k3s)

1. **Start local cluster**:
   ```bash
   # Using k3s
   sudo systemctl start k3s
   
   # Or using Minikube
   minikube start
   ```

2. **Apply Kubernetes manifests**:
   ```bash
   cd ga-gke-3.03
   kubectl apply -k .
   ```

3. **Check deployment status**:
   ```bash
   kubectl get pods
   kubectl get services
   kubectl get ingress
   ```

## Docker Setup

### Building Docker Images

Docker images in this repository use Alpine Linux for minimal size and security:

```dockerfile
FROM node:alpine

WORKDIR /usr/src/app

# Remove old dependencies
RUN rm -rf node_modules package-lock.json

# Install curl for health checks
RUN apk --no-cache add curl

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy application code
COPY . .

EXPOSE 3002

CMD ["npm", "start"]
```

### Best Practices

1. **Use .dockerignore** to exclude unnecessary files
2. **Multi-stage builds** to reduce image size
3. **Non-root user** for security
4. **Health checks** for container orchestration
5. **Specific version tags** instead of `latest`

Reference: [Build and push Docker images with Cloud Build](https://docs.cloud.google.com/build/docs/build-push-docker-image)

## Kubernetes Setup

### Creating a GKE Cluster

```bash
# Create a GKE cluster
gcloud container clusters create my-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --machine-type=n1-standard-2 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10

# Get cluster credentials
gcloud container clusters get-credentials my-cluster \
    --zone=us-central1-a
```

### Deploying Applications

1. **Using kubectl**:
   ```bash
   kubectl apply -f manifests/deployment-backend.yaml
   kubectl apply -f manifests/service-backend.yaml
   kubectl apply -f manifests/ingress.yaml
   ```

2. **Using Kustomize**:
   ```bash
   kubectl apply -k ga-gke-3.04/
   ```

3. **Verify deployment**:
   ```bash
   kubectl get deployments
   kubectl get pods -w
   kubectl logs <pod-name>
   ```

## Google Kubernetes Engine (GKE)

### Cluster Management

**Create a GKE cluster** with optimal configuration:

```bash
gcloud container clusters create production-cluster \
    --region=us-central1 \
    --node-locations=us-central1-a,us-central1-b,us-central1-c \
    --num-nodes=1 \
    --machine-type=e2-standard-4 \
    --disk-size=100 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --enable-autorepair \
    --enable-autoupgrade \
    --maintenance-window-start=2026-01-01T00:00:00Z \
    --maintenance-window-duration=4h
```

### Workload Identity

Configure workload identity for secure GCP service access:

```bash
# Enable Workload Identity on cluster
gcloud container clusters update production-cluster \
    --workload-pool=PROJECT_ID.svc.id.goog

# Create Kubernetes service account
kubectl create serviceaccount k8s-sa -n default

# Bind to GCP service account
gcloud iam service-accounts add-iam-policy-binding \
    gcp-sa@PROJECT_ID.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:PROJECT_ID.svc.id.goog[default/k8s-sa]"

# Annotate K8s service account
kubectl annotate serviceaccount k8s-sa \
    iam.gke.io/gcp-service-account=gcp-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Persistent Storage

```yaml
# PersistentVolume configuration
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  gcePersistentDisk:
    pdName: postgres-disk
    fsType: ext4
```

## GitOps with FluxCD

### FluxCD Installation

```bash
# Install Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Check prerequisites
flux check --pre

# Bootstrap Flux
flux bootstrap github \
    --owner=YOUR_GITHUB_USERNAME \
    --repository=Docker-Kubernetes \
    --path=kube-cluster-todos/flux-system \
    --personal
```

### GitOps Workflow

1. **Commit changes** to Git repository
2. **FluxCD detects** changes automatically
3. **Reconciliation** applies changes to cluster
4. **Health checks** ensure successful deployment

```bash
# Check Flux status
flux get sources git
flux get kustomizations
flux get helmreleases

# Trigger manual reconciliation
flux reconcile kustomization flux-system --with-source
```

### FluxCD Components

- **gotk-components.yaml**: Core Flux controllers
- **gotk-sync.yaml**: Git repository synchronization
- **kustomization.yaml**: Resource management

## Scaling Applications

### Horizontal Pod Autoscaler (HPA)

Automatically scale pods based on CPU/memory utilization:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: todos-backend-db-dep
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

Create HPA via kubectl:

```bash
kubectl autoscale deployment todos-backend-db-dep \
    --cpu-percent=50 \
    --min=2 \
    --max=10

# Check HPA status
kubectl get hpa
kubectl describe hpa todos-backend-db-dep
```

### Vertical Pod Autoscaler (VPA)

Adjust resource requests/limits automatically:

```bash
# Install VPA
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

### Cluster Autoscaler

GKE automatically adds/removes nodes based on demand:

```bash
gcloud container clusters update production-cluster \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --zone=us-central1-a
```

Reference: [Scaling applications on GKE](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/scaling-apps)

## Cloud Build Integration

### Build Docker Images with Cloud Build

1. **Create Artifact Registry repository**:
   ```bash
   gcloud artifacts repositories create docker-repo \
       --repository-format=docker \
       --location=us-central1 \
       --description="Docker repository"
   ```

2. **Build and push image**:
   ```bash
   gcloud builds submit --region=us-central1 \
       --tag us-central1-docker.pkg.dev/PROJECT_ID/docker-repo/backend:v1.0
   ```

3. **Using cloudbuild.yaml**:
   ```yaml
   steps:
   - name: 'gcr.io/cloud-builders/docker'
     args: ['build', '-t', 'us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/backend:$SHORT_SHA', '.']
   - name: 'gcr.io/cloud-builders/docker'
     args: ['push', 'us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/backend:$SHORT_SHA']
   - name: 'gcr.io/cloud-builders/gke-deploy'
     args:
     - run
     - --filename=manifests/
     - --image=us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/backend:$SHORT_SHA
     - --location=us-central1-a
     - --cluster=production-cluster
   images:
   - 'us-central1-docker.pkg.dev/$PROJECT_ID/docker-repo/backend:$SHORT_SHA'
   ```

Reference: [Build and push Docker images](https://docs.cloud.google.com/build/docs/build-push-docker-image)

## Docker Compose

### Local Multi-Container Development

Docker Compose simplifies running multi-container applications locally:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: todos
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

  backend:
    build: ./todo-backend-db
    ports:
      - "3002:3002"
    environment:
      DB_HOST: postgres
      DB_USER: admin
      DB_PASSWORD: secret
      DB_NAME: todos
    depends_on:
      - postgres

  frontend:
    build: ./todo-response-db
    ports:
      - "3001:3001"
    environment:
      BACKEND_URL: http://backend:3002
    depends_on:
      - backend

  finder:
    build: ./todo-finder
    ports:
      - "3003:3003"
    environment:
      BACKEND_URL: http://backend:3002
    depends_on:
      - backend

volumes:
  postgres-data:
```

Run the application stack:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Remove volumes
docker-compose down -v
```

### Deploy to Cloud Run with Compose

Google Cloud Run now supports deploying Docker Compose applications directly:

```bash
# Deploy compose.yaml to Cloud Run (Private Preview)
gcloud run compose up

# Check service status
gcloud run services list
```

Reference: [Cloud Run and Docker Compose](https://cloud.google.com/blog/products/serverless/cloud-run-and-docker-collaboration)

Reference: [Docker Compose documentation](https://docs.docker.com/compose/)

## Best Practices

### Docker

1. **Use Alpine base images** for smaller container sizes
2. **Implement health checks** in Dockerfiles
3. **Use multi-stage builds** to optimize image layers
4. **Scan images for vulnerabilities** with Docker Scout or Trivy
5. **Tag images with semantic versions**, not `latest`
6. **Use .dockerignore** to exclude unnecessary files

### Kubernetes

1. **Set resource requests and limits** for all containers
2. **Use namespaces** to organize resources
3. **Implement readiness and liveness probes**
4. **Use ConfigMaps and Secrets** for configuration
5. **Enable RBAC** for access control
6. **Use Network Policies** for pod-to-pod communication
7. **Implement Pod Security Standards**

### GitOps

1. **Keep Git as single source of truth**
2. **Use separate repositories** for application code and manifests
3. **Implement branch protection** rules
4. **Review changes via pull requests**
5. **Use Kustomize overlays** for environment-specific configs
6. **Monitor Flux reconciliation** status

### Security

1. **Never commit secrets** to Git
2. **Use Workload Identity** for GCP service access
3. **Scan container images** for vulnerabilities
4. **Implement Network Policies**
5. **Enable Pod Security Admission**
6. **Use private GKE clusters** for production
7. **Rotate credentials** regularly

## References

### Google Cloud Platform

- [Scaling applications on GKE](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/scaling-apps)
- [Download and install Google Cloud SDK](https://docs.cloud.google.com/appengine/downloads)
- [Kubernetes Engine API](https://console.cloud.google.com/apis/library/container.googleapis.com)
- [Build and push Docker images with Cloud Build](https://docs.cloud.google.com/build/docs/build-push-docker-image)
- [Cloud Run - Fully managed platform](https://cloud.google.com/run)
- [Cloud Run and Docker Compose collaboration](https://cloud.google.com/blog/products/serverless/cloud-run-and-docker-collaboration)

### Kubernetes

- [Install and Set Up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [k3s Quick-Start Guide](https://docs.k3s.io/quick-start)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Docker

- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### GitOps

- [FluxCD Documentation](https://fluxcd.io/docs/)
- [GitOps-style continuous delivery with Cloud Build](https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build)

### Tutorials

- [Deploy, scale, and update your website with GKE - Google Codelab](https://codelabs.developers.google.com/codelabs/cloud-deploy-website-on-gke)

## Folder Summaries

### ga-gke-3.03 & ga-gke-3.04

**Purpose**: GitHub Actions workflows for automated deployment to Google Kubernetes Engine.

**Technologies**:
- Node.js microservices (Express, Sequelize)
- PostgreSQL database
- Kustomize for manifest management
- GitHub Actions for CI/CD
- Docker containerization

**Key Features**:
- Automated GKE deployments via GitHub Actions
- Service account authentication using OIDC
- Persistent volume claims for database storage
- Ingress configuration for external access
- Kustomize overlays for environment customization (v3.04)

### kube-cluster-4-0-8

**Purpose**: Production Kubernetes cluster with FluxCD GitOps automation.

**Technologies**:
- FluxCD (GitOps Toolkit)
- Kustomize
- Node.js backend services
- PostgreSQL database
- Kubernetes manifests

**Key Features**:
- Automated GitOps deployments
- Flux reconciliation every 1 minute
- Manifest organization by component (backend, db, volume)
- GitHub integration for automatic syncing

### kube-cluster-dwk

**Purpose**: DevOps with Kubernetes cluster demonstrating Go application deployment.

**Technologies**:
- Go (Golang) applications
- FluxCD for GitOps
- Kustomize
- Lightweight container images

**Key Features**:
- Go-based microservices
- UUID generation service
- FluxCD automated deployments
- Example GitOps configurations

### kube-cluster-todos

**Purpose**: Full-stack todo application with event-driven architecture and monitoring.

**Technologies**:
- Node.js microservices (Express)
- NATS message broker
- PostgreSQL database
- Grafana monitoring
- FluxCD GitOps

**Key Features**:
- Event-driven architecture with NATS
- Broadcaster service for real-time updates
- Grafana dashboards for NATS metrics
- Complete microservices architecture (backend, frontend, broadcaster)
- Persistent storage for database and monitoring data

---

**License**: MIT

**Contributors**: Juha Jylhäkoski

**Last Updated**: 2026-06-06
