
This exercise walk you through on how to configure cloud native
applications using
environment variables.

# Learning Outcomes

After completing the lab, you will be able to:

-   Summarize some of the ways to configure an application
-   Use environment variables to externally configure an application
    running locally

# Get started

1.  Set current directory to the `~/exercises/pal-tracker` now in both of
    your terminal windows:

    ```terminal:execute-all
    command: cd ~/exercises/pal-tracker
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

    ```editor:select-matching-text
    file: ~/exercises/pal-tracker/src/main/java/io/pivotal/pal/tracker/WelcomeController.java
    text: "@Value"
    ```

    Review how `@Value` annotation is used to inject `welcome.message`
    property value through a constructor argument.

## Verify it works

1.  Run your app with `WELCOME_MESSAGE` environment variable, which
    is set at the commandline.
    Wait until the application is successfully started.
    (You should see `Tomcat started on port(s): 8080 ...`)

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

    ```terminal:interrupt
    session: 1
    ```

## Manage local properties

Running your application with environment variables at the command line
every time is tedious.

You can
[leverage Gradle](https://cloudnative.tips/configuring-a-java-application-for-local-development-60e2c9794ca7)
to make this easier when running locally.

1.  Add the `bootRun.environment` and `test.environment` methods
    to the `build.gradle` file:

    ```editor:append-lines-to-file
    file: ~/exercises/pal-tracker/build.gradle
    text: |

        bootRun.environment([
                "WELCOME_MESSAGE": "hello",
        ])

        test.environment([
                "WELCOME_MESSAGE": "Hello from test",
        ])
    ```

    If you see a pop-up window in the `Editor`
    asking if you want to synchronize
    the Java classpath/configuration, click `Always`.

    This will instruct Gradle to set that environment variables
    for you when you run the `bootRun` task:

    This has the added benefit of documenting required environment
    variables and supporting multiple operating systems.

1.  Run your app.

    ```terminal:execute
    command: ./gradlew bootRun
    session: 1
    ```

1.  Navigate to `http://localhost:8080` and see that the
    application responds with a `hello` message:

    ```terminal:execute
    command: curl -v localhost:8080
    session: 2
    ```

1.  Terminate your web app:

    ```terminal:interrupt
    session: 1
    ```

1.  Make sure all your tests pass before moving on by running
    the Gradle `build` task.

    ```terminal:execute
    command: ./gradlew clean build
    session: 1
    ```

# Wrap

In this exercise, you used environment variables to set up
configuration properties of an application.

# Resources

- [Spring application external configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html)
