resource "azurecaf_name" "sb-ns" {
  name          = var.project_name
  resource_type = "azurerm_servicebus_namespace"
  prefixes      = length(var.resource_prefix) > 0 ? [var.resource_prefix] : []
  suffixes      = length(var.resource_suffix) > 0 ? [var.resource_suffix] : []
  random_length = var.resource_random_suffix_length
}


resource "azurerm_servicebus_namespace" "sb-ns" {
  name                = azurecaf_name.sb-ns.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  tags                = var.resource_tags
}

resource "azurerm_servicebus_topic" "sb-topic" {
  name                 = "topic"
  namespace_id         = azurerm_servicebus_namespace.sb-ns.id
  partitioning_enabled = false
}

resource "azurerm_servicebus_subscription" "topic-subscription" {
  name               = "subscription"
  topic_id           = azurerm_servicebus_topic.sb-topic.id
  max_delivery_count = 2
}

resource "azurerm_role_assignment" "topic-subscription-receiver" {
  scope                = azurerm_servicebus_subscription.topic-subscription.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.aks-msi.principal_id
}

resource "azurerm_servicebus_topic_authorization_rule" "topic-listen" {
  name     = "listen"
  topic_id = azurerm_servicebus_topic.sb-topic.id
  listen   = true
  send     = false
  manage   = false
}