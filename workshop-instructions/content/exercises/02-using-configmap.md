
This exercise walks you through
how to use *ConfigMaps* in Kubernetes to set
environment variables for your application.

# Learning Outcomes

After completing the lab, you will be able to:

-   Explain how to configure an application running on
    Kubernetes using a *ConfigMap*

## Run in a container locally

Now you are going to build a new
container image and run it on your developer workstation using *Docker*.

1.  Use the `bootBuildImage` task to build a new image.
    Specify the repository and the version while building the image.

    ```terminal:execute
    command: ./gradlew bootBuildImage --imageName=${REGISTRY_HOST}/pal-tracker:v1
    session: 1
    ```

1.  Wait until the image is successfully built and then
    run your new image.
    **An exception is expected to be thrown.**

    ```terminal:execute
    command: docker run --rm -p 8080:8080 ${REGISTRY_HOST}/pal-tracker:v1
    session: 1
    ```

    Note that the exception occurred due to
    `Could not resolve placeholder 'welcome.message' in value "${welcome.message}`.

    Notice that the Spring Boot application does not allow start up
    without the `WELCOME_MESSAGE` environment variable.
    It is required by the application to run.
    It is a better practice to *fail fast* than to have the application
    start in an indeterminate state.

1.  To handle multiple environment variables more easily across Docker
    container instances, create a `dockerenv` file in the root of your
    application with the key/value pair contents:

    ```editor:append-lines-to-file
    file: ~/exercises/pal-tracker/dockerenv
    text: |
        WELCOME_MESSAGE=hello from dockerenv file
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

    ```terminal:interrupt
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
    command: kubectl apply -f .
    session: 2
    ```

    View the output of the `kubectl get pods --watch`.
    The new Pod will start crashing and you will see it cycle its
    STATUS among "Running", "Error", and "CrashLoopBackOff".

1.  View the logs of the Pod by running:

    ```terminal:execute
    command: kubectl logs -lapp=pal-tracker --tail=100
    session: 2
    ```

    This will show the last 100 lines of system out and system error
    from Pods with the label `app: pal-tracker`.

    Notice that the following exception is thrown by the application.
    (You might have to click the above action a couple of times.)

    ```no-highlight
    Caused by: java.lang.IllegalArgumentException: Could not resolve placeholder 'welcome.message' in value "${welcome.message}"
    ```

    This is the same failure of Spring Boot to start the application as
    you saw when running locally.

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
            welcome.message: "hello from kubernetes"
    ```

    The `data` section above sets an environment variable named
    `WELCOME_MESSAGE`.
    The value for `WELCOME_MESSAGE` is taken from a ConfigMap object
    named `pal-tracker`.
    Within the ConfigMap it looks for a value using the key
    `welcome.message`.

1.  Apply the `configmap.yaml`.

    ```terminal:execute
    command: kubectl apply -f configmap.yaml
    session: 2
    ```

1.  Verify the ConfigMap called `pal-tracker` is created successfully.

    ```terminal:execute
    command: kubectl get configmaps
    session: 2
    ```

1.  Review `Data` section of the ConfigMap.

    ```terminal:execute
    command: kubectl describe configmap pal-tracker
    session: 2
    ```

    Note that `welcome.message` is set to `hello from kubernetes`.

1.  Edit `deployment.yaml` file.

    ```editor:insert-value-into-yaml
    file: ~/exercises/k8s/deployment.yaml
    path: spec.template.spec.containers[0]
    value:
        env:
        - name: WELCOME_MESSAGE
          valueFrom:
            configMapKeyRef:
              name: pal-tracker
              key: welcome.message
    ```

1.  Apply the modified `deployment.yaml`.

    ```terminal:execute
    command: kubectl apply -f deployment.yaml
    session: 2
    ```

1.  View the output of the `kubectl get pods --watch`.
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

Now there are some issues to consider with the way configuration
properties are provided to the applications in this exercise:

-   The configuration data among application instances
    become more and more different as time goes on:
    this is called "Configuration Drift".

-   You do not want to set configuration data by hand.
    If you need to change a configuration, you will want
    to make a change in source code-controlled manner,
    which will be picked by automated deployment tool.

-   Some configuration data such as password need to be
    protected.
    This might require the usage of security-enabled configuration
    servers such as *HashiCorp Vault* or *Cloud Foundry CredHub*.

# Resources

- [ConfigMap Overview](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [ConfigMap API Documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#configmap-v1-core)

