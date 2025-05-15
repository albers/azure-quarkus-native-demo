resource "azurecaf_name" "postgres" {
  name          = "${var.project_name}-postgres"
  resource_type = "azurerm_postgresql_server"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = azurecaf_name.postgres.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  zone                = "1"

  storage_mb = 32768
  sku_name   = "GP_Standard_D2s_v3"

  version = "16"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = var.azure_tenant_id
  }

  tags = var.resource_tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "workload_identity" {
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  resource_group_name = azurerm_postgresql_flexible_server.postgres.resource_group_name
  tenant_id           = var.azure_tenant_id
  object_id           = azurerm_user_assigned_identity.aks-msi.principal_id
  principal_name      = azurerm_user_assigned_identity.aks-msi.name
  principal_type      = "ServicePrincipal"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "user_access" {
  for_each = var.entra_id_users

  server_name         = azurerm_postgresql_flexible_server.postgres.name
  resource_group_name = azurerm_postgresql_flexible_server.postgres.resource_group_name
  tenant_id           = var.azure_tenant_id
  object_id           = each.value
  principal_name      = each.key
  principal_type      = "User"
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = "demo"
  server_id = azurerm_postgresql_flexible_server.postgres.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services_rule" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
