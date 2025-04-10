# servicebus-connection-string

A demo application that connects to an Azure Service Bus topic authenticating with a connection string.

**Build and push**
```shell
mvn clean package -Dquarkus.container-image.build -Dquarkus.container-image.push
```

**Deploy or upgrade the application in the active kubectl context**
```shell
helm upgrade --install servicebus-connection-string helm/servicebus-connection-string --values helm/config/values.yaml
```

**Cleanup**
```shell
helm uninstall servicebus-connection-string
```
