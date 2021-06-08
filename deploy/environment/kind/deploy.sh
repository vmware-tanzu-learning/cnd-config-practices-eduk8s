#!/bin/bash

export CLUSTER_NAME="educates"
export REGISTRY_NAME="kind-registry"
export CONTOUR_VERSION="1.16"
export WORKSHOP_NAME="${2}"
DIR=$(dirname $0)

start() {
    # create registry container unless it already exists
    reg_port='5000'
    running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
    if [ "${running}" != 'true' ]; then
      docker run \
        -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${REGISTRY_NAME}" registry:2
    fi

    if [ "$(kind get clusters | grep ${CLUSTER_NAME})" == "${CLUSTER_NAME}" ]; then
      echo "===== Using existing educates cluster"
      docker start "${CLUSTER_NAME}-control-plane"
      exit
    fi

    echo "===== Dynamically populating insecure registry exceptions"
    IPADDRESS="$(ifconfig | grep 'broadcast\|Bcast' | awk -F ' ' {'print $2'} | head -n 1 | sed -e 's/addr://g')"
    if [ -z "$IPADDRESS" ]
    then
        IPADDRESS="$(hostname -I |grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' |head -n 1)" # workaround if ifconfig is not installed on recent versions of Debian
    fi
    INSECURE_REGISTRIES=""
    for i in {1..9}
    do
    INSECURE_REGISTRIES+="  [plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"${WORKSHOP_NAME}-w01-s00${i}-registry.${IPADDRESS}.nip.io\"]"
    INSECURE_REGISTRIES+="\n    endpoint = [\"http:\\/\\/${WORKSHOP_NAME}-w01-s00${i}-registry.${IPADDRESS}.nip.io\"]\n"
    done

    sed "s/  #__EXTRA_REGISTRIES__/${INSECURE_REGISTRIES}/g" ${DIR}/kind-config.yaml > ${DIR}/kind-config.yaml.resolved

    echo "===== Creating cluster"
    kind create cluster --name "${CLUSTER_NAME}" --config=$DIR/kind-config.yaml.resolved
    rm ${DIR}/kind-config.yaml.resolved

    # connect the registry to the cluster network
    # (the network may already be connected)
    docker network connect "kind" "${REGISTRY_NAME}" || true

    # Document the local registry
    # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: local-registry-hosting
      namespace: kube-public
    data:
      localRegistryHosting.v1: |
        host: "localhost:${reg_port}"
        help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

    echo "===== Installing Security Policies"
    kubectl apply -f ${DIR}/policy-resources

    echo "===== Installing Ingress Controller"
    kubectl create ns projectcontour
    kubectl apply -f ${DIR}/ingress-resources
    kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/release-${CONTOUR_VERSION}/examples/render/contour.yaml
    kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
    kubectl rollout status deployment/contour -n projectcontour
    kubectl rollout status daemonset/envoy -n projectcontour
}

stop() {
  docker stop "${CLUSTER_NAME}-control-plane"
}

clean() {
  delete
  docker rm -f "${REGISTRY_NAME}"
}

delete() {
  echo "===== Deleting cluster kind cluster \"${CLUSTER_NAME}\""
  kind delete cluster --name "${CLUSTER_NAME}"
}

"$@"