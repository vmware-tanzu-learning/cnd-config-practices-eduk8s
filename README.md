# README

Welcome to the Developer Cloud Native Deployment practices workshop.

This page is for maintainers,
not for students.

Before getting into the workshop series,
it is necessary to outline the structure of this project.

## Scripts

The `scripts` directory contains convenience scripts to help the
developer/maintainer with local development builds.


See the
[Authoring / Maintaining](#authoring--maintaining) section for
recommended maintainer workflows.

## Workshop

The workshop contains one or more lessons and associated lab exercises
the fit together,
and can be executed by a user within 2 hours.

Each workshop is built as a separate container,
and contains a "bootstrap" script that will set the state of the user's
development environment before starting the workshop session.

The workshop contains the instruction content for the user:

### Overview

The [Intro](./workshop/content/intro.md) file is the overview page -
it is the "home page" of the workshop.

### Exercises

The bulk of the workshop is to guide the user through 1 or more lab
exercises.

Each exercise will add, update or remove code or configuration
artifacts,
and result in one of the various configurations of a cloud native app
running in a Kubernetes cluster to demonstrate a development or
operator concept.

## Building

### Development environment

Minikube and Kind are supported for Educates.
This workshop uses the *container registry per session* feature,
which requires use of `docker` container runtime to support
insecure Docker registries.

If you are running MacOS or Linux,
you can run the convenience script `scripts/deploy-minikube.sh`.

Or you can install minikube and the Educates Operator manually
as follows:

1.  Set up a minikube environment as follows:

    ```bash
    minikube start --driver=hyperkit|virtualbox|kvm2 --insecure-registry=192.168.64.0/24 --memory=8Gi
    minikube addons enable ingress
    minikube addons enable ingress-dns
    minikube addons enable registry
    ```

    *select the appropriate hypervisor for your development platform.*
        *For mac recommend `--driver=hyperkit`*
        *For Windows recommend `--driver=virtualbox`*
        *For Windows10 Pro recommend `--driver=hyperv`*
        *For Linux recommend `--driver=kvm2`*

    *select the appropriate local subnet according to your minikube*
    *installation.*
    *Verify the subnet after minikube starts by gettings its ip address:*
        *`minikube ip`*

    See [this article](https://medium.com/@JockDaRock/minikube-on-windows-10-with-hyper-v-6ef0f4dc158c) for HyperV setup.
    You can skip creating the new virtual adapter as it is not needed.

1.  Set up the
    [*Educates Operator*](https://docs.edukates.io/en/latest/getting-started/installing-operator.html):

    ```bash
    kubectl apply -k "github.com/eduk8s/eduk8s?ref=master"
    kubectl set env deployment/eduk8s-operator -n eduk8s INGRESS_DOMAIN="$(minikube ip).nip.io"
    ```

1.  Set up a proxy for the minikube hosted container registry:

    On Mac or Linux:

    ```bash
    # proxy localhost:5000 to said minikube registry..
    # from https://minikube.sigs.k8s.io/docs/handbook/registry/#docker-on-macos
    docker run --rm -d -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
    ```

    On Windows:

    ```bash
    # proxy localhost:5000 to said minikube registry..
    # from https://minikube.sigs.k8s.io/docs/handbook/registry/#docker-on-windows
    kubectl port-forward --namespace kube-system <name of the registry vm> 5000:5000
    docker run --rm -d -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
    ```

1.  Build the workshop docker images.
    Each will generate and contain all the static source,
    as well as packaging a `code-server` editor.
    It will also generate the codebase git repo from exploded source
    files,
    and put in the `~/exercises` workspace folder.

    `./scripts/build-dev-images.sh`

1.  Deploy the workshop and associated training portal:

    ```bash
    kubectl apply -f resources/
    ```

1.  Verify the training portal and associated URL:

    ```bash
    kubectl get trainingportals
    ```

    You should see similar to following output:

    ```no-highlight
    ╰─$ kubectl get trainingportals
    NAME                      URL                                                     ADMINUSERNAME   ADMINPASSWORD
    cnd-config-practices   http://cnd-config-practices-ui.192.168.39.6.nip.io   eduk8s          sH1VoxEiWGNhaIQgt2Fjwvpe0mldC9u
    ```

If you are updating the training portal or one of the various workshop
configurations,
you will need to apply the updates:

1.  Workshop configuration:

    ```bash
    kubectl apply -f resources/workshop.yaml
    ```

1.  Training portal configuration:

    ```bash
    kubectl apply -f resources/training-portal.yaml
    ```

## Authoring / Maintaining

Authoring is the process of updating the workshop content,
code,
or workshop configuration.

### Flow

There are a few scenarios common with authoring:

1. Lab code/configuration updates
1. Lab instruction updates
1. Slide narrative updates
1. Training portal or workshop configuraton changes
1. A combination of the 4

The first two can be accomplished by the following steps:

1.  Make the appropriate content changes,
    either in the markdown files,
    or code.

1.  Test locally by rebuilding and tagging:

    ```bash
    docker build -t devonk8s-deploy .
    docker tag devonk8s-deploy localhost:5000/devonk8s-deploy
    ```

1.  Publish locally (minikube):

    `docker push localhost:5000/devonk8s-deploy`

    Or (Kind):

    `kind load docker-image localhost:5000/devonk8s-deploy:latest --name "cnd-config-practices"`

1.  Re-deployment of the workshop and training portal resources are not
    required.

    You can merely terminate existing worksessions from the UI,
    or explicitly identify and terminate via the command line:

    Identify the worker sessions:

    ```bash
    kubectl get workshopsessions
    ```

    example output:

    ```no-highlight
    ╰─$ kubectl get workshopsessions
    NAME                               URL                                                            USERNAME   PASSWORD
    cnd-config-practices-w03-s001   http://cnd-config-practices-w03-s001.192.168.64.20.nip.io
    ```

    Delete the worker session(s):

    ```bash
    kubectl delete workshopsession/cnd-config-practices-w03-s001
    ```

    This will terminate the associated workshop session pods.

    New worksessions will start pods based from the last workshop images.

### Lessons

The [workshop content](./workshop/content) contains all the meat of the
course,
lab instructions.

### Solution

The [exercises directory](./exercises) contains the following:

-   `smoke-tests` directory contains the exercise smoke test
    project.

-   `pal-tracker` directory contains the application source code
-   `k8s` directory contains the deployment resource configurations.

## Known issues

### Kubernetes cannot pull from container registry (kind)

This problem is mentioned in [self-signed cert in local kind environment prevents per-session registry from working #18](https://github.com/platform-acceleration-lab/cnd-deploy-practices-eduk8s/issues/18)

Work-around for now is to side-load the image manually following
the steps mentioned below.

```
cd workshop-files/exercises/pal-tracker
./gradlew bootBuildImage --imageName=pal-tracker:v1
(Get and export the value of REGISTRY_HOST from the running workshop)
export REGISTRY_HOST=cnd-config-practices-w01-s001-registry.192.168.1.7.nip.io
docker tag pal-tracker:v1 ${REGISTRY_HOST}/pal-tracker:v1
kind load docker-image --name cnd-config-practices ${REGISTRY_HOST}/pal-tracker:v1
```

### Kubernetes cannot pull from container registry (minikube)

Make sure you have configured the `--insecure-registry` flag to the
correct subnet associated with your minikube installation.

You can verify the minikube ip address:

```bash
minikube ip
```

If you misconfigured the flag,
delete your minikube cluster and recreate with the correct value.

### Workshop does not deploy, workhop namespace does not terminate

You are attempting to update a workspace configuration,
but it is not accessible through the training portal.

1.  Verify the workhop session pods can pull the image during the
    initialization of a workshop session:

    ```bash
    kubectl get po -A --field-selector metadata.namespace!=kube-system -w
    ```

    Watch for pod creation:

    ```no-highlight

    ```

1.  Verify you have no orphaned or dangling workshop sessions:

    ```bash
    kubectl get workshopsessions
    ```

    Delete orphaned workshop session(s):

    ```bash
    kubectl delete workshopsession/<workshopsession name>
    ```
