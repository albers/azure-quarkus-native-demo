# This file contains the variables used in the Terraform configuration for the Quarkus Native Demo project.
# Create a file "terraform.tfvars" in the same directory to set the values for these variables.
# Not all values are required, most have sane defaults.
# The configuration file will be ignored by git.

### Where to create the resources

variable "azure_tenant_id" {
  type        = string
  description = "The tenant in which the resources should be created"
}

variable "azure_subscription_id" {
  type        = string
  description = "The subscription in which the resources should be created"
}

variable "azure_location" {
  type    = string
  default = "West US"
}

### Resource naming

variable "project_name" {
  type        = string
  default     = "quarkus-native-demo"
  description = "Name of the project. This will be used in the names of all resources."
}

variable "resource_prefix" {
  type        = string
  default     = ""
  description = "Optional prefix to all resource names. This is useful for resource grouping."
}

variable "resource_suffix" {
  type        = string
  default     = ""
  description = "Optional suffix to all resource names. This may be useful for compliance to corporate guidelines."
}

variable "resource_random_suffix_length" {
  type        = number
  default     = 5
  description = "Length of the random suffix to be added to resource names."
}

variable "application_namespace" {
  type        = string
  default     = "default"
  description = "Namespace for the Quarkus application in AKS."
}

### Resource tagging

variable "resource_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to all resources. This may be useful for compliance to corporate guidelines."
}

### Additional user access
# By default, only the Managed Identity can access the database and topic subscription via Workload Identity.
# If you want to access the resources from your workstation in Quarkus dev mode,
# you have give yourself additional user access.
# This can be achieved with this setting.
variable "entra_id_users" {
  type        = map(string)
  default     = {}
  description = "map of users ({ \"email\" = \"OID\" }) that should also be able to access the database and topic subscription."
}
