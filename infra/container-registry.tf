resource "azurecaf_name" "acr" {
  name          = var.project_name
  resource_type = "azurerm_container_registry"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_container_registry" "acr" {
  name                   = azurecaf_name.acr.result
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  sku                    = "Standard"
  admin_enabled          = false
  anonymous_pull_enabled = true
  tags                   = var.resource_tags
}
