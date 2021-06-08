# Cloud Native Configuration practices workshop maintainer's guide

Welcome to the Developer Cloud Native Configuration practices workshop.

This page is for maintainers, not for students.

## Requirements

- [Docker Desktop](https://www.docker.com/get-started)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) version `1.21` or greater
- [Kind](https://kind.sigs.k8s.io/)

## Commands

### Build and Run Locally

```bash
make
```

## Rebuild, and redeploy the workshop and training portal with changes

```bash
make reload
```

## Refresh the content in existing deployment

```bash
make refresh
```

After running the refresh, run `update-workshop` in your workshop terminal
window and refresh the browser.
The educates documentation has more details on
[live updates to content](https://docs.edukates.io/en/latest/workshop-content/working-on-content.html#live-updates-to-the-content)
as well.

### Stop an existing educates cluster

```bash
make stop
```

## Start a previously stopped educates cluster

```bash
make start
```

## Delete local educates cluster

```bash
make delete
```

## Delete local educates cluster and local registry

```bash
make clean
```

## Resources

- [Educates](https://docs.edukates.io/)