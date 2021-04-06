#!/bin/bash

cd ~/exercises/k8s
sed -i "s/REGISTRY_HOST/${REGISTRY_HOST}/g" deployment.yaml
sed -i "s/INGRESS_HOST/${SESSION_NAME}.${INGRESS_DOMAIN}/g" ingress.yaml