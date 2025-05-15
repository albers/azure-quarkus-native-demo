# postgres-workload-id

This application accesses an Azure Database for PostgreSQL flexible servers with Jakarta Persistence and authenticating with Workload Identity.
ORM mapping is simplified by using Panache.

All the application does is dump some sample data from the database to the console on startup.

## Prerequisites

Resources:
- An Azure Database for PostgreSQL flexible servers
- A Kubernetes cluster enabled for workload identity where you have permission to create deployments.

> See [../infra/README.md](../infra/README.md) for an automated way to create the resources for this demo.

Locally installed tools:
- JDK 21
- Docker for building and pushing the image
- Kubectl configured to point to the Kubernetes cluster
- Azure CLI (`az`) for logging in to the Azure Container Registry and retrieving tokens
- Helm for deploying the application to Kubernetes

## Authentication

The underlying JDBC driver requires the use of username and password.

To authenticate as a Microsoft Entra ID user, use your email as the username and an Entra ID token as the password.
Generate the token with
```shell
az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken -o tsv
```

For Workload Identity, use the name of the serviceaccount as the username and an Entra ID token as the password.
Acquisition of the token is transparently handled by the [Azure Identity Extension](https://github.com/quarkiverse/quarkus-azure-services/tree/main/common/azure-identity)
if you use the `DefaultAzureCredentialBuilder`.

In this project, we use an authentication plugin for Postgres provided by the [Azure identity authentication extensions plugin library for Java](https://learn.microsoft.com/en-us/java/api/overview/azure/identity-extensions-readme?view=azure-java-stable).
This plugin invokes the `DefaultAzureCredentialBuilder` to retrieve a token and use it as the password.
The plugin is activated by the `authenticationPluginClassName` parameter in the jdbc url.

### Quarkus dev mode

The authentication plugin can also be used in dev mode to authenticate you with the methods supported by the `DefaultAzureCredentialBuilder`.
However, this does not work well because Quarkus dev mode operates with multiple class loaders. 
To use the plugin in dev mode, you have to add the maven coordinates of `com.azure:azure-identity-extensions::jar` and all of its dependencies 
to `quarkus.class-loading.parent-first-artifacts`.
This will yield a long and hard to maintain list of dependencies.

An alternative is not to use the plugin but instead manually set `quarkus.datasource.password` to a token retrieved with `az`.
This project includes a custom MicroProfile `ConfigSource` that retrieves and supplies a token as password by calling `az`
whenever `quarkus.datasource.password` is not set.

I recommend using the Quarkus [dev services for databases](https://quarkus.io/guides/databases-dev-services),
which give you a local containerized Postgres database with excellent Quarkus integration.

## Running the application

> This description assumes that you are using the reference setup provided by the Terraform configurations in the
> [../infra](../infra/README.md) directory and that you use the helm chart in the [helm](helm) directory.

### Running locally

Run the application against a local containerized Postgres database
```shell
./mvnw quarkus:dev
```

If you configured user access for yourself in the reference environment and [added local configuration](config/template.properties),
you can run the application locally against the Azure database with

```shell
./mvnw quarkus:dev -Dquarkus.profile=azure
```

### Running in Kubernetes

Set the name of the Azure Container Registry in [config/application.properties](src/main/resources/application.properties),
see [config/template.yaml](config/template.properties).

Log in to the container registry, e.g., Azure Container Registry
(assuming the environment variable `REGISTRY` is set to the name of the registry):

```shell
az acr login --name $REGISTRY
```

Build and push the image `$REGISTRY/azure-quarkus-native-demo/postgres-workload-id:latest`:

```shell
./mvnw clean package -Dnative -Dquarkus.container-image.build -Dquarkus.container-image.push
```

Configure the deployment, see [helm/config/template.yaml](helm/config/template.yaml).

Deploy the application in the active kubectl context:

```shell
helm install postgres-workload-id helm/postgres-workload-id --values helm/config/values.yaml
```

Check the logs of the pod:

```shell
kubectl logs deployments/postgres-workload-id
```

Example output:

```text
2025-05-17 20:56:04,265 INFO  [de.hs.dem.azu.DatabaseDumper] (main) Person{givenName='Peter', familyName='Yarrow'}
2025-05-17 20:56:04,265 INFO  [de.hs.dem.azu.DatabaseDumper] (main) Person{givenName='Paul', familyName='Stookey'}
2025-05-17 20:56:04,265 INFO  [de.hs.dem.azu.DatabaseDumper] (main) Person{givenName='Mary', familyName='Travers'}
```

Cleanup: uninstall the Helm release:

```shell
helm uninstall postgres-workload-id
```

## Further reading

- Tutorial: [Connect to PostgreSQL Database from a Java Quarkus Container App without secrets using a managed identity](https://learn.microsoft.com/en-us/azure/container-apps/tutorial-java-quarkus-connect-managed-identity-postgresql-database?tabs=flexible)
- [Passwordless Connections Samples for Java Apps](https://github.com/Azure-Samples/Passwordless-Connections-for-Java-Apps)