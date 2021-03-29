# Using ConfigMaps to set environment variables

To gain an understanding of how to use ConfigMaps in Kubernetes to set
environment variables for your application.

# Learning Outcomes

After completing the lab, you will be able to:

- Explain how to configure an application running on Kubernetes using a ConfigMap
- Describe how to view Pod logs

## Running in a container

Now that you have made changes to your code, you need to build a new
container image.

1.  Use the `bootBuildImage` task to build a new image. This time
    specify the repository and the version while building the image.

    ```bash
    ./gradlew bootBuildImage --imageName={{ registry_host }}/pal-tracker:v1
    ```

1.  Try running your new image.

    ```bash
    docker run --rm -p 8080:8080 ${YOUR_DOCKER_HUB_USERNAME}/pal-tracker:v1
    ```

    Inspect the exception that is being thrown.

1.  To handle multiple environment variables more easily across Docker
    container instances, create a `dockerenv` file in the root of your
    application with the key/value pair contents:

    ```bash
    WELCOME_MESSAGE=hello from dockerenv file
    ```

1.  Tell `docker run` to read the environment variables from the file:

    ```bash
    docker run --env-file=dockerenv --rm -p 8080:8080 ${YOUR_DOCKER_HUB_USERNAME}/pal-tracker:v1
    ```

1.  Once you are confident your application runs from within the
    container, publish the new version to Docker Hub.

    ```bash
    docker push ${YOUR_DOCKER_HUB_USERNAME}/pal-tracker:v1
    ```

1.  Delete the `dockerenv` file, it is no longer needed.

## Deploy the new image

1.  Update your Deployment yaml file to use the new version of your
    image:

    ```diff
          containers:
            - name: pal-tracker-container
    -         image: YOUR_DOCKER_HUB_USERNAME/pal-tracker:v0
    +         image: YOUR_DOCKER_HUB_USERNAME/pal-tracker:v1
    ```

1.  Before applying the change to the Deployment run
    `kubectl get pods --watch`.
    This will show you a running status of the Pods as changes are
    applied.
    Run the following commands in a new terminal window so you can
    monitor the Pod changes in real time.

1.  To apply your Deployment changes, run the same command you ran when
    you first created the Deployment:

    ```bash
    kubectl apply -f k8s/deployment.yaml
    ```

    View the output of the `kubectl get pods --watch`.
    You will see a new Pod being created, and the old Pod getting
    terminated.
    The new Pod will start crashing and you will see it cycle its
    STATUS between "Running", "Error", and "CrashLoopBackOff".

1.  View the logs of the Pod by running:

    ```bash
    kubectl logs -lapp=pal-tracker --tail=100
    ```

    This will show the last 100 lines of system out and system error
    from Pods with the label `app: pal-tracker`.
    Right now you only have a single Pod, but when you scale to multiple
    Pods this same command will fetch logs from all of them.

1.  Inspect the exception that is being thrown.

## Configure the app using a ConfigMap

Your application is failing to start because `welcome.message` is not
configured.
To set this value, you will create a Kubernetes ConfigMap to hold a set
of key/value pairs.
Then you will update your Deployment to fetch the `welcome.message`
value out of the ConfigMap, and set it as an environment variable in
the container running your app.

1.  Create a `configmap.yaml` file with the following contents:

    ```terminal:execute
    command: git show configmap-solution:configmap.yaml
    session: 2
    ```

1.  Apply the `configmap.yaml`:

    ```bash
    kubectl apply -f k8s/configmap.yaml
    ```

    You can verify the ConfigMap created successfully by running
    `kubectl get configmaps` and
    `kubectl describe configmap pal-tracker`.

1.  In your Deployment, add an `env` section to your container

    ```diff
            - name: pal-tracker-container
              image: {{ registry_host }}/pal-tracker:v1
    +         env:
    +           - name: WELCOME_MESSAGE
    +             valueFrom:
    +               configMapKeyRef:
    +                 name: pal-tracker
    +                 key: welcome.message
    ```

    The `env` section above sets an environment variable named
    `WELCOME_MESSAGE`.
    The value for `WELCOME_MESSAGE` is taken from a ConfigMap object
    named `pal-tracker`.
    Within the ConfigMap it looks for a value using the key
    `welcome.message`.

1.  Apply the Deployment manifest.

1.  Your Pod will now start successfully.
    Try navigating to the development domain using a web browser.
    You will now see the welcome message you set in the ConfigMap.

1.  Commit and push your changes.

# Assignment

Submit the assignment using the `cloudNativeDeveloperK8sConfigMap`
gradle task.
It requires you to provide the URL of your application running on
Kubernetes and the name of your ConfigMap.
For example:

```bash
cd ~/workspace/assignment-submission
./gradlew cloudNativeDeveloperK8sConfigMap -PserverUrl=http://${YOUR_APPLICATION_URL} -PconfigMapName=pal-tracker
```

# Learning Outcomes

Now that you have completed the lab, you should be able to:
::learningOutcomes::

# Resources

- [ConfigMap Overview](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [ConfigMap API Documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#configmap-v1-core)
