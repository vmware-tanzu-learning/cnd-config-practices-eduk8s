#!/bin/bash -e

pushd `pwd`

_script_dir="$(cd $(dirname $0); pwd -P)"
PROJECT_DIR="$(dirname "${_script_dir}")"

# DRIVER can be: hyperkit|virtualbox|kvm2
DRIVER=$1

# container registry subnet in CIDR form -> 192.168.64.0/24
REGISTRY_SUBNET=$2

minikube start --driver=${DRIVER} --insecure-registry=${REGISTRY_SUBNET} --memory=8Gi
minikube addons enable ingress
minikube addons enable ingress-dns
minikube addons enable registry

kubectl apply -k "github.com/eduk8s/eduk8s?ref=master"
kubectl set env deployment/eduk8s-operator -n eduk8s INGRESS_DOMAIN="$(minikube ip).nip.io"

docker run --rm -d -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

cd ${PROJECT_DIR}

kubectl apply -f deploy/educates/

popd