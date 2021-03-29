#!/bin/bash

export DEFAULT_CLUSTER_NAME="CHANGEME"
export CLUSTER_NAME="${1:-$DEFAULT_CLUSTER_NAME}"
DIR=$(dirname $0)

echo "===== Cleaning up any old clusters"
kind delete cluster --name "${CLUSTER_NAME}" > /dev/null 2>&1 || true

echo "===== Creating cluster"
kind create cluster --name "${CLUSTER_NAME}" --config ${DIR}/kind-config.yaml

echo "===== Installing Ingress Controller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
sleep 20 # TODO - find a better way to determine when the resources are defined so wait command doesn't fail
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=-1s