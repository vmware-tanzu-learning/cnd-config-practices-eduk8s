
This exercise walks you through on
how to use ConfigMaps in Kubernetes to set
environment variables for your application.

# Learning Outcomes

After completing the lab, you will be able to:

- Explain how to configure an application running on Kubernetes using a ConfigMap
- Describe how to view Pod logs

## Run in a container

Now you are going to build a new
container image.

1.  Use the `bootBuildImage` task to build a new image.
    This time
    specify the repository and the version while building the image.

    ```terminal:execute
    command: ./gradlew bootBuildImage --imageName={{ registry_host }}/pal-tracker:v1
    session: 1
    ```

1.  Wait until the image is successfully built and run your new image.
    An exception is expected to be thrown.

    ```terminal:execute
    command: docker run --rm -p 8080:8080 {{ registry_host }}/pal-tracker:v1
    session: 1
    ```

    Inspect the exception that is being thrown.

1.  To handle multiple environment variables more easily across Docker
    container instances, use a `dockerenv` file in the root of your
    application with the key/value pair contents:

    ```editor:open-file
    file: ~/exercises/pal-tracker/dockerenv
    ```

1.  Tell `docker run` to read the environment variables from the file:

    ```terminal:execute
    command: docker run --env-file=dockerenv --rm -p 8080:8080 {{ registry_host }}/pal-tracker:v1
    session: 1
    ```

1.  Navigate to `http://localhost:8080` and see that the
    application responds with a `hello from dockerenv file` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

1.  Terminate your web app:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

1.  Once you are confident your application runs from within the
    container, publish the new version to container registry.

    ```terminal:execute
    command: docker push {{ registry_host }}/pal-tracker:v1
    session: 1
    ```

## Deploy the new image

1.  Make sure you are in your `~/exercises/k8s` directory now in
    both of your terminal windows,
    and clear both:

    ```terminal:execute-all
    command: cd ~/exercises/k8s
    ```

    ```terminal:clear-all
    ```

1.  Before applying the change to the Deployment, run
    `kubectl get pods --watch`.
    This will show you a running status of the Pods as changes are
    applied.

    ```terminal:execute
    command: kubectl get pods --watch
    session: 1
    ```

1.  To apply your Deployment changes, run the same command you ran when
    you first created the Deployment:

    ```terminal:execute
    command: kubectl apply -f deployment.yaml
    session: 2
    ```

    View the output of the `kubectl get pods --watch`.
    You will see a new Pod being created, and the old Pod getting
    terminated.
    The new Pod will start crashing and you will see it cycle its
    STATUS between "Running", "Error", and "CrashLoopBackOff".

1.  View the logs of the Pod by running:

    ```terminal:execute
    command: kubectl logs -lapp=pal-tracker --tail=100
    session: 2
    ```

    This will show the last 100 lines of system out and system error
    from Pods with the label `app: pal-tracker`.
    Right now you only have a single Pod, but when you scale to multiple
    Pods this same command will fetch logs from all of them.

1.  Inspect the exception that is being thrown.

1.  Terminate the watch:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

## Configure the app using a ConfigMap

Your application is failing to start because `welcome.message` is not
configured.
To set this value, you will create a Kubernetes ConfigMap to hold a set
of key/value pairs.
Then you will update your Deployment to fetch the `welcome.message`
value out of the ConfigMap, and set it as an environment variable in
the container running your app.

1.  Review `configmap.yaml` file:

    ```editor:open-file
    file: ~/exercises/k8s/configmap.yaml
    session: 1
    ```

    The `env` section above sets an environment variable named
    `WELCOME_MESSAGE`.
    The value for `WELCOME_MESSAGE` is taken from a ConfigMap object
    named `pal-tracker`.
    Within the ConfigMap it looks for a value using the key
    `welcome.message`.

1.  Apply the `configmap.yaml`:

    ```terminal:execute
    command: kubectl apply -f configmap.yaml
    session: 1
    ```

1.  Verify the ConfigMap is created successfully:

    ```terminal:execute
    command: kubectl get configmaps
    session: 1
    ```

1.  Review `env` section of your container

    ```terminal:execute
    command: kubectl describe configmap pal-tracker
    session: 1
    ```

    Note that `welcome.message` is set to `hello from kubernetes`.

1.  Navigate to `http://localhost:8080` and see that the
    application responds with a `hello` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

# Run a smoke test

Submit the assignment using the `cloudNativeDeveloperK8sConfigMap`
Gradle task.
It requires you to provide the URL of your application running on
Kubernetes and the name of your ConfigMap.
For example:

```bash
cd ~/workspace/assignment-submission
./gradlew cloudNativeDeveloperK8sConfigMap -PserverUrl=http://${YOUR_APPLICATION_URL} -PconfigMapName=pal-tracker
```

# Wrap

[Add some wordings here]

# Resources

- [ConfigMap Overview](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [ConfigMap API Documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#configmap-v1-core)
