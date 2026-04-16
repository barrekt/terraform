# -------------------------------------------------------
# Virtual Network
# -------------------------------------------------------

module "virtual_network" {
  source = "../../../resource/network/virtualNetwork"

  application_purpose     = var.application_purpose
  environment             = var.environment
  region                  = var.region
  resource_group_name     = var.resource_group_name
  location                = var.location
  address_space           = var.address_space
  dns_servers             = var.dns_servers
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  tags                    = var.tags
}

# -------------------------------------------------------
# Network Security Groups
# -------------------------------------------------------

module "network_security_groups" {
  source   = "../../../resource/network/networkSecurityGroup"
  for_each = var.network_security_groups

  application_purpose = "${var.application_purpose}-${each.key}"
  environment         = var.environment
  region              = var.region
  resource_group_name = var.resource_group_name
  location            = var.location
  security_rules      = each.value.security_rules
  tags                = var.tags
}

# -------------------------------------------------------
# Route Tables
# -------------------------------------------------------

module "route_tables" {
  source   = "../../../resource/network/routeTable"
  for_each = var.route_tables

  application_purpose           = "${var.application_purpose}-${each.key}"
  environment                   = var.environment
  region                        = var.region
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled
  routes                        = each.value.routes
  tags                          = var.tags
}

# -------------------------------------------------------
# Subnets
# -------------------------------------------------------

module "subnets" {
  source   = "../../../resource/network/subnet"
  for_each = var.subnets

  application_purpose                           = "${var.application_purpose}-${each.key}"
  environment                                   = var.environment
  region                                        = var.region
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = module.virtual_network.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  default_outbound_access_enabled               = each.value.default_outbound_access_enabled
  network_security_group_id                     = each.value.nsg_key != null ? module.network_security_groups[each.value.nsg_key].id : null
  route_table_id                                = each.value.route_table_key != null ? module.route_tables[each.value.route_table_key].id : null
  delegation                                    = each.value.delegation
}

# -------------------------------------------------------
# Hub Peering
# -------------------------------------------------------

module "hub_peering" {
  source = "../../../resource/network/virtualNetworkPeering"

  application_purpose          = var.application_purpose
  environment                  = var.environment
  region                       = var.region
  resource_group_name          = var.resource_group_name
  virtual_network_name         = module.virtual_network.name
  remote_virtual_network_id    = var.hub_peering.remote_virtual_network_id
  allow_forwarded_traffic      = var.hub_peering.allow_forwarded_traffic
  allow_gateway_transit        = var.hub_peering.allow_gateway_transit
  use_remote_gateways          = var.hub_peering.use_remote_gateways
  allow_virtual_network_access = var.hub_peering.allow_virtual_network_access
}
