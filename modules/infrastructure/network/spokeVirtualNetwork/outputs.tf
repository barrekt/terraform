# -------------------------------------------------------
# Virtual Network
# -------------------------------------------------------

output "virtual_network_id" {
  description = "The resource ID of the spoke Virtual Network."
  value       = module.virtual_network.id
}

output "virtual_network_name" {
  description = "The name of the spoke Virtual Network."
  value       = module.virtual_network.name
}

# -------------------------------------------------------
# Subnets
# -------------------------------------------------------

output "subnet_ids" {
  description = "A map of subnet key to subnet resource ID."
  value       = { for k, v in module.subnets : k => v.id }
}

output "subnet_names" {
  description = "A map of subnet key to subnet name."
  value       = { for k, v in module.subnets : k => v.name }
}

# -------------------------------------------------------
# Network Security Groups
# -------------------------------------------------------

output "nsg_ids" {
  description = "A map of NSG key to Network Security Group resource ID."
  value       = { for k, v in module.network_security_groups : k => v.id }
}

# -------------------------------------------------------
# Route Tables
# -------------------------------------------------------

output "route_table_ids" {
  description = "A map of route table key to Route Table resource ID."
  value       = { for k, v in module.route_tables : k => v.id }
}

# -------------------------------------------------------
# Hub Peering
# -------------------------------------------------------

output "hub_peering_id" {
  description = "The resource ID of the Virtual Network Peering to the hub."
  value       = module.hub_peering.id
}
