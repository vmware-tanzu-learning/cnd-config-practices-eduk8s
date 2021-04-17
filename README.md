# README

Welcome to the Developer Cloud Native Configuration practices workshop.

This page is for maintainers,
not for students.

Before getting into the workshop series,
it is necessary to outline the structure of this project.

## Deploy

The `deploy` directory contains convenience scripts to help the
developer/maintainer with local development builds and deploying
the workshop to local or remote clusters.

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

The development workflow is based on [https://github.com/vmware-tanzu-private/edu-educates-template].

See that repo for pre-requisites and description of commands.

### Running workshop locally

1.  `make`

1.  Navigate to the Training Portal URL displayed in the terminal.

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

At this time,
the only working option for workflow is to tear down and recreate the
kind cluster:

1.  Deleted any pre-existing kind cluster for this workshop:
    `kind delete cluster --name cnd-deploy-practices`

1.  Build the content, images, and deploy to the local Kind cluster:
    `make`

1.  Sideload `pal-tracker` image to Kind cluster specific to the labs:

    `./deploy/environment/kind/sideload-pal-tracker.sh 3`

    Where the argument of `3` give you up to 3 workshop session
    pal-tracker image repositories are side loaded to Kind for you.

    *Side loading of the `pal-tracker` image is required because when*
    *running containerd in a Kind cluster does not allow K8s to pull*
    *from insecure registries*

### Lessons

The [workshop instructions](./workshop-instructions) contains all the
meat of the course,
lab instructions.

### Solution

The [exercises directory](./workshop-files/exercises) contains the following:

-   `pal-tracker` directory contains the application source code

-   `k8s` directory contains the deployment resource configurations

## Production

https://tanzu.vmware.com/developer/workshops/cnd-config-practices/


