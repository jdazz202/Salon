#!/bin/bash

# === CONFIG ===
PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="static-site-cluster"
REGION="us-central1"
ZONE="us-central1-a"
IMAGE_NAME="static-site"
IMAGE_TAG="v1"
DEPLOYMENT_NAME="static-site"
SERVICE_NAME="static-site-service"
# ==============

gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com containerregistry.googleapis.com

# Create GKE cluster
gcloud container clusters create $CLUSTER_NAME --zone $ZONE --num-nodes=1
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

# Build and push Docker image
docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG

# Deploy to Kubernetes
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $DEPLOYMENT_NAME
  template:
    metadata:
      labels:
        app: $DEPLOYMENT_NAME
    spec:
      containers:
      - name: $DEPLOYMENT_NAME
        image: gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
        ports:
        - containerPort: 80
EOF

# Create LoadBalancer service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
spec:
  type: LoadBalancer
  selector:
    app: $DEPLOYMENT_NAME
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

kubectl get service $SERVICE_NAME --watch
