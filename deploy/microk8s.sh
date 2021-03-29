#!/bin/bash

NAME="cnd-config-practices"
DIR=$(dirname $0)

echo "Cleaning up any previous deployment"
kubectl delete -f deploy/educates

# Pre-reqs for microk8s addons:
    # microk8s enable dns
    # microk8s enable ingress
    # microk8s enable rbac
    # microk8s enable registry
    # microk8s enable storage

echo "Installing/updating educates"
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