resource "azurecaf_name" "aks-rg" {
  name          = "${var.project_name}-aks"
  resource_type = "azurerm_resource_group"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_resource_group" "aks-rg" {
  name     = azurecaf_name.aks-rg.result
  location = var.azure_location
  tags     = var.resource_tags
}

resource "azurecaf_name" "aks" {
  name          = var.project_name
  resource_type = "azurerm_kubernetes_cluster"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = azurecaf_name.aks.result
  resource_group_name       = azurerm_resource_group.aks-rg.name
  location                  = azurerm_resource_group.aks-rg.location
  dns_prefix                = "${var.project_name}-aks"
  node_resource_group       = "${azurecaf_name.aks-rg.result}-internal"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name                        = "default"
    node_count                  = 1
    vm_size                     = "Standard_B2s"
    temporary_name_for_rotation = "temp"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = var.resource_tags
}

resource "azurecaf_name" "aks-msi" {
  name          = var.project_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_user_assigned_identity" "aks-msi" {
  location            = azurerm_kubernetes_cluster.aks.location
  name                = azurecaf_name.aks-msi.result
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
  tags                = var.resource_tags
}

resource "azurecaf_name" "msi-fedcred" {
  name          = var.project_name
  resource_type = "azurerm_federated_identity_credential"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_federated_identity_credential" "msi-fedcred" {
  name                = azurecaf_name.msi-fedcred.result
  resource_group_name = azurerm_user_assigned_identity.aks-msi.resource_group_name
  parent_id           = azurerm_user_assigned_identity.aks-msi.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject             = "system:serviceaccount:${var.application_namespace}:${azurerm_user_assigned_identity.aks-msi.name}"
}
