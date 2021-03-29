# Building a blocking web application

This exercise will walk you through building and running a basic
blocking web application using
[Spring Boot](https://projects.spring.io/spring-boot/)
on your "local" development environment.

# Learning outcomes

-   Describe how to run a basic web application in a development
    environment.
-   Describe how dependencies are declared and sourced when building
    your Spring web application.
-   Explain benefits and trade-offs of blocking web applications.

# Getting started

Review the
[Blocking web apps](https://docs.google.com/presentation/d/184YWy6tmtSQ8-bXLw3wdZYcHQEkgW3-cZ3Y7Dqq3rMo/present?slide=id.gc70c0249b7_0_0)
slides or the accompanying *Introduction* lecture.

# Project structure

1.  The workshop exercise instructions will assume from now on that your
    code and configuration are in the `~/exercises` directory.

1.  The `~/exercises/pal-tracker` directory contains the code you will
    review and exercise.

1.  Set current directory to the `~/exercises/pal-tracker` now in both of
    your terminal windows:

    ```terminal:execute-all
    command: cd ~/exercises/pal-tracker
    ```

For the remainder of this lesson you will review,
build and run the code locally.

# Set up your editor

You will set up your editor now to activate the
*Java Project Manager* extension:

1.  Open your editor:

    ```editor:open-file
    file: ~/exercises/pal-tracker/gradle/wrapper/gradle-wrapper.properties
    ```

1.  Execute the `>Java: Create Project` command.
    (Bring up the Command Palette (Cmd+Shift+P for Mac and
    Ctrl+Shift+P for Windows) and then type `Java`
    to search for this command.)

1.  Watch the bottom status bar as the Java project management
    extensions are loaded,
    this may take a minute.
    At the end of the process you will see a prompt for a project
    creation archetype.
    Dismiss it by hitting the ESC key.

    You should now see a "JAVA PROJECTS" view near the bottom of the
    Explorer pane,
    the Java Project Manager will detect your Gradle built Java
    project.

1.  Switch to the "JAVA PROJECTS" view in the editor Explorer.

# Build tool

You need a build tool to compile and package your Java application.
This project uses the [Gradle](https://gradle.org/) build tool.

1.  Read about the [gradle wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html#sec:adding_wrapper).
    It is used in this project to execute various tasks to build or
    run your web application locally.

1.  Review the `gradle/wrapper/gradle-wrapper.properties` file in your
    code editor and review the `DISTRIBUTION_URL` value.
    This is specific version of gradle that is pinned to this project
    which guarantees
    [Environment parity](https://12factor.net/dev-prod-parity)
    of the build tool between the developer and various build and
    pipeline environments.

# Review the gradle project

Now that once the plumbing of our application is set up,
you can begin building a Spring Boot _Hello World_ application.

The Spring community provides [Spring Initializr](http://start.spring.io)
to help you generate your project,
but you very well could generate your own project from scratch.

You are provided the project in this exercise.

Review the various sections of the gradle build to become familiar with
it:

1.  Open your project in your code editor:

    ```editor:open-file
    file: ~/exercises/pal-tracker/build.gradle
    ```

1.  Review the `plugins` "closure"
    (a groovy specific term for a *code block*):

    ```groovy
    plugins {
        id 'org.springframework.boot' version '2.3.1.RELEASE'
        id 'io.spring.dependency-management' version '1.0.8.RELEASE'
        id 'java'
    }
    ```

    -   The first plugin provides behaviors to build and run a spring
        boot application.
        You can read about it here:
        [spring boot gradle plugin](https://docs.spring.io/spring-boot/docs/current/reference/html/build-tool-plugins-gradle-plugin.html).

    -   The second plugin specify dependency management behaviors
        when building your Spring Boot application.
        You can read more about it here:
        [Spring Dependency Management plugin](https://plugins.gradle.org/plugin/io.spring.dependency-management)

    -   The last plugin specifies that the Java language compiler and
        runtime are used to build and run your application.
        You can read about it here:
        [Java plugin](https://docs.gradle.org/current/userguide/java_plugin.html)

1.  Review the `repositories` closure:

    ```groovy
    repositories {
        mavenCentral()
    }
    ```

    The project will source its Java and Spring dependencies from
    [Maven Central Repository](https://mvnrepository.com/).
    This is a public repository on the internet.
    If you are working on behalf of a private or Enterprise company,
    you will likely configure a repository internal to your organization.

1.  Review the `dependencies` closure:

    ```groovy
    dependencies {
        implementation 'org.springframework.boot:spring-boot-starter-web'
    }
    ```

    The "starter" dependency is specific for Spring Boot web blocking
    web applications.
    The starter will tell your build tool to pull in all the Java and
    spring libraries needed to compile, package and run your web
    application.

Your `build.gradle` file is an important part of making your spring boot
web application compliant with the two following cloud native guidelines:

-   [Declaring your dependencies](https://12factor.net/dependencies):
    A goal when deploying to a cloud native ready platform is to not
    rely on arbitrary dependencies, such as language libraries,
    when deploying the application.
    This project's build will provide a single *deployable* artifact that
    can be deployed either locally (for development purposes),
    or to a *Container orchestrator* (you will see in the third lesson).

-   [Port binding](https://12factor.net/port-binding):
    Another goal when deploying to a cloud native ready platform is to
    not rely on arbitrary *Middleware* installations,
    such as web servers.
    This project's build will provide a single *runnable* artifact that
    can be run either locally (for development purposes),
    or on a *Container orchestrator*,
    without requiring injection into a separate web server.

# Review your application code

1.  Inside of the source directory `src/main/java`,
    all of your code is in the `io.pivotal.pal.tracker` package.
    This application is a trivial *Hello World* style application,
    but is it important to consider how you organize and isolate your
    code.
    Later workshops will show more sophisticated codebases.

1.  Review the `io.pivotal.pal.tracker.PalTrackerApplication` class.

    ```editor:open-file
    file: ~/exercises/pal-tracker/src/main/java/io/pivotal/pal/tracker/PalTrackerApplication.java
    ```

    It is simple,
    but there is a lot going on behind the scenes:

    -   The `main()` method is the entry point for Java applications.
        Its purpose is to start the Spring Boot web application process.

    -   [`@SpringBootApplication`](https://docs.spring.io/autorepo/docs/spring-boot/current/api/org/springframework/boot/autoconfigure/SpringBootApplication.html)
        is the secret sauce for setting up the plumbing to run a self-
        encapsulated web application for this project,
        including a web server process, along with *dispatcher* and
        *handlers* that will serve specific URLs with designated
        functionality.

1.  Review the `io.pivotal.pal.tracker.WelcomeController` class.
    It contains the web application *handler* logic.

    ```editor:open-file
    file: ~/exercises/pal-tracker/src/main/java/io/pivotal/pal/tracker/WelcomeController.java
    ```

    -   *Java Code*:

        Notice the entire logic of the web application is in the
        *Controller* class,
        without handling any of the "plumbing" necessary to route the
        request from a network call, or handling conversion of content
        types for the response.

    -   *Java Annotations*:

        The `@RestController` and `@GetMapping` annotations are
        instructions for the Spring framework to generate the "plumbing"
        code to route the request to the *handler* `sayHello()` method
        during the start up time of the application.

# Run your application locally

1.  Using your Gradle wrapper `gradlew` in the root of the `pal-tracker`
    project,
    run the `tasks` command to find which task to use to run your
    application locally
    (hint:
    look under the *Application tasks* category)

    ```terminal:execute
    command: ./gradlew tasks
    session: 1
    ```

1.  Once you find the task, use it to run your application.

    You will see log output from Spring Boot and a line that says it is
    listening on port 8080.
    Navigate to [localhost:8080](http://localhost:8080) and see that the
    application responds with a `hello` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

Notice that the gradle `bootRun` task will implicitly compile the Java
source code, load it into memory, and run it.

It does not build an artifact you can deploy.
You will see that in the next lesson.

# Check your exercise

Run the smoke test to verify you completed the exercise correctly by
running the `cloudNativeDeveloperK8sBootApp` gradle task from within the
existing `smoke-tests` project directory.
It requires you to provide the URL of your application running locally.

1.  Navigate to the `~/exercises/smoke-tests` directory in
    terminal 2:

    ```terminal:execute
    command: cd ~/exercises/smoke-tests
    session: 2
    ```

1.  Run the smoke test command in terminal 2:

    ```terminal:execute
    command: ./gradlew cloudNativeDeveloperK8sBootApp -PserverUrl=http://localhost:8080
    session: 2
    ```

1.  After your smoke test is complete,
    terminate your web app:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

# Resources

- [Spring Initializr](https://start.spring.io)
- [12 factor applications](https://12factor.net)
