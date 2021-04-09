
This exercise walks you through how *Configuration Drift*
can occur and how to avoid it.

# Learning Outcomes

After completing the lab, you will be able to:

-   Describe an example scenario of *Configuratiodn Drift*
-   Describe a scheme of how to avoid *Configuratiodn Drift*

## Get started

1.  Make sure you are in your `~/exercises/k8s` directory now in
    both of your terminal windows,
    and clear both:

    ```terminal:execute-all
    command: cd ~/exercises/k8s
    ```

    ```terminal:clear-all
    ```

## Change ConfigMap

Here you are going to change a value of a configuration
property in the ConfigMap.
You will see if this value will be picked up by all
application instances (existing and new instances through
scaling up) or not.

1.  Change the value of `welcome.message` in the `configmap.yaml` 
    manually from the editor

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

1.  Access the application and observe that the response is 
    still "hello from kubernetes" not "hello2 from kubernetes".

    ```terminal:execute
    command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
    session: 2
    ```

## Scale up the number of instances

An app operator uses horizontal scaling to scale up or down
the number of application instances in order to accomodate
changing number of client requests.

Now here we are going to scale up the `pal-tracker` instances
from 1 to 3 and see if all instances (existing and newly created instances) will
pick up the new configuration value in the ConfigMap.

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
    command: curl -i http://pal-tracker.${SESSION_NAMESPACE}.${INGRESS_DOMAIN}
    session: 2
    ```

    This indicates that the newly created instances picked
    up the new `welcome.message` configuration value while
    the existing one still uses the old configuration value.
    This is an example of *Configuration Drift*.

## Restart all instances

One way to avoid *Configuration Drift* is to restart all
application instances on a periodic basis through 
automation.
    
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

# Resources

- [Configuration Drift](http://kief.com/configuration-drift.html)
- [ConfigurationSynchronization](https://martinfowler.com/bliki/ConfigurationSynchronization.html)
- [Scaling Your App](https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/)
- [Deployments - Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)