# servicebus-workload-id

This application uses the [Azure SDK for Java](https://github.com/Azure/azure-sdk-for-java) to connect to an Azure Service Bus's topic subscription
authenticating with [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=java).

It creates a `ServiceBusProcessorClient` on application startup that logs incoming messages to the console.
The authentication via Workload Identity is provided by the [Azure Identity client library for Java](https://github.com/Azure/azure-sdk-for-java/tree/main/sdk/identity/azure-identity#azure-identity-client-library-for-java).

> **The point of this application is to give a reproducible setting for fixing native build problems
> caused by the Azure Identity library.**

## Prerequisites

The resource setup for this application is complex.
I recommend using the [Terraform](https://www.terraform.io/) configurations in the [../infra](../infra/README.md) directory to create them
so that you have a reproducible setup.

Locally installed tools:
- JDK 21
- Docker for building and pushing the image
- kubectl configured to point to a Kubernetes cluster
- Azure CLI (`az`) for logging in to the Azure Container Registry
- helm for deploying the application to Kubernetes

## Native image

_This native image build is started with_

```shell
./mvnw clean package -Dnative -Dquarkus.container-image.build
```

> I have not yet found a way to successfully complete the native image build.  
> **This is the point where I need help.**  

## Running the application

> This description assumes that you are using the reference setup with the Terraform configurations in the
> [../infra](../infra/README.md) directory and that you use the provided helm chart in the [helm](helm) directory.

### Running locally

In the reference setup, the only principal with access to the topic subscription is the
Workload Identity principal of the pod running the application.
This identity cannot be used outside the AKS cluster,
so the application cannot be run locally with `./mvnw quarkus:dev`.

### Running in Kubernetes

Set the name of the Azure Container Registry in [config/application.properties](src/main/resources/application.properties),
see [config/template.yaml](config/template.properties).

_Log in to the container registry, e.g., Azure Container Registry
(assuming the environment variable `REGISTRY` is set to the name of the registry):_

```shell
az acr login --name $REGISTRY
```

_Build and push the image `$REGISTRY/azure-quarkus-native-demo/servicebus-workload-id:latest`:_
```shell
./mvnw clean package -Dnative -Dquarkus.container-image.build -Dquarkus.container-image.push
```

_The native image build will fail.  
You may use a non-native image (JVM image) instead just to carry on:_

```shell
mvn clean package -Dquarkus.container-image.build -Dquarkus.container-image.push
```

Configure the deployment, see [helm/config/template.yaml](helm/config/template.yaml).

_Deploy or upgrade the application in the active kubectl context:_
```shell
helm upgrade --install servicebus-workload-id helm/servicebus-workload-id --values helm/config/values.yaml
```

_Watch the logs of the Pod:_

```shell
kubectl logs --follow pod/servicebus-workload-id
```

Now you can send a message to the topic subscription with the Service Bus Explorer of the Azure Dashboard
and watch the logs of the Pod to see if the message is received.

_Cleanup: uninstall the Helm release:_

```shell
helm uninstall servicebus-workload-id
```
