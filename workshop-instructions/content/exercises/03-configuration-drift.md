
This exercise walks you through how *Configuration Drift*
can occur and how to avoid it.

# Learning Outcomes

After completing the lab, you will be able to:

-   Describe an example scenario of *Configuration Drift* that can occur
    on a modern orchestration platform.
-   Describe a method avoiding *Configuration Drift* while running on a
    modern orchestration platform.

## Get started

1.  Make sure you are in your `~/exercises/k8s` directory now in
    both of your terminal windows,
    and clear both:

    ```terminal:execute-all
    command: cd ~/exercises/k8s
    ```

    ```terminal:clear-all
    ```

## Change the configuration

Here you are going to change a value of a configuration
property in the `ConfigMap`.

You will see if the updated value will be applied to running
application instances,
both existing prior to the configuration change as well as started
after the configuration change is applied.

1.  Change the value of `welcome.message` in the `configmap.yaml`
    manually from the editor:

    ```editor:select-matching-text
    file: ~/exercises/k8s/configmap.yaml
    text: "hello"
    ```

    or run the following command

    ```terminal:execute
    command: sed -i "s/hello/hello2/g" configmap.yaml
    session: 1
    ```

1.  Apply the changed `configmap.yaml`

    ```terminal:execute
    command: kubectl apply -f configmap.yaml
    session: 1
    ```

1.  Access the application and observe that the response is
    still "hello from kubernetes" not "hello2 from kubernetes".

    ```terminal:execute
    command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
    session: 2
    ```

1.  Apply the `deployment.yaml`

    ```terminal:execute
    command: kubectl apply -f deployment.yaml
    session: 1
    ```

    Do you see any changes to the `pal-tracker` deployment?

    Note that the `ConfigMap` changes are separate from the deployment,
    and that you might consider Kubernetes playing the role of a
    *Backing Service* to provide a source of configuration to your
    deployment during its processes start up time.

1.  Access the application and observe that the response:

    ```terminal:execute
    command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
    session: 2
    ```

   *Is it still "hello from kubernetes" not "hello2 from kubernetes"?*

At this point you have not restarted the existing `pal-tracker`
deployment.

The `pal-tracker` application deployment consists of your `pal-tracker`
Spring Boot app running in a process inside of your deployment's
container.
It sources the `WELCOME_MESSAGE` environment variable from the container
profile during the deployment (and associated container) startup.
Neither the container profile, nor the Spring Boot application, have
any idea about the new environment variable until the Spring Boot
application process is disposed,
and restarted with an update container profile with the new environment
variable value.

## Add instances

In Cloud Native applications, if the load on an application deployment
grows,
an app operator will add capacity to that deployment by adding process
instances.
If the load on an application deployment shrinks,
an app operator will remove capacity from the deployment by removing
process instances.

This is called *Scaling*,
and we will cover that at depth in a later track.

One problem with scaling up (adding process instances) is that if the
`ConfigMap` has changed,
the current running instances will not have that change applied,
but any new instances starting up after the configuration change will.

We are going to "scale up" the `pal-tracker` instances from 1 to 3 to
verify that behavior.
Note that the feature in Kubernetes to specify the number of containers
and associated process instances is call *Replica*:

1.  Scale up the instances to 3

    ```terminal:execute
    command: kubectl scale --replicas=3 deployment.apps/pal-tracker
    session: 1
    ```

1.  Verify the number of instances is now 3

    ```terminal:execute
    command: kubectl get all
    session: 1
    ```
    
1.  Access the application multiple times and observe
    that the ratio of
    responses between "hello from kubernetes" not "hello2 from kubernetes" is roughly 1:2.

    ```terminal:execute
    command: for i in $(seq 9); do curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN} && sleep 1; done
    session: 2
    ```

    This indicates that the newly created instances picked
    up the new `welcome.message` configuration value while
    the existing one still uses the old configuration value.
    This is an example of *Configuration Drift*.

## Restart all instances

You are going to restart all application instances and
see if they all pick up the new configuration value.

1.  Rollout the application

    ```terminal:execute
    command: kubectl rollout restart deployment.apps/pal-tracker
    session: 1
    ```

1.  Access the application multiple times and observe
    that all responses include
    "hello2 from kubernetes".

    ```terminal:execute
    command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
    session: 2
    ```


# Wrap

In this exercise, you did observe an example scenario
of *Configuration Drift*,
in which application instances are becoming different
as time goes on.
This problem could be even more exacerbated through
usage of auto-scaling that is not coordinated with your
configuration updates.

One way to avoid *Configuration Drift* is to restart an *Application Deployment*,
where all instances are disposed and re-started as part of applying a new configuration.

This may cause another problem in that your application deployment may
experience a brief downtime.

We will explore a solution to that problem in a subsequent track.

# Resources

- [Configuration Drift](http://kief.com/configuration-drift.html)
- [ConfigurationSynchronization](https://martinfowler.com/bliki/ConfigurationSynchronization.html)
- [Scaling Your App](https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/)
- [Deployments - Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
