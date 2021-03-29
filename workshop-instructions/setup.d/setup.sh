#!/bin/bash

cd ~/exercises/k8s
sed -i "s/REGISTRY_HOST/${REGISTRY_HOST}/g" deployment.yaml