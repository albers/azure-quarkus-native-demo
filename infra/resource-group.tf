resource "azurecaf_name" "rg" {
  name          = var.project_name
  resource_type = "azurerm_resource_group"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg.result
  location = var.azure_location
  tags     = var.resource_tags
}
