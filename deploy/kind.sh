#!/bin/bash

NAME="cnd-deploy-practices"
DIR=$(dirname $0)
if [ $1 == "stop" ]
then
    kind delete cluster --name "${NAME}"
    exit
fi

echo "Cleaning up any old clusters"
kind delete cluster --name "${NAME}" > /dev/null 2>&1 || true

echo "Creating cluster"
kind create cluster --name "${NAME}" --config $DIR/kind-config.yaml

echo "Loading image into cluster"
kind load docker-image --name "${NAME}" ${NAME}:latest
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
sleep 10
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "Installing educates"
kubectl apply -k "github.com/eduk8s/eduk8s?ref=develop"
IPADDRESS="$(ifconfig | grep 'broadcast\|Bcast' | awk -F ' ' {'print $2'} | head -n 1 | sed -e 's/addr://g')"
if [ -z "$IPADDRESS" ]
then
    IPADDRESS="$(hostname -I |grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' |head -n 1)" # workaround if ifconfig is not installed on recent versions of Debian
fi
kubectl set env deployment/eduk8s-operator -n eduk8s INGRESS_DOMAIN="${IPADDRESS}.nip.io"

echo "Installing the workshop and training portal"
kubectl apply -f $DIR/educates
sleep 5
kubectl get trainingportals.training.eduk8s.io
