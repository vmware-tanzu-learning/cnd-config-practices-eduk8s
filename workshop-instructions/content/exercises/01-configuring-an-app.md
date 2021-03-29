## Configuring a Spring Boot App

Understand on how to configure cloud native applications using
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

Before starting the lab, pull in failing tests using Git:

```bash
cd ~/workspace/pal-tracker
git cherry-pick configuration-start
```

Your goal is to get the test suite passing by the end of the lab.

Since the cherry-pick added tests, you need to set up the build to use a
testing framework.
You will use Junit 5.

Add the following to your `build.gradle` file:

1.  Add the following line to the `dependencies` closure in your
    `build.gradle` file to enable our test dependencies:

    ```groovy
    testImplementation('org.springframework.boot:spring-boot-starter-test') {
        exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
    }
    ```

    *Note*: Spring Boot 2.3.x pulls in both Junit 4 and 5.
    In the Spring Boot segment of the course you will use Junit 5.
    The `exclude group` clause will drop Junit 4 support.

1.  Add the following closure to the end of the `build.gradle`
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

1.  Before you start updating your code, run the provided tests. (It will result in compile error initially.)

    As you make code changes remember to run your tests.
    You can do this by running them from your IDE or running:

    ```bash
    ./gradlew test
    ```

1.  Extract the `hello` message to a field in the controller.
1.  Create a constructor that accepts a `message` parameter and assigns
    it to the field.
1.  Annotate that constructor parameter with `@Value`.

    `@Value` takes a specific format to reference an environment
    variable, for example:

    ```java
    @Value("${welcome.message}")
    ```

    Take time to read about [annotation-based configuration](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#beans-annotation-config)
    if you are new to Spring or if you need a refresher.
    There is more [detailed documentation](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions-beandef)
    on using Spring expressions in bean definitions and annotations, if
    you are interested.

1.  Make sure your `WelcomeControllerTest` passes before moving on.

## Verify it works

Run your app with the `bootRun` Gradle task.
It will fail to start because Spring Boot is unable to find a value for
the requested variable.

From now on the `WELCOME_MESSAGE` environment variable must be set to
run your app.
One way to do this is to add the environment variable assignment before
the Gradle command.

```bash
WELCOME_MESSAGE=hello ./gradlew bootRun
```

## Managing local properties

Running your application with environment variables in the command line
every time is a pain.
You can
[leverage gradle](https://cloudnative.tips/configuring-a-java-application-for-local-development-60e2c9794ca7)
to make this easier.

Extend the `bootRun` and `test` tasks to set the required
environment variable by adding the following to your `build.gradle`
file:

```groovy
bootRun.environment([
    "WELCOME_MESSAGE": "hello",
])

test.environment([
    "WELCOME_MESSAGE": "Hello from test",
])
```

This will instruct Gradle to set that environment variable for you when
you run the `bootRun` task:

```bash
./gradlew bootRun
```

This has the added benefit of documenting required environment variables
and supporting multiple operating systems.

Make sure all your tests pass before moving on by running the Gradle
`build` task.
After the tests pass, use git to commit and push your changes.

# Assignment

Submit the assignment using the `cloudNativeDeveloperK8sConfiguration`
gradle task from within the existing `assignment-submission` project
directory.
It requires you to provide the URL of your application running locally.

For example:

```bash
cd ~/workspace/assignment-submission
./gradlew cloudNativeDeveloperK8sConfiguration -PserverUrl=http://localhost:8080
```

# Learning Outcomes

Now that you have completed the lab, you should be able to:
::learningOutcomes::

# Resources

- [Spring application external configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html)
