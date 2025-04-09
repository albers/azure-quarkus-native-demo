# infra

This subproject hosts terraform configurations to create the resources needed to run the demo applications.

It creates the following resources:

- Kubernetes cluster
  - a resource group
  - a minimal AKS Kubernetes cluster (one node, small VM size)
  - a managed identity for use as the application's workload identity
  - a federated credential for the managed identity to access Azure resources
- Container Registry
  - a resource group
  - an ACR registry
- Azure Service Bus
  - a resource group
  - an Azure Service Bus namespace
  - a topic and a subscription
  - a role assignment for the managed identity to access the Service Bus topic subscription
  - a shared access policy (SAS policy) for the Service Bus topic for access via connection string

**Access to the Service Bus topic subscription can either be authorized with Workload Identity or with a connection string.**

The project is configured with variables defined in the file [variables.tf](variables.tf).
See the hints at the beginning of that file how to customize the project.
Several naming strategies for the created resources are supported.

## Disclaimer

> The resources are not secured in any way.  
> This is a demo project and should not be used in production.  
> It does not represent any best practices or security guidelines.

## Prerequisites

This subproject assumes you have the following tools installed:
- [Terraform](https://www.terraform.io/)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`)

Log in to Azure with the CLI with `az login`.

You will also need an Azure subscription with enough permissions to create the resources.

## Create the resources

With all the prerequisites in place, you can run the following commands in this directory to create the resources:

Initialize the terraform project
```bash
terraform init
```

# Create the resources
```bash
terraform apply
```

After successfully creating the resources, Terraform will output several variables
that you will need to configure the demo applications.

To view these variables again, run
```bash
terraform output
```

# Cleanup

To destroy all the resources created by this project, run

```bash
terraform destroy
```
