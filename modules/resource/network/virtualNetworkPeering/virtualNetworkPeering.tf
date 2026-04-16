resource "azurerm_virtual_network_peering" "this" {
  name                = "npl-${var.application_purpose}-${var.environment}-${var.region}"
  resource_group_name = var.resource_group_name

  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = var.remote_virtual_network_id

  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
  allow_virtual_network_access = var.allow_virtual_network_access
}
