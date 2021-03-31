
This exercise walk you through on how to configure cloud native
applications using
environment variables.

# Learning Outcomes

After completing the lab, you will be able to:

- Summarize some of the ways to configure a Spring application
- Use environment variables to configure an application running locally

# 12 Factor Applications

Take a minute to read through the [12 factors](https://12factor.net)
guidelines on how to architect applications.
In practice you will have to decide which ones to use and if it makes
sense to adhere to all of them.

In the prior labs, you covered the first two factors by setting up your
codebase in GitHub and using Gradle to explicitly declare your
dependencies.

This lab will focus on the third factor: storing configuration in
the environment.

There are many options for how to externalize configuration for a cloud
native application.
Our first choice is to use environment variables.

# Get started

1.  Set current directory to the `~/exercises/pal-tracker` now in both of
    your terminal windows:

    ```terminal:execute-all
    command: cd ~/exercises/pal-tracker
    ```

1.  Open your editor:

    ```editor:open-file
    file: ~/exercises/pal-tracker/build.gradle
    ```

1.  Review the `dependencies` closure in your
    `build.gradle` file to enable our test dependencies:

    ```groovy
    testImplementation('org.springframework.boot:spring-boot-starter-test') {
        exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
    }
    ```

    *Note*: Spring Boot 2.3.x pulls in both Junit 4 and 5.
    In the Spring Boot segment of the course you will use Junit 5.
    The `exclude group` clause will drop Junit 4 support.

1.  Review the `test` closure to the end of the `build.gradle`
    file:

    ```groovy
    test {
        useJUnitPlatform()
    }
    ```

# Environment Variables

You will use the environment variable mechanism to provide configuration
to a process.
In other words, it does not matter if your application is written in
[Java](https://en.wikipedia.org/wiki/Java_(programming_language)),
[Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language)),
[Golang](https://en.wikipedia.org/wiki/Go_(programming_language)), or
some other language, they all have the capability of reading environment
variables.
You will refactor your application to configure the `hello` message from
the environment.

## Externalize Configuration

Spring Boot includes a mechanism to get configuration values.

1.  Review the `io.pivotal.pal.tracker.WelcomeController` class.

    ```editor:open-file
    file: ~/exercises/pal-tracker/src/main/java/io/pivotal/pal/tracker/WelcomeController.java
    ```

    Review how `@Value` annotation is used to inject `welcome.message`
    property value through a constructor argument.

    Take time to read about
    [annotation-based configuration](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-annotation-config)
    if you are new to Spring or if you need a refresher.
    There is more [detailed documentation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions-beandef)
    on using Spring expressions in bean definitions and annotations, if
    you are interested.

## Verify it works

1.  Run your app with `WELCOME_MESSAGE` environment variable, which
    is set at the commandline.

    ```terminal:execute
    command: WELCOME_MESSAGE=hello ./gradlew bootRun
    session: 1
    ```

1.  Navigate to `http://localhost:8080` and see that the
    application responds with a `hello` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

1.  Terminate your web app:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

## Manage local properties

Running your application with environment variables in the command line
every time is a pain.
You can
[leverage Gradle](https://cloudnative.tips/configuring-a-java-application-for-local-development-60e2c9794ca7)
to make this easier.

1.  Review the `bootRun.environment` and `test.environment` methods
    in the `build.gradle` file:

    ```editor:open-file
    file: ~/exercises/pal-tracker/build.gradle
    ```

    This will instruct Gradle to set that environment variables
    for you when you run the `bootRun` task:

    ```terminal:execute
    command: ./gradlew bootRun
    session: 1
    ```

    This has the added benefit of documenting required environment
    variables and supporting multiple operating systems.

1.  Navigate to `http://localhost:8080` and see that the
    application responds with a `hello` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

1.  Terminate your web app:

    ```terminal:execute
    command: <ctrl+c>
    session: 1
    ```

1.  Make sure all your tests pass before moving on by running
    the Gradle `build` task.

    ```terminal:execute
    command: ./gradlew clean build
    session: 1
    ```

# Wrap

[Add some wordings here]

# Resources

- [Spring application external configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html)
