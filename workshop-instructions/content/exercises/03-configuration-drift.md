
This exercise walks you through how *Configuration Drift*
can occur and how to avoid it.

# Learning Outcomes

After completing the lab, you will be able to:

-   Explain an example case of *Configuratiodn Drift*

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

## Restart all instances
    
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

<Add some wording>

# Resources

<Add some resources>