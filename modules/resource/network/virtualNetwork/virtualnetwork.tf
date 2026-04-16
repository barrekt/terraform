resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.application_purpose}-${var.environment}-${var.region}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space           = var.address_space
  dns_servers             = var.dns_servers
  flow_timeout_in_minutes = var.flow_timeout_in_minutes

  tags = var.tags
}
