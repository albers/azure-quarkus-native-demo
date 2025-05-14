# azure-quarkus-native-demo

This project demonstrates how various Azure resources can be accessed from a Quarkus application running in an AKS Kubernetes Cluster
when using [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=java) for authentication.
The project has a clear focus on solutions that can be compiled to a [native image](https://quarkus.io/guides/building-native-image) using GraalVM.

>The original purpose of this project was to illustrate problems with the native image build when using Workload Identity.
These issues are now resolved, thanks to @backwind1233 in [PR #1](https://github.com/albers/azure-quarkus-native-demo/pull/1).
Further improvements were made by the new [Azure Service Bus Extension](https://docs.quarkiverse.io/quarkus-azure-services/dev/quarkus-azure-servicebus.html)
of the [Quarkus Azure Services](https://github.com/quarkiverse/quarkus-azure-services).

## Projects

### [infra](infra/README.md)

This is a Terraform-based infrastructure project that creates the resources needed for the demo applications.
The setup for the Workload Identity application is quite complex,
so I created this project to provide a reference environment.

### [servicebus-workload-id](servicebus-workload-id/README.md)

This application accesses an Azure Service Bus using Workload Identity for authentication.

### [servicebus-connection-string](servicebus-connection-string/README.md)

This application accesses an Azure Service Bus using a connection string (SAS key) for authentication.

### [postgres-workload-id](postgres-workload-id/README.md)

An application that accesses an Azure Database for PostgreSQL flexible servers using Workload Identity for authentication.

## Disclaimer

The code in this repository is for demonstration purposes only.  
It does not follow best practices for production code,
nor does it present any security guidelines.
