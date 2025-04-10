# servicebus-workload-id

A demo application that connects to an Azure Service Bus topic authenticating with Workload Identity.

**Build and push**
```shell
mvn clean package -Dquarkus.container-image.build -Dquarkus.container-image.push
```

**Deploy or upgrade the application in the active kubectl context**
```shell
helm upgrade --install servicebus-workload-id helm/servicebus-workload-id --values helm/config/values.yaml
```

**Cleanup**
```shell
helm uninstall servicebus-workload-id
```
