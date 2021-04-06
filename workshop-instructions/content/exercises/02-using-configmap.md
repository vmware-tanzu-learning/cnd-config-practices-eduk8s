
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
    command: ./gradlew bootBuildImage --imageName=${REGISTRY_HOST}/pal-tracker:v1
    session: 1
    ```

1.  Wait until the image is successfully built and run your new image.
    **An exception is expected to be thrown.**

    ```terminal:execute
    command: docker run --rm -p 8080:8080 ${REGISTRY_HOST}/pal-tracker:v1
    session: 1
    ```

    Note that the exception occurred due to `Could not resolve placeholder 'welcome.message' in value "${welcome.message}`.

1.  To handle multiple environment variables more easily across Docker
    container instances, use a `dockerenv` file in the root of your
    application with the key/value pair contents:

    ```editor:open-file
    file: ~/exercises/pal-tracker/dockerenv
    ```

1.  Tell `docker run` to read the environment variables from the file:

    ```terminal:execute
    command: docker run --env-file=dockerenv --rm -p 8080:8080 ${REGISTRY_HOST}/pal-tracker:v1
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
    command: docker push ${REGISTRY_HOST}/pal-tracker:v1
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

1.  Apply Service and Ingress resources.

    ```terminal:execute
    command: kubectl apply -f service.yaml
    session: 2
    ```

    ```terminal:execute
    command: kubectl apply -f ingress.yaml
    session: 2
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
    you first created the Deployment. 
    **Failure of the deployment is expected**

    ```terminal:execute
    command: kubectl apply -f deployment.yaml
    session: 2
    ```

    View the output of the `kubectl get pods --watch`.
    The new Pod will start crashing and you will see it cycle its
    STATUS among "Pending", ContainerCreating", and "CreateContainerConfigError".

1.  View the logs of the Pod by running:

    ```terminal:execute
    command: kubectl logs -lapp=pal-tracker --tail=100
    session: 2
    ```

    This will show the last 100 lines of system out and system error
    from Pods with the label `app: pal-tracker`.
    Right now you only have a single Pod, but when you scale to multiple
    Pods this same command will fetch logs from all of them.

## Configure the app using a ConfigMap

Your application is failing to start because `welcome.message` is not
configured.
To set this value, you will create a Kubernetes ConfigMap to hold a set
of key/value pairs.
Then you will update your Deployment to fetch the `welcome.message`
value out of the ConfigMap, and set it as an environment variable in
the container running your app.

1.  Create `configmap.yaml` file.

    ```editor:append-lines-to-file
    file: ~/exercises/k8s/configmap.yaml
    text: |
        apiVersion: v1
        kind: ConfigMap
        metadata:
            name: pal-tracker
            labels:
                app: pal-tracker
        data:
            WELCOME_MESSAGE: "hello from kubernetes"
    ```

    The `data` section above sets an environment variable named
    `WELCOME_MESSAGE`.
    The value for `WELCOME_MESSAGE` is taken from a ConfigMap object
    named `pal-tracker`.
    Within the ConfigMap it looks for a value using the key
    `welcome.message`.

2.  Apply the `configmap.yaml`.

    ```terminal:execute
    command: kubectl apply -f configmap.yaml
    session: 2
    ```

3.  Verify the ConfigMap called `pal-tracker` is created successfully.

    ```terminal:execute
    command: kubectl get configmaps
    session: 2
    ```

4.  Review `Data` section of the ConfigMap.

    ```terminal:execute
    command: kubectl describe configmap pal-tracker
    session: 2
    ```

    Note that `WELCOME_MESSAGE` is set to `hello from kubernetes`.

5.  View the output of the `kubectl get pods --watch`.
    You will see the previously failing Pod is now in `Running` status.

# Run a smoke test

Run a smoke test against your deployment via the following command:

```terminal:execute
command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
session: 2
```

You should see 'hello from kubernetes' message in the output.

# Wrap

In this exercise, you used ConfigMap of Kubernetes to set up
properties of an application.

# Resources

- [ConfigMap Overview](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [ConfigMap API Documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#configmap-v1-core)
