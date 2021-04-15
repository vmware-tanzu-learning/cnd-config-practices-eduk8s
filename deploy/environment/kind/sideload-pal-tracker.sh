#!/bin/bash

## side load pal-tracker images:
##  sideload-pal-tracker.sh $number_sessions
##      where $number_sessions is the max number of sessions,
##      given each session gets its own registry

pushd `pwd`

function buildimage() {
    cd $1/workshop-files/exercises/pal-tracker/
    ./gradlew clean bootBuildImage
    ./gradlew clean
}

function ingressdomain() {
    IPADDRESS="$(ifconfig | grep 'broadcast\|Bcast' | awk -F ' ' {'print $2'} | head -n 1 | sed -e 's/addr://g')"
    if [ -z "$IPADDRESS" ]
    then
        IPADDRESS="$(hostname -I |grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' |head -n 1)" # workaround if ifconfig is not installed on recent versions of Debian
    fi

    echo "${IPADDRESS}.nip.io"
}

function sideload() {
    for i in $(seq $3 $4); do
        IMAGE=$1$i-registry.$2/pal-tracker:v1
        echo "side loading $IMAGE..."
        docker tag pal-tracker $IMAGE
        kind load docker-image --name cnd-config-practices $IMAGE
    done
}

SCRIPT_DIR="$(cd $(dirname $0); pwd -P)"
PROJECT_DIR=$(dirname $(dirname $(dirname ${SCRIPT_DIR})))
NUMBER_SESSIONS=$1

# buildimage $PROJECT_DIR

INGRESS_DOMAIN=$(ingressdomain)
REGISTRY_HOST_PREFIX="cnd-config-practices-w01-s00"

sideload $REGISTRY_HOST_PREFIX $INGRESS_DOMAIN 1 $NUMBER_SESSIONS

echo $INGRESS_DOMAIN

popd