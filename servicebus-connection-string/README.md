# servicebus-connection-string

This application uses the [Azure Service Bus Extension](https://docs.quarkiverse.io/quarkus-azure-services/dev/quarkus-azure-servicebus.html)
of the [Quarkus Azure Services](https://github.com/quarkiverse/quarkus-azure-services) to connect to an Azure Service Bus's topic subscription
**authenticating with a connection string**.

It creates a `ServiceBusProcessorClient` on application startup that logs incoming messages to the console.

> The point of this application is to show that it can be compiled to a native image that still functions when deployed to a Kubernetes cluster.

## Prerequisites

Resources:
- An Azure Service Bus with a topic and subscription that can be accessed with a connection string.
- A Kubernetes cluster where you have permission to create pods.

> See [../infra/README.md](../infra/README.md) for an automated way to create the resources for this demo.

Locally installed tools:
- JDK 21
- Docker for building and pushing the image
- kubectl configured to point to a Kubernetes cluster 
- Azure CLI (`az`) for logging in to the Azure Container Registry (if you use one)
- helm for deploying the application to Kubernetes (optional)

## Native image

Due to the support provided by the Quarkus Azure Services,
this application can be built as a native image and packaged in a container with

```shell
./mvnw clean package -Dnative -Dquarkus.container-image.build
```

## Running the application

I recommend first running the application locally in dev mode to see if the connection to the Azure Service Bus works.
If so, you can build the native image and deploy it to a Kubernetes cluster.

### Running locally

The recommended way to configure the application for local execution is to create a `config/application.properties` file.
This is described in [config/template.properties](config/template.properties).

This configuration allows the application to run locally with
```shell
./mvnw quarkus:dev
```

There will be a lot of log output produced by the Azure SDK for Java.
After a few seconds, no more messages should be produced.
Continuing messages are a sign of configuration or permission issues.

Verify that the application can receive messages by sending a message to the topic subscription
with the Service Bus Explorer of the Azure Dashboard.

Example output after receiving the message "Hello World!":
```text
2025-04-14 11:45:09,854 INFO  [de.hs.dem.azu.ServiceBusSubscriber] (receiverPump-2) Received message 0e2971edbc4246cca0d3d3832724049e: Hello World!
```

### Running in Kubernetes

This step requires you to build the Docker image and push it to a container registry
that is accessible from the Kubernetes cluster.
The name of the registry is set in [config/application.properties](config/application.properties),
see [config/template.properties](config/template.properties).

_Log in to the container registry, e.g., Azure Container Registry
(assuming the environment variable `REGISTRY` is set to the name of the registry):_

```shell
az acr login --name $REGISTRY
```

_Build and push the image `$REGISTRY/azure-quarkus-native-demo/servicebus-connection-string:latest`:_
```shell
./mvnw clean package -Dnative -Dquarkus.container-image.build -Dquarkus.container-image.push
```

_Run as a Pod in Kubernetes (in the active kubectl context):_
```shell
kubectl run servicebus-connection-string --image $REGISTRY/azure-quarkus-native-demo/servicebus-connection-string:latest
```

_Watch the logs of the Pod:_
```shell
kubectl logs --follow pod/servicebus-connection-string
```

Now you can send a message to the topic subscription with the Service Bus Explorer of the Azure Dashboard
and watch the logs of the Pod to see if the message is received.

_Cleanup: remove the pod:_

```shell
kubectl delete pod/servicebus-connection-string
```

### Deploying with Helm

Alternatively, you can deploy the application with Helm.
See [helm/config/template.yaml](helm/config/template.yaml) for how to configure the Helm chart.

_Deploy the application in the active kubectl context:_

```shell
helm install servicebus-connection-string helm/servicebus-connection-string --values helm/config/values.yaml
```

_Watch the logs of the pod:_

```shell
kubectl logs --follow deployments/servicebus-connection-string
```

_Cleanup: uninstall the Helm release:_

```shell
helm uninstall servicebus-connection-string
```
