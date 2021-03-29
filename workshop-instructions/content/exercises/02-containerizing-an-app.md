# Containerizing an App

This lab will walk you through how to containerize an application.
You will use a Gradle task provided by Spring Boot Plugin to
generate container image.
Behind the scenes,
the Gradle task uses [Buildpacks](https://buildpacks.io/) to generate
the image.

Once you have built your container image, you will test it using the
locally installed Docker container runtime.

# Learning Outcomes

After completing the lab, you will be able to:

-   Describe how to generate a runnable container image for your
    application

-   Explain how to publish an image to a container registry

# Getting started

Review the
[Containerize](https://docs.google.com/presentation/d/184YWy6tmtSQ8-bXLw3wdZYcHQEkgW3-cZ3Y7Dqq3rMo/present?slide=id.gc70c0249b7_0_168)
slides or the accompanying *Containerize* lecture.

In the previous lesson you ran your application locally using the gradle
`bootRun` task.
Running the task only compiled and ran your application in memory on
your development environment.

You could also have built a Java deployable `jar` artifact using the
gradle `build` task,
and then run it with the java command:

`java -jar build/lib/pal-tracker.jar`

The jar file is deployable and runnable *as long as you have the Java*
*runtime installed on the target machine where you run it*.

But the jar file is not sufficient by itself to run inside a container.
Cloud native applications follow the
[`dependencies`](https://12factor.net/dependencies) guideline,
where all dependencies must be explicitly *declared* and *isolated*.

You will build a container image that explicitly isolates all the
runtime dependencies that can be run on a container orchestrated
platform.

Make sure you are in your `~/exercises/pal-tracker` directory now in
both of your terminal windows,
and clear both:

```terminal:execute-all
command: cd ~/exercises/pal-tracker
```

```terminal:clear-all
```

# Use Buildpacks to containerize your app

To generate container images, you will be using a Gradle task.

1.  From the root of your application, use the `bootBuildImage` task to
    generate a runnable container image for your application.
    (It might take about a minute or so for the task to finish.)

    ```terminal:execute
    command: ./gradlew bootBuildImage
    session: 1
    ```

1.  Once the `bootBuildImage` task finishes, verify that an image was
    generated and is listed in your locally available Docker images.
    Run the following command and look for an image named `pal-tracker`.

    ```terminal:execute
    command: docker images
    session: 1
    ```

# Run your app using the container image locally

You will use the Docker runtime on your local environment to run your
app.

This is a good way to simulate in your local development machine what
your container orchestrator will do in the next lesson.

1.  Run your image using `docker` and expose port 8080 where your
    application is listening.

    ```terminal:execute
    command: docker run --rm -p 8080:8080 pal-tracker
    session: 1
    ```

1.  In the console output, you should see Spring Boot starting up your
    application.
    Once it is running,
    from a separate terminal window execute a request:

    ```terminal:execute
    command: curl -v http://localhost:8080
    session: 2
    ```

    You should see your `hello` message.

1.  Terminate the application:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

# Container registry

Next you will publish your image to a container registry where
your container orchestrated platform can pull to run it.

For this lab, you will use a container registry provided to you at
`https://{{ registry_host }}`,
but you could (in theory) use any container registry.

Examples of other container registries are
[Harbor](https://goharbor.io/),
[Github Container Registry](https://docs.github.com/en/packages/guides/about-github-container-registry),
[Amazon Elastic Container Registry](https://aws.amazon.com/ecr/),
[Google Container Registry](https://cloud.google.com/container-registry),
and
[Docker Hub](https://docker.io).
Ideally you should use a private registry unless you are building open
source projects.

You do not need to explicitly login to the container registry provided
to you.
Your docker client is already set up up with authentication to the
private container registry provided in your lab environment.

# Publish your image

You are now ready to publish your image to your container registry.

1.  Start by tagging your image with your container registry,
    and a version.

    ```terminal:execute
    command: docker tag pal-tracker {{ registry_host }}/pal-tracker:v0
    session: 1
    ```

    Notice the tag is prefixed with your registry host.

1.  Push your image to your container registry:

    ```terminal:execute
    command: docker push {{ registry_host }}/pal-tracker:v0
    session: 1
    ```

# Check your exercise

Run a smoke test using the
`cloudNativeDeveloperK8sContainerizingAnApp` gradle task from within the
existing `smoke-tests` project directory.
It requires you to provide the name of your container registry.

1.  Navigate to the `~/exercises/smoke-tests` directory in
    terminal 2:

    ```terminal:execute
    command: cd ~/exercises/smoke-tests
    session: 2
    ```

1.  Run the smoke-tests command in terminal 2:

    ```terminal:execute
    command: ./gradlew cloudNativeDeveloperK8sContainerizingAnApp -Prepository={{ registry_host }}/pal-tracker
    session: 2
    ```

# Wrap

Notice the manual steps required from the last lesson and this one to
generate a deployable artifact.

There are some issues to consider with this approach:

-   Similar complexity to prepare for deployment as a legacy,
    middleware hosted application.

-   How to ensure your dependencies in your application are free from
    malware or vulnerabilities?

-   What happens behind-the-scenes with the gradle `bootBuildImage`
    command?

-   Where does this fit into an automated build and deployment pipeline?

Fortunately, VMware Tanzu suite of products helps solve some of these
problems.

You can read about some of them here:

- [Cloud Native Buildpacks](https://tanzu.vmware.com/developer/guides/containers/cnb-gs-kpack/)
- [Tanzu Build Service](https://tanzu.vmware.com/build-service?utm_source=google&utm_medium=cpc&utm_campaign=amer_gp-b_a2&utm_content=g2_t014&utm_term=tanzu%20build%20service&_bt=498180106794&_bk=tanzu%20build%20service&_bm=e&_bn=g&_bg=119184091833&gclid=Cj0KCQiAv6yCBhCLARIsABqJTjbnEPQ6tDuo23MFK9yWNHzGSzCc8CEUoAlDgsRH7xM3t6T1L5Y3m70aAnDjEALw_wcB)

# Resources

- [Containerizing Spring Boot Apps](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/reference/html/spring-boot-features.html#boot-features-container-images)
- [Buildpack Author’s Guide](https://buildpacks.io/docs/buildpack-author-guide/)
- [Container Images](https://kubernetes.io/docs/concepts/containers/images/)
