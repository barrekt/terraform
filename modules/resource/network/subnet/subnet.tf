resource "azurerm_subnet" "this" {
  name                 = "snet-${var.application_purpose}-${var.environment}-${var.region}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes  = var.address_prefixes
  service_endpoints = var.service_endpoints

  private_endpoint_network_policies             = var.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  default_outbound_access_enabled               = var.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.service_actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.network_security_group_id != null ? 1 : 0

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_subnet_route_table_association" "this" {
  count = var.route_table_id != null ? 1 : 0

  subnet_id      = azurerm_subnet.this.id
  route_table_id = var.route_table_id
}
